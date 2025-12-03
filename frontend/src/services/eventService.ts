import api from './api'

export interface Event {
  id: string
  title: string
  description: string
  organizer: {
    id: string
    username: string
    first_name?: string
    last_name?: string
    profile?: {
      university?: string | {
        id: string
        name: string
        short_name?: string
      }
    }
  }
  category?: {
    id: string
    name: string
  }
  start_date: string
  end_date?: string
  location: string
  location_lat?: number | string | null
  location_lng?: number | string | null
  image?: string | {
    url: string
  }
  image_url?: string
  capacity?: number
  price: number
  is_free: boolean
  status: 'draft' | 'published' | 'cancelled' | 'completed'
  is_featured: boolean
  views_count: number
  participants_count: number
  participants?: Array<{
    id: string
    username: string
    first_name?: string
    last_name?: string
  }>
  is_participating?: boolean
  is_liked?: boolean
  likes_count: number
  created_at: string
  updated_at: string
}

export const eventService = {
  getEvents: async (params?: {
    category?: string
    status?: string
    university?: string
    date_from?: string
    date_to?: string
    search?: string
    ordering?: string
    page?: number
    page_size?: number
    is_free?: boolean
    price_min?: number
    price_max?: number
    lat?: number
    lng?: number
    radius?: number
  }) => {
    const response = await api.get('/events/', { params })
    return response.data
  },

  getEvent: async (id: string) => {
    const response = await api.get(`/events/${id}/`)
    return response.data
  },

  getCategories: async () => {
    const response = await api.get('/events/categories/')
    return response.data
  },

  createEvent: async (eventData: any) => {
    const response = await api.post('/events/', eventData)
    return response.data
  },

  moderateEvent: async (eventId: string, action: 'delete' | 'publish' | 'cancel' | 'draft') => {
    const response = await api.post(`/events/${eventId}/moderate/`, { action })
    return response.data
  },

  joinEvent: async (eventId: string) => {
    const response = await api.post(`/events/${eventId}/participate/`)
    return response.data
  },

  leaveEvent: async (eventId: string) => {
    const response = await api.delete(`/events/${eventId}/leave/`)
    return response.data
  },

  getMyEvents: async (type?: 'all' | 'organized' | 'participating' | 'favorites') => {
    const params = type && type !== 'all' ? { type } : {}
    const response = await api.get('/events/my_events/', { params })
    return response.data
  },

  getFavorites: async () => {
    const response = await api.get('/events/favorites/')
    return response.data
  },

  getCalendarEvents: async (startDate?: string, endDate?: string) => {
    const params: any = {}
    if (startDate) params.start_date = startDate
    if (endDate) params.end_date = endDate
    const response = await api.get('/events/calendar/events/', { params })
    return response.data
  },

  exportCalendar: async (includeFavorites: boolean = true) => {
    const response = await api.get('/events/calendar/export/', {
      params: { include_favorites: includeFavorites },
      responseType: 'blob'
    })
    return response.data
  },

  getRecommendedEvents: async (limit: number = 10) => {
    const response = await api.get('/events/recommended/', { params: { limit } })
    return response.data
  },

  getShareLinks: async (eventId: string) => {
    const response = await api.get(`/events/${eventId}/share/`)
    return response.data
  },

  trackShare: async (eventId: string, platform: string) => {
    const response = await api.post(`/events/${eventId}/share/`, { platform })
    return response.data
  },

  // Map events with geolocation
  getMapEvents: async (params?: {
    lat?: number
    lng?: number
    radius?: number
  }) => {
    const response = await api.get('/events/map_events/', { params })
    return response.data
  },

  // Filter preferences
  getFilterPreferences: async () => {
    const response = await api.get('/events/filter-preferences/')
    return response.data
  },

  getDefaultFilterPreference: async () => {
    const response = await api.get('/events/filter-preferences/default/')
    return response.data
  },

  saveFilterPreference: async (data: {
    name: string
    filters: Record<string, any>
    is_default?: boolean
  }) => {
    const response = await api.post('/events/filter-preferences/', data)
    return response.data
  },

  updateFilterPreference: async (id: string, data: {
    name?: string
    filters?: Record<string, any>
    is_default?: boolean
  }) => {
    const response = await api.patch(`/events/filter-preferences/${id}/`, data)
    return response.data
  },

  deleteFilterPreference: async (id: string) => {
    const response = await api.delete(`/events/filter-preferences/${id}/`)
    return response.data
  },

  // Clear event history
  clearEventHistory: async (clearAll: boolean = false) => {
    const response = await api.delete('/events/calendar/clear_history/', {
      params: { clear_all: clearAll }
    })
    return response.data
  },
}

