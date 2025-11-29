'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { useEffect, useState, useCallback } from 'react'
import { FiUserPlus, FiCheck, FiX, FiUsers, FiMapPin, FiUser, FiLogOut, FiArrowLeft, FiZap } from 'react-icons/fi'
import { userService, type User, type FriendshipStatus, type FriendSuggestion } from '@/services/userService'
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
          className="flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition text-sm"
        >
          <FiUserPlus className="w-4 h-4" />
          Ajouter
        </button>
      )
    }
    
    if (status.status === 'friends') {
      return (
        <button
          disabled
          className="flex items-center gap-2 px-4 py-2 bg-green-100 text-green-700 rounded-lg cursor-not-allowed text-sm"
        >
          <FiCheck className="w-4 h-4" />
          Ami
        </button>
      )
    }
    
    if (status.status === 'request_sent') {
      return (
        <button
          disabled
          className="flex items-center gap-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg cursor-not-allowed text-sm"
        >
          <FiCheck className="w-4 h-4" />
          En attente
        </button>
      )
    }
    
    if (status.status === 'request_received') {
      return (
        <div className="flex gap-2">
          <button
            onClick={() => handleFriendAction(student.id, 'accept')}
            className="flex items-center gap-2 px-3 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition text-sm"
          >
            <FiCheck className="w-4 h-4" />
            Accepter
          </button>
          <button
            onClick={() => handleFriendAction(student.id, 'reject')}
            className="flex items-center gap-2 px-3 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition text-sm"
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
      {/* Header with navigation and logout */}
      <header className="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-3 sm:py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3 sm:gap-4">
              <button
                onClick={handleGoBack}
                className="p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition"
                title="Retour"
              >
                <FiArrowLeft className="w-5 h-5 sm:w-6 sm:h-6" />
              </button>
              <div>
                <h1 className="text-xl sm:text-2xl font-bold text-gray-900">Découvrir les Étudiants</h1>
                <p className="text-gray-600 text-xs sm:text-sm hidden sm:block">Trouvez et connectez-vous avec d&apos;autres étudiants</p>
              </div>
            </div>
            <button
              onClick={handleLogout}
              className="flex items-center gap-2 px-3 sm:px-4 py-2 text-sm sm:text-base text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition"
              title="Déconnexion"
            >
              <FiLogOut className="w-4 h-4 sm:w-5 sm:h-5" />
              <span className="hidden sm:inline">Déconnexion</span>
            </button>
          </div>
        </div>
      </header>
      
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 sm:py-6 lg:py-8">

        {/* Friend Suggestions Section */}
        {suggestions.length > 0 && (
          <div className="bg-white rounded-2xl shadow-lg p-4 sm:p-6 mb-6">
            <div className="flex items-center gap-2 mb-4">
              <FiZap className="w-5 h-5 text-primary-600" />
              <h2 className="text-lg sm:text-xl font-bold text-gray-900">Suggestions d'amis</h2>
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
                      className="bg-gray-50 rounded-xl p-4 border border-gray-200 hover:border-primary-300 transition"
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
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 sm:gap-6">
              {students.map((student) => (
                <div
                  key={student.id}
                  className="bg-white dark:bg-gray-800 rounded-xl shadow-md overflow-hidden hover:shadow-lg transition"
                >
                  <Link href={`/users/${student.id}`} className="block">
                    <div className="p-4 sm:p-6 cursor-pointer">
                      {/* Avatar */}
                      <div className="flex items-center gap-3 sm:gap-4 mb-4">
                        <div className="w-12 h-12 sm:w-16 sm:h-16 bg-primary-100 dark:bg-primary-900/30 rounded-full flex items-center justify-center flex-shrink-0">
                          {student.profile?.profile_picture ? (
                            <img
                              src={student.profile.profile_picture}
                              alt={student.first_name && student.last_name
                                ? `${student.first_name} ${student.last_name}`
                                : student.username}
                              className="w-full h-full rounded-full object-cover"
                            />
                          ) : (
                            <FiUser className="w-6 h-6 sm:w-8 sm:h-8 text-primary-600 dark:text-primary-400" />
                          )}
                        </div>
                        <div className="flex-1 min-w-0">
                          <h3 className="text-base sm:text-lg font-semibold text-gray-900 dark:text-white truncate hover:text-primary-600 dark:hover:text-primary-400 transition">
                            {student.first_name && student.last_name
                              ? `${student.first_name} ${student.last_name}`
                              : student.username}
                          </h3>
                          <p className="text-xs sm:text-sm text-gray-600 dark:text-gray-400 truncate">@{student.username}</p>
                        </div>
                      </div>

                      {/* University */}
                      {student.profile?.university && (
                        <div className="flex items-center gap-2 mb-3 text-xs sm:text-sm text-gray-600 dark:text-gray-400">
                          <FiMapPin className="w-3 h-3 sm:w-4 sm:h-4 flex-shrink-0" />
                          <span className="truncate">
                            {getUniversityName(student.profile.university)}
                          </span>
                        </div>
                      )}

                      {/* Field of Study */}
                      {student.profile?.field_of_study && (
                        <p className="text-xs sm:text-sm text-gray-500 dark:text-gray-400 mb-4 truncate">
                          {student.profile.field_of_study}
                        </p>
                      )}
                    </div>
                  </Link>
                  
                  {/* Friend Button - Outside Link to prevent navigation */}
                  <div className="px-4 sm:px-6 pb-4 sm:pb-6 flex justify-center" onClick={(e) => e.stopPropagation()}>
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

