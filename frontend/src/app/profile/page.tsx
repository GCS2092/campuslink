'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter, useSearchParams } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiUser, FiMail, FiPhone, FiMapPin, FiEdit2, FiSave, FiX, FiCalendar, FiUsers, FiHash, FiTrendingUp, FiArrowRight, FiClock, FiBarChart2 } from 'react-icons/fi'
import Link from 'next/link'
import { userService } from '@/services/userService'
import toast from 'react-hot-toast'
import { LineChart, Line, BarChart, Bar, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'
import { getUniversityName } from '@/utils/typeHelpers'

interface ProfileStats {
  events: {
    organized: number
    participated: number
    upcoming: number
  }
  groups: {
    created: number
    member: number
  }
  friends: {
    count: number
  }
  recent_events?: Array<{
    id: string
    title: string
    start_date: string
    status: string
  }>
  recent_participations?: Array<{
    id: string
    event__id: string
    event__title: string
    event__start_date: string
    created_at: string
  }>
}

export default function ProfilePage() {
  const { user, loading, refreshUser } = useAuth()
  const router = useRouter()
  const searchParams = useSearchParams()
  const [mounted, setMounted] = useState(false)
  const [isEditing, setIsEditing] = useState(false)
  const [isSaving, setIsSaving] = useState(false)
  const [stats, setStats] = useState<ProfileStats | null>(null)
  const [isLoadingStats, setIsLoadingStats] = useState(false)
  const [detailedStats, setDetailedStats] = useState<any>(null)
  const [isLoadingDetailedStats, setIsLoadingDetailedStats] = useState(false)
  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    bio: '',
    website: '',
    facebook: '',
    instagram: '',
    twitter: '',
  })

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    } else if (user) {
      setFormData({
        first_name: user.first_name || '',
        last_name: user.last_name || '',
        bio: user.profile?.bio || '',
        website: user.profile?.website || '',
        facebook: user.profile?.facebook || '',
        instagram: user.profile?.instagram || '',
        twitter: user.profile?.twitter || '',
      })
      loadStats()
      loadDetailedStats()
      
      // Check if edit parameter is present
      if (searchParams.get('edit') === 'true') {
        setIsEditing(true)
        // Scroll to edit section
        setTimeout(() => {
          const editSection = document.getElementById('profile-edit-section')
          if (editSection) {
            editSection.scrollIntoView({ behavior: 'smooth', block: 'start' })
          }
        }, 100)
      }
    }
  }, [mounted, user, loading, router, searchParams])

  const loadStats = async () => {
    if (!user) return
    setIsLoadingStats(true)
    try {
      const statsData = await userService.getProfileStats()
      setStats(statsData)
    } catch (error) {
      console.error('Error loading stats:', error)
    } finally {
      setIsLoadingStats(false)
    }
  }

  const loadDetailedStats = async () => {
    if (!user) return
    setIsLoadingDetailedStats(true)
    try {
      const detailedData = await userService.getProfileStatsDetailed()
      setDetailedStats(detailedData)
    } catch (error) {
      console.error('Error loading detailed stats:', error)
    } finally {
      setIsLoadingDetailedStats(false)
    }
  }

  const handleSave = async () => {
    if (!user) return
    
    setIsSaving(true)
    try {
      await userService.updateProfile({
        first_name: formData.first_name,
        last_name: formData.last_name,
        bio: formData.bio,
        website: formData.website || undefined,
        facebook: formData.facebook || undefined,
        instagram: formData.instagram || undefined,
        twitter: formData.twitter || undefined,
      })
      
      // Refresh user data
      await refreshUser()
      
      toast.success('Profil mis à jour avec succès!')
      setIsEditing(false)
      // Reload stats to reflect any changes
      await loadStats()
    } catch (error: any) {
      console.error('Error updating profile:', error)
      const errorMessage = typeof error.response?.data?.error === 'string' 
        ? error.response.data.error 
        : (error.response?.data?.error?.message || error.response?.data?.message || 'Erreur lors de la mise à jour du profil')
      toast.error(errorMessage)
    } finally {
      setIsSaving(false)
    }
  }

  const handleCancel = () => {
    // Reset form data to original values
    if (user) {
      setFormData({
        first_name: user.first_name || '',
        last_name: user.last_name || '',
        bio: user.profile?.bio || '',
        website: user.profile?.website || '',
        facebook: user.profile?.facebook || '',
        instagram: user.profile?.instagram || '',
        twitter: user.profile?.twitter || '',
      })
    }
    setIsEditing(false)
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

  const profilePicture = user.profile?.profile_picture
  const coverPicture = user.profile?.cover_picture

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Cover Image */}
        {coverPicture && (
          <div className="bg-white rounded-2xl shadow-lg overflow-hidden mb-6">
            <div className="h-48 bg-gradient-to-r from-primary-500 to-secondary-500 relative">
              <img
                src={coverPicture}
                alt="Cover"
                className="w-full h-full object-cover"
              />
            </div>
          </div>
        )}

        {/* Profile Header - Improved Design */}
        <div id="profile-edit-section" className="bg-white rounded-2xl shadow-xl p-6 sm:p-8 mb-6 border border-gray-100">
          <div className="flex items-start justify-between mb-6">
            <div className="flex items-center gap-4">
              <div className="relative">
                {profilePicture ? (
                  <img
                    src={profilePicture}
                    alt={user.username}
                    className="w-24 h-24 rounded-full object-cover border-4 border-white shadow-lg"
                  />
                ) : (
                  <div className="w-24 h-24 bg-primary-100 rounded-full flex items-center justify-center border-4 border-white shadow-lg">
                    <FiUser className="w-12 h-12 text-primary-600" />
                  </div>
                )}
              </div>
              <div>
                <h1 className="text-2xl sm:text-3xl font-bold text-gray-900">
                  {user.first_name && user.last_name
                    ? `${user.first_name} ${user.last_name}`
                    : user.username || user.email}
                </h1>
                <p className="text-gray-600">@{user.username}</p>
                {user.profile?.university && (
                  <div className="flex items-center gap-1 mt-1 text-sm text-gray-500">
                    <FiMapPin className="w-4 h-4" />
                    <span>
                      {getUniversityName(user.profile.university)}
                    </span>
                    {user.profile?.academic_year_obj && (
                      <span className="ml-2">
                        • {user.profile.academic_year_obj.name || user.profile.academic_year_obj.year}
                      </span>
                    )}
                  </div>
                )}
              </div>
            </div>
            {!isEditing ? (
              <button
                onClick={() => setIsEditing(true)}
                className="flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition"
              >
                <FiEdit2 className="w-4 h-4" />
                <span className="hidden sm:inline">Modifier</span>
              </button>
            ) : (
              <div className="flex gap-2">
                <button
                  onClick={handleSave}
                  disabled={isSaving}
                  className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <FiSave className="w-4 h-4" />
                  <span className="hidden sm:inline">{isSaving ? 'Enregistrement...' : 'Enregistrer'}</span>
                </button>
                <button
                  onClick={handleCancel}
                  disabled={isSaving}
                  className="flex items-center gap-2 px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition disabled:opacity-50"
                >
                  <FiX className="w-4 h-4" />
                  <span className="hidden sm:inline">Annuler</span>
                </button>
              </div>
            )}
          </div>

          {/* Statistics Cards - Improved Design */}
          {stats && (
            <div className="grid grid-cols-2 sm:grid-cols-5 gap-4 mb-6">
              <div className="group bg-gradient-to-br from-blue-50 to-blue-100 rounded-xl p-4 shadow-md hover:shadow-xl transition-all duration-300 border border-blue-200/50 hover:-translate-y-1">
                <div className="flex items-center gap-2 mb-2">
                  <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform">
                    <FiCalendar className="w-5 h-5 text-white" />
                  </div>
                  <span className="text-sm font-semibold text-blue-700">Événements</span>
                </div>
                <p className="text-3xl font-bold text-blue-900">{stats.events.participated}</p>
                <p className="text-xs text-blue-600 font-medium">participations</p>
              </div>
              <div className="group bg-gradient-to-br from-purple-50 to-purple-100 rounded-xl p-4 shadow-md hover:shadow-xl transition-all duration-300 border border-purple-200/50 hover:-translate-y-1">
                <div className="flex items-center gap-2 mb-2">
                  <div className="w-10 h-10 bg-gradient-to-br from-purple-500 to-purple-600 rounded-lg flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform">
                    <FiHash className="w-5 h-5 text-white" />
                  </div>
                  <span className="text-sm font-semibold text-purple-700">Groupes</span>
                </div>
                <p className="text-3xl font-bold text-purple-900">{stats.groups.member}</p>
                <p className="text-xs text-purple-600 font-medium">membres</p>
              </div>
              <div className="group bg-gradient-to-br from-green-50 to-green-100 rounded-xl p-4 shadow-md hover:shadow-xl transition-all duration-300 border border-green-200/50 hover:-translate-y-1">
                <div className="flex items-center gap-2 mb-2">
                  <div className="w-10 h-10 bg-gradient-to-br from-green-500 to-green-600 rounded-lg flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform">
                    <FiUsers className="w-5 h-5 text-white" />
                  </div>
                  <span className="text-sm font-semibold text-green-700">Amis</span>
                </div>
                <p className="text-3xl font-bold text-green-900">{stats.friends.count}</p>
                <p className="text-xs text-green-600 font-medium">connexions</p>
              </div>
              <div className="group bg-gradient-to-br from-orange-50 to-orange-100 rounded-xl p-4 shadow-md hover:shadow-xl transition-all duration-300 border border-orange-200/50 hover:-translate-y-1">
                <div className="flex items-center gap-2 mb-2">
                  <div className="w-10 h-10 bg-gradient-to-br from-orange-500 to-orange-600 rounded-lg flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform">
                    <FiTrendingUp className="w-5 h-5 text-white" />
                  </div>
                  <span className="text-sm font-semibold text-orange-700">Organisés</span>
                </div>
                <p className="text-3xl font-bold text-orange-900">{stats.events.organized}</p>
                <p className="text-xs text-orange-600 font-medium">événements</p>
              </div>
              {user.profile?.reputation_score !== undefined && (
                <div className="group bg-gradient-to-br from-yellow-50 to-yellow-100 rounded-xl p-4 shadow-md hover:shadow-xl transition-all duration-300 border border-yellow-200/50 hover:-translate-y-1">
                  <div className="flex items-center gap-2 mb-2">
                    <div className="w-10 h-10 bg-gradient-to-br from-yellow-500 to-yellow-600 rounded-lg flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform">
                      <FiBarChart2 className="w-5 h-5 text-white" />
                    </div>
                    <span className="text-sm font-semibold text-yellow-700">Réputation</span>
                  </div>
                  <p className="text-3xl font-bold text-yellow-900">{user.profile.reputation_score}</p>
                  <p className="text-xs text-yellow-600 font-medium">points</p>
                </div>
              )}
            </div>
          )}

          {/* Profile Info */}
          <div className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="flex items-center gap-3">
                <FiMail className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Email</p>
                  <p className="text-gray-900">{user.email}</p>
                </div>
              </div>

              {user.phone_number && (
                <div className="flex items-center gap-3">
                  <FiPhone className="w-5 h-5 text-gray-400" />
                  <div>
                    <p className="text-sm text-gray-500">Téléphone</p>
                    <p className="text-gray-900">{user.phone_number}</p>
                  </div>
                </div>
              )}

              {isEditing ? (
                <>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Prénom</label>
                    <input
                      type="text"
                      value={formData.first_name}
                      onChange={(e) => setFormData({ ...formData, first_name: e.target.value })}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                      disabled={isSaving}
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Nom</label>
                    <input
                      type="text"
                      value={formData.last_name}
                      onChange={(e) => setFormData({ ...formData, last_name: e.target.value })}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                      disabled={isSaving}
                    />
                  </div>
                </>
              ) : (
                <>
                  {user.first_name && (
                    <div>
                      <p className="text-sm text-gray-500">Prénom</p>
                      <p className="text-gray-900">{user.first_name}</p>
                    </div>
                  )}
                  {user.last_name && (
                    <div>
                      <p className="text-sm text-gray-500">Nom</p>
                      <p className="text-gray-900">{user.last_name}</p>
                    </div>
                  )}
                </>
              )}
            </div>

            {/* Bio */}
            {isEditing ? (
              <div className="mt-4">
                <label className="block text-sm font-medium text-gray-700 mb-2">Bio</label>
                <textarea
                  value={formData.bio}
                  onChange={(e) => setFormData({ ...formData, bio: e.target.value })}
                  rows={4}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                  placeholder="Parlez-nous de vous..."
                  disabled={isSaving}
                />
              </div>
            ) : (
              user.profile?.bio && (
                <div className="mt-4">
                  <p className="text-sm font-medium text-gray-700 mb-2">Bio</p>
                  <p className="text-gray-900 whitespace-pre-wrap">{user.profile.bio}</p>
                </div>
              )
            )}

            {/* Social Links */}
            {isEditing ? (
              <div className="mt-4 grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Site web</label>
                  <input
                    type="url"
                    value={formData.website}
                    onChange={(e) => setFormData({ ...formData, website: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    placeholder="https://..."
                    disabled={isSaving}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Facebook</label>
                  <input
                    type="text"
                    value={formData.facebook}
                    onChange={(e) => setFormData({ ...formData, facebook: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    placeholder="@username"
                    disabled={isSaving}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Instagram</label>
                  <input
                    type="text"
                    value={formData.instagram}
                    onChange={(e) => setFormData({ ...formData, instagram: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    placeholder="@username"
                    disabled={isSaving}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Twitter</label>
                  <input
                    type="text"
                    value={formData.twitter}
                    onChange={(e) => setFormData({ ...formData, twitter: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    placeholder="@username"
                    disabled={isSaving}
                  />
                </div>
              </div>
            ) : (
              (user.profile?.website || user.profile?.facebook || user.profile?.instagram || user.profile?.twitter) && (
                <div className="mt-4">
                  <p className="text-sm font-medium text-gray-700 mb-2">Réseaux sociaux</p>
                  <div className="flex flex-wrap gap-3">
                    {user.profile.website && (
                      <a
                        href={user.profile.website}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-primary-600 hover:text-primary-700 text-sm"
                      >
                        🌐 Site web
                      </a>
                    )}
                    {user.profile.facebook && (
                      <a
                        href={`https://facebook.com/${user.profile.facebook.replace('@', '')}`}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-blue-600 hover:text-blue-700 text-sm"
                      >
                        📘 Facebook
                      </a>
                    )}
                    {user.profile.instagram && (
                      <a
                        href={`https://instagram.com/${user.profile.instagram.replace('@', '')}`}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-pink-600 hover:text-pink-700 text-sm"
                      >
                        📷 Instagram
                      </a>
                    )}
                    {user.profile.twitter && (
                      <a
                        href={`https://twitter.com/${user.profile.twitter.replace('@', '')}`}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-blue-400 hover:text-blue-500 text-sm"
                      >
                        🐦 Twitter
                      </a>
                    )}
                  </div>
                </div>
              )
            )}

            {/* Status Badges */}
            <div className="mt-6 flex flex-wrap items-center gap-2">
              <span
                className={`px-3 py-1 rounded-full text-sm font-medium ${
                  user.is_verified
                    ? 'bg-green-100 text-green-800'
                    : 'bg-yellow-100 text-yellow-800'
                }`}
              >
                {user.is_verified ? '✓ Compte vérifié' : '⚠ Compte non vérifié'}
              </span>
              <span
                className={`px-3 py-1 rounded-full text-sm font-medium ${
                  user.role === 'admin'
                    ? 'bg-red-100 text-red-800'
                    : user.role === 'class_leader'
                    ? 'bg-purple-100 text-purple-800'
                    : user.role === 'association'
                    ? 'bg-blue-100 text-blue-800'
                    : user.role === 'sponsor'
                    ? 'bg-yellow-100 text-yellow-800'
                    : 'bg-gray-100 text-gray-800'
                }`}
              >
                {user.role === 'admin'
                  ? 'Administrateur'
                  : user.role === 'class_leader'
                  ? 'Responsable de Classe'
                  : user.role === 'association'
                  ? 'Association/Club'
                  : user.role === 'sponsor'
                  ? 'Partenaire/Sponsor'
                  : 'Étudiant'}
              </span>
            </div>
          </div>
        </div>

        {/* Recent Events Section */}
        {stats && stats.recent_events && stats.recent_events.length > 0 && (
          <div className="bg-white rounded-2xl shadow-lg p-6 mb-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-xl font-bold text-gray-900 flex items-center gap-2">
                <FiCalendar className="w-5 h-5 text-primary-600" />
                Mes Événements Organisés
              </h2>
              <Link
                href="/events/my-events"
                className="text-sm text-primary-600 hover:text-primary-700 font-medium flex items-center gap-1"
              >
                Voir tout
                <FiArrowRight className="w-4 h-4" />
              </Link>
            </div>
            <div className="space-y-3">
              {stats.recent_events.map((event) => (
                <Link
                  key={event.id}
                  href={`/events/${event.id}`}
                  className="block p-4 bg-gray-50 hover:bg-gray-100 rounded-lg transition border border-gray-200 hover:border-primary-300"
                >
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <h3 className="font-semibold text-gray-900 mb-1">{event.title}</h3>
                      <div className="flex items-center gap-2 text-sm text-gray-600">
                        <FiClock className="w-4 h-4" />
                        <span>
                          {new Date(event.start_date).toLocaleDateString('fr-FR', {
                            day: 'numeric',
                            month: 'long',
                            year: 'numeric',
                            hour: '2-digit',
                            minute: '2-digit'
                          })}
                        </span>
                      </div>
                    </div>
                    <span
                      className={`px-2 py-1 rounded text-xs font-medium ${
                        event.status === 'published'
                          ? 'bg-green-100 text-green-800'
                          : event.status === 'draft'
                          ? 'bg-gray-100 text-gray-800'
                          : 'bg-red-100 text-red-800'
                      }`}
                    >
                      {event.status === 'published'
                        ? 'Publié'
                        : event.status === 'draft'
                        ? 'Brouillon'
                        : event.status}
                    </span>
                  </div>
                </Link>
              ))}
            </div>
          </div>
        )}

        {/* Recent Participations Section */}
        {stats && stats.recent_participations && stats.recent_participations.length > 0 && (
          <div className="bg-white rounded-2xl shadow-lg p-6 mb-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-xl font-bold text-gray-900 flex items-center gap-2">
                <FiUsers className="w-5 h-5 text-primary-600" />
                Mes Participations Récentes
              </h2>
              <Link
                href="/events/my-events"
                className="text-sm text-primary-600 hover:text-primary-700 font-medium flex items-center gap-1"
              >
                Voir tout
                <FiArrowRight className="w-4 h-4" />
              </Link>
            </div>
            <div className="space-y-3">
              {stats.recent_participations.map((participation) => (
                <Link
                  key={participation.id}
                  href={`/events/${participation.event__id}`}
                  className="block p-4 bg-gray-50 hover:bg-gray-100 rounded-lg transition border border-gray-200 hover:border-primary-300"
                >
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <h3 className="font-semibold text-gray-900 mb-1">{participation.event__title}</h3>
                      <div className="flex items-center gap-2 text-sm text-gray-600">
                        <FiClock className="w-4 h-4" />
                        <span>
                          {new Date(participation.event__start_date).toLocaleDateString('fr-FR', {
                            day: 'numeric',
                            month: 'long',
                            year: 'numeric',
                            hour: '2-digit',
                            minute: '2-digit'
                          })}
                        </span>
                        <span className="text-gray-400">•</span>
                        <span className="text-xs">
                          Inscrit le{' '}
                          {new Date(participation.created_at).toLocaleDateString('fr-FR', {
                            day: 'numeric',
                            month: 'long',
                            year: 'numeric'
                          })}
                        </span>
                      </div>
                    </div>
                    <FiArrowRight className="w-5 h-5 text-gray-400" />
                  </div>
                </Link>
              ))}
            </div>
          </div>
        )}

        {/* Statistics Charts Section */}
        {detailedStats && (
          <div className="bg-white rounded-2xl shadow-lg p-6 mb-6">
            <div className="flex items-center gap-2 mb-6">
              <FiBarChart2 className="w-6 h-6 text-primary-600" />
              <h2 className="text-xl font-bold text-gray-900">Statistiques Détaillées</h2>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              {/* Monthly Participations Chart */}
              {detailedStats.monthly_participations && detailedStats.monthly_participations.length > 0 && (
                <div className="bg-gray-50 rounded-xl p-4">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Participations par Mois</h3>
                  <ResponsiveContainer width="100%" height={250}>
                    <LineChart data={detailedStats.monthly_participations}>
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis 
                        dataKey="month" 
                        tick={{ fontSize: 12 }}
                        angle={-45}
                        textAnchor="end"
                        height={60}
                      />
                      <YAxis tick={{ fontSize: 12 }} />
                      <Tooltip />
                      <Legend />
                      <Line 
                        type="monotone" 
                        dataKey="count" 
                        stroke="#3b82f6" 
                        strokeWidth={2}
                        name="Participations"
                      />
                    </LineChart>
                  </ResponsiveContainer>
                </div>
              )}

              {/* Monthly Organized Events Chart */}
              {detailedStats.monthly_organized && detailedStats.monthly_organized.length > 0 && (
                <div className="bg-gray-50 rounded-xl p-4">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Événements Organisés par Mois</h3>
                  <ResponsiveContainer width="100%" height={250}>
                    <BarChart data={detailedStats.monthly_organized}>
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis 
                        dataKey="month" 
                        tick={{ fontSize: 12 }}
                        angle={-45}
                        textAnchor="end"
                        height={60}
                      />
                      <YAxis tick={{ fontSize: 12 }} />
                      <Tooltip />
                      <Legend />
                      <Bar dataKey="count" fill="#8b5cf6" name="Événements" />
                    </BarChart>
                  </ResponsiveContainer>
                </div>
              )}

              {/* Category Distribution Chart */}
              {detailedStats.category_distribution && detailedStats.category_distribution.length > 0 && (
                <div className="bg-gray-50 rounded-xl p-4">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Répartition par Catégorie</h3>
                  <ResponsiveContainer width="100%" height={250}>
                    <PieChart>
                      <Pie
                        data={detailedStats.category_distribution}
                        cx="50%"
                        cy="50%"
                        labelLine={false}
                        label={({ name, percent }) => `${name}: ${((percent || 0) * 100).toFixed(0)}%`}
                        outerRadius={80}
                        fill="#8884d8"
                        dataKey="count"
                      >
                        {detailedStats.category_distribution.map((entry: any, index: number) => {
                          const colors = ['#3b82f6', '#8b5cf6', '#ec4899', '#f59e0b', '#10b981', '#ef4444', '#06b6d4']
                          return <Cell key={`cell-${index}`} fill={colors[index % colors.length]} />
                        })}
                      </Pie>
                      <Tooltip />
                    </PieChart>
                  </ResponsiveContainer>
                </div>
              )}

              {/* Friends Activity */}
              {detailedStats.friends_activity && detailedStats.friends_activity.length > 0 && (
                <div className="bg-gray-50 rounded-xl p-4">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Activité des Amis</h3>
                  <div className="space-y-3">
                    {detailedStats.friends_activity.map((activity: any) => (
                      <Link
                        key={activity.event_id}
                        href={`/events/${activity.event_id}`}
                        className="block p-3 bg-white rounded-lg hover:bg-gray-100 transition border border-gray-200"
                      >
                        <div className="flex items-center justify-between">
                          <div className="flex-1">
                            <h4 className="font-medium text-gray-900 text-sm">{activity.event_title}</h4>
                            <p className="text-xs text-gray-600 mt-1">
                              {activity.friends_count} {activity.friends_count === 1 ? 'ami participe' : 'amis participent'}
                            </p>
                          </div>
                          <FiUsers className="w-5 h-5 text-primary-600" />
                        </div>
                      </Link>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
