import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, RefreshControl } from 'react-native';
import { Stack } from 'expo-router';
import { getDepartments } from '../../services/universityAdminService';

export default function UniversityAdminDepartmentsScreen() {
  const [list, setList] = useState<unknown[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    const data = await getDepartments();
    setList(Array.isArray(data) ? data : []);
  };

  useEffect(() => {
    load();
  }, []);

  const row = (x: unknown) => x as { id?: string; name?: string };
  return (
    <>
      <Stack.Screen options={{ title: 'Départements' }} />
      <FlatList
        data={list}
        keyExtractor={(x) => String(row(x).id ?? '')}
        contentContainerStyle={styles.list}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
        ListEmptyComponent={<Text style={styles.empty}>Aucun département</Text>}
        renderItem={({ item: x }) => (
          <View style={styles.card}>
            <Text style={styles.name}>{row(x).name ?? '—'}</Text>
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
});
