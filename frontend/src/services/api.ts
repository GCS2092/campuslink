import axios from 'axios'

// Auto-detect API URL based on environment
const getApiUrl = () => {
  // Priority 1: Use environment variable if set (from .env.local or Vercel environment variables)
  // This is the most reliable way for production deployments
  if (process.env.NEXT_PUBLIC_API_URL) {
    // Ensure the URL uses HTTPS in production (Vercel)
    const apiUrl = process.env.NEXT_PUBLIC_API_URL;
    
    // If we're on Vercel (HTTPS) and the API URL is HTTP, log a warning
    if (typeof window !== 'undefined' && window.location.protocol === 'https:' && apiUrl.startsWith('http://')) {
      console.warn('⚠️ Mixed content warning: API URL is HTTP but page is HTTPS. Please set NEXT_PUBLIC_API_URL to HTTPS in Vercel environment variables.');
    }
    
    return apiUrl;
  }
  
  if (typeof window !== 'undefined') {
    // In browser, use the current hostname
    const hostname = window.location.hostname;
    const protocol = window.location.protocol;
    
    // If accessing from localhost, use localhost for backend
    if (hostname === 'localhost' || hostname === '127.0.0.1') {
      return 'http://localhost:8000/api';
    }
    
    // If we're on HTTPS (production/Vercel), we MUST use HTTPS for the API
    // Don't construct HTTP URLs in production as it causes mixed content errors
    if (protocol === 'https:') {
      console.error('❌ NEXT_PUBLIC_API_URL is not set! Please configure it in Vercel environment variables.');
      // Return a placeholder that will fail gracefully
      return 'https://api-url-not-configured.com/api';
    }
    
    // For local network access (development on mobile/other devices), use HTTP
    // This is safe because the frontend is also on HTTP in this case
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
          // Check if error is due to inactive/unverified account
          const errorMessage = error.response?.data?.detail || error.response?.data?.message || ''
          if (errorMessage.includes('activé') || errorMessage.includes('vérifié') || errorMessage.includes('active') || errorMessage.includes('verified')) {
            // Account needs activation, redirect to pending-approval
            localStorage.removeItem('access_token')
            localStorage.removeItem('refresh_token')
            if (window.location.pathname !== '/pending-approval') {
              window.location.href = '/pending-approval'
            }
            return Promise.reject(error)
          }
          
          // Refresh failed for other reasons, logout user
          localStorage.removeItem('access_token')
          localStorage.removeItem('refresh_token')
          // Ne pas rediriger vers /login si on est déjà sur la page d'accueil ou en train de se déconnecter
          if (window.location.pathname !== '/login' && window.location.pathname !== '/') {
            window.location.href = '/login'
          }
          return Promise.reject(refreshError)
        }
      }
    }

    // Check if 401 is due to inactive/unverified account (even after retry)
    if (error.response?.status === 401) {
      const errorMessage = error.response?.data?.detail || error.response?.data?.message || ''
      if (errorMessage.includes('activé') || errorMessage.includes('vérifié') || errorMessage.includes('active') || errorMessage.includes('verified')) {
        // Account needs activation, redirect to pending-approval
        if (typeof window !== 'undefined' && window.location.pathname !== '/pending-approval' && window.location.pathname !== '/') {
          localStorage.removeItem('access_token')
          localStorage.removeItem('refresh_token')
          window.location.href = '/pending-approval'
        }
      }
      // Si on est sur la page d'accueil et qu'on a une erreur 401, ne pas rediriger vers /login
      // (cela peut arriver pendant la déconnexion)
      if (typeof window !== 'undefined' && window.location.pathname === '/') {
        return Promise.reject(error)
      }
    }

    return Promise.reject(error)
  }
)

export { api }
export default api

