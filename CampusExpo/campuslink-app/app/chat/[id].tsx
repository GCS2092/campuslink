import { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { useLocalSearchParams, useRouter, Stack } from 'expo-router';
import { getMessages, sendMessage } from '../../services/messagingService';
import { useAuthStore } from '../../store/authStore';
import type { Message } from '../../types';

export default function ChatScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const { user } = useAuthStore();
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');

  const isValidId = !!id && !id.includes('[') && !id.includes(']');

  const load = async () => {
    if (!isValidId) return;
    const data = await getMessages(id);
    setMessages(data);
  };

  useEffect(() => {
    load();
  }, [id]);

  const handleSend = async () => {
    const content = input.trim();
    if (!content || !isValidId) return;
    setInput('');
    const newMsg = await sendMessage(id, content);
    if (newMsg) setMessages((prev) => [...prev, newMsg]);
  };

  const isMe = (msg: Message) => msg.sender.id === user?.id;

  return (
    <>
      <Stack.Screen options={{ title: 'Chat', headerBackTitle: 'Retour' }} />
      <KeyboardAvoidingView
        style={styles.container}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        keyboardVerticalOffset={90}
      >
        {!isValidId ? (
          <View style={{ padding: 16 }}>
            <Text style={{ color: '#64748b' }}>Conversation introuvable</Text>
            <TouchableOpacity
              style={{ marginTop: 12 }}
              onPress={() => (router.canGoBack() ? router.back() : router.replace('/(tabs)/index'))}
            >
              <Text style={{ color: '#2563eb', fontWeight: '600' }}>Retour</Text>
            </TouchableOpacity>
          </View>
        ) : null}
        <FlatList
          data={messages}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.list}
          renderItem={({ item }) => (
            <View style={[styles.bubble, isMe(item) ? styles.bubbleMe : styles.bubbleThem]}>
              <Text style={styles.bubbleText}>{item.content}</Text>
              <Text style={styles.bubbleTime}>
                {new Date(item.created_at).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })}
              </Text>
            </View>
          )}
        />
        <View style={styles.inputRow}>
          <TextInput
            style={styles.input}
            placeholder="Message..."
            value={input}
            onChangeText={setInput}
            multiline
            maxLength={500}
            editable={isValidId}
          />
          <TouchableOpacity
            style={[styles.sendBtn, !input.trim() && styles.sendBtnDisabled]}
            onPress={handleSend}
            disabled={!input.trim() || !isValidId}
          >
            <Text style={styles.sendText}>Envoyer</Text>
          </TouchableOpacity>
        </View>
      </KeyboardAvoidingView>
    </>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f1f5f9' },
  list: { padding: 16, paddingBottom: 8 },
  bubble: {
    maxWidth: '80%',
    padding: 12,
    borderRadius: 16,
    marginBottom: 8,
  },
  bubbleMe: { alignSelf: 'flex-end', backgroundColor: '#2563eb' },
  bubbleThem: { alignSelf: 'flex-start', backgroundColor: '#fff' },
  bubbleText: { fontSize: 15 },
  bubbleTime: { fontSize: 11, color: '#94a3b8', marginTop: 4 },
  inputRow: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    padding: 8,
    backgroundColor: '#fff',
    borderTopWidth: 1,
    borderTopColor: '#e2e8f0',
  },
  input: {
    flex: 1,
    borderWidth: 1,
    borderColor: '#e2e8f0',
    borderRadius: 20,
    paddingHorizontal: 16,
    paddingVertical: 10,
    maxHeight: 100,
    fontSize: 15,
  },
  sendBtn: {
    marginLeft: 8,
    backgroundColor: '#2563eb',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 20,
    justifyContent: 'center',
  },
  sendBtnDisabled: { opacity: 0.5 },
  sendText: { color: '#fff', fontWeight: '600' },
});
