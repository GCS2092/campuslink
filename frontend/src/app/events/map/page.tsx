'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState, useRef } from 'react'
import { FiMapPin, FiCalendar, FiUsers, FiArrowLeft, FiRefreshCw, FiX } from 'react-icons/fi'
import { eventService, type Event } from '@/services/eventService'
import toast from 'react-hot-toast'
import Link from 'next/link'

export default function EventsMapPage() {
  const { user, loading } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [events, setEvents] = useState<Event[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [userLocation, setUserLocation] = useState<{ lat: number; lng: number } | null>(null)
  const [selectedEvent, setSelectedEvent] = useState<Event | null>(null)
  const [radius, setRadius] = useState(50) // km
  const mapRef = useRef<HTMLDivElement>(null)

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
      getCurrentLocation()
    }
  }, [user])

  useEffect(() => {
    if (userLocation) {
      loadMapEvents()
    }
  }, [userLocation, radius])

  const getCurrentLocation = () => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setUserLocation({
            lat: position.coords.latitude,
            lng: position.coords.longitude
          })
        },
        (error) => {
          console.error('Error getting location:', error)
          // Default to Dakar, Senegal if location is not available
          setUserLocation({ lat: 14.7167, lng: -17.4677 })
          toast.error('Impossible d&apos;obtenir votre localisation. Utilisation de la position par défaut.')
        }
      )
    } else {
      // Default to Dakar, Senegal
      setUserLocation({ lat: 14.7167, lng: -17.4677 })
      toast.error('La géolocalisation n&apos;est pas supportée par votre navigateur.')
    }
  }

  const loadMapEvents = async () => {
    if (!userLocation) return

    setIsLoading(true)
    try {
      const response = await eventService.getMapEvents({
        lat: userLocation.lat,
        lng: userLocation.lng,
        radius
      })
      const eventsData = response.events || response.data || response || []
      setEvents(Array.isArray(eventsData) ? eventsData : [])
    } catch (error: any) {
      console.error('Error loading map events:', error)
      toast.error('Erreur lors du chargement des événements sur la carte')
      setEvents([])
    } finally {
      setIsLoading(false)
    }
  }

  const initializeMap = () => {
    if (!mapRef.current || !userLocation) return

    // Simple map using OpenStreetMap with Leaflet-like approach
    // For production, you might want to use react-leaflet or Google Maps
    const mapContainer = mapRef.current
    mapContainer.innerHTML = '' // Clear previous map

    // Create a simple map visualization
    const mapCanvas = document.createElement('div')
    mapCanvas.style.width = '100%'
    mapCanvas.style.height = '100%'
    mapCanvas.style.background = '#e5e7eb'
    mapCanvas.style.position = 'relative'
    mapCanvas.style.borderRadius = '0.5rem'
    mapCanvas.style.overflow = 'hidden'

    // Add OpenStreetMap iframe as a simple solution
    // In production, use a proper map library like react-leaflet
    const iframe = document.createElement('iframe')
    iframe.width = '100%'
    iframe.height = '100%'
    iframe.frameBorder = '0'
    iframe.style.border = '0'
    iframe.src = `https://www.openstreetmap.org/export/embed.html?bbox=${userLocation.lng - 0.1},${userLocation.lat - 0.1},${userLocation.lng + 0.1},${userLocation.lat + 0.1}&layer=mapnik&marker=${userLocation.lat},${userLocation.lng}`
    
    mapCanvas.appendChild(iframe)
    mapContainer.appendChild(mapCanvas)

    // Add event markers (simplified - in production use proper map markers)
    events.forEach((event) => {
      // TypeScript type guard for location properties
      const hasLocation = 'location_lat' in event && 'location_lng' in event
      if (hasLocation && (event as any).location_lat && (event as any).location_lng) {
        // In a real implementation, you would add markers to the map
        // For now, we'll show events in the sidebar
      }
    })
  }

  useEffect(() => {
    if (userLocation && events.length > 0) {
      // Initialize map when location and events are loaded
      setTimeout(initializeMap, 100)
    }
  }, [userLocation, events])

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
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <Link
                href="/events"
                className="p-2 hover:bg-gray-100 rounded-lg transition"
              >
                <FiArrowLeft className="w-5 h-5" />
              </Link>
              <h1 className="text-xl font-bold text-gray-900">Carte des événements</h1>
            </div>
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-2">
                <label className="text-sm text-gray-600">Rayon:</label>
                <select
                  value={radius}
                  onChange={(e) => setRadius(Number(e.target.value))}
                  className="px-3 py-1 border border-gray-300 rounded-lg text-sm"
                >
                  <option value={10}>10 km</option>
                  <option value={25}>25 km</option>
                  <option value={50}>50 km</option>
                  <option value={100}>100 km</option>
                </select>
              </div>
              <button
                onClick={loadMapEvents}
                disabled={isLoading}
                className="p-2 hover:bg-gray-100 rounded-lg transition disabled:opacity-50"
              >
                <FiRefreshCw className={`w-5 h-5 ${isLoading ? 'animate-spin' : ''}`} />
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Map */}
          <div className="lg:col-span-2">
            <div className="bg-white rounded-xl shadow-lg overflow-hidden" style={{ height: '600px' }}>
              <div ref={mapRef} className="w-full h-full">
                {isLoading ? (
                  <div className="flex items-center justify-center h-full">
                    <div className="text-center">
                      <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
                      <p className="mt-4 text-gray-600">Chargement de la carte...</p>
                    </div>
                  </div>
                ) : userLocation ? (
                  <div className="w-full h-full bg-gray-200 flex items-center justify-center">
                    <p className="text-gray-500">Carte en cours de chargement...</p>
                  </div>
                ) : (
                  <div className="flex items-center justify-center h-full">
                    <p className="text-gray-500">Localisation non disponible</p>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Events List */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-xl shadow-lg p-4">
              <h2 className="text-lg font-semibold mb-4">
                Événements ({events.length})
              </h2>
              {isLoading ? (
                <div className="text-center py-8">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
                  <p className="mt-4 text-sm text-gray-600">Chargement...</p>
                </div>
              ) : events.length === 0 ? (
                <div className="text-center py-8">
                  <FiMapPin className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                  <p className="text-sm text-gray-600">Aucun événement trouvé dans cette zone</p>
                </div>
              ) : (
                <div className="space-y-3 max-h-[600px] overflow-y-auto">
                  {events.map((event) => (
                    <div
                      key={event.id}
                      onClick={() => setSelectedEvent(event)}
                      className={`p-3 rounded-lg border cursor-pointer transition ${
                        selectedEvent?.id === event.id
                          ? 'border-primary-500 bg-primary-50'
                          : 'border-gray-200 hover:border-primary-300 hover:bg-gray-50'
                      }`}
                    >
                      <h3 className="font-semibold text-sm mb-1 line-clamp-2">{event.title}</h3>
                      <div className="space-y-1 text-xs text-gray-600">
                        <div className="flex items-center gap-1">
                          <FiCalendar className="w-3 h-3" />
                          <span>
                            {new Date(event.start_date).toLocaleDateString('fr-FR', {
                              day: 'numeric',
                              month: 'short',
                              hour: '2-digit',
                              minute: '2-digit'
                            })}
                          </span>
                        </div>
                        <div className="flex items-center gap-1">
                          <FiMapPin className="w-3 h-3" />
                          <span className="truncate">{event.location}</span>
                        </div>
                        {event.participants_count !== undefined && (
                          <div className="flex items-center gap-1">
                            <FiUsers className="w-3 h-3" />
                            <span>{event.participants_count} participants</span>
                          </div>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Event Detail Modal */}
        {selectedEvent && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-xl shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
              <div className="p-6">
                <div className="flex items-start justify-between mb-4">
                  <h2 className="text-2xl font-bold">{selectedEvent.title}</h2>
                  <button
                    onClick={() => setSelectedEvent(null)}
                    className="text-gray-500 hover:text-gray-700"
                  >
                    <FiX className="w-6 h-6" />
                  </button>
                </div>
                <div className="space-y-4">
                  <p className="text-gray-700">{selectedEvent.description}</p>
                  <div className="grid grid-cols-2 gap-4 text-sm">
                    <div>
                      <span className="font-semibold">Date:</span>
                      <p>
                        {new Date(selectedEvent.start_date).toLocaleDateString('fr-FR', {
                          day: 'numeric',
                          month: 'long',
                          year: 'numeric',
                          hour: '2-digit',
                          minute: '2-digit'
                        })}
                      </p>
                    </div>
                    <div>
                      <span className="font-semibold">Lieu:</span>
                      <p>{selectedEvent.location}</p>
                    </div>
                    <div>
                      <span className="font-semibold">Prix:</span>
                      <p>{selectedEvent.is_free ? 'Gratuit' : `${selectedEvent.price} FCFA`}</p>
                    </div>
                    <div>
                      <span className="font-semibold">Participants:</span>
                      <p>{selectedEvent.participants_count || 0}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2 pt-4 border-t">
                    <Link
                      href={`/events/${selectedEvent.id}`}
                      className="flex-1 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition text-center"
                    >
                      Voir les détails
                    </Link>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  )
}

