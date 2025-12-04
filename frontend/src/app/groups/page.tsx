'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiUsers, FiPlus, FiSearch, FiX, FiUserPlus, FiCheck, FiMail, FiUser, FiTrash2, FiShield, FiShieldOff, FiEye, FiEyeOff, FiMessageSquare } from 'react-icons/fi'
import { groupService, type Group } from '@/services/groupService'
import { userService, type User } from '@/services/userService'
import { messagingService } from '@/services/messagingService'
import toast from 'react-hot-toast'
import { getUniversityName } from '@/utils/typeHelpers'

export default function GroupsPage() {
  const { user, loading } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [groups, setGroups] = useState<Group[]>([])
  const [isLoadingGroups, setIsLoadingGroups] = useState(true)
  const [showCreateModal, setShowCreateModal] = useState(false)
  const [searchTerm, setSearchTerm] = useState('')
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    university: '',
    category: '',
    is_public: true,
  })
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [showInviteModal, setShowInviteModal] = useState(false)
  const [selectedGroup, setSelectedGroup] = useState<Group | null>(null)
  const [invitations, setInvitations] = useState<any[]>([])
  const [availableStudents, setAvailableStudents] = useState<User[]>([])
  const [selectedUserIds, setSelectedUserIds] = useState<string[]>([])
  const [isLoadingInvitations, setIsLoadingInvitations] = useState(false)
  const [isPublicFilter, setIsPublicFilter] = useState<string>('')
  const [isVerifiedFilter, setIsVerifiedFilter] = useState<string>('')
  
  const isAdmin = user?.role === 'admin' || user?.role === 'class_leader'

  const loadGroups = async () => {
    if (!user) return
    
    setIsLoadingGroups(true)
    try {
      const params: any = {}
      if (searchTerm) {
        params.search = searchTerm
      }
      // Admin filters
      if (isAdmin) {
        if (isPublicFilter !== '') {
          params.is_public = isPublicFilter === 'true'
        }
        if (isVerifiedFilter !== '') {
          params.is_verified = isVerifiedFilter === 'true'
        }
      }
      const response = await groupService.getGroups(params)
      const groupsList = response.results || response.data || response || []
      setGroups(Array.isArray(groupsList) ? groupsList : [])
    } catch (error) {
      console.error('Error loading groups:', error)
      toast.error('Erreur lors du chargement des groupes')
      setGroups([])
    } finally {
      setIsLoadingGroups(false)
    }
  }

  const loadInvitations = async () => {
    if (!user) return
    setIsLoadingInvitations(true)
    try {
      const data = await groupService.getMyInvitations()
      setInvitations(Array.isArray(data) ? data : [])
    } catch (error) {
      console.error('Error loading invitations:', error)
    } finally {
      setIsLoadingInvitations(false)
    }
  }

  const loadAvailableStudents = async () => {
    if (!user) return
    try {
      const students = await userService.getUsers({ verified_only: true })
      setAvailableStudents(Array.isArray(students) ? students : students?.results || [])
    } catch (error) {
      console.error('Error loading students:', error)
    }
  }

  const handleInviteUsers = async () => {
    if (!selectedGroup || selectedUserIds.length === 0) return

    try {
      await groupService.inviteUsers(selectedGroup.id, selectedUserIds)
      toast.success(`${selectedUserIds.length} invitation(s) envoyée(s)`)
      setShowInviteModal(false)
      setSelectedGroup(null)
      setSelectedUserIds([])
      await loadGroups()
    } catch (error: any) {
      console.error('Error inviting users:', error)
      toast.error(error.response?.data?.error || 'Erreur lors de l\'envoi des invitations')
    }
  }

  const handleAcceptInvitation = async (groupId: string) => {
    try {
      await groupService.acceptInvitation(groupId)
      toast.success('Invitation acceptée')
      await loadInvitations()
      await loadGroups()
    } catch (error: any) {
      console.error('Error accepting invitation:', error)
      toast.error(error.response?.data?.error || 'Erreur lors de l\'acceptation')
    }
  }

  const handleRejectInvitation = async (groupId: string) => {
    try {
      await groupService.rejectInvitation(groupId)
      toast.success('Invitation rejetée')
      await loadInvitations()
    } catch (error: any) {
      console.error('Error rejecting invitation:', error)
      toast.error(error.response?.data?.error || 'Erreur lors du rejet')
    }
  }

  const handleOpenGroupConversation = async (groupId: string) => {
    try {
      // Obtenir ou créer la conversation du groupe
      const conversation = await messagingService.getGroupConversation(groupId)
      // Rediriger vers la page des messages avec la conversation sélectionnée
      router.push(`/messages?conversation=${conversation.id}`)
    } catch (error: any) {
      console.error('Error opening group conversation:', error)
      let errorMessage = 'Erreur lors de l\'ouverture de la conversation'
      if (error?.response?.data) {
        const errorData = error.response.data
        if (errorData.error && typeof errorData.error === 'object') {
          errorMessage = errorData.error.message || errorData.error.details?.message || errorMessage
        } else if (typeof errorData === 'string') {
          errorMessage = errorData
        } else if (errorData.message) {
          errorMessage = errorData.message
        } else if (errorData.error && typeof errorData.error === 'string') {
          errorMessage = errorData.error
        }
      } else if (error?.message) {
        errorMessage = error.message
      }
      toast.error(typeof errorMessage === 'string' ? errorMessage : 'Erreur lors de l\'ouverture de la conversation')
    }
  }

  const handleModerate = async (groupId: string, action: 'delete' | 'verify' | 'unverify') => {
    if (!confirm(`Êtes-vous sûr de vouloir ${action === 'delete' ? 'supprimer' : action === 'verify' ? 'vérifier' : 'retirer la vérification de'} ce groupe ?`)) {
      return
    }

    try {
      await groupService.moderateGroup(groupId, action)
      toast.success(`Groupe ${action === 'delete' ? 'supprimé' : action === 'verify' ? 'vérifié' : 'non vérifié'} avec succès`)
      await loadGroups()
    } catch (error: any) {
      console.error('Error moderating group:', error)
      // Handle error object from custom exception handler
      let errorMessage = 'Erreur lors de la modération du groupe'
      if (error?.response?.data) {
        const errorData = error.response.data
        if (errorData.error && typeof errorData.error === 'object') {
          errorMessage = errorData.error.message || errorData.error.details?.message || errorMessage
        } else if (typeof errorData === 'string') {
          errorMessage = errorData
        } else if (errorData.message) {
          errorMessage = errorData.message
        } else if (errorData.error && typeof errorData.error === 'string') {
          errorMessage = errorData.error
        }
      } else if (error?.message) {
        errorMessage = error.message
      }
      toast.error(typeof errorMessage === 'string' ? errorMessage : 'Erreur lors de la modération du groupe')
    }
  }

  const handleCreateGroup = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!user) return

    setIsSubmitting(true)
    try {
      const createdGroup = await groupService.createGroup(formData)
      setShowCreateModal(false)
      setFormData({
        name: '',
        description: '',
        university: '',
        category: '',
        is_public: true,
      })
      await loadGroups()
      toast.success('Groupe créé avec succès!')
    } catch (error: any) {
      console.error('Error creating group:', error)
      // Vérifier si le groupe a quand même été créé (erreur après création)
      if (error?.response?.status === 201 || error?.response?.status === 200) {
        // Le groupe a été créé malgré l'erreur
        toast.success('Groupe créé avec succès!')
        setShowCreateModal(false)
        setFormData({
          name: '',
          description: '',
          university: '',
          category: '',
          is_public: true,
        })
        await loadGroups()
      } else {
        const errorMessage = error.response?.data?.error || error.response?.data?.message || error?.message || 'Erreur lors de la création du groupe'
        toast.error(typeof errorMessage === 'string' ? errorMessage : 'Erreur lors de la création du groupe')
      }
    } finally {
      setIsSubmitting(false)
    }
  }

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    }
  }, [mounted, user, loading, router])

  useEffect(() => {
    if (user) {
      loadGroups()
      loadInvitations()
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user, searchTerm, isPublicFilter, isVerifiedFilter])

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

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header - Improved Design */}
        <div className="relative bg-gradient-to-br from-primary-500 via-primary-600 to-secondary-600 rounded-2xl shadow-xl p-6 sm:p-8 mb-6 sm:mb-8 overflow-hidden">
          {/* Decorative Background Elements */}
          <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16"></div>
          <div className="absolute bottom-0 left-0 w-24 h-24 bg-white/10 rounded-full -ml-12 -mb-12"></div>
          
          <div className="relative z-10 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div className="flex-1">
              <div className="flex items-center gap-3 mb-2">
                <div className="w-12 h-12 bg-white/20 backdrop-blur-sm rounded-xl flex items-center justify-center shadow-lg">
                  <FiUsers className="w-6 h-6 text-white" />
                </div>
                <h1 className="text-2xl sm:text-3xl font-bold text-white drop-shadow-lg">
                  {isAdmin ? 'Gestion des Groupes' : 'Groupes'}
                </h1>
              </div>
              <p className="text-white/90 text-sm sm:text-base">
                {isAdmin ? 'Surveillez et modérez les groupes créés par les étudiants' : 'Rejoignez des groupes et clubs'}
              </p>
            </div>
            {!isAdmin && (
              <div className="flex gap-3 w-full sm:w-auto">
                {invitations.length > 0 && (
                  <button
                    onClick={() => {
                      const element = document.getElementById('invitations-section')
                      element?.scrollIntoView({ behavior: 'smooth' })
                    }}
                    className="flex items-center gap-2 px-5 py-3 bg-yellow-500 text-white rounded-xl hover:bg-yellow-600 transition-all duration-300 text-sm sm:text-base w-full sm:w-auto justify-center shadow-lg hover:shadow-xl hover:-translate-y-1 font-semibold"
                  >
                    <FiMail className="w-4 h-4 sm:w-5 sm:h-5" />
                    <span>Invitations ({invitations.length})</span>
                  </button>
                )}
                <button
                  onClick={() => setShowCreateModal(true)}
                  className="flex items-center gap-2 px-5 py-3 bg-white text-primary-600 rounded-xl hover:bg-white/90 transition-all duration-300 text-sm sm:text-base w-full sm:w-auto justify-center shadow-lg hover:shadow-xl hover:-translate-y-1 font-semibold"
                >
                  <FiPlus className="w-4 h-4 sm:w-5 sm:h-5" />
                  <span>Créer un groupe</span>
                </button>
              </div>
            )}
          </div>
        </div>

        {/* Admin Filters */}
        {isAdmin && (
          <div className="mb-6 flex flex-wrap gap-4">
            <div className="relative flex-1 min-w-[200px]">
              <FiSearch className="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
              <input
                type="text"
                placeholder="Rechercher un groupe..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-12 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              />
            </div>
            <select
              value={isPublicFilter}
              onChange={(e) => setIsPublicFilter(e.target.value)}
              className="px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            >
              <option value="">Tous (public/privé)</option>
              <option value="true">Public uniquement</option>
              <option value="false">Privé uniquement</option>
            </select>
            <select
              value={isVerifiedFilter}
              onChange={(e) => setIsVerifiedFilter(e.target.value)}
              className="px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            >
              <option value="">Tous (vérifié/non vérifié)</option>
              <option value="true">Vérifiés uniquement</option>
              <option value="false">Non vérifiés uniquement</option>
            </select>
          </div>
        )}

        {/* Invitations Section */}
        {invitations.length > 0 && (
          <div id="invitations-section" className="mb-6 sm:mb-8">
            <h2 className="text-xl sm:text-2xl font-bold text-gray-900 mb-4">Mes Invitations</h2>
            <div className="space-y-3">
              {invitations.map((invitation: any) => (
                <div
                  key={invitation.id}
                  className="bg-white rounded-xl shadow-md p-4 sm:p-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4"
                >
                  <div className="flex-1">
                    <h3 className="text-lg font-semibold text-gray-900 mb-1">
                      {invitation.group?.name || 'Groupe'}
                    </h3>
                    <p className="text-sm text-gray-600">
                      Vous avez été invité à rejoindre ce groupe
                    </p>
                  </div>
                  <div className="flex gap-2 w-full sm:w-auto">
                    <button
                      onClick={() => handleAcceptInvitation(invitation.group?.id)}
                      className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition text-sm sm:text-base w-full sm:w-auto justify-center"
                    >
                      <FiCheck className="w-4 h-4" />
                      Accepter
                    </button>
                    <button
                      onClick={() => handleRejectInvitation(invitation.group?.id)}
                      className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition text-sm sm:text-base w-full sm:w-auto justify-center"
                    >
                      <FiX className="w-4 h-4" />
                      Rejeter
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Search Bar (Non-admin) */}
        {!isAdmin && (
          <div className="mb-6">
            <div className="relative">
              <FiSearch className="absolute left-3 sm:left-4 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4 sm:w-5 sm:h-5" />
              <input
                type="text"
                placeholder="Rechercher un groupe..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 sm:pl-12 pr-4 py-2 sm:py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm sm:text-base"
              />
            </div>
          </div>
        )}

        {/* Groups List */}
        {isLoadingGroups ? (
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Chargement des groupes...</p>
          </div>
        ) : groups.length === 0 ? (
          <div className="bg-white rounded-2xl shadow-xl p-12 text-center border border-gray-100">
            <div className="w-20 h-20 bg-gradient-to-br from-gray-100 to-gray-200 rounded-full flex items-center justify-center mx-auto mb-4">
              <FiUsers className="w-10 h-10 text-gray-400" />
            </div>
            <h3 className="text-xl font-bold text-gray-900 mb-2">Aucun groupe</h3>
            <p className="text-gray-600 mb-4">Il n&apos;y a pas encore de groupes disponibles.</p>
            <button 
              onClick={() => setShowCreateModal(true)}
              className="px-6 py-3 bg-primary-600 text-white rounded-xl hover:bg-primary-700 transition-all duration-300 shadow-lg hover:shadow-xl hover:-translate-y-1 font-semibold"
            >
              Créer le premier groupe
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
            {groups.map((group) => (
              <div key={group.id} className="group bg-white rounded-xl shadow-md overflow-hidden hover:shadow-xl transition-all duration-300 border border-gray-100 hover:border-primary-300 hover:-translate-y-1">
                <div className="p-4 sm:p-6">
                  <div className="flex items-start justify-between mb-2">
                    <h3 className="text-lg sm:text-xl font-semibold text-gray-900 flex-1">{group.name}</h3>
                    {isAdmin && (
                      <div className="flex gap-1 ml-2">
                        {group.is_verified ? (
                          <span className="px-2 py-1 bg-blue-100 text-blue-700 rounded text-xs font-medium flex items-center gap-1">
                            <FiShield className="w-3 h-3" />
                            Vérifié
                          </span>
                        ) : (
                          <span className="px-2 py-1 bg-gray-100 text-gray-700 rounded text-xs font-medium">
                            Non vérifié
                          </span>
                        )}
                        {!group.is_public && (
                          <span className="px-2 py-1 bg-purple-100 text-purple-700 rounded text-xs font-medium flex items-center gap-1">
                            <FiEyeOff className="w-3 h-3" />
                            Privé
                          </span>
                        )}
                      </div>
                    )}
                  </div>
                  <p className="text-sm sm:text-base text-gray-600 mb-4 line-clamp-2">{group.description}</p>
                  <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2 text-xs sm:text-sm text-gray-600 mb-4">
                    <div className="flex items-center gap-2">
                      <FiUsers className="w-4 h-4" />
                      <span>{group.members_count} membres</span>
                    </div>
                    {group.category && (
                      <span className="px-2 py-1 bg-gray-100 rounded">{group.category}</span>
                    )}
                    {group.creator && (
                      <div className="text-xs text-gray-500">
                        Par {group.creator.username}
                        {group.university && ` • ${getUniversityName(group.university)}`}
                      </div>
                    )}
                  </div>
                  {isAdmin ? (
                    <div className="flex gap-2">
                      {!group.is_verified ? (
                        <button
                          onClick={() => handleModerate(group.id, 'verify')}
                          className="flex-1 flex items-center justify-center gap-2 bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition text-sm"
                        >
                          <FiShield className="w-4 h-4" />
                          Vérifier
                        </button>
                      ) : (
                        <button
                          onClick={() => handleModerate(group.id, 'unverify')}
                          className="flex-1 flex items-center justify-center gap-2 bg-yellow-600 text-white py-2 rounded-lg hover:bg-yellow-700 transition text-sm"
                        >
                          <FiShieldOff className="w-4 h-4" />
                          Retirer vérif.
                        </button>
                      )}
                      <button
                        onClick={() => handleModerate(group.id, 'delete')}
                        className="flex items-center justify-center gap-2 bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition text-sm"
                      >
                        <FiTrash2 className="w-4 h-4" />
                      </button>
                    </div>
                  ) : (
                    <div className="flex gap-2">
                    {/* Si l'utilisateur est membre, afficher le bouton de conversation */}
                    {group.user_role && (
                      <button
                        onClick={() => handleOpenGroupConversation(group.id)}
                        className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition text-sm sm:text-base flex items-center gap-2"
                        title="Ouvrir la conversation du groupe"
                      >
                        <FiMessageSquare className="w-4 h-4 sm:w-5 sm:h-5" />
                        <span className="hidden sm:inline">Discuter</span>
                      </button>
                    )}
                    {!group.user_role && group.is_public ? (
                      <button
                        onClick={async () => {
                          try {
                            await groupService.joinGroup(group.id)
                            toast.success('Groupe rejoint avec succès')
                            await loadGroups()
                          } catch (error: any) {
                            console.error('Error joining group:', error)
                            toast.error(error.response?.data?.error || 'Erreur lors de la jointure')
                          }
                        }}
                        className="flex-1 bg-primary-600 text-white py-2 rounded-lg hover:bg-primary-700 transition text-sm sm:text-base"
                      >
                        Rejoindre
                      </button>
                    ) : !group.user_role ? (
                      <button
                        disabled
                        className="flex-1 bg-gray-400 text-white py-2 rounded-lg cursor-not-allowed text-sm sm:text-base"
                      >
                        Privé (Invitation requise)
                      </button>
                    ) : null}
                    {(user?.role === 'admin' || user?.role === 'class_leader' || group.creator?.id === user?.id) && (
                      <button
                        onClick={() => {
                          setSelectedGroup(group)
                          setShowInviteModal(true)
                          loadAvailableStudents()
                        }}
                        className="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition text-sm sm:text-base"
                        title="Inviter des membres"
                      >
                        <FiUserPlus className="w-4 h-4 sm:w-5 sm:h-5" />
                      </button>
                    )}
                  </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Create Group Modal */}
        {showCreateModal && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-[9999]" onClick={(e) => {
            if (e.target === e.currentTarget) {
              setShowCreateModal(false)
            }
          }}>
            <div className="bg-white rounded-xl shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
              <div className="flex items-center justify-between p-4 sm:p-6 border-b border-gray-200">
                <h2 className="text-xl sm:text-2xl font-bold text-gray-900">Créer un groupe</h2>
                <button
                  onClick={() => setShowCreateModal(false)}
                  className="p-2 text-gray-400 hover:text-gray-600 transition"
                >
                  <FiX className="w-5 h-5 sm:w-6 sm:h-6" />
                </button>
              </div>
              
              <form onSubmit={handleCreateGroup} className="p-4 sm:p-6 space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Nom du groupe *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm sm:text-base"
                    placeholder="Ex: Club de Football"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Description *
                  </label>
                  <textarea
                    required
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    rows={4}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm sm:text-base"
                    placeholder="Décrivez votre groupe..."
                  />
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Université
                    </label>
                    <input
                      type="text"
                      value={formData.university}
                      onChange={(e) => setFormData({ ...formData, university: e.target.value })}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm sm:text-base"
                      placeholder="Ex: ESMT"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Catégorie
                    </label>
                    <input
                      type="text"
                      value={formData.category}
                      onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm sm:text-base"
                      placeholder="Ex: Sport, Culture..."
                    />
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    id="is_public"
                    checked={formData.is_public}
                    onChange={(e) => setFormData({ ...formData, is_public: e.target.checked })}
                    className="w-4 h-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500"
                  />
                  <label htmlFor="is_public" className="text-sm text-gray-700">
                    Groupe public (visible par tous)
                  </label>
                </div>

                <div className="flex gap-3 pt-4">
                  <button
                    type="button"
                    onClick={() => setShowCreateModal(false)}
                    className="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition text-sm sm:text-base"
                  >
                    Annuler
                  </button>
                  <button
                    type="submit"
                    disabled={isSubmitting}
                    className="flex-1 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition disabled:opacity-50 disabled:cursor-not-allowed text-sm sm:text-base"
                  >
                    {isSubmitting ? 'Création...' : 'Créer le groupe'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* Invite Users Modal */}
        {showInviteModal && selectedGroup && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-xl shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
              <div className="flex items-center justify-between p-4 sm:p-6 border-b border-gray-200">
                <h2 className="text-xl sm:text-2xl font-bold text-gray-900">
                  Inviter des membres - {selectedGroup.name}
                </h2>
                <button
                  onClick={() => {
                    setShowInviteModal(false)
                    setSelectedGroup(null)
                    setSelectedUserIds([])
                  }}
                  className="p-2 text-gray-400 hover:text-gray-600 transition"
                >
                  <FiX className="w-5 h-5 sm:w-6 sm:h-6" />
                </button>
              </div>
              
              <div className="p-4 sm:p-6">
                <div className="mb-4">
                  <p className="text-sm text-gray-600 mb-4">
                    Sélectionnez les étudiants à inviter dans ce groupe
                  </p>
                  <div className="max-h-96 overflow-y-auto border border-gray-200 rounded-lg">
                    {availableStudents.length === 0 ? (
                      <div className="p-8 text-center text-gray-500">
                        <FiUser className="w-12 h-12 mx-auto mb-2 text-gray-400" />
                        <p>Aucun étudiant disponible</p>
                      </div>
                    ) : (
                      <div className="divide-y divide-gray-200">
                        {availableStudents.map((student) => (
                          <label
                            key={student.id}
                            className="flex items-center gap-3 p-3 hover:bg-gray-50 cursor-pointer"
                          >
                            <input
                              type="checkbox"
                              checked={selectedUserIds.includes(student.id)}
                              onChange={(e) => {
                                if (e.target.checked) {
                                  setSelectedUserIds([...selectedUserIds, student.id])
                                } else {
                                  setSelectedUserIds(selectedUserIds.filter(id => id !== student.id))
                                }
                              }}
                              className="w-4 h-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500"
                            />
                            <div className="flex-1">
                              <p className="font-medium text-gray-900">
                                {student.first_name && student.last_name
                                  ? `${student.first_name} ${student.last_name}`
                                  : student.username}
                              </p>
                              <p className="text-sm text-gray-600">{student.email}</p>
                            </div>
                          </label>
                        ))}
                      </div>
                    )}
                  </div>
                </div>

                <div className="flex gap-3 pt-4 border-t border-gray-200">
                  <button
                    type="button"
                    onClick={() => {
                      setShowInviteModal(false)
                      setSelectedGroup(null)
                      setSelectedUserIds([])
                    }}
                    className="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition text-sm sm:text-base"
                  >
                    Annuler
                  </button>
                  <button
                    onClick={handleInviteUsers}
                    disabled={selectedUserIds.length === 0}
                    className="flex-1 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition disabled:opacity-50 disabled:cursor-not-allowed text-sm sm:text-base"
                  >
                    Inviter ({selectedUserIds.length})
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

