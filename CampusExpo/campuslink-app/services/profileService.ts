import { ENDPOINTS } from '../constants';
import { apiGet, apiPost, apiPut } from './api';
import type { User } from '../types';

const PROFILE_CHANGE_PASSWORD = `${ENDPOINTS.profile}change-password/`;
const PROFILE_NOTIFICATION_PREFS = `${ENDPOINTS.profile}notification-preferences/`;

export async function getMyProfile(): Promise<User | null> {
  try {
    const data = await apiGet<User>(ENDPOINTS.profile);
    return data ?? null;
  } catch {
    return null;
  }
}

export async function updateMyProfile(payload: Partial<User> & { profile?: User['profile'] }): Promise<User | null> {
  try {
    const data = await apiPut<User>(ENDPOINTS.profile, payload as object);
    return data ?? null;
  } catch {
    return null;
  }
}

export async function changePassword(payload: {
  old_password: string;
  new_password: string;
  new_password_confirm?: string;
}): Promise<{ success: boolean; error?: string }> {
  try {
    await apiPost(PROFILE_CHANGE_PASSWORD, {
      old_password: payload.old_password,
      new_password: payload.new_password,
      new_password_confirm: payload.new_password_confirm ?? payload.new_password,
    });
    return { success: true };
  } catch (e: unknown) {
    const err = e as { response?: { data?: Record<string, unknown> } };
    const data = err.response?.data;
    const first = data && typeof data === 'object' ? Object.values(data).flat().find(Boolean) : null;
    return { success: false, error: typeof first === 'string' ? first : 'Impossible de changer le mot de passe' };
  }
}

export interface NotificationPreferences {
  email_notifications?: boolean;
  push_notifications?: boolean;
  event_reminders?: boolean;
  friend_requests?: boolean;
  messages?: boolean;
  group_updates?: boolean;
  event_invitations?: boolean;

  // Backward-compat (anciennes clés utilisées côté app)
  event_notifications?: boolean;
  message_notifications?: boolean;
  group_notifications?: boolean;
  sms_notifications?: boolean;
}

function normalizeNotificationPreferences(input: NotificationPreferences): NotificationPreferences {
  return {
    email_notifications: input.email_notifications,
    push_notifications: input.push_notifications,
    event_reminders: input.event_reminders ?? input.event_notifications,
    friend_requests: input.friend_requests,
    messages: input.messages ?? input.message_notifications,
    group_updates: input.group_updates ?? input.group_notifications,
    event_invitations: input.event_invitations,
  };
}

export async function getNotificationPreferences(): Promise<NotificationPreferences | null> {
  try {
    const data = await apiGet<NotificationPreferences>(PROFILE_NOTIFICATION_PREFS);
    if (!data) return null;
    return normalizeNotificationPreferences(data);
  } catch {
    return null;
  }
}

export async function updateNotificationPreferences(payload: NotificationPreferences): Promise<NotificationPreferences | null> {
  try {
    const normalized = normalizeNotificationPreferences(payload);
    const data = await apiPut<NotificationPreferences>(PROFILE_NOTIFICATION_PREFS, normalized as object);
    if (!data) return null;
    return normalizeNotificationPreferences(data);
  } catch {
    return null;
  }
}
