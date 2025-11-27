import api from './api'

export interface GroupInfo {
  id: string
  name: string
  slug: string
  profile_image?: string
}

export interface Conversation {
  id: string
  conversation_type: 'private' | 'group'
  name?: string
  group?: GroupInfo
  created_by: {
    id: string
    username: string
    email: string
  }
  created_at: string
  updated_at: string
  last_message_at?: string
  participants?: Participant[]
  last_message?: Message
  unread_count?: number
}

export interface Participant {
  id: string
  user: {
    id: string
    username: string
    email: string
  }
  joined_at: string
  is_active: boolean
  unread_count: number
}

export interface Message {
  id: string
  conversation: string
  sender: {
    id: string
    username: string
    email: string
  }
  content: string
  message_type: string
  is_read: boolean
  created_at: string
  edited_at?: string
}

export interface BroadcastResponse {
  message: string
  conversations: Array<{
    conversation_id: string
    user_id: string
    username: string
  }>
}

export const messagingService = {
  getConversations: async (type?: 'private' | 'group') => {
    const params = type ? { type } : {}
    const response = await api.get('/messaging/conversations/', { params })
    return response.data
  },

  getConversation: async (id: string) => {
    const response = await api.get(`/messaging/conversations/${id}/`)
    return response.data
  },

  getGroupConversation: async (groupId: string) => {
    const response = await api.get('/messaging/conversations/group_conversation/', {
      params: { group_id: groupId },
    })
    return response.data
  },

  createPrivateConversation: async (userId: string) => {
    const response = await api.post('/messaging/conversations/create_private/', {
      user_id: userId,
    })
    return response.data
  },

  getMessages: async (conversationId: string) => {
    const response = await api.get('/messaging/messages/', {
      params: { conversation: conversationId },
    })
    return response.data
  },

  sendMessage: async (conversationId: string, content: string) => {
    const response = await api.post('/messaging/messages/', {
      conversation: conversationId,
      content,
      message_type: 'text',
    })
    return response.data
  },

  broadcastMessage: async (data: {
    content: string
    type: 'all' | 'university' | 'class'
    university?: string
    field_of_study?: string
    academic_year?: string
  }): Promise<BroadcastResponse> => {
    const response = await api.post('/messaging/messages/broadcast/', data)
    return response.data
  },
}

