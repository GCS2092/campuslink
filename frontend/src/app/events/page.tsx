'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiCalendar, FiMapPin, FiClock, FiUsers, FiSearch, FiTrash2, FiEye, FiEyeOff, FiX, FiCheck } from 'react-icons/fi'
import { eventService, type Event } from '@/services/eventService'
import toast from 'react-hot-toast'

export default function EventsPage() {
  const { user, loading } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [events, setEvents] = useState<Event[]>([])
  const [isLoadingEvents, setIsLoadingEvents] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState<string>('')
  const isAdmin = user?.role === 'admin' || user?.role === 'class_leader'

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    }
  }, [mounted, user, loading, router])

  useEffect(() => {
    if (user) {
      loadEvents()
    }
  }, [user, searchTerm, statusFilter])

  const loadEvents = async () => {
    setIsLoadingEvents(true)
    try {
      const params: any = {}
      if (searchTerm) {
        params.search = searchTerm
      }
      // Admins can filter by status
      if (isAdmin && statusFilter) {
        params.status = statusFilter
      }
      const response = await eventService.getEvents(params)
      const eventsList = response.results || response.data || response || []
      setEvents(Array.isArray(eventsList) ? eventsList : [])
    } catch (error: any) {
      console.error('Error loading events:', error)
      // Handle error object from custom exception handler
      let errorMessage = 'Erreur lors du chargement des événements'
      if (error?.response?.data) {
        const errorData = error.response.data
        if (errorData.error && typeof errorData.error === 'object') {
          errorMessage = errorData.error.message || errorData.error.details?.message || errorMessage
        } else if (typeof errorData === 'string') {
          errorMessage = errorData
        } else if (errorData.message) {
          errorMessage = errorData.message
        } else if (errorData.error && typeof errorData.error === 'string') {
          errorMessage = errorData.error
        }
      } else if (error?.message) {
        errorMessage = error.message
      }
      toast.error(typeof errorMessage === 'string' ? errorMessage : 'Erreur lors du chargement des événements')
      setEvents([])
    } finally {
      setIsLoadingEvents(false)
    }
  }

  const handleModerate = async (eventId: string, action: 'delete' | 'publish' | 'cancel' | 'draft') => {
    if (!confirm(`Êtes-vous sûr de vouloir ${action === 'delete' ? 'supprimer' : action === 'publish' ? 'publier' : action === 'cancel' ? 'annuler' : 'mettre en brouillon'} cet événement ?`)) {
      return
    }

    try {
      await eventService.moderateEvent(eventId, action)
      toast.success(`Événement ${action === 'delete' ? 'supprimé' : 'modifié'} avec succès`)
      await loadEvents()
    } catch (error: any) {
      console.error('Error moderating event:', error)
      // Handle error object from custom exception handler
      let errorMessage = 'Erreur lors de la modération de l\'événement'
      if (error?.response?.data) {
        const errorData = error.response.data
        if (errorData.error && typeof errorData.error === 'object') {
          errorMessage = errorData.error.message || errorData.error.details?.message || errorMessage
        } else if (typeof errorData === 'string') {
          errorMessage = errorData
        } else if (errorData.message) {
          errorMessage = errorData.message
        } else if (errorData.error && typeof errorData.error === 'string') {
          errorMessage = errorData.error
        }
      } else if (error?.message) {
        errorMessage = error.message
      }
      toast.error(typeof errorMessage === 'string' ? errorMessage : 'Erreur lors de la modération de l\'événement')
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

  if (!user) {
    return null
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            {isAdmin ? 'Gestion des Événements' : 'Événements'}
          </h1>
          <p className="text-gray-600">
            {isAdmin 
              ? 'Surveillez et modérez les événements créés par les étudiants' 
              : 'Découvrez les événements près de chez vous'}
          </p>
        </div>

        {/* Filters (Admin only) */}
        {isAdmin && (
          <div className="mb-6 flex flex-wrap gap-4">
            <div className="relative flex-1 min-w-[200px]">
              <FiSearch className="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
              <input
                type="text"
                placeholder="Rechercher un événement..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-12 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              />
            </div>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            >
              <option value="">Tous les statuts</option>
              <option value="published">Publié</option>
              <option value="draft">Brouillon</option>
              <option value="cancelled">Annulé</option>
              <option value="completed">Terminé</option>
            </select>
          </div>
        )}

        {/* Search Bar (Non-admin) */}
        {!isAdmin && (
          <div className="mb-6">
            <div className="relative">
              <FiSearch className="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
              <input
                type="text"
                placeholder="Rechercher un événement..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-12 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              />
            </div>
          </div>
        )}

        {/* Events List */}
        {isLoadingEvents ? (
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Chargement des événements...</p>
          </div>
        ) : events.length === 0 ? (
          <div className="bg-white rounded-2xl shadow-lg p-12 text-center">
            <FiCalendar className="w-16 h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Aucun événement</h3>
            <p className="text-gray-600">Il n&apos;y a pas encore d&apos;événements disponibles.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {events.map((event) => (
              <div key={event.id} className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition">
                <div className="p-6">
                  <div className="flex items-start justify-between mb-2">
                    <h3 className="text-xl font-semibold text-gray-900 flex-1">{event.title}</h3>
                    {isAdmin && (
                      <span className={`ml-2 px-2 py-1 rounded text-xs font-medium ${
                        event.status === 'published' ? 'bg-green-100 text-green-700' :
                        event.status === 'draft' ? 'bg-yellow-100 text-yellow-700' :
                        event.status === 'cancelled' ? 'bg-red-100 text-red-700' :
                        'bg-gray-100 text-gray-700'
                      }`}>
                        {event.status === 'published' ? 'Publié' :
                         event.status === 'draft' ? 'Brouillon' :
                         event.status === 'cancelled' ? 'Annulé' :
                         'Terminé'}
                      </span>
                    )}
                  </div>
                  <p className="text-gray-600 mb-4 line-clamp-2">{event.description}</p>
                  <div className="space-y-2 text-sm text-gray-600 mb-4">
                    <div className="flex items-center gap-2">
                      <FiCalendar className="w-4 h-4" />
                      <span>{new Date(event.start_date).toLocaleDateString('fr-FR', {
                        day: 'numeric',
                        month: 'long',
                        year: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit'
                      })}</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <FiMapPin className="w-4 h-4" />
                      <span>{event.location}</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <FiUsers className="w-4 h-4" />
                      <span>{event.participants_count} participants</span>
                    </div>
                    {event.organizer && (
                      <div className="flex items-center gap-2 text-xs text-gray-500">
                        <span>Par {event.organizer.username}</span>
                        {event.organizer.profile?.university && (
                          <span>• {event.organizer.profile.university}</span>
                        )}
                      </div>
                    )}
                  </div>
                  
                  {isAdmin ? (
                    <div className="flex gap-2">
                      {event.status === 'draft' && (
                        <button
                          onClick={() => handleModerate(event.id, 'publish')}
                          className="flex-1 flex items-center justify-center gap-2 bg-green-600 text-white py-2 rounded-lg hover:bg-green-700 transition text-sm"
                        >
                          <FiCheck className="w-4 h-4" />
                          Publier
                        </button>
                      )}
                      {event.status === 'published' && (
                        <button
                          onClick={() => handleModerate(event.id, 'cancel')}
                          className="flex-1 flex items-center justify-center gap-2 bg-yellow-600 text-white py-2 rounded-lg hover:bg-yellow-700 transition text-sm"
                        >
                          <FiX className="w-4 h-4" />
                          Annuler
                        </button>
                      )}
                      <button
                        onClick={() => handleModerate(event.id, 'delete')}
                        className="flex items-center justify-center gap-2 bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition text-sm"
                      >
                        <FiTrash2 className="w-4 h-4" />
                      </button>
                    </div>
                  ) : (
                    <button className="mt-4 w-full bg-primary-600 text-white py-2 rounded-lg hover:bg-primary-700 transition">
                      Voir détails
                    </button>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

