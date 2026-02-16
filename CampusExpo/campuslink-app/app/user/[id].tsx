import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useLocalSearchParams, useRouter, Stack } from 'expo-router';
import Ionicons from '@expo/vector-icons/Ionicons';
import { getUser, sendFriendRequest } from '../../services/userService';
import { useAuthStore } from '../../store/authStore';
import type { User } from '../../types';

function displayName(u: User) {
  return [u.first_name, u.last_name].filter(Boolean).join(' ') || u.username;
}

export default function UserProfileScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const { user: me } = useAuthStore();
  const [user, setUser] = useState<User | null>(null);
  const [requestSent, setRequestSent] = useState(false);

  const load = async () => {
    if (!id) return;
    const u = await getUser(id);
    setUser(u ?? null);
  };

  useEffect(() => {
    load();
  }, [id]);

  const handleMessage = () => {
    router.push({ pathname: '/chat/[id]', params: { id: id! } });
  };

  const handleAddFriend = async () => {
    if (!user) return;
    await sendFriendRequest(user.id);
    setRequestSent(true);
  };

  if (!user) {
    return (
      <>
        <Stack.Screen options={{ title: 'Profil', headerBackTitle: 'Retour' }} />
        <View style={styles.centered}><Text>Chargement...</Text></View>
      </>
    );
  }

  const isMe = me?.id === user.id;

  return (
    <>
      <Stack.Screen options={{ title: displayName(user), headerBackTitle: 'Retour' }} />
      <ScrollView style={styles.container} contentContainerStyle={styles.content}>
        <View style={styles.avatar}>
          <Text style={styles.avatarText}>{(displayName(user)[0] || '?').toUpperCase()}</Text>
        </View>
        <Text style={styles.name}>{displayName(user)}</Text>
        <Text style={styles.username}>@{user.username}</Text>
        {user.profile?.bio ? <Text style={styles.bio}>{user.profile.bio}</Text> : null}
        {user.profile?.campus ? <Text style={styles.meta}>{user.profile.campus}</Text> : null}
        {!isMe && (
          <View style={styles.actions}>
            <TouchableOpacity style={styles.msgBtn} onPress={handleMessage}>
              <Ionicons name="chatbubble" size={20} color="#fff" />
              <Text style={styles.msgBtnText}>Message</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.addBtn, requestSent && styles.addBtnDisabled]}
              onPress={handleAddFriend}
              disabled={requestSent}
            >
              <Ionicons name="person-add" size={20} color="#2563eb" />
              <Text style={styles.addBtnText}>{requestSent ? 'Demande envoyée' : 'Ajouter en ami'}</Text>
            </TouchableOpacity>
          </View>
        )}
      </ScrollView>
    </>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },
  content: { padding: 24, alignItems: 'center' },
  centered: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  avatar: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: '#2563eb',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  avatarText: { color: '#fff', fontSize: 28, fontWeight: '700' },
  name: { fontSize: 22, fontWeight: '700' },
  username: { fontSize: 14, color: '#64748b', marginTop: 4 },
  bio: { marginTop: 12, textAlign: 'center', color: '#475569' },
  meta: { marginTop: 4, fontSize: 14, color: '#94a3b8' },
  actions: { flexDirection: 'row', marginTop: 24, gap: 12 },
  msgBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#2563eb',
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 8,
  },
  msgBtnText: { color: '#fff', marginLeft: 6, fontWeight: '600' },
  addBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#2563eb',
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 8,
  },
  addBtnDisabled: { opacity: 0.6 },
  addBtnText: { color: '#2563eb', marginLeft: 6, fontWeight: '600' },
});
