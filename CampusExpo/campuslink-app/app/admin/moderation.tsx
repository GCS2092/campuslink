import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, RefreshControl, Alert } from 'react-native';
import { Stack } from 'expo-router';
import { getModerationReports, resolveReport, rejectReport } from '../../services/adminService';

export default function AdminModerationScreen() {
  const [list, setList] = useState<unknown[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    const data = await getModerationReports();
    setList(Array.isArray(data) ? data : []);
  };

  useEffect(() => {
    load();
  }, []);

  const row = (x: unknown) => x as { id?: string; report_type?: string; status?: string; created_at?: string; description?: string };
  return (
    <>
      <Stack.Screen options={{ title: 'Modération' }} />
      <FlatList
        data={list}
        keyExtractor={(x) => String(row(x).id ?? '')}
        contentContainerStyle={styles.list}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
        ListEmptyComponent={<Text style={styles.empty}>Aucun signalement</Text>}
        renderItem={({ item: x }) => {
          const id = row(x).id;
          if (!id) return null;
          return (
            <View style={styles.card}>
              <Text style={styles.type}>{row(x).report_type ?? 'Signalement'}</Text>
              <Text style={styles.desc} numberOfLines={2}>{row(x).description ?? '—'}</Text>
              <Text style={styles.date}>{row(x).created_at ? new Date(row(x).created_at!).toLocaleDateString('fr-FR') : ''}</Text>
              <View style={styles.actions}>
                <TouchableOpacity
                  style={styles.btnReject}
                  onPress={async () => {
                    await rejectReport(id);
                    load();
                  }}
                >
                  <Text style={styles.btnRejectText}>Rejeter</Text>
                </TouchableOpacity>
                <TouchableOpacity
                  style={styles.btnResolve}
                  onPress={async () => {
                    await resolveReport(id);
                    load();
                  }}
                >
                  <Text style={styles.btnResolveText}>Résoudre</Text>
                </TouchableOpacity>
              </View>
            </View>
          );
        }}
      />
    </>
  );
}

const styles = StyleSheet.create({
  list: { padding: 16 },
  empty: { textAlign: 'center', color: '#94a3b8', marginTop: 32 },
  card: {
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 12,
    marginBottom: 8,
  },
  type: { fontWeight: '600' },
  desc: { fontSize: 14, color: '#64748b', marginTop: 4 },
  date: { fontSize: 12, color: '#94a3b8', marginTop: 4 },
  actions: { flexDirection: 'row', marginTop: 12, gap: 8 },
  btnReject: { paddingVertical: 8, paddingHorizontal: 16 },
  btnRejectText: { color: '#dc2626' },
  btnResolve: { backgroundColor: '#2563eb', paddingVertical: 8, paddingHorizontal: 16, borderRadius: 8 },
  btnResolveText: { color: '#fff', fontWeight: '600' },
});
