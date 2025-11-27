import api from './api'

export interface DashboardStats {
  events_count: number
  groups_count: number
  messages_count: number
  notifications_count: number
  friends_count: number
}

export const statsService = {
  getDashboardStats: async (): Promise<DashboardStats> => {
    // We'll need to create an endpoint for this, but for now we can calculate from multiple endpoints
    try {
      const [eventsRes, groupsRes, messagesRes, notificationsRes, friendsRes] = await Promise.all([
        api.get('/events/', { params: { page_size: 1 } }).catch(() => ({ data: { count: 0 } })),
        api.get('/groups/', { params: { page_size: 1 } }).catch(() => ({ data: { count: 0 } })),
        api.get('/messaging/conversations/', { params: { page_size: 1 } }).catch(() => ({ data: { count: 0 } })),
        api.get('/notifications/', { params: { page_size: 1, unread_only: true } }).catch(() => ({ data: { count: 0 } })),
        api.get('/users/friends/').catch(() => ({ data: [] })),
      ])

      return {
        events_count: eventsRes.data?.count || 0,
        groups_count: groupsRes.data?.count || 0,
        messages_count: messagesRes.data?.count || 0,
        notifications_count: notificationsRes.data?.count || 0,
        friends_count: Array.isArray(friendsRes.data) ? friendsRes.data.length : 0,
      }
    } catch (error) {
      console.error('Error fetching stats:', error)
      return {
        events_count: 0,
        groups_count: 0,
        messages_count: 0,
        notifications_count: 0,
        friends_count: 0,
      }
    }
  },
}

