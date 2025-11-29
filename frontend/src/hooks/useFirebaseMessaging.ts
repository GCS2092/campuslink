'use client'

import { useEffect, useState } from 'react'
import { notificationService } from '@/services/notificationService'
import toast from 'react-hot-toast'

// Lazy load Firebase functions to avoid importing during build
let firebaseFunctions: {
  requestNotificationPermission: () => Promise<string | null>
  onMessageListener: () => Promise<any>
} | null = null

const getFirebaseFunctions = async () => {
  // Firebase temporairement désactivé pour permettre le build
  // TODO: Réactiver Firebase avec une meilleure configuration
  return null
}

interface NotificationPayload {
  notification?: {
    title?: string
    body?: string
    icon?: string
  }
  data?: {
    [key: string]: string
  }
}

export const useFirebaseMessaging = () => {
  const [token, setToken] = useState<string | null>(null)
  const [isSupported, setIsSupported] = useState(false)
  const [permission, setPermission] = useState<NotificationPermission>('default')

  useEffect(() => {
    // Vérifier si les notifications sont supportées
    if (typeof window !== 'undefined' && 'Notification' in window) {
      setIsSupported(true)
      setPermission(Notification.permission)

      // Firebase temporairement désactivé
      // TODO: Réactiver Firebase avec une meilleure configuration
      console.log('Firebase Messaging est temporairement désactivé')
    }
  }, [])

  const requestPermission = async () => {
    if (!isSupported) {
      toast.error('Les notifications ne sont pas supportées sur ce navigateur')
      return false
    }

    // Firebase temporairement désactivé
    toast.error('Les notifications Firebase sont temporairement désactivées')
    return false
  }

  return {
    token,
    isSupported,
    permission,
    requestPermission,
  }
}

