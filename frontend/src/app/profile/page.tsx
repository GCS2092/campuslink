'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiUser, FiMail, FiPhone, FiMapPin, FiEdit2, FiSave, FiX } from 'react-icons/fi'

export default function ProfilePage() {
  const { user, loading } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [isEditing, setIsEditing] = useState(false)
  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    bio: '',
    location: '',
  })

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    } else if (user) {
      setFormData({
        first_name: user.first_name || '',
        last_name: user.last_name || '',
        bio: '',
        location: '',
      })
    }
  }, [mounted, user, loading, router])

  const handleSave = () => {
    // TODO: Implémenter la sauvegarde via API
    setIsEditing(false)
  }

  if (!mounted || loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 to-secondary-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Chargement...</p>
        </div>
      </div>
    )
  }

  if (!user) {
    return null
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header */}
        <div className="bg-white rounded-2xl shadow-lg p-6 mb-6">
          <div className="flex items-center justify-between mb-6">
            <h1 className="text-3xl font-bold text-gray-900">Mon Profil</h1>
            {!isEditing ? (
              <button
                onClick={() => setIsEditing(true)}
                className="flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition"
              >
                <FiEdit2 className="w-4 h-4" />
                <span>Modifier</span>
              </button>
            ) : (
              <div className="flex gap-2">
                <button
                  onClick={handleSave}
                  className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition"
                >
                  <FiSave className="w-4 h-4" />
                  <span>Enregistrer</span>
                </button>
                <button
                  onClick={() => setIsEditing(false)}
                  className="flex items-center gap-2 px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition"
                >
                  <FiX className="w-4 h-4" />
                  <span>Annuler</span>
                </button>
              </div>
            )}
          </div>

          {/* Profile Info */}
          <div className="space-y-4">
            <div className="flex items-center gap-4">
              <div className="w-24 h-24 bg-primary-100 rounded-full flex items-center justify-center">
                <FiUser className="w-12 h-12 text-primary-600" />
              </div>
              <div>
                <h2 className="text-2xl font-semibold text-gray-900">
                  {user.first_name && user.last_name
                    ? `${user.first_name} ${user.last_name}`
                    : user.username || user.email}
                </h2>
                <p className="text-gray-600">@{user.username}</p>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-6">
              <div className="flex items-center gap-3">
                <FiMail className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Email</p>
                  <p className="text-gray-900">{user.email}</p>
                </div>
              </div>

              {user.phone_number && (
                <div className="flex items-center gap-3">
                  <FiPhone className="w-5 h-5 text-gray-400" />
                  <div>
                    <p className="text-sm text-gray-500">Téléphone</p>
                    <p className="text-gray-900">{user.phone_number}</p>
                  </div>
                </div>
              )}

              {isEditing ? (
                <>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Prénom</label>
                    <input
                      type="text"
                      value={formData.first_name}
                      onChange={(e) => setFormData({ ...formData, first_name: e.target.value })}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Nom</label>
                    <input
                      type="text"
                      value={formData.last_name}
                      onChange={(e) => setFormData({ ...formData, last_name: e.target.value })}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    />
                  </div>
                </>
              ) : (
                <>
                  {user.first_name && (
                    <div>
                      <p className="text-sm text-gray-500">Prénom</p>
                      <p className="text-gray-900">{user.first_name}</p>
                    </div>
                  )}
                  {user.last_name && (
                    <div>
                      <p className="text-sm text-gray-500">Nom</p>
                      <p className="text-gray-900">{user.last_name}</p>
                    </div>
                  )}
                </>
              )}
            </div>

            {isEditing && (
              <div className="mt-4">
                <label className="block text-sm font-medium text-gray-700 mb-2">Bio</label>
                <textarea
                  value={formData.bio}
                  onChange={(e) => setFormData({ ...formData, bio: e.target.value })}
                  rows={4}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                  placeholder="Parlez-nous de vous..."
                />
              </div>
            )}

            <div className="mt-4">
              <div className="flex items-center gap-2">
                <span
                  className={`px-3 py-1 rounded-full text-sm font-medium ${
                    user.is_verified
                      ? 'bg-green-100 text-green-800'
                      : 'bg-yellow-100 text-yellow-800'
                  }`}
                >
                  {user.is_verified ? '✓ Compte vérifié' : '⚠ Compte non vérifié'}
                </span>
                <span
                  className={`px-3 py-1 rounded-full text-sm font-medium ${
                    user.role === 'admin'
                      ? 'bg-red-100 text-red-800'
                      : user.role === 'class_leader'
                      ? 'bg-purple-100 text-purple-800'
                      : user.role === 'association'
                      ? 'bg-blue-100 text-blue-800'
                      : user.role === 'sponsor'
                      ? 'bg-yellow-100 text-yellow-800'
                      : 'bg-gray-100 text-gray-800'
                  }`}
                >
                  {user.role === 'admin'
                    ? 'Administrateur'
                    : user.role === 'class_leader'
                    ? 'Responsable de Classe'
                    : user.role === 'association'
                    ? 'Association/Club'
                    : user.role === 'sponsor'
                    ? 'Partenaire/Sponsor'
                    : 'Étudiant'}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

