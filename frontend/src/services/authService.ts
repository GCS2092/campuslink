import api from './api'

export interface RegisterData {
  email: string
  username: string
  password: string
  password_confirm: string
  first_name?: string
  last_name?: string
  role?: string
  phone_number: string
}

export interface LoginData {
  email: string
  password: string
}

export interface VerifyPhoneData {
  phone_number: string
  otp_code: string
}

export const authService = {
  register: async (data: RegisterData) => {
    const response = await api.post('/auth/register/', data)
    return response.data
  },

  login: async (data: LoginData) => {
    const response = await api.post('/auth/login/', data)
    const { access, refresh } = response.data
    if (typeof window !== 'undefined') {
      localStorage.setItem('access_token', access)
      localStorage.setItem('refresh_token', refresh)
    }
    return response.data
  },

  logout: () => {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('access_token')
      localStorage.removeItem('refresh_token')
    }
  },

  getProfile: async () => {
    const response = await api.get('/auth/profile/')
    return response.data
  },

  verifyPhone: async (data: VerifyPhoneData) => {
    const response = await api.post('/auth/verify-phone/confirm/', data)
    return response.data
  },

  getVerificationStatus: async () => {
    const response = await api.get('/auth/verification-status/')
    return response.data
  },

  resendOTP: async (phone_number: string) => {
    const response = await api.post('/auth/verify-phone/', { phone_number })
    return response.data
  },
}

