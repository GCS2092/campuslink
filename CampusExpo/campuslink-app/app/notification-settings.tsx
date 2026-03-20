import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, Switch, ScrollView, TouchableOpacity } from 'react-native';
import { Stack, useRouter } from 'expo-router';
import {
  getNotificationPreferences,
  updateNotificationPreferences,
  type NotificationPreferences,
} from '../services/profileService';

export default function NotificationSettingsScreen() {
  const router = useRouter();
  const [prefs, setPrefs] = useState<NotificationPreferences>({
    push_notifications: true,
    email_notifications: true,
    event_reminders: true,
    friend_requests: true,
    messages: true,
    group_updates: true,
    event_invitations: true,
  });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    (async () => {
      const remote = await getNotificationPreferences();
      if (remote) setPrefs((p) => ({ ...p, ...remote }));
    })();
  }, []);

  const setField = <K extends keyof NotificationPreferences>(key: K, value: boolean) => {
    setPrefs((prev) => ({ ...prev, [key]: value }));
  };

  const save = async () => {
    setLoading(true);
    const res = await updateNotificationPreferences(prefs);
    setLoading(false);
    if (!res) return;
    router.back();
  };

  return (
    <>
      <Stack.Screen
        options={{
          title: 'Notifications',
          headerBackTitle: 'Retour',
          headerRight: () => (
            <TouchableOpacity onPress={save} disabled={loading}>
              <Text style={{ color: '#fff', fontWeight: '700' }}>{loading ? '...' : 'OK'}</Text>
            </TouchableOpacity>
          ),
        }}
      />
      <ScrollView style={styles.container} contentContainerStyle={styles.content}>
        <Text style={styles.section}>Canaux</Text>
        <Row label="Push" value={!!prefs.push_notifications} onChange={(v) => setField('push_notifications', v)} />
        <Row label="Email" value={!!prefs.email_notifications} onChange={(v) => setField('email_notifications', v)} />

        <Text style={styles.section}>Types</Text>
        <Row label="Messages" value={!!prefs.messages} onChange={(v) => setField('messages', v)} />
        <Row label="Demandes d'amis" value={!!prefs.friend_requests} onChange={(v) => setField('friend_requests', v)} />
        <Row label="Rappels événements" value={!!prefs.event_reminders} onChange={(v) => setField('event_reminders', v)} />
        <Row label="Invitations événements" value={!!prefs.event_invitations} onChange={(v) => setField('event_invitations', v)} />
        <Row label="Mises à jour de groupes" value={!!prefs.group_updates} onChange={(v) => setField('group_updates', v)} />

        <Text style={styles.hint}>Les options disponibles dépendent du backend. Si un champ n’est pas supporté, il sera ignoré.</Text>
      </ScrollView>
    </>
  );
}

function Row({
  label,
  value,
  onChange,
}: {
  label: string;
  value: boolean;
  onChange: (v: boolean) => void;
}) {
  return (
    <View style={styles.row}>
      <Text style={styles.rowLabel}>{label}</Text>
      <Switch value={value} onValueChange={onChange} />
    </View>
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
  rowLabel: { fontSize: 16, color: '#0f172a', fontWeight: '600' },
  hint: { color: '#64748b', marginTop: 16, lineHeight: 20 },
});
