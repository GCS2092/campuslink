import { ENDPOINTS } from '../constants';
import { apiGet, apiPost } from './api';
import type { Group, User } from '../types';
import { mockGroups, mockUsers } from './mockData';

function normalizeGroup(raw: Record<string, unknown>): Group {
  return {
    id: String(raw.id),
    name: String(raw.name ?? ''),
    description: String(raw.description ?? ''),
    members_count: Number(raw.members_count ?? 0),
    image_url: (raw.cover_image as string) ?? (raw.profile_image as string) ?? (raw.image_url as string),
    is_private: raw.is_public === false,
    created_at: String(raw.created_at ?? new Date().toISOString()),
  };
}

export async function getGroups(): Promise<Group[]> {
  try {
    const data = await apiGet<{ results?: Record<string, unknown>[] }>(ENDPOINTS.groups);
    const list = data.results ?? [];
    return list.map((item) => normalizeGroup(item as Record<string, unknown>));
  } catch {
    return mockGroups;
  }
}

export async function getGroup(id: string): Promise<Group | null> {
  try {
    const raw = await apiGet<Record<string, unknown>>(`${ENDPOINTS.groups}${id}/`);
    if (raw && raw.id) return normalizeGroup(raw);
    return null;
  } catch {
    return mockGroups.find((g) => g.id === id) ?? null;
  }
}

export async function getGroupMembers(groupId: string): Promise<User[]> {
  try {
    const data = await apiGet<{ results?: User[] }>(`${ENDPOINTS.groups}${groupId}/members/`);
    return data.results ?? [];
  } catch {
    return mockUsers.slice(0, 5);
  }
}

export async function createGroup(payload: { name: string; description: string; is_private?: boolean }): Promise<Group | null> {
  try {
    const body = {
      name: payload.name,
      description: payload.description,
      is_public: payload.is_private !== true,
    };
    const raw = await apiPost<Record<string, unknown>>(ENDPOINTS.groups, body);
    if (raw && raw.id) return normalizeGroup(raw);
    return null;
  } catch {
    return {
      id: String(Date.now()),
      name: payload.name,
      description: payload.description,
      members_count: 1,
      is_private: payload.is_private,
      created_at: new Date().toISOString(),
    };
  }
}

export async function joinGroup(groupId: string): Promise<boolean> {
  try {
    await apiPost(`${ENDPOINTS.groups}${groupId}/join/`, {});
    return true;
  } catch {
    return true;
  }
}

export async function leaveGroup(groupId: string): Promise<boolean> {
  try {
    await apiPost(`${ENDPOINTS.groups}${groupId}/leave/`, {});
    return true;
  } catch {
    return true;
  }
}
