'use client'

import { useState, useRef } from 'react'
import { useRouter } from 'next/navigation'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import Link from 'next/link'
import { useAuth } from '@/context/AuthContext'
import { authService } from '@/services/authService'
import toast from 'react-hot-toast'

const loginSchema = z.object({
  email: z.string().email('Email invalide'),
  password: z.string().min(1, 'Le mot de passe est requis'),
})

type LoginFormData = z.infer<typeof loginSchema>

export default function LoginPage() {
  const router = useRouter()
  const { login, refreshUser } = useAuth()
  const [isLoading, setIsLoading] = useState(false)
  const [lockoutMessage, setLockoutMessage] = useState<string | null>(null)
  const submitInProgress = useRef(false)

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  })

  const onSubmit = async (data: LoginFormData) => {
    if (submitInProgress.current) return
    submitInProgress.current = true
    setIsLoading(true)
    setLockoutMessage(null)

    try {
      // Appeler directement authService.login pour avoir accès à account_status
      const result = await authService.login({ email: data.email, password: data.password })
      
      // Vérifier si le compte nécessite une activation
      if (result?.account_status?.requires_activation) {
        toast('⏳ Votre compte est en attente de validation.', { duration: 4000, icon: '⏳' })
        // Rediriger vers la page d'attente
        setTimeout(() => {
          router.push('/pending-approval')
        }, 1000)
        return
      }
      
      // Si le compte est activé, charger le profil
      // Le token est déjà stocké par authService.login()
      try {
        await refreshUser()
      } catch (refreshError) {
        // Si refreshUser échoue, ce n'est pas grave, on a déjà le token
        console.log('Profile refresh skipped, but login successful')
      }
      toast.success('Connexion réussie!')
      router.push('/dashboard')
    } catch (error: any) {
      // Gérer le verrouillage de compte
      if (error.response?.status === 423) {
        const errorData = error.response.data?.error
        if (errorData) {
          const minutes = errorData.lockout_remaining_minutes || 0
          const message = `Compte verrouillé. Réessayez dans ${minutes} minute${minutes > 1 ? 's' : ''}.`
          setLockoutMessage(message)
          toast.error(message, { duration: 5000 })
        } else {
          const message = 'Compte temporairement verrouillé. Réessayez plus tard.'
          setLockoutMessage(message)
          toast.error(message, { duration: 5000 })
        }
      } else if (error.response?.status === 403) {
        // Compte banni
        const errorData = error.response.data?.error
        const message = errorData?.message || 'Votre compte a été banni.'
        toast.error(`🚫 ${message}`, { duration: 5000 })
      } else if (error.response?.status === 429) {
        const detail = error.response?.data?.detail
        const message = typeof detail === 'string' ? detail : 'Trop de tentatives de connexion. Réessayez dans quelques minutes.'
        setLockoutMessage(message)
        toast.error(`⏳ ${message}`, { duration: 6000 })
      } else if (error.response?.status === 401) {
        const message = '❌ Email ou mot de passe incorrect. Vérifiez vos identifiants et réessayez.'
        toast.error(message, { duration: 4000 })
      } else if (error.response?.status === 400) {
        const errorMessage = error.response?.data?.detail || error.response?.data?.message || 'Données invalides. Vérifiez le format de votre email.'
        toast.error(`⚠️ ${errorMessage}`, { duration: 4000 })
      } else if (error.response?.status === 500) {
        toast.error('🔧 Erreur serveur. Veuillez réessayer dans quelques instants.', { duration: 4000 })
      } else if (error.message === 'Network Error' || !error.response) {
        toast.error('🌐 Problème de connexion. Vérifiez votre connexion internet.', { duration: 4000 })
      } else {
        const message = error.response?.data?.detail || error.response?.data?.message || 'Erreur de connexion. Veuillez réessayer.'
        toast.error(`⚠️ ${message}`, { duration: 4000 })
      }
    } finally {
      setIsLoading(false)
      submitInProgress.current = false
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 to-secondary-50 dark:from-gray-900 dark:to-gray-800 px-4">
      <div className="max-w-md w-full bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-8 border border-gray-200 dark:border-gray-700">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">Connexion</h1>
          <p className="text-gray-600 dark:text-gray-300">Connectez-vous à votre compte CampusLink</p>
        </div>

        {lockoutMessage && (
          <div className="mb-6 p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg">
            <div className="flex items-start gap-3">
              <span className="text-xl">🔒</span>
              <div>
                <p className="text-sm font-semibold text-red-800 dark:text-red-300 mb-1">Compte verrouillé</p>
                <p className="text-sm text-red-700 dark:text-red-400">{lockoutMessage}</p>
              </div>
            </div>
          </div>
        )}

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          <div>
            <label htmlFor="email" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Email universitaire
            </label>
            <input
              {...register('email')}
              type="email"
              id="email"
              className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none transition bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500"
              placeholder="exemple@esmt.sn"
              disabled={isLoading}
            />
            {errors.email && (
              <div className="mt-2 p-2 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded flex items-start gap-2">
                <span className="text-red-600 dark:text-red-400">⚠️</span>
                <p className="text-sm text-red-600 dark:text-red-400">{errors.email.message}</p>
              </div>
            )}
          </div>

          <div>
            <label htmlFor="password" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Mot de passe
            </label>
            <input
              {...register('password')}
              type="password"
              id="password"
              className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none transition bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500"
              placeholder="••••••••"
              disabled={isLoading}
            />
            {errors.password && (
              <div className="mt-2 p-2 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded flex items-start gap-2">
                <span className="text-red-600 dark:text-red-400">⚠️</span>
                <p className="text-sm text-red-600 dark:text-red-400">{errors.password.message}</p>
              </div>
            )}
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className="w-full bg-primary-600 dark:bg-primary-500 text-white py-3 rounded-lg font-semibold hover:bg-primary-700 dark:hover:bg-primary-600 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 dark:focus:ring-offset-gray-800 transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            {isLoading ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                <span>Connexion...</span>
              </>
            ) : (
              'Se connecter'
            )}
          </button>
        </form>

        <div className="mt-6 text-center">
          <p className="text-sm text-gray-600 dark:text-gray-400">
            Pas encore de compte?{' '}
            <Link href="/register" className="text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300 font-semibold">
              S&apos;inscrire
            </Link>
          </p>
        </div>
      </div>
    </div>
  )
}

