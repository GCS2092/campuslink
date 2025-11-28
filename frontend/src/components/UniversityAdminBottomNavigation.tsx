'use client'

import { usePathname, useRouter } from 'next/navigation'
import { useAuth } from '@/context/AuthContext'
import { FiHome, FiUsers, FiUserCheck, FiShield, FiSettings, FiMapPin, FiBook, FiFileText } from 'react-icons/fi'

interface NavItem {
  path: string
  icon: React.ComponentType<{ className?: string }>
  label: string
  submenu?: NavItem[]
}

const navItems: NavItem[] = [
  { path: '/university-admin/dashboard', icon: FiHome, label: 'Dashboard' },
  { path: '/university-admin/students', icon: FiUsers, label: 'Étudiants' },
  { path: '/university-admin/class-leaders', icon: FiUserCheck, label: 'Responsables' },
  { path: '/university-admin/moderation', icon: FiShield, label: 'Modération' },
  { path: '/university-admin/users', icon: FiUserCheck, label: 'Vérifications' },
  { path: '/university-admin/settings', icon: FiSettings, label: 'Paramètres' },
]

export default function UniversityAdminBottomNavigation() {
  const pathname = usePathname()
  const router = useRouter()
  const auth = useAuth()
  const user = auth?.user || null
  
  // Only show on university-admin pages
  if (!pathname?.startsWith('/university-admin')) {
    return null
  }

  // Only show if user is university_admin
  if (user?.role !== 'university_admin') {
    return null
  }

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 z-50 shadow-lg safe-area-bottom">
      <div className="max-w-7xl mx-auto">
        <div className="flex items-center justify-around h-18 sm:h-20">
          {navItems.map((item) => {
            const Icon = item.icon
            const isActive = pathname === item.path || pathname?.startsWith(item.path + '/')
            
            return (
              <button
                key={item.path}
                onClick={() => router.push(item.path)}
                className={`
                  relative flex flex-col items-center justify-center gap-1.5 py-2.5 px-3 sm:px-4 
                  flex-1 max-w-[120px] transition-all duration-200
                  ${isActive 
                    ? 'text-primary-600' 
                    : 'text-gray-500 hover:text-primary-500 active:scale-95'
                  }
                `}
                title={item.label}
              >
                <Icon className={`w-7 h-7 sm:w-8 sm:h-8 ${isActive ? 'text-primary-600' : ''}`} />
                <span className={`text-[11px] sm:text-xs font-medium ${isActive ? 'text-primary-600' : 'text-gray-600'}`}>
                  {item.label}
                </span>
                {isActive && (
                  <div className="absolute top-0 left-1/2 transform -translate-x-1/2 w-14 h-1 bg-primary-600 rounded-b-full" />
                )}
              </button>
            )
          })}
        </div>
      </div>
    </nav>
  )
}

