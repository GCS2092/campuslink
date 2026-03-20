'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState, useRef } from 'react'
import { FiCalendar, FiMapPin, FiUsers, FiArrowLeft, FiSearch, FiCheck, FiLoader } from 'react-icons/fi'
import { eventService } from '@/services/eventService'
import toast from 'react-hot-toast'
import Link from 'next/link'

interface GeoSuggestion {
  display_name: string
  lat: string
  lon: string
  place_id: number
}

export default function CreateEventPage() {
  const { user, loading } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [categories, setCategories] = useState<Array<{ id: string; name: string }>>([])

  // Geocoding state
  const [locationInput, setLocationInput] = useState('')
  const [suggestions, setSuggestions] = useState<GeoSuggestion[]>([])
  const [isGeoLoading, setIsGeoLoading] = useState(false)
  const [selectedCoords, setSelectedCoords] = useState<{ lat: number; lng: number } | null>(null)
  const [geoError, setGeoError] = useState('')
  const geoDebounceRef = useRef<NodeJS.Timeout | null>(null)
  const suggestionsRef = useRef<HTMLDivElement>(null)

  const [formData, setFormData] = useState({
    title: '',
    description: '',
    category: '',
    start_date: '',
    start_time: '',
    end_date: '',
    end_time: '',
    capacity: '',
    price: '',
    is_free: true,
    registration_link: '',
    status: 'draft' as 'draft' | 'published',
  })

  useEffect(() => { setMounted(true) }, [])

  useEffect(() => {
    if (mounted && !loading && !user) router.push('/login')
    else if (mounted && user && !user.is_verified) {
      toast.error('Vous devez être vérifié pour créer un événement')
      router.push('/events')
    }
  }, [mounted, user, loading, router])

  useEffect(() => {
    if (user) loadCategories()
  }, [user])

  // Close suggestions when clicking outside
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (suggestionsRef.current && !suggestionsRef.current.contains(e.target as Node)) {
        setSuggestions([])
      }
    }
    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  const loadCategories = async () => {
    try {
      const response = await eventService.getCategories()
      setCategories(Array.isArray(response) ? response : response.results || response.data || [])
    } catch (error) {
      console.error('Error loading categories:', error)
    }
  }

  // ─── Geocoding via Nominatim ─────────────────────────────────────────────────

  const searchLocation = async (query: string) => {
    if (!query.trim() || query.length < 3) {
      setSuggestions([])
      return
    }

    setIsGeoLoading(true)
    setGeoError('')
    try {
      const res = await fetch(
        `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(query)}&format=json&limit=5&addressdetails=1&accept-language=fr`,
        { headers: { 'Accept-Language': 'fr' } }
      )
      const data: GeoSuggestion[] = await res.json()
      setSuggestions(data)
      if (data.length === 0) setGeoError('Aucun lieu trouvé. Essayez un autre terme.')
    } catch {
      setGeoError('Erreur lors de la recherche')
    } finally {
      setIsGeoLoading(false)
    }
  }

  const handleLocationInput = (value: string) => {
    setLocationInput(value)
    setSelectedCoords(null)
    setGeoError('')

    if (geoDebounceRef.current) clearTimeout(geoDebounceRef.current)
    geoDebounceRef.current = setTimeout(() => searchLocation(value), 500)
  }

  const handleSelectSuggestion = (suggestion: GeoSuggestion) => {
    setLocationInput(suggestion.display_name)
    setSelectedCoords({ lat: parseFloat(suggestion.lat), lng: parseFloat(suggestion.lon) })
    setSuggestions([])
    setGeoError('')
    toast.success('📍 Lieu sélectionné avec coordonnées GPS')
  }

  const geocodeOnSubmit = async (): Promise<{ lat: number; lng: number } | null> => {
    if (selectedCoords) return selectedCoords
    if (!locationInput.trim()) return null

    // Try to geocode the raw input
    try {
      const res = await fetch(
        `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(locationInput)}&format=json&limit=1`,
        { headers: { 'Accept-Language': 'fr' } }
      )
      const data: GeoSuggestion[] = await res.json()
      if (data.length > 0) {
        return { lat: parseFloat(data[0].lat), lng: parseFloat(data[0].lon) }
      }
    } catch {
      // Ignore — will submit without coords
    }
    return null
  }

  // ─── Submit ──────────────────────────────────────────────────────────────────

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!user?.is_verified) {
      toast.error('Vous devez être vérifié pour créer un événement')
      return
    }

    if (user?.role === 'admin' || user?.role === 'university_admin' || user?.is_staff) {
      toast.error('Les administrateurs ne peuvent pas créer d\'événements directement')
      router.push('/events')
      return
    }

    if (!formData.title.trim()) { toast.error('Le titre est requis'); return }
    if (!formData.description.trim()) { toast.error('La description est requise'); return }
    if (!formData.start_date || !formData.start_time) { toast.error('La date et heure de début sont requises'); return }
    if (!locationInput.trim()) { toast.error('Le lieu est requis'); return }

    setIsSubmitting(true)
    try {
      // Geocode if not already done
      const coords = await geocodeOnSubmit()

      const startDateTime = `${formData.start_date}T${formData.start_time}:00`
      const endDateTime = formData.end_date && formData.end_time
        ? `${formData.end_date}T${formData.end_time}:00`
        : null

      const eventData: any = {
        title: formData.title,
        description: formData.description,
        start_date: startDateTime,
        location: locationInput,
        status: formData.status,
        is_free: formData.is_free,
        price: formData.is_free ? 0 : parseFloat(formData.price) || 0,
      }

      // ✅ Add GPS coordinates if available
      if (coords) {
        eventData.location_lat = coords.lat
        eventData.location_lng = coords.lng
      }

      if (formData.category) eventData.category = formData.category
      if (endDateTime) eventData.end_date = endDateTime
      if (formData.capacity) eventData.capacity = parseInt(formData.capacity)
      if (formData.registration_link) eventData.registration_link = formData.registration_link

      const createdEvent = await eventService.createEvent(eventData)

      if (coords) {
        toast.success('Événement créé avec succès ! 📍 Coordonnées GPS enregistrées.')
      } else {
        toast.success('Événement créé ! (Lieu sans coordonnées GPS — non visible sur la carte)')
      }

      setTimeout(() => router.push(`/events/${createdEvent.id}`), 500)
    } catch (error: any) {
      console.error('Error creating event:', error)
      if (error?.response?.status === 201 || error?.response?.status === 200) {
        toast.success('Événement créé avec succès !')
        if (error?.response?.data?.id) router.push(`/events/${error.response.data.id}`)
        else router.push('/events')
      } else {
        const errorMessage = error?.response?.data?.error || error?.response?.data?.message || 'Erreur lors de la création'
        toast.error(typeof errorMessage === 'string' ? errorMessage : 'Erreur lors de la création de l\'événement')
      }
    } finally {
      setIsSubmitting(false)
    }
  }

  if (!mounted || loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 to-secondary-50">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  if (!user) return null

  if (!user.is_verified) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="bg-white rounded-xl shadow-lg p-8 text-center">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">Compte non vérifié</h2>
            <p className="text-gray-600 mb-6">Vous devez être vérifié pour créer un événement.</p>
            <Link href="/events" className="inline-flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition">
              <FiArrowLeft className="w-4 h-4" />
              Retour aux événements
            </Link>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <Link href="/events" className="inline-flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-6 transition">
          <FiArrowLeft className="w-4 h-4" />
          Retour aux événements
        </Link>

        <div className="bg-white rounded-2xl shadow-lg overflow-hidden">
          <div className="bg-gradient-to-r from-primary-500 to-secondary-500 p-6">
            <h1 className="text-3xl font-bold text-white">Créer un événement</h1>
            <p className="text-white/90 mt-2">Partagez votre événement avec la communauté</p>
          </div>

          <form onSubmit={handleSubmit} className="p-6 sm:p-8 space-y-6">

            {/* Title */}
            <div>
              <label htmlFor="title" className="block text-sm font-medium text-gray-700 mb-2">
                Titre de l'événement *
              </label>
              <input
                type="text" id="title" required
                value={formData.title}
                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                placeholder="Ex: Soirée de fin d'année"
              />
            </div>

            {/* Description */}
            <div>
              <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-2">
                Description *
              </label>
              <textarea
                id="description" required rows={6}
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                placeholder="Décrivez votre événement en détail..."
              />
            </div>

            {/* Category */}
            {categories.length > 0 && (
              <div>
                <label htmlFor="category" className="block text-sm font-medium text-gray-700 mb-2">Catégorie</label>
                <select
                  id="category" value={formData.category}
                  onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                >
                  <option value="">Sélectionner une catégorie</option>
                  {categories.map((cat) => (
                    <option key={cat.id} value={cat.id}>{cat.name}</option>
                  ))}
                </select>
              </div>
            )}

            {/* Dates */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Date de début *</label>
                <input type="date" required value={formData.start_date}
                  onChange={(e) => setFormData({ ...formData, start_date: e.target.value })}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Heure de début *</label>
                <input type="time" required value={formData.start_time}
                  onChange={(e) => setFormData({ ...formData, start_time: e.target.value })}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent" />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Date de fin (optionnel)</label>
                <input type="date" value={formData.end_date}
                  onChange={(e) => setFormData({ ...formData, end_date: e.target.value })}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Heure de fin (optionnel)</label>
                <input type="time" value={formData.end_time}
                  onChange={(e) => setFormData({ ...formData, end_time: e.target.value })}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent" />
              </div>
            </div>

            {/* ✅ Location with geocoding */}
            <div>
              <label htmlFor="location" className="block text-sm font-medium text-gray-700 mb-2">
                Lieu * <span className="text-xs text-gray-400 font-normal">(les coordonnées GPS seront automatiquement détectées)</span>
              </label>
              <div className="relative" ref={suggestionsRef}>
                <div className="relative">
                  <FiMapPin className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                  <input
                    type="text"
                    id="location"
                    required
                    value={locationInput}
                    onChange={(e) => handleLocationInput(e.target.value)}
                    className={`w-full pl-10 pr-10 py-3 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition ${
                      selectedCoords ? 'border-green-400 bg-green-50' : 'border-gray-300'
                    }`}
                    placeholder="Ex: Ouest Foire, Dakar"
                    autoComplete="off"
                  />
                  <div className="absolute right-3 top-1/2 -translate-y-1/2">
                    {isGeoLoading && <div className="w-4 h-4 border-2 border-primary-500 border-t-transparent rounded-full animate-spin" />}
                    {selectedCoords && !isGeoLoading && <FiCheck className="w-4 h-4 text-green-500" />}
                    {!selectedCoords && !isGeoLoading && locationInput && <FiSearch className="w-4 h-4 text-gray-400" />}
                  </div>
                </div>

                {/* GPS confirmed badge */}
                {selectedCoords && (
                  <div className="mt-1.5 flex items-center gap-1.5 text-xs text-green-600">
                    <FiCheck className="w-3 h-3" />
                    <span>GPS confirmé — visible sur la carte ({selectedCoords.lat.toFixed(4)}, {selectedCoords.lng.toFixed(4)})</span>
                  </div>
                )}

                {/* Error */}
                {geoError && (
                  <p className="mt-1.5 text-xs text-amber-600">{geoError} — L'événement sera créé sans coordonnées GPS.</p>
                )}

                {/* Suggestions dropdown */}
                {suggestions.length > 0 && (
                  <div className="absolute z-50 w-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg overflow-hidden">
                    {suggestions.map((s) => (
                      <button
                        key={s.place_id}
                        type="button"
                        onClick={() => handleSelectSuggestion(s)}
                        className="w-full text-left px-4 py-3 hover:bg-primary-50 transition border-b border-gray-100 last:border-0"
                      >
                        <div className="flex items-start gap-2">
                          <FiMapPin className="w-4 h-4 text-primary-500 flex-shrink-0 mt-0.5" />
                          <span className="text-sm text-gray-700 line-clamp-2">{s.display_name}</span>
                        </div>
                      </button>
                    ))}
                  </div>
                )}
              </div>
            </div>

            {/* Capacity */}
            <div>
              <label htmlFor="capacity" className="block text-sm font-medium text-gray-700 mb-2">
                Capacité (optionnel)
              </label>
              <input
                type="number" id="capacity" min="1"
                value={formData.capacity}
                onChange={(e) => setFormData({ ...formData, capacity: e.target.value })}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                placeholder="Ex: 100"
              />
            </div>

            {/* Price */}
            <div>
              <div className="flex items-center gap-3 mb-4">
                <input type="checkbox" id="is_free" checked={formData.is_free}
                  onChange={(e) => setFormData({ ...formData, is_free: e.target.checked, price: '' })}
                  className="w-4 h-4 text-primary-600 rounded focus:ring-primary-500" />
                <label htmlFor="is_free" className="text-sm font-medium text-gray-700">Événement gratuit</label>
              </div>
              {!formData.is_free && (
                <div>
                  <label htmlFor="price" className="block text-sm font-medium text-gray-700 mb-2">Prix (FCFA)</label>
                  <input type="number" id="price" min="0" step="0.01"
                    value={formData.price}
                    onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    placeholder="Ex: 5000" />
                </div>
              )}
            </div>

            {/* Registration link */}
            <div>
              <label htmlFor="registration_link" className="block text-sm font-medium text-gray-700 mb-2">
                Lien d'inscription (optionnel)
              </label>
              <input type="url" id="registration_link"
                value={formData.registration_link}
                onChange={(e) => setFormData({ ...formData, registration_link: e.target.value })}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                placeholder="https://..." />
            </div>

            {/* Status */}
            <div>
              <label htmlFor="status" className="block text-sm font-medium text-gray-700 mb-2">Statut</label>
              <select id="status" value={formData.status}
                onChange={(e) => setFormData({ ...formData, status: e.target.value as 'draft' | 'published' })}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent">
                <option value="draft">Brouillon (non visible publiquement)</option>
                <option value="published">Publié (visible par tous)</option>
              </select>
            </div>

            {/* Submit */}
            <div className="flex gap-4 pt-6 border-t border-gray-200">
              <Link href="/events"
                className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition font-medium">
                Annuler
              </Link>
              <button type="submit" disabled={isSubmitting}
                className="flex-1 bg-primary-600 text-white py-3 rounded-lg hover:bg-primary-700 transition font-medium disabled:opacity-50 disabled:cursor-not-allowed">
                {isSubmitting ? 'Création en cours...' : 'Créer l\'événement'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  )
}