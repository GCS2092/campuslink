'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiCalendar, FiMapPin, FiClock, FiUsers, FiSearch, FiTrash2, FiEye, FiEyeOff, FiX, FiCheck, FiArrowRight } from 'react-icons/fi'
import { eventService, type Event } from '@/services/eventService'
import toast from 'react-hot-toast'
import Link from 'next/link'
import AdvancedEventFilters, { type FilterOptions } from '@/components/AdvancedEventFilters'
import { getUniversityName } from '@/utils/typeHelpers'

export default function EventsPage() {
  const { user, loading } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [events, setEvents] = useState<Event[]>([])
  const [isLoadingEvents, setIsLoadingEvents] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState<string>('')
  const [joiningEventId, setJoiningEventId] = useState<string | null>(null)
  const [advancedFilters, setAdvancedFilters] = useState<FilterOptions>({})
  const [categories, setCategories] = useState<Array<{ id: string; name: string }>>([])
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
      loadCategories()
      loadEvents()
    } else if (!loading) {
      // Si l'utilisateur n'est pas connecté et le chargement est terminé, arrêter le chargement des événements
      setIsLoadingEvents(false)
    }
  }, [user, searchTerm, statusFilter, advancedFilters, loading])

  const loadCategories = async () => {
    try {
      const data = await eventService.getCategories()
      setCategories(Array.isArray(data) ? data : data.results || [])
    } catch (error: any) {
      console.error('Error loading categories:', error)
    }
  }

  const loadEvents = async () => {
    if (!user) {
      setIsLoadingEvents(false)
      return
    }
    setIsLoadingEvents(true)
    try {
      const params: any = {}
      if (searchTerm) {
        params.search = searchTerm
      }
      // Admins can filter by status
      const userIsAdmin = user?.role === 'admin' || user?.role === 'class_leader'
      if (userIsAdmin && statusFilter) {
        params.status = statusFilter
      }
      // Advanced filters
      if (advancedFilters.category) {
        params.category = advancedFilters.category
      }
      if (advancedFilters.is_free !== undefined && advancedFilters.is_free !== null) {
        params.is_free = advancedFilters.is_free
      }
      if (advancedFilters.price_min !== undefined) {
        params.price_min = advancedFilters.price_min
      }
      if (advancedFilters.price_max !== undefined) {
        params.price_max = advancedFilters.price_max
      }
      if (advancedFilters.date_from) {
        params.date_from = advancedFilters.date_from
      }
      if (advancedFilters.date_to) {
        params.date_to = advancedFilters.date_to
      }
      if (advancedFilters.university) {
        params.university = advancedFilters.university
      }
      const response = await eventService.getEvents(params)
      const eventsList = response.results || response.data || response || []
      // Filter out events without valid IDs
      const validEvents = Array.isArray(eventsList) 
        ? eventsList.filter((e: Event) => e && e.id && typeof e.id === 'string')
        : []
      setEvents(validEvents)
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

  const handleJoinEvent = async (eventId: string) => {
    if (!eventId) {
      toast.error('ID d\'événement invalide')
      return
    }
    
    setJoiningEventId(eventId)
    try {
      await eventService.joinEvent(eventId)
      toast.success('Vous avez rejoint l\'événement avec succès')
      await loadEvents()
    } catch (error: any) {
      console.error('Error joining event:', error)
      const errorMessage = error?.response?.data?.error || error?.response?.data?.message || 'Erreur lors de la jointure'
      toast.error(typeof errorMessage === 'string' ? errorMessage : 'Erreur lors de la jointure')
    } finally {
      setJoiningEventId(null)
    }
  }

  const handleLeaveEvent = async (eventId: string) => {
    if (!eventId) {
      toast.error('ID d\'événement invalide')
      return
    }
    
    if (!confirm('Êtes-vous sûr de vouloir quitter cet événement ?')) {
      return
    }
    
    setJoiningEventId(eventId)
    try {
      await eventService.leaveEvent(eventId)
      toast.success('Vous avez quitté l\'événement')
      await loadEvents()
    } catch (error: any) {
      console.error('Error leaving event:', error)
      const errorMessage = error?.response?.data?.error || error?.response?.data?.message || 'Erreur lors de la sortie'
      toast.error(typeof errorMessage === 'string' ? errorMessage : 'Erreur lors de la sortie')
    } finally {
      setJoiningEventId(null)
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
        {/* Header - Improved Design */}
        <div className="relative bg-gradient-to-br from-primary-500 via-primary-600 to-secondary-600 rounded-2xl shadow-xl p-6 sm:p-8 mb-6 sm:mb-8 overflow-hidden">
          {/* Decorative Background Elements */}
          <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16"></div>
          <div className="absolute bottom-0 left-0 w-24 h-24 bg-white/10 rounded-full -ml-12 -mb-12"></div>
          
          <div className="relative z-10 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div className="flex-1">
              <div className="flex items-center gap-3 mb-2">
                <div className="w-12 h-12 bg-white/20 backdrop-blur-sm rounded-xl flex items-center justify-center shadow-lg">
                  <FiCalendar className="w-6 h-6 text-white" />
                </div>
                <h1 className="text-2xl sm:text-3xl font-bold text-white drop-shadow-lg">
                  {isAdmin ? 'Gestion des Événements' : 'Événements'}
                </h1>
              </div>
              <p className="text-white/90 text-sm sm:text-base">
                {isAdmin 
                  ? 'Surveillez et modérez les événements créés par les étudiants' 
                  : 'Découvrez les événements près de chez vous'}
              </p>
            </div>
            {!isAdmin && user?.is_verified && (
              <Link
                href="/events/create"
                className="px-5 py-3 bg-white text-primary-600 rounded-xl hover:bg-white/90 transition-all duration-300 font-semibold flex items-center gap-2 shadow-lg hover:shadow-xl hover:-translate-y-1"
              >
                <FiCalendar className="w-5 h-5" />
                <span className="hidden sm:inline">Créer un événement</span>
                <span className="sm:hidden">Créer</span>
              </Link>
            )}
          </div>
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

        {/* Search Bar and Advanced Filters (Non-admin) - Improved Responsive Design */}
        {!isAdmin && (
          <div className="mb-6 space-y-3 sm:space-y-4">
            {/* Search Bar - Full Width on Mobile */}
            <div className="relative w-full">
              <FiSearch className="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
              <input
                type="text"
                placeholder="Rechercher un événement..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-12 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-transparent shadow-sm"
              />
            </div>
            
            {/* Filters Row - Responsive Layout */}
            <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-3 sm:gap-4">
              <div className="flex-1 sm:flex-initial">
                <AdvancedEventFilters
                  categories={categories}
                  currentFilters={advancedFilters}
                  onFiltersChange={setAdvancedFilters}
                />
              </div>
              <Link
                href="/events/map"
                className="px-4 py-3 bg-white border border-gray-300 rounded-xl hover:bg-gray-50 hover:border-primary-300 transition-all duration-200 flex items-center justify-center gap-2 shadow-sm hover:shadow-md"
              >
                <FiMapPin className="w-5 h-5 text-primary-600" />
                <span className="font-medium text-gray-700">Carte</span>
              </Link>
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
          <div className="bg-white rounded-2xl shadow-xl p-12 text-center border border-gray-100">
            <FiCalendar className="w-16 h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Aucun événement</h3>
            <p className="text-gray-600">Il n&apos;y a pas encore d&apos;événements disponibles.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5 sm:gap-6">
            {events.map((event) => (
              <div key={event.id} className="group bg-white rounded-xl shadow-md overflow-hidden hover:shadow-xl transition-all duration-300 border border-gray-100 hover:border-primary-300 hover:-translate-y-1">
                <div className="p-5 sm:p-6">
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
                          <span>• {getUniversityName(event.organizer.profile.university)}</span>
                        )}
                      </div>
                    )}
                  </div>
                  
                  {/* Action Buttons */}
                  <div className="flex gap-2 mt-4">
                    {isAdmin ? (
                      <>
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
                      </>
                    ) : (
                      <>
                        {event.status === 'published' && (
                          <>
                            <Link
                              href={`/events/${event.id}`}
                              className="flex-1 flex items-center justify-center gap-2 bg-gray-100 text-gray-700 py-2 rounded-lg hover:bg-gray-200 transition text-sm"
                            >
                              <FiArrowRight className="w-4 h-4" />
                              Détails
                            </Link>
                            {event.is_participating ? (
                              <button
                                onClick={() => handleLeaveEvent(event.id)}
                                disabled={joiningEventId === event.id}
                                className="flex-1 flex items-center justify-center gap-2 bg-red-600 text-white py-2 rounded-lg hover:bg-red-700 transition text-sm disabled:opacity-50 disabled:cursor-not-allowed"
                              >
                                {joiningEventId === event.id ? 'Traitement...' : 'Quitter'}
                              </button>
                            ) : (
                              <button
                                onClick={() => handleJoinEvent(event.id)}
                                disabled={joiningEventId === event.id || !!(event.capacity && (event.participants_count || 0) >= event.capacity)}
                                className="flex-1 flex items-center justify-center gap-2 bg-primary-600 text-white py-2 rounded-lg hover:bg-primary-700 transition text-sm disabled:opacity-50 disabled:cursor-not-allowed"
                              >
                                {joiningEventId === event.id ? 'Traitement...' : (event.capacity && (event.participants_count || 0) >= event.capacity) ? 'Complet' : 'Rejoindre'}
                              </button>
                            )}
                          </>
                        )}
                      </>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

