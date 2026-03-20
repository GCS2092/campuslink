import type { Metadata, Viewport } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { Providers } from './providers'
import BottomNavigation from '@/components/BottomNavigation'
import AdminBottomNavigation from '@/components/AdminBottomNavigation'
import UniversityAdminBottomNavigation from '@/components/UniversityAdminBottomNavigation'
import PageLoader from '@/components/PageLoader'
import PwaProvider from '@/components/PwaProvider'

// ❌ Supprime cette ligne
// import 'leaflet/dist/leaflet.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'CampusLink - Réseau Social Étudiant',
  description: 'Connecte ton campus, partage ta vie',
  manifest: '/manifest.json',
  appleWebApp: {
    capable: true,
    statusBarStyle: 'default',
    title: 'CampusLink',
  },
  other: {
    'mobile-web-app-capable': 'yes',
  },
  icons: {
    apple: [
      { url: '/icons/icon-152x152.png', sizes: '152x152', type: 'image/png' },
      { url: '/icons/icon-192x192.png', sizes: '192x192', type: 'image/png' },
    ],
  },
}

export const viewport: Viewport = {
  themeColor: '#0ea5e9',
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="fr">
      <head>
        {/* ✅ Leaflet CSS via CDN */}
        <link
          rel="stylesheet"
          href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
          integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
          crossOrigin=""
        />
      </head>
      <body className={inter.className}>
        <PwaProvider />
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