'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import Link from 'next/link'
import { FiUsers, FiCalendar, FiCheckCircle, FiXCircle, FiClock, FiLogOut, FiArrowLeft, FiShield, FiUserCheck, FiFileText, FiBookOpen, FiMapPin, FiBook, FiSettings } from 'react-icons/fi'
import { adminService } from '@/services/adminService'

interface DashboardStats {
  pending_students_count: number
  active_students_count: number
  total_students_count: number
  verified_students_count: number
  unverified_students_count: number
  events_count: number
  groups_count: number
  posts_count: number
  class_leaders_count: number
  registrations_last_7_days: number
  registrations_last_30_days: number
  registrations_this_month: number
  active_students_last_7_days: number
  active_students_last_30_days: number
  activity_rate: number
  verification_rate: number
  upcoming_events: number
  past_events: number
  events_this_month: number
  verified_groups: number
  public_groups: number
  groups_this_month: number
  university: {
    id: string
    name: string
    short_name: string
  }
  recent_registrations: Array<{
    id: string
    username: string
    email: string
    date_joined: string
    is_active: boolean
    is_verified: boolean
  }>
}

export default function UniversityAdminDashboardPage() {
  const { user, loading, logout } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    } else if (mounted && user && user.role !== 'university_admin') {
      router.push('/dashboard')
    }
  }, [mounted, user, loading, router])

  useEffect(() => {
    if (user && user.role === 'university_admin') {
      loadStats()
    }
  }, [user])

  const loadStats = async () => {
    if (!user) return

    setIsLoading(true)
    try {
      const statsData = await adminService.getUniversityAdminDashboardStats()
      setStats(statsData)
    } catch (error) {
      console.error('Error loading stats:', error)
    } finally {
      setIsLoading(false)
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

  if (!user || user.role !== 'university_admin') {
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
      {/* Header with navigation */}
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
                <h1 className="text-xl sm:text-2xl font-bold text-gray-900">
                  Tableau de Bord - Administrateur d&apos;Université
                </h1>
                <p className="text-sm text-gray-600 hidden sm:block">
                  {stats?.university?.name && `Gérez ${stats.university.name}`}
                </p>
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

        {stats && (
          <>
            {/* University Info */}
            {stats.university && (
              <div className="bg-gradient-to-r from-primary-600 to-primary-700 rounded-xl shadow-lg p-4 sm:p-6 mb-6 text-white">
                <div className="flex items-center gap-3">
                  <FiBookOpen className="w-6 h-6 sm:w-8 sm:h-8" />
                  <div>
                    <h2 className="text-xl sm:text-2xl font-bold">{stats.university.name}</h2>
                    <p className="text-primary-100 text-sm sm:text-base">{stats.university.short_name}</p>
                  </div>
                </div>
              </div>
            )}

            {/* Stats Cards */}
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-6 sm:mb-8">
              <Link
                href="/university-admin/students"
                className="bg-white rounded-xl shadow-md p-4 sm:p-6 hover:shadow-lg transition"
              >
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-xs sm:text-sm text-gray-600 mb-1">En attente</p>
                    <p className="text-xl sm:text-2xl font-bold text-gray-900">
                      {stats.pending_students_count}
                    </p>
                  </div>
                  <div className="p-2 sm:p-3 bg-yellow-100 rounded-lg">
                    <FiClock className="w-5 h-5 sm:w-6 sm:h-6 text-yellow-600" />
                  </div>
                </div>
              </Link>

              <div className="bg-white rounded-xl shadow-md p-4 sm:p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-xs sm:text-sm text-gray-600 mb-1">Actifs</p>
                    <p className="text-xl sm:text-2xl font-bold text-gray-900">
                      {stats.active_students_count}
                    </p>
                  </div>
                  <div className="p-2 sm:p-3 bg-green-100 rounded-lg">
                    <FiCheckCircle className="w-5 h-5 sm:w-6 sm:h-6 text-green-600" />
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl shadow-md p-4 sm:p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-xs sm:text-sm text-gray-600 mb-1">Total</p>
                    <p className="text-xl sm:text-2xl font-bold text-gray-900">
                      {stats.total_students_count}
                    </p>
                  </div>
                  <div className="p-2 sm:p-3 bg-blue-100 rounded-lg">
                    <FiUsers className="w-5 h-5 sm:w-6 sm:h-6 text-blue-600" />
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl shadow-md p-4 sm:p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-xs sm:text-sm text-gray-600 mb-1">Responsables</p>
                    <p className="text-xl sm:text-2xl font-bold text-gray-900">
                      {stats.class_leaders_count}
                    </p>
                  </div>
                  <div className="p-2 sm:p-3 bg-purple-100 rounded-lg">
                    <FiUserCheck className="w-5 h-5 sm:w-6 sm:h-6 text-purple-600" />
                  </div>
                </div>
              </div>
            </div>

            {/* Additional Stats */}
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-6 sm:mb-8">
              <div className="bg-white rounded-xl shadow-md p-4 sm:p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-xs sm:text-sm text-gray-600 mb-1">Événements</p>
                    <p className="text-xl sm:text-2xl font-bold text-gray-900">
                      {stats.events_count}
                    </p>
                    <p className="text-xs text-gray-500 mt-1">
                      {stats.upcoming_events} à venir
                    </p>
                  </div>
                  <div className="p-2 sm:p-3 bg-primary-100 rounded-lg">
                    <FiCalendar className="w-5 h-5 sm:w-6 sm:h-6 text-primary-600" />
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl shadow-md p-4 sm:p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-xs sm:text-sm text-gray-600 mb-1">Groupes</p>
                    <p className="text-xl sm:text-2xl font-bold text-gray-900">
                      {stats.groups_count}
                    </p>
                    <p className="text-xs text-gray-500 mt-1">
                      {stats.verified_groups} vérifiés
                    </p>
                  </div>
                  <div className="p-2 sm:p-3 bg-indigo-100 rounded-lg">
                    <FiUsers className="w-5 h-5 sm:w-6 sm:h-6 text-indigo-600" />
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl shadow-md p-4 sm:p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-xs sm:text-sm text-gray-600 mb-1">Taux d&apos;activité</p>
                    <p className="text-xl sm:text-2xl font-bold text-gray-900">
                      {stats.activity_rate.toFixed(1)}%
                    </p>
                    <p className="text-xs text-gray-500 mt-1">
                      {stats.active_students_last_30_days} actifs (30j)
                    </p>
                  </div>
                  <div className="p-2 sm:p-3 bg-green-100 rounded-lg">
                    <FiCheckCircle className="w-5 h-5 sm:w-6 sm:h-6 text-green-600" />
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl shadow-md p-4 sm:p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-xs sm:text-sm text-gray-600 mb-1">Taux de vérification</p>
                    <p className="text-xl sm:text-2xl font-bold text-gray-900">
                      {stats.verification_rate.toFixed(1)}%
                    </p>
                    <p className="text-xs text-gray-500 mt-1">
                      {stats.verified_students_count} vérifiés
                    </p>
                  </div>
                  <div className="p-2 sm:p-3 bg-blue-100 rounded-lg">
                    <FiCheckCircle className="w-5 h-5 sm:w-6 sm:h-6 text-blue-600" />
                  </div>
                </div>
              </div>
            </div>

            {/* Quick Actions */}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 mb-6 sm:mb-8">
              <Link
                href="/university-admin/students"
                className="bg-white rounded-xl shadow-md p-4 sm:p-6 hover:shadow-lg transition flex items-center gap-4"
              >
                <div className="p-3 bg-blue-100 rounded-lg">
                  <FiUsers className="w-6 h-6 text-blue-600" />
                </div>
                <div>
                  <p className="font-semibold text-gray-900">Gérer les Étudiants</p>
                  <p className="text-sm text-gray-600">Activer, désactiver, vérifier</p>
                </div>
              </Link>

              <Link
                href="/university-admin/class-leaders"
                className="bg-white rounded-xl shadow-md p-4 sm:p-6 hover:shadow-lg transition flex items-center gap-4"
              >
                <div className="p-3 bg-purple-100 rounded-lg">
                  <FiUserCheck className="w-6 h-6 text-purple-600" />
                </div>
                <div>
                  <p className="font-semibold text-gray-900">Responsables de Classe</p>
                  <p className="text-sm text-gray-600">Assigner et gérer</p>
                </div>
              </Link>

              <Link
                href="/university-admin/moderation"
                className="bg-white rounded-xl shadow-md p-4 sm:p-6 hover:shadow-lg transition flex items-center gap-4"
              >
                <div className="p-3 bg-red-100 rounded-lg">
                  <FiShield className="w-6 h-6 text-red-600" />
                </div>
                <div>
                  <p className="font-semibold text-gray-900">Modération</p>
                  <p className="text-sm text-gray-600">Gérer les signalements</p>
                </div>
              </Link>

              <Link
                href="/university-admin/users"
                className="bg-white rounded-xl shadow-md p-4 sm:p-6 hover:shadow-lg transition flex items-center gap-4"
              >
                <div className="p-3 bg-green-100 rounded-lg">
                  <FiUserCheck className="w-6 h-6 text-green-600" />
                </div>
                <div>
                  <p className="font-semibold text-gray-900">Vérifications</p>
                  <p className="text-sm text-gray-600">Gérer les comptes en attente</p>
                </div>
              </Link>

              <Link
                href="/university-admin/campuses"
                className="bg-white rounded-xl shadow-md p-4 sm:p-6 hover:shadow-lg transition flex items-center gap-4"
              >
                <div className="p-3 bg-indigo-100 rounded-lg">
                  <FiMapPin className="w-6 h-6 text-indigo-600" />
                </div>
                <div>
                  <p className="font-semibold text-gray-900">Campus</p>
                  <p className="text-sm text-gray-600">Gérer les campus</p>
                </div>
              </Link>


              <Link
                href="/university-admin/settings"
                className="bg-white rounded-xl shadow-md p-4 sm:p-6 hover:shadow-lg transition flex items-center gap-4"
              >
                <div className="p-3 bg-gray-100 rounded-lg">
                  <FiSettings className="w-6 h-6 text-gray-600" />
                </div>
                <div>
                  <p className="font-semibold text-gray-900">Paramètres</p>
                  <p className="text-sm text-gray-600">Configurer l&apos;université</p>
                </div>
              </Link>

              <Link
                href="/university-admin/audit-logs"
                className="bg-white rounded-xl shadow-md p-4 sm:p-6 hover:shadow-lg transition flex items-center gap-4"
              >
                <div className="p-3 bg-purple-100 rounded-lg">
                  <FiFileText className="w-6 h-6 text-purple-600" />
                </div>
                <div>
                  <p className="font-semibold text-gray-900">Logs d&apos;Audit</p>
                  <p className="text-sm text-gray-600">Voir l&apos;historique</p>
                </div>
              </Link>
            </div>

            {/* Recent Registrations */}
            {stats.recent_registrations && stats.recent_registrations.length > 0 && (
              <div className="bg-white rounded-xl shadow-md p-4 sm:p-6">
                <h2 className="text-lg sm:text-xl font-bold text-gray-900 mb-4">
                  Inscriptions Récentes
                </h2>
                <div className="space-y-3">
                  {stats.recent_registrations.map((registration) => (
                    <div
                      key={registration.id}
                      className="flex items-center justify-between p-3 border border-gray-200 rounded-lg"
                    >
                      <div className="flex-1 min-w-0">
                        <p className="text-sm sm:text-base font-medium text-gray-900 truncate">
                          {registration.username}
                        </p>
                        <p className="text-xs sm:text-sm text-gray-600 truncate">
                          {registration.email}
                        </p>
                        <p className="text-xs text-gray-500 mt-1">
                          {new Date(registration.date_joined).toLocaleDateString('fr-FR', {
                            day: 'numeric',
                            month: 'long',
                            year: 'numeric',
                            hour: '2-digit',
                            minute: '2-digit',
                          })}
                        </p>
                      </div>
                      <div className="flex gap-2 ml-4">
                        {registration.is_active ? (
                          <span className="px-2 py-1 bg-green-100 text-green-700 rounded text-xs">
                            Actif
                          </span>
                        ) : (
                          <span className="px-2 py-1 bg-red-100 text-red-700 rounded text-xs">
                            Inactif
                          </span>
                        )}
                        {registration.is_verified ? (
                          <span className="px-2 py-1 bg-blue-100 text-blue-700 rounded text-xs">
                            Vérifié
                          </span>
                        ) : (
                          <span className="px-2 py-1 bg-yellow-100 text-yellow-700 rounded text-xs">
                            Non vérifié
                          </span>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  )
}

