import api from './api'

export interface User {
  id: string
  email: string
  username: string
  first_name?: string
  last_name?: string
  role?: string
  phone_number?: string
  phone_verified: boolean
  is_verified: boolean
  verification_status: string
  date_joined: string
  last_login?: string
  profile?: any
}

export interface FriendshipStatus {
  status: 'none' | 'friends' | 'request_sent' | 'request_received' | 'rejected'
}

export const userService = {
  getUsers: async (params?: {
    verified_only?: boolean
    university?: string
    search?: string
    page?: number
    page_size?: number
  }) => {
    const response = await api.get('/users/', { params })
    return response.data
  },

  getUser: async (id: string) => {
    const response = await api.get(`/users/${id}/`)
    return response.data
  },

  getFriends: async () => {
    const response = await api.get('/users/friends/')
    return response.data
  },

  sendFriendRequest: async (to_user_id: string) => {
    const response = await api.post('/users/friends/request/', { to_user_id })
    return response.data
  },

  acceptFriendRequest: async (friendship_id: string) => {
    const response = await api.put(`/users/friends/${friendship_id}/accept/`)
    return response.data
  },

  rejectFriendRequest: async (friendship_id: string) => {
    const response = await api.put(`/users/friends/${friendship_id}/reject/`)
    return response.data
  },

  removeFriend: async (friendship_id: string) => {
    const response = await api.delete(`/users/friends/${friendship_id}/`)
    return response.data
  },

  getFriendRequests: async () => {
    const response = await api.get('/users/friends/requests/')
    return response.data
  },

  getFriendshipStatus: async (user_id: string): Promise<FriendshipStatus> => {
    const response = await api.get(`/users/friends/status/${user_id}/`)
    return response.data
  },
}

