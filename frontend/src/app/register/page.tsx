'use client'

import { useState, useRef, type KeyboardEvent, type ClipboardEvent } from 'react'
import { useRouter } from 'next/navigation'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import Link from 'next/link'
import { authService } from '@/services/authService'
import toast from 'react-hot-toast'

function ResendOTPButton({ phoneNumber }: { phoneNumber: string }) {
  const [isResending, setIsResending] = useState(false)
  const [cooldown, setCooldown] = useState(0)

  const handleResend = async () => {
    if (cooldown > 0) return

    setIsResending(true)
    try {
      await authService.resendOTP(phoneNumber)
      toast.success('Code OTP renvoyé!')
      setCooldown(60) // 60 secondes de cooldown
      
      // Countdown
      const interval = setInterval(() => {
        setCooldown((prev) => {
          if (prev <= 1) {
            clearInterval(interval)
            return 0
          }
          return prev - 1
        })
      }, 1000)
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Erreur lors du renvoi du code')
    } finally {
      setIsResending(false)
    }
  }

  return (
    <button
      type="button"
      onClick={handleResend}
      disabled={isResending || cooldown > 0}
      className="text-sm text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300 disabled:opacity-50 disabled:cursor-not-allowed"
    >
      {isResending
        ? 'Envoi...'
        : cooldown > 0
        ? `Renvoyer dans ${cooldown}s`
        : 'Renvoyer le code'}
    </button>
  )
}

const registerSchema = z.object({
  email: z
    .string()
    .email('Email invalide')
    .refine(
      (email) => /@(esmt|ucad|ugb|esp|uasz|univ-thies)\.sn$/.test(email),
      "Email doit être d'un domaine universitaire valide (@esmt.sn, @ucad.sn, etc.)"
    ),
  username: z
    .string()
    .min(3, "Le nom d'utilisateur doit contenir au moins 3 caractères")
    .max(30, "Le nom d'utilisateur ne peut pas dépasser 30 caractères")
    .regex(/^[a-zA-Z0-9_]+$/, "Le nom d'utilisateur ne peut contenir que des lettres, chiffres et underscores"),
  password: z
    .string()
    .min(8, 'Le mot de passe doit contenir au moins 8 caractères')
    .regex(/[A-Z]/, 'Le mot de passe doit contenir au moins une majuscule')
    .regex(/[a-z]/, 'Le mot de passe doit contenir au moins une minuscule')
    .regex(/[0-9]/, 'Le mot de passe doit contenir au moins un chiffre')
    .regex(/[^A-Za-z0-9]/, 'Le mot de passe doit contenir au moins un caractère spécial'),
  password_confirm: z.string(),
  phone_number: z
    .string()
    .regex(/^\+221[0-9]{9}$/, 'Le numéro de téléphone doit être au format +221XXXXXXXXX'),
  first_name: z.string().optional(),
  last_name: z.string().optional(),
  role: z.enum(['student', 'organizer', 'sponsor']).optional(),
}).refine((data) => data.password === data.password_confirm, {
  message: 'Les mots de passe ne correspondent pas',
  path: ['password_confirm'],
})

type RegisterFormData = z.infer<typeof registerSchema>

