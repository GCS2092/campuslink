import axios from 'axios'

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api',
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    if (typeof window !== 'undefined') {
      const token = localStorage.getItem('access_token')
      if (token) {
        config.headers.Authorization = `Bearer ${token}`
      }
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response interceptor to handle errors
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config

    // If 401 and not already retried, try to refresh token
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true

      if (typeof window !== 'undefined') {
        try {
          const refreshToken = localStorage.getItem('refresh_token')
          if (refreshToken) {
            const baseURL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api'
            const response = await axios.post(
              `${baseURL}/auth/token/refresh/`,
              { refresh: refreshToken }
            )
            const { access } = response.data
            localStorage.setItem('access_token', access)
            originalRequest.headers.Authorization = `Bearer ${access}`
            return api(originalRequest)
          }
        } catch (refreshError) {
          // Refresh failed, logout user
          localStorage.removeItem('access_token')
          localStorage.removeItem('refresh_token')
          window.location.href = '/login'
          return Promise.reject(refreshError)
        }
      }
    }

    return Promise.reject(error)
  }
)

export { api }
export default api

