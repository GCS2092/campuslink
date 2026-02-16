import { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  TextInput,
  RefreshControl,
  Modal,
  Alert,
} from 'react-native';
import { useRouter } from 'expo-router';
import Ionicons from '@expo/vector-icons/Ionicons';
import { getFeed, createPost, likePost } from '../../services/feedService';
import type { Post } from '../../types';

function formatTime(iso: string) {
  const d = new Date(iso);
  const now = new Date();
  const diff = (now.getTime() - d.getTime()) / 60000;
  if (diff < 60) return 'À l\'instant';
  if (diff < 1440) return `Il y a ${Math.floor(diff / 60)} h`;
  return d.toLocaleDateString('fr-FR');
}

export default function FeedScreen() {
  const router = useRouter();
  const [posts, setPosts] = useState<Post[]>([]);
  const [refreshing, setRefreshing] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [newContent, setNewContent] = useState('');
  const [posting, setPosting] = useState(false);

  const load = async () => {
    const data = await getFeed();
    setPosts(data);
  };

  useEffect(() => {
    load();
  }, []);

  const handleLike = async (post: Post) => {
    const res = await likePost(post.id);
    setPosts((prev) =>
      prev.map((p) =>
        p.id === post.id
          ? { ...p, is_liked: res.is_liked, likes_count: p.likes_count + (res.is_liked ? 1 : -1) }
          : p
      )
    );
  };

  const handleCreatePost = async () => {
    const content = newContent.trim();
    if (!content) return;
    setPosting(true);
    const created = await createPost(content);
    setPosting(false);
    setModalVisible(false);
    setNewContent('');
    if (created) {
      setPosts((prev) => [created, ...prev]);
    }
  };

  const authorName = (p: Post) =>
    [p.author.first_name, p.author.last_name].filter(Boolean).join(' ') || p.author.username;

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.createBtn} onPress={() => setModalVisible(true)}>
          <Ionicons name="add-circle" size={24} color="#2563eb" />
          <Text style={styles.createBtnText}>Nouveau post</Text>
        </TouchableOpacity>
      </View>
      <FlatList
        data={posts}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} />}
        ListEmptyComponent={<Text style={styles.empty}>Aucun post</Text>}
        renderItem={({ item }) => (
          <View style={styles.card}>
            <View style={styles.cardHeader}>
              <View style={styles.avatar}>
                <Text style={styles.avatarText}>{(authorName(item)[0] || '?').toUpperCase()}</Text>
              </View>
              <View style={styles.cardHeaderText}>
                <Text style={styles.authorName}>{authorName(item)}</Text>
                <Text style={styles.time}>{formatTime(item.created_at)}</Text>
              </View>
            </View>
            <Text style={styles.content}>{item.content}</Text>
            {item.image_url ? (
              <View style={styles.imagePlaceholder}>
                <Ionicons name="image" size={40} color="#94a3b8" />
              </View>
            ) : null}
            <View style={styles.actions}>
              <TouchableOpacity style={styles.actionBtn} onPress={() => handleLike(item)}>
                <Ionicons name={item.is_liked ? 'heart' : 'heart-outline'} size={22} color={item.is_liked ? '#ef4444' : '#64748b'} />
                <Text style={styles.actionText}>{item.likes_count}</Text>
              </TouchableOpacity>
              <TouchableOpacity style={styles.actionBtn} onPress={() => router.push({ pathname: '/post/[id]', params: { id: item.id } })}>
                <Ionicons name="chatbubble-outline" size={22} color="#64748b" />
                <Text style={styles.actionText}>{item.comments_count}</Text>
              </TouchableOpacity>
            </View>
          </View>
        )}
      />

      <Modal visible={modalVisible} animationType="slide" transparent>
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Nouveau post</Text>
            <TextInput
              style={styles.modalInput}
              placeholder="Quoi de neuf ?"
              value={newContent}
              onChangeText={setNewContent}
              multiline
              editable={!posting}
            />
            <View style={styles.modalButtons}>
              <TouchableOpacity style={styles.modalCancel} onPress={() => { setModalVisible(false); setNewContent(''); }}>
                <Text style={styles.modalCancelText}>Annuler</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.modalSubmit, (!newContent.trim() || posting) && styles.modalSubmitDisabled]}
                onPress={handleCreatePost}
                disabled={!newContent.trim() || posting}
              >
                <Text style={styles.modalSubmitText}>{posting ? 'Publication...' : 'Publier'}</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f1f5f9' },
  header: { padding: 16, paddingBottom: 8 },
  createBtn: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  createBtnText: { marginLeft: 8, color: '#2563eb', fontWeight: '600' },
  list: { padding: 16 },
  empty: { textAlign: 'center', color: '#94a3b8', marginTop: 32 },
  card: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
  },
  cardHeader: { flexDirection: 'row', alignItems: 'center', marginBottom: 12 },
  avatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#2563eb',
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarText: { color: '#fff', fontWeight: '600' },
  cardHeaderText: { marginLeft: 12 },
  authorName: { fontWeight: '600' },
  time: { fontSize: 12, color: '#94a3b8' },
  content: { fontSize: 15, lineHeight: 22 },
  imagePlaceholder: {
    height: 120,
    backgroundColor: '#f1f5f9',
    borderRadius: 8,
    marginTop: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  actions: { flexDirection: 'row', marginTop: 12, gap: 24 },
  actionBtn: { flexDirection: 'row', alignItems: 'center' },
  actionText: { marginLeft: 4, fontSize: 14, color: '#64748b' },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'center',
    padding: 24,
  },
  modalContent: { backgroundColor: '#fff', borderRadius: 16, padding: 20 },
  modalTitle: { fontSize: 18, fontWeight: '700', marginBottom: 12 },
  modalInput: {
    borderWidth: 1,
    borderColor: '#e2e8f0',
    borderRadius: 8,
    padding: 12,
    minHeight: 100,
    textAlignVertical: 'top',
  },
  modalButtons: { flexDirection: 'row', justifyContent: 'flex-end', marginTop: 16, gap: 12 },
  modalCancel: {},
  modalCancelText: { color: '#64748b' },
  modalSubmit: { backgroundColor: '#2563eb', paddingHorizontal: 20, paddingVertical: 10, borderRadius: 8 },
  modalSubmitDisabled: { opacity: 0.5 },
  modalSubmitText: { color: '#fff', fontWeight: '600' },
});