export default function RegisterPage() {
  const router = useRouter()
  const [isLoading, setIsLoading] = useState(false)
  const [step, setStep] = useState<'form' | 'verification'>('form')
  const [userId, setUserId] = useState<string | null>(null)
  const [phoneNumber, setPhoneNumber] = useState<string>('')

  const {
    register,
    handleSubmit,
    formState: { errors },
    getValues,
  } = useForm<RegisterFormData>({
    resolver: zodResolver(registerSchema),
  })

  const onSubmit = async (data: RegisterFormData) => {
    setIsLoading(true)

    try {
      const response = await authService.register(data)
      setUserId(response.user_id)
      setPhoneNumber(data.phone_number)
      setStep('verification')
      toast.success('✅ Inscription réussie! Vérifiez votre téléphone pour le code OTP.', { duration: 5000 })
    } catch (error: any) {
      if (error.response?.status === 400) {
        const errors = error.response.data
        if (typeof errors === 'object') {
          // Afficher les erreurs de validation avec des messages clairs
          Object.keys(errors).forEach((key) => {
            let errorMessage = ''
            if (Array.isArray(errors[key])) {
              errorMessage = errors[key][0]
            } else if (typeof errors[key] === 'string') {
              errorMessage = errors[key]
            } else if (typeof errors[key] === 'object' && errors[key].message) {
              errorMessage = errors[key].message
            }
            
            if (errorMessage) {
              // Messages personnalisés selon le champ
              const fieldNames: Record<string, string> = {
                email: '📧 Email',
                username: '👤 Nom d\'utilisateur',
                password: '🔒 Mot de passe',
                password_confirm: '🔒 Confirmation mot de passe',
                phone_number: '📱 Numéro de téléphone',
                first_name: 'Prénom',
                last_name: 'Nom'
              }
              const fieldName = fieldNames[key] || key
              toast.error(`${fieldName}: ${errorMessage}`, { duration: 5000 })
            }
          })
        } else {
          toast.error('⚠️ Erreur de validation. Veuillez vérifier tous les champs.', { duration: 4000 })
        }
      } else if (error.response?.status === 409) {
        toast.error('❌ Ce compte existe déjà. Essayez de vous connecter ou utilisez un autre email.', { duration: 5000 })
      } else if (error.response?.status === 500) {
        toast.error('🔧 Erreur serveur. Veuillez réessayer dans quelques instants.', { duration: 4000 })
      } else if (error.message === 'Network Error' || !error.response) {
        toast.error('🌐 Problème de connexion. Vérifiez votre connexion internet.', { duration: 4000 })
      } else {
        const message = error.response?.data?.message || error.response?.data?.detail || "Erreur lors de l'inscription. Veuillez réessayer."
        toast.error(`⚠️ ${message}`, { duration: 4000 })
      }
    } finally {
      setIsLoading(false)
    }
  }

  const handleOTPVerification = async (otp: string) => {
    setIsLoading(true)

    try {
      await authService.verifyPhone({
        phone_number: phoneNumber,
        otp_code: otp,
      })
      toast.success('✅ Vérification réussie! Redirection...', { duration: 3000 })
      // Auto-login après vérification
      setTimeout(() => {
        router.push('/login')
      }, 1000)
    } catch (error: any) {
      if (error.response?.status === 400) {
        const message = error.response?.data?.message || error.response?.data?.detail || 'Code OTP invalide.'
        toast.error(`❌ ${message}`, { duration: 4000 })
      } else if (error.response?.status === 404) {
        toast.error('❌ Code OTP expiré ou invalide. Demandez un nouveau code.', { duration: 4000 })
      } else if (error.response?.status === 429) {
        toast.error('⏱️ Trop de tentatives. Attendez quelques instants avant de réessayer.', { duration: 4000 })
      } else {
        toast.error('❌ Code OTP invalide. Vérifiez le code reçu et réessayez.', { duration: 4000 })
      }
    } finally {
      setIsLoading(false)
    }
  }

  if (step === 'verification') {
    return (
      <OTPVerificationStep
        phoneNumber={phoneNumber}
        onVerify={handleOTPVerification}
        isLoading={isLoading}
      />
    )
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 to-secondary-50 dark:from-gray-900 dark:to-gray-800 px-4 py-8">
      <div className="max-w-md w-full bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-8 border border-gray-200 dark:border-gray-700">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">Inscription</h1>
          <p className="text-gray-600 dark:text-gray-300">Créez votre compte CampusLink</p>
        </div>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
          <div>
            <label htmlFor="email" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Email universitaire <span className="text-red-500">*</span>
            </label>
            <input
              {...register('email')}
              type="email"
              id="email"
              className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none transition bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500"
              placeholder="exemple@esmt.sn"
              disabled={isLoading}
            />
            {errors.email && (
              <div className="mt-2 p-2 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded flex items-start gap-2">
                <span className="text-red-600 dark:text-red-400">⚠️</span>
                <p className="text-sm text-red-600 dark:text-red-400">{errors.email.message}</p>
              </div>
            )}
            <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">
              Domaines acceptés: @esmt.sn, @ucad.sn, @ugb.sn, @esp.sn, @uasz.sn, @univ-thies.sn
            </p>
          </div>

          <div>
            <label htmlFor="username" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Nom d&apos;utilisateur <span className="text-red-500">*</span>
            </label>
            <input
              {...register('username')}
              type="text"
              id="username"
              className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none transition bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500"
              placeholder="johndoe"
              disabled={isLoading}
            />
            {errors.username && (
              <div className="mt-2 p-2 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded flex items-start gap-2">
                <span className="text-red-600 dark:text-red-400">⚠️</span>
                <p className="text-sm text-red-600 dark:text-red-400">{errors.username.message}</p>
              </div>
            )}
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label htmlFor="first_name" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Prénom
              </label>
              <input
                {...register('first_name')}
                type="text"
                id="first_name"
                className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none transition bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500"
                placeholder="John"
                disabled={isLoading}
              />
            </div>

            <div>
              <label htmlFor="last_name" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Nom
              </label>
              <input
                {...register('last_name')}
                type="text"
                id="last_name"
                className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none transition bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500"
                placeholder="Doe"
                disabled={isLoading}
              />
            </div>
          </div>

          <div>
            <label htmlFor="phone_number" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Numéro de téléphone <span className="text-red-500">*</span>
            </label>
            <input
              {...register('phone_number')}
              type="tel"
              id="phone_number"
              className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none transition bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500"
              placeholder="+221771234567"
              disabled={isLoading}
            />
            {errors.phone_number && (
              <div className="mt-2 p-2 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded flex items-start gap-2">
                <span className="text-red-600 dark:text-red-400">⚠️</span>
                <p className="text-sm text-red-600 dark:text-red-400">{errors.phone_number.message}</p>
              </div>
            )}
            <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">
              Format: +221XXXXXXXXX (ex: +221771234567)
            </p>
          </div>

          <div>
            <label htmlFor="role" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Rôle
            </label>
            <select
              {...register('role')}
              id="role"
              className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none transition bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              disabled={isLoading}
            >
              <option value="student">Étudiant</option>
              <option value="organizer">Organisateur</option>
              <option value="sponsor">Sponsor</option>
            </select>
          </div>

          <div>
            <label htmlFor="password" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Mot de passe <span className="text-red-500">*</span>
            </label>
            <input
              {...register('password')}
              type="password"
              id="password"
              className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none transition bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500"
              placeholder="••••••••"
              disabled={isLoading}
            />
            {errors.password && (
              <div className="mt-2 p-2 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded flex items-start gap-2">
                <span className="text-red-600 dark:text-red-400">⚠️</span>
                <p className="text-sm text-red-600 dark:text-red-400">{errors.password.message}</p>
              </div>
            )}
            <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">
              Min. 8 caractères, 1 majuscule, 1 minuscule, 1 chiffre, 1 caractère spécial
            </p>
          </div>

          <div>
            <label htmlFor="password_confirm" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Confirmer le mot de passe <span className="text-red-500">*</span>
            </label>
            <input
              {...register('password_confirm')}
              type="password"
              id="password_confirm"
              className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none transition bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500"
              placeholder="••••••••"
              disabled={isLoading}
            />
            {errors.password_confirm && (
              <div className="mt-2 p-2 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded flex items-start gap-2">
                <span className="text-red-600 dark:text-red-400">⚠️</span>
                <p className="text-sm text-red-600 dark:text-red-400">{errors.password_confirm.message}</p>
              </div>
            )}
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className="w-full bg-primary-600 dark:bg-primary-500 text-white py-3 rounded-lg font-semibold hover:bg-primary-700 dark:hover:bg-primary-600 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 dark:focus:ring-offset-gray-800 transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            {isLoading ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                <span>Inscription...</span>
              </>
            ) : (
              'S&apos;inscrire'
            )}
          </button>
        </form>

        <div className="mt-6 text-center">
          <p className="text-sm text-gray-600 dark:text-gray-400">
            Déjà un compte?{' '}
            <Link href="/login" className="text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300 font-semibold">
              Se connecter
            </Link>
          </p>
        </div>
      </div>
    </div>
  )
}

