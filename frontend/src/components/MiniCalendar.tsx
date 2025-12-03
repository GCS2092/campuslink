'use client'

import { useState, useEffect } from 'react'
import { FiChevronLeft, FiChevronRight, FiCalendar } from 'react-icons/fi'
import { eventService, type Event } from '@/services/eventService'

interface MiniCalendarProps {
  onDateSelect?: (date: Date) => void
  selectedDate?: Date
  className?: string
}

export default function MiniCalendar({ onDateSelect, selectedDate, className = '' }: MiniCalendarProps) {
  const [currentDate, setCurrentDate] = useState(selectedDate || new Date())
  const [events, setEvents] = useState<Event[]>([])
  const [isLoadingEvents, setIsLoadingEvents] = useState(false)
  const today = new Date()
  today.setHours(0, 0, 0, 0)

  const year = currentDate.getFullYear()
  const month = currentDate.getMonth()

  const firstDayOfMonth = new Date(year, month, 1)
  const lastDayOfMonth = new Date(year, month + 1, 0)
  const daysInMonth = lastDayOfMonth.getDate()
  const startingDayOfWeek = firstDayOfMonth.getDay()

  const monthNames = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
  ]

  const dayNames = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam']

  const handlePreviousMonth = () => {
    setCurrentDate(new Date(year, month - 1, 1))
  }

  const handleNextMonth = () => {
    setCurrentDate(new Date(year, month + 1, 1))
  }

  const handleDateClick = (day: number) => {
    const clickedDate = new Date(year, month, day)
    clickedDate.setHours(0, 0, 0, 0)
    if (onDateSelect) {
      onDateSelect(clickedDate)
    }
  }

  const isToday = (day: number) => {
    const date = new Date(year, month, day)
    date.setHours(0, 0, 0, 0)
    return date.getTime() === today.getTime()
  }

  const isSelected = (day: number) => {
    if (!selectedDate) return false
    const date = new Date(year, month, day)
    date.setHours(0, 0, 0, 0)
    const selDate = new Date(selectedDate)
    selDate.setHours(0, 0, 0, 0)
    return date.getTime() === selDate.getTime()
  }

  const hasEvents = (day: number) => {
    const date = new Date(year, month, day)
    date.setHours(0, 0, 0, 0)
    return events.some((event) => {
      const eventDate = new Date(event.start_date)
      eventDate.setHours(0, 0, 0, 0)
      return eventDate.getTime() === date.getTime()
    })
  }

  const getEventCount = (day: number) => {
    const date = new Date(year, month, day)
    date.setHours(0, 0, 0, 0)
    return events.filter((event) => {
      const eventDate = new Date(event.start_date)
      eventDate.setHours(0, 0, 0, 0)
      return eventDate.getTime() === date.getTime()
    }).length
  }

  // Load events for the current month
  useEffect(() => {
    const loadEvents = async () => {
      setIsLoadingEvents(true)
      try {
        const firstDay = new Date(year, month, 1)
        const lastDay = new Date(year, month + 1, 0)
        const startDate = firstDay.toISOString().split('T')[0]
        const endDate = lastDay.toISOString().split('T')[0]
        
        const data = await eventService.getCalendarEvents(startDate, endDate)
        const eventsList = Array.isArray(data) ? data : data?.results || []
        setEvents(eventsList)
      } catch (error) {
        console.error('Error loading calendar events:', error)
        setEvents([])
      } finally {
        setIsLoadingEvents(false)
      }
    }

    loadEvents()
  }, [year, month])

  const renderDays = () => {
    const days = []
    
    // Jours vides avant le premier jour du mois
    for (let i = 0; i < startingDayOfWeek; i++) {
      days.push(
        <div key={`empty-${i}`} className="w-8 h-8"></div>
      )
    }

    // Jours du mois
    for (let day = 1; day <= daysInMonth; day++) {
      const isTodayDate = isToday(day)
      const isSelectedDate = isSelected(day)
      const dayHasEvents = hasEvents(day)
      const eventCount = getEventCount(day)
      
      days.push(
        <button
          key={day}
          onClick={() => handleDateClick(day)}
          className={`w-8 h-8 flex flex-col items-center justify-center text-xs rounded-lg transition-all relative ${
            isSelectedDate
              ? 'bg-primary-600 text-white font-bold shadow-md'
              : isTodayDate
              ? 'bg-primary-100 text-primary-700 font-semibold border-2 border-primary-500'
              : 'text-gray-700 hover:bg-gray-100 hover:text-primary-600'
          }`}
          title={dayHasEvents ? `${eventCount} événement(s) ce jour` : undefined}
        >
          <span>{day}</span>
          {dayHasEvents && !isSelectedDate && (
            <span className={`absolute bottom-0.5 w-1 h-1 rounded-full ${
              isTodayDate ? 'bg-primary-600' : 'bg-primary-500'
            }`}></span>
          )}
        </button>
      )
    }

    return days
  }

  return (
    <div className={`bg-white rounded-xl shadow-md p-4 border border-gray-100 ${className}`}>
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <button
          onClick={handlePreviousMonth}
          className="p-1.5 hover:bg-gray-100 rounded-lg transition-colors"
          aria-label="Mois précédent"
        >
          <FiChevronLeft className="w-5 h-5 text-gray-600" />
        </button>
        <div className="flex items-center gap-2">
          <FiCalendar className="w-4 h-4 text-primary-600" />
          <h3 className="text-sm font-bold text-gray-900">
            {monthNames[month]} {year}
          </h3>
        </div>
        <button
          onClick={handleNextMonth}
          className="p-1.5 hover:bg-gray-100 rounded-lg transition-colors"
          aria-label="Mois suivant"
        >
          <FiChevronRight className="w-5 h-5 text-gray-600" />
        </button>
      </div>
      
      {/* Events indicator legend */}
      {events.length > 0 && (
        <div className="mb-2 flex items-center gap-2 text-xs text-gray-500">
          <span className="w-1 h-1 rounded-full bg-primary-500"></span>
          <span>Jour avec événement</span>
        </div>
      )}

      {/* Day names */}
      <div className="grid grid-cols-7 gap-1 mb-2">
        {dayNames.map((day) => (
          <div key={day} className="w-8 h-8 flex items-center justify-center text-xs font-semibold text-gray-500">
            {day}
          </div>
        ))}
      </div>

      {/* Calendar grid */}
      <div className="grid grid-cols-7 gap-1">
        {renderDays()}
      </div>
    </div>
  )
}

