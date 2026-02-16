import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, RefreshControl } from 'react-native';
import { useRouter, Stack } from 'expo-router';
import Ionicons from '@expo/vector-icons/Ionicons';
import { getConversations } from '../services/messagingService';
import type { Conversation } from '../types';

export default function ConversationsScreen() {
  const router = useRouter();
  const [list, setList] = useState<Conversation[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    const data = await getConversations();
    setList(data);
  };

  useEffect(() => {
    load();
  }, []);

  const otherParticipant = (c: Conversation) => c.participants?.find((p) => p.id !== c.participants?.[0]?.id) ?? c.participants?.[0];
  const displayName = (c: Conversation) => {
    const u = otherParticipant(c);
    return u ? `${u.first_name ?? ''} ${u.last_name ?? ''}`.trim() || u.username : 'Conversation';
  };

  return (
    <>
      <Stack.Screen options={{ title: 'Messages', headerBackTitle: 'Retour' }} />
      <FlatList
        data={list}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
        ListEmptyComponent={<Text style={styles.empty}>Aucune conversation</Text>}
        renderItem={({ item }) => (
          <TouchableOpacity
            style={styles.row}
            onPress={() => router.push({ pathname: '/chat/[id]', params: { id: item.id } })}
          >
            <View style={styles.avatar}>
              <Text style={styles.avatarText}>{(displayName(item)[0] || '?').toUpperCase()}</Text>
            </View>
            <View style={styles.body}>
              <Text style={styles.name}>{displayName(item)}</Text>
              <Text style={styles.preview} numberOfLines={1}>{item.last_message?.content ?? '—'}</Text>
            </View>
            {(item.unread_count ?? 0) > 0 && (
              <View style={styles.unread}><Text style={styles.unreadText}>{item.unread_count}</Text></View>
            )}
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
  avatarText: { color: '#fff', fontSize: 18, fontWeight: '600' },
  body: { flex: 1 },
  name: { fontWeight: '600', fontSize: 16 },
  preview: { fontSize: 14, color: '#64748b', marginTop: 2 },
  unread: {
    backgroundColor: '#2563eb',
    borderRadius: 12,
    minWidth: 24,
    height: 24,
    justifyContent: 'center',
    alignItems: 'center',
  },
  unreadText: { color: '#fff', fontSize: 12, fontWeight: '600' },
});
