'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiBook, FiPlus, FiEdit, FiTrash2, FiLogOut, FiArrowLeft, FiCheck, FiX } from 'react-icons/fi'
import { universityService, Department } from '@/services/universityService'
import toast from 'react-hot-toast'

export default function UniversityAdminDepartmentsPage() {
  const { user, loading, logout } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [departments, setDepartments] = useState<Department[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [showCreateModal, setShowCreateModal] = useState(false)
  const [editingDepartment, setEditingDepartment] = useState<Department | null>(null)
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    is_active: true
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
      loadDepartments()
    }
  }, [user])

  const loadDepartments = async () => {
    setIsLoading(true)
    try {
      const response = await universityService.getDepartments()
      const departmentsList = Array.isArray(response) ? response : response.results || []
      setDepartments(departmentsList)
    } catch (error: any) {
      console.error('Error loading departments:', error)
      toast.error('Erreur lors du chargement des départements')
    } finally {
      setIsLoading(false)
    }
  }

  const handleCreate = async () => {
    try {
      const university = await universityService.getMyUniversity()
      await universityService.createDepartment({
        ...formData,
        university: university.id
      })
      toast.success('Département créé avec succès')
      setShowCreateModal(false)
      resetForm()
      loadDepartments()
    } catch (error: any) {
      console.error('Error creating department:', error)
      toast.error(error.response?.data?.error || 'Erreur lors de la création du département')
    }
  }

  const handleUpdate = async () => {
    if (!editingDepartment) return
    
    try {
      await universityService.updateDepartment(editingDepartment.id, formData)
      toast.success('Département mis à jour avec succès')
      setEditingDepartment(null)
      resetForm()
      loadDepartments()
    } catch (error: any) {
      console.error('Error updating department:', error)
      toast.error(error.response?.data?.error || 'Erreur lors de la mise à jour du département')
    }
  }

  const handleDelete = async (departmentId: string) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce département ?')) return
    
    try {
      await universityService.deleteDepartment(departmentId)
      toast.success('Département supprimé avec succès')
      loadDepartments()
    } catch (error: any) {
      console.error('Error deleting department:', error)
      toast.error(error.response?.data?.error || 'Erreur lors de la suppression du département')
    }
  }

  const resetForm = () => {
    setFormData({
      name: '',
      description: '',
      is_active: true
    })
  }

  const openEditModal = (department: Department) => {
    setEditingDepartment(department)
    setFormData({
      name: department.name,
      description: department.description || '',
      is_active: department.is_active
    })
    setShowCreateModal(true)
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
                <h1 className="text-xl sm:text-2xl font-bold text-gray-900">Gestion des Départements</h1>
                <p className="text-sm text-gray-600 hidden sm:block">
                  Gérez les départements de votre université
                </p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <button
                onClick={() => {
                  resetForm()
                  setEditingDepartment(null)
                  setShowCreateModal(true)
                }}
                className="flex items-center gap-2 px-3 sm:px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition text-sm sm:text-base"
              >
                <FiPlus className="w-4 h-4" />
                <span className="hidden sm:inline">Nouveau Département</span>
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

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 sm:py-8">
        {isLoading ? (
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Chargement des départements...</p>
          </div>
        ) : departments.length === 0 ? (
          <div className="bg-white rounded-lg shadow-sm p-8 text-center">
            <FiBook className="mx-auto h-12 w-12 text-gray-400 mb-4" />
            <p className="text-gray-600 mb-4">Aucun département trouvé</p>
            <button
              onClick={() => {
                resetForm()
                setEditingDepartment(null)
                setShowCreateModal(true)
              }}
              className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700"
            >
              Créer un département
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {departments.map((department) => (
              <div key={department.id} className="bg-white rounded-lg shadow-sm p-6">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex-1">
                    <h3 className="text-lg font-semibold text-gray-900 mb-1">{department.name}</h3>
                    {department.description && (
                      <p className="text-sm text-gray-600 mt-1">{department.description}</p>
                    )}
                  </div>
                  <div className="flex gap-2">
                    <button
                      onClick={() => openEditModal(department)}
                      className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg"
                      title="Modifier"
                    >
                      <FiEdit className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => handleDelete(department.id)}
                      className="p-2 text-red-600 hover:bg-red-50 rounded-lg"
                      title="Supprimer"
                    >
                      <FiTrash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
                <div className="flex gap-2">
                  {department.is_active ? (
                    <span className="px-2 py-1 bg-green-100 text-green-700 rounded text-xs flex items-center gap-1">
                      <FiCheck className="w-3 h-3" />
                      Actif
                    </span>
                  ) : (
                    <span className="px-2 py-1 bg-red-100 text-red-700 rounded text-xs flex items-center gap-1">
                      <FiX className="w-3 h-3" />
                      Inactif
                    </span>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Create/Edit Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-md w-full p-6">
            <h2 className="text-xl font-bold text-gray-900 mb-4">
              {editingDepartment ? 'Modifier le Département' : 'Nouveau Département'}
            </h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Nom *</label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <textarea
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
                  rows={3}
                />
              </div>
              <div>
                <label className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    checked={formData.is_active}
                    onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
                    className="rounded"
                  />
                  <span className="text-sm text-gray-700">Actif</span>
                </label>
              </div>
            </div>
            <div className="flex gap-2 mt-6">
              <button
                onClick={() => {
                  setShowCreateModal(false)
                  resetForm()
                  setEditingDepartment(null)
                }}
                className="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"
              >
                Annuler
              </button>
              <button
                onClick={editingDepartment ? handleUpdate : handleCreate}
                className="flex-1 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700"
              >
                {editingDepartment ? 'Mettre à jour' : 'Créer'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

