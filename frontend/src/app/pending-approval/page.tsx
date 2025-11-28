'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { authService } from '@/services/authService'
import toast from 'react-hot-toast'

export default function PendingApprovalPage() {
  const router = useRouter()
  const [isChecking, setIsChecking] = useState(false)
  const [verificationStatus, setVerificationStatus] = useState<{
    is_verified: boolean
    is_active: boolean
    verification_status: string
  } | null>(null)

  const checkStatus = async () => {
    setIsChecking(true)
    try {
      const status = await authService.getVerificationStatus()
      setVerificationStatus(status)
      
      // Si le compte est activé et vérifié, rediriger vers le dashboard
      if (status.is_active && status.is_verified) {
        toast.success('✅ Votre compte a été activé! Redirection...', { duration: 3000 })
        setTimeout(() => {
          router.push('/dashboard')
        }, 2000)
      }
    } catch (error: any) {
      // Si l'utilisateur n'est pas connecté, ne pas rediriger mais afficher un message
      if (error.response?.status === 401) {
        // L'utilisateur n'est pas connecté, c'est normal après l'inscription
        // On laisse la page s'afficher avec le message d'attente
        setVerificationStatus(null)
      } else {
        toast.error('Erreur lors de la vérification du statut')
      }
    } finally {
      setIsChecking(false)
    }
  }

  useEffect(() => {
    // Vérifier le statut au chargement de la page seulement si l'utilisateur est connecté
    // On vérifie si un token existe
    if (typeof window !== 'undefined' && localStorage.getItem('access_token')) {
      checkStatus()
    }
  }, [])

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 to-secondary-50 dark:from-gray-900 dark:to-gray-800 px-4 py-8">
      <div className="max-w-2xl w-full bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-8 md:p-12 border border-gray-200 dark:border-gray-700">
        {/* Icon */}
        <div className="text-center mb-8">
          <div className="mx-auto w-20 h-20 bg-yellow-100 dark:bg-yellow-900/30 rounded-full flex items-center justify-center mb-6">
            <svg
              className="w-10 h-10 text-yellow-600 dark:text-yellow-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </div>
          
          <h1 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
            Inscription en attente de validation
          </h1>
          
          <p className="text-lg text-gray-600 dark:text-gray-300 mb-2">
            Votre compte a été créé avec succès !
          </p>
        </div>

        {/* Message principal */}
        <div className="bg-yellow-50 dark:bg-yellow-900/20 border-l-4 border-yellow-400 dark:border-yellow-500 p-6 rounded-r-lg mb-6">
          <div className="flex items-start">
            <div className="flex-shrink-0">
              <svg
                className="h-6 w-6 text-yellow-600 dark:text-yellow-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
            <div className="ml-3 flex-1">
              <h3 className="text-lg font-semibold text-yellow-800 dark:text-yellow-200 mb-2">
                Validation en cours
              </h3>
              <p className="text-yellow-700 dark:text-yellow-300 mb-3">
                Votre compte est actuellement en attente de validation par un administrateur de la plateforme.
                Une fois validé, vous recevrez une notification et pourrez accéder à toutes les fonctionnalités de CampusLink.
              </p>
              <p className="text-sm text-yellow-600 dark:text-yellow-400 font-medium">
                💡 <strong>Conseil :</strong> Rapprochez-vous de votre administrateur ou responsable de classe pour accélérer le processus de validation.
              </p>
            </div>
          </div>
        </div>

        {/* Informations supplémentaires */}
        <div className="space-y-4 mb-8">
          <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
            <h4 className="font-semibold text-blue-900 dark:text-blue-200 mb-2 flex items-center gap-2">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              Ce qui a été fait
            </h4>
            <ul className="text-sm text-blue-800 dark:text-blue-300 space-y-1 ml-7">
              <li>✓ Votre compte a été créé</li>
              <li>✓ Votre numéro de téléphone a été vérifié</li>
              <li>✓ Votre email a été vérifié</li>
            </ul>
          </div>

          <div className="bg-gray-50 dark:bg-gray-700/50 border border-gray-200 dark:border-gray-600 rounded-lg p-4">
            <h4 className="font-semibold text-gray-900 dark:text-gray-200 mb-2 flex items-center gap-2">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              Prochaines étapes
            </h4>
            <ul className="text-sm text-gray-700 dark:text-gray-300 space-y-1 ml-7">
              <li>⏳ Validation par un administrateur</li>
              <li>📧 Notification par email une fois validé</li>
              <li>🎉 Accès complet à la plateforme</li>
            </ul>
          </div>
        </div>

        {/* Actions */}
        <div className="space-y-4">
          <button
            onClick={checkStatus}
            disabled={isChecking}
            className="w-full bg-primary-600 dark:bg-primary-500 text-white py-3 rounded-lg font-semibold hover:bg-primary-700 dark:hover:bg-primary-600 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 dark:focus:ring-offset-gray-800 transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            {isChecking ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                <span>Vérification en cours...</span>
              </>
            ) : (
              <>
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                </svg>
                <span>Vérifier le statut de mon compte</span>
              </>
            )}
          </button>

          <Link
            href="/login"
            className="block w-full text-center text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300 font-semibold py-2 transition"
          >
            Se connecter
          </Link>
        </div>

        {/* Statut actuel (si vérifié) */}
        {verificationStatus && (
          <div className="mt-6 pt-6 border-t border-gray-200 dark:border-gray-700">
            <h4 className="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">Statut actuel :</h4>
            <div className="space-y-2 text-sm">
              <div className="flex items-center gap-2">
                <span className={verificationStatus.is_active ? 'text-green-600' : 'text-yellow-600'}>
                  {verificationStatus.is_active ? '✓' : '⏳'}
                </span>
                <span className="text-gray-600 dark:text-gray-400">
                  Compte {verificationStatus.is_active ? 'activé' : 'en attente d\'activation'}
                </span>
              </div>
              <div className="flex items-center gap-2">
                <span className={verificationStatus.is_verified ? 'text-green-600' : 'text-yellow-600'}>
                  {verificationStatus.is_verified ? '✓' : '⏳'}
                </span>
                <span className="text-gray-600 dark:text-gray-400">
                  {verificationStatus.is_verified ? 'Vérifié' : 'En attente de vérification'}
                </span>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

