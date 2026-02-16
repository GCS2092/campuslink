import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useLocalSearchParams, useRouter, Stack } from 'expo-router';
import Ionicons from '@expo/vector-icons/Ionicons';
import { getGroup, getGroupMembers, joinGroup, leaveGroup } from '../../services/groupService';
import type { Group, User } from '../../types';

export default function GroupDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const [group, setGroup] = useState<Group | null>(null);
  const [members, setMembers] = useState<User[]>([]);
  const [joined, setJoined] = useState(false);
  const [loading, setLoading] = useState(false);

  const load = async () => {
    if (!id) return;
    const [g, m] = await Promise.all([getGroup(id), getGroupMembers(id)]);
    setGroup(g ?? null);
    setMembers(m);
    setJoined(!!g); // mock: consider joined if we have the group
  };

  useEffect(() => {
    load();
  }, [id]);

  const toggleJoin = async () => {
    if (!group || loading) return;
    setLoading(true);
    if (joined) {
      await leaveGroup(group.id);
      setJoined(false);
      setGroup((prev) => prev ? { ...prev, members_count: prev.members_count - 1 } : null);
    } else {
      await joinGroup(group.id);
      setJoined(true);
      setGroup((prev) => prev ? { ...prev, members_count: prev.members_count + 1 } : null);
    }
    setLoading(false);
  };

  if (!group) {
    return (
      <>
        <Stack.Screen options={{ title: 'Groupe', headerBackTitle: 'Retour' }} />
        <View style={styles.centered}><Text>Chargement...</Text></View>
      </>
    );
  }

  const displayName = (u: User) => [u.first_name, u.last_name].filter(Boolean).join(' ') || u.username;

  return (
    <>
      <Stack.Screen options={{ title: group.name, headerBackTitle: 'Retour' }} />
      <ScrollView style={styles.container} contentContainerStyle={styles.content}>
        <View style={styles.header}>
          <View style={styles.iconWrap}>
            <Ionicons name="people" size={48} color="#2563eb" />
          </View>
          <Text style={styles.title}>{group.name}</Text>
          <Text style={styles.desc}>{group.description}</Text>
          <Text style={styles.meta}>{group.members_count} membre(s)</Text>
        </View>
        <TouchableOpacity
          style={[styles.btn, joined ? styles.btnLeave : styles.btnJoin]}
          onPress={toggleJoin}
          disabled={loading}
        >
          <Text style={styles.btnText}>{joined ? 'Quitter le groupe' : 'Rejoindre'}</Text>
        </TouchableOpacity>
        <Text style={styles.sectionTitle}>Membres</Text>
        {members.map((u) => (
          <TouchableOpacity
            key={u.id}
            style={styles.memberRow}
            onPress={() => router.push(`/user/${u.id}`)}
          >
            <View style={styles.avatar}>
              <Text style={styles.avatarText}>{(displayName(u)[0] || '?').toUpperCase()}</Text>
            </View>
            <Text style={styles.memberName}>{displayName(u)}</Text>
            <Ionicons name="chevron-forward" size={18} color="#94a3b8" />
          </TouchableOpacity>
        ))}
      </ScrollView>
    </>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },
  content: { padding: 16 },
  centered: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  header: { alignItems: 'center', marginBottom: 24 },
  iconWrap: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: '#eff6ff',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  title: { fontSize: 22, fontWeight: '700' },
  desc: { textAlign: 'center', color: '#64748b', marginTop: 8 },
  meta: { fontSize: 14, color: '#94a3b8', marginTop: 4 },
  btn: { padding: 16, borderRadius: 8, alignItems: 'center' },
  btnJoin: { backgroundColor: '#2563eb' },
  btnLeave: { backgroundColor: '#94a3b8' },
  btnText: { color: '#fff', fontWeight: '600' },
  sectionTitle: { fontWeight: '600', marginTop: 24, marginBottom: 12 },
  memberRow: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    padding: 12,
    borderRadius: 8,
    marginBottom: 8,
  },
  avatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#2563eb',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  avatarText: { color: '#fff', fontWeight: '600' },
  memberName: { flex: 1 },
});
