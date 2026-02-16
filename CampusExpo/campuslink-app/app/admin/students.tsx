import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, TextInput, RefreshControl } from 'react-native';
import { Stack } from 'expo-router';
import { getPendingStudents } from '../../services/adminService';

export default function AdminStudentsScreen() {
  const [list, setList] = useState<unknown[]>([]);
  const [search, setSearch] = useState('');
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    const data = await getPendingStudents({ search: search || undefined });
    setList(Array.isArray(data) ? data : []);
  };

  useEffect(() => {
    load();
  }, [search]);

  const item = (row: unknown) => row as { id?: string; email?: string; username?: string; first_name?: string; last_name?: string };
  const name = (row: unknown) => {
    const r = item(row);
    return [r.first_name, r.last_name].filter(Boolean).join(' ') || r.username || r.email || '—';
  };

  return (
    <>
      <Stack.Screen options={{ title: 'Étudiants' }} />
      <View style={styles.container}>
        <TextInput
          style={styles.search}
          placeholder="Rechercher..."
          value={search}
          onChangeText={setSearch}
        />
        <FlatList
          data={list}
          keyExtractor={(x) => String(item(x).id ?? '')}
          contentContainerStyle={styles.list}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
          ListEmptyComponent={<Text style={styles.empty}>Aucun résultat</Text>}
          renderItem={({ item: row }) => (
            <View style={styles.card}>
              <Text style={styles.name}>{name(row)}</Text>
              <Text style={styles.email}>{item(row).email}</Text>
            </View>
          )}
        />
      </View>
    </>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },
  search: {
    backgroundColor: '#fff',
    margin: 16,
    padding: 12,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#e2e8f0',
  },
  list: { padding: 16, paddingTop: 0 },
  empty: { textAlign: 'center', color: '#94a3b8', marginTop: 32 },
  card: {
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 12,
    marginBottom: 8,
  },
  name: { fontWeight: '600' },
  email: { fontSize: 14, color: '#64748b', marginTop: 4 },
});
