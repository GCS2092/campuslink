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
  // Firebase temporairement désactivé
  return null
  
  // Code désactivé - à réactiver quand Firebase sera configuré correctement
  /*
  if (firebaseFunctions) {
    return firebaseFunctions
  }
  
  if (typeof window === 'undefined') {
    return null
  }
  
  try {
    const firebase = await import('@/lib/firebase')
    firebaseFunctions = {
      requestNotificationPermission: firebase.requestNotificationPermission,
      onMessageListener: firebase.onMessageListener,
    }
    return firebaseFunctions
  } catch (error) {
    console.error('Error loading Firebase functions:', error)
    return null
  }
  */
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

      // Demander la permission et obtenir le token
      const initializeMessaging = async () => {
        try {
          // Attendre que le service worker soit enregistré
          if ('serviceWorker' in navigator) {
            await navigator.serviceWorker.ready
          }
          
          const functions = await getFirebaseFunctions()
          if (!functions) return
          
          const fcmToken = await functions.requestNotificationPermission()
          if (fcmToken) {
            setToken(fcmToken)
            console.log('FCM Token:', fcmToken)
            // Envoyer le token au backend pour l'enregistrer
            try {
              await notificationService.registerFCMToken(fcmToken)
            } catch (error) {
              console.error('Error registering FCM token:', error)
            }
          }
        } catch (error) {
          console.error('Error initializing Firebase Messaging:', error)
        }
      }

      // Attendre un peu avant d'initialiser pour s'assurer que tout est prêt
      setTimeout(() => {
        initializeMessaging()
      }, 2000)

      // Configurer l'écoute des messages en temps réel (quand l'app est ouverte)
      const setupMessageListener = async () => {
        try {
          const functions = await getFirebaseFunctions()
          if (!functions) return
          
          // Cette fonction écoute les messages quand l'app est au premier plan
          // Les messages en arrière-plan sont gérés par le service worker
          const payload = await functions.onMessageListener()
          if (payload) {
            console.log('📨 Message reçu (app ouverte):', payload)
            
            // Afficher une notification toast
            if (payload.notification) {
              toast.success(payload.notification.title || 'Nouvelle notification', {
                description: payload.notification.body,
                duration: 5000,
              })
            }

            // Afficher une notification native du navigateur (optionnel, car l'app est ouverte)
            if ('Notification' in window && Notification.permission === 'granted') {
              new Notification(payload.notification?.title || 'CampusLink', {
                body: payload.notification?.body,
                icon: payload.notification?.icon || '/icon-192x192.png',
                badge: '/icon-192x192.png',
                tag: payload.data?.conversation_id || payload.data?.event_id || 'notification',
              })
            }
            
            // Réécouter pour le prochain message
            setupMessageListener()
          }
        } catch (error) {
          // Ne pas afficher d'erreur si c'est juste que messaging n'est pas disponible
          if (error instanceof Error && !error.message.includes('not available')) {
            console.error('Error listening to messages:', error)
          }
        }
      }

      // Démarrer l'écoute après un délai pour s'assurer que Firebase est initialisé
      setTimeout(() => {
        setupMessageListener()
      }, 3000)
    }
  }, [])

  const requestPermission = async () => {
    if (!isSupported) {
      toast.error('Les notifications ne sont pas supportées sur ce navigateur')
      return false
    }

    try {
      const functions = await getFirebaseFunctions()
      if (!functions) {
        toast.error('Firebase n\'est pas disponible')
        return false
      }
      
      const fcmToken = await functions.requestNotificationPermission()
      if (fcmToken) {
        setToken(fcmToken)
        setPermission('granted')
        toast.success('Notifications activées!')
        return true
      } else {
        setPermission(Notification.permission)
        if (Notification.permission === 'denied') {
          toast.error('Les notifications ont été refusées. Veuillez les activer dans les paramètres du navigateur.')
        }
        return false
      }
    } catch (error) {
      console.error('Error requesting permission:', error)
      toast.error('Erreur lors de la demande de permission')
      return false
    }
  }

  return {
    token,
    isSupported,
    permission,
    requestPermission,
  }
}

