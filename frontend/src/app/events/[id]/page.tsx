'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter, useParams } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiCalendar, FiMapPin, FiClock, FiUsers, FiArrowLeft, FiUser } from 'react-icons/fi'
import { eventService, type Event } from '@/services/eventService'
import toast from 'react-hot-toast'
import Link from 'next/link'

export default function EventDetailPage() {
  const { user, loading } = useAuth()
  const router = useRouter()
  const params = useParams()
  const eventId = params?.id as string
  const [mounted, setMounted] = useState(false)
  const [event, setEvent] = useState<Event | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [isJoining, setIsJoining] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    }
  }, [mounted, user, loading, router])

  useEffect(() => {
    if (eventId && user) {
      loadEvent()
    }
  }, [eventId, user])

  const loadEvent = async () => {
    if (!eventId) {
      toast.error('ID d\'événement manquant')
      router.push('/events')
      return
    }
    
    setIsLoading(true)
    try {
      const eventData = await eventService.getEvent(eventId)
      if (!eventData || !eventData.id) {
        throw new Error('Événement introuvable')
      }
      setEvent(eventData)
    } catch (error: any) {
      console.error('Error loading event:', error)
      const errorMessage = error?.response?.data?.error || error?.response?.data?.message || error?.message || 'Erreur lors du chargement de l\'événement'
      toast.error(typeof errorMessage === 'string' ? errorMessage : 'Erreur lors du chargement de l\'événement')
      setTimeout(() => {
        router.push('/events')
      }, 2000)
    } finally {
      setIsLoading(false)
    }
  }

  const handleJoinEvent = async () => {
    if (!event || !eventId) return
    
    setIsJoining(true)
    try {
      await eventService.joinEvent(eventId)
      toast.success('Vous avez rejoint l\'événement avec succès')
      await loadEvent() // Reload to get updated participant count
    } catch (error: any) {
      console.error('Error joining event:', error)
      const errorMessage = error?.response?.data?.error || error?.response?.data?.message || 'Erreur lors de la jointure'
      toast.error(typeof errorMessage === 'string' ? errorMessage : 'Erreur lors de la jointure')
    } finally {
      setIsJoining(false)
    }
  }

  const handleLeaveEvent = async () => {
    if (!event || !eventId) return
    
    if (!confirm('Êtes-vous sûr de vouloir quitter cet événement ?')) {
      return
    }
    
    setIsJoining(true)
    try {
      await eventService.leaveEvent(eventId)
      toast.success('Vous avez quitté l\'événement')
      await loadEvent()
    } catch (error: any) {
      console.error('Error leaving event:', error)
      const errorMessage = error?.response?.data?.error || error?.response?.data?.message || 'Erreur lors de la sortie'
      toast.error(typeof errorMessage === 'string' ? errorMessage : 'Erreur lors de la sortie')
    } finally {
      setIsJoining(false)
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

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 to-secondary-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Chargement de l'événement...</p>
        </div>
      </div>
    )
  }

  if (!event) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="bg-white rounded-xl shadow-lg p-8 text-center">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">Événement introuvable</h2>
            <p className="text-gray-600 mb-6">L'événement que vous recherchez n'existe pas ou a été supprimé.</p>
            <Link
              href="/events"
              className="inline-flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition"
            >
              <FiArrowLeft className="w-4 h-4" />
              Retour aux événements
            </Link>
          </div>
        </div>
      </div>
    )
  }

  // Use is_participating from serializer or check manually
  const isParticipant = event.is_participating || false
  const isOrganizer = event.organizer?.id === user?.id
  const isEventFull = event.capacity ? (event.participants_count || 0) >= event.capacity : false
  const isEventPassed = event.start_date ? new Date(event.start_date) < new Date() : false
  const canJoin = event.status === 'published' && !isParticipant && !isOrganizer && !isEventFull && !isEventPassed

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Back Button */}
        <Link
          href="/events"
          className="inline-flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-6 transition"
        >
          <FiArrowLeft className="w-4 h-4" />
          Retour aux événements
        </Link>

        {/* Event Card */}
        <div className="bg-white rounded-2xl shadow-lg overflow-hidden">
          {/* Header Image */}
          {event.image && (
            <div className="h-64 sm:h-80 bg-gradient-to-r from-primary-500 to-secondary-500 relative overflow-hidden">
              <img
                src={(typeof event.image === 'string' ? event.image : (event.image as any)?.url || event.image_url || '')}
                alt={event.title}
                className="w-full h-full object-cover"
              />
            </div>
          )}

          {/* Content */}
          <div className="p-6 sm:p-8">
            {/* Title and Status */}
            <div className="flex items-start justify-between mb-4">
              <h1 className="text-3xl font-bold text-gray-900 flex-1">{event.title}</h1>
              {event.status && (
                <span className={`ml-4 px-3 py-1 rounded-full text-sm font-medium ${
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

            {/* Description */}
            <p className="text-gray-700 mb-6 leading-relaxed whitespace-pre-wrap">{event.description}</p>

            {/* Event Details */}
            <div className="space-y-4 mb-6">
              <div className="flex items-start gap-3">
                <FiCalendar className="w-5 h-5 text-primary-600 mt-1 flex-shrink-0" />
                <div>
                  <p className="font-medium text-gray-900">Date et heure</p>
                  <p className="text-gray-600">
                    {new Date(event.start_date).toLocaleDateString('fr-FR', {
                      weekday: 'long',
                      day: 'numeric',
                      month: 'long',
                      year: 'numeric',
                      hour: '2-digit',
                      minute: '2-digit'
                    })}
                  </p>
                  {event.end_date && (
                    <p className="text-sm text-gray-500 mt-1">
                      Jusqu'au {new Date(event.end_date).toLocaleDateString('fr-FR', {
                        day: 'numeric',
                        month: 'long',
                        year: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit'
                      })}
                    </p>
                  )}
                </div>
              </div>

              <div className="flex items-start gap-3">
                <FiMapPin className="w-5 h-5 text-primary-600 mt-1 flex-shrink-0" />
                <div>
                  <p className="font-medium text-gray-900">Lieu</p>
                  <p className="text-gray-600">{event.location}</p>
                </div>
              </div>

              <div className="flex items-start gap-3">
                <FiUsers className="w-5 h-5 text-primary-600 mt-1 flex-shrink-0" />
                <div>
                  <p className="font-medium text-gray-900">Participants</p>
                  <p className="text-gray-600">
                    {event.participants_count || 0} participant{event.participants_count !== 1 ? 's' : ''}
                    {event.capacity && ` / ${event.capacity} places`}
                  </p>
                  {isEventFull && (
                    <p className="text-sm text-red-600 font-medium mt-1">⚠️ Événement complet</p>
                  )}
                  {isParticipant && (
                    <p className="text-sm text-green-600 font-medium mt-1">✓ Vous participez à cet événement</p>
                  )}
                  {isOrganizer && (
                    <p className="text-sm text-blue-600 font-medium mt-1">👤 Vous êtes l'organisateur</p>
                  )}
                </div>
              </div>

              {event.organizer && (
                <div className="flex items-start gap-3">
                  <FiUser className="w-5 h-5 text-primary-600 mt-1 flex-shrink-0" />
                  <div>
                    <p className="font-medium text-gray-900">Organisateur</p>
                    <p className="text-gray-600">
                      {event.organizer.first_name && event.organizer.last_name
                        ? `${event.organizer.first_name} ${event.organizer.last_name}`
                        : event.organizer.username}
                    </p>
                    {event.organizer.profile?.university && (
                      <p className="text-sm text-gray-500 mt-1">
                        {typeof event.organizer.profile.university === 'string' 
                          ? event.organizer.profile.university 
                          : event.organizer.profile.university?.name || event.organizer.profile.university?.short_name || 'Université'}
                      </p>
                    )}
                  </div>
                </div>
              )}
            </div>

            {/* Action Buttons */}
            {event.status === 'published' && (
              <div className="flex gap-3 pt-6 border-t border-gray-200">
                {canJoin ? (
                  <button
                    onClick={handleJoinEvent}
                    disabled={isJoining || isEventFull || isEventPassed}
                    className="flex-1 bg-primary-600 text-white py-3 rounded-lg hover:bg-primary-700 transition font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isJoining ? 'Traitement...' : isEventFull ? 'Événement complet' : isEventPassed ? 'Événement terminé' : 'Rejoindre l\'événement'}
                  </button>
                ) : isParticipant ? (
                  <button
                    onClick={handleLeaveEvent}
                    disabled={isJoining}
                    className="flex-1 bg-red-600 text-white py-3 rounded-lg hover:bg-red-700 transition font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isJoining ? 'Traitement...' : 'Quitter l\'événement'}
                  </button>
                ) : isOrganizer ? (
                  <div className="flex-1 bg-blue-50 text-blue-700 py-3 rounded-lg text-center font-medium">
                    Vous êtes l'organisateur de cet événement
                  </div>
                ) : isEventFull ? (
                  <div className="flex-1 bg-red-50 text-red-700 py-3 rounded-lg text-center font-medium">
                    Événement complet
                  </div>
                ) : isEventPassed ? (
                  <div className="flex-1 bg-gray-50 text-gray-700 py-3 rounded-lg text-center font-medium">
                    Cet événement est terminé
                  </div>
                ) : null}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

