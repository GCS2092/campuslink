'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { FiArrowLeft, FiPlus, FiEdit2, FiTrash2, FiEye, FiEyeOff, FiGlobe, FiLock } from 'react-icons/fi'
import { feedService, type FeedItem } from '@/services/feedService'
import toast from 'react-hot-toast'

export default function ManageFeedPage() {
  const { user, loading } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [feedItems, setFeedItems] = useState<FeedItem[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [showModal, setShowModal] = useState(false)
  const [editingItem, setEditingItem] = useState<FeedItem | null>(null)
  const [formData, setFormData] = useState({
    type: 'news' as 'event' | 'group' | 'announcement' | 'news',
    title: '',
    content: '',
    visibility: 'public' as 'public' | 'private',
    image: null as File | null,
  })
  const [imagePreview, setImagePreview] = useState<string | null>(null)

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    } else if (mounted && user && user.role !== 'class_leader' && user.role !== 'admin') {
      router.push('/dashboard')
    }
  }, [mounted, user, loading, router])

  useEffect(() => {
    if (user && (user.role === 'class_leader' || user.role === 'admin')) {
      loadFeedItems()
    }
  }, [user])

  const loadFeedItems = async () => {
    setIsLoading(true)
    try {
      const items = await feedService.getMyFeedItems()
      setFeedItems(Array.isArray(items) ? items : [])
    } catch (error) {
      console.error('Error loading feed items:', error)
      toast.error('Erreur lors du chargement des actualités')
    } finally {
      setIsLoading(false)
    }
  }

  const handleOpenModal = (item?: FeedItem) => {
    if (item) {
      setEditingItem(item)
      // Convert 'feed' type to 'news' if needed, as formData doesn't accept 'feed'
      const itemType = item.type === 'feed' ? 'news' : (item.type || 'news')
      const validType = (['event', 'group', 'announcement', 'news'].includes(itemType) 
        ? itemType 
        : 'news') as 'event' | 'group' | 'announcement' | 'news'
      setFormData({
        type: validType,
        title: item.title || '',
        content: item.content || '',
        visibility: item.visibility || 'public',
        image: null,
      })
      setImagePreview(item.image || null)
    } else {
      setEditingItem(null)
      setFormData({
        type: 'news',
        title: '',
        content: '',
        visibility: 'public',
        image: null,
      })
      setImagePreview(null)
    }
    setShowModal(true)
  }

  const handleCloseModal = () => {
    setShowModal(false)
    setEditingItem(null)
    setFormData({
      type: 'news',
      title: '',
      content: '',
      visibility: 'public',
      image: null,
    })
    setImagePreview(null)
  }

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      setFormData({ ...formData, image: file })
      const reader = new FileReader()
      reader.onloadend = () => {
        setImagePreview(reader.result as string)
      }
      reader.readAsDataURL(file)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!formData.title || !formData.content) {
      toast.error('Veuillez remplir tous les champs obligatoires')
      return
    }

    try {
      if (editingItem) {
        await feedService.updateFeedItem(editingItem.id, {
          ...formData,
          image: formData.image || undefined,
        })
        toast.success('Actualité modifiée avec succès')
      } else {
        await feedService.createFeedItem({
          ...formData,
          image: formData.image || undefined,
        })
        toast.success('Actualité créée avec succès')
      }
      handleCloseModal()
      loadFeedItems()
    } catch (error: any) {
      console.error('Error saving feed item:', error)
      toast.error(error?.response?.data?.error || 'Erreur lors de la sauvegarde')
    }
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cette actualité ?')) {
      return
    }

    try {
      await feedService.deleteFeedItem(id)
      toast.success('Actualité supprimée avec succès')
      loadFeedItems()
    } catch (error: any) {
      console.error('Error deleting feed item:', error)
      toast.error(error?.response?.data?.error || 'Erreur lors de la suppression')
    }
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

  if (!user || (user.role !== 'class_leader' && user.role !== 'admin')) {
    return null
  }

  const handleGoBack = () => {
    // Rediriger vers le dashboard approprié selon le rôle
    if (user.role === 'admin') {
      router.push('/admin/dashboard')
    } else {
      router.push('/dashboard')
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 page-with-bottom-nav">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-3 sm:py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3 sm:gap-4">
              <button
                onClick={handleGoBack}
                className="p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition"
                title="Retour"
              >
                <FiArrowLeft className="w-5 h-5 sm:w-6 sm:h-6" />
              </button>
              <div>
                <h1 className="text-xl sm:text-2xl font-bold text-gray-900">Gérer les Actualités</h1>
                <p className="text-sm text-gray-600 hidden sm:block">
                  Créez et gérez les actualités de votre campus
                </p>
              </div>
            </div>
            <button
              onClick={() => handleOpenModal()}
              className="flex items-center gap-2 px-3 sm:px-4 py-2 text-sm sm:text-base bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition"
            >
              <FiPlus className="w-4 h-4 sm:w-5 sm:h-5" />
              <span className="hidden sm:inline">Nouvelle Actualité</span>
            </button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-4 sm:py-6">
        {isLoading ? (
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Chargement...</p>
          </div>
        ) : feedItems.length === 0 ? (
          <div className="bg-white rounded-xl shadow-md p-8 sm:p-12 text-center">
            <FiPlus className="w-12 h-12 sm:w-16 sm:h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg sm:text-xl font-semibold text-gray-900 mb-2">Aucune actualité</h3>
            <p className="text-sm text-gray-600 mb-4">Créez votre première actualité pour commencer</p>
            <button
              onClick={() => handleOpenModal()}
              className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition"
            >
              Créer une actualité
            </button>
          </div>
        ) : (
          <div className="space-y-4 sm:space-y-6">
            {feedItems.map((item) => (
              <div
                key={item.id}
                className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition"
              >
                <div className="p-4 sm:p-6">
                  <div className="flex items-start justify-between gap-4 mb-4">
                    <div className="flex-1">
                      <h3 className="text-lg font-semibold text-gray-900 mb-2">{item.title}</h3>
                      <div className="flex items-center gap-2 text-sm text-gray-500">
                        <span className={`px-2 py-1 rounded ${
                          item.visibility === 'public' 
                            ? 'bg-green-100 text-green-700' 
                            : 'bg-blue-100 text-blue-700'
                        }`}>
                          {item.visibility === 'public' ? (
                            <>
                              <FiGlobe className="w-3 h-3 inline mr-1" />
                              Publique
                            </>
                          ) : (
                            <>
                              <FiLock className="w-3 h-3 inline mr-1" />
                              Privée ({typeof item.university === 'string' 
                                ? item.university 
                                : item.university?.name || item.university?.short_name || 'Université'})
                            </>
                          )}
                        </span>
                        <span className="text-gray-400">•</span>
                        <span>{new Date(item.created_at).toLocaleDateString('fr-FR')}</span>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => handleOpenModal(item)}
                        className="p-2 text-primary-600 hover:bg-primary-50 rounded-lg transition"
                        title="Modifier"
                      >
                        <FiEdit2 className="w-5 h-5" />
                      </button>
                      <button
                        onClick={() => handleDelete(item.id)}
                        className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition"
                        title="Supprimer"
                      >
                        <FiTrash2 className="w-5 h-5" />
                      </button>
                    </div>
                  </div>
                  <p className="text-sm text-gray-700 mb-4 whitespace-pre-wrap line-clamp-3">
                    {item.content}
                  </p>
                  {item.image && (
                    <div className="rounded-lg overflow-hidden">
                      <img
                        src={item.image.startsWith('http') ? item.image : `${process.env.NEXT_PUBLIC_API_URL?.replace('/api', '')}${item.image}`}
                        alt={item.title}
                        className="w-full h-32 sm:h-48 object-cover"
                      />
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </main>

      {/* Modal for Create/Edit */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-xl shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-4 sm:p-6">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-xl sm:text-2xl font-bold text-gray-900">
                  {editingItem ? 'Modifier l\'actualité' : 'Nouvelle actualité'}
                </h2>
                <button
                  onClick={handleCloseModal}
                  className="p-2 text-gray-400 hover:text-gray-600 transition"
                >
                  <FiArrowLeft className="w-5 h-5" />
                </button>
              </div>

              <form onSubmit={handleSubmit} className="space-y-4">
                {/* Type */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Type
                  </label>
                  <select
                    value={formData.type}
                    onChange={(e) => setFormData({ ...formData, type: e.target.value as any })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                  >
                    <option value="news">Actualité</option>
                    <option value="event">Événement</option>
                    <option value="group">Groupe</option>
                    <option value="announcement">Annonce</option>
                  </select>
                </div>

                {/* Title */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Titre *
                  </label>
                  <input
                    type="text"
                    value={formData.title}
                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    required
                  />
                </div>

                {/* Content */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Contenu *
                  </label>
                  <textarea
                    value={formData.content}
                    onChange={(e) => setFormData({ ...formData, content: e.target.value })}
                    rows={6}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    required
                  />
                </div>

                {/* Visibility */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Visibilité
                  </label>
                  <div className="flex gap-4">
                    <label className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="radio"
                        name="visibility"
                        value="public"
                        checked={formData.visibility === 'public'}
                        onChange={(e) => setFormData({ ...formData, visibility: e.target.value as any })}
                        className="w-4 h-4 text-primary-600"
                      />
                      <div className="flex items-center gap-2">
                        <FiGlobe className="w-4 h-4" />
                        <span>Publique (Tous les utilisateurs)</span>
                      </div>
                    </label>
                    <label className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="radio"
                        name="visibility"
                        value="private"
                        checked={formData.visibility === 'private'}
                        onChange={(e) => setFormData({ ...formData, visibility: e.target.value as any })}
                        className="w-4 h-4 text-primary-600"
                      />
                      <div className="flex items-center gap-2">
                        <FiLock className="w-4 h-4" />
                        <span>Privée (Mon école uniquement)</span>
                      </div>
                    </label>
                  </div>
                </div>

                {/* Image */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Image (optionnel)
                  </label>
                  <input
                    type="file"
                    accept="image/*"
                    onChange={handleImageChange}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                  />
                  {imagePreview && (
                    <div className="mt-4 rounded-lg overflow-hidden">
                      <img
                        src={imagePreview}
                        alt="Preview"
                        className="w-full h-48 object-cover"
                      />
                    </div>
                  )}
                </div>

                {/* Buttons */}
                <div className="flex items-center justify-end gap-3 pt-4">
                  <button
                    type="button"
                    onClick={handleCloseModal}
                    className="px-4 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition"
                  >
                    Annuler
                  </button>
                  <button
                    type="submit"
                    className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition"
                  >
                    {editingItem ? 'Modifier' : 'Créer'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

