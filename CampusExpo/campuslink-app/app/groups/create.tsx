import { useState } from 'react';
import { View, Text, TextInput, StyleSheet, TouchableOpacity, Alert } from 'react-native';
import { useRouter, Stack } from 'expo-router';
import { createGroup } from '../../services/groupService';

export default function CreateGroupScreen() {
  const router = useRouter();
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [loading, setLoading] = useState(false);

  const handleCreate = async () => {
    if (!name.trim()) {
      Alert.alert('Erreur', 'Nom du groupe requis');
      return;
    }
    setLoading(true);
    const group = await createGroup({
      name: name.trim(),
      description: description.trim(),
      is_private: false,
    });
    setLoading(false);
    if (group) {
      Alert.alert('Succès', 'Groupe créé', [
        { text: 'OK', onPress: () => router.replace(`/groups/${group.id}`) },
      ]);
    } else {
      Alert.alert('Erreur', 'Impossible de créer le groupe');
    }
  };

  return (
    <>
      <Stack.Screen options={{ title: 'Créer un groupe', headerBackTitle: 'Retour' }} />
      <View style={styles.container}>
        <Text style={styles.label}>Nom du groupe *</Text>
        <TextInput
          style={styles.input}
          value={name}
          onChangeText={setName}
          placeholder="Ex: L3 Informatique"
          editable={!loading}
        />
        <Text style={styles.label}>Description</Text>
        <TextInput
          style={[styles.input, styles.textArea]}
          value={description}
          onChangeText={setDescription}
          placeholder="Décrivez le groupe..."
          multiline
          editable={!loading}
        />
        <TouchableOpacity
          style={[styles.button, loading && styles.buttonDisabled]}
          onPress={handleCreate}
          disabled={loading}
        >
          <Text style={styles.buttonText}>{loading ? 'Création...' : 'Créer le groupe'}</Text>
        </TouchableOpacity>
      </View>
    </>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 16, backgroundColor: '#f8fafc' },
  label: { fontSize: 14, fontWeight: '600', marginBottom: 6 },
  input: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#e2e8f0',
    borderRadius: 8,
    padding: 14,
    marginBottom: 16,
    fontSize: 16,
  },
  textArea: { minHeight: 80 },
  button: {
    backgroundColor: '#2563eb',
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 8,
  },
  buttonDisabled: { opacity: 0.6 },
  buttonText: { color: '#fff', fontSize: 16, fontWeight: '600' },
});
