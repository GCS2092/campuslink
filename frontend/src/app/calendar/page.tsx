'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiCalendar, FiChevronLeft, FiChevronRight, FiDownload, FiClock, FiMapPin, FiUsers } from 'react-icons/fi'
import { eventService, type Event } from '@/services/eventService'
import toast from 'react-hot-toast'
import Link from 'next/link'
import { format, startOfMonth, endOfMonth, eachDayOfInterval, isSameMonth, isSameDay, startOfWeek, endOfWeek, addMonths, subMonths } from 'date-fns'

type ViewMode = 'month' | 'week' | 'day'

interface CalendarEvent extends Event {
  calendar_type?: 'participation' | 'favorite'
}

export default function CalendarPage() {
  const { user, loading } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [currentDate, setCurrentDate] = useState(new Date())
  const [viewMode, setViewMode] = useState<ViewMode>('month')
  const [events, setEvents] = useState<CalendarEvent[]>([])
  const [isLoading, setIsLoading] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    } else if (user) {
      loadCalendarEvents()
    }
  }, [mounted, user, loading, router, currentDate, viewMode])

  const loadCalendarEvents = async () => {
    if (!user) return
    
    setIsLoading(true)
    try {
      let startDate: string | undefined
      let endDate: string | undefined

      if (viewMode === 'month') {
        const monthStart = startOfMonth(currentDate)
        const monthEnd = endOfMonth(currentDate)
        startDate = monthStart.toISOString()
        endDate = monthEnd.toISOString()
      } else if (viewMode === 'week') {
        const weekStart = startOfWeek(currentDate, { weekStartsOn: 1 })
        const weekEnd = endOfWeek(currentDate, { weekStartsOn: 1 })
        startDate = weekStart.toISOString()
        endDate = weekEnd.toISOString()
      } else {
        const dayStart = new Date(currentDate)
        dayStart.setHours(0, 0, 0, 0)
        const dayEnd = new Date(currentDate)
        dayEnd.setHours(23, 59, 59, 999)
        startDate = dayStart.toISOString()
        endDate = dayEnd.toISOString()
      }

      const data = await eventService.getCalendarEvents(startDate, endDate)
      setEvents(Array.isArray(data) ? data : [])
    } catch (error: any) {
      console.error('Error loading calendar events:', error)
      toast.error('Erreur lors du chargement du calendrier')
    } finally {
      setIsLoading(false)
    }
  }

  const handleExportCalendar = async () => {
    try {
      const blob = await eventService.exportCalendar(true)
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `campuslink_calendar_${user?.username || 'calendar'}.ics`
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      document.body.removeChild(a)
      toast.success('Calendrier exporté avec succès!')
    } catch (error: any) {
      console.error('Error exporting calendar:', error)
      toast.error('Erreur lors de l\'export du calendrier')
    }
  }

  const getEventsForDate = (date: Date): CalendarEvent[] => {
    return events.filter(event => {
      const eventDate = new Date(event.start_date)
      return isSameDay(eventDate, date)
    })
  }

  const navigateMonth = (direction: 'prev' | 'next') => {
    setCurrentDate(prev => direction === 'prev' ? subMonths(prev, 1) : addMonths(prev, 1))
  }

  const navigateWeek = (direction: 'prev' | 'next') => {
    const days = direction === 'prev' ? -7 : 7
    setCurrentDate(prev => new Date(prev.getTime() + days * 24 * 60 * 60 * 1000))
  }

  const navigateDay = (direction: 'prev' | 'next') => {
    const days = direction === 'prev' ? -1 : 1
    setCurrentDate(prev => new Date(prev.getTime() + days * 24 * 60 * 60 * 1000))
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

  const monthStart = startOfMonth(currentDate)
  const monthEnd = endOfMonth(currentDate)
  const calendarStart = startOfWeek(monthStart, { weekStartsOn: 1 })
  const calendarEnd = endOfWeek(monthEnd, { weekStartsOn: 1 })
  const calendarDays = eachDayOfInterval({ start: calendarStart, end: calendarEnd })

  const weekStart = startOfWeek(currentDate, { weekStartsOn: 1 })
  const weekDays = eachDayOfInterval({ start: weekStart, end: endOfWeek(currentDate, { weekStartsOn: 1 }) })

  const dayEvents = getEventsForDate(currentDate)

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        {/* Header - Improved Design */}
        <div className="relative bg-gradient-to-br from-primary-500 via-primary-600 to-secondary-600 rounded-2xl shadow-xl p-5 sm:p-6 mb-6 overflow-hidden">
          {/* Decorative Background Elements */}
          <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16"></div>
          <div className="absolute bottom-0 left-0 w-24 h-24 bg-white/10 rounded-full -ml-12 -mb-12"></div>
          
          <div className="relative z-10 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 bg-white/20 backdrop-blur-sm rounded-xl flex items-center justify-center shadow-lg">
                <FiCalendar className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-2xl sm:text-3xl font-bold text-white drop-shadow-lg">Mon Calendrier</h1>
                <p className="text-sm sm:text-base text-white/90">Vos événements en un coup d'œil</p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <button
                onClick={handleExportCalendar}
                className="flex items-center gap-2 px-5 py-3 bg-white text-primary-600 rounded-xl hover:bg-white/90 transition-all duration-300 shadow-lg hover:shadow-xl hover:-translate-y-1 font-semibold"
              >
                <FiDownload className="w-4 h-4" />
                <span className="hidden sm:inline">Exporter</span>
              </button>
            </div>
          </div>

          {/* View Mode Selector */}
          <div className="mt-4 flex items-center gap-2">
            <button
              onClick={() => setViewMode('month')}
              className={`px-4 py-2 rounded-lg transition ${
                viewMode === 'month'
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Mois
            </button>
            <button
              onClick={() => setViewMode('week')}
              className={`px-4 py-2 rounded-lg transition ${
                viewMode === 'week'
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Semaine
            </button>
            <button
              onClick={() => setViewMode('day')}
              className={`px-4 py-2 rounded-lg transition ${
                viewMode === 'day'
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Jour
            </button>
          </div>

          {/* Navigation */}
          <div className="mt-4 flex items-center justify-between">
            <button
              onClick={() => {
                if (viewMode === 'month') navigateMonth('prev')
                else if (viewMode === 'week') navigateWeek('prev')
                else navigateDay('prev')
              }}
              className="p-2 hover:bg-gray-100 rounded-lg transition"
            >
              <FiChevronLeft className="w-5 h-5" />
            </button>
            <h2 className="text-lg font-semibold text-gray-900">
              {viewMode === 'month' && format(currentDate, 'MMMM yyyy')}
              {viewMode === 'week' && `Semaine du ${format(weekStart, 'd MMMM')}`}
              {viewMode === 'day' && format(currentDate, 'EEEE d MMMM yyyy')}
            </h2>
            <button
              onClick={() => {
                if (viewMode === 'month') navigateMonth('next')
                else if (viewMode === 'week') navigateWeek('next')
                else navigateDay('next')
              }}
              className="p-2 hover:bg-gray-100 rounded-lg transition"
            >
              <FiChevronRight className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Calendar View */}
        {isLoading ? (
          <div className="bg-white rounded-2xl shadow-xl p-12 text-center border border-gray-100">
            <div className="animate-spin rounded-full h-8 w-8 border-3 border-primary-600 border-t-transparent mx-auto"></div>
            <p className="mt-4 text-gray-600 font-medium">Chargement des événements...</p>
          </div>
        ) : viewMode === 'month' ? (
          <div className="bg-white rounded-2xl shadow-xl p-4 sm:p-6 border border-gray-100">
            {/* Weekday Headers */}
            <div className="grid grid-cols-7 gap-2 mb-2">
              {['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'].map(day => (
                <div key={day} className="text-center text-sm font-semibold text-gray-600 py-2">
                  {day}
                </div>
              ))}
            </div>

            {/* Calendar Grid */}
            <div className="grid grid-cols-7 gap-2">
              {calendarDays.map((day, idx) => {
                const dayEvents = getEventsForDate(day)
                const isCurrentMonth = isSameMonth(day, currentDate)
                const isToday = isSameDay(day, new Date())

                return (
                  <div
                    key={idx}
                    className={`min-h-24 sm:min-h-32 p-2 rounded-lg border ${
                      isCurrentMonth ? 'bg-white border-gray-200' : 'bg-gray-50 border-gray-100'
                    } ${isToday ? 'ring-2 ring-primary-500' : ''}`}
                  >
                    <div className={`text-sm font-medium mb-1 ${isCurrentMonth ? 'text-gray-900' : 'text-gray-400'} ${isToday ? 'text-primary-600' : ''}`}>
                      {format(day, 'd')}
                    </div>
                    <div className="space-y-1">
                      {dayEvents.slice(0, 3).map(event => (
                        <Link
                          key={event.id}
                          href={`/events/${event.id}`}
                          className={`block text-xs p-1 rounded truncate ${
                            event.calendar_type === 'participation'
                              ? 'bg-blue-100 text-blue-800'
                              : 'bg-purple-100 text-purple-800'
                          }`}
                          title={event.title}
                        >
                          {event.title}
                        </Link>
                      ))}
                      {dayEvents.length > 3 && (
                        <div className="text-xs text-gray-500">+{dayEvents.length - 3} autres</div>
                      )}
                    </div>
                  </div>
                )
              })}
            </div>
          </div>
        ) : viewMode === 'week' ? (
          <div className="bg-white rounded-2xl shadow-xl p-4 sm:p-6 border border-gray-100">
            <div className="space-y-4">
              {weekDays.map(day => {
                const dayEvents = getEventsForDate(day)
                const isToday = isSameDay(day, new Date())

                return (
                  <div key={day.toISOString()} className="border-b border-gray-200 pb-4 last:border-0">
                    <div className="flex items-center gap-4 mb-3">
                      <div className={`w-12 text-center ${isToday ? 'text-primary-600 font-bold' : 'text-gray-600'}`}>
                        <div className="text-sm">{format(day, 'EEE')}</div>
                        <div className="text-lg">{format(day, 'd')}</div>
                      </div>
                      <div className="flex-1">
                        {dayEvents.length === 0 ? (
                          <p className="text-sm text-gray-400">Aucun événement</p>
                        ) : (
                          <div className="space-y-2">
                            {dayEvents.map(event => (
                              <Link
                                key={event.id}
                                href={`/events/${event.id}`}
                                className="group block p-3 bg-gray-50 hover:bg-gray-100 rounded-xl transition-all duration-200 hover:shadow-md border border-gray-200 hover:border-primary-300"
                              >
                                <div className="flex items-start justify-between">
                                  <div className="flex-1">
                                    <h3 className="font-semibold text-gray-900">{event.title}</h3>
                                    <div className="flex items-center gap-3 mt-1 text-sm text-gray-600">
                                      <span className="flex items-center gap-1">
                                        <FiClock className="w-4 h-4" />
                                        {format(new Date(event.start_date), 'HH:mm')}
                                      </span>
                                      <span className="flex items-center gap-1">
                                        <FiMapPin className="w-4 h-4" />
                                        {event.location}
                                      </span>
                                    </div>
                                  </div>
                                  <span className={`px-2 py-1 rounded text-xs ${
                                    event.calendar_type === 'participation'
                                      ? 'bg-blue-100 text-blue-800'
                                      : 'bg-purple-100 text-purple-800'
                                  }`}>
                                    {event.calendar_type === 'participation' ? 'Participation' : 'Favori'}
                                  </span>
                                </div>
                              </Link>
                            ))}
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                )
              })}
            </div>
          </div>
        ) : (
          <div className="bg-white rounded-2xl shadow-xl p-4 sm:p-6 border border-gray-100">
            <div className="mb-4">
              <h3 className="text-lg font-semibold text-gray-900 mb-2">
                {format(currentDate, 'EEEE d MMMM yyyy')}
              </h3>
            </div>
            {dayEvents.length === 0 ? (
              <div className="text-center py-12">
                <FiCalendar className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                <p className="text-gray-600">Aucun événement ce jour</p>
              </div>
            ) : (
              <div className="space-y-4">
                {dayEvents.map(event => (
                  <Link
                    key={event.id}
                    href={`/events/${event.id}`}
                    className="group block p-4 bg-gray-50 hover:bg-gray-100 rounded-xl transition-all duration-200 border border-gray-200 hover:border-primary-300 hover:shadow-md"
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <h3 className="text-lg font-semibold text-gray-900 mb-2">{event.title}</h3>
                        <div className="space-y-2 text-sm text-gray-600">
                          <div className="flex items-center gap-2">
                            <FiClock className="w-4 h-4" />
                            <span>
                              {format(new Date(event.start_date), 'HH:mm')}
                              {event.end_date && ` - ${format(new Date(event.end_date), 'HH:mm')}`}
                            </span>
                          </div>
                          <div className="flex items-center gap-2">
                            <FiMapPin className="w-4 h-4" />
                            <span>{event.location}</span>
                          </div>
                          {event.participants_count !== undefined && (
                            <div className="flex items-center gap-2">
                              <FiUsers className="w-4 h-4" />
                              <span>{event.participants_count} participants</span>
                            </div>
                          )}
                        </div>
                      </div>
                      <span className={`px-3 py-1 rounded text-sm font-medium ${
                        event.calendar_type === 'participation'
                          ? 'bg-blue-100 text-blue-800'
                          : 'bg-purple-100 text-purple-800'
                      }`}>
                        {event.calendar_type === 'participation' ? 'Participation' : 'Favori'}
                      </span>
                    </div>
                  </Link>
                ))}
              </div>
            )}
          </div>
        )}

        {/* Legend */}
        <div className="mt-6 bg-white rounded-2xl shadow-lg p-4 sm:p-6">
          <h3 className="text-sm font-semibold text-gray-900 mb-3">Légende</h3>
          <div className="flex flex-wrap gap-4">
            <div className="flex items-center gap-2">
              <div className="w-4 h-4 bg-blue-100 rounded"></div>
              <span className="text-sm text-gray-600">Événements auxquels vous participez</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-4 h-4 bg-purple-100 rounded"></div>
              <span className="text-sm text-gray-600">Événements favoris</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

