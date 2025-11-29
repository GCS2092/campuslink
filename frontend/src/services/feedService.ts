import api from './api'

export interface FeedItem {
  id: string
  author?: {
    id: string
    username: string
    first_name?: string
    last_name?: string
  }
  type?: 'event' | 'group' | 'announcement' | 'news' | 'feed'
  title?: string
  content?: string
  image?: string
  visibility?: 'public' | 'private'
  university?: string
  is_published?: boolean
  created_at?: string
  updated_at?: string
  // For personalized feed items
  event_data?: any
  feed_data?: any
}

export const feedService = {
  getFeedItems: async (params?: {
    type?: string
    university?: string
  }) => {
    const response = await api.get('/feed/', { params })
    // DRF may return paginated response with 'results' field
    // Return the data directly, let the caller handle pagination
    return response.data
  },

  getMyFeedItems: async () => {
    const response = await api.get('/feed/my_feed_items/')
    return response.data
  },

  getFeedItem: async (id: string) => {
    const response = await api.get(`/feed/${id}/`)
    return response.data
  },

  createFeedItem: async (data: {
    type: 'event' | 'group' | 'announcement' | 'news'
    title: string
    content: string
    image?: File | string
    visibility: 'public' | 'private'
    university?: string
  }) => {
    const formData = new FormData()
    formData.append('type', data.type)
    formData.append('title', data.title)
    formData.append('content', data.content)
    formData.append('visibility', data.visibility)
    if (data.university) {
      formData.append('university', data.university)
    }
    if (data.image) {
      if (data.image instanceof File) {
        formData.append('image', data.image)
      } else {
        formData.append('image', data.image)
      }
    }

    const response = await api.post('/feed/', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    })
    return response.data
  },

  updateFeedItem: async (id: string, data: {
    type?: 'event' | 'group' | 'announcement' | 'news'
    title?: string
    content?: string
    image?: File | string
    visibility?: 'public' | 'private'
    university?: string
    is_published?: boolean
  }) => {
    const formData = new FormData()
    if (data.type) formData.append('type', data.type)
    if (data.title) formData.append('title', data.title)
    if (data.content) formData.append('content', data.content)
    if (data.visibility) formData.append('visibility', data.visibility)
    if (data.university) formData.append('university', data.university)
    if (data.is_published !== undefined) formData.append('is_published', String(data.is_published))
    if (data.image) {
      if (data.image instanceof File) {
        formData.append('image', data.image)
      } else {
        formData.append('image', data.image)
      }
    }

    const response = await api.patch(`/feed/${id}/`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    })
    return response.data
  },

  deleteFeedItem: async (id: string) => {
    const response = await api.delete(`/feed/${id}/`)
    return response.data
  },

  getPersonalizedFeed: async () => {
    const response = await api.get('/feed/personalized/')
    return response.data
  },

  getFriendsActivity: async () => {
    const response = await api.get('/feed/friends_activity/')
    return response.data
  },
}

