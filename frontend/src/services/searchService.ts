import api from './api'

export interface SearchResult {
  query: string
  users: Array<{
    id: string
    username: string
    email: string
    first_name?: string
    last_name?: string
    profile?: any
  }>
  events: Array<{
    id: string
    title: string
    description: string
    start_date: string
    location: string
    organizer: any
    participants_count: number
  }>
  groups: Array<{
    id: string
    name: string
    description: string
    members_count: number
    creator: any
  }>
  total: number
  counts: {
    users: number
    events: number
    groups: number
  }
}

export const searchService = {
  globalSearch: async (query: string, type?: 'all' | 'users' | 'events' | 'groups', limit?: number): Promise<SearchResult> => {
    const params: any = { q: query }
    if (type && type !== 'all') {
      params.type = type
    }
    if (limit) {
      params.limit = limit
    }
    const response = await api.get('/search/', { params })
    return response.data
  },
}

