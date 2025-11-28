import axios from 'axios'

// Auto-detect API URL based on environment
const getApiUrl = () => {
  // Priority 1: Use environment variable if set (from auto-config.js or .env.local)
  if (process.env.NEXT_PUBLIC_API_URL) {
    return process.env.NEXT_PUBLIC_API_URL;
  }
  
  if (typeof window !== 'undefined') {
    // In browser, use the current hostname
    const hostname = window.location.hostname;
    const protocol = window.location.protocol;
    
    // If accessing from localhost, use localhost for backend
    if (hostname === 'localhost' || hostname === '127.0.0.1') {
      return 'http://localhost:8000/api';
    }
    
    // For network access (mobile, other devices), use the same hostname but port 8000
    // This allows the frontend and backend to be on the same machine
    // Use http:// even if frontend is https:// (for local development)
    return `http://${hostname}:8000/api`;
  }
  
  // Server-side default - try to use environment variable or fallback
  return process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api';
};

const api = axios.create({
  baseURL: getApiUrl(),
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
            const baseURL = getApiUrl()
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

