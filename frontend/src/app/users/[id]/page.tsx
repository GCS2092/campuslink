'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter, useParams } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiUser, FiMail, FiMapPin, FiBook, FiCalendar, FiUsers, FiUserPlus, FiUserMinus, FiCheck, FiX, FiArrowRight } from 'react-icons/fi'
import { userService, type User } from '@/services/userService'
import toast from 'react-hot-toast'
import Link from 'next/link'
import { getUniversityName, getCampusName } from '@/utils/typeHelpers'

interface Friend extends User {
  friendship_id?: string
}

export default function UserProfilePage() {
  const { user: currentUser, loading } = useAuth()
  const router = useRouter()
  const params = useParams()
  const userId = params?.id as string
  
  const [profileUser, setProfileUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [friendshipStatus, setFriendshipStatus] = useState<string>('none')
  const [friendshipId, setFriendshipId] = useState<string | null>(null)
  const [isProcessing, setIsProcessing] = useState(false)
  const [friends, setFriends] = useState<Friend[]>([])
  const [isLoadingFriends, setIsLoadingFriends] = useState(false)
  const [showFriendsSection, setShowFriendsSection] = useState(true) // Afficher par défaut

  useEffect(() => {
    if (!loading && !currentUser) {
      router.push('/login')
    }
  }, [currentUser, loading, router])

  useEffect(() => {
    if (userId && currentUser) {
      loadProfile()
      // Si c'est le profil de l'utilisateur connecté, charger ses amis
      // Comparer les IDs en string pour éviter les problèmes de type
      if (String(userId) === String(currentUser.id)) {
        loadFriends()
      }
    }
  }, [userId, currentUser])

  const loadProfile = async () => {
    if (!userId) return
    
    setIsLoading(true)
    try {
      const data = await userService.getPublicProfile(userId)
      setProfileUser(data)
      setFriendshipStatus(data.friendship_status || 'none')
      setFriendshipId(data.friendship_id || null)
    } catch (error: any) {
      console.error('Error loading profile:', error)
      toast.error('Erreur lors du chargement du profil')
      if (error.response?.status === 404) {
        router.push('/dashboard')
      }
    } finally {
      setIsLoading(false)
    }
  }

  const handleSendFriendRequest = async () => {
    if (!profileUser || isProcessing) return
    
    setIsProcessing(true)
    try {
      await userService.sendFriendRequest(profileUser.id)
      setFriendshipStatus('request_sent')
      toast.success('Demande d\'ami envoyée')
    } catch (error: any) {
      console.error('Error sending friend request:', error)
      toast.error(error.response?.data?.error || 'Erreur lors de l\'envoi de la demande')
    } finally {
      setIsProcessing(false)
    }
  }

  const loadFriends = async () => {
    setIsLoadingFriends(true)
    try {
      const data = await userService.getFriends()
      console.log('Friends data received:', data) // Debug log
      const friendsList = Array.isArray(data) ? data : []
      console.log('Friends list:', friendsList) // Debug log
      setFriends(friendsList)
    } catch (error: any) {
      console.error('Error loading friends:', error)
      toast.error('Erreur lors du chargement des amis')
      setFriends([]) // Set empty array on error
    } finally {
      setIsLoadingFriends(false)
    }
  }

  const handleRemoveFriend = async (friendId: string, friendshipIdToRemove: string) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cet ami ?')) {
      return
    }
    
    setIsProcessing(true)
    try {
      await userService.removeFriend(friendshipIdToRemove)
      // Si on supprime depuis la liste d'amis
      if (friendshipIdToRemove) {
        setFriends(friends.filter(f => f.id !== friendId))
        toast.success('Ami supprimé')
      } else {
        // Si on supprime depuis le profil
        setFriendshipStatus('none')
        setFriendshipId(null)
        toast.success('Ami supprimé')
        // Recharger la liste des amis si on est sur notre propre profil
        if (userId === currentUser?.id) {
          loadFriends()
        }
      }
    } catch (error: any) {
      console.error('Error removing friend:', error)
      toast.error(error.response?.data?.error || 'Erreur lors de la suppression')
    } finally {
      setIsProcessing(false)
    }
  }

  const handleRemoveFriendFromProfile = async () => {
    if (!profileUser || !friendshipId) return
    await handleRemoveFriend(profileUser.id, friendshipId)
  }

  if (loading || isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  if (!profileUser) {
    return (
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center">
        <div className="text-center">
          <p className="text-gray-500 dark:text-gray-400">Profil non trouvé</p>
        </div>
      </div>
    )
  }

  const profile = profileUser.profile || {}
  const fullName = profileUser.first_name && profileUser.last_name
    ? `${profileUser.first_name} ${profileUser.last_name}`
    : profileUser.username

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-6 sm:py-8">
        {/* Header - Improved Design */}
        <div className="bg-white rounded-2xl shadow-xl overflow-hidden mb-6 border border-gray-100">
          {/* Cover Image - Enhanced */}
          <div className="relative h-40 sm:h-48 bg-gradient-to-br from-primary-500 via-primary-600 to-secondary-600 overflow-hidden">
            <div className="absolute inset-0 bg-black/10"></div>
            <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16"></div>
            <div className="absolute bottom-0 left-0 w-24 h-24 bg-white/10 rounded-full -ml-12 -mb-12"></div>
          </div>
          
          {/* Profile Info - Improved Responsive Design */}
          <div className="px-4 sm:px-6 pb-6 -mt-16 sm:-mt-20">
            <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4">
              <div className="flex flex-col sm:flex-row sm:items-end gap-4">
                {/* Profile Picture - Responsive */}
                <div className="w-24 h-24 sm:w-32 sm:h-32 bg-white rounded-full flex items-center justify-center border-4 border-white shadow-xl mx-auto sm:mx-0">
                  {profile.profile_picture ? (
                    <img
                      src={profile.profile_picture}
                      alt={fullName}
                      className="w-full h-full rounded-full object-cover"
                    />
                  ) : (
                    <FiUser className="w-12 h-12 sm:w-16 sm:h-16 text-primary-600" />
                  )}
                </div>
                
                <div className="text-center sm:text-left pb-2 sm:pb-4">
                  <h1 className="text-xl sm:text-2xl lg:text-3xl font-bold text-gray-900">{fullName}</h1>
                  <p className="text-sm sm:text-base text-gray-500 mt-1">@{profileUser.username}</p>
                </div>
              </div>
              
              {/* Action Buttons - Responsive */}
              <div className="flex flex-col sm:flex-row gap-2 sm:pb-4 justify-center sm:justify-end">
                {friendshipStatus === 'none' && (
                  <button
                    onClick={handleSendFriendRequest}
                    disabled={isProcessing}
                    className="px-4 sm:px-5 py-2.5 sm:py-3 bg-primary-600 text-white rounded-xl hover:bg-primary-700 transition-all duration-200 disabled:opacity-50 flex items-center justify-center gap-2 font-semibold shadow-lg hover:shadow-xl hover:-translate-y-0.5"
                  >
                    <FiUserPlus className="w-4 h-4 sm:w-5 sm:h-5" />
                    <span className="text-sm sm:text-base">Ajouter comme ami</span>
                  </button>
                )}
                {friendshipStatus === 'request_sent' && (
                  <button
                    disabled
                    className="px-4 sm:px-5 py-2.5 sm:py-3 bg-gray-200 text-gray-600 rounded-xl flex items-center justify-center gap-2 font-semibold"
                  >
                    <FiCheck className="w-4 h-4 sm:w-5 sm:h-5" />
                    <span className="text-sm sm:text-base">Demande envoyée</span>
                  </button>
                )}
                {friendshipStatus === 'request_received' && (
                  <div className="flex gap-2">
                    <button
                      onClick={async () => {
                        if (!friendshipId) return
                        setIsProcessing(true)
                        try {
                          await userService.acceptFriendRequest(friendshipId)
                          setFriendshipStatus('friends')
                          toast.success('Demande d\'ami acceptée')
                        } catch (error: any) {
                          toast.error('Erreur lors de l\'acceptation')
                        } finally {
                          setIsProcessing(false)
                        }
                      }}
                      disabled={isProcessing}
                      className="flex-1 px-4 py-2.5 bg-primary-600 text-white rounded-xl hover:bg-primary-700 transition-all duration-200 disabled:opacity-50 flex items-center justify-center gap-2 font-semibold shadow-lg hover:shadow-xl"
                    >
                      <FiCheck className="w-4 h-4 sm:w-5 sm:h-5" />
                      <span className="text-sm sm:text-base">Accepter</span>
                    </button>
                    <button
                      onClick={async () => {
                        if (!friendshipId) return
                        setIsProcessing(true)
                        try {
                          await userService.rejectFriendRequest(friendshipId)
                          setFriendshipStatus('none')
                          setFriendshipId(null)
                          toast.success('Demande refusée')
                        } catch (error: any) {
                          toast.error('Erreur lors du refus')
                        } finally {
                          setIsProcessing(false)
                        }
                      }}
                      disabled={isProcessing}
                      className="px-4 py-2.5 bg-gray-200 text-gray-600 rounded-xl hover:bg-gray-300 transition-all duration-200 disabled:opacity-50 flex items-center justify-center gap-2 font-semibold"
                    >
                      <FiX className="w-4 h-4 sm:w-5 sm:h-5" />
                    </button>
                  </div>
                )}
                {friendshipStatus === 'friends' && (
                  <button
                    onClick={handleRemoveFriendFromProfile}
                    disabled={isProcessing}
                    className="px-4 sm:px-5 py-2.5 sm:py-3 bg-red-600 text-white rounded-xl hover:bg-red-700 transition-all duration-200 disabled:opacity-50 flex items-center justify-center gap-2 font-semibold shadow-lg hover:shadow-xl"
                  >
                    <FiUserMinus className="w-4 h-4 sm:w-5 sm:h-5" />
                    <span className="text-sm sm:text-base">Supprimer l'ami</span>
                  </button>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Profile Details - Improved Responsive Design */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 sm:gap-6">
          {/* Left Column */}
          <div className="space-y-4 sm:space-y-6">
            {/* About - Enhanced */}
            {profile.bio && (
              <div className="bg-white rounded-xl shadow-lg p-5 sm:p-6 border border-gray-100 hover:shadow-xl transition-all duration-300">
                <h2 className="text-lg sm:text-xl font-bold text-gray-900 mb-3 sm:mb-4 flex items-center gap-2">
                  <div className="w-1 h-6 bg-gradient-to-b from-primary-500 to-secondary-500 rounded-full"></div>
                  À propos
                </h2>
                <p className="text-gray-600 text-sm sm:text-base leading-relaxed">{profile.bio}</p>
              </div>
            )}

            {/* Education - Enhanced */}
            <div className="bg-white rounded-xl shadow-lg p-5 sm:p-6 border border-gray-100 hover:shadow-xl transition-all duration-300">
              <h2 className="text-lg sm:text-xl font-bold text-gray-900 mb-3 sm:mb-4 flex items-center gap-2">
                <div className="w-1 h-6 bg-gradient-to-b from-primary-500 to-secondary-500 rounded-full"></div>
                Éducation
              </h2>
              <div className="space-y-4">
                {profile.university && (
                  <div className="flex items-start gap-3 p-3 bg-gray-50 rounded-xl hover:bg-gray-100 transition-colors">
                    <div className="w-10 h-10 bg-primary-100 rounded-lg flex items-center justify-center flex-shrink-0">
                      <FiMapPin className="w-5 h-5 text-primary-600" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-semibold text-gray-900 text-sm sm:text-base">
                        {getUniversityName(profile.university)}
                      </p>
                      {profile.campus && (
                        <p className="text-xs sm:text-sm text-gray-600 mt-1">
                          {getCampusName(profile.campus)}
                        </p>
                      )}
                    </div>
                  </div>
                )}
                {profile.field_of_study && (
                  <div className="flex items-start gap-3 p-3 bg-gray-50 rounded-xl hover:bg-gray-100 transition-colors">
                    <div className="w-10 h-10 bg-primary-100 rounded-lg flex items-center justify-center flex-shrink-0">
                      <FiBook className="w-5 h-5 text-primary-600" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-semibold text-gray-900 text-sm sm:text-base">{profile.field_of_study}</p>
                      {profile.academic_year && (
                        <p className="text-xs sm:text-sm text-gray-600 mt-1">Année: {profile.academic_year}</p>
                      )}
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Right Column */}
          <div className="space-y-4 sm:space-y-6">
            {/* Contact Info - Enhanced */}
            <div className="bg-white rounded-xl shadow-lg p-5 sm:p-6 border border-gray-100 hover:shadow-xl transition-all duration-300">
              <h2 className="text-lg sm:text-xl font-bold text-gray-900 mb-3 sm:mb-4 flex items-center gap-2">
                <div className="w-1 h-6 bg-gradient-to-b from-primary-500 to-secondary-500 rounded-full"></div>
                Informations
              </h2>
              <div className="space-y-3">
                <div className="flex items-center gap-3 p-2 rounded-lg hover:bg-gray-50 transition-colors">
                  <div className="w-8 h-8 bg-primary-100 rounded-lg flex items-center justify-center flex-shrink-0">
                    <FiMail className="w-4 h-4 text-primary-600" />
                  </div>
                  <p className="text-sm sm:text-base text-gray-600 truncate">{profileUser.email}</p>
                </div>
                {profile.university_email && (
                  <div className="flex items-center gap-3 p-2 rounded-lg hover:bg-gray-50 transition-colors">
                    <div className="w-8 h-8 bg-primary-100 rounded-lg flex items-center justify-center flex-shrink-0">
                      <FiMail className="w-4 h-4 text-primary-600" />
                    </div>
                    <p className="text-sm sm:text-base text-gray-600 truncate">{profile.university_email}</p>
                  </div>
                )}
                <div className="flex items-center gap-3 p-2 rounded-lg hover:bg-gray-50 transition-colors">
                  <div className="w-8 h-8 bg-primary-100 rounded-lg flex items-center justify-center flex-shrink-0">
                    <FiCalendar className="w-4 h-4 text-primary-600" />
                  </div>
                  <p className="text-sm sm:text-base text-gray-600">
                    Membre depuis {new Date(profileUser.date_joined).toLocaleDateString('fr-FR', {
                      year: 'numeric',
                      month: 'long',
                    })}
                  </p>
                </div>
              </div>
            </div>

            {/* Stats - Enhanced */}
            <div className="bg-white rounded-xl shadow-lg p-5 sm:p-6 border border-gray-100 hover:shadow-xl transition-all duration-300">
              <h2 className="text-lg sm:text-xl font-bold text-gray-900 mb-3 sm:mb-4 flex items-center gap-2">
                <div className="w-1 h-6 bg-gradient-to-b from-primary-500 to-secondary-500 rounded-full"></div>
                Statistiques
              </h2>
              <div className="grid grid-cols-2 gap-3 sm:gap-4">
                <div className="text-center p-3 bg-gradient-to-br from-primary-50 to-primary-100 rounded-xl">
                  <div className="flex items-center justify-center gap-2 mb-1">
                    <FiUsers className="w-5 h-5 text-primary-600" />
                    <p className="text-2xl sm:text-3xl font-bold text-gray-900">{profile.friends_count || 0}</p>
                  </div>
                  <p className="text-xs sm:text-sm text-gray-600 font-medium">Amis</p>
                </div>
                <div className="text-center p-3 bg-gradient-to-br from-secondary-50 to-secondary-100 rounded-xl">
                  <div className="flex items-center justify-center gap-2 mb-1">
                    <FiUser className="w-5 h-5 text-secondary-600" />
                    <p className="text-2xl sm:text-3xl font-bold text-gray-900">{profile.reputation_score || 0}</p>
                  </div>
                  <p className="text-xs sm:text-sm text-gray-600 font-medium">Réputation</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Friends Section - Only show for current user's own profile - Enhanced */}
        {currentUser && String(userId) === String(currentUser.id) && (
          <div className="bg-white rounded-xl shadow-lg p-5 sm:p-6 mt-4 sm:mt-6 border border-gray-100">
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 sm:gap-4 mb-4">
              <h2 className="text-lg sm:text-xl font-bold text-gray-900 flex items-center gap-2">
                <div className="w-10 h-10 bg-gradient-to-br from-primary-500 to-secondary-500 rounded-xl flex items-center justify-center">
                  <FiUsers className="w-5 h-5 text-white" />
                </div>
                <span>Mes Amis <span className="text-primary-600">({friends.length})</span></span>
              </h2>
              <button
                onClick={() => setShowFriendsSection(!showFriendsSection)}
                className="px-4 py-2 text-sm font-semibold text-primary-600 hover:text-primary-700 hover:bg-primary-50 rounded-xl transition-all duration-200"
              >
                {showFriendsSection ? 'Masquer' : 'Afficher'}
              </button>
            </div>

            {showFriendsSection && (
              <>
                {isLoadingFriends ? (
                  <div className="flex items-center justify-center py-12">
                    <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-primary-600"></div>
                  </div>
                ) : friends.length === 0 ? (
                  <div className="text-center py-12">
                    <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                      <FiUsers className="w-8 h-8 text-gray-400" />
                    </div>
                    <p className="text-gray-600 font-medium mb-1">Vous n'avez pas encore d'amis</p>
                    <p className="text-sm text-gray-500">
                      Explorez la section "Étudiants" pour trouver des amis
                    </p>
                  </div>
                ) : (
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 sm:gap-4">
                    {friends.map((friend) => {
                      const friendProfile = friend.profile || {}
                      const friendName = friend.first_name && friend.last_name
                        ? `${friend.first_name} ${friend.last_name}`
                        : friend.username
                      
                      return (
                        <div
                          key={friend.id}
                          className="bg-gradient-to-br from-white to-gray-50 rounded-xl p-4 border border-gray-200 hover:border-primary-300 hover:shadow-lg transition-all duration-300 hover:-translate-y-1"
                        >
                          <div className="flex items-center gap-3 mb-3">
                            <div className="w-12 h-12 bg-primary-100 rounded-full flex items-center justify-center flex-shrink-0 border-2 border-white shadow-md">
                              {friendProfile.profile_picture ? (
                                <img
                                  src={friendProfile.profile_picture}
                                  alt={friendName}
                                  className="w-full h-full rounded-full object-cover"
                                />
                              ) : (
                                <FiUser className="w-6 h-6 text-primary-600" />
                              )}
                            </div>
                            <div className="flex-1 min-w-0">
                              <h3 className="font-semibold text-gray-900 truncate text-sm sm:text-base">
                                {friendName}
                              </h3>
                              <p className="text-xs sm:text-sm text-gray-500 truncate">
                                @{friend.username}
                              </p>
                            </div>
                          </div>
                          
                          <div className="flex gap-2">
                            <Link
                              href={`/users/${friend.id}`}
                              className="flex-1 px-3 py-2 text-xs sm:text-sm bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-all duration-200 text-center flex items-center justify-center gap-1 font-medium shadow-md hover:shadow-lg"
                            >
                              Voir profil
                              <FiArrowRight className="w-3 h-3 sm:w-4 sm:h-4" />
                            </Link>
                            <button
                              onClick={() => handleRemoveFriend(friend.id, friend.friendship_id || '')}
                              disabled={isProcessing || !friend.friendship_id}
                              className="px-3 py-2 text-xs sm:text-sm bg-red-600 text-white rounded-lg hover:bg-red-700 transition-all duration-200 disabled:opacity-50 flex items-center justify-center gap-1 shadow-md hover:shadow-lg"
                              title="Supprimer l'ami"
                            >
                              <FiUserMinus className="w-3 h-3 sm:w-4 sm:h-4" />
                            </button>
                          </div>
                        </div>
                      )
                    })}
                  </div>
                )}
              </>
            )}
          </div>
        )}
      </div>
    </div>
  )
}

