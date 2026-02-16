import { useEffect, useState, useCallback } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, RefreshControl } from 'react-native';
import { useRouter, Stack } from 'expo-router';
import { useFocusEffect } from '@react-navigation/native';
import Ionicons from '@expo/vector-icons/Ionicons';
import { useAuthStore } from '../../store/authStore';
import { getClassLeaderDashboardStats } from '../../services/classLeaderService';
import type { ClassLeaderDashboardStats } from '../../services/classLeaderService';
import { isClassLeader } from '../../types';
import { getRedirectForUser } from '../../utils/roleRedirect';
import { Card } from '../../components/Card';

export default function ClassLeaderDashboardScreen() {
  const router = useRouter();
  const { user, logout } = useAuthStore();
  const [stats, setStats] = useState<ClassLeaderDashboardStats | null>(null);
  const [refreshing, setRefreshing] = useState(false);

  const load = useCallback(async () => {
    const data = await getClassLeaderDashboardStats();
    setStats(data);
  }, []);

  useEffect(() => {
    if (!user || !isClassLeader(user)) {
      router.replace(getRedirectForUser(user) as any);
      return;
    }
    load();
  }, [user, load]);

  useFocusEffect(
    useCallback(() => {
      if (user && isClassLeader(user)) load();
    }, [user, load])
  );

  const handleLogout = async () => {
    await logout();
    router.replace('/login');
  };

  if (!user || !isClassLeader(user)) return null;

  return (
    <>
      <Stack.Screen
        options={{
          title: 'Responsable de classe',
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
        <Text style={styles.greeting}>Tableau de bord responsable de classe</Text>
        <View style={styles.statsRow}>
          <View style={styles.statBox}>
            <Text style={styles.statValue}>{stats?.students_count ?? '—'}</Text>
            <Text style={styles.statLabel}>Étudiants</Text>
          </View>
          <View style={styles.statBox}>
            <Text style={styles.statValue}>{stats?.events_count ?? '—'}</Text>
            <Text style={styles.statLabel}>Événements</Text>
          </View>
          <View style={styles.statBox}>
            <Text style={styles.statValue}>{stats?.groups_count ?? '—'}</Text>
            <Text style={styles.statLabel}>Groupes</Text>
          </View>
        </View>
        <Card>
          <TouchableOpacity style={styles.menuRow} onPress={() => router.push('/class-leader/events')}>
            <Ionicons name="calendar" size={24} color="#2563eb" />
            <Text style={styles.menuText}>Événements de la classe</Text>
            <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
          </TouchableOpacity>
          <TouchableOpacity style={styles.menuRow} onPress={() => router.push('/class-leader/groups')}>
            <Ionicons name="people" size={24} color="#2563eb" />
            <Text style={styles.menuText}>Groupes de la classe</Text>
            <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
          </TouchableOpacity>
          <TouchableOpacity style={styles.menuRow} onPress={() => router.push('/class-leader/students')}>
            <Ionicons name="person" size={24} color="#2563eb" />
            <Text style={styles.menuText}>Étudiants de la classe</Text>
            <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
          </TouchableOpacity>
          <TouchableOpacity style={styles.menuRow} onPress={() => router.push('/class-leader/moderation')}>
            <Ionicons name="shield-checkmark" size={24} color="#2563eb" />
            <Text style={styles.menuText}>Modération</Text>
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
  statBox: {
    flex: 1,
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
  },
  statValue: { fontSize: 22, fontWeight: '700', color: '#0f172a' },
  statLabel: { fontSize: 12, color: '#64748b', marginTop: 4 },
  menuRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 14,
    borderBottomWidth: 1,
    borderBottomColor: '#f1f5f9',
  },
  menuText: { flex: 1, marginLeft: 12, fontSize: 16 },
});
