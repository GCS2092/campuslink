import { ENDPOINTS } from '../constants';
import { apiGet, apiPut } from './api';
import type { NotificationItem } from '../types';
import { mockNotifications } from './mockData';

const TTL_MS = 5000;
let notificationsCache: { ts: number; data: NotificationItem[] } | null = null;
let unreadCache: { ts: number; count: number } | null = null;
let notificationsPromise: Promise<NotificationItem[]> | null = null;
let unreadPromise: Promise<number> | null = null;

export async function getNotifications(): Promise<NotificationItem[]> {
  if (notificationsCache && Date.now() - notificationsCache.ts < TTL_MS) return notificationsCache.data;
  if (notificationsPromise) return notificationsPromise;

  notificationsPromise = (async () => {
  try {
    const data = await apiGet<{ results?: NotificationItem[] }>(ENDPOINTS.notifications);
    const res = data.results ?? [];
    notificationsCache = { ts: Date.now(), data: res };
    return res;
  } catch {
    const res = mockNotifications;
    notificationsCache = { ts: Date.now(), data: res };
    return res;
  }
  })();

  try {
    return await notificationsPromise;
  } finally {
    notificationsPromise = null;
  }
}

export async function getUnreadCount(): Promise<number> {
  if (unreadCache && Date.now() - unreadCache.ts < TTL_MS) return unreadCache.count;
  if (unreadPromise) return unreadPromise;

  unreadPromise = (async () => {
  try {
    const data = await apiGet<{ count?: number }>(`${ENDPOINTS.notifications}unread_count/`);
    const count = data.count ?? 0;
    unreadCache = { ts: Date.now(), count };
    return count;
  } catch {
    const count = mockNotifications.filter((n) => !n.read).length;
    unreadCache = { ts: Date.now(), count };
    return count;
  }
  })();

  try {
    return await unreadPromise;
  } finally {
    unreadPromise = null;
  }
}

export async function markAsRead(id: string): Promise<void> {
  try {
    await apiPut(`${ENDPOINTS.notifications}${id}/read/`);
    notificationsCache = null;
    unreadCache = null;
  } catch {
    // noop
  }
}

export async function markAllAsRead(): Promise<void> {
  try {
    await apiPut(`${ENDPOINTS.notifications}read_all/`);
    notificationsCache = null;
    unreadCache = null;
  } catch {
    // noop
  }
}
