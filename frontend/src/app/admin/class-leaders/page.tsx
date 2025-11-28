'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiUser, FiUserCheck, FiUserX, FiUsers, FiMail, FiCalendar, FiChevronDown, FiChevronUp, FiLogOut, FiArrowLeft } from 'react-icons/fi'
import FilterBar from '@/components/FilterBar'
import Pagination from '@/components/Pagination'
import { adminService } from '@/services/adminService'

const UNIVERSITIES = [
  'ESMT',
  'UCAD',
  'UGB',
  'ESP',
  'UASZ',
  'Université de Thiès',
]

const ORDERING_OPTIONS = [
  { value: '-date_joined', label: 'Date d\'inscription (récent)' },
  { value: 'date_joined', label: 'Date d\'inscription (ancien)' },
  { value: 'username', label: 'Nom d\'utilisateur (A-Z)' },
  { value: '-username', label: 'Nom d\'utilisateur (Z-A)' },
  { value: 'email', label: 'Email (A-Z)' },
  { value: '-email', label: 'Email (Z-A)' },
  { value: '-last_login', label: 'Dernière connexion (récent)' },
  { value: 'last_login', label: 'Dernière connexion (ancien)' },
  { value: 'profile__university', label: 'École (A-Z)' },
  { value: '-profile__university', label: 'École (Z-A)' },
]

interface ClassLeader {
  id: string
  username: string
  email: string
  first_name?: string
  last_name?: string
  is_active: boolean
  is_verified: boolean
  verification_status: string
  date_joined: string
  last_login?: string
  profile?: {
    university?: string
    field_of_study?: string
  }
}

