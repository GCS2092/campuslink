import { Redirect } from 'expo-router';
import { View, ActivityIndicator } from 'react-native';
import { useSegments } from 'expo-router';
import { useAuthStore } from '../store/authStore';
import { getRedirectIfUnauthorized } from '../utils/roleRedirect';

export function RoleGuard({ children }: { children: React.ReactNode }) {
  const segments = useSegments();
  const { token, user, isLoading } = useAuthStore();
  const firstSegment = (segments[0] as string) ?? '';

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