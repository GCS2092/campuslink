import { ENDPOINTS } from '../constants';
import { apiGet, apiPut } from './api';
import type { NotificationItem } from '../types';
import { mockNotifications } from './mockData';

export async function getNotifications(): Promise<NotificationItem[]> {
  try {
    const data = await apiGet<{ results?: NotificationItem[] }>(ENDPOINTS.notifications);
    return data.results ?? [];
  } catch {
    return mockNotifications;
  }
}

export async function getUnreadCount(): Promise<number> {
  try {
    const data = await apiGet<{ count?: number }>(`${ENDPOINTS.notifications}unread_count/`);
    return data.count ?? 0;
  } catch {
    return mockNotifications.filter((n) => !n.read).length;
  }
}

export async function markAsRead(id: string): Promise<void> {
  try {
    await apiPut(`${ENDPOINTS.notifications}${id}/read/`);
  } catch {
    // noop
  }
}

export async function markAllAsRead(): Promise<void> {
  try {
    await apiPut(`${ENDPOINTS.notifications}read_all/`);
  } catch {
    // noop
  }
}
