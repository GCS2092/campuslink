import { apiGet, apiPost, apiPut } from './api';

const P = (path: string) => `users/${path}`;

export interface AdminDashboardStats {
  total_students?: number;
  total_events?: number;
  total_groups?: number;
  pending_verifications?: number;
  [key: string]: number | undefined;
}

/** Réponse brute du backend (noms de champs différents). */
interface AdminDashboardStatsRaw {
  total_students_count?: number;
  total_students?: number;
  events_count?: number;
  total_events?: number;
  groups_count?: number;
  total_groups?: number;
  pending_students_count?: number;
  pending_verifications?: number;
  [key: string]: number | unknown[] | undefined;
}

export async function getAdminDashboardStats(): Promise<AdminDashboardStats | null> {
  try {
    const raw = await apiGet<AdminDashboardStatsRaw>(P('admin/dashboard-stats/'));
    if (!raw) return null;
    return {
      ...raw,
      total_students: Number(raw.total_students_count ?? raw.total_students ?? 0),
      total_events: Number(raw.events_count ?? raw.total_events ?? 0),
      total_groups: Number(raw.groups_count ?? raw.total_groups ?? 0),
      pending_verifications: Number(raw.pending_students_count ?? raw.pending_verifications ?? 0),
    } as AdminDashboardStats;
  } catch {
    return null;
  }
}

export async function getPendingStudents(params?: { search?: string; page?: number }): Promise<unknown[]> {
  try {
    const q = new URLSearchParams();
    if (params?.search) q.set('search', params.search);
    if (params?.page != null) q.set('page', String(params.page));
    const url = q.toString() ? `users/admin/pending-students/?${q}` : 'users/admin/pending-students/';
    const data = await apiGet<{ results?: unknown[] }>(url);
    return data.results ?? [];
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

export async function getPendingVerifications(): Promise<unknown[]> {
  try {
    const data = await apiGet<{ results?: unknown[] }>(P('admin/users/pending-verifications/'));
    return data.results ?? [];
  } catch {
    return [];
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

export async function getUniversities(): Promise<unknown[]> {
  try {
    const data = await apiGet<{ results?: unknown[] }>(P('universities/'));
    return data.results ?? [];
  } catch {
    try {
      const data = await apiGet<{ results?: unknown[] }>('auth/universities/');
      return data.results ?? [];
    } catch {
      return [];
    }
  }
}

export async function getModerationReports(): Promise<unknown[]> {
  try {
    const data = await apiGet<{ results?: unknown[] }>('moderation/admin/reports/');
    return data.results ?? [];
  } catch {
    return [];
  }
}

export async function resolveReport(reportId: string): Promise<{ success: boolean }> {
  try {
    await apiPost(`moderation/admin/reports/${reportId}/resolve/`, {});
    return { success: true };
  } catch {
    return { success: false };
  }
}

/** Rejeter / classer un signalement sans suite (backend: dismiss). */
export async function rejectReport(reportId: string): Promise<{ success: boolean }> {
  try {
    await apiPost(`moderation/admin/reports/${reportId}/dismiss/`, {});
    return { success: true };
  } catch {
    return { success: false };
  }
}
