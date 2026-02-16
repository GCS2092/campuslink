import { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Alert,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { useRouter, Stack } from 'expo-router';
import { createEvent } from '../../services/eventService';

export default function CreateEventScreen() {
  const router = useRouter();
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [location, setLocation] = useState('');
  const [startDate, setStartDate] = useState('');
  const [startTime, setStartTime] = useState('');
  const [loading, setLoading] = useState(false);

  const handleCreate = async () => {
    if (!title.trim()) {
      Alert.alert('Erreur', 'Titre requis');
      return;
    }
    if (!location.trim()) {
      Alert.alert('Erreur', 'Lieu requis');
      return;
    }
    let start = startDate && startTime
      ? new Date(`${startDate}T${startTime}`).toISOString()
      : new Date(Date.now() + 864e5).toISOString();
    setLoading(true);
    const ev = await createEvent({
      title: title.trim(),
      description: description.trim(),
      location: location.trim(),
      start_date: start,
      is_free: true,
      price: 0,
    });
    setLoading(false);
    if (ev) {
      Alert.alert('Succès', 'Événement créé', [
        { text: 'OK', onPress: () => router.replace(`/events/${ev.id}`) },
      ]);
    } else {
      Alert.alert('Erreur', 'Impossible de créer l\'événement');
    }
  };

  return (
    <>
      <Stack.Screen options={{ title: 'Créer un événement', headerBackTitle: 'Retour' }} />
      <KeyboardAvoidingView style={styles.container} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <ScrollView contentContainerStyle={styles.scroll}>
          <Text style={styles.label}>Titre *</Text>
          <TextInput
            style={styles.input}
            value={title}
            onChangeText={setTitle}
            placeholder="Ex: Soirée de rentrée"
            editable={!loading}
          />
          <Text style={styles.label}>Description</Text>
          <TextInput
            style={[styles.input, styles.textArea]}
            value={description}
            onChangeText={setDescription}
            placeholder="Décrivez l'événement..."
            multiline
            editable={!loading}
          />
          <Text style={styles.label}>Lieu *</Text>
          <TextInput
            style={styles.input}
            value={location}
            onChangeText={setLocation}
            placeholder="Ex: Amphi A"
            editable={!loading}
          />
          <Text style={styles.label}>Date (AAAA-MM-JJ)</Text>
          <TextInput
            style={styles.input}
            value={startDate}
            onChangeText={setStartDate}
            placeholder="2025-03-15"
            editable={!loading}
          />
          <Text style={styles.label}>Heure (HH:MM)</Text>
          <TextInput
            style={styles.input}
            value={startTime}
            onChangeText={setStartTime}
            placeholder="18:00"
            editable={!loading}
          />
          <TouchableOpacity
            style={[styles.button, loading && styles.buttonDisabled]}
            onPress={handleCreate}
            disabled={loading}
          >
            <Text style={styles.buttonText}>{loading ? 'Création...' : 'Créer l\'événement'}</Text>
          </TouchableOpacity>
        </ScrollView>
      </KeyboardAvoidingView>
    </>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },
  scroll: { padding: 16 },
  label: { fontSize: 14, fontWeight: '600', marginBottom: 6, color: '#334155' },
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