export default function ClassLeadersPage() {
  const { user, loading, logout } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [leaders, setLeaders] = useState<ClassLeader[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedUniversity, setSelectedUniversity] = useState('')
  const [selectedActive, setSelectedActive] = useState('')
  const [selectedOrdering, setSelectedOrdering] = useState('-date_joined')
  const [currentPage, setCurrentPage] = useState(1)
  const [totalPages, setTotalPages] = useState(1)
  const [totalCount, setTotalCount] = useState(0)

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    } else if (mounted && user && user.role !== 'admin' && user.role !== 'university_admin') {
      router.push('/dashboard')
    }
  }, [mounted, user, loading, router])

  useEffect(() => {
    if (user && (user.role === 'admin' || user.role === 'university_admin')) {
      loadLeaders()
    }
  }, [user, searchTerm, selectedUniversity, selectedActive, selectedOrdering, currentPage])

  const loadLeaders = async () => {
    if (!user) return

    setIsLoading(true)
    try {
      const params: any = {
        page: currentPage,
        page_size: 20,
        ordering: selectedOrdering,
      }

      if (searchTerm) {
        params.search = searchTerm
      }

      // Only admins can filter by university (university admins see only their university)
      if (selectedUniversity && user?.role === 'admin') {
        params.university = selectedUniversity
      }

      if (selectedActive !== '') {
        params.is_active = selectedActive === 'true'
      }

      const response = await adminService.getClassLeaders(params)
      setLeaders(response.results || response)
      setTotalCount(response.count || (response.results || response).length)
      
      if (response.count !== undefined) {
        setTotalPages(Math.ceil(response.count / 20))
      }
    } catch (error) {
      console.error('Error loading class leaders:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const handleRevoke = async (leaderId: string) => {
    if (!confirm('Êtes-vous sûr de vouloir révoquer le rôle de responsable de classe ?')) return

    try {
      await adminService.revokeClassLeader(leaderId)
      await loadLeaders()
    } catch (error) {
      console.error('Error revoking class leader:', error)
      alert('Erreur lors de la révocation du rôle')
    }
  }

  const resetFilters = () => {
    setSearchTerm('')
    setSelectedUniversity('')
    setSelectedActive('')
    setSelectedOrdering('-date_joined')
    setCurrentPage(1)
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

  if (!user || (user.role !== 'admin' && user.role !== 'university_admin')) {
    return null
  }

  const handleLogout = () => {
    logout()
    router.push('/')
  }

  const handleGoBack = () => {
    if (user?.role === 'admin') {
      router.push('/admin/dashboard')
    } else if (user?.role === 'university_admin') {
      router.push('/university-admin/dashboard')
    } else {
      router.push('/dashboard')
    }
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
                <h1 className="text-xl sm:text-2xl font-bold text-gray-900">Gestion des Responsables de Classe</h1>
                <p className="text-sm text-gray-600 hidden sm:block">
                  Visualisez et gérez les responsables de classe par école
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

        {/* Filters */}
        <FilterBar
          searchPlaceholder="Rechercher par nom, email..."
          searchValue={searchTerm}
          onSearchChange={(value) => {
            setSearchTerm(value)
            setCurrentPage(1)
          }}
          filters={[
            // Only show university filter for global admins, not for university admins
            ...(user?.role === 'admin' ? [{
              label: 'Université',
              name: 'university',
              options: UNIVERSITIES.map((u) => ({ value: u, label: u })),
              value: selectedUniversity,
              onChange: (value) => {
                setSelectedUniversity(value)
                setCurrentPage(1)
              },
            }] : []),
            {
              label: 'Statut',
              name: 'is_active',
              options: [
                { value: 'true', label: 'Actif' },
                { value: 'false', label: 'Inactif' },
              ],
              value: selectedActive,
              onChange: (value) => {
                setSelectedActive(value)
                setCurrentPage(1)
              },
            },
            {
              label: 'Trier par',
              name: 'ordering',
              options: ORDERING_OPTIONS,
              value: selectedOrdering,
              onChange: (value) => {
                setSelectedOrdering(value)
                setCurrentPage(1)
              },
            },
          ]}
          onReset={resetFilters}
        />

        {/* Leaders List */}
        {isLoading ? (
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Chargement des responsables...</p>
          </div>
        ) : leaders.length === 0 ? (
          <div className="bg-white rounded-2xl shadow-lg p-8 sm:p-12 text-center mt-6">
            <FiUsers className="w-12 h-12 sm:w-16 sm:h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg sm:text-xl font-semibold text-gray-900 mb-2">
              Aucun responsable de classe trouvé
            </h3>
            <p className="text-gray-600 text-sm sm:text-base">
              {searchTerm || selectedUniversity || selectedActive
                ? 'Essayez de modifier vos critères de recherche.'
                : 'Il n\'y a pas encore de responsables de classe assignés.'}
            </p>
          </div>
        ) : (
          <>
            <div className="mt-6 space-y-4">
              {leaders.map((leader) => (
                <div
                  key={leader.id}
                  className="bg-white rounded-xl shadow-md p-4 sm:p-6 hover:shadow-lg transition"
                >
                  <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-3 mb-2">
                        <div className="w-10 h-10 sm:w-12 sm:h-12 bg-purple-100 rounded-full flex items-center justify-center flex-shrink-0">
                          <FiUserCheck className="w-5 h-5 sm:w-6 sm:h-6 text-purple-600" />
                        </div>
                        <div className="min-w-0 flex-1">
                          <h3 className="text-base sm:text-lg font-semibold text-gray-900 truncate">
                            {leader.first_name && leader.last_name
                              ? `${leader.first_name} ${leader.last_name}`
                              : leader.username}
                          </h3>
                          <div className="flex flex-wrap items-center gap-2 text-xs sm:text-sm text-gray-600">
                            <span className="flex items-center gap-1">
                              <FiMail className="w-3 h-3 sm:w-4 sm:h-4" />
                              {leader.email}
                            </span>
                            <span className="flex items-center gap-1">
                              <FiCalendar className="w-3 h-3 sm:w-4 sm:h-4" />
                              {new Date(leader.date_joined).toLocaleDateString('fr-FR')}
                            </span>
                            {leader.last_login && (
                              <span className="text-xs text-gray-500">
                                Dernière connexion: {new Date(leader.last_login).toLocaleDateString('fr-FR')}
                              </span>
                            )}
                          </div>
                        </div>
                      </div>

                      {leader.profile?.university && (
                        <p className="text-xs sm:text-sm text-gray-600 ml-14 sm:ml-16 mb-2">
                          <span className="font-medium">École:</span> {
                            typeof leader.profile.university === 'string' 
                              ? leader.profile.university 
                              : leader.profile.university?.name || leader.profile.university?.short_name || 'Université'
                          }
                          {leader.profile.field_of_study && ` - ${leader.profile.field_of_study}`}
                        </p>
                      )}

                      <div className="flex flex-wrap gap-2 mt-3 ml-14 sm:ml-16">
                        <span
                          className={`px-2 py-1 rounded text-xs ${
                            leader.is_active
                              ? 'bg-green-100 text-green-700'
                              : 'bg-red-100 text-red-700'
                          }`}
                        >
                          {leader.is_active ? 'Actif' : 'Inactif'}
                        </span>
                        <span
                          className={`px-2 py-1 rounded text-xs ${
                            leader.is_verified
                              ? 'bg-blue-100 text-blue-700'
                              : 'bg-yellow-100 text-yellow-700'
                          }`}
                        >
                          {leader.verification_status === 'verified'
                            ? 'Vérifié'
                            : leader.verification_status === 'rejected'
                            ? 'Rejeté'
                            : 'En attente'}
                        </span>
                        <span className="px-2 py-1 rounded text-xs bg-purple-100 text-purple-700">
                          Responsable de Classe
                        </span>
                      </div>
                    </div>

                    <div className="flex gap-2 w-full sm:w-auto">
                      <button
                        onClick={() => handleRevoke(leader.id)}
                        className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition text-sm sm:text-base w-full sm:w-auto justify-center"
                      >
                        <FiUserX className="w-4 h-4" />
                        Révoquer le rôle
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>

            {/* Pagination */}
            <Pagination
              currentPage={currentPage}
              totalPages={totalPages}
              onPageChange={setCurrentPage}
              pageSize={20}
              totalItems={totalCount}
            />
          </>
        )}
      </div>
    </div>
  )
}

