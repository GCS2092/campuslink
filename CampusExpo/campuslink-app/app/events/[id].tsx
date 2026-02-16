import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useLocalSearchParams, useRouter, Stack } from 'expo-router';
import Ionicons from '@expo/vector-icons/Ionicons';
import { getEvent, participate, leaveEvent } from '../../services/eventService';
import type { Event } from '../../types';

export default function EventDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const [event, setEvent] = useState<Event | null>(null);
  const [loading, setLoading] = useState(false);

  const load = async () => {
    if (!id) return;
    const ev = await getEvent(id);
    setEvent(ev);
  };

  useEffect(() => {
    load();
  }, [id]);

  const toggleParticipate = async () => {
    if (!event || loading) return;
    setLoading(true);
    if (event.is_participating) {
      await leaveEvent(event.id);
      setEvent((prev) => prev ? { ...prev, is_participating: false, participants_count: prev.participants_count - 1 } : null);
    } else {
      await participate(event.id);
      setEvent((prev) => prev ? { ...prev, is_participating: true, participants_count: prev.participants_count + 1 } : null);
    }
    setLoading(false);
  };

  if (!event) {
    return (
      <>
        <Stack.Screen options={{ title: 'Événement', headerBackTitle: 'Retour' }} />
        <View style={styles.centered}><Text style={styles.empty}>Chargement...</Text></View>
      </>
    );
  }

  const start = new Date(event.start_date);
  const dateStr = start.toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });
  const timeStr = start.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' });

  return (
    <>
      <Stack.Screen options={{ title: event.title, headerBackTitle: 'Retour' }} />
      <ScrollView style={styles.container} contentContainerStyle={styles.content}>
        <View style={styles.header}>
          <Text style={styles.title}>{event.title}</Text>
          <Text style={styles.organizer}>Par {event.organizer?.name ?? '—'}</Text>
        </View>
        <View style={styles.meta}>
          <Ionicons name="calendar-outline" size={20} color="#64748b" />
          <Text style={styles.metaText}>{dateStr} à {timeStr}</Text>
        </View>
        <View style={styles.meta}>
          <Ionicons name="location-outline" size={20} color="#64748b" />
          <Text style={styles.metaText}>{event.location}</Text>
        </View>
        <View style={styles.meta}>
          <Ionicons name="people-outline" size={20} color="#64748b" />
          <Text style={styles.metaText}>{event.participants_count} participant(s)</Text>
        </View>
        {event.description ? (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Description</Text>
            <Text style={styles.description}>{event.description}</Text>
          </View>
        ) : null}
        <TouchableOpacity
          style={[styles.btn, event.is_participating ? styles.btnLeave : styles.btnJoin]}
          onPress={toggleParticipate}
          disabled={loading}
        >
          <Text style={styles.btnText}>
            {event.is_participating ? 'Ne plus participer' : 'Participer'}
          </Text>
        </TouchableOpacity>
      </ScrollView>
    </>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },
  content: { padding: 16 },
  centered: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  empty: { color: '#94a3b8' },
  header: { marginBottom: 16 },
  title: { fontSize: 22, fontWeight: '700', color: '#0f172a' },
  organizer: { fontSize: 14, color: '#64748b', marginTop: 4 },
  meta: { flexDirection: 'row', alignItems: 'center', marginBottom: 8 },
  metaText: { marginLeft: 8, color: '#475569' },
  section: { marginTop: 20 },
  sectionTitle: { fontWeight: '600', marginBottom: 8 },
  description: { color: '#475569', lineHeight: 22 },
  btn: {
    marginTop: 24,
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
  },
  btnJoin: { backgroundColor: '#2563eb' },
  btnLeave: { backgroundColor: '#94a3b8' },
  btnText: { color: '#fff', fontWeight: '600' },
});
