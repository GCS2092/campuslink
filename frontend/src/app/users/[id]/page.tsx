'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter, useParams } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiUser, FiMail, FiMapPin, FiBook, FiCalendar, FiUsers, FiUserPlus, FiUserMinus, FiCheck, FiX, FiArrowRight } from 'react-icons/fi'
import { userService, type User } from '@/services/userService'
import toast from 'react-hot-toast'
import Link from 'next/link'
import { getUniversityName, getCampusName } from '@/utils/typeHelpers'

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
  const [friends, setFriends] = useState<User[]>([])
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
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <div className="max-w-4xl mx-auto px-4 py-8">
        {/* Header */}
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm overflow-hidden mb-6">
          {/* Cover Image */}
          <div className="h-48 bg-gradient-to-r from-primary-500 to-purple-600"></div>
          
          {/* Profile Info */}
          <div className="px-6 pb-6 -mt-16">
            <div className="flex items-end justify-between">
              <div className="flex items-end gap-4">
                {/* Profile Picture */}
                <div className="w-32 h-32 bg-primary-100 dark:bg-primary-900 rounded-full flex items-center justify-center border-4 border-white dark:border-gray-800">
                  {profile.profile_picture ? (
                    <img
                      src={profile.profile_picture}
                      alt={fullName}
                      className="w-full h-full rounded-full object-cover"
                    />
                  ) : (
                    <FiUser className="w-16 h-16 text-primary-600 dark:text-primary-400" />
                  )}
                </div>
                
                <div className="pb-4">
                  <h1 className="text-2xl font-bold text-gray-900 dark:text-white">{fullName}</h1>
                  <p className="text-gray-500 dark:text-gray-400">@{profileUser.username}</p>
                </div>
              </div>
              
              {/* Action Buttons */}
              <div className="flex gap-2 pb-4">
                {friendshipStatus === 'none' && (
                  <button
                    onClick={handleSendFriendRequest}
                    disabled={isProcessing}
                    className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition disabled:opacity-50 flex items-center gap-2"
                  >
                    <FiUserPlus className="w-5 h-5" />
                    Ajouter comme ami
                  </button>
                )}
                {friendshipStatus === 'request_sent' && (
                  <button
                    disabled
                    className="px-4 py-2 bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-300 rounded-lg flex items-center gap-2"
                  >
                    <FiCheck className="w-5 h-5" />
                    Demande envoyée
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
                      className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition disabled:opacity-50 flex items-center gap-2"
                    >
                      <FiCheck className="w-5 h-5" />
                      Accepter
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
                      className="px-4 py-2 bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-300 rounded-lg hover:bg-gray-300 dark:hover:bg-gray-600 transition disabled:opacity-50 flex items-center gap-2"
                    >
                      <FiX className="w-5 h-5" />
                      Refuser
                    </button>
                  </div>
                )}
                {friendshipStatus === 'friends' && (
                  <button
                    onClick={handleRemoveFriendFromProfile}
                    disabled={isProcessing}
                    className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition disabled:opacity-50 flex items-center gap-2"
                  >
                    <FiUserMinus className="w-5 h-5" />
                    Supprimer l'ami
                  </button>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Profile Details */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Left Column */}
          <div className="space-y-6">
            {/* About */}
            {profile.bio && (
              <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6">
                <h2 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">À propos</h2>
                <p className="text-gray-600 dark:text-gray-300">{profile.bio}</p>
              </div>
            )}

            {/* Education */}
            <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6">
              <h2 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Éducation</h2>
              <div className="space-y-3">
                {profile.university && (
                  <div className="flex items-start gap-3">
                    <FiMapPin className="w-5 h-5 text-primary-600 dark:text-primary-400 mt-0.5" />
                    <div>
                      <p className="font-medium text-gray-900 dark:text-white">
                        {getUniversityName(profile.university)}
                      </p>
                      {profile.campus && (
                        <p className="text-sm text-gray-500 dark:text-gray-400">
                          {getCampusName(profile.campus)}
                        </p>
                      )}
                    </div>
                  </div>
                )}
                {profile.field_of_study && (
                  <div className="flex items-start gap-3">
                    <FiBook className="w-5 h-5 text-primary-600 dark:text-primary-400 mt-0.5" />
                    <div>
                      <p className="font-medium text-gray-900 dark:text-white">{profile.field_of_study}</p>
                      {profile.academic_year && (
                        <p className="text-sm text-gray-500 dark:text-gray-400">Année: {profile.academic_year}</p>
                      )}
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Right Column */}
          <div className="space-y-6">
            {/* Contact Info */}
            <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6">
              <h2 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Informations</h2>
              <div className="space-y-3">
                <div className="flex items-center gap-3">
                  <FiMail className="w-5 h-5 text-primary-600 dark:text-primary-400" />
                  <p className="text-gray-600 dark:text-gray-300">{profileUser.email}</p>
                </div>
                {profile.university_email && (
                  <div className="flex items-center gap-3">
                    <FiMail className="w-5 h-5 text-primary-600 dark:text-primary-400" />
                    <p className="text-gray-600 dark:text-gray-300">{profile.university_email}</p>
                  </div>
                )}
                <div className="flex items-center gap-3">
                  <FiCalendar className="w-5 h-5 text-primary-600 dark:text-primary-400" />
                  <p className="text-gray-600 dark:text-gray-300">
                    Membre depuis {new Date(profileUser.date_joined).toLocaleDateString('fr-FR', {
                      year: 'numeric',
                      month: 'long',
                    })}
                  </p>
                </div>
              </div>
            </div>

            {/* Stats */}
            <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6">
              <h2 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Statistiques</h2>
              <div className="grid grid-cols-2 gap-4">
                <div className="text-center">
                  <div className="flex items-center justify-center gap-2 mb-1">
                    <FiUsers className="w-5 h-5 text-primary-600 dark:text-primary-400" />
                    <p className="text-2xl font-bold text-gray-900 dark:text-white">{profile.friends_count || 0}</p>
                  </div>
                  <p className="text-sm text-gray-500 dark:text-gray-400">Amis</p>
                </div>
                <div className="text-center">
                  <div className="flex items-center justify-center gap-2 mb-1">
                    <FiUser className="w-5 h-5 text-primary-600 dark:text-primary-400" />
                    <p className="text-2xl font-bold text-gray-900 dark:text-white">{profile.reputation_score || 0}</p>
                  </div>
                  <p className="text-sm text-gray-500 dark:text-gray-400">Réputation</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Friends Section - Only show for current user's own profile */}
        {currentUser && String(userId) === String(currentUser.id) && (
          <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6 mt-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold text-gray-900 dark:text-white flex items-center gap-2">
                <FiUsers className="w-5 h-5 text-primary-600 dark:text-primary-400" />
                Mes Amis ({friends.length})
              </h2>
              <button
                onClick={() => setShowFriendsSection(!showFriendsSection)}
                className="text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300 text-sm font-medium"
              >
                {showFriendsSection ? 'Masquer' : 'Afficher'}
              </button>
            </div>

            {showFriendsSection && (
              <>
                {isLoadingFriends ? (
                  <div className="flex items-center justify-center py-8">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
                  </div>
                ) : friends.length === 0 ? (
                  <div className="text-center py-8">
                    <FiUsers className="w-12 h-12 text-gray-400 dark:text-gray-500 mx-auto mb-3" />
                    <p className="text-gray-500 dark:text-gray-400">Vous n'avez pas encore d'amis</p>
                    <p className="text-sm text-gray-400 dark:text-gray-500 mt-1">
                      Explorez la section "Étudiants" pour trouver des amis
                    </p>
                  </div>
                ) : (
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                    {friends.map((friend) => {
                      const friendProfile = friend.profile || {}
                      const friendName = friend.first_name && friend.last_name
                        ? `${friend.first_name} ${friend.last_name}`
                        : friend.username
                      
                      // Trouver l'ID de l'amitié pour ce friend
                      // Note: L'API retourne les utilisateurs, pas les friendships directement
                      // On devra peut-être modifier l'API pour retourner aussi l'ID de l'amitié
                      
                      return (
                        <div
                          key={friend.id}
                          className="bg-gray-50 dark:bg-gray-700/50 rounded-lg p-4 hover:bg-gray-100 dark:hover:bg-gray-700 transition"
                        >
                          <div className="flex items-center gap-3 mb-3">
                            <div className="w-12 h-12 bg-primary-100 dark:bg-primary-900/30 rounded-full flex items-center justify-center flex-shrink-0">
                              {friendProfile.profile_picture ? (
                                <img
                                  src={friendProfile.profile_picture}
                                  alt={friendName}
                                  className="w-full h-full rounded-full object-cover"
                                />
                              ) : (
                                <FiUser className="w-6 h-6 text-primary-600 dark:text-primary-400" />
                              )}
                            </div>
                            <div className="flex-1 min-w-0">
                              <h3 className="font-medium text-gray-900 dark:text-white truncate">
                                {friendName}
                              </h3>
                              <p className="text-sm text-gray-500 dark:text-gray-400 truncate">
                                @{friend.username}
                              </p>
                            </div>
                          </div>
                          
                          <div className="flex gap-2">
                            <Link
                              href={`/users/${friend.id}`}
                              className="flex-1 px-3 py-2 text-sm bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition text-center flex items-center justify-center gap-1"
                            >
                              Voir profil
                              <FiArrowRight className="w-4 h-4" />
                            </Link>
                            <button
                              onClick={() => handleRemoveFriend(friend.id, friend.friendship_id)}
                              disabled={isProcessing}
                              className="px-3 py-2 text-sm bg-red-600 text-white rounded-lg hover:bg-red-700 transition disabled:opacity-50 flex items-center gap-1"
                              title="Supprimer l'ami"
                            >
                              <FiUserMinus className="w-4 h-4" />
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

