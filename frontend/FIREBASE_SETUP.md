# 🔥 Guide de Configuration Firebase pour Next.js

## Problème rencontré

Firebase utilise des modules Node.js (`undici`) qui ne sont pas disponibles côté client, causant des erreurs de build sur Vercel.

## Solution : Utiliser Firebase uniquement côté client

### Option 1 : Utiliser `firebase/compat` (Recommandé)
FIRE BASE MESSAN PUSH
Le SDK `firebase/compat` est mieux adapté pour Next.js et évite les problèmes avec les modules Node.js.

#### Étape 1 : Installer Firebase

```bash
cd frontend
npm install firebase
```

#### Étape 2 : Créer `frontend/src/lib/firebase.ts`

```typescript
'use client'

// Utiliser firebase/compat pour éviter les problèmes avec les modules Node.js
import firebase from 'firebase/compat/app'
import 'firebase/compat/auth'
import 'firebase/compat/firestore'
import 'firebase/compat/messaging'

// Configuration Firebase depuis les variables d'environnement
const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
}

// Initialiser Firebase uniquement côté client
let app: firebase.app.App | null = null

if (typeof window !== 'undefined') {
  if (!firebase.apps.length) {
    app = firebase.initializeApp(firebaseConfig)
  } else {
    app = firebase.app()
  }
}

// Services Firebase (uniquement côté client)
export const auth = typeof window !== 'undefined' ? firebase.auth() : null
export const db = typeof window !== 'undefined' ? firebase.firestore() : null

// Messaging (uniquement côté client)
export const getMessaging = () => {
  if (typeof window === 'undefined' || !('Notification' in window)) {
    return null
  }
  return firebase.messaging()
}

// Fonction pour demander la permission de notification
export const requestNotificationPermission = async (): Promise<string | null> => {
  if (typeof window === 'undefined' || !('Notification' in window)) {
    return null
  }

  try {
    const permission = await Notification.requestPermission()
    if (permission === 'granted') {
      const messaging = getMessaging()
      if (messaging) {
        const vapidKey = process.env.NEXT_PUBLIC_FIREBASE_VAPID_KEY
        if (vapidKey) {
          const token = await messaging.getToken({ vapidKey })
          return token
        }
      }
    }
    return null
  } catch (error) {
    console.error('Error requesting notification permission:', error)
    return null
  }
}

// Fonction pour écouter les messages
export const onMessageListener = (callback: (payload: any) => void) => {
  if (typeof window === 'undefined') {
    return () => {}
  }

  const messaging = getMessaging()
  if (messaging) {
    return messaging.onMessage(callback)
  }
  return () => {}
}

export default app
```

#### Étape 3 : Mettre à jour `frontend/src/hooks/useFirebaseMessaging.ts`

```typescript
'use client'

import { useEffect, useState } from 'react'
import { requestNotificationPermission, onMessageListener } from '@/lib/firebase'
import { notificationService } from '@/services/notificationService'
import toast from 'react-hot-toast'

export const useFirebaseMessaging = () => {
  const [token, setToken] = useState<string | null>(null)
  const [isSupported, setIsSupported] = useState(false)
  const [permission, setPermission] = useState<NotificationPermission>('default')

  useEffect(() => {
    if (typeof window !== 'undefined' && 'Notification' in window) {
      setIsSupported(true)
      setPermission(Notification.permission)

      // Initialiser Firebase Messaging
      const initializeMessaging = async () => {
        try {
          if ('serviceWorker' in navigator) {
            await navigator.serviceWorker.ready
          }
          
          const fcmToken = await requestNotificationPermission()
          if (fcmToken) {
            setToken(fcmToken)
            console.log('FCM Token:', fcmToken)
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

      setTimeout(() => {
        initializeMessaging()
      }, 2000)

      // Écouter les messages
      const unsubscribe = onMessageListener((payload) => {
        console.log('📨 Message reçu:', payload)
        
        if (payload.notification) {
          toast.success(payload.notification.title || 'Nouvelle notification', {
            description: payload.notification.body,
            duration: 5000,
          })
        }
      })

      return () => {
        unsubscribe()
      }
    }
  }, [])

  const requestPermission = async () => {
    if (!isSupported) {
      toast.error('Les notifications ne sont pas supportées sur ce navigateur')
      return false
    }

    try {
      const fcmToken = await requestNotificationPermission()
      if (fcmToken) {
        setToken(fcmToken)
        setPermission('granted')
        toast.success('Notifications activées!')
        return true
      } else {
        setPermission(Notification.permission)
        if (Notification.permission === 'denied') {
          toast.error('Les notifications ont été refusées.')
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
```

