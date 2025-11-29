'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiUsers, FiCalendar, FiHeart, FiStar, FiArrowLeft, FiRefreshCw, FiClock } from 'react-icons/fi'
import { feedService } from '@/services/feedService'
import Link from 'next/link'
import toast from 'react-hot-toast'
import { formatDistanceToNow } from 'date-fns'
import { fr } from 'date-fns/locale'

interface FriendActivity {
  type: 'participation' | 'event_created' | 'event_liked' | 'event_favorited' | 'feed_item'
  id: string
  friend: {
    id: string
    username: string
    first_name?: string
    last_name?: string
    profile_picture?: string
  }
  event?: {
    id: string
    title: string
    image_url?: string
    description?: string
    start_date?: string
  }
  content?: string
  title?: string
  image?: string
  message: string
  created_at: string
}

export default function FriendsActivityPage() {
  const { user, loading } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [activities, setActivities] = useState<FriendActivity[]>([])
  const [isLoading, setIsLoading] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    } else if (user) {
      loadActivities()
    }
  }, [mounted, user, loading, router])

  const loadActivities = async () => {
    setIsLoading(true)
    try {
      const response = await feedService.getFriendsActivity()
      setActivities(response.items || [])
    } catch (error: any) {
      console.error('Error loading friends activity:', error)
      toast.error('Erreur lors du chargement de l\'activité des amis')
    } finally {
      setIsLoading(false)
    }
  }

  const getActivityIcon = (type: string) => {
    switch (type) {
      case 'participation':
        return <FiCalendar className="w-5 h-5 text-blue-600" />
      case 'event_created':
        return <FiCalendar className="w-5 h-5 text-green-600" />
      case 'event_liked':
        return <FiHeart className="w-5 h-5 text-red-600" />
      case 'event_favorited':
        return <FiStar className="w-5 h-5 text-yellow-600" />
      default:
        return <FiUsers className="w-5 h-5 text-purple-600" />
    }
  }

  const getActivityColor = (type: string) => {
    switch (type) {
      case 'participation':
        return 'bg-blue-50 border-blue-200'
      case 'event_created':
        return 'bg-green-50 border-green-200'
      case 'event_liked':
        return 'bg-red-50 border-red-200'
      case 'event_favorited':
        return 'bg-yellow-50 border-yellow-200'
      default:
        return 'bg-purple-50 border-purple-200'
    }
  }

  if (!mounted || loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Chargement...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto px-4 py-6">
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-4">
            <Link
              href="/dashboard"
              className="p-2 hover:bg-gray-200 rounded-lg transition"
            >
              <FiArrowLeft className="w-5 h-5 text-gray-700" />
            </Link>
            <div>
              <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2">
                <FiUsers className="w-6 h-6 text-primary-600" />
                Activité des Amis
              </h1>
              <p className="text-sm text-gray-600 mt-1">
                Découvrez ce que vos amis font sur CampusLink
              </p>
            </div>
          </div>
          <button
            onClick={loadActivities}
            disabled={isLoading}
            className="p-2 hover:bg-gray-200 rounded-lg transition disabled:opacity-50"
          >
            <FiRefreshCw className={`w-5 h-5 text-gray-700 ${isLoading ? 'animate-spin' : ''}`} />
          </button>
        </div>

        {/* Activities List */}
        {isLoading && activities.length === 0 ? (
          <div className="bg-white rounded-2xl shadow-lg p-12 text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Chargement de l'activité...</p>
          </div>
        ) : activities.length === 0 ? (
          <div className="bg-white rounded-2xl shadow-lg p-12 text-center">
            <FiUsers className="w-16 h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-xl font-semibold text-gray-900 mb-2">
              Aucune activité pour le moment
            </h3>
            <p className="text-gray-600 mb-6">
              Ajoutez des amis pour voir leur activité sur CampusLink!
            </p>
            <Link
              href="/students"
              className="inline-flex items-center gap-2 px-6 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition"
            >
              <FiUsers className="w-5 h-5" />
              Découvrir des amis
            </Link>
          </div>
        ) : (
          <div className="space-y-4">
            {activities.map((activity) => (
              <div
                key={activity.id}
                className={`bg-white rounded-xl shadow-md p-6 border-2 ${getActivityColor(activity.type)} hover:shadow-lg transition`}
              >
                <div className="flex gap-4">
                  {/* Friend Avatar */}
                  <div className="flex-shrink-0">
                    {activity.friend.profile_picture ? (
                      <img
                        src={activity.friend.profile_picture}
                        alt={activity.friend.username}
                        className="w-12 h-12 rounded-full object-cover border-2 border-white shadow-sm"
                      />
                    ) : (
                      <div className="w-12 h-12 rounded-full bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center border-2 border-white shadow-sm">
                        <span className="text-white font-semibold text-lg">
                          {(activity.friend.first_name?.[0] || activity.friend.username[0]).toUpperCase()}
                        </span>
                      </div>
                    )}
                  </div>

                  {/* Activity Content */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-4 mb-2">
                      <div className="flex items-center gap-2 flex-1">
                        {getActivityIcon(activity.type)}
                        <div>
                          <Link
                            href={`/users/${activity.friend.id}`}
                            className="font-semibold text-gray-900 hover:text-primary-600 transition"
                          >
                            {activity.friend.first_name && activity.friend.last_name
                              ? `${activity.friend.first_name} ${activity.friend.last_name}`
                              : activity.friend.username}
                          </Link>
                          <p className="text-sm text-gray-600">{activity.message}</p>
                        </div>
                      </div>
                      <div className="flex items-center gap-1 text-xs text-gray-500 flex-shrink-0">
                        <FiClock className="w-3 h-3" />
                        <span>
                          {formatDistanceToNow(new Date(activity.created_at), {
                            addSuffix: true,
                            locale: fr,
                          })}
                        </span>
                      </div>
                    </div>

                    {/* Event Details */}
                    {activity.event && (
                      <Link
                        href={`/events/${activity.event.id}`}
                        className="block mt-3 p-4 bg-white rounded-lg border border-gray-200 hover:border-primary-300 transition"
                      >
                        <div className="flex gap-4">
                          {activity.event.image_url && (
                            <img
                              src={activity.event.image_url}
                              alt={activity.event.title}
                              className="w-20 h-20 rounded-lg object-cover flex-shrink-0"
                            />
                          )}
                          <div className="flex-1 min-w-0">
                            <h3 className="font-semibold text-gray-900 mb-1 line-clamp-2">
                              {activity.event.title}
                            </h3>
                            {activity.event.description && (
                              <p className="text-sm text-gray-600 line-clamp-2">
                                {activity.event.description}
                              </p>
                            )}
                            {activity.event.start_date && (
                              <p className="text-xs text-gray-500 mt-2">
                                {new Date(activity.event.start_date).toLocaleDateString('fr-FR', {
                                  day: 'numeric',
                                  month: 'long',
                                  year: 'numeric',
                                  hour: '2-digit',
                                  minute: '2-digit',
                                })}
                              </p>
                            )}
                          </div>
                        </div>
                      </Link>
                    )}

                    {/* Feed Item Content */}
                    {activity.type === 'feed_item' && activity.content && (
                      <div className="mt-3 p-4 bg-white rounded-lg border border-gray-200">
                        {activity.title && (
                          <h3 className="font-semibold text-gray-900 mb-2">{activity.title}</h3>
                        )}
                        <p className="text-sm text-gray-700">{activity.content}</p>
                        {activity.image && (
                          <img
                            src={activity.image}
                            alt={activity.title}
                            className="mt-3 rounded-lg w-full max-w-md"
                          />
                        )}
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

