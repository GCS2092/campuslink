'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiSettings, FiLock, FiBell, FiUser, FiArrowLeft, FiLogOut, FiSave, FiEye, FiEyeOff } from 'react-icons/fi'
import { userService } from '@/services/userService'
import toast from 'react-hot-toast'
import Link from 'next/link'

export default function SettingsPage() {
  const { user, loading, logout } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [activeTab, setActiveTab] = useState<'account' | 'security' | 'notifications'>('account')
  
  // Password change form
  const [passwordData, setPasswordData] = useState({
    old_password: '',
    new_password: '',
    new_password_confirm: '',
  })
  const [showPasswords, setShowPasswords] = useState({
    old: false,
    new: false,
    confirm: false,
  })
  const [isChangingPassword, setIsChangingPassword] = useState(false)
  
  // Notification preferences
  const [notificationPrefs, setNotificationPrefs] = useState({
    email_notifications: true,
    push_notifications: true,
    event_reminders: true,
    friend_requests: true,
    messages: true,
    group_updates: true,
    event_invitations: true,
  })
  const [isLoadingPrefs, setIsLoadingPrefs] = useState(true)
  const [isSavingPrefs, setIsSavingPrefs] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    } else if (user) {
      loadNotificationPreferences()
    }
  }, [mounted, user, loading, router])

  // Handle URL query parameter for tab
  useEffect(() => {
    if (typeof window !== 'undefined') {
      const params = new URLSearchParams(window.location.search)
      const tab = params.get('tab')
      if (tab === 'security' || tab === 'notifications' || tab === 'account') {
        setActiveTab(tab)
      }
    }
  }, [])

  const loadNotificationPreferences = async () => {
    setIsLoadingPrefs(true)
    try {
      const prefs = await userService.getNotificationPreferences()
      setNotificationPrefs(prefs)
    } catch (error) {
      console.error('Error loading notification preferences:', error)
    } finally {
      setIsLoadingPrefs(false)
    }
  }

  const handleChangePassword = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (passwordData.new_password !== passwordData.new_password_confirm) {
      toast.error('Les nouveaux mots de passe ne correspondent pas')
      return
    }
    
    if (passwordData.new_password.length < 8) {
      toast.error('Le mot de passe doit contenir au moins 8 caractères')
      return
    }
    
    setIsChangingPassword(true)
    try {
      await userService.changePassword(
        passwordData.old_password,
        passwordData.new_password,
        passwordData.new_password_confirm
      )
      toast.success('Mot de passe modifié avec succès!')
      setPasswordData({
        old_password: '',
        new_password: '',
        new_password_confirm: '',
      })
    } catch (error: any) {
      console.error('Error changing password:', error)
      const errorMessage = typeof error.response?.data?.error === 'string' 
        ? error.response.data.error 
        : (error.response?.data?.error?.message || error.response?.data?.message || 'Erreur lors de la modification du mot de passe')
      toast.error(errorMessage)
    } finally {
      setIsChangingPassword(false)
    }
  }

  const handleSaveNotificationPreferences = async () => {
    setIsSavingPrefs(true)
    try {
      await userService.updateNotificationPreferences(notificationPrefs)
      toast.success('Préférences de notifications mises à jour!')
    } catch (error: any) {
      console.error('Error saving notification preferences:', error)
      const errorMessage = typeof error.response?.data?.error === 'string' 
        ? error.response.data.error 
        : (error.response?.data?.error?.message || error.response?.data?.message || 'Erreur lors de la sauvegarde des préférences')
      toast.error(errorMessage)
    } finally {
      setIsSavingPrefs(false)
    }
  }

  const handleLogout = () => {
    logout()
    router.push('/')
  }

  const handleGoBack = () => {
    router.push('/dashboard')
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

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
      {/* Header - CampusLink Design */}
      <CampusLinkHeader
        title="Paramètres"
        subtitle="Gérez vos préférences et votre compte"
        icon={<FiSettings className="w-6 h-6 sm:w-7 sm:h-7 text-white" />}
        showBackButton
        onBack={handleGoBack}
      />

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-4 sm:py-6">
        {/* Tabs - Improved Design */}
        <div className="bg-white rounded-xl shadow-lg p-4 sm:p-5 mb-6 border border-gray-100">
          <div className="flex flex-wrap gap-2">
            <button
              onClick={() => setActiveTab('account')}
              className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition ${
                activeTab === 'account'
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <FiUser className="w-4 h-4" />
              <span>Compte</span>
            </button>
            <button
              onClick={() => setActiveTab('security')}
              className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition ${
                activeTab === 'security'
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <FiLock className="w-4 h-4" />
              <span>Sécurité</span>
            </button>
            <button
              onClick={() => setActiveTab('notifications')}
              className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition ${
                activeTab === 'notifications'
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <FiBell className="w-4 h-4" />
              <span>Notifications</span>
            </button>
          </div>
        </div>

        {/* Account Tab - Improved Design */}
        {activeTab === 'account' && (
          <div className="bg-white rounded-xl shadow-lg p-6 sm:p-8 border border-gray-100">
            <h2 className="text-xl font-bold text-gray-900 mb-4 flex items-center gap-2">
              <FiUser className="w-5 h-5 text-primary-600" />
              Informations du compte
            </h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Email</label>
                <input
                  type="email"
                  value={user.email}
                  disabled
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 text-gray-500"
                />
                <p className="text-xs text-gray-500 mt-1">L'email ne peut pas être modifié</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Nom d'utilisateur</label>
                <input
                  type="text"
                  value={user.username}
                  disabled
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 text-gray-500"
                />
                <p className="text-xs text-gray-500 mt-1">Le nom d'utilisateur ne peut pas être modifié</p>
              </div>
              <div className="pt-4 border-t border-gray-200">
                <Link
                  href="/profile"
                  className="inline-flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition"
                >
                  <FiUser className="w-4 h-4" />
                  <span>Modifier mon profil</span>
                </Link>
              </div>
            </div>
          </div>
        )}

        {/* Security Tab - Improved Design */}
        {activeTab === 'security' && (
          <div className="bg-white rounded-xl shadow-lg p-6 sm:p-8 border border-gray-100">
            <h2 className="text-xl font-bold text-gray-900 mb-4 flex items-center gap-2">
              <FiLock className="w-5 h-5 text-primary-600" />
              Sécurité
            </h2>
            <form onSubmit={handleChangePassword} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Ancien mot de passe</label>
                <div className="relative">
                  <input
                    type={showPasswords.old ? 'text' : 'password'}
                    value={passwordData.old_password}
                    onChange={(e) => setPasswordData({ ...passwordData, old_password: e.target.value })}
                    required
                    className="w-full px-4 py-2 pr-10 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    disabled={isChangingPassword}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPasswords({ ...showPasswords, old: !showPasswords.old })}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                  >
                    {showPasswords.old ? <FiEyeOff className="w-5 h-5" /> : <FiEye className="w-5 h-5" />}
                  </button>
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Nouveau mot de passe</label>
                <div className="relative">
                  <input
                    type={showPasswords.new ? 'text' : 'password'}
                    value={passwordData.new_password}
                    onChange={(e) => setPasswordData({ ...passwordData, new_password: e.target.value })}
                    required
                    minLength={8}
                    className="w-full px-4 py-2 pr-10 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    disabled={isChangingPassword}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPasswords({ ...showPasswords, new: !showPasswords.new })}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                  >
                    {showPasswords.new ? <FiEyeOff className="w-5 h-5" /> : <FiEye className="w-5 h-5" />}
                  </button>
                </div>
                <p className="text-xs text-gray-500 mt-1">Au moins 8 caractères</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Confirmer le nouveau mot de passe</label>
                <div className="relative">
                  <input
                    type={showPasswords.confirm ? 'text' : 'password'}
                    value={passwordData.new_password_confirm}
                    onChange={(e) => setPasswordData({ ...passwordData, new_password_confirm: e.target.value })}
                    required
                    minLength={8}
                    className="w-full px-4 py-2 pr-10 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    disabled={isChangingPassword}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPasswords({ ...showPasswords, confirm: !showPasswords.confirm })}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                  >
                    {showPasswords.confirm ? <FiEyeOff className="w-5 h-5" /> : <FiEye className="w-5 h-5" />}
                  </button>
                </div>
              </div>
              <button
                type="submit"
                disabled={isChangingPassword}
                className="flex items-center gap-2 px-6 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <FiSave className="w-4 h-4" />
                <span>{isChangingPassword ? 'Modification...' : 'Modifier le mot de passe'}</span>
              </button>
            </form>
          </div>
        )}

        {/* Notifications Tab - Improved Design */}
        {activeTab === 'notifications' && (
          <div className="bg-white rounded-xl shadow-lg p-6 sm:p-8 border border-gray-100">
            <h2 className="text-xl font-bold text-gray-900 mb-4 flex items-center gap-2">
              <FiBell className="w-5 h-5 text-primary-600" />
              Préférences de notifications
            </h2>
            {isLoadingPrefs ? (
              <div className="text-center py-8">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
                <p className="mt-4 text-gray-600">Chargement...</p>
              </div>
            ) : (
              <div className="space-y-4">
                <div className="flex items-center justify-between py-3 border-b border-gray-200">
                  <div>
                    <h3 className="font-medium text-gray-900">Notifications par email</h3>
                    <p className="text-sm text-gray-600">Recevoir des notifications par email</p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input
                      type="checkbox"
                      checked={notificationPrefs.email_notifications}
                      onChange={(e) => setNotificationPrefs({ ...notificationPrefs, email_notifications: e.target.checked })}
                      className="sr-only peer"
                    />
                    <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
                  </label>
                </div>
                <div className="flex items-center justify-between py-3 border-b border-gray-200">
                  <div>
                    <h3 className="font-medium text-gray-900">Notifications push</h3>
                    <p className="text-sm text-gray-600">Recevoir des notifications push dans le navigateur</p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input
                      type="checkbox"
                      checked={notificationPrefs.push_notifications}
                      onChange={(e) => setNotificationPrefs({ ...notificationPrefs, push_notifications: e.target.checked })}
                      className="sr-only peer"
                    />
                    <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
                  </label>
                </div>
                <div className="flex items-center justify-between py-3 border-b border-gray-200">
                  <div>
                    <h3 className="font-medium text-gray-900">Rappels d'événements</h3>
                    <p className="text-sm text-gray-600">Recevoir des rappels pour les événements auxquels vous participez</p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input
                      type="checkbox"
                      checked={notificationPrefs.event_reminders}
                      onChange={(e) => setNotificationPrefs({ ...notificationPrefs, event_reminders: e.target.checked })}
                      className="sr-only peer"
                    />
                    <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
                  </label>
                </div>
                <div className="flex items-center justify-between py-3 border-b border-gray-200">
                  <div>
                    <h3 className="font-medium text-gray-900">Demandes d'amis</h3>
                    <p className="text-sm text-gray-600">Recevoir des notifications pour les demandes d'amis</p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input
                      type="checkbox"
                      checked={notificationPrefs.friend_requests}
                      onChange={(e) => setNotificationPrefs({ ...notificationPrefs, friend_requests: e.target.checked })}
                      className="sr-only peer"
                    />
                    <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
                  </label>
                </div>
                <div className="flex items-center justify-between py-3 border-b border-gray-200">
                  <div>
                    <h3 className="font-medium text-gray-900">Messages</h3>
                    <p className="text-sm text-gray-600">Recevoir des notifications pour les nouveaux messages</p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input
                      type="checkbox"
                      checked={notificationPrefs.messages}
                      onChange={(e) => setNotificationPrefs({ ...notificationPrefs, messages: e.target.checked })}
                      className="sr-only peer"
                    />
                    <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
                  </label>
                </div>
                <div className="flex items-center justify-between py-3 border-b border-gray-200">
                  <div>
                    <h3 className="font-medium text-gray-900">Mises à jour de groupes</h3>
                    <p className="text-sm text-gray-600">Recevoir des notifications pour les activités de vos groupes</p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input
                      type="checkbox"
                      checked={notificationPrefs.group_updates}
                      onChange={(e) => setNotificationPrefs({ ...notificationPrefs, group_updates: e.target.checked })}
                      className="sr-only peer"
                    />
                    <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
                  </label>
                </div>
                <div className="flex items-center justify-between py-3">
                  <div>
                    <h3 className="font-medium text-gray-900">Invitations à des événements</h3>
                    <p className="text-sm text-gray-600">Recevoir des notifications pour les invitations à des événements</p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input
                      type="checkbox"
                      checked={notificationPrefs.event_invitations}
                      onChange={(e) => setNotificationPrefs({ ...notificationPrefs, event_invitations: e.target.checked })}
                      className="sr-only peer"
                    />
                    <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
                  </label>
                </div>
                <button
                  onClick={handleSaveNotificationPreferences}
                  disabled={isSavingPrefs}
                  className="flex items-center gap-2 px-6 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition disabled:opacity-50 disabled:cursor-not-allowed mt-6"
                >
                  <FiSave className="w-4 h-4" />
                  <span>{isSavingPrefs ? 'Sauvegarde...' : 'Enregistrer les préférences'}</span>
                </button>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  )
}
