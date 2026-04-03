import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/providers/profile_provider.dart';
import 'admin_dashboard_screen.dart';
import 'university_admin_dashboard_screen.dart';
import 'class_leader_dashboard_screen.dart';

class RoleBasedDashboardScreen extends ConsumerWidget {
  const RoleBasedDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      // ✅ Pendant le chargement
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),

      // ✅ En cas d'erreur
      error: (e, _) => Scaffold(
        body: Center(child: Text('Erreur: $e')),
      ),

      // ✅ u est User? — on utilise u?.role avec fallback
      data: (u) {
        final role = u?.role ?? 'student';

        switch (role) {
          case 'admin':
            return const AdminDashboardScreen();
          case 'university_admin':
            return const UniversityAdminDashboardScreen();
          case 'class_leader':
            return const ClassLeaderDashboardScreen();
          default:
            return Scaffold(
              appBar: AppBar(title: const Text('Dashboard')),
              body: const Center(
                child: Text(
                  'Cette section est réservée aux administrateurs et délégués.',
                ),
              ),
            );
        }
      },
    );
  }
}