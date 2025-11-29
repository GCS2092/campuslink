'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { useEffect, useState } from 'react'
import { FiUser, FiCheck, FiX, FiUsers, FiMail, FiCalendar, FiUserCheck, FiLogOut, FiArrowLeft } from 'react-icons/fi'
import FilterBar, { type FilterOption } from '@/components/FilterBar'
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

const VERIFICATION_STATUS_OPTIONS: FilterOption[] = [
  { value: 'pending', label: 'En attente' },
  { value: 'verified', label: 'Vérifié' },
  { value: 'rejected', label: 'Rejeté' },
]

const ACTIVE_STATUS_OPTIONS: FilterOption[] = [
  { value: 'true', label: 'Actif' },
  { value: 'false', label: 'Inactif' },
]

const ORDERING_OPTIONS: FilterOption[] = [
  { value: '-date_joined', label: 'Date d\'inscription (récent)' },
  { value: 'date_joined', label: 'Date d\'inscription (ancien)' },
  { value: 'username', label: 'Nom d\'utilisateur (A-Z)' },
  { value: '-username', label: 'Nom d\'utilisateur (Z-A)' },
  { value: 'email', label: 'Email (A-Z)' },
  { value: '-email', label: 'Email (Z-A)' },
]

interface Student {
  id: string
  username: string
  email: string
  first_name?: string
  last_name?: string
  is_active: boolean
  is_verified: boolean
  verification_status: string
  date_joined: string
  profile?: {
    university?: string
    field_of_study?: string
  }
}

