import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Stack, useRouter } from 'expo-router';
import { useAuthStore } from '../store/authStore';

export default function PendingActivationScreen() {
  const router = useRouter();
  const { logout } = useAuthStore();

  return (
    <>
      <Stack.Screen options={{ title: 'Validation du compte', headerBackTitle: 'Retour' }} />
      <View style={styles.container}>
        <Text style={styles.title}>Compte en attente</Text>
        <Text style={styles.text}>
          Ton compte a bien été créé, mais il est en attente de validation par un administrateur.
        </Text>
        <Text style={styles.text}>
          Tu pourras te connecter normalement dès que la validation sera terminée.
        </Text>

        <TouchableOpacity style={styles.btn} onPress={() => router.replace('/login')}>
          <Text style={styles.btnText}>Retour à la connexion</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.secondary}
          onPress={async () => {
            await logout();
            router.replace('/login');
          }}
        >
          <Text style={styles.secondaryText}>Se déconnecter</Text>
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
  secondary: { marginTop: 12, alignItems: 'center', padding: 12 },
  secondaryText: { color: '#64748b', fontWeight: '600' },
});
