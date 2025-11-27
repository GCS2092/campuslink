import api from './api'

export interface Group {
  id: string
  name: string
  slug: string
  description: string
  cover_image?: string
  profile_image?: string
  creator: any
  university?: string
  category?: string
  is_public: boolean
  is_verified: boolean
  members_count: number
  posts_count: number
  events_count: number
  created_at: string
  updated_at: string
}

export const groupService = {
  getGroups: async (params?: {
    university?: string
    category?: string
    is_public?: boolean
    search?: string
    page?: number
    page_size?: number
  }) => {
    const response = await api.get('/groups/', { params })
    return response.data
  },

  getGroup: async (id: string) => {
    const response = await api.get(`/groups/${id}/`)
    return response.data
  },

  createGroup: async (data: {
    name: string
    description: string
    university?: string
    category?: string
    is_public?: boolean
    cover_image?: string
    profile_image?: string
  }) => {
    const response = await api.post('/groups/', data)
    return response.data
  },

  joinGroup: async (id: string) => {
    const response = await api.post(`/groups/${id}/join/`)
    return response.data
  },

  leaveGroup: async (id: string) => {
    const response = await api.post(`/groups/${id}/leave/`)
    return response.data
  },

  inviteUsers: async (groupId: string, userIds: string[]) => {
    const response = await api.post(`/groups/${groupId}/invite/`, {
      user_ids: userIds,
    })
    return response.data
  },

  acceptInvitation: async (groupId: string) => {
    const response = await api.post(`/groups/${groupId}/accept_invitation/`)
    return response.data
  },

  rejectInvitation: async (groupId: string) => {
    const response = await api.post(`/groups/${groupId}/reject_invitation/`)
    return response.data
  },

  getMyInvitations: async () => {
    const response = await api.get('/groups/my_invitations/')
    return response.data
  },

  moderateGroup: async (groupId: string, action: 'delete' | 'verify' | 'unverify') => {
    const response = await api.post(`/groups/${groupId}/moderate/`, { action })
    return response.data
  },
}

