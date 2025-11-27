'use client'

import Link from 'next/link'
import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { 
  FiUsers, 
  FiCalendar, 
  FiMessageSquare, 
  FiBell, 
  FiShield, 
  FiSmartphone,
  FiArrowRight,
  FiZap,
  FiHeart
} from 'react-icons/fi'

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
    {
      icon: FiUsers,
      title: 'Réseau Social',
      color: 'from-blue-500 to-blue-600',
      emoji: '👥'
    },
    {
      icon: FiCalendar,
      title: 'Événements',
      color: 'from-purple-500 to-purple-600',
      emoji: '📅'
    },
    {
      icon: FiMessageSquare,
      title: 'Messages',
      color: 'from-green-500 to-green-600',
      emoji: '💬'
    },
    {
      icon: FiBell,
      title: 'Actualités',
      color: 'from-orange-500 to-orange-600',
      emoji: '📢'
    }
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
          {/* Main Title with Animation */}
          <div className="mb-8">
            <h1 className="text-6xl sm:text-7xl lg:text-8xl font-extrabold mb-4">
              <span className="block text-gray-900 dark:text-white">Bienvenue sur</span>
              <span className="block text-transparent bg-clip-text bg-gradient-to-r from-primary-600 via-purple-600 to-secondary-600 animate-gradient">
                CampusLink
              </span>
            </h1>
            <p className="text-2xl sm:text-3xl text-gray-600 dark:text-gray-300 font-light mt-6">
              Connecte ton campus en un clic ✨
            </p>
          </div>

          {/* Interactive Features Grid */}
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 sm:gap-6 mb-12 max-w-3xl mx-auto">
            {features.map((feature, index) => {
              const Icon = feature.icon
              const isHovered = hoveredFeature === index
              return (
                <div
                  key={index}
                  onMouseEnter={() => setHoveredFeature(index)}
                  onMouseLeave={() => setHoveredFeature(null)}
                  className={`
                    group relative bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm rounded-2xl p-6 
                    cursor-pointer transition-all duration-300 transform
                    ${isHovered ? 'scale-110 shadow-2xl -translate-y-2' : 'scale-100 shadow-lg hover:shadow-xl'}
                    border-2 ${isHovered ? 'border-primary-500 dark:border-primary-400' : 'border-transparent dark:border-gray-700'}
                  `}
                >
                  <div className={`
                    w-16 h-16 mx-auto mb-3 rounded-xl flex items-center justify-center
                    bg-gradient-to-br ${feature.color} transition-transform duration-300
                    ${isHovered ? 'scale-125 rotate-6' : 'scale-100'}
                  `}>
                    <span className="text-3xl">{feature.emoji}</span>
                  </div>
                  <h3 className="text-sm sm:text-base font-bold text-gray-800 dark:text-white">
                    {feature.title}
                  </h3>
                  {isHovered && (
                    <div className="absolute inset-0 bg-gradient-to-br from-primary-500/10 to-secondary-500/10 rounded-2xl animate-pulse"></div>
                  )}
                </div>
              )
            })}
          </div>

          {/* CTA Buttons */}
          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <Link
              href="/register"
              className="group relative px-10 py-5 bg-gradient-to-r from-primary-600 to-secondary-600 text-white rounded-2xl font-bold text-lg shadow-2xl hover:shadow-primary-500/50 transition-all duration-300 transform hover:scale-105 hover:-translate-y-1 overflow-hidden"
            >
              <span className="relative z-10 flex items-center gap-2">
                Commencer maintenant
                <FiArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
              </span>
              <div className="absolute inset-0 bg-gradient-to-r from-secondary-600 to-primary-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            </Link>
            <Link
              href="/login"
              className="px-10 py-5 bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm text-primary-600 dark:text-primary-400 border-2 border-primary-600 dark:border-primary-500 rounded-2xl font-bold text-lg shadow-lg hover:shadow-xl transition-all duration-300 transform hover:scale-105 hover:-translate-y-1"
            >
              Se connecter
            </Link>
          </div>

          {/* Quick Stats */}
          <div className="mt-16 flex flex-wrap justify-center gap-8 sm:gap-12">
            <div className="flex items-center gap-2 text-gray-600 dark:text-gray-300">
              <FiUsers className="w-5 h-5 text-primary-600 dark:text-primary-400" />
              <span className="font-semibold">Communauté</span>
            </div>
            <div className="flex items-center gap-2 text-gray-600 dark:text-gray-300">
              <FiZap className="w-5 h-5 text-yellow-500 dark:text-yellow-400" />
              <span className="font-semibold">Temps réel</span>
            </div>
            <div className="flex items-center gap-2 text-gray-600 dark:text-gray-300">
              <FiHeart className="w-5 h-5 text-red-500 dark:text-red-400" />
              <span className="font-semibold">100% Gratuit</span>
            </div>
          </div>
        </div>

        {/* Scroll Indicator */}
        <div className="absolute bottom-8 left-1/2 transform -translate-x-1/2 animate-bounce">
          <div className="w-6 h-10 border-2 border-gray-400 dark:border-gray-600 rounded-full flex justify-center">
            <div className="w-1 h-3 bg-gray-400 dark:bg-gray-600 rounded-full mt-2"></div>
          </div>
        </div>
      </div>

      {/* Simple CTA Section */}
      <div className="relative py-20 bg-gradient-to-r from-primary-600 via-purple-600 to-secondary-600 dark:from-primary-700 dark:via-purple-700 dark:to-secondary-700">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-4xl sm:text-5xl font-bold text-white mb-6">
            Prêt à commencer ? 🚀
          </h2>
          <p className="text-xl text-white/90 dark:text-white/80 mb-8">
            Rejoins la communauté étudiante en quelques secondes
          </p>
          <Link
            href="/register"
            className="inline-flex items-center gap-2 px-10 py-5 bg-white dark:bg-gray-800 text-primary-600 dark:text-primary-400 rounded-2xl font-bold text-lg shadow-2xl hover:shadow-white/50 dark:hover:shadow-gray-800/50 transition-all duration-300 transform hover:scale-105"
          >
            Créer mon compte
            <FiArrowRight className="w-5 h-5" />
          </Link>
        </div>
      </div>
    </main>
  )
}

