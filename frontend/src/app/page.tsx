'use client'

import Link from 'next/link'
import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiUsers, FiCalendar, FiMessageSquare, FiBell, FiArrowRight, FiZap, FiHeart } from 'react-icons/fi'

export default function Home() {
  const { user, loading } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [hoveredFeature, setHoveredFeature] = useState<number | null>(null)

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && user) {
      router.push('/dashboard')
    }
  }, [mounted, user, loading, router])

  if (!mounted || loading) {
    return (
      <main className="flex min-h-screen flex-col items-center justify-center p-24">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Chargement...</p>
        </div>
      </main>
    )
  }

  if (user) {
    return (
      <main className="flex min-h-screen flex-col items-center justify-center p-24">
        <div className="text-center">
          <p className="text-gray-600">Redirection...</p>
        </div>
      </main>
    )
  }

  const features = [
    { icon: FiUsers, title: 'Réseau Social', color: 'from-blue-500 to-blue-600' },
    { icon: FiCalendar, title: 'Événements', color: 'from-purple-500 to-purple-600' },
    { icon: FiMessageSquare, title: 'Messages', color: 'from-green-500 to-green-600' },
    { icon: FiBell, title: 'Actualités', color: 'from-orange-500 to-orange-600' },
  ]

  return (
    <main className="min-h-screen bg-gradient-to-br from-primary-50 via-white to-secondary-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 overflow-hidden">
      {/* Hero Section - Interactive */}
      <div className="relative min-h-screen flex items-center justify-center px-4 sm:px-6 lg:px-8">
        {/* Animated Background Elements */}
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <div className="absolute top-20 left-10 w-72 h-72 bg-primary-200 dark:bg-primary-900/30 rounded-full mix-blend-multiply dark:mix-blend-normal filter blur-xl opacity-30 animate-blob"></div>
          <div className="absolute top-40 right-10 w-72 h-72 bg-secondary-200 dark:bg-secondary-900/30 rounded-full mix-blend-multiply dark:mix-blend-normal filter blur-xl opacity-30 animate-blob animation-delay-2000"></div>
          <div className="absolute -bottom-8 left-1/2 w-72 h-72 bg-purple-200 dark:bg-purple-900/30 rounded-full mix-blend-multiply dark:mix-blend-normal filter blur-xl opacity-30 animate-blob animation-delay-4000"></div>
        </div>

        <div className="relative z-10 max-w-5xl mx-auto text-center">
          {/* Main Title */}
          <div className="mb-6">
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold mb-3 tracking-tight">
              <span className="block text-gray-900 dark:text-white">Bienvenue sur</span>
              <span className="block text-transparent bg-clip-text bg-gradient-to-r from-primary-600 via-purple-600 to-secondary-600">
                CampusLink
              </span>
            </h1>
            <p className="text-lg sm:text-xl text-gray-600 dark:text-gray-400 mt-4">
              Connecte ton campus en un clic
            </p>
          </div>

          {/* Features - compact grid */}
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 sm:gap-4 mb-10 max-w-2xl mx-auto">
            {features.map((feature, index) => {
              const Icon = feature.icon
              const isHovered = hoveredFeature === index
              return (
                <div
                  key={index}
                  onMouseEnter={() => setHoveredFeature(index)}
                  onMouseLeave={() => setHoveredFeature(null)}
                  className={`
                    group relative bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-xl p-4
                    cursor-pointer transition-all duration-200
                    ${isHovered ? 'shadow-lg -translate-y-0.5 ring-2 ring-primary-400/50 dark:ring-primary-500/50' : 'shadow-md hover:shadow-lg'}
                    border border-gray-200/80 dark:border-gray-700/80
                  `}
                >
                  <div className={`
                    w-10 h-10 mx-auto mb-2 rounded-lg flex items-center justify-center
                    bg-gradient-to-br ${feature.color} transition-transform duration-200
                    ${isHovered ? 'scale-105' : ''}
                  `}>
                    <Icon className="w-5 h-5 text-white" />
                  </div>
                  <h3 className="text-xs sm:text-sm font-semibold text-gray-700 dark:text-gray-200">
                    {feature.title}
                  </h3>
                </div>
              )
            })}
          </div>

          {/* CTA Buttons */}
          <div className="flex flex-col sm:flex-row gap-3 justify-center items-center">
            <Link
              href="/register"
              className="group inline-flex items-center gap-2 px-6 py-3.5 bg-gradient-to-r from-primary-600 to-secondary-600 text-white rounded-xl font-semibold text-base shadow-lg hover:shadow-primary-500/40 transition-all duration-200 hover:opacity-95"
            >
              Commencer maintenant
              <FiArrowRight className="w-4 h-4 group-hover:translate-x-0.5 transition-transform" />
            </Link>
            <Link
              href="/login"
              className="inline-flex items-center px-6 py-3.5 bg-white dark:bg-gray-800 text-primary-600 dark:text-primary-400 border border-primary-500 dark:border-primary-500 rounded-xl font-semibold text-base shadow-md hover:shadow-lg transition-all duration-200"
            >
              Se connecter
            </Link>
          </div>

          {/* Quick Stats */}
          <div className="mt-10 flex flex-wrap justify-center gap-6 sm:gap-8">
            <div className="flex items-center gap-1.5 text-sm text-gray-500 dark:text-gray-400">
              <FiUsers className="w-4 h-4 text-primary-500 dark:text-primary-400" />
              <span className="font-medium">Communauté</span>
            </div>
            <div className="flex items-center gap-1.5 text-sm text-gray-500 dark:text-gray-400">
              <FiZap className="w-4 h-4 text-amber-500 dark:text-amber-400" />
              <span className="font-medium">Temps réel</span>
            </div>
            <div className="flex items-center gap-1.5 text-sm text-gray-500 dark:text-gray-400">
              <FiHeart className="w-4 h-4 text-rose-500 dark:text-rose-400" />
              <span className="font-medium">100% Gratuit</span>
            </div>
          </div>
        </div>

        {/* Scroll hint */}
        <div className="absolute bottom-6 left-1/2 -translate-x-1/2 text-gray-400 dark:text-gray-500">
          <div className="w-5 h-8 border-2 border-current rounded-full flex justify-center pt-1.5">
            <div className="w-1 h-2 bg-current rounded-full" />
          </div>
        </div>
      </div>

      {/* CTA Section */}
      <div className="relative py-12 sm:py-16 bg-gradient-to-r from-primary-600 via-purple-600 to-secondary-600 dark:from-primary-700 dark:via-purple-700 dark:to-secondary-700">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-2xl sm:text-3xl font-bold text-white mb-3">
            Prêt à commencer ?
          </h2>
          <p className="text-base text-white/90 dark:text-white/80 mb-6">
            Rejoins la communauté étudiante en quelques secondes
          </p>
          <Link
            href="/register"
            className="inline-flex items-center gap-2 px-6 py-3 bg-white dark:bg-gray-800 text-primary-600 dark:text-primary-400 rounded-xl font-semibold text-sm shadow-lg hover:opacity-95 transition-opacity"
          >
            Créer mon compte
            <FiArrowRight className="w-4 h-4" />
          </Link>
        </div>
      </div>
    </main>
  )
}

