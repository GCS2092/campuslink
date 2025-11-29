'use client'

import { useFirebaseMessaging } from '@/hooks/useFirebaseMessaging'
import { useEffect } from 'react'

/**
 * Composant qui initialise Firebase Messaging pour les notifications push
 * Ce composant doit être utilisé une seule fois dans l'application (dans Providers)
 */
export default function FirebaseProvider() {
  const { token, permission, isSupported } = useFirebaseMessaging()

  useEffect(() => {
    // Log pour le débogage (uniquement en développement)
    if (process.env.NODE_ENV === 'development') {
      if (isSupported) {
        console.log('🔔 Firebase Messaging:', {
          supported: true,
          permission,
          token: token ? '✅ Enregistré' : '❌ Non disponible',
        })
      } else {
        console.log('🔔 Firebase Messaging: Non supporté sur ce navigateur')
      }
    }
  }, [token, permission, isSupported])

  // Ce composant ne rend rien, il initialise juste Firebase en arrière-plan
  return null
}

