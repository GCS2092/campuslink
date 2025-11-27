'use client'

import { usePathname, useRouter } from 'next/navigation'
import { useAuth } from '@/context/AuthContext'
import { FiHome, FiUsers, FiUserCheck, FiFileText, FiCalendar, FiUsers as FiGroupsIcon, FiShield, FiAlertCircle } from 'react-icons/fi'

interface NavItem {
  path: string
  icon: React.ComponentType<{ className?: string }>
  label: string
  adminOnly?: boolean
}

const navItems: NavItem[] = [
  { path: '/admin/dashboard', icon: FiHome, label: 'Dashboard' },
  { path: '/admin/students', icon: FiUsers, label: 'Étudiants' },
  { path: '/admin/users', icon: FiUserCheck, label: 'Vérifications' },
  { path: '/admin/moderation', icon: FiShield, label: 'Modération' },
  { path: '/admin/class-leaders', icon: FiUserCheck, label: 'Responsables', adminOnly: true },
  { path: '/events', icon: FiCalendar, label: 'Événements' },
  { path: '/groups', icon: FiGroupsIcon, label: 'Groupes' },
  { path: '/feed/manage', icon: FiFileText, label: 'Actualités' },
]

export default function AdminBottomNavigation() {
  const pathname = usePathname()
  const router = useRouter()
  const auth = useAuth()
  const user = auth?.user || null
  
  // Only show on admin pages and admin-accessible pages
  if (!pathname?.startsWith('/admin') && pathname !== '/feed/manage' && pathname !== '/events' && pathname !== '/groups') {
    return null
  }

  // Only show if user is admin or class leader
  if (user?.role !== 'admin' && user?.role !== 'class_leader') {
    return null
  }

  // Filter nav items based on user role
  const filteredNavItems = navItems.filter(item => {
    if (item.adminOnly && user?.role !== 'admin') {
      return false
    }
    return true
  })

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 z-50 shadow-lg safe-area-bottom">
      <div className="max-w-7xl mx-auto">
        <div className="flex items-center justify-around h-18 sm:h-20">
          {filteredNavItems.map((item) => {
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

