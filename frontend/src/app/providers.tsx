'use client'

import { useState, useEffect } from 'react'
import { QueryClient, QueryClientProvider } from 'react-query'
import { Toaster } from 'react-hot-toast'
import { AuthProvider } from '@/context/AuthContext'
import FirebaseProvider from '@/components/FirebaseProvider'

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

