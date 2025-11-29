'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { useEffect, useState } from 'react'
import { FiUser, FiCheck, FiX, FiUsers, FiMail, FiCalendar, FiUserCheck, FiLogOut, FiArrowLeft, FiPlus } from 'react-icons/fi'
import FilterBar, { type FilterOption } from '@/components/FilterBar'
import Pagination from '@/components/Pagination'
import { adminService } from '@/services/adminService'
import { universityService } from '@/services/universityService'
import toast from 'react-hot-toast'

const VERIFICATION_STATUS_OPTIONS: FilterOption[] = [
  { value: 'pending', label: 'En attente' },
  { value: 'verified', label: 'Vérifié' },
  { value: 'rejected', label: 'Rejeté' },
]

const ACTIVE_STATUS_OPTIONS: FilterOption[] = [
  { value: 'true', label: 'Actif' },
  { value: 'false', label: 'Inactif' },
]

const ACADEMIC_YEAR_OPTIONS: FilterOption[] = [
  { value: 'Licence 1', label: 'Licence 1' },
  { value: 'Licence 2', label: 'Licence 2' },
  { value: 'Licence 3', label: 'Licence 3' },
  { value: 'Master 1', label: 'Master 1' },
  { value: 'Master 2', label: 'Master 2' },
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
    academic_year?: string
  }
}

