'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { FiMenu, FiX, FiCalendar, FiSearch, FiUsers } from 'react-icons/fi'

export default function HamburgerMenu() {
  const [isOpen, setIsOpen] = useState(false)
  const router = useRouter()

  const menuItems = [
    { icon: FiCalendar, label: 'Calendrier', path: '/calendar' },
    { icon: FiSearch, label: 'Recherche', path: '/search' },
    { icon: FiUsers, label: 'Activité Amis', path: '/friends-activity' },
  ]

  const handleItemClick = (path: string) => {
    router.push(path)
    setIsOpen(false)
  }

  return (
    <div className="relative">
      {/* Hamburger Button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="p-2.5 text-white hover:bg-white/20 rounded-xl transition-all duration-200"
        title="Menu"
        aria-label="Menu"
      >
        {isOpen ? (
          <FiX className="w-6 h-6" />
        ) : (
          <FiMenu className="w-6 h-6" />
        )}
      </button>

      {/* Menu Dropdown */}
      {isOpen && (
        <>
          {/* Backdrop */}
          <div
            className="fixed inset-0 z-40"
            onClick={() => setIsOpen(false)}
          />

          {/* Menu */}
          <div className="absolute left-0 top-full mt-2 w-56 bg-white rounded-xl shadow-2xl border border-gray-200 z-50 overflow-hidden">
            <div className="p-2">
              {menuItems.map((item) => {
                const Icon = item.icon
                return (
                  <button
                    key={item.path}
                    onClick={() => handleItemClick(item.path)}
                    className="w-full flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-gray-100 transition-colors text-left"
                  >
                    <Icon className="w-5 h-5 text-gray-600" />
                    <span className="text-sm font-medium text-gray-900">{item.label}</span>
                  </button>
                )
              })}
            </div>
          </div>
        </>
      )}
    </div>
  )
}

