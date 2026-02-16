// API Configuration - l'URL est résolue automatiquement selon le réseau (voir services/apiConfig.ts).
// On essaie d'abord les backends locaux (10.0.2.2, 192.168.x.x), puis production.
// Pour forcer une URL, modifier getDefaultCandidates() dans services/apiConfig.ts.
export const API_BASE_URL = 'https://campuslink-9knz.onrender.com/api'; // fallback production

export const ENDPOINTS = {
  login: 'auth/login/',
  register: 'auth/register/',
  profile: 'auth/profile/',
  refreshToken: 'auth/token/refresh/',
  events: 'events/',
  feed: 'feed/',
  feedPersonalized: 'feed/personalized/',
  socialPosts: 'social/posts/',
  groups: 'groups/',
  conversations: 'messaging/conversations/',
  messages: 'messaging/messages/',
  notifications: 'notifications/',
  users: 'users/',
  usersFriends: 'users/friends/',
  usersFriendsRequests: 'users/friends/requests/',
} as const;

export const STORAGE_KEYS = {
  accessToken: 'auth_token',
  refreshToken: 'refresh_token',
  userData: 'user_data',
} as const;
