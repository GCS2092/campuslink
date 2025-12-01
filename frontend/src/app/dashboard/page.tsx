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
        <div className="max-w-7xl mx-auto px-3 sm:px-4 lg:px-6 py-2 sm:py-3">
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2 sm:gap-0">
            <div className="flex items-center gap-2">
              <h1 className="text-lg sm:text-xl font-bold text-gray-900">CampusLink</h1>
            </div>
            <div className="flex items-center gap-2 sm:gap-3 w-full sm:w-auto justify-end">
              <NotificationBell userId={user?.id} />
              <button
                onClick={handleLogout}
                className="flex items-center gap-1.5 px-2 sm:px-3 py-1.5 text-xs sm:text-sm text-gray-600 hover:text-gray-900 transition"
              >
                <FiLogOut className="w-3.5 h-3.5 sm:w-4 sm:h-4" />
                <span className="hidden sm:inline">Déconnexion</span>
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-4xl mx-auto px-3 sm:px-4 lg:px-6 py-3 sm:py-4">
        {/* Welcome Section */}
        <div className="bg-white rounded-lg sm:rounded-xl shadow-md p-3 sm:p-4 mb-3 sm:mb-4">
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2 sm:gap-3">
            <div>
              <h2 className="text-base sm:text-lg font-bold text-gray-900 mb-0.5">
                Bienvenue, {user.first_name || user.username || user.email}!
              </h2>
              <p className="text-xs sm:text-sm text-gray-600">
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
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 sm:gap-3 mb-3 sm:mb-4">
          <Link
            href="/profile"
            className="bg-white rounded-lg shadow-sm p-2.5 sm:p-3 hover:shadow-md transition-all duration-200 border border-gray-100 hover:border-primary-300 group"
          >
            <div className="flex flex-col items-center text-center gap-1.5">
              <div className="w-10 h-10 sm:w-11 sm:h-11 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center group-hover:scale-105 transition-transform">
                <FiUser className="w-5 h-5 sm:w-5.5 sm:h-5.5 text-white" />
              </div>
              <span className="text-[10px] sm:text-xs font-semibold text-gray-700">Mon Profil</span>
            </div>
          </Link>

          <Link
            href="/settings"
            className="bg-white rounded-lg shadow-sm p-2.5 sm:p-3 hover:shadow-md transition-all duration-200 border border-gray-100 hover:border-primary-300 group"
          >
            <div className="flex flex-col items-center text-center gap-1.5">
              <div className="w-10 h-10 sm:w-11 sm:h-11 bg-gradient-to-br from-purple-500 to-purple-600 rounded-lg flex items-center justify-center group-hover:scale-105 transition-transform">
                <FiSettings className="w-5 h-5 sm:w-5.5 sm:h-5.5 text-white" />
              </div>
              <span className="text-[10px] sm:text-xs font-semibold text-gray-700">Paramètres</span>
            </div>
          </Link>

          <Link
            href="/settings?tab=security"
            className="bg-white rounded-lg shadow-sm p-2.5 sm:p-3 hover:shadow-md transition-all duration-200 border border-gray-100 hover:border-primary-300 group"
          >
            <div className="flex flex-col items-center text-center gap-1.5">
              <div className="w-10 h-10 sm:w-11 sm:h-11 bg-gradient-to-br from-red-500 to-red-600 rounded-lg flex items-center justify-center group-hover:scale-105 transition-transform">
                <FiKey className="w-5 h-5 sm:w-5.5 sm:h-5.5 text-white" />
              </div>
              <span className="text-[10px] sm:text-xs font-semibold text-gray-700">Mot de passe</span>
            </div>
          </Link>

          <Link
            href="/settings?tab=notifications"
            className="bg-white rounded-lg shadow-sm p-2.5 sm:p-3 hover:shadow-md transition-all duration-200 border border-gray-100 hover:border-primary-300 group"
          >
            <div className="flex flex-col items-center text-center gap-1.5">
              <div className="w-10 h-10 sm:w-11 sm:h-11 bg-gradient-to-br from-green-500 to-green-600 rounded-lg flex items-center justify-center group-hover:scale-105 transition-transform">
                <FiBell className="w-5 h-5 sm:w-5.5 sm:h-5.5 text-white" />
              </div>
              <span className="text-[10px] sm:text-xs font-semibold text-gray-700">Notifications</span>
            </div>
          </Link>
        </div>

        {/* Additional Quick Actions */}
        <div className="grid grid-cols-2 sm:grid-cols-3 gap-2 sm:gap-3 mb-3 sm:mb-4">
          <Link
            href="/calendar"
            className="bg-white rounded-lg shadow-sm p-2.5 sm:p-3 hover:shadow-md transition-all duration-200 border border-gray-100 hover:border-primary-300 group"
          >
            <div className="flex flex-col items-center text-center gap-1.5">
              <div className="w-10 h-10 sm:w-11 sm:h-11 bg-gradient-to-br from-indigo-500 to-indigo-600 rounded-lg flex items-center justify-center group-hover:scale-105 transition-transform">
                <FiCalendar className="w-5 h-5 sm:w-5.5 sm:h-5.5 text-white" />
              </div>
              <span className="text-[10px] sm:text-xs font-semibold text-gray-700">Calendrier</span>
            </div>
          </Link>

          <Link
            href="/friends-activity"
            className="bg-white rounded-lg shadow-sm p-2.5 sm:p-3 hover:shadow-md transition-all duration-200 border border-gray-100 hover:border-primary-300 group"
          >
            <div className="flex flex-col items-center text-center gap-1.5">
              <div className="w-10 h-10 sm:w-11 sm:h-11 bg-gradient-to-br from-pink-500 to-pink-600 rounded-lg flex items-center justify-center group-hover:scale-105 transition-transform">
                <FiUsers className="w-5 h-5 sm:w-5.5 sm:h-5.5 text-white" />
              </div>
              <span className="text-[10px] sm:text-xs font-semibold text-gray-700">Activité Amis</span>
            </div>
          </Link>
        </div>

        {/* Recommended Events Section - Pour vous */}
        {recommendedEvents.length > 0 && (
          <div className="mb-4 sm:mb-5">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-1.5">
                <FiZap className="w-4 h-4 sm:w-4.5 sm:h-4.5 text-primary-600" />
                <h3 className="text-base sm:text-lg font-bold text-gray-900">Pour vous</h3>
              </div>
              <Link
                href="/events"
                className="text-xs sm:text-sm text-primary-600 hover:text-primary-700 font-medium flex items-center gap-1"
              >
                Voir tout
                <FiArrowRight className="w-3.5 h-3.5 sm:w-4 sm:h-4" />
              </Link>
            </div>
            {isLoadingRecommended ? (
              <div className="bg-white rounded-lg shadow-sm p-6 text-center">
                <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600 mx-auto"></div>
                <p className="mt-3 text-gray-600 text-xs">Chargement des recommandations...</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                {recommendedEvents.map((event) => (
                  <Link
                    key={event.id}
                    href={`/events/${event.id}`}
                    className="bg-white rounded-lg shadow-sm overflow-hidden hover:shadow-md transition-all duration-200 border border-gray-100 hover:border-primary-300"
                  >
                    {event.image_url && (
                      <div className="h-32 sm:h-36 bg-gray-200 relative overflow-hidden">
                        <img
                          src={event.image_url}
                          alt={event.title}
                          className="w-full h-full object-cover"
                        />
                      </div>
                    )}
                    <div className="p-3">
                      <h4 className="font-semibold text-sm text-gray-900 mb-1.5 line-clamp-2">{event.title}</h4>
                      <div className="space-y-1 text-xs text-gray-600">
                        <div className="flex items-center gap-1.5">
                          <FiCalendar className="w-3.5 h-3.5" />
                          <span>
                            {new Date(event.start_date).toLocaleDateString('fr-FR', {
                              day: 'numeric',
                              month: 'short',
                              hour: '2-digit',
                              minute: '2-digit'
                            })}
                          </span>
                        </div>
                        <div className="flex items-center gap-1.5">
                          <FiMapPin className="w-3.5 h-3.5" />
                          <span className="truncate">{event.location}</span>
                        </div>
                        {event.participants_count !== undefined && (
                          <div className="flex items-center gap-1.5">
                            <FiUsers className="w-3.5 h-3.5" />
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
        <div className="space-y-3 sm:space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-base sm:text-lg font-bold text-gray-900">Actualités</h3>
            <div className="flex items-center gap-2">
              {isResponsible && (
                <button
                  onClick={() => router.push('/feed/manage')}
                  className="flex items-center gap-1.5 px-2.5 sm:px-3 py-1.5 text-xs bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition"
                >
                  <FiEdit2 className="w-3.5 h-3.5" />
                  <span className="hidden sm:inline">Gérer</span>
                </button>
              )}
              <button
                onClick={loadFeed}
                disabled={isLoadingFeed}
                className="text-xs sm:text-sm text-primary-600 hover:text-primary-700 font-medium disabled:opacity-50"
              >
                {isLoadingFeed ? 'Chargement...' : 'Actualiser'}
              </button>
            </div>
          </div>

          {/* Feed Items */}
          {isLoadingFeed ? (
            <div className="bg-white rounded-lg shadow-sm p-6 text-center">
              <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600 mx-auto"></div>
              <p className="mt-3 text-gray-600 text-xs">Chargement des actualités...</p>
            </div>
          ) : feedItems.length === 0 ? (
            <div className="bg-white rounded-lg shadow-sm p-6 text-center">
              <FiCalendar className="w-10 h-10 sm:w-12 sm:h-12 text-gray-400 mx-auto mb-3" />
              <h4 className="text-base font-semibold text-gray-900 mb-1.5">Aucune actualité pour le moment</h4>
              <p className="text-xs text-gray-600 mb-3">
                Les actualités de votre campus apparaîtront ici
              </p>
              <div className="text-[10px] sm:text-xs text-gray-500 space-y-0.5">
                <p>• Événements en cours d&apos;organisation</p>
                <p>• Événements récemment organisés</p>
                <p>• Nouvelles publications des groupes</p>
                <p>• Actualités des différentes écoles</p>
              </div>
            </div>
          ) : (
            <div className="space-y-3 sm:space-y-4">
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
                           className="bg-white rounded-lg shadow-sm overflow-hidden hover:shadow-md transition-all duration-300 border border-gray-100"
                         >
                           {/* Feed Item Header with Gradient */}
                           <div className="bg-gradient-to-r from-primary-50 to-secondary-50 p-3 sm:p-4 border-b border-gray-200">
                             <div className="flex items-start gap-3">
                               {/* Author Avatar & Icon */}
                               <div className="relative flex-shrink-0">
                                 <div className="w-10 h-10 sm:w-12 sm:h-12 bg-gradient-to-br from-primary-500 to-secondary-500 rounded-lg flex items-center justify-center shadow-sm">
                                   {itemType === 'event' ? (
                                     <FiCalendar className="w-5 h-5 sm:w-6 sm:h-6 text-white" />
                                   ) : itemType === 'group' ? (
                                     <FiUsers className="w-5 h-5 sm:w-6 sm:h-6 text-white" />
                                   ) : itemType === 'announcement' ? (
                                     <FiImage className="w-5 h-5 sm:w-6 sm:h-6 text-white" />
                                   ) : (
                                     <FiImage className="w-5 h-5 sm:w-6 sm:h-6 text-white" />
                                   )}
                                 </div>
                                 {itemAuthor && (
                                   <div className="absolute -bottom-0.5 -right-0.5 w-4 h-4 sm:w-5 sm:h-5 bg-white rounded-full border-2 border-white flex items-center justify-center">
                                     <div className="w-2.5 h-2.5 sm:w-3 sm:h-3 bg-primary-600 rounded-full"></div>
                                   </div>
                                 )}
                               </div>
                               
                               {/* Title and Meta */}
                               <div className="flex-1 min-w-0">
                                 <h4 className="text-sm sm:text-base font-bold text-gray-900 mb-1.5 leading-tight">
                                   {itemTitle}
                                 </h4>
                                 <div className="flex flex-wrap items-center gap-1.5 sm:gap-2 text-[10px] sm:text-xs">
                                   {itemAuthor && (
                                     <span className="text-gray-600 font-medium">
                                       Par {itemAuthor.first_name || itemAuthor.username || 'Auteur'}
                                     </span>
                                   )}
                                   {itemUniversity && (
                                     <>
                                       <span className="text-gray-400">•</span>
                                       <div className="flex items-center gap-0.5 text-gray-600">
                                         <FiMapPin className="w-3 h-3" />
                                         <span>{getUniversityName(itemUniversity)}</span>
                                       </div>
                                     </>
                                   )}
                                   <span className="text-gray-400">•</span>
                                   <div className="flex items-center gap-0.5 text-gray-600">
                                     <FiClock className="w-3 h-3" />
                                     <time dateTime={itemCreatedAt}>
                                       {new Date(itemCreatedAt).toLocaleDateString('fr-FR', {
                                         day: 'numeric',
                                         month: 'short',
                                         year: 'numeric',
                                         hour: '2-digit',
                                         minute: '2-digit'
                                       })}
                                     </time>
                                   </div>
                                   <span className={`ml-auto px-2 py-0.5 rounded-full text-[10px] font-medium flex items-center gap-1 shadow-sm ${
                                     itemVisibility === 'public' 
                                       ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' 
                                       : 'bg-blue-50 text-blue-700 border border-blue-200'
                                   }`}>
                                     {itemVisibility === 'public' ? (
                                       <>
                                         <FiGlobe className="w-2.5 h-2.5" />
                                         Publique
                                       </>
                                     ) : (
                                       <>
                                         <FiLock className="w-2.5 h-2.5" />
                                         Privée
                                       </>
                                     )}
                                   </span>
                                 </div>
                               </div>
                             </div>
                           </div>

                           {/* Feed Item Content */}
                           <div className="p-3 sm:p-4">
                             {itemImage && (
                               <div className="rounded-lg overflow-hidden mb-3 shadow-sm">
                                 <img
                                   src={itemImage.startsWith('http') ? itemImage : `${process.env.NEXT_PUBLIC_API_URL?.replace('/api', '')}${itemImage}`}
                                   alt={itemTitle}
                                   className="w-full h-40 sm:h-56 object-cover hover:scale-105 transition-transform duration-500"
                                 />
                               </div>
                             )}
                             <div className="prose prose-xs sm:prose-sm max-w-none">
                               <p className="text-xs sm:text-sm text-gray-700 leading-relaxed whitespace-pre-wrap">
                                 {itemContent}
                               </p>
                             </div>
                             {itemType === 'event' && item.event_data && (
                               <div className="mt-3 pt-3 border-t border-gray-200">
                                 <Link
                                   href={`/events/${itemId}`}
                                   className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition text-xs"
                                 >
                                   <FiCalendar className="w-3.5 h-3.5" />
                                   <span>Voir l'événement</span>
                                 </Link>
                               </div>
                             )}
                           </div>
                           
                           {/* Footer with Type Badge */}
                           <div className="px-3 sm:px-4 py-2 bg-gray-50 border-t border-gray-100">
                             <div className="flex items-center justify-between">
                               <span className="text-[10px] sm:text-xs font-semibold text-gray-500 uppercase tracking-wide">
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

