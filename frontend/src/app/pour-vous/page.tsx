'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiCalendar, FiMapPin, FiClock, FiUsers, FiArrowLeft, FiLogOut, FiZap } from 'react-icons/fi'
import { eventService, type Event } from '@/services/eventService'
import { getUniversityName } from '@/utils/typeHelpers'
import Link from 'next/link'
import toast from 'react-hot-toast'
import CampusLinkHeader from '@/components/CampusLinkHeader'

export default function PourVousPage() {
  const { user, loading, logout } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [recommendedEvents, setRecommendedEvents] = useState<Event[]>([])
  const [isLoadingRecommended, setIsLoadingRecommended] = useState(false)
  const [eventFilter, setEventFilter] = useState<'all' | 'today' | 'week' | 'month'>('all')

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    } else if (mounted && user) {
      if (!user.is_active || !user.is_verified) {
        router.push('/pending-approval')
        return
      }
      loadRecommendedEvents()
    }
  }, [mounted, user, loading, router])

  const loadRecommendedEvents = async () => {
    if (!user) return
    setIsLoadingRecommended(true)
    try {
      const events = await eventService.getRecommendedEvents(20) // Plus d'événements sur la page dédiée
      setRecommendedEvents(Array.isArray(events) ? events : [])
    } catch (error: any) {
      console.error('Error loading recommended events:', error)
      toast.error('Erreur lors du chargement des recommandations')
    } finally {
      setIsLoadingRecommended(false)
    }
  }

  const handleLogout = () => {
    logout()
    router.push('/')
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

  const filteredEvents = recommendedEvents.filter((event) => {
    if (eventFilter === 'all') return true
    const eventDate = new Date(event.start_date)
    const now = new Date()
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    const eventDay = new Date(eventDate.getFullYear(), eventDate.getMonth(), eventDate.getDate())
    
    if (eventFilter === 'today') {
      return eventDay.getTime() === today.getTime()
    }
    if (eventFilter === 'week') {
      const weekFromNow = new Date(today)
      weekFromNow.setDate(weekFromNow.getDate() + 7)
      return eventDate >= today && eventDate <= weekFromNow
    }
    if (eventFilter === 'month') {
      const monthFromNow = new Date(today)
      monthFromNow.setMonth(monthFromNow.getMonth() + 1)
      return eventDate >= today && eventDate <= monthFromNow
    }
    return true
  })

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
      {/* Header */}
      <CampusLinkHeader
        title="Pour vous"
        icon={<FiZap className="w-6 h-6 sm:w-7 sm:h-7 text-white" />}
        showBackButton
        onBack={() => router.push('/dashboard')}
      />

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 sm:py-6">
        {/* Description */}
        <div className="bg-white rounded-xl shadow-md p-4 sm:p-5 mb-6 border border-gray-100">
          <div className="flex items-start gap-3">
            <div className="w-10 h-10 bg-gradient-to-br from-primary-500 to-secondary-500 rounded-xl flex items-center justify-center shadow-lg flex-shrink-0">
              <FiZap className="w-5 h-5 text-white" />
            </div>
            <div className="flex-1">
              <h2 className="text-base sm:text-lg font-bold text-gray-900 mb-1">Événements recommandés</h2>
              <p className="text-xs sm:text-sm text-gray-600">
                Découvrez les événements qui correspondent à vos intérêts et à votre université
              </p>
            </div>
          </div>
        </div>

        {/* Filters */}
        <div className="bg-white rounded-xl shadow-md p-4 mb-6 border border-gray-100">
          <div className="flex flex-wrap gap-2">
            <button
              onClick={() => setEventFilter('all')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition ${
                eventFilter === 'all'
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Tous
            </button>
            <button
              onClick={() => setEventFilter('today')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition ${
                eventFilter === 'today'
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Aujourd'hui
            </button>
            <button
              onClick={() => setEventFilter('week')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition ${
                eventFilter === 'week'
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Cette semaine
            </button>
            <button
              onClick={() => setEventFilter('month')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition ${
                eventFilter === 'month'
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Ce mois
            </button>
          </div>
        </div>

        {/* Events List */}
        {isLoadingRecommended ? (
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Chargement des recommandations...</p>
          </div>
        ) : filteredEvents.length === 0 ? (
          <div className="bg-white rounded-xl shadow-md p-12 text-center">
            <FiCalendar className="w-16 h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Aucun événement recommandé</h3>
            <p className="text-gray-600">
              {eventFilter === 'all'
                ? 'Nous n\'avons pas encore d\'événements à vous recommander.'
                : `Aucun événement ${eventFilter === 'today' ? "aujourd'hui" : eventFilter === 'week' ? 'cette semaine' : 'ce mois'}.`}
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
            {filteredEvents.map((event) => (
              <Link
                key={event.id}
                href={`/events/${event.id}`}
                className="group bg-white rounded-xl shadow-md overflow-hidden hover:shadow-xl transition-all duration-300 border border-gray-200 hover:border-primary-300 hover:-translate-y-1"
              >
                {/* Event Image */}
                {(event.image_url || event.image) && (
                  <div className="relative h-48 sm:h-56 overflow-hidden">
                    <img
                      src={
                        event.image_url || 
                        (typeof event.image === 'string' 
                          ? (event.image.startsWith('http') ? event.image : `${process.env.NEXT_PUBLIC_API_URL?.replace('/api', '')}${event.image}`)
                          : (event.image && typeof event.image === 'object' && 'url' in event.image ? event.image.url : ''))
                      }
                      alt={event.title}
                      className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700"
                    />
                  </div>
                )}

                {/* Event Content */}
                <div className="p-4 sm:p-5">
                  <h3 className="text-base sm:text-lg font-bold text-gray-900 mb-2 line-clamp-2 group-hover:text-primary-600 transition-colors">
                    {event.title}
                  </h3>
                  
                  {event.description && (
                    <p className="text-xs sm:text-sm text-gray-600 mb-3 line-clamp-2">
                      {event.description}
                    </p>
                  )}

                  {/* Event Meta */}
                  <div className="space-y-2">
                    {event.location && (
                      <div className="flex items-center gap-2 text-xs sm:text-sm text-gray-600">
                        <FiMapPin className="w-4 h-4 flex-shrink-0" />
                        <span className="truncate">{event.location}</span>
                      </div>
                    )}
                    
                    <div className="flex items-center gap-2 text-xs sm:text-sm text-gray-600">
                      <FiClock className="w-4 h-4 flex-shrink-0" />
                      <time dateTime={event.start_date}>
                        {new Date(event.start_date).toLocaleDateString('fr-FR', {
                          day: 'numeric',
                          month: 'long',
                          year: 'numeric',
                          hour: '2-digit',
                          minute: '2-digit',
                        })}
                      </time>
                    </div>

                    {event.organizer && (
                      <div className="flex items-center gap-2 text-xs sm:text-sm text-gray-600">
                        <FiUsers className="w-4 h-4 flex-shrink-0" />
                        <span className="truncate">
                          {event.organizer.first_name || event.organizer.username || 'Organisateur'}
                        </span>
                      </div>
                    )}

                    {event.university && (
                      <div className="flex items-center gap-2 text-xs sm:text-sm text-gray-600">
                        <FiMapPin className="w-4 h-4 flex-shrink-0" />
                        <span className="truncate">{getUniversityName(event.university)}</span>
                      </div>
                    )}
                  </div>

                  {/* Participants Count */}
                  {event.participants_count !== undefined && (
                    <div className="mt-3 pt-3 border-t border-gray-200">
                      <div className="flex items-center justify-between">
                        <span className="text-xs sm:text-sm text-gray-600">
                          {event.participants_count} participant{event.participants_count > 1 ? 's' : ''}
                        </span>
                        {event.capacity && (
                          <span className="text-xs sm:text-sm text-gray-500">
                            {event.capacity} places max
                          </span>
                        )}
                      </div>
                    </div>
                  )}
                </div>
              </Link>
            ))}
          </div>
        )}
      </main>
    </div>
  )
}

