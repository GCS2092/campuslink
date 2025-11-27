import api from './api'

export interface DashboardStats {
  pending_students_count: number
  active_students_count: number
  total_students_count: number
  events_count: number
  groups_count: number
  posts_count: number
  recent_registrations: Array<{
    id: string
    username: string
    email: string
    date_joined: string
    is_active: boolean
    is_verified: boolean
  }>
}

export const adminService = {
  getPendingStudents: async (params?: {
    university?: string
    search?: string
    verification_status?: string
    is_active?: string
    ordering?: string
    page?: number
    page_size?: number
  }) => {
    const response = await api.get('/users/admin/pending-students/', { params })
    return response.data
  },

  activateStudent: async (studentId: string) => {
    const response = await api.put(`/users/admin/students/${studentId}/activate/`)
    return response.data
  },

  deactivateStudent: async (studentId: string) => {
    const response = await api.put(`/users/admin/students/${studentId}/deactivate/`)
    return response.data
  },

  getDashboardStats: async (): Promise<DashboardStats> => {
    const response = await api.get('/users/admin/dashboard-stats/')
    return response.data
  },

  getClassLeaders: async (params?: {
    university?: string
    search?: string
    is_active?: boolean
    ordering?: string
    page?: number
    page_size?: number
  }) => {
    const response = await api.get('/users/admin/class-leaders/', { params })
    return response.data
  },

  getClassLeadersByUniversity: async () => {
    const response = await api.get('/users/admin/class-leaders/by-university/')
    return response.data
  },

  assignClassLeader: async (userId: string) => {
    const response = await api.put(`/users/admin/class-leaders/${userId}/assign/`)
    return response.data
  },

  revokeClassLeader: async (userId: string) => {
    const response = await api.put(`/users/admin/class-leaders/${userId}/revoke/`)
    return response.data
  },

  // User verification and banning
  verifyUser: async (userId: string) => {
    const response = await api.post(`/users/admin/users/${userId}/verify/`)
    return response.data
  },

  rejectUser: async (userId: string, data: { reason?: string; message?: string }) => {
    const response = await api.post(`/users/admin/users/${userId}/reject/`, data)
    return response.data
  },

  banUser: async (userId: string, data: { ban_type: 'permanent' | 'temporary'; reason: string; banned_until?: string }) => {
    const response = await api.post(`/users/admin/users/${userId}/ban/`, data)
    return response.data
  },

  unbanUser: async (userId: string) => {
    const response = await api.post(`/users/admin/users/${userId}/unban/`)
    return response.data
  },

  getPendingVerifications: async () => {
    const response = await api.get('/users/admin/users/pending-verifications/')
    return response.data
  },

  getBannedUsers: async () => {
    const response = await api.get('/users/admin/users/banned/')
    return response.data
  },
}

