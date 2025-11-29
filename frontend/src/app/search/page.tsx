'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState, Suspense } from 'react'
import { FiSearch, FiUser, FiCalendar, FiUsers, FiArrowLeft, FiLogOut, FiX } from 'react-icons/fi'
import { searchService, type SearchResult } from '@/services/searchService'
import Link from 'next/link'
import { useDebounce } from '@/hooks/useDebounce'

type SearchType = 'all' | 'users' | 'events' | 'groups'

function SearchContent() {
  const { user, loading, logout } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [query, setQuery] = useState('')
  const [searchType, setSearchType] = useState<SearchType>('all')
  const [results, setResults] = useState<SearchResult | null>(null)
  const [isLoading, setIsLoading] = useState(false)
  const [activeTab, setActiveTab] = useState<SearchType>('all')

  const debouncedQuery = useDebounce(query, 500)

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    }
  }, [mounted, user, loading, router])

  useEffect(() => {
    // Get query from URL if present
    if (typeof window !== 'undefined') {
      const urlParams = new URLSearchParams(window.location.search)
      const q = urlParams.get('q')
      if (q) {
        setQuery(q)
      }
    }
  }, [])

  useEffect(() => {
    if (debouncedQuery && debouncedQuery.length >= 2) {
      performSearch()
    } else {
      setResults(null)
    }
  }, [debouncedQuery, searchType])

  const performSearch = async () => {
    if (!debouncedQuery || debouncedQuery.length < 2) return

    setIsLoading(true)
    try {
      const data = await searchService.globalSearch(debouncedQuery, searchType, 20)
      setResults(data)
    } catch (error: any) {
      console.error('Error performing search:', error)
      setResults(null)
    } finally {
      setIsLoading(false)
    }
  }

  const handleLogout = () => {
    logout()
    router.push('/')
  }

  const handleGoBack = () => {
    router.push('/dashboard')
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleDateString('fr-FR', {
      day: 'numeric',
      month: 'long',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
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
      <header className="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-3 sm:py-4">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-3 sm:gap-4">
              <button
                onClick={handleGoBack}
                className="p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition"
                title="Retour"
              >
                <FiArrowLeft className="w-5 h-5 sm:w-6 sm:h-6" />
              </button>
              <h1 className="text-xl sm:text-2xl font-bold text-gray-900">Recherche</h1>
            </div>
            <button
              onClick={handleLogout}
              className="flex items-center gap-2 px-3 sm:px-4 py-2 text-sm sm:text-base text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition"
              title="Déconnexion"
            >
              <FiLogOut className="w-4 h-4 sm:w-5 sm:h-5" />
              <span className="hidden sm:inline">Déconnexion</span>
            </button>
          </div>

          {/* Search Bar */}
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <FiSearch className="h-5 w-5 text-gray-400" />
            </div>
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Rechercher des étudiants, événements, groupes..."
              className="block w-full pl-10 pr-10 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            />
            {query && (
              <button
                onClick={() => {
                  setQuery('')
                  setResults(null)
                }}
                className="absolute inset-y-0 right-0 pr-3 flex items-center"
              >
                <FiX className="h-5 w-5 text-gray-400 hover:text-gray-600" />
              </button>
            )}
          </div>

          {/* Search Type Filters */}
          <div className="flex gap-2 mt-3 overflow-x-auto">
            {(['all', 'users', 'events', 'groups'] as SearchType[]).map((type) => (
              <button
                key={type}
                onClick={() => {
                  setSearchType(type)
                  setActiveTab(type)
                }}
                className={`px-4 py-2 rounded-lg text-sm font-medium whitespace-nowrap transition ${
                  searchType === type
                    ? 'bg-primary-600 text-white'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                {type === 'all' ? 'Tout' : type === 'users' ? 'Étudiants' : type === 'events' ? 'Événements' : 'Groupes'}
              </button>
            ))}
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 sm:py-6">
        {isLoading ? (
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Recherche en cours...</p>
          </div>
        ) : !query || query.length < 2 ? (
          <div className="bg-white rounded-2xl shadow-lg p-8 sm:p-12 text-center">
            <FiSearch className="w-12 h-12 sm:w-16 sm:h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg sm:text-xl font-semibold text-gray-900 mb-2">
              Recherche globale
            </h3>
            <p className="text-gray-600 text-sm sm:text-base">
              Tapez au moins 2 caractères pour commencer la recherche
            </p>
          </div>
        ) : results && results.total === 0 ? (
          <div className="bg-white rounded-2xl shadow-lg p-8 sm:p-12 text-center">
            <FiSearch className="w-12 h-12 sm:w-16 sm:h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg sm:text-xl font-semibold text-gray-900 mb-2">
              Aucun résultat trouvé
            </h3>
            <p className="text-gray-600 text-sm sm:text-base">
              Aucun résultat pour &quot;{query}&quot;
            </p>
          </div>
        ) : results ? (
          <div className="space-y-6">
            {/* Users Results */}
            {(activeTab === 'all' || activeTab === 'users') && results.users.length > 0 && (
              <div>
                <h2 className="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
                  <FiUser className="w-5 h-5 text-primary-600" />
                  Étudiants ({results.counts.users})
                </h2>
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                  {results.users.map((userResult) => (
                    <Link
                      key={userResult.id}
                      href={`/students/${userResult.id}`}
                      className="bg-white rounded-xl shadow-md p-4 hover:shadow-lg transition"
                    >
                      <div className="flex items-center gap-3">
                        <div className="w-12 h-12 bg-primary-100 rounded-full flex items-center justify-center flex-shrink-0">
                          <FiUser className="w-6 h-6 text-primary-600" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h3 className="font-semibold text-gray-900 truncate">
                            {userResult.first_name && userResult.last_name
                              ? `${userResult.first_name} ${userResult.last_name}`
                              : userResult.username}
                          </h3>
                          <p className="text-sm text-gray-600 truncate">@{userResult.username}</p>
                        </div>
                      </div>
                    </Link>
                  ))}
                </div>
              </div>
            )}

            {/* Events Results */}
            {(activeTab === 'all' || activeTab === 'events') && results.events.length > 0 && (
              <div>
                <h2 className="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
                  <FiCalendar className="w-5 h-5 text-primary-600" />
                  Événements ({results.counts.events})
                </h2>
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                  {results.events.map((event) => (
                    <Link
                      key={event.id}
                      href={`/events/${event.id}`}
                      className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition"
                    >
                      <div className="p-4">
                        <h3 className="font-semibold text-gray-900 mb-2 line-clamp-2">{event.title}</h3>
                        <p className="text-sm text-gray-600 mb-2 line-clamp-2">{event.description}</p>
                        <div className="flex items-center gap-2 text-xs text-gray-500">
                          <FiCalendar className="w-4 h-4" />
                          <span>{formatDate(event.start_date)}</span>
                        </div>
                        <div className="flex items-center gap-2 text-xs text-gray-500 mt-1">
                          <FiUsers className="w-4 h-4" />
                          <span>{event.participants_count || 0} participants</span>
                        </div>
                      </div>
                    </Link>
                  ))}
                </div>
              </div>
            )}

            {/* Groups Results */}
            {(activeTab === 'all' || activeTab === 'groups') && results.groups.length > 0 && (
              <div>
                <h2 className="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
                  <FiUsers className="w-5 h-5 text-primary-600" />
                  Groupes ({results.counts.groups})
                </h2>
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                  {results.groups.map((group) => (
                    <Link
                      key={group.id}
                      href={`/groups/${group.id}`}
                      className="bg-white rounded-xl shadow-md p-4 hover:shadow-lg transition"
                    >
                      <div className="flex items-start gap-3">
                        <div className="w-12 h-12 bg-purple-100 rounded-full flex items-center justify-center flex-shrink-0">
                          <FiUsers className="w-6 h-6 text-purple-600" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h3 className="font-semibold text-gray-900 mb-1 truncate">{group.name}</h3>
                          <p className="text-sm text-gray-600 line-clamp-2 mb-2">{group.description}</p>
                          <div className="flex items-center gap-2 text-xs text-gray-500">
                            <FiUsers className="w-4 h-4" />
                            <span>{group.members_count || 0} membres</span>
                          </div>
                        </div>
                      </div>
                    </Link>
                  ))}
                </div>
              </div>
            )}
          </div>
        ) : null}
      </div>
    </div>
  )
}

export default function SearchPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 to-secondary-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Chargement...</p>
        </div>
      </div>
    }>
      <SearchContent />
    </Suspense>
  )
}

