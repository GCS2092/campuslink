import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, RefreshControl } from 'react-native';
import { useRouter, Stack } from 'expo-router';
import { getClassGroups } from '../../services/classLeaderService';

export default function ClassLeaderGroupsScreen() {
  const router = useRouter();
  const [list, setList] = useState<unknown[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    const data = await getClassGroups();
    setList(Array.isArray(data) ? data : []);
  };

  useEffect(() => {
    load();
  }, []);

  const row = (x: unknown) => x as { id?: string; name?: string; members_count?: number };
  return (
    <>
      <Stack.Screen options={{ title: 'Groupes' }} />
      <FlatList
        data={list}
        keyExtractor={(x) => String(row(x).id ?? '')}
        contentContainerStyle={styles.list}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
        ListEmptyComponent={<Text style={styles.empty}>Aucun groupe</Text>}
        renderItem={({ item: x }) => (
          <TouchableOpacity style={styles.card} onPress={() => router.push(`/groups/${row(x).id}`)}>
            <Text style={styles.title}>{row(x).name}</Text>
            <Text style={styles.meta}>{row(x).members_count ?? 0} membre(s)</Text>
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