function OTPVerificationStep({
  phoneNumber,
  onVerify,
  isLoading,
}: {
  phoneNumber: string
  onVerify: (otp: string) => void
  isLoading: boolean
}) {
  const [otp, setOtp] = useState(['', '', '', '', '', ''])
  const inputRefs = useRef<(HTMLInputElement | null)[]>(Array(6).fill(null))

  const handleChange = (index: number, value: string) => {
    if (value.length > 1) return
    const newOtp = [...otp]
    newOtp[index] = value
    setOtp(newOtp)

    // Auto-focus next input
    if (value && index < 5) {
      inputRefs.current[index + 1]?.focus()
    }

    // Auto-submit when all fields are filled
    if (newOtp.every((digit) => digit !== '') && newOtp.join('').length === 6) {
      onVerify(newOtp.join(''))
    }
  }

  const handleKeyDown = (index: number, e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      inputRefs.current[index - 1]?.focus()
    }
  }

  const handlePaste = (e: ClipboardEvent<HTMLInputElement>) => {
    e.preventDefault()
    const pastedData = e.clipboardData.getData('text').slice(0, 6)
    const newOtp = [...otp]
    for (let i = 0; i < pastedData.length && i < 6; i++) {
      newOtp[i] = pastedData[i]
    }
    setOtp(newOtp)
    if (pastedData.length === 6) {
      onVerify(pastedData)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 to-secondary-50 dark:from-gray-900 dark:to-gray-800 px-4">
      <div className="max-w-md w-full bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-8 border border-gray-200 dark:border-gray-700">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">Vérification</h1>
          <p className="text-gray-600 dark:text-gray-300">
            Entrez le code OTP envoyé à <br />
            <span className="font-semibold text-gray-900 dark:text-white">{phoneNumber}</span>
          </p>
        </div>

        <form
          onSubmit={(e) => {
            e.preventDefault()
            onVerify(otp.join(''))
          }}
          className="space-y-6"
        >
          <div className="flex justify-center gap-3">
            {otp.map((digit, index) => (
              <input
                key={index}
                ref={(el) => {
                  inputRefs.current[index] = el
                }}
                type="text"
                inputMode="numeric"
                maxLength={1}
                value={digit}
                onChange={(e) => handleChange(index, e.target.value)}
                onKeyDown={(e) => handleKeyDown(index, e)}
                onPaste={handlePaste}
                className="w-12 h-14 text-center text-2xl font-bold border-2 border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                disabled={isLoading}
              />
            ))}
          </div>

          <button
            type="submit"
            disabled={isLoading || otp.join('').length !== 6}
            className="w-full bg-primary-600 dark:bg-primary-500 text-white py-3 rounded-lg font-semibold hover:bg-primary-700 dark:hover:bg-primary-600 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 dark:focus:ring-offset-gray-800 transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            {isLoading ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                <span>Vérification...</span>
              </>
            ) : (
              'Vérifier'
            )}
          </button>
        </form>

        <div className="mt-6 text-center">
          <ResendOTPButton phoneNumber={phoneNumber} />
        </div>
      </div>
    </div>
  )
}

