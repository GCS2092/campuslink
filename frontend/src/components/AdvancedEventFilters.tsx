'use client'

import { useState, useEffect } from 'react'
import { FiFilter, FiSave, FiX, FiTrash2, FiCheck } from 'react-icons/fi'
import { eventService } from '@/services/eventService'
import toast from 'react-hot-toast'

export interface FilterOptions {
  category?: string
  is_free?: boolean | null
  price_min?: number
  price_max?: number
  date_from?: string
  date_to?: string
  university?: string
}

interface SavedFilter {
  id: string
  name: string
  filters: FilterOptions
  is_default: boolean
}

interface AdvancedEventFiltersProps {
  categories: Array<{ id: string; name: string }>
  universities?: Array<{ id: string; name: string }>
  onFiltersChange: (filters: FilterOptions) => void
  currentFilters: FilterOptions
}

export default function AdvancedEventFilters({
  categories,
  universities = [],
  onFiltersChange,
  currentFilters
}: AdvancedEventFiltersProps) {
  const [isOpen, setIsOpen] = useState(false)
  const [filters, setFilters] = useState<FilterOptions>(currentFilters)
  const [savedFilters, setSavedFilters] = useState<SavedFilter[]>([])
  const [isLoadingSaved, setIsLoadingSaved] = useState(false)
  const [saveName, setSaveName] = useState('')
  const [showSaveDialog, setShowSaveDialog] = useState(false)

  useEffect(() => {
    loadSavedFilters()
  }, [])

  useEffect(() => {
    setFilters(currentFilters)
  }, [currentFilters])

  const loadSavedFilters = async () => {
    setIsLoadingSaved(true)
    try {
      const data = await eventService.getFilterPreferences()
      setSavedFilters(Array.isArray(data) ? data : data.results || [])
    } catch (error: any) {
      console.error('Error loading saved filters:', error)
    } finally {
      setIsLoadingSaved(false)
    }
  }

  const handleFilterChange = (key: keyof FilterOptions, value: any) => {
    const newFilters = { ...filters, [key]: value }
    setFilters(newFilters)
    onFiltersChange(newFilters)
  }

  const clearFilters = () => {
    const emptyFilters: FilterOptions = {}
    setFilters(emptyFilters)
    onFiltersChange(emptyFilters)
  }

  const handleSaveFilter = async () => {
    if (!saveName.trim()) {
      toast.error('Veuillez entrer un nom pour ce filtre')
      return
    }

    try {
      await eventService.saveFilterPreference({
        name: saveName.trim(),
        filters,
        is_default: false
      })
      toast.success('Filtre sauvegardé avec succès')
      setShowSaveDialog(false)
      setSaveName('')
      loadSavedFilters()
    } catch (error: any) {
      console.error('Error saving filter:', error)
      toast.error('Erreur lors de la sauvegarde du filtre')
    }
  }

  const handleLoadFilter = async (savedFilter: SavedFilter) => {
    setFilters(savedFilter.filters)
    onFiltersChange(savedFilter.filters)
    toast.success(`Filtre "${savedFilter.name}" chargé`)
  }

  const handleSetDefault = async (filterId: string) => {
    try {
      await eventService.updateFilterPreference(filterId, { is_default: true })
      toast.success('Filtre par défaut mis à jour')
      loadSavedFilters()
    } catch (error: any) {
      console.error('Error setting default filter:', error)
      toast.error('Erreur lors de la mise à jour du filtre par défaut')
    }
  }

  const handleDeleteFilter = async (filterId: string) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce filtre ?')) {
      return
    }

    try {
      await eventService.deleteFilterPreference(filterId)
      toast.success('Filtre supprimé')
      loadSavedFilters()
    } catch (error: any) {
      console.error('Error deleting filter:', error)
      toast.error('Erreur lors de la suppression du filtre')
    }
  }

  const activeFiltersCount = Object.keys(filters).filter(
    key => filters[key as keyof FilterOptions] !== undefined && filters[key as keyof FilterOptions] !== null && filters[key as keyof FilterOptions] !== ''
  ).length

  return (
    <div className="relative">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center gap-2 px-4 py-2 bg-white rounded-lg border border-gray-300 hover:bg-gray-50 transition"
      >
        <FiFilter className="w-4 h-4" />
        <span>Filtres avancés</span>
        {activeFiltersCount > 0 && (
          <span className="bg-primary-600 text-white text-xs px-2 py-0.5 rounded-full">
            {activeFiltersCount}
          </span>
        )}
      </button>

      {isOpen && (
        <div className="absolute top-full left-0 mt-2 w-96 bg-white rounded-lg shadow-xl border border-gray-200 z-50 p-4 max-h-[80vh] overflow-y-auto">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold">Filtres avancés</h3>
            <button
              onClick={() => setIsOpen(false)}
              className="text-gray-500 hover:text-gray-700"
            >
              <FiX className="w-5 h-5" />
            </button>
          </div>

          {/* Category Filter */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Catégorie
            </label>
            <select
              value={filters.category || ''}
              onChange={(e) => handleFilterChange('category', e.target.value || undefined)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            >
              <option value="">Toutes les catégories</option>
              {categories.map((cat) => (
                <option key={cat.id} value={cat.id}>
                  {cat.name}
                </option>
              ))}
            </select>
          </div>

          {/* Price Filter */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Prix
            </label>
            <div className="flex items-center gap-2">
              <select
                value={filters.is_free === null || filters.is_free === undefined ? '' : filters.is_free ? 'free' : 'paid'}
                onChange={(e) => {
                  const value = e.target.value
                  handleFilterChange('is_free', value === '' ? undefined : value === 'free')
                }}
                className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="">Tous</option>
                <option value="free">Gratuit</option>
                <option value="paid">Payant</option>
              </select>
            </div>
            {filters.is_free === false && (
              <div className="flex items-center gap-2 mt-2">
                <input
                  type="number"
                  placeholder="Min"
                  value={filters.price_min || ''}
                  onChange={(e) => handleFilterChange('price_min', e.target.value ? parseFloat(e.target.value) : undefined)}
                  className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                />
                <span className="text-gray-500">-</span>
                <input
                  type="number"
                  placeholder="Max"
                  value={filters.price_max || ''}
                  onChange={(e) => handleFilterChange('price_max', e.target.value ? parseFloat(e.target.value) : undefined)}
                  className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
            )}
          </div>

          {/* Date Range Filter */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Période
            </label>
            <div className="space-y-2">
              <input
                type="date"
                value={filters.date_from || ''}
                onChange={(e) => handleFilterChange('date_from', e.target.value || undefined)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              />
              <input
                type="date"
                value={filters.date_to || ''}
                onChange={(e) => handleFilterChange('date_to', e.target.value || undefined)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
          </div>

          {/* University Filter */}
          {universities.length > 0 && (
            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Université
              </label>
              <select
                value={filters.university || ''}
                onChange={(e) => handleFilterChange('university', e.target.value || undefined)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="">Toutes les universités</option>
                {universities.map((uni) => (
                  <option key={uni.id} value={uni.id}>
                    {uni.name}
                  </option>
                ))}
              </select>
            </div>
          )}

          {/* Actions */}
          <div className="flex items-center gap-2 mb-4 pt-4 border-t border-gray-200">
            <button
              onClick={clearFilters}
              className="flex-1 px-4 py-2 text-sm text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition"
            >
              Réinitialiser
            </button>
            <button
              onClick={() => setShowSaveDialog(true)}
              className="flex-1 px-4 py-2 text-sm text-white bg-primary-600 rounded-lg hover:bg-primary-700 transition flex items-center justify-center gap-2"
            >
              <FiSave className="w-4 h-4" />
              Sauvegarder
            </button>
          </div>

          {/* Saved Filters */}
          <div className="border-t border-gray-200 pt-4">
            <h4 className="text-sm font-semibold text-gray-700 mb-2">Filtres sauvegardés</h4>
            {isLoadingSaved ? (
              <p className="text-sm text-gray-500">Chargement...</p>
            ) : savedFilters.length === 0 ? (
              <p className="text-sm text-gray-500">Aucun filtre sauvegardé</p>
            ) : (
              <div className="space-y-2">
                {savedFilters.map((saved) => (
                  <div
                    key={saved.id}
                    className="flex items-center justify-between p-2 bg-gray-50 rounded-lg hover:bg-gray-100"
                  >
                    <button
                      onClick={() => handleLoadFilter(saved)}
                      className="flex-1 text-left text-sm"
                    >
                      {saved.name}
                      {saved.is_default && (
                        <span className="ml-2 text-xs text-primary-600">(Par défaut)</span>
                      )}
                    </button>
                    <div className="flex items-center gap-1">
                      {!saved.is_default && (
                        <button
                          onClick={() => handleSetDefault(saved.id)}
                          className="p-1 text-gray-500 hover:text-primary-600"
                          title="Définir par défaut"
                        >
                          <FiCheck className="w-4 h-4" />
                        </button>
                      )}
                      <button
                        onClick={() => handleDeleteFilter(saved.id)}
                        className="p-1 text-gray-500 hover:text-red-600"
                        title="Supprimer"
                      >
                        <FiTrash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}

      {/* Save Dialog */}
      {showSaveDialog && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-96">
            <h3 className="text-lg font-semibold mb-4">Sauvegarder le filtre</h3>
            <input
              type="text"
              value={saveName}
              onChange={(e) => setSaveName(e.target.value)}
              placeholder="Nom du filtre"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg mb-4 focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              autoFocus
            />
            <div className="flex items-center gap-2">
              <button
                onClick={() => setShowSaveDialog(false)}
                className="flex-1 px-4 py-2 text-sm text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition"
              >
                Annuler
              </button>
              <button
                onClick={handleSaveFilter}
                className="flex-1 px-4 py-2 text-sm text-white bg-primary-600 rounded-lg hover:bg-primary-700 transition"
              >
                Sauvegarder
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

