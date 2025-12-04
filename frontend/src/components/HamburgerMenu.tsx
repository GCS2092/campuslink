'use client'

import { useState, useEffect, useRef } from 'react'
import { useRouter, usePathname } from 'next/navigation'
import { FiMenu, FiX, FiCalendar, FiSearch, FiUsers, FiBell } from 'react-icons/fi'

export default function HamburgerMenu() {
  const [isOpen, setIsOpen] = useState(false)
  const router = useRouter()
  const pathname = usePathname()
  const menuRef = useRef<HTMLDivElement>(null)

  const menuItems = [
    { icon: FiBell, label: 'Pour vous', path: '/notifications', color: 'purple' },
    { icon: FiCalendar, label: 'Calendrier', path: '/calendar', color: 'indigo' },
    { icon: FiSearch, label: 'Recherche', path: '/search', color: 'teal' },
    { icon: FiUsers, label: 'Activité Amis', path: '/friends-activity', color: 'pink' },
  ]

  const handleItemClick = (path: string) => {
    router.push(path)
    setIsOpen(false)
  }

  // Fermer le menu si on clique en dehors
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setIsOpen(false)
      }
    }

    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside)
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside)
    }
  }, [isOpen])

  // Fermer le menu si la route change
  useEffect(() => {
    setIsOpen(false)
  }, [pathname])

  return (
    <div className="relative" ref={menuRef}>
      {/* Hamburger Button - Improved Design */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="p-2.5 text-white hover:bg-white/20 rounded-xl transition-all duration-200 hover:scale-105 active:scale-95"
        title="Menu"
        aria-label="Menu"
      >
        <div className="relative w-6 h-6">
          <FiMenu 
            className={`absolute inset-0 w-6 h-6 transition-all duration-300 ${isOpen ? 'opacity-0 rotate-90' : 'opacity-100 rotate-0'}`} 
          />
          <FiX 
            className={`absolute inset-0 w-6 h-6 transition-all duration-300 ${isOpen ? 'opacity-100 rotate-0' : 'opacity-0 -rotate-90'}`} 
          />
        </div>
      </button>

      {/* Menu Dropdown - Improved Design */}
      {isOpen && (
        <>
          {/* Backdrop with blur */}
          <div
            className="fixed inset-0 z-40 bg-black/20 backdrop-blur-sm transition-opacity duration-300"
            onClick={() => setIsOpen(false)}
          />

          {/* Menu - Enhanced Design */}
          <div className="absolute left-0 top-full mt-2 w-64 bg-white rounded-2xl shadow-2xl border border-gray-200 z-50 overflow-hidden animate-in fade-in slide-in-from-top-2 duration-200">
            {/* Header */}
            <div className="bg-gradient-to-r from-primary-500 to-secondary-500 px-4 py-3 border-b border-primary-600">
              <h3 className="text-sm font-bold text-white uppercase tracking-wide">Navigation rapide</h3>
            </div>
            
            {/* Menu Items */}
            <div className="p-2 space-y-1">
              {menuItems.map((item, index) => {
                const Icon = item.icon
                const isActive = pathname === item.path || pathname?.startsWith(item.path + '/')
                
                // Classes de couleur selon l'item
                const getColorClasses = (color: string, active: boolean) => {
                  if (!active) return 'hover:bg-gray-50 text-gray-700'
                  
                  switch (color) {
                    case 'purple':
                      return 'bg-purple-50 text-purple-600 hover:bg-purple-100'
                    case 'indigo':
                      return 'bg-indigo-50 text-indigo-600 hover:bg-indigo-100'
                    case 'teal':
                      return 'bg-teal-50 text-teal-600 hover:bg-teal-100'
                    case 'pink':
                      return 'bg-pink-50 text-pink-600 hover:bg-pink-100'
                    default:
                      return 'bg-gray-50 text-gray-600 hover:bg-gray-100'
                  }
                }
                
                const getIconColor = (color: string, active: boolean) => {
                  if (!active) return 'text-gray-600'
                  
                  switch (color) {
                    case 'purple':
                      return 'text-purple-600'
                    case 'indigo':
                      return 'text-indigo-600'
                    case 'teal':
                      return 'text-teal-600'
                    case 'pink':
                      return 'text-pink-600'
                    default:
                      return 'text-gray-600'
                  }
                }
                
                const getTextColor = (color: string, active: boolean) => {
                  if (!active) return 'text-gray-900'
                  
                  switch (color) {
                    case 'purple':
                      return 'text-purple-700'
                    case 'indigo':
                      return 'text-indigo-700'
                    case 'teal':
                      return 'text-teal-700'
                    case 'pink':
                      return 'text-pink-700'
                    default:
                      return 'text-gray-700'
                  }
                }
                
                return (
                  <button
                    key={item.path}
                    onClick={() => handleItemClick(item.path)}
                    className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 text-left group ${
                      getColorClasses(item.color, isActive)
                    }`}
                    style={{ animationDelay: `${index * 50}ms` }}
                  >
                    <div className={`p-2 rounded-lg transition-all duration-200 ${
                      isActive 
                        ? 'bg-white shadow-sm'
                        : 'bg-gray-100 group-hover:bg-gray-200'
                    }`}>
                      <Icon className={`w-5 h-5 ${getIconColor(item.color, isActive)}`} />
                    </div>
                    <span className={`text-sm font-semibold flex-1 ${getTextColor(item.color, isActive)}`}>
                      {item.label}
                    </span>
                    {isActive && (
                      <div className="w-2 h-2 rounded-full bg-current"></div>
                    )}
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

