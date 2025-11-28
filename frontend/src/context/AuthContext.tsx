'use client'

import React, { createContext, useContext, useState, useEffect, useCallback } from 'react'
import { authService } from '@/services/authService'

interface User {
  id: string
  email: string
  username: string
  first_name?: string
  last_name?: string
  role?: string
  phone_number?: string
  is_verified: boolean
  verification_status: string
  is_active?: boolean
  profile?: any
}

interface AuthContextType {
  user: User | null
  loading: boolean
  login: (email: string, password: string) => Promise<void>
  logout: () => void
  refreshUser: () => Promise<void>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  const refreshUser = useCallback(async () => {
    try {
      const userData = await authService.getProfile()
      setUser(userData)
    } catch (error) {
      console.error('Error fetching user:', error)
      authService.logout()
      setUser(null)
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    // Check if user is logged in on mount
    if (typeof window !== 'undefined') {
      const token = localStorage.getItem('access_token')
      if (token) {
        refreshUser()
      } else {
        setLoading(false)
      }
    } else {
      setLoading(false)
    }
  }, [refreshUser])

  const login = async (email: string, password: string) => {
    const result = await authService.login({ email, password })
    
    // Si le compte nécessite une activation, ne pas appeler refreshUser
    // car cela échouera (l'utilisateur n'est pas actif)
    if (result?.account_status?.requires_activation) {
      // Retourner le résultat avec account_status pour que la page de login puisse gérer la redirection
      return result
    }
    
    // Sinon, charger le profil normalement
    await refreshUser()
    return result
  }

  const logout = () => {
    authService.logout()
    setUser(null)
  }

  return (
    <AuthContext.Provider value={{ user, loading, login, logout, refreshUser }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    // Return a default context instead of throwing to prevent crashes
    return {
      user: null,
      loading: true,
      login: async () => {},
      logout: () => {},
      refreshUser: async () => {},
    }
  }
  return context
}

