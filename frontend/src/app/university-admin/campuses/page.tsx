'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiMapPin, FiPlus, FiEdit, FiTrash2, FiLogOut, FiArrowLeft, FiCheck, FiX } from 'react-icons/fi'
import { universityService, Campus } from '@/services/universityService'
import toast from 'react-hot-toast'

export default function UniversityAdminCampusesPage() {
  const { user, loading, logout } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [campuses, setCampuses] = useState<Campus[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [showCreateModal, setShowCreateModal] = useState(false)
  const [editingCampus, setEditingCampus] = useState<Campus | null>(null)
  const [formData, setFormData] = useState({
    name: '',
    address: '',
    city: '',
    is_main: false,
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
      loadCampuses()
    }
  }, [user])

  const loadCampuses = async () => {
    setIsLoading(true)
    try {
      const response = await universityService.getCampuses()
      const campusesList = Array.isArray(response) ? response : response.results || []
      setCampuses(campusesList)
    } catch (error: any) {
      console.error('Error loading campuses:', error)
      toast.error('Erreur lors du chargement des campus')
    } finally {
      setIsLoading(false)
    }
  }

  const handleCreate = async () => {
    try {
      // Get university ID from user's managed_university
      const university = await universityService.getMyUniversity()
      await universityService.createCampus({
        ...formData,
        university: university.id
      })
      toast.success('Campus créé avec succès')
      setShowCreateModal(false)
      resetForm()
      loadCampuses()
    } catch (error: any) {
      console.error('Error creating campus:', error)
      toast.error(error.response?.data?.error || 'Erreur lors de la création du campus')
    }
  }

  const handleUpdate = async () => {
    if (!editingCampus) return
    
    try {
      await universityService.updateCampus(editingCampus.id, formData)
      toast.success('Campus mis à jour avec succès')
      setEditingCampus(null)
      resetForm()
      loadCampuses()
    } catch (error: any) {
      console.error('Error updating campus:', error)
      toast.error(error.response?.data?.error || 'Erreur lors de la mise à jour du campus')
    }
  }

  const handleDelete = async (campusId: string) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce campus ?')) return
    
    try {
      await universityService.deleteCampus(campusId)
      toast.success('Campus supprimé avec succès')
      loadCampuses()
    } catch (error: any) {
      console.error('Error deleting campus:', error)
      toast.error(error.response?.data?.error || 'Erreur lors de la suppression du campus')
    }
  }

  const resetForm = () => {
    setFormData({
      name: '',
      address: '',
      city: '',
      is_main: false,
      is_active: true
    })
  }

  const openEditModal = (campus: Campus) => {
    setEditingCampus(campus)
    setFormData({
      name: campus.name,
      address: campus.address || '',
      city: campus.city || '',
      is_main: campus.is_main,
      is_active: campus.is_active
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
                <h1 className="text-xl sm:text-2xl font-bold text-gray-900">Gestion des Campus</h1>
                <p className="text-sm text-gray-600 hidden sm:block">
                  Gérez les campus de votre université
                </p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <button
                onClick={() => {
                  resetForm()
                  setEditingCampus(null)
                  setShowCreateModal(true)
                }}
                className="flex items-center gap-2 px-3 sm:px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition text-sm sm:text-base"
              >
                <FiPlus className="w-4 h-4" />
                <span className="hidden sm:inline">Nouveau Campus</span>
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
            <p className="mt-4 text-gray-600">Chargement des campus...</p>
          </div>
        ) : campuses.length === 0 ? (
          <div className="bg-white rounded-lg shadow-sm p-8 text-center">
            <FiMapPin className="mx-auto h-12 w-12 text-gray-400 mb-4" />
            <p className="text-gray-600 mb-4">Aucun campus trouvé</p>
            <button
              onClick={() => {
                resetForm()
                setEditingCampus(null)
                setShowCreateModal(true)
              }}
              className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700"
            >
              Créer un campus
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {campuses.map((campus) => (
              <div key={campus.id} className="bg-white rounded-lg shadow-sm p-6">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex-1">
                    <h3 className="text-lg font-semibold text-gray-900 mb-1">{campus.name}</h3>
                    {campus.city && (
                      <p className="text-sm text-gray-600 flex items-center gap-1">
                        <FiMapPin className="w-4 h-4" />
                        {campus.city}
                      </p>
                    )}
                    {campus.address && (
                      <p className="text-xs text-gray-500 mt-1">{campus.address}</p>
                    )}
                  </div>
                  <div className="flex gap-2">
                    <button
                      onClick={() => openEditModal(campus)}
                      className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg"
                      title="Modifier"
                    >
                      <FiEdit className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => handleDelete(campus.id)}
                      className="p-2 text-red-600 hover:bg-red-50 rounded-lg"
                      title="Supprimer"
                    >
                      <FiTrash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
                <div className="flex gap-2">
                  {campus.is_main && (
                    <span className="px-2 py-1 bg-primary-100 text-primary-700 rounded text-xs">
                      Principal
                    </span>
                  )}
                  {campus.is_active ? (
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
              {editingCampus ? 'Modifier le Campus' : 'Nouveau Campus'}
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
                <label className="block text-sm font-medium text-gray-700 mb-1">Adresse</label>
                <input
                  type="text"
                  value={formData.address}
                  onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Ville</label>
                <input
                  type="text"
                  value={formData.city}
                  onChange={(e) => setFormData({ ...formData, city: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
                />
              </div>
              <div className="flex items-center gap-4">
                <label className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    checked={formData.is_main}
                    onChange={(e) => setFormData({ ...formData, is_main: e.target.checked })}
                    className="rounded"
                  />
                  <span className="text-sm text-gray-700">Campus principal</span>
                </label>
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
                  setEditingCampus(null)
                }}
                className="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"
              >
                Annuler
              </button>
              <button
                onClick={editingCampus ? handleUpdate : handleCreate}
                className="flex-1 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700"
              >
                {editingCampus ? 'Mettre à jour' : 'Créer'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

