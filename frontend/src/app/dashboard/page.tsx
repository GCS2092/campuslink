'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiLogOut, FiBell, FiCalendar, FiUsers, FiImage, FiMapPin, FiClock, FiEdit2, FiGlobe, FiLock } from 'react-icons/fi'
import { feedService, type FeedItem } from '@/services/feedService'
import NotificationBell from '@/components/NotificationBell'

export default function DashboardPage() {
  const { user, loading, logout } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [feedItems, setFeedItems] = useState<FeedItem[]>([])
  const [isLoadingFeed, setIsLoadingFeed] = useState(false)
  const isResponsible = user?.role === 'class_leader' || user?.role === 'admin'

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    } else if (mounted && user && user.role === 'admin') {
      // Seuls les admins sont redirigés vers le dashboard admin
      // Les responsables de classe restent sur le dashboard normal avec accès aux actualités
      router.push('/admin/dashboard')
    }
  }, [mounted, user, loading, router])

  useEffect(() => {
    if (user) {
      loadFeed()
    }
  }, [user])

  const loadFeed = async () => {
    setIsLoadingFeed(true)
    try {
      const response = await feedService.getFeedItems()
      console.log('Feed response:', response) // Debug log
      
      // Handle paginated response (DRF returns {results: [...], count: ...})
      // or direct array
      let items = []
      if (Array.isArray(response)) {
        items = response
      } else if (response && typeof response === 'object') {
        // Check if it's a paginated response
        items = response.results || response.data || []
        console.log('Paginated response detected. Count:', response.count, 'Items:', items.length)
      }
      
      console.log('Feed items extracted:', items.length, 'items') // Debug log
      console.log('First item:', items[0]) // Debug first item
      setFeedItems(items)
    } catch (error: any) {
      console.error('Error loading feed:', error)
      console.error('Error details:', {
        message: error?.message,
        response: error?.response?.data,
        status: error?.response?.status
      })
      setFeedItems([])
    } finally {
      setIsLoadingFeed(false)
    }
  }

  const handleLogout = () => {
    logout()
    router.push('/')
  }

  if (!mounted || loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 to-secondary-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Chargement...</p>
        </div>
      </div>
    )
  }

  if (!user) {
    return null
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-3 sm:py-4">
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 sm:gap-0">
            <div className="flex items-center gap-3">
              <h1 className="text-xl sm:text-2xl font-bold text-gray-900">CampusLink</h1>
            </div>
            <div className="flex items-center gap-2 sm:gap-4 w-full sm:w-auto justify-end">
              <NotificationBell userId={user?.id} />
              <button
                onClick={handleLogout}
                className="flex items-center gap-2 px-3 sm:px-4 py-2 text-sm sm:text-base text-gray-600 hover:text-gray-900 transition"
              >
                <FiLogOut className="w-4 h-4 sm:w-5 sm:h-5" />
                <span className="hidden sm:inline">Déconnexion</span>
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-4 sm:py-6">
        {/* Welcome Section */}
        <div className="bg-white rounded-xl sm:rounded-2xl shadow-lg p-4 sm:p-6 mb-4 sm:mb-6">
          <h2 className="text-xl sm:text-2xl font-bold text-gray-900 mb-1">
            Bienvenue, {user.first_name || user.username || user.email}!
          </h2>
          <p className="text-sm text-gray-600">
            {user.is_verified
              ? user.role === 'class_leader'
                ? 'En tant que responsable de classe, vous pouvez gérer les actualités de votre école'
                : 'Découvrez les actualités de votre campus'
              : 'Vérifiez votre compte pour accéder à toutes les fonctionnalités.'}
          </p>
        </div>

        {/* Feed Section - Actualités */}
        <div className="space-y-4 sm:space-y-6">
          <div className="flex items-center justify-between">
            <h3 className="text-lg sm:text-xl font-bold text-gray-900">Actualités</h3>
            <div className="flex items-center gap-3">
              {isResponsible && (
                <button
                  onClick={() => router.push('/feed/manage')}
                  className="flex items-center gap-2 px-3 sm:px-4 py-2 text-sm bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition"
                >
                  <FiEdit2 className="w-4 h-4" />
                  <span className="hidden sm:inline">Gérer</span>
                </button>
              )}
              <button
                onClick={loadFeed}
                disabled={isLoadingFeed}
                className="text-sm text-primary-600 hover:text-primary-700 font-medium disabled:opacity-50"
              >
                {isLoadingFeed ? 'Chargement...' : 'Actualiser'}
              </button>
            </div>
          </div>

          {/* Feed Items */}
          {isLoadingFeed ? (
            <div className="bg-white rounded-xl shadow-md p-8 sm:p-12 text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
              <p className="mt-4 text-gray-600 text-sm">Chargement des actualités...</p>
            </div>
          ) : feedItems.length === 0 ? (
            <div className="bg-white rounded-xl shadow-md p-8 sm:p-12 text-center">
              <FiCalendar className="w-12 h-12 sm:w-16 sm:h-16 text-gray-400 mx-auto mb-4" />
              <h4 className="text-lg font-semibold text-gray-900 mb-2">Aucune actualité pour le moment</h4>
              <p className="text-sm text-gray-600 mb-4">
                Les actualités de votre campus apparaîtront ici
              </p>
              <div className="text-xs text-gray-500 space-y-1">
                <p>• Événements en cours d&apos;organisation</p>
                <p>• Événements récemment organisés</p>
                <p>• Nouvelles publications des groupes</p>
                <p>• Actualités des différentes écoles</p>
              </div>
            </div>
          ) : (
            <div className="space-y-4 sm:space-y-6">
              {feedItems.map((item) => (
                <article
                  key={item.id}
                  className="bg-white rounded-2xl shadow-lg overflow-hidden hover:shadow-xl transition-all duration-300 border border-gray-100"
                >
                  {/* Feed Item Header with Gradient */}
                  <div className="bg-gradient-to-r from-primary-50 to-secondary-50 p-4 sm:p-6 border-b border-gray-200">
                    <div className="flex items-start gap-4">
                      {/* Author Avatar & Icon */}
                      <div className="relative flex-shrink-0">
                        <div className="w-14 h-14 sm:w-16 sm:h-16 bg-gradient-to-br from-primary-500 to-secondary-500 rounded-2xl flex items-center justify-center shadow-md">
                          {item.type === 'event' ? (
                            <FiCalendar className="w-7 h-7 sm:w-8 sm:h-8 text-white" />
                          ) : item.type === 'group' ? (
                            <FiUsers className="w-7 h-7 sm:w-8 sm:h-8 text-white" />
                          ) : item.type === 'announcement' ? (
                            <FiImage className="w-7 h-7 sm:w-8 sm:h-8 text-white" />
                          ) : (
                            <FiImage className="w-7 h-7 sm:w-8 sm:h-8 text-white" />
                          )}
                        </div>
                        {item.author && (
                          <div className="absolute -bottom-1 -right-1 w-5 h-5 sm:w-6 sm:h-6 bg-white rounded-full border-2 border-white flex items-center justify-center">
                            <div className="w-3 h-3 sm:w-4 sm:h-4 bg-primary-600 rounded-full"></div>
                          </div>
                        )}
                      </div>
                      
                      {/* Title and Meta */}
                      <div className="flex-1 min-w-0">
                        <h4 className="text-lg sm:text-xl font-bold text-gray-900 mb-2 leading-tight">
                          {item.title}
                        </h4>
                        <div className="flex flex-wrap items-center gap-2 sm:gap-3 text-xs sm:text-sm">
                          {item.author && (
                            <span className="text-gray-600 font-medium">
                              Par {item.author.first_name || item.author.username || 'Auteur'}
                            </span>
                          )}
                          {item.university && (
                            <>
                              <span className="text-gray-400">•</span>
                              <div className="flex items-center gap-1 text-gray-600">
                                <FiMapPin className="w-3 h-3 sm:w-4 sm:h-4" />
                                <span>{item.university}</span>
                              </div>
                            </>
                          )}
                          <span className="text-gray-400">•</span>
                          <div className="flex items-center gap-1 text-gray-600">
                            <FiClock className="w-3 h-3 sm:w-4 sm:h-4" />
                            <time dateTime={item.created_at}>
                              {new Date(item.created_at).toLocaleDateString('fr-FR', {
                                day: 'numeric',
                                month: 'long',
                                year: 'numeric',
                                hour: '2-digit',
                                minute: '2-digit'
                              })}
                            </time>
                          </div>
                          <span className={`ml-auto px-3 py-1 rounded-full text-xs font-medium flex items-center gap-1.5 shadow-sm ${
                            item.visibility === 'public' 
                              ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' 
                              : 'bg-blue-50 text-blue-700 border border-blue-200'
                          }`}>
                            {item.visibility === 'public' ? (
                              <>
                                <FiGlobe className="w-3 h-3" />
                                Publique
                              </>
                            ) : (
                              <>
                                <FiLock className="w-3 h-3" />
                                Privée
                              </>
                            )}
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Feed Item Content */}
                  <div className="p-4 sm:p-6">
                    {item.image && (
                      <div className="rounded-xl overflow-hidden mb-4 shadow-md">
                        <img
                          src={item.image.startsWith('http') ? item.image : `${process.env.NEXT_PUBLIC_API_URL?.replace('/api', '')}${item.image}`}
                          alt={item.title}
                          className="w-full h-56 sm:h-80 object-cover hover:scale-105 transition-transform duration-500"
                        />
                      </div>
                    )}
                    <div className="prose prose-sm sm:prose-base max-w-none">
                      <p className="text-sm sm:text-base text-gray-700 leading-relaxed whitespace-pre-wrap">
                        {item.content}
                      </p>
                    </div>
                  </div>
                  
                  {/* Footer with Type Badge */}
                  <div className="px-4 sm:px-6 py-3 bg-gray-50 border-t border-gray-100">
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-semibold text-gray-500 uppercase tracking-wide">
                        {item.type === 'event' ? '📅 Événement' : 
                         item.type === 'group' ? '👥 Groupe' : 
                         item.type === 'announcement' ? '📢 Annonce' : 
                         '📰 Actualité'}
                      </span>
                    </div>
                  </div>
                </article>
              ))}
            </div>
          )}
        </div>
      </main>
    </div>
  )
}

