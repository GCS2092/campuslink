'use client'

// Configuration Firebase depuis les variables d'environnement
const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
}

// Vérifier que toutes les variables sont présentes
if (typeof window !== 'undefined' && (!firebaseConfig.apiKey || !firebaseConfig.projectId)) {
  console.warn('⚠️ Firebase configuration is incomplete. Please check your environment variables.')
}

// Lazy load Firebase modules to avoid Node.js dependencies during build
let firebaseApp: any = null
let firebaseAuth: any = null
let firebaseFirestore: any = null
let firebaseMessaging: any = null

// Initialize Firebase only on client side
const initializeFirebase = async () => {
  if (typeof window === 'undefined') {
    return null
  }

  if (firebaseApp) {
    return firebaseApp
  }

  try {
    // Dynamic imports to avoid bundling Node.js modules
    const { initializeApp, getApps } = await import('firebase/app')
    
    if (getApps().length === 0) {
      firebaseApp = initializeApp(firebaseConfig)
    } else {
      firebaseApp = getApps()[0]
    }

    return firebaseApp
  } catch (error) {
    console.error('Error initializing Firebase:', error)
    return null
  }
}

// Get Firebase Auth (lazy loaded)
export const getAuthInstance = async () => {
  if (typeof window === 'undefined') {
    return null
  }

  if (firebaseAuth) {
    return firebaseAuth
  }

  try {
    const app = await initializeFirebase()
    if (!app) return null

    const { getAuth } = await import('firebase/auth')
    firebaseAuth = getAuth(app)
    return firebaseAuth
  } catch (error) {
    console.error('Error getting Firebase Auth:', error)
    return null
  }
}

// Get Firebase Firestore (lazy loaded)
export const getFirestoreInstance = async () => {
  if (typeof window === 'undefined') {
    return null
  }

  if (firebaseFirestore) {
    return firebaseFirestore
  }

  try {
    const app = await initializeFirebase()
    if (!app) return null

    const { getFirestore } = await import('firebase/firestore')
    firebaseFirestore = getFirestore(app)
    return firebaseFirestore
  } catch (error) {
    console.error('Error getting Firebase Firestore:', error)
    return null
  }
}

// Enregistrer le service worker pour les notifications push
const registerServiceWorker = async () => {
  if (typeof window === 'undefined' || !('serviceWorker' in navigator)) {
    return null
  }

  try {
    const registration = await navigator.serviceWorker.register('/firebase-messaging-sw.js', {
      scope: '/',
    })
    console.log('✅ Service Worker enregistré:', registration.scope)
    
    // Fonction pour envoyer la configuration
    const sendConfig = (target: ServiceWorker | null) => {
      if (target) {
        target.postMessage({
          type: 'FIREBASE_CONFIG',
          config: firebaseConfig,
        })
        console.log('📤 Configuration Firebase envoyée au Service Worker')
      }
    }
    
    // Envoyer la configuration Firebase au service worker
    if (registration.active) {
      sendConfig(registration.active)
    } else if (registration.installing) {
      registration.installing.addEventListener('statechange', () => {
        if (registration.active) {
          sendConfig(registration.active)
        }
      })
    } else if (registration.waiting) {
      sendConfig(registration.waiting)
    }
    
    // Attendre que le service worker soit prêt et renvoyer la config si nécessaire
    await navigator.serviceWorker.ready
    if (registration.active) {
      sendConfig(registration.active)
    }
    
    return registration
  } catch (error) {
    console.error('❌ Erreur lors de l\'enregistrement du Service Worker:', error)
    return null
  }
}

// Messaging (uniquement côté client)
export const getMessagingInstance = async (): Promise<any> => {
  if (typeof window === 'undefined' || !('Notification' in window)) {
    return null
  }

  if (firebaseMessaging) {
    return firebaseMessaging
  }

  try {
    const app = await initializeFirebase()
    if (!app) return null

    // Enregistrer le service worker d'abord
    await registerServiceWorker()
    
    // Attendre un peu pour que le service worker soit prêt
    await new Promise((resolve) => setTimeout(resolve, 1000))
    
    const { getMessaging } = await import('firebase/messaging')
    firebaseMessaging = getMessaging(app)
    return firebaseMessaging
  } catch (error) {
    console.warn('Firebase Messaging not available:', error)
    return null
  }
}

// Fonction pour demander la permission de notification
export const requestNotificationPermission = async (): Promise<string | null> => {
  if (typeof window === 'undefined' || !('Notification' in window)) {
    return null
  }

  try {
    const permission = await Notification.requestPermission()
    if (permission === 'granted') {
      const messaging = await getMessagingInstance()
      if (messaging) {
        // VAPID key - à récupérer dans Firebase Console > Project Settings > Cloud Messaging
        const vapidKey = process.env.NEXT_PUBLIC_FIREBASE_VAPID_KEY
        if (vapidKey) {
          const { getToken } = await import('firebase/messaging')
          const token = await getToken(messaging, { vapidKey })
          return token
        } else {
          console.warn('VAPID key not configured. Please add NEXT_PUBLIC_FIREBASE_VAPID_KEY to your environment variables.')
        }
      }
    }
    return null
  } catch (error) {
    console.error('Error requesting notification permission:', error)
    return null
  }
}

// Fonction pour écouter les messages en arrière-plan
export const onMessageListener = (): Promise<any> => {
  return new Promise(async (resolve, reject) => {
    if (typeof window === 'undefined') {
      reject(new Error('Firebase Messaging not available (server-side)'))
      return
    }

    try {
      const messaging = await getMessagingInstance()
      if (messaging) {
        const { onMessage } = await import('firebase/messaging')
        onMessage(messaging, (payload: any) => {
          resolve(payload)
        })
      } else {
        reject(new Error('Firebase Messaging not available'))
      }
    } catch (error) {
      reject(error)
    }
  })
}

// Export app for backward compatibility (lazy loaded)
export const getApp = async () => {
  return await initializeFirebase()
}

export default { getApp, getAuthInstance, getFirestoreInstance, getMessagingInstance }
