import { initializeApp, getApps, FirebaseApp } from 'firebase/app'
import { getAuth, Auth } from 'firebase/auth'
import { getFirestore, Firestore } from 'firebase/firestore'
// Firebase Storage is not used in the frontend, so we don't import it to avoid Node.js module issues
// import { getStorage, FirebaseStorage } from 'firebase/storage'
import { getMessaging, Messaging, getToken, onMessage } from 'firebase/messaging'

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
if (!firebaseConfig.apiKey || !firebaseConfig.projectId) {
  console.warn('⚠️ Firebase configuration is incomplete. Please check your environment variables.')
}

// Initialiser Firebase (éviter les doubles initialisations)
let app: FirebaseApp
if (getApps().length === 0) {
  app = initializeApp(firebaseConfig)
} else {
  app = getApps()[0]
}

// Services Firebase
export const auth: Auth = getAuth(app)
export const db: Firestore = getFirestore(app)
// Firebase Storage is not used in the frontend, so we don't initialize it
// If needed in the future, initialize it conditionally: typeof window !== 'undefined' ? getStorage(app) : null
// export const storage: FirebaseStorage = getStorage(app)

// Enregistrer le service worker pour les notifications push
const registerServiceWorker = async () => {
  if (typeof window !== 'undefined' && 'serviceWorker' in navigator) {
    try {
      const registration = await navigator.serviceWorker.register('/firebase-messaging-sw.js', {
        scope: '/',
      })
      console.log('✅ Service Worker enregistré:', registration.scope)
      
      // Fonction pour envoyer la configuration
      const sendConfig = (target) => {
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
  return null
}

// Messaging (uniquement côté client)
export const getMessagingInstance = async (): Promise<Messaging | null> => {
  if (typeof window !== 'undefined' && 'Notification' in window) {
    try {
      // Enregistrer le service worker d'abord
      await registerServiceWorker()
      
      // Attendre un peu pour que le service worker soit prêt
      await new Promise((resolve) => setTimeout(resolve, 1000))
      
      return getMessaging(app)
    } catch (error) {
      console.warn('Firebase Messaging not available:', error)
      return null
    }
  }
  return null
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
    try {
      const messaging = await getMessagingInstance()
      if (messaging) {
        onMessage(messaging, (payload) => {
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

export default app

