/**
 * Utility functions for type-safe handling of union types
 */

/**
 * Safely extracts university name from a university field that can be string or object
 */
export function getUniversityName(
  university: string | { name?: string; short_name?: string } | null | undefined
): string {
  if (!university) {
    return 'Université'
  }
  
  if (typeof university === 'string') {
    return university
  }
  
  if (typeof university === 'object') {
    return university.name || university.short_name || 'Université'
  }
  
  return 'Université'
}

/**
 * Safely extracts campus name from a campus field that can be string or object
 */
export function getCampusName(
  campus: string | { name?: string } | null | undefined
): string {
  if (!campus) {
    return 'Campus'
  }
  
  if (typeof campus === 'string') {
    return campus
  }
  
  if (typeof campus === 'object') {
    return campus.name || 'Campus'
  }
  
  return 'Campus'
}

/**
 * Safely extracts image URL from an image field that can be string or object
 */
export function getImageUrl(
  image: string | { url?: string } | null | undefined,
  fallback?: string
): string {
  if (!image) {
    return fallback || ''
  }
  
  if (typeof image === 'string') {
    return image
  }
  
  if (typeof image === 'object' && image.url) {
    return image.url
  }
  
  return fallback || ''
}

