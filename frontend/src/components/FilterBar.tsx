'use client'

import { FiSearch, FiX } from 'react-icons/fi'

export interface FilterOption {
  value: string
  label: string
}

export interface FilterBarProps {
  searchPlaceholder?: string
  searchValue: string
  onSearchChange: (value: string) => void
  filters?: {
    label: string
    name: string
    options: FilterOption[]
    value: string
    onChange: (value: string) => void
  }[]
  onReset?: () => void
  showReset?: boolean
}

export default function FilterBar({
  searchPlaceholder = 'Rechercher...',
  searchValue,
  onSearchChange,
  filters = [],
  onReset,
  showReset = true,
}: FilterBarProps) {
  const hasActiveFilters = searchValue || filters.some((f) => f.value)

  return (
    <div className="bg-white rounded-xl shadow-md p-4 sm:p-6 space-y-4">
      {/* Search */}
      <div className="relative">
        <FiSearch className="absolute left-3 sm:left-4 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4 sm:w-5 sm:h-5" />
        <input
          type="text"
          placeholder={searchPlaceholder}
          value={searchValue}
          onChange={(e) => onSearchChange(e.target.value)}
          className="w-full pl-10 sm:pl-12 pr-4 py-2 sm:py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm sm:text-base"
        />
      </div>

      {/* Filters */}
      {filters.length > 0 && (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {filters.map((filter) => (
            <div key={filter.name}>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                {filter.label}
              </label>
              <select
                value={filter.value}
                onChange={(e) => filter.onChange(e.target.value)}
                className="w-full px-4 py-2 sm:py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm sm:text-base"
              >
                <option value="">Tous</option>
                {filter.options.map((option) => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>
            </div>
          ))}
        </div>
      )}

      {/* Reset Button */}
      {showReset && hasActiveFilters && onReset && (
        <div className="flex justify-end">
          <button
            onClick={onReset}
            className="flex items-center gap-2 px-4 py-2 text-sm text-gray-600 hover:text-gray-900 transition"
          >
            <FiX className="w-4 h-4" />
            Réinitialiser les filtres
          </button>
        </div>
      )}
    </div>
  )
}

