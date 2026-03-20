import { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  ScrollView,
  Alert,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { Stack, useRouter } from 'expo-router';
import { useAuthStore } from '../store/authStore';
import { getMyProfile, updateMyProfile } from '../services/profileService';

export default function EditProfileScreen() {
  const router = useRouter();
  const { user, setUser } = useAuthStore();
  const [loading, setLoading] = useState(false);

  const [firstName, setFirstName] = useState(user?.first_name ?? '');
  const [lastName, setLastName] = useState(user?.last_name ?? '');
  const [bio, setBio] = useState(user?.profile?.bio ?? '');
  const [campus, setCampus] = useState(user?.profile?.campus ?? '');
  const [department, setDepartment] = useState(user?.profile?.department ?? '');

  useEffect(() => {
    (async () => {
      const u = await getMyProfile();
      if (!u) return;
      setUser(u);
      setFirstName(u.first_name ?? '');
      setLastName(u.last_name ?? '');
      setBio(u.profile?.bio ?? '');
      setCampus(u.profile?.campus ?? '');
      setDepartment(u.profile?.department ?? '');
    })();
  }, [setUser]);

  const handleSave = async () => {
    setLoading(true);
    const updated = await updateMyProfile({
      first_name: firstName.trim() || undefined,
      last_name: lastName.trim() || undefined,
      profile: {
        bio: bio.trim() || undefined,
        campus: campus.trim() || undefined,
        department: department.trim() || undefined,
      },
    });
    setLoading(false);

    if (!updated) {
      Alert.alert('Erreur', 'Impossible de sauvegarder le profil');
      return;
    }

    setUser(updated);
    Alert.alert('Succès', 'Profil mis à jour', [{ text: 'OK', onPress: () => router.back() }]);
  };

  return (
    <>
      <Stack.Screen options={{ title: 'Modifier le profil', headerBackTitle: 'Retour' }} />
      <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <ScrollView style={styles.container} contentContainerStyle={styles.content}>
          <Text style={styles.label}>Prénom</Text>
          <TextInput style={styles.input} value={firstName} onChangeText={setFirstName} editable={!loading} />

          <Text style={styles.label}>Nom</Text>
          <TextInput style={styles.input} value={lastName} onChangeText={setLastName} editable={!loading} />

          <Text style={styles.label}>Bio</Text>
          <TextInput
            style={[styles.input, styles.textArea]}
            value={bio}
            onChangeText={setBio}
            editable={!loading}
            multiline
          />

          <Text style={styles.label}>Campus</Text>
          <TextInput style={styles.input} value={campus} onChangeText={setCampus} editable={!loading} />

          <Text style={styles.label}>Département</Text>
          <TextInput style={styles.input} value={department} onChangeText={setDepartment} editable={!loading} />

          <TouchableOpacity style={[styles.btn, loading && styles.btnDisabled]} onPress={handleSave} disabled={loading}>
            <Text style={styles.btnText}>{loading ? 'Sauvegarde...' : 'Sauvegarder'}</Text>
          </TouchableOpacity>

          <Text style={styles.hint}>
            Note : selon la configuration du backend, certains champs peuvent être ignorés ou gérés via des entités (campus/département).
          </Text>
        </ScrollView>
      </KeyboardAvoidingView>
    </>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },
  content: { padding: 16 },
  label: { fontWeight: '600', marginBottom: 6, color: '#334155' },
  input: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#e2e8f0',
    borderRadius: 10,
    padding: 12,
    fontSize: 16,
    marginBottom: 14,
  },
  textArea: { minHeight: 90, textAlignVertical: 'top' },
  btn: {
    backgroundColor: '#2563eb',
    padding: 16,
    borderRadius: 10,
    alignItems: 'center',
    marginTop: 4,
  },
  btnDisabled: { opacity: 0.6 },
  btnText: { color: '#fff', fontWeight: '700', fontSize: 16 },
  hint: { color: '#64748b', marginTop: 16, lineHeight: 20 },
});
