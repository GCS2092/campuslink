import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, RefreshControl } from 'react-native';
import { useRouter, Stack } from 'expo-router';
import { getFriends } from '../services/userService';
import { startConversation } from '../services/messagingService';
import type { User } from '../types';

function displayName(u: User) {
  return [u.first_name, u.last_name].filter(Boolean).join(' ') || u.username;
}

export default function FriendsScreen() {
  const router = useRouter();
  const [list, setList] = useState<User[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    const data = await getFriends();
    setList(data);
  };

  useEffect(() => {
    load();
  }, []);

  return (
    <>
      <Stack.Screen options={{ title: 'Amis', headerBackTitle: 'Retour' }} />
      <FlatList
        data={list}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
        ListEmptyComponent={<Text style={styles.empty}>Aucun ami</Text>}
        renderItem={({ item }) => (
          <TouchableOpacity
            style={styles.row}
            onPress={() => router.push(`/user/${item.id}`)}
          >
            <View style={styles.avatar}>
              <Text style={styles.avatarText}>{(displayName(item)[0] || '?').toUpperCase()}</Text>
            </View>
            <View style={styles.body}>
              <Text style={styles.name}>{displayName(item)}</Text>
              <Text style={styles.username}>@{item.username}</Text>
            </View>
            <Text
              style={styles.chatBtn}
              onPress={async () => {
                const conv = await startConversation(item.id);
                if (conv) router.push({ pathname: '/chat/[id]', params: { id: conv.id } });
              }}
            >
              Message
            </Text>
          </TouchableOpacity>
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
  chatBtn: { color: '#2563eb', fontWeight: '600' },
});
