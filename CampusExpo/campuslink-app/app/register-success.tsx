import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Stack, useRouter } from 'expo-router';

export default function RegisterSuccessScreen() {
  const router = useRouter();

  return (
    <>
      <Stack.Screen options={{ title: 'Inscription', headerBackTitle: 'Retour' }} />
      <View style={styles.container}>
        <Text style={styles.title}>Inscription réussie</Text>
        <Text style={styles.text}>
          Ton compte a été créé. Selon la configuration, il peut nécessiter une validation avant activation.
        </Text>
        <TouchableOpacity style={styles.btn} onPress={() => router.replace('/login')}>
          <Text style={styles.btnText}>Aller à la connexion</Text>
        </TouchableOpacity>
      </View>
    </>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc', padding: 24, justifyContent: 'center' },
  title: { fontSize: 24, fontWeight: '800', color: '#0f172a', marginBottom: 10, textAlign: 'center' },
  text: { color: '#475569', lineHeight: 20, textAlign: 'center', marginTop: 8 },
  btn: { marginTop: 24, backgroundColor: '#2563eb', padding: 16, borderRadius: 10, alignItems: 'center' },
  btnText: { color: '#fff', fontWeight: '700' },
});
