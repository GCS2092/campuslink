import { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { useLocalSearchParams, Stack } from 'expo-router';
import { getPost, getComments, addComment } from '../../services/feedService';
import type { Post, Comment } from '../../types';

function authorName(a: { first_name?: string; last_name?: string; username: string }) {
  return [a.first_name, a.last_name].filter(Boolean).join(' ') || a.username;
}

export default function PostDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const [post, setPost] = useState<Post | null>(null);
  const [comments, setComments] = useState<Comment[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);

  const isValidId = !!id && !id.includes('[') && !id.includes(']');

  const load = async () => {
    if (!isValidId) return;
    const [p, c] = await Promise.all([getPost(id), getComments(id)]);
    setPost(p ?? null);
    setComments(c);
  };

  useEffect(() => {
    load();
  }, [id]);

  const handleSend = async () => {
    const content = input.trim();
    if (!content || !isValidId || loading) return;
    setLoading(true);
    const newComment = await addComment(id, content);
    setLoading(false);
    setInput('');
    if (newComment) setComments((prev) => [...prev, newComment]);
  };

  if (!post) {
    return (
      <>
        <Stack.Screen options={{ title: 'Publication', headerBackTitle: 'Retour' }} />
        <View style={styles.centered}>
          <Text>{isValidId ? 'Chargement...' : 'Publication introuvable'}</Text>
        </View>
      </>
    );
  }

  return (
    <>
      <Stack.Screen options={{ title: 'Publication', headerBackTitle: 'Retour' }} />
      <KeyboardAvoidingView style={styles.container} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <ScrollView style={styles.scroll} contentContainerStyle={styles.scrollContent}>
          <View style={styles.card}>
            <View style={styles.cardHeader}>
              <View style={styles.avatar}>
                <Text style={styles.avatarText}>{(authorName(post.author)[0] || '?').toUpperCase()}</Text>
              </View>
              <View>
                <Text style={styles.authorName}>{authorName(post.author)}</Text>
                <Text style={styles.time}>{new Date(post.created_at).toLocaleDateString('fr-FR')}</Text>
              </View>
            </View>
            <Text style={styles.content}>{post.content}</Text>
          </View>
          <Text style={styles.sectionTitle}>Commentaires ({comments.length})</Text>
          {comments.map((c) => (
            <View key={c.id} style={styles.comment}>
              <Text style={styles.commentAuthor}>{authorName(c.author)}</Text>
              <Text style={styles.commentContent}>{c.content}</Text>
            </View>
          ))}
        </ScrollView>
        <View style={styles.inputRow}>
          <TextInput
            style={styles.input}
            placeholder="Ajouter un commentaire..."
            value={input}
            onChangeText={setInput}
            editable={!loading}
          />
          <TouchableOpacity
            style={[styles.sendBtn, !input.trim() && styles.sendBtnDisabled]}
            onPress={handleSend}
            disabled={!input.trim() || loading}
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
  scroll: { flex: 1 },
  scrollContent: { padding: 16, paddingBottom: 24 },
  centered: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  card: { backgroundColor: '#fff', borderRadius: 12, padding: 16, marginBottom: 16 },
  cardHeader: { flexDirection: 'row', alignItems: 'center', marginBottom: 12 },
  avatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#2563eb',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  avatarText: { color: '#fff', fontWeight: '600' },
  authorName: { fontWeight: '600' },
  time: { fontSize: 12, color: '#94a3b8' },
  content: { fontSize: 15, lineHeight: 22 },
  sectionTitle: { fontWeight: '600', marginBottom: 12 },
  comment: { backgroundColor: '#fff', padding: 12, borderRadius: 8, marginBottom: 8 },
  commentAuthor: { fontWeight: '600', fontSize: 14 },
  commentContent: { marginTop: 4, color: '#475569' },
  inputRow: {
    flexDirection: 'row',
    alignItems: 'center',
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
    fontSize: 15,
  },
  sendBtn: {
    marginLeft: 8,
    backgroundColor: '#2563eb',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 20,
  },
  sendBtnDisabled: { opacity: 0.5 },
  sendText: { color: '#fff', fontWeight: '600' },
});
