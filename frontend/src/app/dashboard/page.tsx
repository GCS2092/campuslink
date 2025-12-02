'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { useHotkeys } from 'react-hotkeys-hook'
import { FiLogOut, FiBell, FiCalendar, FiUsers, FiImage, FiMapPin, FiClock, FiEdit2, FiGlobe, FiLock, FiBarChart2, FiZap, FiArrowRight, FiSearch, FiSettings, FiShare2 } from 'react-icons/fi'
import { feedService, type FeedItem } from '@/services/feedService'
import { eventService, type Event } from '@/services/eventService'
import { userService } from '@/services/userService'
import { groupService } from '@/services/groupService'
import NotificationBell from '@/components/NotificationBell'
import Link from 'next/link'
import { getUniversityName } from '@/utils/typeHelpers'
import toast from 'react-hot-toast'
import MiniCalendar from '@/components/MiniCalendar'

export default function DashboardPage() {
  const { user, loading, logout } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [feedItems, setFeedItems] = useState<FeedItem[]>([])
  const [isLoadingFeed, setIsLoadingFeed] = useState(false)
  const [recommendedEvents, setRecommendedEvents] = useState<Event[]>([])
  const [isLoadingRecommended, setIsLoadingRecommended] = useState(false)
  const [stats, setStats] = useState({ friends: 0, events: 0, groups: 0 })
  const [isLoadingStats, setIsLoadingStats] = useState(false)
  const [eventFilter, setEventFilter] = useState<'all' | 'today' | 'week' | 'month'>('all')
  const isResponsible = user?.role === 'class_leader' || user?.role === 'admin'

  // Citations du jour
  const dailyQuotes = [
    "Chaque jour est une nouvelle opportunité de grandir et d'apprendre.",
    "Le succès commence par la décision d'essayer.",
    "Votre éducation est votre arme la plus puissante.",
    "Les rêves deviennent réalité quand nous agissons.",
    "L'excellence n'est pas une compétence, c'est une attitude.",
    "Investissez en vous-même, c'est le meilleur investissement.",
    "Le savoir est le seul bien qui augmente quand on le partage.",
    "L'avenir appartient à ceux qui croient en la beauté de leurs rêves.",
  ]
  const todayQuote = dailyQuotes[new Date().getDate() % dailyQuotes.length]

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      // Vérifier si on est en train de se déconnecter (pas de token)
      // Si pas de token, logout() va gérer la redirection vers /
      const token = localStorage.getItem('access_token')
      if (!token) {
        // Pas de token = déconnexion en cours, ne pas rediriger
        // logout() gère déjà la redirection vers /
        return
      }
      // Token présent mais user null = erreur, rediriger vers login
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
      loadStats()
    }
  }, [user])

  const loadStats = async () => {
    setIsLoadingStats(true)
    try {
      // Charger les statistiques du profil
      const profileStats = await userService.getProfileStats()
      
      // Charger les amis
      const friendsData = await userService.getFriends()
      const friendsCount = Array.isArray(friendsData) ? friendsData.length : friendsData?.results?.length || friendsData?.count || 0
      
      // Utiliser groups_count depuis les stats du profil
      const groupsCount = profileStats?.groups_count || 0
      
      // Compter les événements à venir
      const eventsData = await eventService.getMyEvents()
      const eventsList = Array.isArray(eventsData) ? eventsData : eventsData?.results || []
      const upcomingEvents = eventsList.filter((e: Event) => {
        const eventDate = new Date(e.start_date)
        return eventDate > new Date()
      }).length
      
      setStats({
        friends: friendsCount,
        events: upcomingEvents,
        groups: groupsCount,
      })
    } catch (error) {
      console.error('Error loading stats:', error)
      // Utiliser les stats du profil si disponibles
      try {
        const profileStats = await userService.getProfileStats()
        setStats({
          friends: profileStats?.friends_count || user?.profile?.friends_count || 0,
          events: profileStats?.events_count || 0,
          groups: profileStats?.groups_count || 0,
        })
      } catch (e) {
        // Ignorer l'erreur
      }
    } finally {
      setIsLoadingStats(false)
    }
  }

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
    // logout() gère déjà la redirection vers / avec window.location.href
    logout()
  }

  const handleShareFeedItem = async (item: FeedItem) => {
    const itemTitle = item.title || item.event_data?.title || item.feed_data?.title || 'Actualité CampusLink'
    const itemContent = item.content || item.event_data?.description || item.feed_data?.content || ''
    const itemUrl = item.event_data ? `${window.location.origin}/events/${item.event_data.id}` : `${window.location.origin}/dashboard`
    
    // Utiliser Web Share API si disponible (mobile et certains navigateurs)
    if (navigator.share) {
      try {
        await navigator.share({
          title: itemTitle,
          text: itemContent.substring(0, 200) + (itemContent.length > 200 ? '...' : ''),
          url: itemUrl,
        })
        toast.success('Partagé avec succès !')
      } catch (error: any) {
        // L'utilisateur a annulé le partage
        if (error.name !== 'AbortError') {
          console.error('Error sharing:', error)
          toast.error('Erreur lors du partage')
        }
      }
    } else {
      // Fallback : copier le lien dans le presse-papiers
      try {
        await navigator.clipboard.writeText(itemUrl)
        toast.success('Lien copié dans le presse-papiers !')
      } catch (error) {
        console.error('Error copying to clipboard:', error)
        toast.error('Impossible de copier le lien')
      }
    }
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
      {/* Header - Improved Design */}
      <header className="bg-gradient-to-r from-primary-600 via-primary-500 to-secondary-600 shadow-lg border-b border-primary-700">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-3 sm:py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 sm:w-12 sm:h-12 bg-white/20 backdrop-blur-sm rounded-xl flex items-center justify-center shadow-lg">
                <FiGlobe className="w-6 h-6 sm:w-7 sm:h-7 text-white" />
              </div>
              <h1 className="text-xl sm:text-2xl font-bold text-white drop-shadow-lg">CampusLink</h1>
            </div>
            <div className="flex items-center gap-2 sm:gap-3">
              <NotificationBell userId={user?.id} />
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

      {/* Main Content */}
      <main className="max-w-4xl mx-auto px-3 sm:px-4 lg:px-6 py-4 sm:py-6">
        {/* Welcome Section - Improved Design */}
        <div className="relative bg-gradient-to-br from-primary-500 via-primary-600 to-secondary-600 rounded-2xl shadow-xl p-5 sm:p-6 mb-5 sm:mb-6 overflow-hidden">
          {/* Decorative Background Elements */}
          <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16"></div>
          <div className="absolute bottom-0 left-0 w-24 h-24 bg-white/10 rounded-full -ml-12 -mb-12"></div>
          
          <div className="relative z-10 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 sm:gap-4">
            <div className="flex-1">
              <h2 className="text-xl sm:text-2xl font-bold text-white mb-2 drop-shadow-lg">
                👋 Bienvenue, {user.first_name || user.username || user.email}!
              </h2>
              <p className="text-sm sm:text-base text-white/90 leading-relaxed">
                {user.is_verified
                  ? user.role === 'class_leader'
                    ? 'En tant que responsable de classe, vous pouvez gérer les actualités de votre école'
                    : 'Découvrez les actualités de votre campus et restez connecté avec votre communauté'
                  : 'Vérifiez votre compte pour accéder à toutes les fonctionnalités.'}
              </p>
            </div>
          </div>
        </div>

        {/* Statistiques Rapides */}
        <div className="grid grid-cols-3 gap-3 sm:gap-4 mb-5 sm:mb-6">
          <div className="bg-white rounded-xl shadow-md p-4 border border-gray-100">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center">
                <FiUsers className="w-5 h-5 text-white" />
              </div>
              <div>
                <p className="text-xs text-gray-500">Amis</p>
                <p className="text-lg font-bold text-gray-900">{isLoadingStats ? '...' : stats.friends}</p>
              </div>
            </div>
          </div>
          <div className="bg-white rounded-xl shadow-md p-4 border border-gray-100">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-gradient-to-br from-green-500 to-green-600 rounded-lg flex items-center justify-center">
                <FiCalendar className="w-5 h-5 text-white" />
              </div>
              <div>
                <p className="text-xs text-gray-500">Événements</p>
                <p className="text-lg font-bold text-gray-900">{isLoadingStats ? '...' : stats.events}</p>
              </div>
            </div>
          </div>
          <div className="bg-white rounded-xl shadow-md p-4 border border-gray-100">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-gradient-to-br from-purple-500 to-purple-600 rounded-lg flex items-center justify-center">
                <FiUsers className="w-5 h-5 text-white" />
              </div>
              <div>
                <p className="text-xs text-gray-500">Groupes</p>
                <p className="text-lg font-bold text-gray-900">{isLoadingStats ? '...' : stats.groups}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Citations du jour et Calendrier Mini - Layout responsive */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 sm:gap-5 mb-5 sm:mb-6">
          <div className="lg:col-span-2">
            <div className="bg-gradient-to-r from-yellow-50 to-orange-50 dark:from-yellow-900/20 dark:to-orange-900/20 rounded-xl shadow-md p-4 sm:p-5 border border-yellow-200 dark:border-yellow-800">
              <div className="flex items-start gap-3">
                <div className="text-2xl">💡</div>
                <div>
                  <p className="text-xs font-semibold text-yellow-800 dark:text-yellow-200 mb-1">Citation du jour</p>
                  <p className="text-sm sm:text-base text-gray-700 dark:text-gray-300 italic">"{todayQuote}"</p>
                </div>
              </div>
            </div>
          </div>
          <div className="lg:col-span-1">
            <MiniCalendar
              onDateSelect={(date) => {
                // Rediriger vers le calendrier avec la date sélectionnée
                router.push(`/calendar?date=${date.toISOString().split('T')[0]}`)
              }}
            />
          </div>
        </div>

        {/* Quick Actions - Improved Design */}
        <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 sm:gap-4 mb-5 sm:mb-6">
          <Link
            href="/calendar"
            className="group relative bg-white rounded-xl shadow-md hover:shadow-xl transition-all duration-300 p-4 sm:p-5 border border-gray-100 hover:border-indigo-300 hover:-translate-y-1"
          >
            <div className="flex flex-col items-center text-center gap-2">
              <div className="relative w-12 h-12 sm:w-14 sm:h-14 bg-gradient-to-br from-indigo-500 to-indigo-600 rounded-xl flex items-center justify-center group-hover:scale-110 group-hover:rotate-3 transition-all duration-300 shadow-lg">
                <FiCalendar className="w-6 h-6 sm:w-7 sm:h-7 text-white" />
              </div>
              <span className="text-xs sm:text-sm font-semibold text-gray-700 group-hover:text-indigo-600 transition-colors">Calendrier</span>
            </div>
            <div className="absolute inset-0 bg-gradient-to-br from-indigo-50/0 to-indigo-50/0 group-hover:from-indigo-50/50 group-hover:to-transparent rounded-xl transition-all duration-300"></div>
          </Link>

          <Link
            href="/friends-activity"
            className="group relative bg-white rounded-xl shadow-md hover:shadow-xl transition-all duration-300 p-4 sm:p-5 border border-gray-100 hover:border-pink-300 hover:-translate-y-1"
          >
            <div className="flex flex-col items-center text-center gap-2">
              <div className="relative w-12 h-12 sm:w-14 sm:h-14 bg-gradient-to-br from-pink-500 to-pink-600 rounded-xl flex items-center justify-center group-hover:scale-110 group-hover:rotate-3 transition-all duration-300 shadow-lg">
                <FiUsers className="w-6 h-6 sm:w-7 sm:h-7 text-white" />
              </div>
              <span className="text-xs sm:text-sm font-semibold text-gray-700 group-hover:text-pink-600 transition-colors">Activité Amis</span>
            </div>
            <div className="absolute inset-0 bg-gradient-to-br from-pink-50/0 to-pink-50/0 group-hover:from-pink-50/50 group-hover:to-transparent rounded-xl transition-all duration-300"></div>
          </Link>

          <Link
            href="/search"
            className="group relative bg-white rounded-xl shadow-md hover:shadow-xl transition-all duration-300 p-4 sm:p-5 border border-gray-100 hover:border-teal-300 hover:-translate-y-1"
          >
            <div className="flex flex-col items-center text-center gap-2">
              <div className="relative w-12 h-12 sm:w-14 sm:h-14 bg-gradient-to-br from-teal-500 to-teal-600 rounded-xl flex items-center justify-center group-hover:scale-110 group-hover:rotate-3 transition-all duration-300 shadow-lg">
                <FiSearch className="w-6 h-6 sm:w-7 sm:h-7 text-white" />
              </div>
              <span className="text-xs sm:text-sm font-semibold text-gray-700 group-hover:text-teal-600 transition-colors">Recherche</span>
            </div>
            <div className="absolute inset-0 bg-gradient-to-br from-teal-50/0 to-teal-50/0 group-hover:from-teal-50/50 group-hover:to-transparent rounded-xl transition-all duration-300"></div>
          </Link>

          <Link
            href="/groups"
            className="group relative bg-white rounded-xl shadow-md hover:shadow-xl transition-all duration-300 p-4 sm:p-5 border border-gray-100 hover:border-purple-300 hover:-translate-y-1"
          >
            <div className="flex flex-col items-center text-center gap-2">
              <div className="relative w-12 h-12 sm:w-14 sm:h-14 bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl flex items-center justify-center group-hover:scale-110 group-hover:rotate-3 transition-all duration-300 shadow-lg">
                <FiUsers className="w-6 h-6 sm:w-7 sm:h-7 text-white" />
              </div>
              <span className="text-xs sm:text-sm font-semibold text-gray-700 group-hover:text-purple-600 transition-colors">Groupes</span>
            </div>
            <div className="absolute inset-0 bg-gradient-to-br from-purple-50/0 to-purple-50/0 group-hover:from-purple-50/50 group-hover:to-transparent rounded-xl transition-all duration-300"></div>
          </Link>

          <Link
            href="/settings"
            className="group relative bg-white rounded-xl shadow-md hover:shadow-xl transition-all duration-300 p-4 sm:p-5 border border-gray-100 hover:border-gray-400 hover:-translate-y-1"
          >
            <div className="flex flex-col items-center text-center gap-2">
              <div className="relative w-12 h-12 sm:w-14 sm:h-14 bg-gradient-to-br from-gray-500 to-gray-600 rounded-xl flex items-center justify-center group-hover:scale-110 group-hover:rotate-3 transition-all duration-300 shadow-lg">
                <FiSettings className="w-6 h-6 sm:w-7 sm:h-7 text-white" />
              </div>
              <span className="text-xs sm:text-sm font-semibold text-gray-700 group-hover:text-gray-600 transition-colors">Paramètres</span>
            </div>
            <div className="absolute inset-0 bg-gradient-to-br from-gray-50/0 to-gray-50/0 group-hover:from-gray-50/50 group-hover:to-transparent rounded-xl transition-all duration-300"></div>
          </Link>
        </div>

        {/* Recommended Events Section - Pour vous - Improved Design */}
        {recommendedEvents.length > 0 && (
          <div className="mb-5 sm:mb-6">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <div className="w-10 h-10 bg-gradient-to-br from-primary-500 to-secondary-500 rounded-lg flex items-center justify-center shadow-md">
                  <FiZap className="w-5 h-5 text-white" />
                </div>
                <h3 className="text-lg sm:text-xl font-bold text-gray-900">Pour vous</h3>
              </div>
              <div className="flex items-center gap-2 flex-wrap">
                {/* Bouton Export Calendrier */}
                <button
                  onClick={async () => {
                    try {
                      const blob = await eventService.exportCalendar(true)
                      const url = window.URL.createObjectURL(blob)
                      const a = document.createElement('a')
                      a.href = url
                      a.download = 'campuslink-calendar.ics'
                      document.body.appendChild(a)
                      a.click()
                      window.URL.revokeObjectURL(url)
                      document.body.removeChild(a)
                      toast.success('Calendrier exporté avec succès !')
                    } catch (error) {
                      console.error('Error exporting calendar:', error)
                      toast.error('Erreur lors de l\'export du calendrier')
                    }
                  }}
                  className="px-3 py-1.5 text-xs sm:text-sm bg-primary-600 hover:bg-primary-700 text-white rounded-lg transition-colors flex items-center gap-1.5 shadow-sm"
                  title="Exporter le calendrier"
                >
                  <FiCalendar className="w-3.5 h-3.5" />
                  <span className="hidden sm:inline">Export</span>
                </button>
                {/* Filtres rapides */}
                <div className="flex gap-1 bg-gray-100 dark:bg-gray-700 rounded-lg p-1">
                  <button
                    onClick={() => setEventFilter('all')}
                    className={`px-2 py-1 text-xs font-medium rounded transition ${
                      eventFilter === 'all'
                        ? 'bg-white dark:bg-gray-600 text-primary-600 dark:text-primary-400 shadow-sm'
                        : 'text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200'
                    }`}
                  >
                    Tous
                  </button>
                  <button
                    onClick={() => setEventFilter('today')}
                    className={`px-2 py-1 text-xs font-medium rounded transition ${
                      eventFilter === 'today'
                        ? 'bg-white dark:bg-gray-600 text-primary-600 dark:text-primary-400 shadow-sm'
                        : 'text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200'
                    }`}
                  >
                    Aujourd'hui
                  </button>
                  <button
                    onClick={() => setEventFilter('week')}
                    className={`px-2 py-1 text-xs font-medium rounded transition ${
                      eventFilter === 'week'
                        ? 'bg-white dark:bg-gray-600 text-primary-600 dark:text-primary-400 shadow-sm'
                        : 'text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200'
                    }`}
                  >
                    Cette semaine
                  </button>
                  <button
                    onClick={() => setEventFilter('month')}
                    className={`px-2 py-1 text-xs font-medium rounded transition ${
                      eventFilter === 'month'
                        ? 'bg-white dark:bg-gray-600 text-primary-600 dark:text-primary-400 shadow-sm'
                        : 'text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200'
                    }`}
                  >
                    Ce mois
                  </button>
                </div>
                <Link
                  href="/events"
                  className="text-sm sm:text-base text-primary-600 hover:text-primary-700 font-semibold flex items-center gap-1.5 hover:gap-2 transition-all group"
                >
                  Voir tout
                  <FiArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                </Link>
              </div>
            </div>
            {isLoadingRecommended ? (
              <div className="bg-white rounded-lg shadow-sm p-6 text-center">
                <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600 mx-auto"></div>
                <p className="mt-3 text-gray-600 text-xs">Chargement des recommandations...</p>
              </div>
            ) : (
              <div className="relative">
                {/* Carrousel horizontal avec scroll natif */}
                <div className="overflow-x-auto scrollbar-hide -mx-2 px-2 pb-4">
                  <div className="flex gap-4" style={{ minWidth: 'max-content' }}>
                    {recommendedEvents
                      .filter((event) => {
                        if (eventFilter === 'all') return true
                        const eventDate = new Date(event.start_date)
                        const now = new Date()
                        const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
                        const eventDay = new Date(eventDate.getFullYear(), eventDate.getMonth(), eventDate.getDate())
                        
                        if (eventFilter === 'today') {
                          return eventDay.getTime() === today.getTime()
                        }
                        if (eventFilter === 'week') {
                          const weekFromNow = new Date(today)
                          weekFromNow.setDate(weekFromNow.getDate() + 7)
                          return eventDate >= today && eventDate <= weekFromNow
                        }
                        if (eventFilter === 'month') {
                          const monthFromNow = new Date(today)
                          monthFromNow.setMonth(monthFromNow.getMonth() + 1)
                          return eventDate >= today && eventDate <= monthFromNow
                        }
                        return true
                      })
                      .map((event) => (
                        <Link
                          key={event.id}
                          href={`/events/${event.id}`}
                          className="group bg-white rounded-xl shadow-md overflow-hidden hover:shadow-xl transition-all duration-300 border border-gray-100 hover:border-primary-300 hover:-translate-y-1 flex-shrink-0"
                          style={{ width: '280px' }}
                        >
                          {event.image_url && (
                            <div className="h-40 sm:h-44 bg-gray-200 relative overflow-hidden">
                              <img
                                src={event.image_url}
                                alt={event.title}
                                className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                              />
                              <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent"></div>
                            </div>
                          )}
                          <div className="p-4">
                            <h4 className="font-bold text-base text-gray-900 mb-2 line-clamp-2 group-hover:text-primary-600 transition-colors">{event.title}</h4>
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
                </div>
                {/* Style pour masquer la scrollbar mais garder le scroll */}
                <style jsx>{`
                  .scrollbar-hide {
                    -ms-overflow-style: none;
                    scrollbar-width: none;
                  }
                  .scrollbar-hide::-webkit-scrollbar {
                    display: none;
                  }
                `}</style>
              </div>
            )}
          </div>
        )}

        {/* Feed Section - Actualités - Improved Design */}
        <div className="space-y-4 sm:space-y-5">
          <div className="flex items-center justify-between mb-1">
            <div className="flex items-center gap-2">
              <div className="w-10 h-10 bg-gradient-to-br from-orange-500 to-red-500 rounded-lg flex items-center justify-center shadow-md">
                <FiBell className="w-5 h-5 text-white" />
              </div>
              <h3 className="text-lg sm:text-xl font-bold text-gray-900">Actualités</h3>
            </div>
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
            <div className="bg-white rounded-xl shadow-md p-8 text-center border border-gray-100">
              <div className="animate-spin rounded-full h-8 w-8 border-3 border-primary-600 border-t-transparent mx-auto"></div>
              <p className="mt-4 text-gray-600 text-sm font-medium">Chargement des actualités...</p>
            </div>
          ) : feedItems.length === 0 ? (
            <div className="bg-white rounded-xl shadow-md p-8 text-center border border-gray-100">
              <div className="w-16 h-16 bg-gradient-to-br from-gray-100 to-gray-200 rounded-full flex items-center justify-center mx-auto mb-4">
                <FiCalendar className="w-8 h-8 text-gray-400" />
              </div>
              <h4 className="text-lg font-bold text-gray-900 mb-2">Aucune actualité pour le moment</h4>
              <p className="text-sm text-gray-600 mb-4">
                Les actualités de votre campus apparaîtront ici
              </p>
              <div className="text-xs sm:text-sm text-gray-500 space-y-1.5 max-w-md mx-auto">
                <p className="flex items-center justify-center gap-2">
                  <span className="w-1.5 h-1.5 bg-primary-500 rounded-full"></span>
                  Événements en cours d&apos;organisation
                </p>
                <p className="flex items-center justify-center gap-2">
                  <span className="w-1.5 h-1.5 bg-primary-500 rounded-full"></span>
                  Événements récemment organisés
                </p>
                <p className="flex items-center justify-center gap-2">
                  <span className="w-1.5 h-1.5 bg-primary-500 rounded-full"></span>
                  Nouvelles publications des groupes
                </p>
                <p className="flex items-center justify-center gap-2">
                  <span className="w-1.5 h-1.5 bg-primary-500 rounded-full"></span>
                  Actualités des différentes écoles
                </p>
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
                           className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-xl transition-all duration-300 border border-gray-100 hover:-translate-y-1"
                         >
                           {/* Feed Item Header with Gradient - Improved */}
                           <div className="bg-gradient-to-r from-primary-50 via-primary-50/80 to-secondary-50 p-4 sm:p-5 border-b border-gray-200">
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

                           {/* Feed Item Content - Improved */}
                           <div className="p-4 sm:p-5">
                             {itemImage && (
                               <div className="rounded-xl overflow-hidden mb-4 shadow-lg">
                                 <img
                                   src={itemImage.startsWith('http') ? itemImage : `${process.env.NEXT_PUBLIC_API_URL?.replace('/api', '')}${itemImage}`}
                                   alt={itemTitle}
                                   className="w-full h-48 sm:h-64 object-cover hover:scale-110 transition-transform duration-700"
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
                           
                           {/* Footer with Type Badge and Share - Improved */}
                           <div className="px-4 sm:px-5 py-3 bg-gradient-to-r from-gray-50 to-gray-100/50 border-t border-gray-200">
                             <div className="flex items-center justify-between">
                               <span className="text-xs sm:text-sm font-bold text-gray-600 uppercase tracking-wide">
                                 {itemType === 'event' ? '📅 Événement' : 
                                  itemType === 'group' ? '👥 Groupe' : 
                                  itemType === 'announcement' ? '📢 Annonce' : 
                                  '📰 Actualité'}
                               </span>
                               <button
                                 onClick={() => handleShareFeedItem(item)}
                                 className="flex items-center gap-1.5 px-2.5 py-1.5 text-xs text-gray-600 hover:text-primary-600 hover:bg-primary-50 rounded-lg transition-colors"
                                 title="Partager"
                               >
                                 <FiShare2 className="w-3.5 h-3.5" />
                                 <span className="hidden sm:inline">Partager</span>
                               </button>
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

