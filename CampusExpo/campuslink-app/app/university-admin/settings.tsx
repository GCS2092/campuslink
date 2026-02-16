import { View, Text, StyleSheet } from 'react-native';
import { Stack } from 'expo-router';

export default function UniversityAdminSettingsScreen() {
  return (
    <>
      <Stack.Screen options={{ title: 'Paramètres université' }} />
      <View style={styles.container}>
        <Text style={styles.text}>Paramètres de l'université — à configurer côté backend.</Text>
      </View>
    </>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 24, justifyContent: 'center' },
  text: { textAlign: 'center', color: '#64748b' },
});
