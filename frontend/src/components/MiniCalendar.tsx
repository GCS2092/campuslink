'use client'

import { useState } from 'react'
import { FiChevronLeft, FiChevronRight } from 'react-icons/fi'

interface MiniCalendarProps {
  onDateSelect?: (date: Date) => void
  selectedDate?: Date
  className?: string
}

export default function MiniCalendar({ onDateSelect, selectedDate, className = '' }: MiniCalendarProps) {
  const [currentDate, setCurrentDate] = useState(selectedDate || new Date())
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
      
      days.push(
        <button
          key={day}
          onClick={() => handleDateClick(day)}
          className={`w-8 h-8 flex items-center justify-center text-xs rounded-lg transition-all ${
            isSelectedDate
              ? 'bg-primary-600 text-white font-bold shadow-md'
              : isTodayDate
              ? 'bg-primary-100 text-primary-700 font-semibold border-2 border-primary-500'
              : 'text-gray-700 hover:bg-gray-100 hover:text-primary-600'
          }`}
        >
          {day}
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
        <h3 className="text-sm font-bold text-gray-900">
          {monthNames[month]} {year}
        </h3>
        <button
          onClick={handleNextMonth}
          className="p-1.5 hover:bg-gray-100 rounded-lg transition-colors"
          aria-label="Mois suivant"
        >
          <FiChevronRight className="w-5 h-5 text-gray-600" />
        </button>
      </div>

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

