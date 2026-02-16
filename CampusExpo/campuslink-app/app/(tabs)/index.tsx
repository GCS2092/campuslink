import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, RefreshControl } from 'react-native';
import { useRouter } from 'expo-router';
import Ionicons from '@expo/vector-icons/Ionicons';
import { useAuthStore } from '../../store/authStore';
import { getMyEvents } from '../../services/eventService';
import { getUnreadCount } from '../../services/notificationService';
import type { Event } from '../../types';
import { Card } from '../../components/Card';

function formatDate(iso: string) {
  const d = new Date(iso);
  return d.toLocaleDateString('fr-FR', { weekday: 'short', day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
}

export default function DashboardScreen() {
  const router = useRouter();
  const { user } = useAuthStore();
  const [events, setEvents] = useState<Event[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    const [ev, count] = await Promise.all([getMyEvents(), getUnreadCount()]);
    setEvents(ev.slice(0, 5));
    setUnreadCount(count);
  };

  useEffect(() => {
    load();
  }, []);

  const onRefresh = async () => {
    setRefreshing(true);
    await load();
    setRefreshing(false);
  };

  const displayName = user?.first_name && user?.last_name
    ? `${user.first_name} ${user.last_name}`
    : user?.username ?? 'Étudiant';

  return (
    <ScrollView
      style={styles.container}
      contentContainerStyle={styles.content}
      refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
    >
      <View style={styles.header}>
        <Text style={styles.greeting}>Bonjour, {displayName}</Text>
        <Text style={styles.role}>{user?.profile?.campus ?? 'Campus'}</Text>
      </View>

      <View style={styles.quickActions}>
        <TouchableOpacity style={styles.quickBtn} onPress={() => router.push('/conversations')}>
          <Ionicons name="chatbubbles" size={28} color="#2563eb" />
          <Text style={styles.quickLabel}>Messages</Text>
          {unreadCount > 0 && (
            <View style={styles.badge}><Text style={styles.badgeText}>{unreadCount > 99 ? '99+' : unreadCount}</Text></View>
          )}
        </TouchableOpacity>
        <TouchableOpacity style={styles.quickBtn} onPress={() => router.push('/(tabs)/feed')}>
          <Ionicons name="newspaper" size={28} color="#2563eb" />
          <Text style={styles.quickLabel}>Feed</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.quickBtn} onPress={() => router.push('/events/create')}>
          <Ionicons name="add-circle" size={28} color="#2563eb" />
          <Text style={styles.quickLabel}>Créer</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.quickBtn} onPress={() => router.push('/notifications')}>
          <Ionicons name="notifications" size={28} color="#2563eb" />
          <Text style={styles.quickLabel}>Notifs</Text>
          {unreadCount > 0 && (
            <View style={styles.badge}><Text style={styles.badgeText}>{unreadCount > 99 ? '99+' : unreadCount}</Text></View>
          )}
        </TouchableOpacity>
      </View>

      <Card>
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Mes événements à venir</Text>
          <TouchableOpacity onPress={() => router.push('/(tabs)/events')}>
            <Text style={styles.seeAll}>Voir tout</Text>
          </TouchableOpacity>
        </View>
        {events.length === 0 ? (
          <Text style={styles.empty}>Aucun événement à venir</Text>
        ) : (
          events.map((ev) => (
            <TouchableOpacity
              key={ev.id}
              style={styles.eventRow}
              onPress={() => router.push(`/events/${ev.id}`)}
            >
              <View style={styles.eventDateBox}>
                <Text style={styles.eventDateText}>{new Date(ev.start_date).getDate()}</Text>
                <Text style={styles.eventMonth}>{new Date(ev.start_date).toLocaleDateString('fr-FR', { month: 'short' })}</Text>
              </View>
              <View style={styles.eventInfo}>
                <Text style={styles.eventTitle} numberOfLines={1}>{ev.title}</Text>
                <Text style={styles.eventMeta}>{ev.location} · {formatDate(ev.start_date)}</Text>
              </View>
              <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
            </TouchableOpacity>
          ))
        )}
      </Card>

      <Card>
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Raccourcis</Text>
        </View>
        <TouchableOpacity style={styles.shortcutRow} onPress={() => router.push('/friends')}>
          <Ionicons name="people" size={22} color="#64748b" />
          <Text style={styles.shortcutText}>Amis</Text>
          <Ionicons name="chevron-forward" size={18} color="#94a3b8" />
        </TouchableOpacity>
        <TouchableOpacity style={styles.shortcutRow} onPress={() => router.push('/friend-requests')}>
          <Ionicons name="person-add" size={22} color="#64748b" />
          <Text style={styles.shortcutText}>Demandes d'amis</Text>
          <Ionicons name="chevron-forward" size={18} color="#94a3b8" />
        </TouchableOpacity>
        <TouchableOpacity style={styles.shortcutRow} onPress={() => router.push('/search')}>
          <Ionicons name="search" size={22} color="#64748b" />
          <Text style={styles.shortcutText}>Recherche</Text>
          <Ionicons name="chevron-forward" size={18} color="#94a3b8" />
        </TouchableOpacity>
        <TouchableOpacity style={styles.shortcutRow} onPress={() => router.push('/settings')}>
          <Ionicons name="settings" size={22} color="#64748b" />
          <Text style={styles.shortcutText}>Paramètres</Text>
          <Ionicons name="chevron-forward" size={18} color="#94a3b8" />
        </TouchableOpacity>
      </Card>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f1f5f9' },
  content: { padding: 16, paddingBottom: 32 },
  header: { marginBottom: 20 },
  greeting: { fontSize: 22, fontWeight: '700', color: '#0f172a' },
  role: { fontSize: 14, color: '#64748b', marginTop: 4 },
  quickActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  quickBtn: {
    alignItems: 'center',
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 12,
    flex: 1,
    marginHorizontal: 4,
    position: 'relative',
  },
  quickLabel: { fontSize: 12, color: '#64748b', marginTop: 6 },
  badge: {
    position: 'absolute',
    top: 8,
    right: 8,
    backgroundColor: '#ef4444',
    borderRadius: 10,
    minWidth: 18,
    height: 18,
    justifyContent: 'center',
    alignItems: 'center',
  },
  badgeText: { color: '#fff', fontSize: 10, fontWeight: '700' },
  sectionHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 },
  sectionTitle: { fontSize: 16, fontWeight: '600', color: '#0f172a' },
  seeAll: { fontSize: 14, color: '#2563eb' },
  empty: { color: '#94a3b8', fontSize: 14 },
  eventRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#f1f5f9',
  },
  eventDateBox: {
    width: 48,
    height: 48,
    backgroundColor: '#2563eb',
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  eventDateText: { color: '#fff', fontSize: 18, fontWeight: '700' },
  eventMonth: { color: '#fff', fontSize: 10 },
  eventInfo: { flex: 1 },
  eventTitle: { fontWeight: '600', color: '#0f172a' },
  eventMeta: { fontSize: 12, color: '#64748b', marginTop: 2 },
  shortcutRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#f1f5f9',
  },
  shortcutText: { flex: 1, marginLeft: 12, fontSize: 15, color: '#334155' },
});
