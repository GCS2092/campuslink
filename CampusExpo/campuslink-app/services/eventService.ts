import { ENDPOINTS } from '../constants';
import { apiGet, apiPost } from './api';
import type { Event, EventOrganizer } from '../types';
import { mockEvents } from './mockData';

function organizerName(org: { first_name?: string; last_name?: string; username?: string; name?: string } | null): string {
  if (!org) return '—';
  if (org.name) return org.name;
  const full = [org.first_name, org.last_name].filter(Boolean).join(' ');
  return full || org.username || '—';
}

function normalizeEvent(raw: Record<string, unknown>): Event {
  const org = raw.organizer as Record<string, unknown> | undefined;
  const organizer: EventOrganizer = {
    id: String(org?.id ?? ''),
    name: organizerName(org as { first_name?: string; last_name?: string; username?: string; name?: string }),
  };
  return {
    id: String(raw.id),
    title: String(raw.title ?? ''),
    description: String(raw.description ?? ''),
    organizer,
    category: raw.category as Event['category'],
    start_date: String(raw.start_date ?? ''),
    end_date: raw.end_date as string | undefined,
    location: String(raw.location ?? ''),
    image_url: raw.image_url as string | undefined,
    capacity: raw.capacity as number | undefined,
    price: Number(raw.price ?? 0),
    is_free: Boolean(raw.is_free),
    status: String(raw.status ?? 'published'),
    participants_count: Number(raw.participants_count ?? 0),
    is_participating: Boolean(raw.is_participating),
    created_at: String(raw.created_at ?? ''),
  };
}

export async function getEvents(): Promise<Event[]> {
  try {
    const data = await apiGet<{ results?: Record<string, unknown>[]; data?: Record<string, unknown>[] } | Record<string, unknown>[]>(ENDPOINTS.events);
    const list = Array.isArray(data) ? data : (data.results ?? data.data ?? []);
    if (!Array.isArray(list)) return [];
    return list.map((item) => normalizeEvent(item as Record<string, unknown>));
  } catch {
    return mockEvents;
  }
}

export async function getEvent(id: string): Promise<Event | null> {
  try {
    const raw = await apiGet<Record<string, unknown>>(`${ENDPOINTS.events}${id}/`);
    if (raw && raw.id) return normalizeEvent(raw);
    return null;
  } catch {
    return mockEvents.find((e) => e.id === id) ?? null;
  }
}

export async function getMyEvents(): Promise<Event[]> {
  try {
    const data = await apiGet<{ results?: Record<string, unknown>[] }>(`${ENDPOINTS.events}my_events/`);
    const list = data.results ?? [];
    return list.map((item) => normalizeEvent(item as Record<string, unknown>));
  } catch {
    return mockEvents.filter((e) => e.is_participating);
  }
}

export async function createEvent(payload: {
  title: string;
  description: string;
  start_date: string;
  location: string;
  end_date?: string;
  is_free?: boolean;
  price?: number;
}): Promise<Event | null> {
  try {
    const raw = await apiPost<Record<string, unknown>>(ENDPOINTS.events, payload);
    if (raw && raw.id) return normalizeEvent(raw);
    return null;
  } catch {
    const newEv: Event = {
      id: String(Date.now()),
      ...payload,
      organizer: { id: '1', name: 'Moi' },
      price: payload.price ?? 0,
      is_free: payload.is_free ?? true,
      status: 'published',
      participants_count: 0,
      created_at: new Date().toISOString(),
    };
    return newEv;
  }
}

export async function participate(eventId: string): Promise<boolean> {
  try {
    await apiPost(`${ENDPOINTS.events}${eventId}/participate/`, {});
    return true;
  } catch {
    return true;
  }
}

export async function leaveEvent(eventId: string): Promise<boolean> {
  try {
    await apiPost(`${ENDPOINTS.events}${eventId}/leave/`, {});
    return true;
  } catch {
    return true;
  }
}