#### Étape 4 : Réactiver FirebaseProvider dans `frontend/src/app/providers.tsx`

```typescript
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
```

#### Étape 5 : Mettre à jour le Service Worker `frontend/public/firebase-messaging-sw.js`

```javascript
// Service Worker pour Firebase Cloud Messaging
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js')
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js')

let firebaseApp = null
let messaging = null

const initializeFirebase = (config) => {
  if (!firebaseApp && config && config.apiKey && config.projectId) {
    try {
      firebaseApp = firebase.initializeApp(config)
      messaging = firebase.messaging()
      console.log('✅ Firebase initialisé dans le Service Worker')
      
      messaging.onBackgroundMessage((payload) => {
        console.log('📨 Message reçu en arrière-plan:', payload)

        const notificationTitle = payload.notification?.title || 'CampusLink'
        const notificationOptions = {
          body: payload.notification?.body || 'Vous avez une nouvelle notification',
          icon: payload.notification?.icon || '/icon-192x192.png',
          badge: '/icon-192x192.png',
          tag: payload.data?.conversation_id || payload.data?.event_id || 'notification',
          data: payload.data,
        }

        return self.registration.showNotification(notificationTitle, notificationOptions)
      })
    } catch (error) {
      console.error('❌ Erreur lors de l\'initialisation de Firebase:', error)
    }
  }
}

self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'FIREBASE_CONFIG') {
    initializeFirebase(event.data.config)
  }
})

self.addEventListener('notificationclick', (event) => {
  console.log('Notification cliquée:', event)
  
  event.notification.close()

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      for (let i = 0; i < clientList.length; i++) {
        const client = clientList[i]
        if (client.url === '/' && 'focus' in client) {
          return client.focus()
        }
      }
      if (clients.openWindow) {
        const url = event.notification.data?.url || '/'
        return clients.openWindow(url)
      }
    })
  )
})
```

### Option 2 : Utiliser une bibliothèque alternative

Si `firebase/compat` ne fonctionne toujours pas, vous pouvez utiliser une bibliothèque alternative comme :
- `react-firebase-hooks` - Hooks React pour Firebase
- `@react-firebase/auth` - Authentification Firebase pour React

## Variables d'environnement requises

Dans Vercel (Settings → Environment Variables), ajoutez :

```
NEXT_PUBLIC_FIREBASE_API_KEY=your-api-key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your-project-id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your-project.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your-sender-id
NEXT_PUBLIC_FIREBASE_APP_ID=your-app-id
NEXT_PUBLIC_FIREBASE_VAPID_KEY=your-vapid-key
```

## Étapes pour réactiver Firebase

1. **Renommer le fichier désactivé :**
   ```bash
   git mv frontend/src/lib/firebase.ts.disabled frontend/src/lib/firebase.ts
   ```

2. **Créer le nouveau fichier `firebase.ts`** avec le code de l'Option 1 ci-dessus

3. **Mettre à jour `useFirebaseMessaging.ts`** avec le nouveau code

4. **Réactiver `FirebaseProvider`** dans `providers.tsx`

5. **Tester localement :**
   ```bash
   cd frontend
   npm run dev
   ```

6. **Vérifier que le build fonctionne :**
   ```bash
   npm run build
   ```

7. **Si le build réussit, commit et push :**
   ```bash
   git add .
   git commit -m "feat: Réactivation de Firebase avec firebase/compat"
   git push origin main
   ```

## Notes importantes

- `firebase/compat` utilise l'ancienne API Firebase mais est mieux supporté par Next.js
- Tous les imports Firebase doivent être conditionnels (`typeof window !== 'undefined'`)
- Le service worker doit être configuré correctement pour les notifications push
- Les variables d'environnement doivent être configurées dans Vercel

## Dépannage

Si vous rencontrez encore des erreurs :

1. **Vérifiez que vous utilisez `firebase/compat`** et non `firebase/app`
2. **Assurez-vous que tous les imports sont conditionnels** côté client
3. **Vérifiez que le service worker est correctement configuré**
4. **Vérifiez les variables d'environnement** dans Vercel

