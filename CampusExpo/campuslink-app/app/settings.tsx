import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Stack, useRouter } from 'expo-router';
import Ionicons from '@expo/vector-icons/Ionicons';

export default function SettingsScreen() {
  const router = useRouter();

  return (
    <>
      <Stack.Screen options={{ title: 'Paramètres', headerBackTitle: 'Retour' }} />
      <ScrollView style={styles.container} contentContainerStyle={styles.content}>
        <Text style={styles.section}>Compte</Text>
        <Row icon="person-circle" label="Modifier le profil" onPress={() => router.push('/edit-profile')} />
        <Row icon="key" label="Changer le mot de passe" onPress={() => router.push('/change-password')} />

        <Text style={styles.section}>Notifications</Text>
        <Row icon="notifications" label="Préférences de notifications" onPress={() => router.push('/notification-settings')} />

        <Text style={styles.section}>Général</Text>
        <Row icon="color-palette" label="Apparence" onPress={() => router.push('/appearance')} />

        <Text style={styles.section}>Informations</Text>
        <Row icon="information-circle" label="À propos" onPress={() => router.push('/about')} />
      </ScrollView>
    </>
  );
}

function Row({
  icon,
  label,
  onPress,
}: {
  icon: React.ComponentProps<typeof Ionicons>['name'];
  label: string;
  onPress: () => void;
}) {
  return (
    <TouchableOpacity style={styles.row} onPress={onPress}>
      <Ionicons name={icon} size={22} color="#64748b" />
      <Text style={styles.rowText}>{label}</Text>
      <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },
  content: { padding: 16 },
  section: { fontWeight: '700', fontSize: 16, marginTop: 20, marginBottom: 8 },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#e2e8f0',
    marginBottom: 10,
  },
  rowText: { flex: 1, marginLeft: 12, fontSize: 16 },
});
