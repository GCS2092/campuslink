import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, RefreshControl } from 'react-native';
import { Stack } from 'expo-router';
import { getNotifications, markAsRead, markAllAsRead } from '../services/notificationService';
import type { NotificationItem as Notif } from '../types';

export default function NotificationsScreen() {
  const [list, setList] = useState<Notif[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    const data = await getNotifications();
    setList(data);
  };

  useEffect(() => {
    load();
  }, []);

  const handleMarkAll = async () => {
    await markAllAsRead();
    setList((prev) => prev.map((n) => ({ ...n, read: true })));
  };

  return (
    <>
      <Stack.Screen
        options={{
          title: 'Notifications',
          headerBackTitle: 'Retour',
          headerRight: () => (
            <TouchableOpacity onPress={handleMarkAll}>
              <Text style={{ color: '#2563eb', fontSize: 15 }}>Tout lire</Text>
            </TouchableOpacity>
          ),
        }}
      />
      <FlatList
        data={list}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
        ListEmptyComponent={<Text style={styles.empty}>Aucune notification</Text>}
        renderItem={({ item }) => (
          <TouchableOpacity
            style={[styles.row, !item.read && styles.rowUnread]}
            onPress={async () => {
              await markAsRead(item.id);
              setList((prev) => prev.map((n) => (n.id === item.id ? { ...n, read: true } : n)));
            }}
          >
            <View style={styles.body}>
              <Text style={styles.title}>{item.title}</Text>
              <Text style={styles.bodyText}>{item.body}</Text>
              <Text style={styles.time}>{new Date(item.created_at).toLocaleDateString('fr-FR')}</Text>
            </View>
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
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 12,
    marginBottom: 8,
  },
  rowUnread: { backgroundColor: '#eff6ff' },
  body: {},
  title: { fontWeight: '600', fontSize: 15 },
  bodyText: { color: '#64748b', marginTop: 4 },
  time: { fontSize: 12, color: '#94a3b8', marginTop: 6 },
});
