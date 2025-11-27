/**
 * Moderation service for admin content moderation.
 */
import api from './api'

export interface Report {
  id: string
  reporter: {
    id: string
    username: string
    email: string
  }
  content_type: string
  content_id: string
  reason: 'spam' | 'harassment' | 'inappropriate' | 'fake' | 'other'
  description: string
  status: 'pending' | 'reviewed' | 'resolved' | 'dismissed'
  reviewed_by?: {
    id: string
    username: string
  }
  reviewed_at?: string
  created_at: string
}

export interface AuditLog {
  id: string
  user?: {
    id: string
    username: string
    email: string
  }
  action_type: string
  resource_type: string
  resource_id?: string
  ip_address?: string
  user_agent?: string
  details: Record<string, any>
  created_at: string
}

export const moderationService = {
  // Reports
  getReports: async (params?: {
    status?: 'pending' | 'reviewed' | 'resolved' | 'dismissed'
    content_type?: string
    page?: number
    page_size?: number
  }) => {
    const response = await api.get('/moderation/admin/reports/', { params })
    return response.data
  },

  resolveReport: async (reportId: string, data: { action_taken?: string; notes?: string }) => {
    const response = await api.post(`/moderation/admin/reports/${reportId}/resolve/`, data)
    return response.data
  },

  dismissReport: async (reportId: string, data: { reason?: string }) => {
    const response = await api.post(`/moderation/admin/reports/${reportId}/dismiss/`, data)
    return response.data
  },

  // Audit Logs
  getAuditLogs: async (params?: {
    user_id?: string
    action_type?: string
    resource_type?: string
    date_from?: string
    date_to?: string
    page?: number
    page_size?: number
  }) => {
    const response = await api.get('/moderation/admin/audit-log/', { params })
    return response.data
  },

  // Post moderation
  moderatePost: async (postId: string, data: { action: 'delete' | 'hide' | 'unhide' | 'approve'; reason?: string }) => {
    const response = await api.post(`/moderation/admin/moderate/post/${postId}/`, data)
    return response.data
  },

  // Feed item moderation
  moderateFeedItem: async (feedItemId: string, data: { action: 'delete' | 'hide' | 'unhide' | 'approve'; reason?: string }) => {
    const response = await api.post(`/moderation/admin/moderate/feed-item/${feedItemId}/`, data)
    return response.data
  },

  // Comment moderation
  moderateComment: async (commentId: string, data: { reason?: string }) => {
    const response = await api.post(`/moderation/admin/moderate/comment/${commentId}/`, data)
    return response.data
  },
}