export default function UniversityAdminStudentsPage() {
  const { user, loading, logout } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [students, setStudents] = useState<Student[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedStatus, setSelectedStatus] = useState('')
  const [selectedActiveStatus, setSelectedActiveStatus] = useState('')
  const [selectedAcademicYear, setSelectedAcademicYear] = useState('')
  const [ordering, setOrdering] = useState('-date_joined')
  const [currentPage, setCurrentPage] = useState(1)
  const [totalPages, setTotalPages] = useState(1)
  const [totalCount, setTotalCount] = useState(0)
  const [showCreateModal, setShowCreateModal] = useState(false)
  const [isCreating, setIsCreating] = useState(false)
  const [academicYears, setAcademicYears] = useState<{ id: string; year: string }[]>([])
  const [formData, setFormData] = useState({
    email: '',
    username: '',
    password: '',
    password_confirm: '',
    phone_number: '',
    first_name: '',
    last_name: '',
    academic_year_id: '',
  })

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
      loadStudents()
      loadAcademicYears()
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user, searchTerm, selectedStatus, selectedActiveStatus, selectedAcademicYear, ordering, currentPage])

  const loadAcademicYears = async () => {
    try {
      const university = await universityService.getMyUniversity()
      // For now, use the static options since we don't have an academic years endpoint yet
      // In the future, we can add: const response = await universityService.getAcademicYears({ university: university.id })
      setAcademicYears([]) // Will be populated when endpoint is available
    } catch (error) {
      console.error('Error loading academic years:', error)
    }
  }

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

      // University admin doesn't need university filter - backend filters automatically
      if (selectedStatus) {
        params.verification_status = selectedStatus
      }

      if (selectedActiveStatus) {
        params.is_active = selectedActiveStatus
      }

      if (selectedAcademicYear) {
        params.academic_year = selectedAcademicYear
      }

      const response = await adminService.getPendingStudents(params)
      
      let studentsList: Student[] = []
      let totalCount = 0
      
      if (Array.isArray(response)) {
        studentsList = response
        totalCount = response.length
      } else if (response && typeof response === 'object') {
        studentsList = response.results || response.data || []
        totalCount = response.count || studentsList.length
      }
      
      setStudents(studentsList)
      setTotalCount(totalCount)
      setTotalPages(Math.ceil(totalCount / 20))
    } catch (error) {
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
      toast.success('Compte activé avec succès!')
      await loadStudents()
    } catch (error) {
      console.error('Error activating student:', error)
      toast.error('Erreur lors de l\'activation du compte')
    }
  }

  const handleDeactivate = async (studentId: string) => {
    if (!confirm('Êtes-vous sûr de vouloir désactiver ce compte ?')) return

    try {
      await adminService.deactivateStudent(studentId)
      toast.success('Compte désactivé avec succès!')
      await loadStudents()
    } catch (error) {
      console.error('Error deactivating student:', error)
      toast.error('Erreur lors de la désactivation du compte')
    }
  }

  const handleAssignClassLeader = async (studentId: string) => {
    if (!confirm('Êtes-vous sûr de vouloir assigner ce rôle de responsable de classe ?')) return

    try {
      await adminService.assignClassLeader(studentId)
      toast.success('Responsable de classe assigné avec succès')
      await loadStudents()
    } catch (error: any) {
      console.error('Error assigning class leader:', error)
      toast.error(error.response?.data?.error || 'Erreur lors de l\'assignation du rôle')
    }
  }

  const handleCreateStudent = async () => {
    if (!formData.email || !formData.username || !formData.password || !formData.password_confirm || !formData.phone_number || !formData.academic_year_id) {
      toast.error('Veuillez remplir tous les champs obligatoires')
      return
    }

    if (formData.password !== formData.password_confirm) {
      toast.error('Les mots de passe ne correspondent pas')
      return
    }

    setIsCreating(true)
    try {
      await adminService.createStudent({
        email: formData.email,
        username: formData.username,
        password: formData.password,
        password_confirm: formData.password_confirm,
        phone_number: formData.phone_number,
        first_name: formData.first_name || undefined,
        last_name: formData.last_name || undefined,
        academic_year_id: formData.academic_year_id,
      })
      toast.success('Étudiant créé avec succès!')
      setShowCreateModal(false)
      setFormData({
        email: '',
        username: '',
        password: '',
        password_confirm: '',
        phone_number: '',
        first_name: '',
        last_name: '',
        academic_year_id: '',
      })
      await loadStudents()
    } catch (error: any) {
      console.error('Error creating student:', error)
      const errorMessage = error.response?.data?.error || error.response?.data?.message || 'Erreur lors de la création de l\'étudiant'
      if (typeof errorMessage === 'object') {
        Object.keys(errorMessage).forEach((key) => {
          const fieldErrors = Array.isArray(errorMessage[key]) ? errorMessage[key] : [errorMessage[key]]
          fieldErrors.forEach((err: string) => {
            toast.error(`${key}: ${err}`)
          })
        })
      } else {
        toast.error(errorMessage)
      }
    } finally {
      setIsCreating(false)
    }
  }

  const resetFilters = () => {
    setSearchTerm('')
    setSelectedStatus('')
    setSelectedActiveStatus('')
    setSelectedAcademicYear('')
    setOrdering('-date_joined')
    setCurrentPage(1)
  }

  const handleLogout = () => {
    logout()
    router.push('/')
  }

  const handleGoBack = () => {
    router.push('/university-admin/dashboard')
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

  if (!user || user.role !== 'university_admin') {
    return null
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
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
                  Activez ou désactivez les comptes des étudiants de votre université
                </p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <button
                onClick={() => setShowCreateModal(true)}
                className="flex items-center gap-2 px-3 sm:px-4 py-2 text-sm sm:text-base bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition"
                title="Ajouter un étudiant"
              >
                <FiPlus className="w-4 h-4 sm:w-5 sm:h-5" />
                <span className="hidden sm:inline">Ajouter un étudiant</span>
              </button>
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
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 sm:py-6 lg:py-8">
        <FilterBar
          searchPlaceholder="Rechercher par nom, email..."
          searchValue={searchTerm}
          onSearchChange={(value) => {
            setSearchTerm(value)
            setCurrentPage(1)
          }}
          filters={[
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
              label: 'Classe',
              name: 'academic_year',
              options: ACADEMIC_YEAR_OPTIONS,
              value: selectedAcademicYear,
              onChange: (value: string) => {
                setSelectedAcademicYear(value)
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
              {searchTerm || selectedStatus
                ? 'Essayez de modifier vos critères de recherche.'
                : 'Il n\'y a pas d\'étudiants dans votre université.'}
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
                          {student.profile.academic_year && ` - ${student.profile.academic_year}`}
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
                      <Link
                        href={`/users/${student.id}`}
                        className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition text-sm sm:text-base w-full sm:w-auto justify-center"
                      >
                        <FiUser className="w-4 h-4" />
                        Voir profil
                      </Link>
                      
                      {student.is_active ? (
                        <>
                          <button
                            onClick={() => handleDeactivate(student.id)}
                            className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition text-sm sm:text-base w-full sm:w-auto justify-center"
                          >
                            <FiX className="w-4 h-4" />
                            Désactiver
                          </button>
                          <button
                            onClick={() => handleAssignClassLeader(student.id)}
                            className="flex items-center gap-2 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition text-sm sm:text-base w-full sm:w-auto justify-center"
                          >
                            <FiUserCheck className="w-4 h-4" />
                            Assigner Responsable
                          </button>
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

      {/* Create Student Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-2xl font-bold text-gray-900">Ajouter un étudiant</h2>
                <button
                  onClick={() => setShowCreateModal(false)}
                  className="text-gray-400 hover:text-gray-600 transition"
                  disabled={isCreating}
                >
                  <FiX className="w-6 h-6" />
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Email universitaire <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="email"
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    placeholder="exemple@esmt.sn"
                    disabled={isCreating}
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Nom d&apos;utilisateur <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    value={formData.username}
                    onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    placeholder="johndoe"
                    disabled={isCreating}
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Prénom
                    </label>
                    <input
                      type="text"
                      value={formData.first_name}
                      onChange={(e) => setFormData({ ...formData, first_name: e.target.value })}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                      placeholder="John"
                      disabled={isCreating}
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Nom
                    </label>
                    <input
                      type="text"
                      value={formData.last_name}
                      onChange={(e) => setFormData({ ...formData, last_name: e.target.value })}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                      placeholder="Doe"
                      disabled={isCreating}
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Numéro de téléphone <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="tel"
                    value={formData.phone_number}
                    onChange={(e) => setFormData({ ...formData, phone_number: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    placeholder="+221771234567"
                    disabled={isCreating}
                  />
                  <p className="mt-1 text-xs text-gray-500">Format : +221XXXXXXXXX</p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Classe <span className="text-red-500">*</span>
                  </label>
                  <select
                    value={formData.academic_year_id}
                    onChange={(e) => setFormData({ ...formData, academic_year_id: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    disabled={isCreating}
                  >
                    <option value="">Sélectionnez une classe</option>
                    {ACADEMIC_YEAR_OPTIONS.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Mot de passe <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="password"
                    value={formData.password}
                    onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    placeholder="••••••••"
                    disabled={isCreating}
                  />
                  <p className="mt-1 text-xs text-gray-500">Minimum 8 caractères, 1 majuscule, 1 minuscule, 1 chiffre, 1 caractère spécial</p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Confirmer le mot de passe <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="password"
                    value={formData.password_confirm}
                    onChange={(e) => setFormData({ ...formData, password_confirm: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    placeholder="••••••••"
                    disabled={isCreating}
                  />
                </div>
              </div>

              <div className="flex items-center justify-end gap-3 mt-6">
                <button
                  onClick={() => setShowCreateModal(false)}
                  className="px-4 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition"
                  disabled={isCreating}
                >
                  Annuler
                </button>
                <button
                  onClick={handleCreateStudent}
                  disabled={isCreating}
                  className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                >
                  {isCreating ? (
                    <>
                      <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                      <span>Création...</span>
                    </>
                  ) : (
                    <>
                      <FiPlus className="w-4 h-4" />
                      <span>Créer l&apos;étudiant</span>
                    </>
                  )}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
