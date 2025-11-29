'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiCalendar, FiMapPin, FiClock, FiUsers, FiHeart, FiEdit2, FiTrash2, FiArrowLeft, FiLogOut, FiFilter } from 'react-icons/fi'
import { eventService, type Event } from '@/services/eventService'
import toast from 'react-hot-toast'
import Link from 'next/link'

type EventType = 'all' | 'organized' | 'participating' | 'favorites'

export default function MyEventsPage() {
  const { user, loading, logout } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [events, setEvents] = useState<Event[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [selectedType, setSelectedType] = useState<EventType>('all')
  const [leavingEventId, setLeavingEventId] = useState<string | null>(null)

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
  }, [user, selectedType])

  const loadEvents = async () => {
    if (!user) return
    
    setIsLoading(true)
    try {
      const data = await eventService.getMyEvents(selectedType)
      setEvents(Array.isArray(data) ? data : [])
    } catch (error: any) {
      console.error('Error loading events:', error)
      toast.error('Erreur lors du chargement de vos événements')
      setEvents([])
    } finally {
      setIsLoading(false)
    }
  }

  const handleLeaveEvent = async (eventId: string) => {
    if (!confirm('Êtes-vous sûr de vouloir annuler votre participation à cet événement ?')) {
      return
    }

    setLeavingEventId(eventId)
    try {
      await eventService.leaveEvent(eventId)
      toast.success('Participation annulée')
      await loadEvents()
    } catch (error: any) {
      console.error('Error leaving event:', error)
      const errorMessage = error.response?.data?.error || error.response?.data?.message || 'Erreur lors de l\'annulation'
      toast.error(errorMessage)
    } finally {
      setLeavingEventId(null)
    }
  }

  const handleLogout = () => {
    logout()
    router.push('/')
  }

  const handleGoBack = () => {
    router.push('/dashboard')
  }

  const getEventTypeLabel = (type: EventType) => {
    switch (type) {
      case 'organized':
        return 'Organisés'
      case 'participating':
        return 'Participations'
      case 'favorites':
        return 'Favoris'
      default:
        return 'Tous'
    }
  }

  const getEventTypeCount = async (type: EventType) => {
    // This would require separate API calls, for now we'll just show the current filter
    return null
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleDateString('fr-FR', {
      day: 'numeric',
      month: 'long',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  const isEventPast = (event: Event) => {
    if (!event.end_date) {
      return new Date(event.start_date) < new Date()
    }
    return new Date(event.end_date) < new Date()
  }

  const isEventUpcoming = (event: Event) => {
    return new Date(event.start_date) > new Date()
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

  // Separate events by status
  const upcomingEvents = events.filter(e => isEventUpcoming(e))
  const pastEvents = events.filter(e => isEventPast(e))
  const organizedEvents = events.filter(e => e.organizer.id === user.id)
  const participatingEvents = events.filter(e => e.is_participating && e.organizer.id !== user.id)
  const favoriteEvents = events.filter(e => e.is_liked) // Note: is_liked might not be the right field for favorites

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
      {/* Header */}
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
                <h1 className="text-xl sm:text-2xl font-bold text-gray-900">Mes Événements</h1>
                <p className="text-gray-600 text-xs sm:text-sm hidden sm:block">
                  Gérez vos événements et participations
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

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 sm:py-6">
        {/* Filter Tabs */}
        <div className="bg-white rounded-xl shadow-md p-4 mb-6">
          <div className="flex flex-wrap gap-2">
            {(['all', 'organized', 'participating', 'favorites'] as EventType[]).map((type) => (
              <button
                key={type}
                onClick={() => setSelectedType(type)}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition ${
                  selectedType === type
                    ? 'bg-primary-600 text-white'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                {getEventTypeLabel(type)}
              </button>
            ))}
          </div>
        </div>

        {/* Quick Stats */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-6">
          <div className="bg-white rounded-xl shadow-md p-4">
            <div className="flex items-center gap-2 mb-2">
              <FiCalendar className="w-5 h-5 text-blue-600" />
              <span className="text-sm font-medium text-gray-700">À venir</span>
            </div>
            <p className="text-2xl font-bold text-gray-900">{upcomingEvents.length}</p>
          </div>
          <div className="bg-white rounded-xl shadow-md p-4">
            <div className="flex items-center gap-2 mb-2">
              <FiUsers className="w-5 h-5 text-green-600" />
              <span className="text-sm font-medium text-gray-700">Participations</span>
            </div>
            <p className="text-2xl font-bold text-gray-900">{participatingEvents.length}</p>
          </div>
          <div className="bg-white rounded-xl shadow-md p-4">
            <div className="flex items-center gap-2 mb-2">
              <FiEdit2 className="w-5 h-5 text-purple-600" />
              <span className="text-sm font-medium text-gray-700">Organisés</span>
            </div>
            <p className="text-2xl font-bold text-gray-900">{organizedEvents.length}</p>
          </div>
          <div className="bg-white rounded-xl shadow-md p-4">
            <div className="flex items-center gap-2 mb-2">
              <FiHeart className="w-5 h-5 text-red-600" />
              <span className="text-sm font-medium text-gray-700">Favoris</span>
            </div>
            <p className="text-2xl font-bold text-gray-900">{favoriteEvents.length}</p>
          </div>
        </div>

        {/* Events List */}
        {isLoading ? (
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Chargement de vos événements...</p>
          </div>
        ) : events.length === 0 ? (
          <div className="bg-white rounded-2xl shadow-lg p-8 sm:p-12 text-center">
            <FiCalendar className="w-12 h-12 sm:w-16 sm:h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg sm:text-xl font-semibold text-gray-900 mb-2">
              Aucun événement {selectedType !== 'all' ? getEventTypeLabel(selectedType).toLowerCase() : ''}
            </h3>
            <p className="text-gray-600 text-sm sm:text-base mb-6">
              {selectedType === 'organized'
                ? 'Vous n\'avez pas encore organisé d\'événements.'
                : selectedType === 'participating'
                ? 'Vous ne participez à aucun événement pour le moment.'
                : selectedType === 'favorites'
                ? 'Vous n\'avez pas encore d\'événements favoris.'
                : 'Vous n\'avez pas encore d\'événements.'}
            </p>
            {selectedType === 'all' && (
              <Link
                href="/events/create"
                className="inline-flex items-center gap-2 px-6 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition"
              >
                <FiCalendar className="w-5 h-5" />
                <span>Créer un événement</span>
              </Link>
            )}
          </div>
        ) : (
          <div className="space-y-6">
            {/* Upcoming Events */}
            {upcomingEvents.length > 0 && (
              <div>
                <h2 className="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
                  <FiClock className="w-5 h-5 text-primary-600" />
                  Événements à venir ({upcomingEvents.length})
                </h2>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {upcomingEvents.map((event) => (
                    <EventCard
                      key={event.id}
                      event={event}
                      user={user}
                      onLeave={handleLeaveEvent}
                      leavingEventId={leavingEventId}
                      formatDate={formatDate}
                    />
                  ))}
                </div>
              </div>
            )}

            {/* Past Events */}
            {pastEvents.length > 0 && (
              <div>
                <h2 className="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
                  <FiCalendar className="w-5 h-5 text-gray-600" />
                  Événements passés ({pastEvents.length})
                </h2>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {pastEvents.map((event) => (
                    <EventCard
                      key={event.id}
                      event={event}
                      user={user}
                      onLeave={handleLeaveEvent}
                      leavingEventId={leavingEventId}
                      formatDate={formatDate}
                      isPast={true}
                    />
                  ))}
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  )
}

interface EventCardProps {
  event: Event
  user: any
  onLeave: (eventId: string) => void
  leavingEventId: string | null
  formatDate: (date: string) => string
  isPast?: boolean
}

function EventCard({ event, user, onLeave, leavingEventId, formatDate, isPast = false }: EventCardProps) {
  const isOrganizer = event.organizer.id === user.id
  const isParticipating = event.is_participating

  const getImageUrl = () => {
    if (event.image) {
      if (typeof event.image === 'string') {
        return event.image
      }
      if (event.image.url) {
        return event.image.url
      }
    }
    if (event.image_url) {
      return event.image_url
    }
    return null
  }

  return (
    <div className={`bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition ${isPast ? 'opacity-75' : ''}`}>
      <Link href={`/events/${event.id}`}>
        {getImageUrl() && (
          <div className="h-48 bg-gray-200 overflow-hidden">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={getImageUrl()}
              alt={event.title}
              className="w-full h-full object-cover hover:scale-105 transition-transform duration-300"
            />
          </div>
        )}
        <div className="p-4 sm:p-6">
          <div className="flex items-start justify-between mb-2">
            <h3 className="text-lg font-bold text-gray-900 line-clamp-2 flex-1">{event.title}</h3>
            {isOrganizer && (
              <span className="ml-2 px-2 py-1 bg-purple-100 text-purple-700 text-xs font-medium rounded-full flex-shrink-0">
                Organisateur
              </span>
            )}
          </div>
          
          <div className="space-y-2 mb-4">
            <div className="flex items-center gap-2 text-sm text-gray-600">
              <FiClock className="w-4 h-4 flex-shrink-0" />
              <span>{formatDate(event.start_date)}</span>
            </div>
            <div className="flex items-center gap-2 text-sm text-gray-600">
              <FiMapPin className="w-4 h-4 flex-shrink-0" />
              <span className="truncate">{event.location}</span>
            </div>
            <div className="flex items-center gap-2 text-sm text-gray-600">
              <FiUsers className="w-4 h-4 flex-shrink-0" />
              <span>{event.participants_count || 0} participant{event.participants_count !== 1 ? 's' : ''}</span>
            </div>
          </div>

          {event.category && (
            <span className="inline-block px-3 py-1 bg-primary-50 text-primary-700 text-xs font-medium rounded-full mb-4">
              {event.category.name}
            </span>
          )}
        </div>
      </Link>

      {/* Actions */}
      <div className="px-4 sm:px-6 pb-4 sm:pb-6 flex gap-2">
        {isParticipating && !isOrganizer && (
          <button
            onClick={(e) => {
              e.preventDefault()
              e.stopPropagation()
              onLeave(event.id)
            }}
            disabled={leavingEventId === event.id}
            className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-red-50 text-red-700 rounded-lg hover:bg-red-100 transition disabled:opacity-50"
          >
            <FiUsers className="w-4 h-4" />
            <span>Annuler participation</span>
          </button>
        )}
        {isOrganizer && (
          <Link
            href={`/events/${event.id}/edit`}
            className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-primary-50 text-primary-700 rounded-lg hover:bg-primary-100 transition"
            onClick={(e) => e.stopPropagation()}
          >
            <FiEdit2 className="w-4 h-4" />
            <span>Modifier</span>
          </Link>
        )}
      </div>
    </div>
  )
}

