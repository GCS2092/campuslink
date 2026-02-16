import { useEffect } from 'react';
import { Redirect } from 'expo-router';
import { View, ActivityIndicator } from 'react-native';
import { useSegments } from 'expo-router';
import { useAuthStore } from '../store/authStore';
import { getRedirectIfUnauthorized } from '../utils/roleRedirect';

/**
 * Vérifie que l'utilisateur connecté a le droit d'accéder à la route actuelle.
 * Sinon redirige vers la page appropriée (login ou dashboard selon le rôle).
 */
export function RoleGuard({ children }: { children: React.ReactNode }) {
  const segments = useSegments();
  const { token, user, isLoading, loadFromStorage } = useAuthStore();
  const firstSegment = (segments[0] as string) ?? '';

  useEffect(() => {
    loadFromStorage();
  }, [loadFromStorage]);

  if (isLoading) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  const redirect = getRedirectIfUnauthorized(user, token, firstSegment);
  if (redirect) {
    return <Redirect href={redirect as any} />;
  }

  return <>{children}</>;
}
