import { View, Text, StyleSheet } from 'react-native';
import { Stack } from 'expo-router';

export default function UniversityAdminModerationScreen() {
  return (
    <>
      <Stack.Screen options={{ title: 'Modération' }} />
      <View style={styles.container}>
        <Text style={styles.text}>Modération des contenus de l'université — signalements et validation.</Text>
      </View>
    </>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 24, justifyContent: 'center' },
  text: { textAlign: 'center', color: '#64748b' },
});
