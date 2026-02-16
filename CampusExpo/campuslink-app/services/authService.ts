import * as SecureStore from 'expo-secure-store';
import { ENDPOINTS, STORAGE_KEYS } from '../constants';
import type { User } from '../types';
import { getApi, apiGet, apiPost } from './api';

export async function login(email: string, password: string): Promise<{ user: User; token: string } | { error: string }> {
  try {
    const api = await getApi();
    const { data } = await api.post<{
      access?: string;
      refresh?: string;
      user_id?: string;
      email?: string;
      username?: string;
      first_name?: string;
      last_name?: string;
      role?: string;
      is_staff?: boolean;
      is_superuser?: boolean;
    }>(ENDPOINTS.login, { email, password });
    const token = data.access;
    if (!token) return { error: 'Pas de token reçu' };
    await SecureStore.setItemAsync(STORAGE_KEYS.accessToken, token);
    if (data.refresh) await SecureStore.setItemAsync(STORAGE_KEYS.refreshToken, data.refresh);
    let user: User = {
      id: String(data.user_id ?? ''),
      email: data.email ?? email,
      username: data.username ?? email.split('@')[0],
      first_name: data.first_name,
      last_name: data.last_name,
      role: data.role?.toLowerCase?.() ?? data.role,
      is_staff: data.is_staff,
      is_superuser: data.is_superuser,
    };
    const profileData = await getProfile().catch(() => null);
    if (profileData) {
      user = { ...user, ...profileData };
      if (profileData.role != null) user.role = typeof profileData.role === 'string' ? profileData.role.toLowerCase() : profileData.role;
    }
    await SecureStore.setItemAsync(STORAGE_KEYS.userData, JSON.stringify(user));
    return { user, token };
  } catch (e: unknown) {
    const err = e as { response?: { data?: Record<string, unknown>; status?: number }; message?: string };
    const status = err.response?.status;
    const data = err.response?.data;
    let msg: string | null = null;
    if (data) {
      if (typeof data.detail === 'string') msg = data.detail;
      else if (data.error && typeof data.error === 'object' && 'message' in data.error)
        msg = String((data.error as { message?: string }).message);
      else if (typeof data.error === 'string') msg = data.error;
    }
    if (!msg && status === 401)
      msg = 'Email ou mot de passe incorrect.';
    if (!msg && status === 429)
      msg = 'Trop de tentatives de connexion. Réessayez dans quelques minutes.';
    if (!msg && status === 404)
      msg = 'Serveur introuvable. Vérifiez que l\'URL dans constants.ts pointe vers votre backend (ex: http://VOTRE_IP:8000/api).';
    if (!msg && (err.message === 'Network Error' || err.message?.includes('timeout')))
      msg = 'Impossible de joindre le serveur. Vérifiez la connexion et que le backend tourne (python manage.py runserver 0.0.0.0:8000).';
    return { error: msg || 'Connexion impossible' };
  }
}

export async function register(payload: {
  email: string;
  username: string;
  password: string;
  password_confirm?: string;
  phone_number?: string;
  first_name?: string;
  last_name?: string;
}): Promise<{ user: User; token: string } | { error: string }> {
  try {
    const body = { ...payload, password_confirm: payload.password_confirm ?? payload.password };
    const api = await getApi();
    const { data } = await api.post<{ access?: string; user_id?: string; email?: string; username?: string }>(
      ENDPOINTS.register,
      body
    );
    const token = data.access;
    if (!token) return { error: 'Inscription échouée' };
    await SecureStore.setItemAsync(STORAGE_KEYS.accessToken, token);
    let user: User = {
      id: String(data.user_id ?? ''),
      email: data.email ?? payload.email,
      username: data.username ?? payload.username,
      first_name: payload.first_name,
      last_name: payload.last_name,
      role: (data as { role?: string }).role ?? 'student',
    };
    const profile = await getProfile().catch(() => null);
    if (profile) user = { ...user, ...profile };
    await SecureStore.setItemAsync(STORAGE_KEYS.userData, JSON.stringify(user));
    return { user, token };
  } catch (e: unknown) {
    const res = e && typeof e === 'object' && 'response' in e ? (e as { response?: { data?: Record<string, string[]> } }).response?.data : null;
    const first = res && typeof res === 'object' ? Object.values(res).flat().find(Boolean) : null;
    return { error: first || 'Inscription impossible' };
  }
}

/** Normalise la réponse profil backend vers le type User de l'app (profile.campus, profile.avatar). */
function normalizeProfileUser(data: Record<string, unknown>): User {
  const profile = data.profile as Record<string, unknown> | undefined;
  const campusName =
    (profile?.university as { name?: string } | undefined)?.name ??
    (profile?.campus as { name?: string } | undefined)?.name ??
    (profile?.campus as string | undefined);
  const departmentName =
    (profile?.department as { name?: string } | undefined)?.name ??
    (profile?.department as string | undefined);
  return {
    id: String(data.id ?? ''),
    email: String(data.email ?? ''),
    username: String(data.username ?? ''),
    first_name: data.first_name as string | undefined,
    last_name: data.last_name as string | undefined,
    role: data.role as string | undefined,
    phone_number: data.phone_number as string | undefined,
    is_verified: data.is_verified as boolean | undefined,
    is_staff: data.is_staff as boolean | undefined,
    is_superuser: data.is_superuser as boolean | undefined,
    profile: {
      bio: profile?.bio as string | undefined,
      avatar: (profile?.profile_picture as string) ?? (profile?.avatar as string),
      campus: typeof campusName === 'string' ? campusName : undefined,
      department: typeof departmentName === 'string' ? departmentName : undefined,
    },
  };
}

export async function getProfile(): Promise<User | null> {
  try {
    const data = await apiGet<Record<string, unknown>>(ENDPOINTS.profile);
    if (data && typeof data === 'object') return normalizeProfileUser(data);
    return null;
  } catch {
    return null;
  }
}
