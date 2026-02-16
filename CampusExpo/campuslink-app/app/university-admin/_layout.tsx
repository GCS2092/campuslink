import { useEffect } from 'react';
import { Stack, useRouter } from 'expo-router';
import { View, ActivityIndicator } from 'react-native';
import { useAuthStore } from '../../store/authStore';
import { isUniversityAdmin } from '../../types';
import { getRedirectForUser } from '../../utils/roleRedirect';

export default function UniversityAdminLayout() {
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
    if (!user || !isUniversityAdmin(user)) {
      router.replace(getRedirectForUser(user) as any);
    }
  }, [isLoading, token, user]);

  if (isLoading || !token || !user || !isUniversityAdmin(user)) {
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
