import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';
import Ionicons from '@expo/vector-icons/Ionicons';
import { useAuthStore } from '../../store/authStore';

export default function ProfileScreen() {
  const router = useRouter();
  const { user, logout } = useAuthStore();

  const displayName = user?.first_name && user?.last_name
    ? `${user.first_name} ${user.last_name}`
    : user?.username ?? '—';
  const email = user?.email ?? '—';

  const handleLogout = async () => {
    await logout();
    router.replace('/login');
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.avatar}>
        <Text style={styles.avatarText}>{(displayName[0] || '?').toUpperCase()}</Text>
      </View>
      <Text style={styles.name}>{displayName}</Text>
      <Text style={styles.email}>{email}</Text>
      {user?.profile?.campus ? (
        <Text style={styles.meta}>{user.profile.campus}</Text>
      ) : null}

      <TouchableOpacity style={styles.menuRow} onPress={() => router.push('/friends')}>
        <Ionicons name="people" size={22} color="#64748b" />
        <Text style={styles.menuText}>Amis</Text>
        <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
      </TouchableOpacity>
      <TouchableOpacity style={styles.menuRow} onPress={() => router.push('/friend-requests')}>
        <Ionicons name="person-add" size={22} color="#64748b" />
        <Text style={styles.menuText}>Demandes d'amis</Text>
        <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
      </TouchableOpacity>
      <TouchableOpacity style={styles.menuRow} onPress={() => router.push('/notifications')}>
        <Ionicons name="notifications" size={22} color="#64748b" />
        <Text style={styles.menuText}>Notifications</Text>
        <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
      </TouchableOpacity>
      <TouchableOpacity style={styles.menuRow} onPress={() => router.push('/settings')}>
        <Ionicons name="settings" size={22} color="#64748b" />
        <Text style={styles.menuText}>Paramètres</Text>
        <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
      </TouchableOpacity>

      <TouchableOpacity style={styles.logoutBtn} onPress={handleLogout}>
        <Ionicons name="log-out" size={22} color="#ef4444" />
        <Text style={styles.logoutText}>Déconnexion</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f1f5f9' },
  content: { padding: 24, alignItems: 'center' },
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
  email: { fontSize: 14, color: '#64748b', marginTop: 4 },
  meta: { fontSize: 14, color: '#94a3b8', marginTop: 2 },
  menuRow: {
    flexDirection: 'row',
    alignItems: 'center',
    width: '100%',
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 12,
    marginTop: 12,
  },
  menuText: { flex: 1, marginLeft: 12, fontSize: 16 },
  logoutBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 32,
    padding: 16,
  },
  logoutText: { marginLeft: 8, color: '#ef4444', fontWeight: '600' },
});
