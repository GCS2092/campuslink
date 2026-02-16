import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, RefreshControl } from 'react-native';
import { useRouter, Stack } from 'expo-router';
import { getClassEvents } from '../../services/classLeaderService';

export default function ClassLeaderEventsScreen() {
  const router = useRouter();
  const [list, setList] = useState<unknown[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    const data = await getClassEvents();
    setList(Array.isArray(data) ? data : []);
  };

  useEffect(() => {
    load();
  }, []);

  const row = (x: unknown) => x as { id?: string; title?: string; start_date?: string; location?: string };
  return (
    <>
      <Stack.Screen options={{ title: 'Événements' }} />
      <FlatList
        data={list}
        keyExtractor={(x) => String(row(x).id ?? '')}
        contentContainerStyle={styles.list}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
        ListEmptyComponent={<Text style={styles.empty}>Aucun événement</Text>}
        renderItem={({ item: x }) => (
          <TouchableOpacity style={styles.card} onPress={() => router.push(`/events/${row(x).id}`)}>
            <Text style={styles.title}>{row(x).title}</Text>
            <Text style={styles.meta}>{row(x).location} · {row(x).start_date ? new Date(row(x).start_date!).toLocaleDateString('fr-FR') : ''}</Text>
          </TouchableOpacity>
        )}
      />
    </>
  );
}

const styles = StyleSheet.create({
  list: { padding: 16 },
  empty: { textAlign: 'center', color: '#94a3b8', marginTop: 32 },
  card: { backgroundColor: '#fff', padding: 16, borderRadius: 12, marginBottom: 8 },
  title: { fontWeight: '600' },
  meta: { fontSize: 14, color: '#64748b', marginTop: 4 },
});
