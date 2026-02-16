import type { User } from '../types';
import { isAdmin, isClassLeader, isUniversityAdmin } from '../types';

export function getRedirectForUser(user: User | null): string {
  if (!user) return '/(tabs)';
  if (isAdmin(user)) return '/admin';
  if (isUniversityAdmin(user)) return '/university-admin';
  if (isClassLeader(user)) return '/class-leader';
  return '/(tabs)';
}

/** Routes réservées à chaque rôle (premier segment du path). */
const ADMIN_PREFIX = 'admin';
const CLASS_LEADER_PREFIX = 'class-leader';
const UNIVERSITY_ADMIN_PREFIX = 'university-admin';
const TABS_PREFIX = '(tabs)';

/** Chemins accessibles sans être connecté. */
const PUBLIC_PATHS = ['login', 'register'];

/**
 * Retourne la redirection à effectuer si l'utilisateur n'a pas le droit d'être sur ce chemin.
 * Sinon retourne null (accès autorisé).
 */
export function getRedirectIfUnauthorized(
  user: User | null,
  token: string | null,
  firstSegment: string
): string | null {
  if (!token) return PUBLIC_PATHS.includes(firstSegment) ? null : '/login';
  if (!user) return null;

  // Déjà connecté : ne pas rester sur login/register, rediriger vers le dashboard du rôle
  if (firstSegment === 'login' || firstSegment === 'register') {
    return getRedirectForUser(user);
  }

  const isAdminUser = isAdmin(user);
  const isClassLeaderUser = isClassLeader(user);
  const isUniversityAdminUser = isUniversityAdmin(user);
  const isStudentRole = !isAdminUser && !isClassLeaderUser && !isUniversityAdminUser;

  const allowedForAdmin = [ADMIN_PREFIX, 'index'];
  const allowedForUnivAdmin = [UNIVERSITY_ADMIN_PREFIX, 'index'];
  const allowedForClassLeader = [CLASS_LEADER_PREFIX, 'index'];

  if (isAdminUser) {
    return allowedForAdmin.includes(firstSegment) ? null : '/admin';
  }
  if (isUniversityAdminUser) {
    return allowedForUnivAdmin.includes(firstSegment) ? null : '/university-admin';
  }
  if (isClassLeaderUser) {
    return allowedForClassLeader.includes(firstSegment) ? null : '/class-leader';
  }
  if (isStudentRole) {
    if (
      firstSegment === ADMIN_PREFIX ||
      firstSegment === CLASS_LEADER_PREFIX ||
      firstSegment === UNIVERSITY_ADMIN_PREFIX
    ) {
      return '/(tabs)';
    }
  }
  return null;
}
