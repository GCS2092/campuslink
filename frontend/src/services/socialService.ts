/**
 * Social service for personal posts.
 */
import api from './api'

export interface Post {
  id: string
  author: {
    id: string
    username: string
    first_name?: string
    last_name?: string
    profile?: {
      profile_picture?: string
    }
  }
  content: string
  post_type: 'text' | 'image' | 'video'
  image_url?: string
  video_url?: string
  is_public: boolean
  likes_count: number
  comments_count: number
  shares_count: number
  is_liked?: boolean
  created_at: string
  updated_at: string
}

export interface PostComment {
  id: string
  user: {
    id: string
    username: string
    first_name?: string
    last_name?: string
    profile?: {
      profile_picture?: string
    }
  }
  content: string
  created_at: string
  updated_at: string
}

export const socialService = {
  // Get all posts
  getPosts: async (params?: {
    post_type?: 'text' | 'image' | 'video'
    is_public?: boolean
    search?: string
    ordering?: string
    page?: number
    page_size?: number
  }) => {
    const response = await api.get('/social/posts/', { params })
    return response.data
  },

  // Get a single post
  getPost: async (id: string) => {
    const response = await api.get(`/social/posts/${id}/`)
    return response.data
  },

  // Create a post
  createPost: async (data: {
    content: string
    post_type?: 'text' | 'image' | 'video'
    image_url?: string
    video_url?: string
    is_public?: boolean
  }) => {
    const response = await api.post('/social/posts/', data)
    return response.data
  },

  // Update a post
  updatePost: async (id: string, data: {
    content?: string
    post_type?: 'text' | 'image' | 'video'
    image_url?: string
    video_url?: string
    is_public?: boolean
  }) => {
    const response = await api.patch(`/social/posts/${id}/`, data)
    return response.data
  },

  // Delete a post
  deletePost: async (id: string) => {
    const response = await api.delete(`/social/posts/${id}/`)
    return response.data
  },

  // Like a post
  likePost: async (id: string) => {
    const response = await api.post(`/social/posts/${id}/like/`)
    return response.data
  },

  // Unlike a post
  unlikePost: async (id: string) => {
    const response = await api.delete(`/social/posts/${id}/unlike/`)
    return response.data
  },

  // Get comments for a post
  getPostComments: async (postId: string) => {
    const response = await api.get(`/social/posts/${postId}/comments/`)
    return response.data
  },

  // Add a comment to a post
  addComment: async (postId: string, content: string) => {
    const response = await api.post(`/social/posts/${postId}/comments/`, { content })
    return response.data
  },

  // Share a post
  sharePost: async (id: string) => {
    const response = await api.post(`/social/posts/${id}/share/`)
    return response.data
  },
}

