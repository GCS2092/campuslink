/**
 * Résout l'URL de base de l'API selon le réseau (WiFi / connexion).
 * Essaie en priorité les backends locaux (liste de candidats courants), puis production.
 * Sans dépendance expo-network pour éviter les soucis d'installation.
 */
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

const CACHE_KEY = 'campuslink_api_base_url';
const CACHE_TS_KEY = 'campuslink_api_base_url_ts';
const CACHE_TTL_MS = 5 * 60 * 1000; // 5 min

const PRODUCTION_URL = 'https://campuslink-9knz.onrender.com/api';

function isWeb(): boolean {
  // eslint-disable-next-line no-restricted-globals
  return typeof window !== 'undefined' && typeof document !== 'undefined';
}

/** Liste des URLs candidates : locales (émulateur + 192.168.x.x) puis production. */
function getCandidates(): string[] {
  return [
    'http://10.0.2.2:8000/api',
    'http://192.168.1.1:8000/api',
    'http://192.168.1.2:8000/api',
    'http://192.168.1.10:8000/api',
    'http://192.168.1.35:8000/api',
    'http://192.168.1.50:8000/api',
    'http://192.168.1.100:8000/api',
    'http://192.168.1.125:8000/api',
    'http://192.168.1.127:8000/api',
    'http://192.168.0.1:8000/api',
    'http://192.168.12.35:8000/api',
    PRODUCTION_URL,
  ];
}

async function tryBaseUrl(baseUrl: string): Promise<boolean> {
  try {
    const url = baseUrl.endsWith('/') ? `${baseUrl}auth/login/` : `${baseUrl}/auth/login/`;
    const r = await axios.get(url, {
      timeout: 3000,
      validateStatus: (s) => s === 200 || s === 405,
    });
    // 200 = endpoint existe, 405 = GET non autorisé (login attend POST) → c'est notre API
    return r.status === 200 || r.status === 405;
  } catch {
    return false;
  }
}

/**
 * Résout l'URL de base : cache 5 min, sinon détection (IP WiFi si dispo) + test des candidats.
 */
export async function resolveApiBaseUrl(): Promise<string> {
  // En Web, les probes cross-origin (ex: GET /auth/login/) sont bloqués par CORS.
  // On utilise donc une URL explicite (env) ou la prod.
  if (isWeb()) {
    const envUrl = (process.env.EXPO_PUBLIC_API_BASE_URL ?? '').trim();
    return envUrl || PRODUCTION_URL;
  }

  try {
    const cached = await AsyncStorage.getItem(CACHE_KEY);
    const tsStr = await AsyncStorage.getItem(CACHE_TS_KEY);
    const ts = tsStr ? parseInt(tsStr, 10) : 0;
    if (cached && Date.now() - ts < CACHE_TTL_MS) {
      return cached;
    }
  } catch {
    /* ignore */
  }

  const candidates = getCandidates();

  for (const url of candidates) {
    if (await tryBaseUrl(url)) {
      try {
        await AsyncStorage.setItem(CACHE_KEY, url);
        await AsyncStorage.setItem(CACHE_TS_KEY, String(Date.now()));
      } catch {
        /* ignore */
      }
      return url;
    }
  }

  try {
    await AsyncStorage.setItem(CACHE_KEY, PRODUCTION_URL);
    await AsyncStorage.setItem(CACHE_TS_KEY, String(Date.now()));
  } catch {
    /* ignore */
  }
  return PRODUCTION_URL;
}

export function invalidateApiBaseUrlCache(): Promise<void> {
  return Promise.all([
    AsyncStorage.removeItem(CACHE_KEY),
    AsyncStorage.removeItem(CACHE_TS_KEY),
  ]).then(() => undefined);
}
