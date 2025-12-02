'use client'

import { FiLogOut, FiGlobe } from 'react-icons/fi'
import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { ReactNode } from 'react'

interface CampusLinkHeaderProps {
  title: string
  subtitle?: string
  icon?: ReactNode
  showBackButton?: boolean
  onBack?: () => void
  rightContent?: ReactNode
}

export default function CampusLinkHeader({
  title,
  subtitle,
  icon,
  showBackButton = false,
  onBack,
  rightContent
}: CampusLinkHeaderProps) {
  const { logout } = useAuth()
  const router = useRouter()

  const handleLogout = () => {
    logout()
    router.push('/')
  }

  const handleBack = () => {
    if (onBack) {
      onBack()
    } else {
      router.push('/dashboard')
    }
  }

  return (
    <header className="bg-gradient-to-r from-primary-600 via-primary-500 to-secondary-600 shadow-lg border-b border-primary-700 sticky top-0 z-10">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-3 sm:py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            {showBackButton && (
              <button
                onClick={handleBack}
                className="p-2 text-white hover:bg-white/20 rounded-xl transition-all duration-200"
                title="Retour"
              >
                <svg className="w-5 h-5 sm:w-6 sm:h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                </svg>
              </button>
            )}
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 sm:w-12 sm:h-12 bg-white/20 backdrop-blur-sm rounded-xl flex items-center justify-center shadow-lg">
                {icon || <FiGlobe className="w-6 h-6 sm:w-7 sm:h-7 text-white" />}
              </div>
              <div>
                <h1 className="text-xl sm:text-2xl font-bold text-white drop-shadow-lg">{title}</h1>
                {subtitle && (
                  <p className="text-white/90 text-xs sm:text-sm hidden sm:block">{subtitle}</p>
                )}
              </div>
            </div>
          </div>
          <div className="flex items-center gap-2 sm:gap-3">
            {rightContent}
            <button
              onClick={handleLogout}
              className="flex items-center gap-2 px-3 sm:px-4 py-2 sm:py-2.5 bg-white/20 hover:bg-white/30 backdrop-blur-sm text-white rounded-xl transition-all duration-300 shadow-md hover:shadow-lg hover:scale-105 border border-white/30"
              title="Déconnexion"
            >
              <FiLogOut className="w-4 h-4 sm:w-5 sm:h-5" />
              <span className="hidden sm:inline font-semibold">Déconnexion</span>
            </button>
          </div>
        </div>
      </div>
    </header>
  )
}

