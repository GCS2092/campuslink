import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, RefreshControl } from 'react-native';
import { useRouter, Stack } from 'expo-router';
import { getActiveStudents } from '../../services/universityAdminService';

export default function UniversityAdminStudentsScreen() {
  const router = useRouter();
  const [list, setList] = useState<unknown[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    const data = await getActiveStudents();
    setList(Array.isArray(data) ? data : []);
  };

  useEffect(() => {
    load();
  }, []);

  const row = (x: unknown) => x as { id?: string; email?: string; username?: string; first_name?: string; last_name?: string };
  const name = (x: unknown) => [row(x).first_name, row(x).last_name].filter(Boolean).join(' ') || row(x).username || '—';

  return (
    <>
      <Stack.Screen options={{ title: 'Étudiants' }} />
      <FlatList
        data={list}
        keyExtractor={(x) => String(row(x).id ?? '')}
        contentContainerStyle={styles.list}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
        ListEmptyComponent={<Text style={styles.empty}>Aucun étudiant</Text>}
        renderItem={({ item: x }) => (
          <View style={styles.card}>
            <Text style={styles.name}>{name(x)}</Text>
            <Text style={styles.email}>{row(x).email}</Text>
          </View>
        )}
      />
    </>
  );
}

const styles = StyleSheet.create({
  list: { padding: 16 },
  empty: { textAlign: 'center', color: '#94a3b8', marginTop: 32 },
  card: { backgroundColor: '#fff', padding: 16, borderRadius: 12, marginBottom: 8 },
  name: { fontWeight: '600' },
  email: { fontSize: 14, color: '#64748b', marginTop: 4 },
});
