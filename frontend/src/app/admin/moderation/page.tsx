'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiAlertCircle, FiCheck, FiX, FiEye, FiEyeOff, FiTrash2, FiFileText, FiClock } from 'react-icons/fi'
import { moderationService, Report } from '@/services/moderationService'
import toast from 'react-hot-toast'

export default function ModerationPage() {
  const { user, loading } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [reports, setReports] = useState<Report[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [statusFilter, setStatusFilter] = useState<string>('pending')
  const [contentTypeFilter, setContentTypeFilter] = useState<string>('')

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    } else if (mounted && user && user.role !== 'admin' && user.role !== 'class_leader') {
      router.push('/dashboard')
    }
  }, [mounted, user, loading, router])

  useEffect(() => {
    if (user && (user.role === 'admin' || user.role === 'class_leader')) {
      loadReports()
    }
  }, [user, statusFilter, contentTypeFilter])

  const loadReports = async () => {
    setIsLoading(true)
    try {
      const params: any = {}
      if (statusFilter) params.status = statusFilter
      if (contentTypeFilter) params.content_type = contentTypeFilter
      
      const response = await moderationService.getReports(params)
      setReports(Array.isArray(response) ? response : response.results || [])
    } catch (error: any) {
      console.error('Error loading reports:', error)
      toast.error('Erreur lors du chargement des signalements')
    } finally {
      setIsLoading(false)
    }
  }

  const handleResolve = async (reportId: string) => {
    const actionTaken = prompt('Action prise (optionnel):')
    const notes = prompt('Notes (optionnel):')
    
    try {
      await moderationService.resolveReport(reportId, {
        action_taken: actionTaken || '',
        notes: notes || ''
      })
      toast.success('Signalement résolu')
      loadReports()
    } catch (error: any) {
      console.error('Error resolving report:', error)
      toast.error('Erreur lors de la résolution du signalement')
    }
  }

  const handleDismiss = async (reportId: string) => {
    const reason = prompt('Raison du rejet (optionnel):')
    
    try {
      await moderationService.dismissReport(reportId, { reason: reason || '' })
      toast.success('Signalement rejeté')
      loadReports()
    } catch (error: any) {
      console.error('Error dismissing report:', error)
      toast.error('Erreur lors du rejet du signalement')
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

  if (!user || (user.role !== 'admin' && user.role !== 'class_leader')) {
    return null
  }

  const getReasonLabel = (reason: string) => {
    const labels: Record<string, string> = {
      spam: 'Spam',
      harassment: 'Harcèlement',
      inappropriate: 'Contenu inapproprié',
      fake: 'Faux',
      other: 'Autre'
    }
    return labels[reason] || reason
  }

  const getStatusColor = (status: string) => {
    const colors: Record<string, string> = {
      pending: 'bg-yellow-100 text-yellow-800',
      reviewed: 'bg-blue-100 text-blue-800',
      resolved: 'bg-green-100 text-green-800',
      dismissed: 'bg-gray-100 text-gray-800'
    }
    return colors[status] || 'bg-gray-100 text-gray-800'
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 sm:py-8">
        <div className="mb-6">
          <h1 className="text-2xl sm:text-3xl font-bold text-gray-900 mb-2">Modération</h1>
          <p className="text-gray-600">Gérer les signalements et modérer le contenu</p>
        </div>

        {/* Filters */}
        <div className="bg-white rounded-lg shadow-sm p-4 mb-6">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Statut</label>
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="">Tous</option>
                <option value="pending">En attente</option>
                <option value="reviewed">Examiné</option>
                <option value="resolved">Résolu</option>
                <option value="dismissed">Rejeté</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Type de contenu</label>
              <select
                value={contentTypeFilter}
                onChange={(e) => setContentTypeFilter(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="">Tous</option>
                <option value="post">Post</option>
                <option value="event">Événement</option>
                <option value="user">Utilisateur</option>
                <option value="group">Groupe</option>
              </select>
            </div>
          </div>
        </div>

        {/* Reports List */}
        <div className="space-y-4">
          {reports.length === 0 ? (
            <div className="bg-white rounded-lg shadow-sm p-8 text-center">
              <FiAlertCircle className="mx-auto h-12 w-12 text-gray-400 mb-4" />
              <p className="text-gray-600">Aucun signalement trouvé</p>
            </div>
          ) : (
            reports.map((report) => (
              <div key={report.id} className="bg-white rounded-lg shadow-sm p-4 sm:p-6">
                <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(report.status)}`}>
                        {report.status}
                      </span>
                      <span className="px-2 py-1 bg-blue-100 text-blue-800 rounded-full text-xs font-medium">
                        {report.content_type}
                      </span>
                      <span className="px-2 py-1 bg-purple-100 text-purple-800 rounded-full text-xs font-medium">
                        {getReasonLabel(report.reason)}
                      </span>
                    </div>
                    <p className="text-gray-900 font-medium mb-1">
                      Signalé par {report.reporter.username}
                    </p>
                    {report.description && (
                      <p className="text-gray-600 text-sm mb-2">{report.description}</p>
                    )}
                    <div className="flex items-center gap-4 text-sm text-gray-500">
                      <span className="flex items-center gap-1">
                        <FiClock className="h-4 w-4" />
                        {new Date(report.created_at).toLocaleDateString('fr-FR')}
                      </span>
                      {report.reviewed_by && (
                        <span>Examiné par {report.reviewed_by.username}</span>
                      )}
                    </div>
                  </div>
                  {report.status === 'pending' && (
                    <div className="flex gap-2">
                      <button
                        onClick={() => handleResolve(report.id)}
                        className="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 flex items-center gap-2"
                      >
                        <FiCheck className="h-4 w-4" />
                        Résoudre
                      </button>
                      <button
                        onClick={() => handleDismiss(report.id)}
                        className="px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700 flex items-center gap-2"
                      >
                        <FiX className="h-4 w-4" />
                        Rejeter
                      </button>
                    </div>
                  )}
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  )
}

