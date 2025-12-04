'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { useEffect, useState, useCallback } from 'react'
import { FiUserPlus, FiCheck, FiX, FiUsers, FiMapPin, FiUser, FiLogOut, FiArrowLeft, FiZap, FiMessageSquare } from 'react-icons/fi'
import { userService, type User, type FriendshipStatus, type FriendSuggestion } from '@/services/userService'
import { messagingService } from '@/services/messagingService'
import FilterBar from '@/components/FilterBar'
import toast from 'react-hot-toast'
import { getUniversityName } from '@/utils/typeHelpers'

const UNIVERSITIES = [
  'ESMT',
  'UCAD',
  'UGB',
  'ESP',
  'UASZ',
  'Université de Thiès',
]

export default function StudentsPage() {
  const { user, loading, logout } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [students, setStudents] = useState<User[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedUniversity, setSelectedUniversity] = useState<string>('')
  const [friendshipStatuses, setFriendshipStatuses] = useState<Record<string, FriendshipStatus>>({})
  const [suggestions, setSuggestions] = useState<FriendSuggestion[]>([])
  const [isLoadingSuggestions, setIsLoadingSuggestions] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    } else if (mounted && user) {
      loadSuggestions()
    }
  }, [mounted, user, loading, router])

  const loadSuggestions = async () => {
    if (!user) return
    setIsLoadingSuggestions(true)
    try {
      const data = await userService.getFriendSuggestions(6)
      setSuggestions(Array.isArray(data) ? data : [])
    } catch (error: any) {
      console.error('Error loading friend suggestions:', error)
    } finally {
      setIsLoadingSuggestions(false)
    }
  }

  const loadStudents = useCallback(async () => {
    if (!user) return
    
    setIsLoading(true)
    try {
      const params: any = {
        verified_only: true,
      }
      
      if (selectedUniversity) {
        params.university = selectedUniversity
      }
      
      if (searchTerm) {
        params.search = searchTerm
      }

      const response = await userService.getUsers(params)
      
      // Simplified response handling - no pagination
      let studentsList: User[] = []
      
      // Safe response parsing
      if (!response) {
        studentsList = []
      } else if (Array.isArray(response)) {
        studentsList = response
      } else if (response && typeof response === 'object' && response !== null) {
        const responseObj = response as any
        // Try to get results if paginated response, otherwise use data or empty array
        studentsList = Array.isArray(responseObj.results) 
          ? responseObj.results 
          : Array.isArray(responseObj.data) 
            ? responseObj.data 
            : []
      }
      
      setStudents(studentsList)
      
      // Load friendship statuses for all students
      if (studentsList.length > 0) {
        const statusPromises = studentsList.map((student: User) =>
          userService.getFriendshipStatus(student.id)
            .then(status => ({ id: student.id, status }))
            .catch(() => ({ id: student.id, status: { status: 'none' } as FriendshipStatus }))
        )
        const statuses = await Promise.all(statusPromises)
        const statusMap: Record<string, FriendshipStatus> = {}
        statuses.forEach(({ id, status }) => {
          statusMap[id] = status
        })
        setFriendshipStatuses(statusMap)
      }
    } catch (error: any) {
      // Error handled silently, students list will remain empty
      setStudents([])
    } finally {
      setIsLoading(false)
    }
  }, [user, searchTerm, selectedUniversity])

  useEffect(() => {
    if (user) {
      loadStudents()
    }
  }, [user, loadStudents])

  const handleFriendAction = async (studentId: string, action: 'send' | 'accept' | 'reject' | 'remove') => {
    if (!user) return

    try {
      switch (action) {
        case 'send':
          await userService.sendFriendRequest(studentId)
          break
        case 'accept':
          // Find the friendship ID from friend requests
          const requests = await userService.getFriendRequests()
          const request = requests.find((r: any) => r.from_user.id === studentId)
          if (request) {
            await userService.acceptFriendRequest(request.id)
          }
          break
        case 'reject':
          const requests2 = await userService.getFriendRequests()
          const request2 = requests2.find((r: any) => r.from_user.id === studentId)
          if (request2) {
            await userService.rejectFriendRequest(request2.id)
          }
          break
        case 'remove':
          // Find the friendship ID
          const friends = await userService.getFriends()
          const friend = friends.find((f: User) => f.id === studentId)
          // We'd need the friendship ID, but for now just reload
          break
      }
      await loadStudents()
    } catch (error) {
      // Error handled silently
    }
  }

  if (!mounted || loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 to-secondary-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Chargement...</p>
        </div>
      </div>
    )
  }

  if (!user) {
    return null
  }

  const getFriendButton = (student: User | FriendSuggestion) => {
    const status = friendshipStatuses[student.id]
    
    if (!status || status.status === 'none') {
      return (
        <button
          onClick={() => handleFriendAction(student.id, 'send')}
          className="w-full flex items-center justify-center gap-2 px-4 py-2.5 bg-primary-600 text-white rounded-xl hover:bg-primary-700 transition-all duration-200 text-sm font-semibold shadow-md hover:shadow-lg hover:-translate-y-0.5"
        >
          <FiUserPlus className="w-4 h-4" />
          Ajouter
        </button>
      )
    }
    
    if (status.status === 'friends') {
      return (
        <div className="w-full flex gap-2">
          <button
            onClick={async () => {
              try {
                const conversation = await messagingService.createPrivateConversation(student.id)
                router.push(`/messages`)
                toast.success('Conversation ouverte')
              } catch (error: any) {
                console.error('Error creating conversation:', error)
                toast.error(error?.response?.data?.error || 'Erreur lors de la création de la conversation')
              }
            }}
            className="flex-1 flex items-center justify-center gap-2 px-3 py-2.5 bg-primary-600 text-white rounded-xl hover:bg-primary-700 transition-all duration-200 text-sm font-semibold shadow-md hover:shadow-lg"
            title="Envoyer un message"
          >
            <FiMessageSquare className="w-4 h-4" />
            <span className="hidden sm:inline">Message</span>
          </button>
          <button
            disabled
            className="px-3 py-2.5 bg-green-100 text-green-700 rounded-xl cursor-not-allowed text-sm font-semibold flex items-center justify-center"
            title="Ami"
          >
            <FiCheck className="w-4 h-4" />
          </button>
        </div>
      )
    }
    
    if (status.status === 'request_sent') {
      return (
        <button
          disabled
          className="w-full flex items-center justify-center gap-2 px-4 py-2.5 bg-gray-100 text-gray-700 rounded-xl cursor-not-allowed text-sm font-semibold"
        >
          <FiCheck className="w-4 h-4" />
          En attente
        </button>
      )
    }
    
    if (status.status === 'request_received') {
      return (
        <div className="w-full flex gap-2">
          <button
            onClick={() => handleFriendAction(student.id, 'accept')}
            className="flex-1 flex items-center justify-center gap-2 px-3 py-2.5 bg-green-600 text-white rounded-xl hover:bg-green-700 transition-all duration-200 text-sm font-semibold shadow-md hover:shadow-lg"
          >
            <FiCheck className="w-4 h-4" />
            Accepter
          </button>
          <button
            onClick={() => handleFriendAction(student.id, 'reject')}
            className="px-3 py-2.5 bg-red-600 text-white rounded-xl hover:bg-red-700 transition-all duration-200 shadow-md hover:shadow-lg"
          >
            <FiX className="w-4 h-4" />
          </button>
        </div>
      )
    }
    
    return null
  }

  const handleLogout = () => {
    logout()
    router.push('/')
  }

  const handleGoBack = () => {
    router.push('/dashboard')
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
      {/* Header - CampusLink Design */}
      <header className="bg-gradient-to-r from-primary-600 via-primary-500 to-secondary-600 shadow-lg border-b border-primary-700 sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-3 sm:py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <button
                onClick={handleGoBack}
                className="p-2 text-white hover:bg-white/20 rounded-xl transition-all duration-200"
                title="Retour"
              >
                <FiArrowLeft className="w-5 h-5 sm:w-6 sm:h-6" />
              </button>
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 sm:w-12 sm:h-12 bg-white/20 backdrop-blur-sm rounded-xl flex items-center justify-center shadow-lg">
                  <FiUsers className="w-6 h-6 sm:w-7 sm:h-7 text-white" />
                </div>
                <div>
                  <h1 className="text-xl sm:text-2xl font-bold text-white drop-shadow-lg">Découvrir les Étudiants</h1>
                  <p className="text-white/90 text-xs sm:text-sm hidden sm:block">Trouvez et connectez-vous avec d&apos;autres étudiants</p>
                </div>
              </div>
            </div>
            <button
              onClick={handleLogout}
              className="flex items-center gap-2 px-3 sm:px-4 py-2 sm:py-2.5 bg-white/20 hover:bg-white/30 backdrop-blur-sm text-white rounded-xl transition-all duration-300 shadow-md hover:shadow-lg hover:scale-105 border border-white/30"
              title="Déconnexion"
            >
              <FiLogOut className="w-4 h-4 sm:w-5 sm:h-5" />
              <span className="hidden sm:inline font-semibold">Déconnexion</span>
            </button>
          </div>
        </div>
      </header>
      
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 sm:py-6 lg:py-8">

        {/* Friend Suggestions Section - Enhanced Design */}
        {suggestions.length > 0 && (
          <div className="bg-white rounded-2xl shadow-xl p-5 sm:p-6 mb-6 border border-gray-100">
            <div className="flex items-center gap-3 mb-5">
              <div className="w-10 h-10 bg-gradient-to-br from-primary-500 to-secondary-500 rounded-xl flex items-center justify-center shadow-lg">
                <FiZap className="w-5 h-5 text-white" />
              </div>
              <div>
                <h2 className="text-lg sm:text-xl font-bold text-gray-900">Suggestions d'amis</h2>
                <p className="text-sm text-gray-600">Personnes que vous pourriez connaître</p>
              </div>
            </div>
            {isLoadingSuggestions ? (
              <div className="text-center py-8">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
                <p className="mt-4 text-gray-600 text-sm">Chargement des suggestions...</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                {suggestions.map((suggestion) => {
                  const status = friendshipStatuses[suggestion.id] || { status: 'none' }
                  return (
                    <div
                      key={suggestion.id}
                      className="group bg-gradient-to-br from-white to-gray-50 rounded-xl p-4 border border-gray-200 hover:border-primary-300 hover:shadow-xl transition-all duration-300 hover:-translate-y-1"
                    >
                      <div className="flex items-start gap-3">
                        <Link href={`/users/${suggestion.id}`} className="flex-shrink-0">
                          <div className="w-12 h-12 bg-gradient-to-br from-primary-500 to-secondary-500 rounded-full flex items-center justify-center">
                            <FiUser className="w-6 h-6 text-white" />
                          </div>
                        </Link>
                        <div className="flex-1 min-w-0">
                          <Link href={`/users/${suggestion.id}`}>
                            <h3 className="font-semibold text-gray-900 truncate">
                              {suggestion.first_name && suggestion.last_name
                                ? `${suggestion.first_name} ${suggestion.last_name}`
                                : suggestion.username}
                            </h3>
                          </Link>
                          {suggestion.profile?.university && (
                            <p className="text-sm text-gray-600 truncate">
                              {getUniversityName(suggestion.profile.university)}
                            </p>
                          )}
                          {suggestion.suggestion_reasons && suggestion.suggestion_reasons.length > 0 && (
                            <div className="mt-2 flex flex-wrap gap-1">
                              {suggestion.suggestion_reasons.map((reason: string, idx: number) => (
                                <span
                                  key={idx}
                                  className="text-xs px-2 py-1 bg-primary-100 text-primary-700 rounded-full"
                                >
                                  {reason}
                                </span>
                              ))}
                            </div>
                          )}
                        </div>
                        <div className="flex-shrink-0">
                          {getFriendButton(suggestion)}
                        </div>
                      </div>
                    </div>
                  )
                })}
              </div>
            )}
          </div>
        )}

        {/* Filters */}
        <FilterBar
          searchPlaceholder="Rechercher par nom, email..."
          searchValue={searchTerm}
          onSearchChange={(value) => {
            setSearchTerm(value)
          }}
          filters={[
            {
              label: 'Filtrer par école',
              name: 'university',
              options: UNIVERSITIES.map((u) => ({ value: u, label: u })),
              value: selectedUniversity,
              onChange: (value) => {
                setSelectedUniversity(value)
              },
            },
          ]}
          onReset={() => {
            setSearchTerm('')
            setSelectedUniversity('')
          }}
        />

        {/* Students List */}
        {isLoading ? (
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Chargement des étudiants...</p>
          </div>
        ) : students.length === 0 ? (
          <div className="bg-white rounded-2xl shadow-lg p-8 sm:p-12 text-center">
            <FiUsers className="w-12 h-12 sm:w-16 sm:h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg sm:text-xl font-semibold text-gray-900 mb-2">Aucun étudiant trouvé</h3>
            <p className="text-gray-600 text-sm sm:text-base">
              {searchTerm || selectedUniversity
                ? 'Essayez de modifier vos critères de recherche.'
                : 'Il n\'y a pas encore d\'étudiants vérifiés sur la plateforme.'}
            </p>
          </div>
        ) : (
          <>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 sm:gap-5 lg:gap-6">
              {students.map((student) => (
                <div
                  key={student.id}
                  className="group bg-white rounded-xl shadow-lg overflow-hidden hover:shadow-2xl transition-all duration-300 border border-gray-200 hover:border-primary-300 hover:-translate-y-1"
                >
                  <Link href={`/users/${student.id}`} className="block">
                    <div className="p-4 sm:p-5 cursor-pointer">
                      {/* Avatar - Enhanced */}
                      <div className="flex flex-col items-center text-center mb-4">
                        <div className="relative w-16 h-16 sm:w-20 sm:h-20 bg-gradient-to-br from-primary-500 to-secondary-500 rounded-full flex items-center justify-center flex-shrink-0 mb-3 border-4 border-white shadow-xl group-hover:scale-110 transition-transform duration-300">
                          {student.profile?.profile_picture ? (
                            <img
                              src={student.profile.profile_picture}
                              alt={student.first_name && student.last_name
                                ? `${student.first_name} ${student.last_name}`
                                : student.username}
                              className="w-full h-full rounded-full object-cover"
                            />
                          ) : (
                            <FiUser className="w-8 h-8 sm:w-10 sm:h-10 text-white" />
                          )}
                        </div>
                        <div className="w-full">
                          <h3 className="text-base sm:text-lg font-bold text-gray-900 truncate group-hover:text-primary-600 transition-colors">
                            {student.first_name && student.last_name
                              ? `${student.first_name} ${student.last_name}`
                              : student.username}
                          </h3>
                          <p className="text-xs sm:text-sm text-gray-500 truncate mt-1">@{student.username}</p>
                        </div>
                      </div>

                      {/* University - Enhanced */}
                      {student.profile?.university && (
                        <div className="flex items-center justify-center gap-2 mb-3 p-2 bg-gray-50 rounded-lg">
                          <FiMapPin className="w-4 h-4 text-primary-600 flex-shrink-0" />
                          <span className="text-xs sm:text-sm text-gray-700 font-medium truncate text-center">
                            {getUniversityName(student.profile.university)}
                          </span>
                        </div>
                      )}

                      {/* Field of Study - Enhanced */}
                      {student.profile?.field_of_study && (
                        <div className="text-center mb-4">
                          <p className="text-xs sm:text-sm text-gray-600 bg-primary-50 rounded-lg px-3 py-1.5 inline-block">
                            {student.profile.field_of_study}
                          </p>
                        </div>
                      )}
                    </div>
                  </Link>
                  
                  {/* Friend Button - Enhanced */}
                  <div className="px-4 sm:px-5 pb-4 sm:pb-5 flex justify-center" onClick={(e) => e.stopPropagation()}>
                    {getFriendButton(student)}
                  </div>
                </div>
              ))}
            </div>

          </>
        )}
      </div>
    </div>
  )
}

