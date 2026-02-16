import { useState } from 'react';
import {
  Text,
  TextInput,
  StyleSheet,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
  Alert,
} from 'react-native';
import { useRouter } from 'expo-router';
import * as SecureStore from 'expo-secure-store';
import { useAuthStore } from '../store/authStore';
import { login as authLogin } from '../services/authService';
import { STORAGE_KEYS } from '../constants';
import { mockUser } from '../services/mockData';
import { getRedirectForUser } from '../utils/roleRedirect';

export default function LoginScreen() {
  const router = useRouter();
  const { setUser, setToken } = useAuthStore();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async () => {
    if (!email.trim() || !password) {
      Alert.alert('Erreur', 'Email et mot de passe requis');
      return;
    }
    setLoading(true);
    const result = await authLogin(email.trim(), password);
    setLoading(false);
    if ('error' in result) {
      Alert.alert('Erreur', result.error);
      return;
    }
    setUser(result.user);
    setToken(result.token);
    router.replace(getRedirectForUser(result.user) as any);
  };

  const handleDemoMode = async () => {
    const token = 'demo_' + Date.now();
    await SecureStore.setItemAsync(STORAGE_KEYS.accessToken, token);
    await SecureStore.setItemAsync(STORAGE_KEYS.userData, JSON.stringify(mockUser));
    setUser(mockUser);
    setToken(token);
    router.replace('/(tabs)');
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <Text style={styles.title}>CampusLink</Text>
      <Text style={styles.subtitle}>Connexion</Text>
      <Text style={styles.roleHint}>
        Utilisez le compte du rôle souhaité : vous serez redirigé vers l’espace correspondant (étudiant, admin, responsable de classe, admin université).
      </Text>

      <TextInput
        style={styles.input}
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
        autoCapitalize="none"
        keyboardType="email-address"
        editable={!loading}
      />
      <TextInput
        style={styles.input}
        placeholder="Mot de passe"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
        editable={!loading}
      />

      <TouchableOpacity
        style={[styles.button, loading && styles.buttonDisabled]}
        onPress={handleLogin}
        disabled={loading}
      >
        <Text style={styles.buttonText}>
          {loading ? 'Connexion...' : 'Se connecter'}
        </Text>
      </TouchableOpacity>

      <TouchableOpacity
        style={styles.link}
        onPress={() => router.push('/register')}
        disabled={loading}
      >
        <Text style={styles.linkText}>Pas de compte ? S'inscrire</Text>
      </TouchableOpacity>
      <TouchableOpacity style={styles.demoLink} onPress={handleDemoMode} disabled={loading}>
        <Text style={styles.demoLinkText}>Mode démo (sans backend)</Text>
      </TouchableOpacity>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    padding: 24,
    backgroundColor: '#f8fafc',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 4,
    color: '#1e293b',
  },
  subtitle: {
    fontSize: 16,
    color: '#64748b',
    textAlign: 'center',
    marginBottom: 8,
  },
  roleHint: {
    fontSize: 12,
    color: '#94a3b8',
    textAlign: 'center',
    marginHorizontal: 16,
    marginBottom: 24,
  },
  input: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#e2e8f0',
    borderRadius: 8,
    padding: 14,
    marginBottom: 12,
    fontSize: 16,
  },
  button: {
    backgroundColor: '#2563eb',
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 8,
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  link: {
    marginTop: 20,
    alignItems: 'center',
  },
  linkText: {
    color: '#2563eb',
    fontSize: 14,
  },
  demoLink: {
    marginTop: 12,
    alignItems: 'center',
  },
  demoLinkText: {
    color: '#94a3b8',
    fontSize: 13,
  },
});
