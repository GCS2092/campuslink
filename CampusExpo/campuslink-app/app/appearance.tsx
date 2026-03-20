import { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { Stack } from 'expo-router';

type ThemeMode = 'system' | 'light' | 'dark';

export default function AppearanceScreen() {
  const [mode, setMode] = useState<ThemeMode>('system');

  return (
    <>
      <Stack.Screen options={{ title: 'Apparence', headerBackTitle: 'Retour' }} />
      <ScrollView style={styles.container} contentContainerStyle={styles.content}>
        <Text style={styles.section}>Thème</Text>
        <Option label="Système" selected={mode === 'system'} onPress={() => setMode('system')} />
        <Option label="Clair" selected={mode === 'light'} onPress={() => setMode('light')} />
        <Option label="Sombre" selected={mode === 'dark'} onPress={() => setMode('dark')} />

        <Text style={styles.hint}>
          Pour l’instant, ce choix est local et n’applique pas encore un thème global. Il sert de base pour finaliser la gestion du thème.
        </Text>
      </ScrollView>
    </>
  );
}

function Option({
  label,
  selected,
  onPress,
}: {
  label: string;
  selected: boolean;
  onPress: () => void;
}) {
  return (
    <TouchableOpacity style={[styles.row, selected && styles.rowSelected]} onPress={onPress}>
      <Text style={styles.rowText}>{label}</Text>
      <Text style={styles.rowRight}>{selected ? '✓' : ''}</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },
  content: { padding: 16 },
  section: { fontWeight: '800', fontSize: 16, marginTop: 18, marginBottom: 10 },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#e2e8f0',
    borderRadius: 12,
    padding: 14,
    marginBottom: 10,
  },
  rowSelected: { borderColor: '#2563eb' },
  rowText: { fontSize: 16, color: '#0f172a', fontWeight: '600' },
  rowRight: { color: '#2563eb', fontWeight: '800' },
  hint: { color: '#64748b', marginTop: 16, lineHeight: 20 },
});
