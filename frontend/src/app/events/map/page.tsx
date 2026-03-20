'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState, useRef, useCallback } from 'react'
import {
  FiMapPin, FiCalendar, FiUsers, FiArrowLeft, FiRefreshCw,
  FiNavigation, FiExternalLink, FiCrosshair, FiZap
} from 'react-icons/fi'
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
  const [radius, setRadius] = useState(50)
  const [routeInfo, setRouteInfo] = useState<{ distance: string; duration: string; eventId: string } | null>(null)
  const [isRoutingLoading, setIsRoutingLoading] = useState<string | null>(null)
  const [isTracking, setIsTracking] = useState(false)
  const [mapReady, setMapReady] = useState(false)

  // Leaflet refs
  const mapContainerRef = useRef<HTMLDivElement>(null)
  const mapRef = useRef<any>(null)
  const userMarkerRef = useRef<any>(null)
  const userCircleRef = useRef<any>(null)
  const eventMarkersRef = useRef<any[]>([])
  const routeLayerRef = useRef<any>(null)
  const watchIdRef = useRef<number | null>(null)
  const LRef = useRef<any>(null)

  useEffect(() => { setMounted(true) }, [])

  useEffect(() => {
    if (mounted && !loading && !user) router.push('/login')
  }, [mounted, user, loading, router])

  useEffect(() => {
    if (user) getCurrentLocation()
    return () => { if (watchIdRef.current) navigator.geolocation.clearWatch(watchIdRef.current) }
  }, [user])

  useEffect(() => {
    if (userLocation && mounted) {
      initMap()
    }
  }, [userLocation, mounted])

  useEffect(() => {
    if (mapReady && userLocation) {
      loadMapEvents()
    }
  }, [mapReady, radius])

  useEffect(() => {
    if (mapReady && events.length > 0) {
      addEventMarkers()
    }
  }, [events, mapReady])

  // ─── Geolocation ────────────────────────────────────────────────────────────

  const getCurrentLocation = () => {
    if (!navigator.geolocation) {
      setUserLocation({ lat: 14.7167, lng: -17.4677 })
      return
    }
    navigator.geolocation.getCurrentPosition(
      (pos) => setUserLocation({ lat: pos.coords.latitude, lng: pos.coords.longitude }),
      () => {
        setUserLocation({ lat: 14.7167, lng: -17.4677 })
        toast.error('Localisation par défaut utilisée (Dakar)')
      },
      { enableHighAccuracy: true }
    )
  }

  const startTracking = () => {
    if (!navigator.geolocation) return
    setIsTracking(true)
    toast.success('Suivi de position activé')
    watchIdRef.current = navigator.geolocation.watchPosition(
      (pos) => {
        const newLoc = { lat: pos.coords.latitude, lng: pos.coords.longitude }
        setUserLocation(newLoc)
        updateUserMarker(newLoc)
      },
      () => toast.error('Erreur de géolocalisation'),
      { enableHighAccuracy: true, maximumAge: 3000, timeout: 10000 }
    )
  }

  const stopTracking = () => {
    if (watchIdRef.current !== null) {
      navigator.geolocation.clearWatch(watchIdRef.current)
      watchIdRef.current = null
    }
    setIsTracking(false)
    toast('Suivi de position désactivé')
  }

  const centerOnUser = () => {
    if (!mapRef.current || !userLocation) return
    mapRef.current.setView([userLocation.lat, userLocation.lng], 15, { animate: true })
  }

  // ─── Leaflet Map ─────────────────────────────────────────────────────────────

  const initMap = async () => {
    if (mapRef.current || !mapContainerRef.current || !userLocation) return

    const L = (await import('leaflet')).default
    LRef.current = L

    // Fix default icons
    delete (L.Icon.Default.prototype as any)._getIconUrl
    L.Icon.Default.mergeOptions({
      iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
      iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
      shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
    })

    const map = L.map(mapContainerRef.current, {
      center: [userLocation.lat, userLocation.lng],
      zoom: 13,
      zoomControl: true,
    })

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      maxZoom: 19,
    }).addTo(map)

    mapRef.current = map

    // Add user marker
    addUserMarker(userLocation)

    setMapReady(true)
    await loadMapEvents()
  }

  const addUserMarker = (loc: { lat: number; lng: number }) => {
    const L = LRef.current
    if (!L || !mapRef.current) return

    // Remove old
    if (userMarkerRef.current) userMarkerRef.current.remove()
    if (userCircleRef.current) userCircleRef.current.remove()

    // Pulsing blue dot for user
    const userIcon = L.divIcon({
      html: `
        <div style="position:relative;width:20px;height:20px">
          <div style="
            position:absolute;inset:0;
            background:#3b82f6;
            border-radius:50%;
            border:3px solid white;
            box-shadow:0 2px 8px rgba(59,130,246,0.6);
            animation:pulse 2s infinite;
          "></div>
        </div>
        <style>
          @keyframes pulse {
            0%,100%{box-shadow:0 0 0 0 rgba(59,130,246,0.4)}
            50%{box-shadow:0 0 0 10px rgba(59,130,246,0)}
          }
        </style>
      `,
      className: '',
      iconSize: [20, 20],
      iconAnchor: [10, 10],
    })

    userMarkerRef.current = L.marker([loc.lat, loc.lng], { icon: userIcon, zIndexOffset: 1000 })
      .addTo(mapRef.current)
      .bindPopup('<b>📍 Vous êtes ici</b>')

    // Accuracy circle
    userCircleRef.current = L.circle([loc.lat, loc.lng], {
      radius: 80,
      color: '#3b82f6',
      fillColor: '#3b82f6',
      fillOpacity: 0.1,
      weight: 1,
    }).addTo(mapRef.current)
  }

  const updateUserMarker = (loc: { lat: number; lng: number }) => {
    if (!mapRef.current || !LRef.current) return
    addUserMarker(loc)
    if (isTracking) {
      mapRef.current.setView([loc.lat, loc.lng], mapRef.current.getZoom(), { animate: true })
    }
  }

  const addEventMarkers = async () => {
    const L = LRef.current
    if (!L || !mapRef.current) return

    // Clear old event markers
    eventMarkersRef.current.forEach(m => m.remove())
    eventMarkersRef.current = []

    events.forEach((event) => {
      if (!event.location_lat || !event.location_lng) return

      const eventIcon = L.divIcon({
        html: `
          <div style="
            background:#ef4444;
            color:white;
            border-radius:50% 50% 50% 0;
            transform:rotate(-45deg);
            width:28px;height:28px;
            border:2px solid white;
            box-shadow:0 2px 6px rgba(0,0,0,0.3);
            display:flex;align-items:center;justify-content:center;
          ">
            <span style="transform:rotate(45deg);font-size:12px">📅</span>
          </div>
        `,
        className: '',
        iconSize: [28, 28],
        iconAnchor: [14, 28],
        popupAnchor: [0, -28],
      })

      const lat = parseFloat(String(event.location_lat))
      const lng = parseFloat(String(event.location_lng))

      const marker = L.marker([lat, lng], { icon: eventIcon })
        .addTo(mapRef.current)
        .bindPopup(`
          <div style="min-width:160px;font-family:sans-serif">
            <b style="font-size:13px">${event.title}</b><br/>
            <span style="color:#6b7280;font-size:11px">📍 ${event.location}</span><br/>
            <span style="color:#6b7280;font-size:11px">👥 ${event.participants_count} participants</span>
          </div>
        `)

      eventMarkersRef.current.push(marker)
    })
  }

  // ─── Load Events ─────────────────────────────────────────────────────────────

  const loadMapEvents = async () => {
    if (!userLocation) return
    setIsLoading(true)
    try {
      const response = await eventService.getMapEvents({ lat: userLocation.lat, lng: userLocation.lng, radius })
      const eventsData = response.events || response.data || response || []
      setEvents(Array.isArray(eventsData) ? eventsData : [])
    } catch {
      toast.error('Erreur lors du chargement des événements')
      setEvents([])
    } finally {
      setIsLoading(false)
    }
  }

  // ─── Routing ─────────────────────────────────────────────────────────────────

  const getRoute = async (event: Event) => {
    if (!userLocation || !event.location_lat || !event.location_lng) return
    setIsRoutingLoading(event.id)
    setRouteInfo(null)

    const L = LRef.current
    if (routeLayerRef.current && mapRef.current) {
      routeLayerRef.current.remove()
      routeLayerRef.current = null
    }

    const destLat = parseFloat(String(event.location_lat))
    const destLng = parseFloat(String(event.location_lng))

    try {
      const res = await fetch(`https://router.project-osrm.org/route/v1/driving/${userLocation.lng},${userLocation.lat};${destLng},${destLat}?overview=full&geometries=geojson`)
      const data = await res.json()

      if (data.code !== 'Ok' || !data.routes?.length) {
        toast.error('Impossible de calculer l\'itinéraire')
        return
      }

      const route = data.routes[0]
      const distanceKm = (route.distance / 1000).toFixed(1)
      const durationMin = Math.round(route.duration / 60)
      const durationStr = durationMin < 60 ? `${durationMin} min` : `${Math.floor(durationMin / 60)}h${durationMin % 60 > 0 ? String(durationMin % 60) + 'min' : ''}`

      setRouteInfo({ distance: `${distanceKm} km`, duration: durationStr, eventId: event.id })

      // Draw route on Leaflet map
      if (L && mapRef.current) {
        const coords = route.geometry.coordinates.map(([lng, lat]: number[]) => [lat, lng])
        routeLayerRef.current = L.polyline(coords, {
          color: '#3b82f6', weight: 5, opacity: 0.8,
          dashArray: undefined,
        }).addTo(mapRef.current)
        mapRef.current.fitBounds(routeLayerRef.current.getBounds(), { padding: [50, 50], animate: true })
      }

      toast.success(`${distanceKm} km — ${durationStr} en voiture`)
    } catch {
      toast.error('Erreur lors du calcul de l\'itinéraire')
    } finally {
      setIsRoutingLoading(null)
    }
  }

  const clearRoute = () => {
    if (routeLayerRef.current && mapRef.current) {
      routeLayerRef.current.remove()
      routeLayerRef.current = null
    }
    setRouteInfo(null)
    if (userLocation) mapRef.current?.setView([userLocation.lat, userLocation.lng], 13, { animate: true })
  }

  const openInGoogleMaps = (event: Event) => {
    if (!userLocation || !event.location_lat || !event.location_lng) return
    window.open(`https://www.google.com/maps/dir/${userLocation.lat},${userLocation.lng}/${event.location_lat},${event.location_lng}`, '_blank')
  }

  const openInOSM = (event: Event) => {
    if (!userLocation || !event.location_lat || !event.location_lng) return
    window.open(`https://www.openstreetmap.org/directions?engine=osrm_car&route=${userLocation.lat},${userLocation.lng};${event.location_lat},${event.location_lng}`, '_blank')
  }

  const focusEventOnMap = (event: Event) => {
    if (!mapRef.current || !event.location_lat || !event.location_lng) return
    const lat = parseFloat(String(event.location_lat))
    const lng = parseFloat(String(event.location_lng))
    mapRef.current.setView([lat, lng], 15, { animate: true })
    // Open popup of the corresponding marker
    eventMarkersRef.current.forEach(m => {
      const pos = m.getLatLng()
      if (Math.abs(pos.lat - lat) < 0.0001 && Math.abs(pos.lng - lng) < 0.0001) {
        m.openPopup()
      }
    })
  }

  if (!mounted || loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  if (!user) return null

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 pb-24">

      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-20">
        <div className="max-w-7xl mx-auto px-4 py-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <Link href="/events" className="p-2 hover:bg-gray-100 rounded-lg transition">
                <FiArrowLeft className="w-5 h-5" />
              </Link>
              <h1 className="text-lg font-bold text-gray-900">Carte des événements</h1>
            </div>
            <div className="flex items-center gap-2">
              <select
                value={radius}
                onChange={(e) => { setRadius(Number(e.target.value)); setRouteInfo(null) }}
                className="px-2 py-1 border border-gray-300 rounded-lg text-xs"
              >
                <option value={10}>10 km</option>
                <option value={25}>25 km</option>
                <option value={50}>50 km</option>
                <option value={100}>100 km</option>
              </select>
              <button onClick={() => { loadMapEvents(); clearRoute() }} disabled={isLoading}
                className="p-2 hover:bg-gray-100 rounded-lg transition disabled:opacity-50">
                <FiRefreshCw className={`w-4 h-4 ${isLoading ? 'animate-spin' : ''}`} />
              </button>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 py-4 space-y-4">

        {/* Map container */}
        <div className="relative bg-white rounded-xl shadow-lg overflow-hidden" style={{ height: '340px' }}>
          <div ref={mapContainerRef} className="w-full h-full" />

          {/* Map controls overlay */}
          <div className="absolute bottom-3 right-3 flex flex-col gap-2 z-[1000]">
            {/* Center on user */}
            <button
              onClick={centerOnUser}
              className="bg-white shadow-md rounded-lg p-2.5 hover:bg-blue-50 transition border border-gray-200"
              title="Centrer sur ma position"
            >
              <FiCrosshair className="w-4 h-4 text-blue-600" />
            </button>

            {/* Live tracking toggle */}
            <button
              onClick={isTracking ? stopTracking : startTracking}
              className={`shadow-md rounded-lg p-2.5 transition border ${isTracking ? 'bg-blue-600 border-blue-600' : 'bg-white border-gray-200 hover:bg-blue-50'}`}
              title={isTracking ? 'Arrêter le suivi' : 'Activer le suivi en direct'}
            >
              <FiZap className={`w-4 h-4 ${isTracking ? 'text-white' : 'text-gray-600'}`} />
            </button>
          </div>

          {/* Tracking badge */}
          {isTracking && (
            <div className="absolute top-3 left-3 z-[1000] bg-blue-600 text-white text-xs font-semibold px-3 py-1.5 rounded-full flex items-center gap-1.5 shadow-md">
              <span className="w-2 h-2 bg-white rounded-full animate-pulse"></span>
              Suivi actif
            </div>
          )}

          {!mapReady && (
            <div className="absolute inset-0 flex items-center justify-center bg-white z-10">
              <div className="text-center">
                <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-primary-600 mx-auto"></div>
                <p className="mt-3 text-sm text-gray-600">Chargement de la carte...</p>
              </div>
            </div>
          )}
        </div>

        {/* Route info banner */}
        {routeInfo && (
          <div className="bg-blue-50 border border-blue-200 rounded-xl px-4 py-3 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <FiNavigation className="w-5 h-5 text-blue-600 flex-shrink-0" />
              <div>
                <span className="font-bold text-blue-800">{routeInfo.distance}</span>
                <span className="text-blue-600 ml-2 text-sm">· {routeInfo.duration} en voiture</span>
              </div>
            </div>
            <button onClick={clearRoute} className="text-blue-400 hover:text-blue-600 p-1">
              ✕
            </button>
          </div>
        )}

        {/* Events list */}
        <div>
          <h2 className="text-base font-bold text-gray-900 mb-3">
            {isLoading ? 'Chargement...' : `${events.length} événement${events.length > 1 ? 's' : ''} trouvé${events.length > 1 ? 's' : ''}`}
          </h2>

          {isLoading ? (
            <div className="text-center py-8">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
            </div>
          ) : events.length === 0 ? (
            <div className="bg-white rounded-xl p-8 text-center shadow-sm">
              <FiMapPin className="w-12 h-12 text-gray-300 mx-auto mb-3" />
              <p className="text-gray-500 text-sm">Aucun événement dans cette zone</p>
              <p className="text-gray-400 text-xs mt-1">Essayez d'augmenter le rayon de recherche</p>
            </div>
          ) : (
            <div className="space-y-3">
              {events.map((event) => (
                <div key={event.id} className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                  <div className="p-4">
                    {/* Event title — cliquable pour centrer sur la carte */}
                    <button
                      onClick={() => focusEventOnMap(event)}
                      className="text-left w-full mb-2 group"
                    >
                      <h3 className="font-bold text-gray-900 group-hover:text-primary-600 transition flex items-center gap-2">
                        {event.title}
                        <FiMapPin className="w-3.5 h-3.5 text-gray-400 group-hover:text-primary-500 flex-shrink-0" />
                      </h3>
                    </button>

                    <div className="space-y-1.5 text-sm text-gray-600 mb-3">
                      <div className="flex items-center gap-2">
                        <FiCalendar className="w-4 h-4 text-primary-500 flex-shrink-0" />
                        <span>{new Date(event.start_date).toLocaleDateString('fr-FR', {
                          day: 'numeric', month: 'long', hour: '2-digit', minute: '2-digit'
                        })}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <FiMapPin className="w-4 h-4 text-primary-500 flex-shrink-0" />
                        <span>{event.location}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <FiUsers className="w-4 h-4 text-primary-500 flex-shrink-0" />
                        <span>{event.participants_count} participant{(event.participants_count || 0) > 1 ? 's' : ''}</span>
                      </div>
                    </div>

                    {/* Route result for this event */}
                    {routeInfo?.eventId === event.id && (
                      <div className="bg-blue-50 rounded-lg px-3 py-2 flex items-center gap-2 mb-3">
                        <FiNavigation className="w-4 h-4 text-blue-600 flex-shrink-0" />
                        <span className="text-sm font-semibold text-blue-800">{routeInfo.distance} · {routeInfo.duration} en voiture</span>
                      </div>
                    )}

                    {event.location_lat && event.location_lng ? (
                      <div className="space-y-2">
                        {/* In-app routing */}
                        <button
                          onClick={() => getRoute(event)}
                          disabled={isRoutingLoading === event.id}
                          className="w-full flex items-center justify-center gap-2 px-4 py-2.5 bg-blue-600 text-white rounded-lg text-sm font-semibold hover:bg-blue-700 transition disabled:opacity-50"
                        >
                          <FiNavigation className="w-4 h-4" />
                          {isRoutingLoading === event.id ? 'Calcul en cours...' : 'Calculer l\'itinéraire'}
                        </button>

                        {/* External apps */}
                        <div className="grid grid-cols-2 gap-2">
                          <button onClick={() => openInGoogleMaps(event)}
                            className="flex items-center justify-center gap-1.5 px-3 py-2 bg-gray-100 text-gray-700 rounded-lg text-xs font-semibold hover:bg-gray-200 transition">
                            <FiExternalLink className="w-3.5 h-3.5" />
                            Google Maps
                          </button>
                          <button onClick={() => openInOSM(event)}
                            className="flex items-center justify-center gap-1.5 px-3 py-2 bg-gray-100 text-gray-700 rounded-lg text-xs font-semibold hover:bg-gray-200 transition">
                            <FiExternalLink className="w-3.5 h-3.5" />
                            OpenStreetMap
                          </button>
                        </div>
                      </div>
                    ) : (
                      <p className="text-xs text-gray-400 italic">Coordonnées GPS non disponibles pour cet événement</p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}