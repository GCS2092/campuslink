import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, TextInput, TouchableOpacity, RefreshControl } from 'react-native';
import { useRouter, Stack } from 'expo-router';
import { getClassStudents } from '../../services/classLeaderService';

export default function ClassLeaderStudentsScreen() {
  const router = useRouter();
  const [list, setList] = useState<unknown[]>([]);
  const [search, setSearch] = useState('');
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    const data = await getClassStudents({ search: search || undefined });
    setList(Array.isArray(data) ? data : []);
  };

  useEffect(() => {
    load();
  }, [search]);

  const row = (x: unknown) => x as { id?: string; username?: string; first_name?: string; last_name?: string; email?: string };
  const name = (x: unknown) => [row(x).first_name, row(x).last_name].filter(Boolean).join(' ') || row(x).username || '—';
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
          keyExtractor={(x) => String(row(x).id ?? '')}
          contentContainerStyle={styles.list}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
          ListEmptyComponent={<Text style={styles.empty}>Aucun résultat</Text>}
          renderItem={({ item: x }) => (
            <TouchableOpacity style={styles.card} onPress={() => router.push(`/user/${row(x).id}`)}>
              <Text style={styles.name}>{name(x)}</Text>
              <Text style={styles.email}>{row(x).email}</Text>
            </TouchableOpacity>
          )}
        />
      </View>
    </>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },
  search: { backgroundColor: '#fff', margin: 16, padding: 12, borderRadius: 8, borderWidth: 1, borderColor: '#e2e8f0' },
  list: { padding: 16, paddingTop: 0 },
  empty: { textAlign: 'center', color: '#94a3b8', marginTop: 32 },
  card: { backgroundColor: '#fff', padding: 16, borderRadius: 12, marginBottom: 8 },
  name: { fontWeight: '600' },
  email: { fontSize: 14, color: '#64748b', marginTop: 4 },
});
