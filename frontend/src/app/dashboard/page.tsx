'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiLogOut, FiBell, FiCalendar, FiUsers, FiImage, FiMapPin, FiClock, FiEdit2, FiGlobe, FiLock, FiSettings, FiUser, FiKey, FiBarChart2, FiZap, FiArrowRight } from 'react-icons/fi'
import { feedService, type FeedItem } from '@/services/feedService'
import { eventService, type Event } from '@/services/eventService'
import NotificationBell from '@/components/NotificationBell'
import Link from 'next/link'
import { getUniversityName } from '@/utils/typeHelpers'

export default function DashboardPage() {
  const { user, loading, logout } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [feedItems, setFeedItems] = useState<FeedItem[]>([])
  const [isLoadingFeed, setIsLoadingFeed] = useState(false)
  const [recommendedEvents, setRecommendedEvents] = useState<Event[]>([])
  const [isLoadingRecommended, setIsLoadingRecommended] = useState(false)
  const isResponsible = user?.role === 'class_leader' || user?.role === 'admin'

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    } else if (mounted && user) {
      // Vérifier si l'utilisateur est actif et vérifié
      if (!user.is_active || !user.is_verified) {
        router.push('/pending-approval')
        return
      }
      
      if (user.role === 'admin') {
        // Seuls les admins globaux sont redirigés vers le dashboard admin
        router.push('/admin/dashboard')
      } else if (user.role === 'university_admin') {
        // Les admins d'université sont redirigés vers leur dashboard
        router.push('/university-admin/dashboard')
      }
    }
    // Les responsables de classe restent sur le dashboard normal avec accès aux actualités
  }, [mounted, user, loading, router])

  useEffect(() => {
    if (user) {
      loadFeed()
      loadRecommendedEvents()
    }
  }, [user])

  const loadRecommendedEvents = async () => {
    setIsLoadingRecommended(true)
    try {
      const events = await eventService.getRecommendedEvents(6)
      setRecommendedEvents(Array.isArray(events) ? events : [])
    } catch (error: any) {
      console.error('Error loading recommended events:', error)
    } finally {
      setIsLoadingRecommended(false)
    }
  }

  const loadFeed = async () => {
    setIsLoadingFeed(true)
    try {
      // Use personalized feed for better user experience
      const response = await feedService.getPersonalizedFeed()
      console.log('Personalized feed response:', response) // Debug log
      
      // Personalized feed returns {items: [...], total: ..., events_count: ..., feed_items_count: ...}
      let items = []
      if (response && response.items) {
        items = response.items
      } else if (Array.isArray(response)) {
        items = response
      } else if (response && typeof response === 'object') {
        // Fallback to regular feed if personalized fails
        items = response.results || response.data || []
      }
      
      console.log('Feed items extracted:', items.length, 'items') // Debug log
      setFeedItems(items)
    } catch (error: any) {
      console.error('Error loading personalized feed, falling back to regular feed:', error)
      // Fallback to regular feed if personalized feed fails
      try {
        const response = await feedService.getFeedItems()
        let items = []
        if (Array.isArray(response)) {
          items = response
        } else if (response && typeof response === 'object') {
          items = response.results || response.data || []
        }
        setFeedItems(items)
      } catch (fallbackError: any) {
        console.error('Error loading regular feed:', fallbackError)
        setFeedItems([])
      }
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
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div>
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
          </div>
        </div>

        {/* Quick Actions Section */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 sm:gap-4 mb-4 sm:mb-6">
          <Link
            href="/profile"
            className="bg-white rounded-xl shadow-md p-4 hover:shadow-lg transition-all duration-200 border border-gray-100 hover:border-primary-300 group"
          >
            <div className="flex flex-col items-center text-center gap-2">
              <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl flex items-center justify-center group-hover:scale-110 transition-transform">
                <FiUser className="w-6 h-6 text-white" />
              </div>
              <span className="text-xs sm:text-sm font-semibold text-gray-700">Mon Profil</span>
            </div>
          </Link>

          <Link
            href="/settings"
            className="bg-white rounded-xl shadow-md p-4 hover:shadow-lg transition-all duration-200 border border-gray-100 hover:border-primary-300 group"
          >
            <div className="flex flex-col items-center text-center gap-2">
              <div className="w-12 h-12 bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl flex items-center justify-center group-hover:scale-110 transition-transform">
                <FiSettings className="w-6 h-6 text-white" />
              </div>
              <span className="text-xs sm:text-sm font-semibold text-gray-700">Paramètres</span>
            </div>
          </Link>

          <Link
            href="/settings?tab=security"
            className="bg-white rounded-xl shadow-md p-4 hover:shadow-lg transition-all duration-200 border border-gray-100 hover:border-primary-300 group"
          >
            <div className="flex flex-col items-center text-center gap-2">
              <div className="w-12 h-12 bg-gradient-to-br from-red-500 to-red-600 rounded-xl flex items-center justify-center group-hover:scale-110 transition-transform">
                <FiKey className="w-6 h-6 text-white" />
              </div>
              <span className="text-xs sm:text-sm font-semibold text-gray-700">Mot de passe</span>
            </div>
          </Link>

          <Link
            href="/settings?tab=notifications"
            className="bg-white rounded-xl shadow-md p-4 hover:shadow-lg transition-all duration-200 border border-gray-100 hover:border-primary-300 group"
          >
            <div className="flex flex-col items-center text-center gap-2">
              <div className="w-12 h-12 bg-gradient-to-br from-green-500 to-green-600 rounded-xl flex items-center justify-center group-hover:scale-110 transition-transform">
                <FiBell className="w-6 h-6 text-white" />
              </div>
              <span className="text-xs sm:text-sm font-semibold text-gray-700">Notifications</span>
            </div>
          </Link>
        </div>

        {/* Additional Quick Actions */}
        <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 sm:gap-4 mb-4 sm:mb-6">
          <Link
            href="/calendar"
            className="bg-white rounded-xl shadow-md p-4 hover:shadow-lg transition-all duration-200 border border-gray-100 hover:border-primary-300 group"
          >
            <div className="flex flex-col items-center text-center gap-2">
              <div className="w-12 h-12 bg-gradient-to-br from-indigo-500 to-indigo-600 rounded-xl flex items-center justify-center group-hover:scale-110 transition-transform">
                <FiCalendar className="w-6 h-6 text-white" />
              </div>
              <span className="text-xs sm:text-sm font-semibold text-gray-700">Calendrier</span>
            </div>
          </Link>

          <Link
            href="/friends-activity"
            className="bg-white rounded-xl shadow-md p-4 hover:shadow-lg transition-all duration-200 border border-gray-100 hover:border-primary-300 group"
          >
            <div className="flex flex-col items-center text-center gap-2">
              <div className="w-12 h-12 bg-gradient-to-br from-pink-500 to-pink-600 rounded-xl flex items-center justify-center group-hover:scale-110 transition-transform">
                <FiUsers className="w-6 h-6 text-white" />
              </div>
              <span className="text-xs sm:text-sm font-semibold text-gray-700">Activité Amis</span>
            </div>
          </Link>
        </div>

        {/* Recommended Events Section - Pour vous */}
        {recommendedEvents.length > 0 && (
          <div className="mb-6">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <FiZap className="w-5 h-5 text-primary-600" />
                <h3 className="text-lg sm:text-xl font-bold text-gray-900">Pour vous</h3>
              </div>
              <Link
                href="/events"
                className="text-sm text-primary-600 hover:text-primary-700 font-medium flex items-center gap-1"
              >
                Voir tout
                <FiArrowRight className="w-4 h-4" />
              </Link>
            </div>
            {isLoadingRecommended ? (
              <div className="bg-white rounded-xl shadow-md p-8 text-center">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
                <p className="mt-4 text-gray-600 text-sm">Chargement des recommandations...</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                {recommendedEvents.map((event) => (
                  <Link
                    key={event.id}
                    href={`/events/${event.id}`}
                    className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition-all duration-200 border border-gray-100 hover:border-primary-300"
                  >
                    {event.image_url && (
                      <div className="h-40 bg-gray-200 relative overflow-hidden">
                        <img
                          src={event.image_url}
                          alt={event.title}
                          className="w-full h-full object-cover"
                        />
                      </div>
                    )}
                    <div className="p-4">
                      <h4 className="font-semibold text-gray-900 mb-2 line-clamp-2">{event.title}</h4>
                      <div className="space-y-1 text-sm text-gray-600">
                        <div className="flex items-center gap-2">
                          <FiCalendar className="w-4 h-4" />
                          <span>
                            {new Date(event.start_date).toLocaleDateString('fr-FR', {
                              day: 'numeric',
                              month: 'short',
                              hour: '2-digit',
                              minute: '2-digit'
                            })}
                          </span>
                        </div>
                        <div className="flex items-center gap-2">
                          <FiMapPin className="w-4 h-4" />
                          <span className="truncate">{event.location}</span>
                        </div>
                        {event.participants_count !== undefined && (
                          <div className="flex items-center gap-2">
                            <FiUsers className="w-4 h-4" />
                            <span>{event.participants_count} participants</span>
                          </div>
                        )}
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            )}
          </div>
        )}

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
                     {feedItems.map((item) => {
                       // Handle both regular feed items and personalized feed items
                       const itemType = item.type || (item.event_data ? 'event' : 'feed')
                       const itemTitle = item.title || item.event_data?.title || item.feed_data?.title || ''
                       const itemContent = item.content || item.event_data?.description || item.feed_data?.content || ''
                       const itemImage = item.image || item.event_data?.image_url || item.event_data?.image || item.feed_data?.image
                       const itemAuthor = item.author || item.event_data?.organizer || item.feed_data?.author
                       const itemUniversity = item.university || item.event_data?.university || item.feed_data?.university
                       const itemCreatedAt = item.created_at || item.event_data?.start_date || item.event_data?.created_at || item.feed_data?.created_at
                       const itemVisibility = item.visibility || item.feed_data?.visibility || 'public'
                       const itemId = item.id || item.event_data?.id || item.feed_data?.id
                       
                       return (
                         <article
                           key={itemId}
                           className="bg-white rounded-2xl shadow-lg overflow-hidden hover:shadow-xl transition-all duration-300 border border-gray-100"
                         >
                           {/* Feed Item Header with Gradient */}
                           <div className="bg-gradient-to-r from-primary-50 to-secondary-50 p-4 sm:p-6 border-b border-gray-200">
                             <div className="flex items-start gap-4">
                               {/* Author Avatar & Icon */}
                               <div className="relative flex-shrink-0">
                                 <div className="w-14 h-14 sm:w-16 sm:h-16 bg-gradient-to-br from-primary-500 to-secondary-500 rounded-2xl flex items-center justify-center shadow-md">
                                   {itemType === 'event' ? (
                                     <FiCalendar className="w-7 h-7 sm:w-8 sm:h-8 text-white" />
                                   ) : itemType === 'group' ? (
                                     <FiUsers className="w-7 h-7 sm:w-8 sm:h-8 text-white" />
                                   ) : itemType === 'announcement' ? (
                                     <FiImage className="w-7 h-7 sm:w-8 sm:h-8 text-white" />
                                   ) : (
                                     <FiImage className="w-7 h-7 sm:w-8 sm:h-8 text-white" />
                                   )}
                                 </div>
                                 {itemAuthor && (
                                   <div className="absolute -bottom-1 -right-1 w-5 h-5 sm:w-6 sm:h-6 bg-white rounded-full border-2 border-white flex items-center justify-center">
                                     <div className="w-3 h-3 sm:w-4 sm:h-4 bg-primary-600 rounded-full"></div>
                                   </div>
                                 )}
                               </div>
                               
                               {/* Title and Meta */}
                               <div className="flex-1 min-w-0">
                                 <h4 className="text-lg sm:text-xl font-bold text-gray-900 mb-2 leading-tight">
                                   {itemTitle}
                                 </h4>
                                 <div className="flex flex-wrap items-center gap-2 sm:gap-3 text-xs sm:text-sm">
                                   {itemAuthor && (
                                     <span className="text-gray-600 font-medium">
                                       Par {itemAuthor.first_name || itemAuthor.username || 'Auteur'}
                                     </span>
                                   )}
                                   {itemUniversity && (
                                     <>
                                       <span className="text-gray-400">•</span>
                                       <div className="flex items-center gap-1 text-gray-600">
                                         <FiMapPin className="w-3 h-3 sm:w-4 sm:h-4" />
                                         <span>{getUniversityName(itemUniversity)}</span>
                                       </div>
                                     </>
                                   )}
                                   <span className="text-gray-400">•</span>
                                   <div className="flex items-center gap-1 text-gray-600">
                                     <FiClock className="w-3 h-3 sm:w-4 sm:h-4" />
                                     <time dateTime={itemCreatedAt}>
                                       {new Date(itemCreatedAt).toLocaleDateString('fr-FR', {
                                         day: 'numeric',
                                         month: 'long',
                                         year: 'numeric',
                                         hour: '2-digit',
                                         minute: '2-digit'
                                       })}
                                     </time>
                                   </div>
                                   <span className={`ml-auto px-3 py-1 rounded-full text-xs font-medium flex items-center gap-1.5 shadow-sm ${
                                     itemVisibility === 'public' 
                                       ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' 
                                       : 'bg-blue-50 text-blue-700 border border-blue-200'
                                   }`}>
                                     {itemVisibility === 'public' ? (
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
                             {itemImage && (
                               <div className="rounded-xl overflow-hidden mb-4 shadow-md">
                                 <img
                                   src={itemImage.startsWith('http') ? itemImage : `${process.env.NEXT_PUBLIC_API_URL?.replace('/api', '')}${itemImage}`}
                                   alt={itemTitle}
                                   className="w-full h-56 sm:h-80 object-cover hover:scale-105 transition-transform duration-500"
                                 />
                               </div>
                             )}
                             <div className="prose prose-sm sm:prose-base max-w-none">
                               <p className="text-sm sm:text-base text-gray-700 leading-relaxed whitespace-pre-wrap">
                                 {itemContent}
                               </p>
                             </div>
                             {itemType === 'event' && item.event_data && (
                               <div className="mt-4 pt-4 border-t border-gray-200">
                                 <Link
                                   href={`/events/${itemId}`}
                                   className="inline-flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition text-sm"
                                 >
                                   <FiCalendar className="w-4 h-4" />
                                   <span>Voir l'événement</span>
                                 </Link>
                               </div>
                             )}
                           </div>
                           
                           {/* Footer with Type Badge */}
                           <div className="px-4 sm:px-6 py-3 bg-gray-50 border-t border-gray-100">
                             <div className="flex items-center justify-between">
                               <span className="text-xs font-semibold text-gray-500 uppercase tracking-wide">
                                 {itemType === 'event' ? '📅 Événement' : 
                                  itemType === 'group' ? '👥 Groupe' : 
                                  itemType === 'announcement' ? '📢 Annonce' : 
                                  '📰 Actualité'}
                               </span>
                             </div>
                           </div>
                         </article>
                       )
                     })}
            </div>
          )}
        </div>
      </main>
    </div>
  )
}

