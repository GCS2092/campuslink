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
    final role = userAsync.maybeWhen(
      data: (u) => u.role,
      orElse: () => 'student',
    );

    // Route to appropriate dashboard based on role
    switch (role) {
      case 'admin':
        return const AdminDashboardScreen();
      case 'university_admin':
        return const UniversityAdminDashboardScreen();
      case 'class_leader':
        return const ClassLeaderDashboardScreen();
      default:
        // Students don't have a special dashboard, show error or redirect
        return Scaffold(
          appBar: AppBar(title: const Text('Dashboard')),
          body: const Center(
            child: Text('Cette section est réservée aux administrateurs et délégués.'),
          ),
        );
    }
  }
}
