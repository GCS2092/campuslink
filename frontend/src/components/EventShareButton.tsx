'use client'

import { useState, useEffect, useCallback } from 'react'
import { FiShare2, FiFacebook, FiTwitter, FiLinkedin, FiMail, FiLink, FiX } from 'react-icons/fi'
import { eventService } from '@/services/eventService'
import toast from 'react-hot-toast'

interface EventShareButtonProps {
  eventId: string
  eventTitle: string
  className?: string
}

export default function EventShareButton({ eventId, eventTitle, className = '' }: EventShareButtonProps) {
  const [isOpen, setIsOpen] = useState(false)
  const [shareLinks, setShareLinks] = useState<any>(null)
  const [isLoading, setIsLoading] = useState(false)

  const loadShareLinks = useCallback(async () => {
    setIsLoading(true)
    try {
      const links = await eventService.getShareLinks(eventId)
      setShareLinks(links)
    } catch (error: any) {
      console.error('Error loading share links:', error)
      toast.error('Erreur lors du chargement des liens de partage')
    } finally {
      setIsLoading(false)
    }
  }, [eventId])

  useEffect(() => {
    if (isOpen && !shareLinks) {
      loadShareLinks()
    }
  }, [isOpen, shareLinks, loadShareLinks])

  useEffect(() => {
    if (isOpen && !shareLinks) {
      loadShareLinks()
    }
  }, [isOpen, shareLinks, loadShareLinks])

  const handleShare = async (platform: string, url: string) => {
    try {
      // Track the share
      await eventService.trackShare(eventId, platform)

      if (platform === 'link') {
        // Copy to clipboard
        await navigator.clipboard.writeText(url)
        toast.success('Lien copié dans le presse-papiers!')
        setIsOpen(false)
      } else if (platform === 'email') {
        // Open email client
        window.location.href = url
      } else {
        // Open share window
        const width = 600
        const height = 400
        const left = (window.innerWidth - width) / 2
        const top = (window.innerHeight - height) / 2
        window.open(
          url,
          'share',
          `width=${width},height=${height},left=${left},top=${top},toolbar=0,location=0,menubar=0`
        )
        setIsOpen(false)
      }
    } catch (error: any) {
      console.error('Error sharing:', error)
      toast.error('Erreur lors du partage')
    }
  }

  const platforms = [
    { key: 'facebook', icon: FiFacebook, label: 'Facebook', color: 'text-blue-600 hover:bg-blue-50' },
    { key: 'twitter', icon: FiTwitter, label: 'Twitter', color: 'text-sky-500 hover:bg-sky-50' },
    { key: 'linkedin', icon: FiLinkedin, label: 'LinkedIn', color: 'text-blue-700 hover:bg-blue-50' },
    { key: 'whatsapp', icon: FiShare2, label: 'WhatsApp', color: 'text-green-600 hover:bg-green-50' },
    { key: 'email', icon: FiMail, label: 'Email', color: 'text-gray-600 hover:bg-gray-50' },
    { key: 'link', icon: FiLink, label: 'Copier le lien', color: 'text-purple-600 hover:bg-purple-50' },
  ]

  return (
    <div className={`relative ${className}`}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition shadow-md hover:shadow-lg"
      >
        <FiShare2 className="w-5 h-5" />
        <span>Partager</span>
      </button>

      {isOpen && (
        <>
          {/* Backdrop */}
          <div
            className="fixed inset-0 z-40"
            onClick={() => setIsOpen(false)}
          />

          {/* Share Menu */}
          <div className="absolute right-0 mt-2 w-64 bg-white rounded-xl shadow-2xl border border-gray-200 z-50 overflow-hidden">
            <div className="p-4 border-b border-gray-200 flex items-center justify-between">
              <h3 className="font-semibold text-gray-900">Partager l&apos;événement</h3>
              <button
                onClick={() => setIsOpen(false)}
                className="p-1 hover:bg-gray-100 rounded transition"
              >
                <FiX className="w-5 h-5 text-gray-500" />
              </button>
            </div>

            {isLoading ? (
              <div className="p-8 text-center">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
                <p className="mt-2 text-sm text-gray-600">Chargement...</p>
              </div>
            ) : shareLinks ? (
              <div className="p-2">
                {platforms.map((platform) => {
                  const Icon = platform.icon
                  const url = shareLinks.share_urls?.[platform.key]
                  if (!url) return null

                  return (
                    <button
                      key={platform.key}
                      onClick={() => handleShare(platform.key, url)}
                      className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg transition ${platform.color}`}
                    >
                      <Icon className="w-5 h-5" />
                      <span className="text-sm font-medium">{platform.label}</span>
                    </button>
                  )
                })}
                {shareLinks.share_count > 0 && (
                  <div className="mt-4 pt-4 border-t border-gray-200 text-center">
                    <p className="text-xs text-gray-500">
                      Partagé {shareLinks.share_count} fois
                    </p>
                  </div>
                )}
              </div>
            ) : (
              <div className="p-8 text-center">
                <p className="text-sm text-gray-600">Erreur lors du chargement</p>
              </div>
            )}
          </div>
        </>
      )}
    </div>
  )
}

