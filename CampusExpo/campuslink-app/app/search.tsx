import { useState } from 'react';
import { View, Text, StyleSheet, FlatList, TextInput, TouchableOpacity } from 'react-native';
import { useRouter, Stack } from 'expo-router';
import Ionicons from '@expo/vector-icons/Ionicons';
import { searchUsers } from '../services/userService';
import type { User } from '../types';

function displayName(u: User) {
  return [u.first_name, u.last_name].filter(Boolean).join(' ') || u.username;
}

export default function SearchScreen() {
  const router = useRouter();
  const [query, setQuery] = useState('');
  const [list, setList] = useState<User[]>([]);
  const [searching, setSearching] = useState(false);

  const doSearch = async () => {
    const q = query.trim();
    if (!q) {
      setList([]);
      return;
    }
    setSearching(true);
    const data = await searchUsers(q);
    setList(data);
    setSearching(false);
  };

  return (
    <>
      <Stack.Screen options={{ title: 'Recherche', headerBackTitle: 'Retour' }} />
      <View style={styles.container}>
        <View style={styles.searchRow}>
          <TextInput
            style={styles.input}
            placeholder="Nom, username..."
            value={query}
            onChangeText={setQuery}
            onSubmitEditing={doSearch}
            returnKeyType="search"
          />
          <TouchableOpacity style={styles.searchBtn} onPress={doSearch}>
            <Ionicons name="search" size={22} color="#fff" />
          </TouchableOpacity>
        </View>
        <FlatList
          data={list}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.list}
          ListEmptyComponent={
            <Text style={styles.empty}>
              {searching ? 'Recherche...' : query.trim() ? 'Aucun résultat' : 'Saisissez un terme'}
            </Text>
          }
          renderItem={({ item }) => (
            <TouchableOpacity
              style={styles.row}
              onPress={() => router.push(`/user/${item.id}`)}
            >
              <View style={styles.avatar}>
                <Text style={styles.avatarText}>{(displayName(item)[0] || '?').toUpperCase()}</Text>
              </View>
              <View style={styles.body}>
                <Text style={styles.name}>{displayName(item)}</Text>
                <Text style={styles.username}>@{item.username}</Text>
              </View>
              <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
            </TouchableOpacity>
          )}
        />
      </View>
    </>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },
  searchRow: { flexDirection: 'row', padding: 16, gap: 8 },
  input: {
    flex: 1,
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#e2e8f0',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
  },
  searchBtn: {
    backgroundColor: '#2563eb',
    width: 48,
    height: 48,
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
  },
  list: { padding: 16 },
  empty: { textAlign: 'center', color: '#94a3b8', marginTop: 32 },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    padding: 12,
    borderRadius: 12,
    marginBottom: 8,
  },
  avatar: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: '#2563eb',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  avatarText: { color: '#fff', fontWeight: '600' },
  body: { flex: 1 },
  name: { fontWeight: '600' },
  username: { fontSize: 12, color: '#94a3b8' },
});
