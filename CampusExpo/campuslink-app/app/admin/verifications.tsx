import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, RefreshControl, Alert } from 'react-native';
import { Stack } from 'expo-router';
import { getPendingVerifications, verifyUser, rejectUser } from '../../services/adminService';

export default function AdminVerificationsScreen() {
  const [list, setList] = useState<unknown[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    const data = await getPendingVerifications();
    setList(Array.isArray(data) ? data : []);
  };

  useEffect(() => {
    load();
  }, []);

  const item = (row: unknown) => row as { id?: string; email?: string; username?: string; first_name?: string; last_name?: string };
  const name = (row: unknown) => {
    const r = item(row);
    return [r.first_name, r.last_name].filter(Boolean).join(' ') || r.username || r.email || '—';
  };

  const handleVerify = async (id: string) => {
    const res = await verifyUser(id);
    if (res.success) {
      setList((prev) => prev.filter((x) => (x as { id?: string }).id !== id));
    } else Alert.alert('Erreur', res.error);
  };

  const handleReject = async (id: string) => {
    Alert.alert('Confirmer', 'Rejeter cette demande ?', [
      { text: 'Annuler', style: 'cancel' },
      {
        text: 'Rejeter',
        style: 'destructive',
        onPress: async () => {
          const res = await rejectUser(id);
          if (res.success) setList((prev) => prev.filter((x) => (x as { id?: string }).id !== id));
          else Alert.alert('Erreur', res.error);
        },
      },
    ]);
  };

  return (
    <>
      <Stack.Screen options={{ title: 'Vérifications' }} />
      <FlatList
        data={list}
        keyExtractor={(x) => String((x as { id?: string }).id ?? '')}
        contentContainerStyle={styles.list}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
        ListEmptyComponent={<Text style={styles.empty}>Aucune demande en attente</Text>}
        renderItem={({ item: row }) => {
          const id = (row as { id?: string }).id;
          if (!id) return null;
          return (
            <View style={styles.card}>
              <Text style={styles.name}>{name(row)}</Text>
              <Text style={styles.email}>{(row as { email?: string }).email}</Text>
              <View style={styles.actions}>
                <TouchableOpacity style={styles.btnReject} onPress={() => handleReject(id)}>
                  <Text style={styles.btnRejectText}>Rejeter</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.btnVerify} onPress={() => handleVerify(id)}>
                  <Text style={styles.btnVerifyText}>Vérifier</Text>
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
  name: { fontWeight: '600', fontSize: 16 },
  email: { fontSize: 14, color: '#64748b', marginTop: 4 },
  actions: { flexDirection: 'row', marginTop: 12, gap: 8 },
  btnReject: { paddingHorizontal: 16, paddingVertical: 8 },
  btnRejectText: { color: '#dc2626' },
  btnVerify: { backgroundColor: '#2563eb', paddingHorizontal: 16, paddingVertical: 8, borderRadius: 8 },
  btnVerifyText: { color: '#fff', fontWeight: '600' },
});
