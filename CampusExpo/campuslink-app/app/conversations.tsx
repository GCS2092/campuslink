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

  const safeConversation = (c: unknown): Conversation | null => {
    if (!c || typeof c !== 'object') return null;
    const id = (c as { id?: unknown }).id;
    if (id == null) return null;
    return c as Conversation;
  };

  const load = async () => {
    const data = await getConversations();
    const safeArray = Array.isArray(data) ? data : [];
    const normalized = safeArray
      .map((c) => safeConversation(c))
      .filter((c): c is Conversation => !!c);
    setList(normalized);
  };

  useEffect(() => {
    load();
  }, []);

  const otherParticipant = (c: Conversation) => {
    const ps = Array.isArray(c.participants) ? c.participants.filter(Boolean) : [];
    const firstId = ps[0]?.id;
    return ps.find((p) => p?.id != null && p.id !== firstId) ?? ps[0];
  };

  const displayName = (c: Conversation) => {
    const u = otherParticipant(c);
    return u ? `${u.first_name ?? ''} ${u.last_name ?? ''}`.trim() || u.username : 'Conversation';
  };

  return (
    <>
      <Stack.Screen options={{ title: 'Messages', headerBackTitle: 'Retour' }} />
      <FlatList
        data={list}
        keyExtractor={(item, index) => {
          const id = (item as unknown as { id?: unknown })?.id;
          if (typeof id === 'string' && id) return id;
          if (typeof id === 'number') return String(id);
          return String(index);
        }}
        contentContainerStyle={styles.list}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
        ListEmptyComponent={<Text style={styles.empty}>Aucune conversation</Text>}
        renderItem={({ item }) => {
          const conv = safeConversation(item);
          if (!conv) return null;
          const id = (conv as unknown as { id?: unknown })?.id;
          const name = displayName(conv);
          return (
            <TouchableOpacity
              style={styles.row}
              onPress={() => {
                if (typeof id !== 'string' && typeof id !== 'number') return;
                router.push({ pathname: '/chat/[id]', params: { id: String(id) } });
              }}
            >
              <View style={styles.avatar}>
                <Text style={styles.avatarText}>{(name[0] || '?').toUpperCase()}</Text>
              </View>
              <View style={styles.body}>
                <Text style={styles.name}>{name}</Text>
                <Text style={styles.preview} numberOfLines={1}>{conv.last_message?.content ?? '—'}</Text>
              </View>
              {(conv.unread_count ?? 0) > 0 && (
                <View style={styles.unread}><Text style={styles.unreadText}>{conv.unread_count}</Text></View>
              )}
            </TouchableOpacity>
          );
        }}
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