export default function AdminStudentsPage() {
  const { user, loading, logout } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [students, setStudents] = useState<Student[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedUniversity, setSelectedUniversity] = useState('')
  const [selectedStatus, setSelectedStatus] = useState('')
  const [selectedActiveStatus, setSelectedActiveStatus] = useState('')
  const [ordering, setOrdering] = useState('-date_joined')
  const [currentPage, setCurrentPage] = useState(1)
  const [totalPages, setTotalPages] = useState(1)
  const [totalCount, setTotalCount] = useState(0)

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    } else if (mounted && user && user.role !== 'admin' && user.role !== 'class_leader') {
      // Class leaders can access students page for their class
      router.push('/dashboard')
    }
  }, [mounted, user, loading, router])

  useEffect(() => {
    if (user && (user.role === 'admin' || user.role === 'class_leader')) {
      loadStudents()
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user, searchTerm, selectedUniversity, selectedStatus, selectedActiveStatus, ordering, currentPage])

  const loadStudents = async () => {
    if (!user) return

    setIsLoading(true)
    try {
      const params: any = {
        page: currentPage,
        page_size: 20,
        ordering: ordering,
      }

      if (searchTerm) {
        params.search = searchTerm
      }

      // Only admins can filter by university (class leaders see only their university)
      if (selectedUniversity && user?.role === 'admin') {
        params.university = selectedUniversity
      }

      if (selectedStatus) {
        params.verification_status = selectedStatus
      }

      if (selectedActiveStatus) {
        params.is_active = selectedActiveStatus
      }

      const response = await adminService.getPendingStudents(params)
      
      // Safe response handling - handle both paginated and non-paginated responses
      let studentsList: Student[] = []
      let totalCount = 0
      
      if (Array.isArray(response)) {
        // Direct array response
        studentsList = response
        totalCount = response.length
      } else if (response && typeof response === 'object') {
        // Paginated response with results
        studentsList = response.results || response.data || []
        totalCount = response.count || studentsList.length
      }
      
      setStudents(studentsList)
      setTotalCount(totalCount)
      setTotalPages(Math.ceil(totalCount / 20))
    } catch (error) {
      // Error handled silently, students list will remain empty
      setStudents([])
      setTotalCount(0)
      setTotalPages(1)
    } finally {
      setIsLoading(false)
    }
  }

  const handleActivate = async (studentId: string) => {
    if (!confirm('Êtes-vous sûr de vouloir activer ce compte ?')) return

    try {
      await adminService.activateStudent(studentId)
      await loadStudents()
    } catch (error) {
      console.error('Error activating student:', error)
      alert('Erreur lors de l\'activation du compte')
    }
  }

  const handleDeactivate = async (studentId: string) => {
    if (!confirm('Êtes-vous sûr de vouloir désactiver ce compte ?')) return

    try {
      await adminService.deactivateStudent(studentId)
      await loadStudents()
    } catch (error) {
      console.error('Error deactivating student:', error)
      alert('Erreur lors de la désactivation du compte')
    }
  }

  const handleAssignClassLeader = async (studentId: string) => {
    if (!confirm('Êtes-vous sûr de vouloir assigner ce rôle de responsable de classe ?')) return

    try {
      await adminService.assignClassLeader(studentId)
      alert('Responsable de classe assigné avec succès')
      await loadStudents()
    } catch (error: any) {
      console.error('Error assigning class leader:', error)
      alert(error.response?.data?.error || 'Erreur lors de l\'assignation du rôle')
    }
  }

  const resetFilters = () => {
    setSearchTerm('')
    setSelectedUniversity('')
    setSelectedStatus('')
    setSelectedActiveStatus('')
    setOrdering('-date_joined')
    setCurrentPage(1)
  }

  const handleLogout = () => {
    logout()
    router.push('/')
  }

  const handleGoBack = () => {
    if (user?.role === 'admin') {
      router.push('/admin/dashboard')
    } else {
      router.push('/dashboard')
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

  if (!user || (user.role !== 'admin' && user.role !== 'class_leader')) {
    return null
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
                  Gestion des Étudiants
                </h1>
                <p className="text-sm text-gray-600 hidden sm:block">
                  Activez ou désactivez les comptes des étudiants
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
            // Only show university filter for admins, not for class leaders
            ...(user?.role === 'admin' ? [{
              label: 'Université',
              name: 'university',
              options: UNIVERSITIES.map((u) => ({ value: u, label: u })),
              value: selectedUniversity,
              onChange: (value: string) => {
                setSelectedUniversity(value)
                setCurrentPage(1)
              },
            }] : []),
            {
              label: 'Statut de vérification',
              name: 'verification_status',
              options: VERIFICATION_STATUS_OPTIONS,
              value: selectedStatus,
              onChange: (value: string) => {
                setSelectedStatus(value)
                setCurrentPage(1)
              },
            },
            {
              label: 'Statut d\'activation',
              name: 'is_active',
              options: ACTIVE_STATUS_OPTIONS,
              value: selectedActiveStatus,
              onChange: (value: string) => {
                setSelectedActiveStatus(value)
                setCurrentPage(1)
              },
            },
            {
              label: 'Trier par',
              name: 'ordering',
              options: ORDERING_OPTIONS,
              value: ordering,
              onChange: (value: string) => {
                setOrdering(value)
                setCurrentPage(1)
              },
            },
          ]}
          onReset={resetFilters}
        />

        {/* Students List */}
        {isLoading ? (
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Chargement des étudiants...</p>
          </div>
        ) : students.length === 0 ? (
          <div className="bg-white rounded-2xl shadow-lg p-8 sm:p-12 text-center mt-6">
            <FiUsers className="w-12 h-12 sm:w-16 sm:h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg sm:text-xl font-semibold text-gray-900 mb-2">
              Aucun étudiant trouvé
            </h3>
            <p className="text-gray-600 text-sm sm:text-base">
              {searchTerm || selectedUniversity || selectedStatus
                ? 'Essayez de modifier vos critères de recherche.'
                : 'Il n\'y a pas d\'étudiants en attente de validation.'}
            </p>
          </div>
        ) : (
          <>
            <div className="mt-6 space-y-4">
              {students.map((student) => (
                <div
                  key={student.id}
                  className="bg-white dark:bg-gray-800 rounded-xl shadow-md p-4 sm:p-6 hover:shadow-lg transition"
                >
                  <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                    <Link href={`/users/${student.id}`} className="flex-1 min-w-0 cursor-pointer">
                      <div className="flex items-center gap-3 mb-2">
                        <div className="w-10 h-10 sm:w-12 sm:h-12 bg-primary-100 dark:bg-primary-900/30 rounded-full flex items-center justify-center flex-shrink-0">
                          <FiUser className="w-5 h-5 sm:w-6 sm:h-6 text-primary-600 dark:text-primary-400" />
                        </div>
                        <div className="min-w-0 flex-1">
                          <h3 className="text-base sm:text-lg font-semibold text-gray-900 dark:text-white truncate hover:text-primary-600 dark:hover:text-primary-400 transition">
                            {student.first_name && student.last_name
                              ? `${student.first_name} ${student.last_name}`
                              : student.username}
                          </h3>
                          <div className="flex flex-wrap items-center gap-2 text-xs sm:text-sm text-gray-600 dark:text-gray-400">
                            <span className="flex items-center gap-1">
                              <FiMail className="w-3 h-3 sm:w-4 sm:h-4" />
                              {student.email}
                            </span>
                            <span className="flex items-center gap-1">
                              <FiCalendar className="w-3 h-3 sm:w-4 sm:h-4" />
                              {new Date(student.date_joined).toLocaleDateString('fr-FR')}
                            </span>
                          </div>
                        </div>
                      </div>

                      {student.profile?.university && (
                        <p className="text-xs sm:text-sm text-gray-600 dark:text-gray-400 ml-14 sm:ml-16">
                          {typeof student.profile.university === 'string' 
                            ? student.profile.university 
                            : student.profile.university?.name || student.profile.university?.short_name || 'Université'}
                          {student.profile.field_of_study && ` - ${student.profile.field_of_study}`}
                        </p>
                      )}

                      <div className="flex flex-wrap gap-2 mt-3 ml-14 sm:ml-16">
                        <span
                          className={`px-2 py-1 rounded text-xs ${
                            student.is_active
                              ? 'bg-green-100 text-green-700'
                              : 'bg-red-100 text-red-700'
                          }`}
                        >
                          {student.is_active ? 'Actif' : 'Inactif'}
                        </span>
                        <span
                          className={`px-2 py-1 rounded text-xs ${
                            student.is_verified
                              ? 'bg-blue-100 text-blue-700'
                              : 'bg-yellow-100 text-yellow-700'
                          }`}
                        >
                          {student.verification_status === 'verified'
                            ? 'Vérifié'
                            : student.verification_status === 'rejected'
                            ? 'Rejeté'
                            : 'En attente'}
                        </span>
                      </div>
                    </Link>

                    <div className="flex flex-col sm:flex-row gap-2 w-full sm:w-auto" onClick={(e) => e.stopPropagation()}>
                      {/* View Profile Button - Available for all (admin and class leader) */}
                      <Link
                        href={`/users/${student.id}`}
                        className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition text-sm sm:text-base w-full sm:w-auto justify-center"
                      >
                        <FiUser className="w-4 h-4" />
                        Voir profil
                      </Link>
                      
                      {/* Admin/Class Leader Actions */}
                      {student.is_active ? (
                        <>
                          <button
                            onClick={() => handleDeactivate(student.id)}
                            className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition text-sm sm:text-base w-full sm:w-auto justify-center"
                          >
                            <FiX className="w-4 h-4" />
                            Désactiver
                          </button>
                          {/* Only admins can promote to class leader */}
                          {user?.role === 'admin' && (
                            <button
                              onClick={() => handleAssignClassLeader(student.id)}
                              className="flex items-center gap-2 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition text-sm sm:text-base w-full sm:w-auto justify-center"
                            >
                              <FiUserCheck className="w-4 h-4" />
                              Assigner Responsable
                            </button>
                          )}
                        </>
                      ) : (
                        <button
                          onClick={() => handleActivate(student.id)}
                          className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition text-sm sm:text-base w-full sm:w-auto justify-center"
                        >
                          <FiCheck className="w-4 h-4" />
                          Activer
                        </button>
                      )}
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

