'use client'

import { useState } from 'react'
import { FiFlag, FiX } from 'react-icons/fi'
import { moderationService } from '@/services/moderationService'
import toast from 'react-hot-toast'

interface ReportButtonProps {
  contentType: 'event' | 'post' | 'user' | 'group_post' | 'feed_item'
  contentId: string
  className?: string
}

export default function ReportButton({ contentType, contentId, className = '' }: ReportButtonProps) {
  const [showModal, setShowModal] = useState(false)
  const [reason, setReason] = useState<'spam' | 'harassment' | 'inappropriate' | 'fake' | 'other'>('spam')
  const [description, setDescription] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleReport = async () => {
    if (!description.trim() && reason !== 'spam') {
      toast.error('Veuillez fournir une description')
      return
    }

    setIsSubmitting(true)
    try {
      await moderationService.createReport({
        content_type: contentType,
        content_id: contentId,
        reason,
        description: description.trim() || '',
      })
      toast.success('Signalement envoyé avec succès')
      setShowModal(false)
      setDescription('')
      setReason('spam')
    } catch (error: any) {
      console.error('Error reporting content:', error)
      toast.error(error.response?.data?.error || 'Erreur lors du signalement')
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <>
      <button
        onClick={() => setShowModal(true)}
        className={`flex items-center gap-2 text-gray-500 hover:text-red-600 transition ${className}`}
        title="Signaler"
      >
        <FiFlag className="w-4 h-4" />
        <span className="text-sm">Signaler</span>
      </button>

      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-bold text-gray-900">Signaler du contenu</h3>
              <button
                onClick={() => setShowModal(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <FiX className="w-5 h-5" />
              </button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Raison du signalement
                </label>
                <select
                  value={reason}
                  onChange={(e) => setReason(e.target.value as any)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                >
                  <option value="spam">Spam</option>
                  <option value="harassment">Harcèlement</option>
                  <option value="inappropriate">Contenu inapproprié</option>
                  <option value="fake">Faux/Imposture</option>
                  <option value="other">Autre</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Description (optionnel)
                </label>
                <textarea
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  placeholder="Décrivez le problème..."
                  rows={4}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                />
              </div>

              <div className="flex gap-3">
                <button
                  onClick={() => setShowModal(false)}
                  className="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition"
                >
                  Annuler
                </button>
                <button
                  onClick={handleReport}
                  disabled={isSubmitting}
                  className="flex-1 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition disabled:opacity-50"
                >
                  {isSubmitting ? 'Envoi...' : 'Signaler'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  )
}

