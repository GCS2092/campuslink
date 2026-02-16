import { apiGet, apiPost, apiPut } from './api';

const P = (path: string) => `users/${path}`;

export interface UniversityAdminDashboardStats {
  total_students?: number;
  pending_verifications?: number;
  total_events?: number;
  [key: string]: number | undefined;
}

interface UniversityAdminDashboardStatsRaw {
  total_students_count?: number;
  pending_students_count?: number;
  events_count?: number;
  [key: string]: number | unknown[] | object | undefined;
}

export async function getUniversityAdminDashboardStats(): Promise<UniversityAdminDashboardStats | null> {
  try {
    const raw = await apiGet<UniversityAdminDashboardStatsRaw>(P('university-admin/dashboard-stats/'));
    if (!raw) return null;
    return {
      ...raw,
      total_students: Number(raw.total_students_count ?? raw.total_students ?? 0),
      pending_verifications: Number(raw.pending_students_count ?? raw.pending_verifications ?? 0),
      total_events: Number(raw.events_count ?? raw.total_events ?? 0),
    } as UniversityAdminDashboardStats;
  } catch {
    return null;
  }
}

export async function getActiveStudents(params?: { page?: number }): Promise<unknown[]> {
  try {
    const q = new URLSearchParams();
    q.set('role', 'student');
    q.set('is_active', 'true');
    if (params?.page != null) q.set('page', String(params.page));
    const data = await apiGet<unknown[] | { results?: unknown[] }>(`users/?${q}`);
    return Array.isArray(data) ? data : (data as { results?: unknown[] })?.results ?? [];
  } catch {
    return [];
  }
}

export async function getPendingStudents(params?: { page?: number }): Promise<unknown[]> {
  try {
    const suffix = params?.page != null ? `?page=${params.page}` : '';
    const data = await apiGet<unknown[] | { results?: unknown[] }>(P('admin/pending-students/') + suffix);
    return Array.isArray(data) ? data : (data as { results?: unknown[] })?.results ?? [];
  } catch {
    return [];
  }
}

export async function verifyUser(userId: string): Promise<{ success: boolean; error?: string }> {
  try {
    await apiPost(P(`admin/users/${userId}/verify/`), {});
    return { success: true };
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { error?: string } } })?.response?.data?.error;
    return { success: false, error: msg || 'Erreur' };
  }
}

export async function rejectUser(userId: string): Promise<{ success: boolean; error?: string }> {
  try {
    await apiPost(P(`admin/users/${userId}/reject/`), {});
    return { success: true };
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { error?: string } } })?.response?.data?.error;
    return { success: false, error: msg || 'Erreur' };
  }
}

export async function activateStudent(userId: string): Promise<{ success: boolean; error?: string }> {
  try {
    await apiPut(P(`admin/students/${userId}/activate/`));
    return { success: true };
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { error?: string } } })?.response?.data?.error;
    return { success: false, error: msg || 'Erreur' };
  }
}

export async function deactivateStudent(userId: string): Promise<{ success: boolean; error?: string }> {
  try {
    await apiPut(P(`admin/students/${userId}/deactivate/`));
    return { success: true };
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { error?: string } } })?.response?.data?.error;
    return { success: false, error: msg || 'Erreur' };
  }
}

export async function getClassLeaders(): Promise<unknown[]> {
  try {
    const data = await apiGet<{ results?: unknown[] }>(P('admin/class-leaders/'));
    return data.results ?? [];
  } catch {
    return [];
  }
}

export async function assignClassLeader(userId: string): Promise<{ success: boolean; error?: string }> {
  try {
    await apiPut(P(`admin/class-leaders/${userId}/assign/`));
    return { success: true };
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { error?: string } } })?.response?.data?.error;
    return { success: false, error: msg || 'Erreur' };
  }
}

export async function revokeClassLeader(userId: string): Promise<{ success: boolean; error?: string }> {
  try {
    await apiPut(P(`admin/class-leaders/${userId}/revoke/`));
    return { success: true };
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { error?: string } } })?.response?.data?.error;
    return { success: false, error: msg || 'Erreur' };
  }
}

export async function getCampuses(): Promise<unknown[]> {
  try {
    const data = await apiGet<{ results?: unknown[] }>('users/campuses/');
    return data.results ?? [];
  } catch {
    return [];
  }
}

export async function getDepartments(): Promise<unknown[]> {
  try {
    const data = await apiGet<{ results?: unknown[] }>('users/departments/');
    return data.results ?? [];
  } catch {
    return [];
  }
}
