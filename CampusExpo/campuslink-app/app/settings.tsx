import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { Stack } from 'expo-router';

export default function SettingsScreen() {
  return (
    <>
      <Stack.Screen options={{ title: 'Paramètres', headerBackTitle: 'Retour' }} />
      <ScrollView style={styles.container} contentContainerStyle={styles.content}>
        <Text style={styles.section}>Général</Text>
        <Text style={styles.placeholder}>Thème (clair / sombre) — à venir</Text>
        <Text style={styles.placeholder}>Langue — à venir</Text>
        <Text style={styles.section}>Notifications</Text>
        <Text style={styles.placeholder}>Activer les notifications push — à venir</Text>
        <Text style={styles.placeholder}>Notifications de messages — à venir</Text>
        <Text style={styles.section}>Compte</Text>
        <Text style={styles.placeholder}>Modifier le profil — à venir</Text>
        <Text style={styles.placeholder}>Changer le mot de passe — à venir</Text>
      </ScrollView>
    </>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },
  content: { padding: 16 },
  section: { fontWeight: '700', fontSize: 16, marginTop: 20, marginBottom: 8 },
  placeholder: { color: '#64748b', paddingVertical: 8 },
});
