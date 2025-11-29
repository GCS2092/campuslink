'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiUser, FiUserCheck, FiUserX, FiLock, FiUnlock, FiCheck, FiX, FiClock } from 'react-icons/fi'
import { adminService } from '@/services/adminService'
import toast from 'react-hot-toast'

interface User {
  id: string
  username: string
  email: string
  is_active: boolean
  is_verified: boolean
  verification_status: string
  is_banned: boolean
  banned_at?: string
  banned_until?: string
  ban_reason?: string
  date_joined: string
}

export default function AdminUsersPage() {
  const { user, loading } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [pendingUsers, setPendingUsers] = useState<User[]>([])
  const [bannedUsers, setBannedUsers] = useState<User[]>([])
  const [activeTab, setActiveTab] = useState<'pending' | 'banned'>('pending')
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    } else if (mounted && user && user.role !== 'admin') {
      router.push('/dashboard')
    }
  }, [mounted, user, loading, router])

  useEffect(() => {
    if (user && user.role === 'admin') {
      loadData()
    }
  }, [user, activeTab])

  const loadData = async () => {
    setIsLoading(true)
    try {
      if (activeTab === 'pending') {
        const data = await adminService.getPendingVerifications()
        setPendingUsers(Array.isArray(data) ? data : [])
      } else {
        const data = await adminService.getBannedUsers()
        setBannedUsers(Array.isArray(data) ? data : [])
      }
    } catch (error: any) {
      console.error('Error loading users:', error)
      toast.error('Erreur lors du chargement des utilisateurs')
    } finally {
      setIsLoading(false)
    }
  }

  const handleVerify = async (userId: string) => {
    if (!confirm('Voulez-vous vérifier ce compte ?')) return
    
    try {
      await adminService.verifyUser(userId)
      toast.success('Compte vérifié avec succès')
      loadData()
    } catch (error: any) {
      console.error('Error verifying user:', error)
      toast.error('Erreur lors de la vérification')
    }
  }

  const handleReject = async (userId: string) => {
    const reason = prompt('Raison du rejet (optionnel):')
    const message = prompt('Message personnalisé (optionnel):')
    
    if (reason === null && message === null) return // User cancelled
    
    try {
      await adminService.rejectUser(userId, {
        reason: reason || '',
        message: message || ''
      })
      toast.success('Compte rejeté')
      loadData()
    } catch (error: any) {
      console.error('Error rejecting user:', error)
      toast.error('Erreur lors du rejet')
    }
  }

  const handleBan = async (userId: string) => {
    const banType = prompt('Type de bannissement (permanent/temporary):')
    if (!banType || (banType !== 'permanent' && banType !== 'temporary')) {
      toast.error('Type invalide. Utilisez "permanent" ou "temporary"')
      return
    }
    
    const reason = prompt('Raison du bannissement (requis):')
    if (!reason) {
      toast.error('La raison est obligatoire')
      return
    }
    
    let bannedUntil: string | undefined = undefined
    if (banType === 'temporary') {
      const dateStr = prompt('Date de fin (YYYY-MM-DD HH:MM):')
      if (dateStr) {
        bannedUntil = dateStr
      }
    }
    
    try {
      await adminService.banUser(userId, {
        ban_type: banType as 'permanent' | 'temporary',
        reason,
        banned_until: bannedUntil
      })
      toast.success('Utilisateur banni avec succès')
      loadData()
    } catch (error: any) {
      console.error('Error banning user:', error)
      toast.error('Erreur lors du bannissement')
    }
  }

  const handleUnban = async (userId: string) => {
    if (!confirm('Voulez-vous débannir cet utilisateur ?')) return
    
    try {
      await adminService.unbanUser(userId)
      toast.success('Utilisateur débanni avec succès')
      loadData()
    } catch (error: any) {
      console.error('Error unbanning user:', error)
      toast.error('Erreur lors du débannissement')
    }
  }

  if (!mounted || loading || isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 to-secondary-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Chargement...</p>
        </div>
      </div>
    )
  }

  if (!user || user.role !== 'admin') {
    return null
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 sm:py-8">
        <div className="mb-6">
          <h1 className="text-2xl sm:text-3xl font-bold text-gray-900 mb-2">Gestion des Utilisateurs</h1>
          <p className="text-gray-600">Vérifier les comptes et gérer les bannissements</p>
        </div>

        {/* Tabs */}
        <div className="bg-white rounded-lg shadow-sm mb-6">
          <div className="flex border-b border-gray-200">
            <button
              onClick={() => setActiveTab('pending')}
              className={`flex-1 px-4 py-3 text-center font-medium ${
                activeTab === 'pending'
                  ? 'text-primary-600 border-b-2 border-primary-600'
                  : 'text-gray-600 hover:text-gray-900'
              }`}
            >
              En attente de vérification ({pendingUsers.length})
            </button>
            <button
              onClick={() => setActiveTab('banned')}
              className={`flex-1 px-4 py-3 text-center font-medium ${
                activeTab === 'banned'
                  ? 'text-primary-600 border-b-2 border-primary-600'
                  : 'text-gray-600 hover:text-gray-900'
              }`}
            >
              Utilisateurs bannis ({bannedUsers.length})
            </button>
          </div>
        </div>

        {/* Users List */}
        <div className="space-y-4">
          {activeTab === 'pending' ? (
            pendingUsers.length === 0 ? (
              <div className="bg-white rounded-lg shadow-sm p-8 text-center">
                <FiUser className="mx-auto h-12 w-12 text-gray-400 mb-4" />
                <p className="text-gray-600">Aucun compte en attente de vérification</p>
              </div>
            ) : (
              pendingUsers.map((user) => (
                <div key={user.id} className="bg-white rounded-lg shadow-sm p-4 sm:p-6">
                  <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                    <div className="flex-1">
                      <h3 className="text-lg font-semibold text-gray-900">{user.username}</h3>
                      <p className="text-gray-600 text-sm">{user.email}</p>
                      <div className="flex items-center gap-4 mt-2 text-sm text-gray-500">
                        <span className="flex items-center gap-1">
                          <FiClock className="h-4 w-4" />
                          Inscrit le {new Date(user.date_joined).toLocaleDateString('fr-FR')}
                        </span>
                      </div>
                    </div>
                    <div className="flex gap-2">
                      <button
                        onClick={() => handleVerify(user.id)}
                        className="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 flex items-center gap-2"
                      >
                        <FiCheck className="h-4 w-4" />
                        Vérifier
                      </button>
                      <button
                        onClick={() => handleReject(user.id)}
                        className="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 flex items-center gap-2"
                      >
                        <FiX className="h-4 w-4" />
                        Rejeter
                      </button>
                    </div>
                  </div>
                </div>
              ))
            )
          ) : (
            bannedUsers.length === 0 ? (
              <div className="bg-white rounded-lg shadow-sm p-8 text-center">
                <FiLock className="mx-auto h-12 w-12 text-gray-400 mb-4" />
                <p className="text-gray-600">Aucun utilisateur banni</p>
              </div>
            ) : (
              bannedUsers.map((user) => (
                <div key={user.id} className="bg-white rounded-lg shadow-sm p-4 sm:p-6">
                  <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                    <div className="flex-1">
                      <h3 className="text-lg font-semibold text-gray-900">{user.username}</h3>
                      <p className="text-gray-600 text-sm">{user.email}</p>
                      {user.ban_reason && (
                        <p className="text-red-600 text-sm mt-1">Raison: {user.ban_reason}</p>
                      )}
                      <div className="flex items-center gap-4 mt-2 text-sm text-gray-500">
                        <span className="flex items-center gap-1">
                          <FiClock className="h-4 w-4" />
                          Banni le {user.banned_at ? new Date(user.banned_at).toLocaleDateString('fr-FR') : 'N/A'}
                        </span>
                        {user.banned_until && (
                          <span>Jusqu'au {new Date(user.banned_until).toLocaleDateString('fr-FR')}</span>
                        )}
                      </div>
                    </div>
                    <button
                      onClick={() => handleUnban(user.id)}
                      className="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 flex items-center gap-2"
                    >
                      <FiUnlock className="h-4 w-4" />
                      Débannir
                    </button>
                  </div>
                </div>
              ))
            )
          )}
        </div>
      </div>
    </div>
  )
}

