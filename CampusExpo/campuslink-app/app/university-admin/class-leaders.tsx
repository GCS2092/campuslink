import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, RefreshControl, Alert } from 'react-native';
import { Stack } from 'expo-router';
import { getClassLeaders, assignClassLeader, revokeClassLeader } from '../../services/universityAdminService';

export default function UniversityAdminClassLeadersScreen() {
  const [list, setList] = useState<unknown[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    const data = await getClassLeaders();
    setList(Array.isArray(data) ? data : []);
  };

  useEffect(() => {
    load();
  }, []);

  const row = (x: unknown) => x as { id?: string; email?: string; username?: string; first_name?: string; last_name?: string; role?: string };
  const name = (x: unknown) => [row(x).first_name, row(x).last_name].filter(Boolean).join(' ') || row(x).username || '—';
  const isCL = (x: unknown) => row(x).role === 'class_leader';

  const handleAssign = async (id: string) => {
    const res = await assignClassLeader(id);
    if (res.success) load();
    else Alert.alert('Erreur', res.error);
  };

  const handleRevoke = async (id: string) => {
    Alert.alert('Confirmer', 'Retirer le rôle responsable de classe ?', [
      { text: 'Annuler', style: 'cancel' },
      { text: 'Retirer', style: 'destructive', onPress: async () => {
        const res = await revokeClassLeader(id);
        if (res.success) load();
        else Alert.alert('Erreur', res.error);
      }},
    ]);
  };

  return (
    <>
      <Stack.Screen options={{ title: 'Responsables de classe' }} />
      <FlatList
        data={list}
        keyExtractor={(x) => String(row(x).id ?? '')}
        contentContainerStyle={styles.list}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
        ListEmptyComponent={<Text style={styles.empty}>Aucun résultat</Text>}
        renderItem={({ item: x }) => {
          const id = row(x).id;
          if (!id) return null;
          const cl = isCL(x);
          return (
            <View style={styles.card}>
              <Text style={styles.name}>{name(x)}</Text>
              <Text style={styles.email}>{row(x).email}</Text>
              <Text style={styles.role}>{cl ? 'Responsable de classe' : 'Étudiant'}</Text>
              <View style={styles.actions}>
                {cl ? (
                  <TouchableOpacity style={styles.btnRevoke} onPress={() => handleRevoke(id)}>
                    <Text style={styles.btnRevokeText}>Retirer le rôle</Text>
                  </TouchableOpacity>
                ) : (
                  <TouchableOpacity style={styles.btnAssign} onPress={() => handleAssign(id)}>
                    <Text style={styles.btnAssignText}>Assigner responsable</Text>
                  </TouchableOpacity>
                )}
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
  card: { backgroundColor: '#fff', padding: 16, borderRadius: 12, marginBottom: 8 },
  name: { fontWeight: '600' },
  email: { fontSize: 14, color: '#64748b', marginTop: 4 },
  role: { fontSize: 12, color: '#94a3b8', marginTop: 4 },
  actions: { marginTop: 12 },
  btnAssign: { backgroundColor: '#2563eb', paddingVertical: 8, paddingHorizontal: 16, borderRadius: 8, alignSelf: 'flex-start' },
  btnAssignText: { color: '#fff', fontWeight: '600' },
  btnRevoke: { paddingVertical: 8 },
  btnRevokeText: { color: '#dc2626' },
});
