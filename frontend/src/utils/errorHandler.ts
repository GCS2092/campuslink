/**
 * Utility function to safely extract error messages from API errors
 * Prevents React errors when trying to render error objects directly
 */
export function getErrorMessage(error: any, defaultMessage: string = 'Une erreur est survenue'): string {
  if (!error) return defaultMessage

  // If error is already a string, return it
  if (typeof error === 'string') return error

  // Try to extract from response.data
  if (error?.response?.data) {
    const errorData = error.response.data

    // If errorData is a string, return it
    if (typeof errorData === 'string') return errorData

    // If errorData has an error property
    if (errorData.error) {
      // If error is an object with message/details
      if (typeof errorData.error === 'object') {
        return errorData.error.message || errorData.error.details?.message || defaultMessage
      }
      // If error is a string
      if (typeof errorData.error === 'string') {
        return errorData.error
      }
    }

    // If errorData has a message property
    if (errorData.message && typeof errorData.message === 'string') {
      return errorData.message
    }

    // If errorData has a detail property
    if (errorData.detail && typeof errorData.detail === 'string') {
      return errorData.detail
    }
  }

  // Try error.message
  if (error?.message && typeof error.message === 'string') {
    return error.message
  }

  return defaultMessage
}

