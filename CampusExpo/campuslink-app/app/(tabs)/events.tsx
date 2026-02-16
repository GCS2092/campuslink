import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, RefreshControl } from 'react-native';
import { useRouter } from 'expo-router';
import Ionicons from '@expo/vector-icons/Ionicons';
import { getEvents } from '../../services/eventService';
import type { Event } from '../../types';

function formatDate(iso: string) {
  const d = new Date(iso);
  return d.toLocaleDateString('fr-FR', { weekday: 'short', day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
}

export default function EventsScreen() {
  const router = useRouter();
  const [events, setEvents] = useState<Event[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    const data = await getEvents();
    setEvents(data);
  };

  useEffect(() => {
    load();
  }, []);

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.addBtn} onPress={() => router.push('/events/create')}>
          <Ionicons name="add" size={24} color="#fff" />
          <Text style={styles.addBtnText}>Créer</Text>
        </TouchableOpacity>
      </View>
      <FlatList
        data={events}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
        ListEmptyComponent={<Text style={styles.empty}>Aucun événement</Text>}
        renderItem={({ item }) => (
          <TouchableOpacity
            style={styles.card}
            onPress={() => router.push(`/events/${item.id}`)}
          >
            <View style={styles.dateBox}>
              <Text style={styles.dateDay}>{new Date(item.start_date).getDate()}</Text>
              <Text style={styles.dateMonth}>{new Date(item.start_date).toLocaleDateString('fr-FR', { month: 'short' })}</Text>
            </View>
            <View style={styles.cardBody}>
              <Text style={styles.cardTitle} numberOfLines={1}>{item.title}</Text>
              <Text style={styles.cardMeta}>{item.location}</Text>
              <Text style={styles.cardMeta}>{formatDate(item.start_date)}</Text>
              <View style={styles.badges}>
                <Text style={styles.badge}>{item.participants_count} participants</Text>
                {item.is_participating && <Text style={styles.badgeJoin}>Inscrit</Text>}
              </View>
            </View>
            <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
          </TouchableOpacity>
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f1f5f9' },
  header: { padding: 16, paddingBottom: 0 },
  addBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    alignSelf: 'flex-end',
    backgroundColor: '#2563eb',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 8,
  },
  addBtnText: { color: '#fff', marginLeft: 6, fontWeight: '600' },
  list: { padding: 16 },
  empty: { textAlign: 'center', color: '#94a3b8', marginTop: 32 },
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    padding: 12,
    borderRadius: 12,
    marginBottom: 8,
  },
  dateBox: {
    width: 56,
    height: 56,
    backgroundColor: '#2563eb',
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  dateDay: { color: '#fff', fontSize: 20, fontWeight: '700' },
  dateMonth: { color: '#fff', fontSize: 11 },
  cardBody: { flex: 1 },
  cardTitle: { fontWeight: '600', fontSize: 16 },
  cardMeta: { fontSize: 12, color: '#64748b', marginTop: 2 },
  badges: { flexDirection: 'row', marginTop: 6, gap: 8 },
  badge: { fontSize: 11, color: '#64748b' },
  badgeJoin: { fontSize: 11, color: '#2563eb', fontWeight: '600' },
});
