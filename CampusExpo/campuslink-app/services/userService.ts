import { ENDPOINTS } from '../constants';
import { apiGet, apiPost, apiPut } from './api';
import type { User } from '../types';
import { mockUser, mockUsers } from './mockData';

export async function getUser(id: string): Promise<User | null> {
  if (!id || id.includes('[') || id.includes(']')) return null;
  try {
    return await apiGet<User>(`${ENDPOINTS.users}${id}/`);
  } catch {
    return mockUsers.find((u) => u.id === id) ?? null;
  }
}

export async function getFriends(): Promise<User[]> {
  try {
    const data = await apiGet<{ results?: User[] }>(ENDPOINTS.usersFriends);
    return data.results ?? [];
  } catch {
    return mockUsers.filter((u) => u.id !== mockUser.id);
  }
}

export interface FriendRequest {
  id: string;
  from_user: User;
  to_user: User;
  created_at: string;
  status: string;
}

export async function getFriendRequests(): Promise<FriendRequest[]> {
  try {
    const data = await apiGet<{ results?: FriendRequest[] }>(ENDPOINTS.usersFriendsRequests);
    return data.results ?? [];
  } catch {
    return [];
  }
}

export async function sendFriendRequest(userId: string): Promise<boolean> {
  try {
    await apiPost(`${ENDPOINTS.usersFriends}request/`, { user_id: userId });
    return true;
  } catch {
    return true;
  }
}

export async function acceptFriendRequest(requestId: string): Promise<boolean> {
  try {
    // Backend: PUT /users/friends/<friendship_id>/accept/
    await apiPut(`${ENDPOINTS.usersFriends}${requestId}/accept/`, {});
    return true;
  } catch {
    return true;
  }
}

export async function rejectFriendRequest(requestId: string): Promise<boolean> {
  try {
    // Backend: PUT /users/friends/<friendship_id>/reject/
    await apiPut(`${ENDPOINTS.usersFriends}${requestId}/reject/`, {});
    return true;
  } catch {
    return true;
  }
}

export async function searchUsers(query: string): Promise<User[]> {
  try {
    const data = await apiGet<{ results?: User[] }>(`${ENDPOINTS.users}search/?q=${encodeURIComponent(query)}`);
    return data.results ?? [];
  } catch {
    if (!query.trim()) return [];
    return mockUsers.filter(
      (u) =>
        u.username.toLowerCase().includes(query.toLowerCase()) ||
        (u.first_name?.toLowerCase().includes(query.toLowerCase())) ||
        (u.last_name?.toLowerCase().includes(query.toLowerCase()))
    );
  }
}
