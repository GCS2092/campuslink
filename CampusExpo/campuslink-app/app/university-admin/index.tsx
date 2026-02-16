import { useEffect, useState, useCallback } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, RefreshControl } from 'react-native';
import { useRouter, Stack } from 'expo-router';
import { useFocusEffect } from '@react-navigation/native';
import Ionicons from '@expo/vector-icons/Ionicons';
import { useAuthStore } from '../../store/authStore';
import { getUniversityAdminDashboardStats } from '../../services/universityAdminService';
import type { UniversityAdminDashboardStats } from '../../services/universityAdminService';
import { isUniversityAdmin } from '../../types';
import { getRedirectForUser } from '../../utils/roleRedirect';
import { Card } from '../../components/Card';

export default function UniversityAdminDashboardScreen() {
  const router = useRouter();
  const { user, logout } = useAuthStore();
  const [stats, setStats] = useState<UniversityAdminDashboardStats | null>(null);
  const [refreshing, setRefreshing] = useState(false);

  const load = useCallback(async () => {
    const data = await getUniversityAdminDashboardStats();
    setStats(data);
  }, []);

  useEffect(() => {
    if (!user || !isUniversityAdmin(user)) {
      router.replace(getRedirectForUser(user) as any);
      return;
    }
    load();
  }, [user, load]);

  useFocusEffect(
    useCallback(() => {
      if (user && isUniversityAdmin(user)) load();
    }, [user, load])
  );

  const handleLogout = async () => {
    await logout();
    router.replace('/login');
  };

  if (!user || !isUniversityAdmin(user)) return null;

  return (
    <>
      <Stack.Screen
        options={{
          title: 'Admin université',
          headerRight: () => (
            <TouchableOpacity onPress={handleLogout}>
              <Text style={{ color: '#fff', marginRight: 12 }}>Déconnexion</Text>
            </TouchableOpacity>
          ),
        }}
      />
      <ScrollView
        style={styles.container}
        contentContainerStyle={styles.content}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
      >
        <Text style={styles.greeting}>Tableau de bord admin université</Text>
        <View style={styles.statsRow}>
          <View style={styles.statBox}>
            <Text style={styles.statValue}>{stats?.total_students ?? '—'}</Text>
            <Text style={styles.statLabel}>Étudiants</Text>
          </View>
          <View style={[styles.statBox, styles.statBoxWarning]}>
            <Text style={styles.statValue}>{stats?.pending_verifications ?? '—'}</Text>
            <Text style={styles.statLabel}>En attente</Text>
          </View>
        </View>
        <Card>
          <Text style={styles.sectionTitle}>Gestion</Text>
          <TouchableOpacity style={styles.menuRow} onPress={() => router.push('/university-admin/students')}>
            <Ionicons name="people" size={24} color="#2563eb" />
            <Text style={styles.menuText}>Étudiants</Text>
            <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
          </TouchableOpacity>
          <TouchableOpacity style={styles.menuRow} onPress={() => router.push('/university-admin/verifications')}>
            <Ionicons name="checkmark-circle" size={24} color="#2563eb" />
            <Text style={styles.menuText}>Vérifications</Text>
            <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
          </TouchableOpacity>
          <TouchableOpacity style={styles.menuRow} onPress={() => router.push('/university-admin/class-leaders')}>
            <Ionicons name="school" size={24} color="#2563eb" />
            <Text style={styles.menuText}>Responsables de classe</Text>
            <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
          </TouchableOpacity>
          <TouchableOpacity style={styles.menuRow} onPress={() => router.push('/university-admin/campuses')}>
            <Ionicons name="location" size={24} color="#2563eb" />
            <Text style={styles.menuText}>Campus</Text>
            <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
          </TouchableOpacity>
          <TouchableOpacity style={styles.menuRow} onPress={() => router.push('/university-admin/departments')}>
            <Ionicons name="library" size={24} color="#2563eb" />
            <Text style={styles.menuText}>Départements</Text>
            <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
          </TouchableOpacity>
          <TouchableOpacity style={styles.menuRow} onPress={() => router.push('/university-admin/moderation')}>
            <Ionicons name="shield-checkmark" size={24} color="#2563eb" />
            <Text style={styles.menuText}>Modération</Text>
            <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
          </TouchableOpacity>
          <TouchableOpacity style={styles.menuRow} onPress={() => router.push('/university-admin/settings')}>
            <Ionicons name="settings" size={24} color="#2563eb" />
            <Text style={styles.menuText}>Paramètres</Text>
            <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
          </TouchableOpacity>
        </Card>
      </ScrollView>
    </>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f1f5f9' },
  content: { padding: 16, paddingBottom: 32 },
  greeting: { fontSize: 18, color: '#64748b', marginBottom: 16 },
  statsRow: { flexDirection: 'row', gap: 12, marginBottom: 16 },
  statBox: { flex: 1, backgroundColor: '#fff', padding: 16, borderRadius: 12, alignItems: 'center' },
  statBoxWarning: { backgroundColor: '#fef3c7' },
  statValue: { fontSize: 22, fontWeight: '700', color: '#0f172a' },
  statLabel: { fontSize: 12, color: '#64748b', marginTop: 4 },
  sectionTitle: { fontSize: 16, fontWeight: '600', marginBottom: 12 },
  menuRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 14,
    borderBottomWidth: 1,
    borderBottomColor: '#f1f5f9',
  },
  menuText: { flex: 1, marginLeft: 12, fontSize: 16 },
});
