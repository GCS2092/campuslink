import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { Stack } from 'expo-router';

export default function AboutScreen() {
  return (
    <>
      <Stack.Screen options={{ title: 'À propos', headerBackTitle: 'Retour' }} />
      <ScrollView style={styles.container} contentContainerStyle={styles.content}>
        <Text style={styles.title}>CampusLink</Text>
        <Text style={styles.text}>
          CampusLink est une plateforme de communication étudiante (web + mobile) : événements, groupes, feed, notifications et messagerie.
        </Text>
        <Text style={styles.section}>Stack</Text>
        <Text style={styles.text}>Backend : Django + DRF + Channels (WebSockets)</Text>
        <Text style={styles.text}>Web : Next.js + TypeScript + Tailwind</Text>
        <Text style={styles.text}>Mobile : Flutter / Expo (selon client)</Text>
        <Text style={styles.section}>Note</Text>
        <Text style={styles.text}>Cette app Expo utilise une API et peut fallback sur des données mock en mode démo.</Text>
      </ScrollView>
    </>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },
  content: { padding: 16 },
  title: { fontSize: 24, fontWeight: '800', color: '#0f172a', marginBottom: 10 },
  section: { marginTop: 18, fontWeight: '800', fontSize: 16 },
  text: { marginTop: 8, color: '#475569', lineHeight: 20 },
});
