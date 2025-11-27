import api from './api'

export interface Notification {
  id: string
  notification_type: string
  title: string
  message: string
  is_read: boolean
  related_object_type?: string
  related_object_id?: string
  created_at: string
}

export interface UnreadCount {
  unread_count: number
}

export const notificationService = {
  getNotifications: async (params?: { is_read?: boolean; page?: number; page_size?: number }) => {
    const response = await api.get('/notifications/', { params })
    return response.data
  },

  getNotification: async (id: string) => {
    const response = await api.get(`/notifications/${id}/`)
    return response.data
  },

  getUnreadCount: async (): Promise<number> => {
    const response = await api.get<UnreadCount>('/notifications/unread_count/')
    return response.data.unread_count
  },

  markAsRead: async (id: string) => {
    const response = await api.put(`/notifications/${id}/read/`)
    return response.data
  },

  markAllAsRead: async () => {
    const response = await api.put('/notifications/read_all/')
    return response.data
  },
}

