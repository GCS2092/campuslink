import { useEffect } from 'react';
import { Stack, useRouter } from 'expo-router';
import { View, ActivityIndicator } from 'react-native';
import { useAuthStore } from '../../store/authStore';
import { isClassLeader } from '../../types';
import { getRedirectForUser } from '../../utils/roleRedirect';

export default function ClassLeaderLayout() {
  const router = useRouter();
  const { token, user, isLoading, loadFromStorage } = useAuthStore();

  useEffect(() => {
    loadFromStorage();
  }, [loadFromStorage]);

  useEffect(() => {
    if (isLoading) return;
    if (!token) {
      router.replace('/login');
      return;
    }
    if (!user || !isClassLeader(user)) {
      router.replace(getRedirectForUser(user) as any);
    }
  }, [isLoading, token, user]);

  if (isLoading || !token || !user || !isClassLeader(user)) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  return (
    <Stack
      screenOptions={{
        headerStyle: { backgroundColor: '#2563eb' },
        headerTintColor: '#fff',
        headerBackTitle: 'Retour',
      }}
    />
  );
}
