import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, RefreshControl } from 'react-native';
import { Stack } from 'expo-router';
import { getFriendRequests, acceptFriendRequest, rejectFriendRequest } from '../services/userService';
import type { FriendRequest } from '../services/userService';

function displayName(req: FriendRequest) {
  const u = req.from_user;
  return [u.first_name, u.last_name].filter(Boolean).join(' ') || u.username;
}

export default function FriendRequestsScreen() {
  const [list, setList] = useState<FriendRequest[]>([]);
  const [refreshing, setRefreshing] = useState(false);
  const [loadingId, setLoadingId] = useState<string | null>(null);

  const load = async () => {
    const data = await getFriendRequests();
    setList(data);
  };

  useEffect(() => {
    load();
  }, []);

  const handleAccept = async (id: string) => {
    setLoadingId(id);
    await acceptFriendRequest(id);
    setList((prev) => prev.filter((r) => r.id !== id));
    setLoadingId(null);
  };

  const handleReject = async (id: string) => {
    setLoadingId(id);
    await rejectFriendRequest(id);
    setList((prev) => prev.filter((r) => r.id !== id));
    setLoadingId(null);
  };

  return (
    <>
      <Stack.Screen options={{ title: 'Demandes d\'amis', headerBackTitle: 'Retour' }} />
      <FlatList
        data={list}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
        ListEmptyComponent={<Text style={styles.empty}>Aucune demande</Text>}
        renderItem={({ item }) => (
          <View style={styles.row}>
            <View style={styles.avatar}>
              <Text style={styles.avatarText}>{(displayName(item)[0] || '?').toUpperCase()}</Text>
            </View>
            <View style={styles.body}>
              <Text style={styles.name}>{displayName(item)}</Text>
              <Text style={styles.username}>@{item.from_user.username}</Text>
            </View>
            <TouchableOpacity
              style={styles.acceptBtn}
              onPress={() => handleAccept(item.id)}
              disabled={loadingId === item.id}
            >
              <Text style={styles.acceptBtnText}>Accepter</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={styles.rejectBtn}
              onPress={() => handleReject(item.id)}
              disabled={loadingId === item.id}
            >
              <Text style={styles.rejectBtnText}>Refuser</Text>
            </TouchableOpacity>
          </View>
        )}
      />
    </>
  );
}

const styles = StyleSheet.create({
  list: { padding: 16 },
  empty: { textAlign: 'center', color: '#94a3b8', marginTop: 32 },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    padding: 12,
    borderRadius: 12,
    marginBottom: 8,
  },
  avatar: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: '#2563eb',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  avatarText: { color: '#fff', fontWeight: '600' },
  body: { flex: 1 },
  name: { fontWeight: '600' },
  username: { fontSize: 12, color: '#94a3b8' },
  acceptBtn: { backgroundColor: '#2563eb', paddingHorizontal: 12, paddingVertical: 8, borderRadius: 8, marginLeft: 8 },
  acceptBtnText: { color: '#fff', fontWeight: '600' },
  rejectBtn: { paddingHorizontal: 12, paddingVertical: 8, marginLeft: 4 },
  rejectBtnText: { color: '#64748b' },
});
