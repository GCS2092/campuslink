/**
 * Validators for form inputs
 */

export const universityDomains = [
  '@esmt.sn',
  '@ucad.sn',
  '@ugb.sn',
  '@esp.sn',
  '@uasz.sn',
  '@univ-thies.sn',
]

export function validateUniversityEmail(email: string): boolean {
  if (!email) return false
  return universityDomains.some((domain) => email.endsWith(domain))
}

export function validatePhone(phone: string): boolean {
  if (!phone) return false
  const pattern = /^\+221\d{9}$/
  return pattern.test(phone)
}

export function formatPhone(phone: string): string {
  // Remove all non-digit characters except +
  let cleaned = phone.replace(/[^\d+]/g, '')

  // If starts with 0, replace with +221
  if (cleaned.startsWith('0')) {
    cleaned = '+221' + cleaned.slice(1)
  }
  // If starts with 221, add +
  else if (cleaned.startsWith('221')) {
    cleaned = '+' + cleaned
  }
  // If doesn't start with +, add +221
  else if (!cleaned.startsWith('+')) {
    cleaned = '+221' + cleaned
  }

  return cleaned
}

export function validateMatricule(matricule: string): boolean {
  // Basic validation - can be enhanced based on university requirements
  if (!matricule) return false
  return matricule.length >= 5 && matricule.length <= 20
}

