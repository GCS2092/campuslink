'use client'

import { useEffect } from 'react'

/**
 * Enregistre le Service Worker pour rendre l'app installable en PWA.
 * Requis pour le critère d'installation (Chrome, Edge, etc.).
 */
export default function PwaProvider() {
  useEffect(() => {
    if (typeof window === 'undefined' || !('serviceWorker' in navigator)) return

    const register = async () => {
      try {
        const reg = await navigator.serviceWorker.register('/sw.js', { scope: '/' })
        if (reg.installing) {
          console.log('[PWA] Service worker installing')
        } else if (reg.waiting) {
          console.log('[PWA] Service worker waiting')
        } else if (reg.active) {
          console.log('[PWA] Service worker active')
        }
      } catch (e) {
        console.warn('[PWA] Service worker registration failed:', e)
      }
    }

    register()
  }, [])

  return null
}
