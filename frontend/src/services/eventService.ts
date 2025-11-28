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
}

