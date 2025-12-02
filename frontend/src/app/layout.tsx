import type { Metadata, Viewport } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { Providers } from './providers'
import BottomNavigation from '@/components/BottomNavigation'
import AdminBottomNavigation from '@/components/AdminBottomNavigation'
import UniversityAdminBottomNavigation from '@/components/UniversityAdminBottomNavigation'
import PageLoader from '@/components/PageLoader'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'CampusLink - Réseau Social Étudiant',
  description: 'Connecte ton campus, partage ta vie',
  manifest: '/manifest.json',
}

export const viewport: Viewport = {
  themeColor: '#0ea5e9',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="fr">
      <body className={inter.className}>
        <Providers>
          <PageLoader />
          {children}
          <BottomNavigation />
          <AdminBottomNavigation />
          <UniversityAdminBottomNavigation />
        </Providers>
      </body>
    </html>
  )
}

