import axios, { AxiosInstance, InternalAxiosRequestConfig } from 'axios';
import * as SecureStore from 'expo-secure-store';
import { ENDPOINTS, STORAGE_KEYS } from '../constants';
import { useAuthStore } from '../store/authStore';
import { resolveApiBaseUrl } from './apiConfig';

let api: AxiosInstance | null = null;
let apiPromise: Promise<AxiosInstance> | null = null;
let refreshPromise: Promise<string | null> | null = null;

async function getToken(): Promise<string | null> {
  return SecureStore.getItemAsync(STORAGE_KEYS.accessToken);
}

async function doRefreshToken(instance: AxiosInstance): Promise<string | null> {
  if (refreshPromise) return refreshPromise;

  refreshPromise = (async () => {
    const refresh = await SecureStore.getItemAsync(STORAGE_KEYS.refreshToken);
    if (!refresh) return null;
    try {
      const base = (instance.defaults.baseURL ?? '').replace(/\/$/, '');
      const path = ENDPOINTS.refreshToken.replace(/^\//, '');
      const { data } = await axios.post<{ access?: string }>(
        `${base}/${path}`,
        { refresh },
        { headers: { 'Content-Type': 'application/json' }, timeout: 10000 }
      );
      const access = data.access;
      if (access) {
        await SecureStore.setItemAsync(STORAGE_KEYS.accessToken, access);
        return access;
      }
    } catch {
      /* ignore */
    }
    return null;
  })();

  try {
    return await refreshPromise;
  } finally {
    refreshPromise = null;
  }
}

async function clearAuth(): Promise<void> {
  await SecureStore.deleteItemAsync(STORAGE_KEYS.accessToken);
  await SecureStore.deleteItemAsync(STORAGE_KEYS.refreshToken);
  await SecureStore.deleteItemAsync(STORAGE_KEYS.userData);
  useAuthStore.getState().setUser(null);
  useAuthStore.getState().setToken(null);
}

/** Retourne l'instance API (résout l'URL selon le réseau au premier appel). */
export async function getApi(): Promise<AxiosInstance> {
  if (api) return api;
  if (apiPromise) return apiPromise;

  apiPromise = (async () => {
    const baseURL = await resolveApiBaseUrl();
    const instance = axios.create({
      baseURL,
      timeout: 30000,
      headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    });
    instance.interceptors.request.use(async (config) => {
      const token = await getToken();
      if (token) config.headers.Authorization = `Bearer ${token}`;
      return config;
    });
    instance.interceptors.response.use(
      (r) => r,
      async (err) => {
        const originalRequest = err.config as InternalAxiosRequestConfig & { _retry?: boolean };
        if (err.response?.status === 401 && !originalRequest._retry) {
          const isTokenError =
            (err.response?.data?.code === 'token_not_valid') ||
            (String(err.response?.data?.detail ?? '').includes('token'));
          if (isTokenError && (await SecureStore.getItemAsync(STORAGE_KEYS.refreshToken))) {
            originalRequest._retry = true;
            const newToken = await doRefreshToken(instance);
            if (newToken) {
              originalRequest.headers.Authorization = `Bearer ${newToken}`;
              useAuthStore.getState().setToken(newToken);
              return instance.request(originalRequest);
            }
          }
          await clearAuth();
        }
        return Promise.reject(err);
      }
    );
    api = instance;
    return instance;
  })();

  try {
    return await apiPromise;
  } finally {
    apiPromise = null;
  }
}

export async function apiGet<T = unknown>(url: string): Promise<T> {
  const instance = await getApi();
  const { data } = await instance.get<T>(url);
  return data;
}

export async function apiPost<T = unknown>(url: string, body: object): Promise<T> {
  const instance = await getApi();
  const { data } = await instance.post<T>(url, body);
  return data;
}

export async function apiPut<T = unknown>(url: string, body?: object): Promise<T> {
  const instance = await getApi();
  const { data } = await instance.put<T>(url, body ?? {});
  return data;
}

export async function apiDelete(url: string): Promise<void> {
  const instance = await getApi();
  await instance.delete(url);
}
