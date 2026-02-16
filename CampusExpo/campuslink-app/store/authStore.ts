import { create } from 'zustand';
import * as SecureStore from 'expo-secure-store';
import { STORAGE_KEYS } from '../constants';
import type { User } from '../types';

interface AuthState {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  setUser: (user: User | null) => void;
  setToken: (token: string | null) => void;
  loadFromStorage: () => Promise<void>;
  logout: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  token: null,
  isLoading: true,

  setUser: (user) => set({ user }),
  setToken: (token) => set({ token }),

  loadFromStorage: async () => {
    try {
      const [token, userJson] = await Promise.all([
        SecureStore.getItemAsync(STORAGE_KEYS.accessToken),
        SecureStore.getItemAsync(STORAGE_KEYS.userData),
      ]);
      const user = userJson ? (JSON.parse(userJson) as User) : null;
      set({ token, user, isLoading: false });
    } catch {
      set({ token: null, user: null, isLoading: false });
    }
  },

  logout: async () => {
    await SecureStore.deleteItemAsync(STORAGE_KEYS.accessToken);
    await SecureStore.deleteItemAsync(STORAGE_KEYS.refreshToken);
    await SecureStore.deleteItemAsync(STORAGE_KEYS.userData);
    set({ user: null, token: null });
  },
}));
