'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiSettings, FiSave, FiLogOut, FiArrowLeft } from 'react-icons/fi'
import { universityService, UniversitySettings } from '@/services/universityService'
import toast from 'react-hot-toast'

export default function UniversityAdminSettingsPage() {
  const { user, loading, logout } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [university, setUniversity] = useState<any>(null)
  const [settings, setSettings] = useState<UniversitySettings | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)
  const [formData, setFormData] = useState({
    allow_student_registration: true,
    require_email_verification: true,
    require_phone_verification: true,
    auto_verify_students: false,
    max_groups_per_student: 10,
    max_events_per_student: 20
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
      loadData()
    }
  }, [user])

  const loadData = async () => {
    setIsLoading(true)
    try {
      const uni = await universityService.getMyUniversity()
      setUniversity(uni)
      
      const settingsData = await universityService.getUniversitySettings(uni.id)
      setSettings(settingsData)
      setFormData({
        allow_student_registration: settingsData.allow_student_registration ?? true,
        require_email_verification: settingsData.require_email_verification ?? true,
        require_phone_verification: settingsData.require_phone_verification ?? true,
        auto_verify_students: settingsData.auto_verify_students ?? false,
        max_groups_per_student: settingsData.max_groups_per_student ?? 10,
        max_events_per_student: settingsData.max_events_per_student ?? 20
      })
    } catch (error: any) {
      console.error('Error loading settings:', error)
      toast.error('Erreur lors du chargement des paramètres')
    } finally {
      setIsLoading(false)
    }
  }

  const handleSave = async () => {
    if (!university) return
    
    setIsSaving(true)
    try {
      await universityService.updateUniversitySettings(university.id, formData)
      toast.success('Paramètres mis à jour avec succès')
      loadData()
    } catch (error: any) {
      console.error('Error saving settings:', error)
      toast.error(error.response?.data?.error || 'Erreur lors de la sauvegarde des paramètres')
    } finally {
      setIsSaving(false)
    }
  }

  const handleLogout = () => {
    logout()
    router.push('/')
  }

  const handleGoBack = () => {
    router.push('/university-admin/dashboard')
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
                <h1 className="text-xl sm:text-2xl font-bold text-gray-900">Paramètres de l&apos;Université</h1>
                <p className="text-sm text-gray-600 hidden sm:block">
                  {university?.name && `Configurez les paramètres de ${university.name}`}
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

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-6 sm:py-8">
        {university && (
          <div className="bg-white rounded-lg shadow-sm p-6 mb-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-2">{university.name}</h2>
            {university.short_name && (
              <p className="text-sm text-gray-600">{university.short_name}</p>
            )}
          </div>
        )}

        <div className="bg-white rounded-lg shadow-sm p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-6 flex items-center gap-2">
            <FiSettings className="w-5 h-5" />
            Configuration
          </h2>

          <div className="space-y-6">
            <div>
              <h3 className="text-md font-medium text-gray-900 mb-4">Inscription et Vérification</h3>
              <div className="space-y-4">
                <label className="flex items-center gap-3">
                  <input
                    type="checkbox"
                    checked={formData.allow_student_registration}
                    onChange={(e) => setFormData({ ...formData, allow_student_registration: e.target.checked })}
                    className="rounded"
                  />
                  <div>
                    <span className="text-sm font-medium text-gray-900">Autoriser l&apos;inscription des étudiants</span>
                    <p className="text-xs text-gray-500">Permet aux étudiants de s&apos;inscrire sur la plateforme</p>
                  </div>
                </label>

                <label className="flex items-center gap-3">
                  <input
                    type="checkbox"
                    checked={formData.require_email_verification}
                    onChange={(e) => setFormData({ ...formData, require_email_verification: e.target.checked })}
                    className="rounded"
                  />
                  <div>
                    <span className="text-sm font-medium text-gray-900">Vérification email requise</span>
                    <p className="text-xs text-gray-500">Les étudiants doivent vérifier leur email pour activer leur compte</p>
                  </div>
                </label>

                <label className="flex items-center gap-3">
                  <input
                    type="checkbox"
                    checked={formData.require_phone_verification}
                    onChange={(e) => setFormData({ ...formData, require_phone_verification: e.target.checked })}
                    className="rounded"
                  />
                  <div>
                    <span className="text-sm font-medium text-gray-900">Vérification téléphone requise</span>
                    <p className="text-xs text-gray-500">Les étudiants doivent vérifier leur numéro de téléphone</p>
                  </div>
                </label>

                <label className="flex items-center gap-3">
                  <input
                    type="checkbox"
                    checked={formData.auto_verify_students}
                    onChange={(e) => setFormData({ ...formData, auto_verify_students: e.target.checked })}
                    className="rounded"
                  />
                  <div>
                    <span className="text-sm font-medium text-gray-900">Vérification automatique</span>
                    <p className="text-xs text-gray-500">Les étudiants sont automatiquement vérifiés à l&apos;inscription</p>
                  </div>
                </label>
              </div>
            </div>

            <div className="border-t border-gray-200 pt-6">
              <h3 className="text-md font-medium text-gray-900 mb-4">Limites</h3>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Nombre maximum de groupes par étudiant
                  </label>
                  <input
                    type="number"
                    min="1"
                    max="50"
                    value={formData.max_groups_per_student}
                    onChange={(e) => setFormData({ ...formData, max_groups_per_student: parseInt(e.target.value) || 10 })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Nombre maximum d&apos;événements par étudiant
                  </label>
                  <input
                    type="number"
                    min="1"
                    max="100"
                    value={formData.max_events_per_student}
                    onChange={(e) => setFormData({ ...formData, max_events_per_student: parseInt(e.target.value) || 20 })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
                  />
                </div>
              </div>
            </div>

            <div className="flex justify-end pt-4 border-t border-gray-200">
              <button
                onClick={handleSave}
                disabled={isSaving}
                className="flex items-center gap-2 px-6 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <FiSave className="w-4 h-4" />
                {isSaving ? 'Enregistrement...' : 'Enregistrer'}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

