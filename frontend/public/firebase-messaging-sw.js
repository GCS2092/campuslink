// Service Worker pour Firebase Cloud Messaging
// Ce fichier doit être dans le dossier public/

importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js')
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js')

// Configuration Firebase
// Les valeurs seront récupérées depuis le message envoyé par le client
let firebaseApp = null
let messaging = null

// Fonction pour initialiser Firebase et Messaging
const initializeFirebase = (config) => {
  if (!firebaseApp && config && config.apiKey && config.projectId) {
    try {
      firebaseApp = firebase.initializeApp(config)
      messaging = firebase.messaging()
      console.log('✅ Firebase initialisé dans le Service Worker')
      
      // Configurer le gestionnaire de messages en arrière-plan
      if (messaging) {
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
      }
    } catch (error) {
      console.error('❌ Erreur lors de l\'initialisation de Firebase:', error)
    }
  }
}

// Écouter les messages du client pour recevoir la configuration
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'FIREBASE_CONFIG') {
    initializeFirebase(event.data.config)
  }
})

// Si la configuration est déjà disponible (via self.firebaseConfig)
if (self.firebaseConfig) {
  initializeFirebase(self.firebaseConfig)
}

// Gérer les clics sur les notifications
self.addEventListener('notificationclick', (event) => {
  console.log('Notification cliquée:', event)
  
  event.notification.close()

  // Ouvrir ou se concentrer sur la fenêtre de l'application
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      // Si une fenêtre est déjà ouverte, la mettre au premier plan
      for (let i = 0; i < clientList.length; i++) {
        const client = clientList[i]
        if (client.url === '/' && 'focus' in client) {
          return client.focus()
        }
      }
      // Sinon, ouvrir une nouvelle fenêtre
      if (clients.openWindow) {
        const url = event.notification.data?.url || '/'
        return clients.openWindow(url)
      }
    })
  )
})

