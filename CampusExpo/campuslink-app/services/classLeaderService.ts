import { apiGet } from './api';

const P = (path: string) => `users/${path}`;

export interface ClassLeaderDashboardStats {
  students_count?: number;
  events_count?: number;
  groups_count?: number;
  [key: string]: number | undefined;
}

interface ClassLeaderDashboardStatsRaw {
  total_students_count?: number;
  students_count?: number;
  events_count?: number;
  groups_count?: number;
  [key: string]: number | unknown[] | object | undefined;
}

export async function getClassLeaderDashboardStats(): Promise<ClassLeaderDashboardStats | null> {
  try {
    const raw = await apiGet<ClassLeaderDashboardStatsRaw>(P('class-leader/dashboard-stats/'));
    if (!raw) return null;
    return {
      ...raw,
      students_count: Number(raw.total_students_count ?? raw.students_count ?? 0),
      events_count: Number(raw.events_count ?? 0),
      groups_count: Number(raw.groups_count ?? 0),
    } as ClassLeaderDashboardStats;
  } catch {
    return null;
  }
}

export async function getClassEvents(params?: { status?: string; page?: number }): Promise<unknown[]> {
  try {
    const q = new URLSearchParams();
    if (params?.status) q.set('status', params.status);
    if (params?.page != null) q.set('page', String(params.page));
    const url = q.toString() ? `events/?${q}` : 'events/';
    const data = await apiGet<{ results?: unknown[] }>(url);
    return data.results ?? [];
  } catch {
    return [];
  }
}

export async function getClassGroups(params?: { search?: string; page?: number }): Promise<unknown[]> {
  try {
    const q = new URLSearchParams();
    if (params?.search) q.set('search', params.search);
    if (params?.page != null) q.set('page', String(params.page));
    const url = q.toString() ? `groups/?${q}` : 'groups/';
    const data = await apiGet<{ results?: unknown[] }>(url);
    return data.results ?? [];
  } catch {
    return [];
  }
}

export async function getClassStudents(params?: { search?: string; page?: number }): Promise<unknown[]> {
  try {
    const q = new URLSearchParams();
    if (params?.search) q.set('search', params.search);
    if (params?.page != null) q.set('page', String(params.page));
    const url = q.toString() ? `users/students/?${q}` : 'users/students/';
    const data = await apiGet<{ results?: unknown[] }>(url);
    return data.results ?? [];
  } catch {
    return [];
  }
}
