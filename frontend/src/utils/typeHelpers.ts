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

