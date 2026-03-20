import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { RoleGuard } from '../components/RoleGuard';

export default function RootLayout() {
  return (
    <>
      <StatusBar style="auto" />
      <RoleGuard>
        <Stack
          screenOptions={{
            headerShown: true,
            headerBackTitle: 'Retour',
            headerStyle: { backgroundColor: '#2563eb' },
            headerTintColor: '#fff',
          }}
        />
      </RoleGuard>
    </>
  );
}
