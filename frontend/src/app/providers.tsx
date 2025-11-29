'use client'

import { useState, useEffect } from 'react'
import dynamic from 'next/dynamic'
import { QueryClient, QueryClientProvider } from 'react-query'
import { Toaster } from 'react-hot-toast'
import { AuthProvider } from '@/context/AuthContext'

// Load FirebaseProvider dynamically to avoid importing Firebase during build
const FirebaseProvider = dynamic(() => import('@/components/FirebaseProvider'), {
  ssr: false, // Disable server-side rendering for Firebase
})

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            refetchOnWindowFocus: false,
            retry: 1,
          },
        },
      })
  )

  useEffect(() => {
    // Ne pas désenregistrer le service worker Firebase
    // Le service worker Firebase sera géré par le composant FirebaseProvider
    // Cette logique a été supprimée pour éviter les conflits avec Firebase Messaging
  }, []);

  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <FirebaseProvider />
        {children}
        <Toaster position="top-right" />
      </AuthProvider>
    </QueryClientProvider>
  )
}

