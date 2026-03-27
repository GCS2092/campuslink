import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../profile/providers/profile_provider.dart';
import '../admin_dashboard_screen.dart';
import '../moderation_screen.dart';
import '../pending_students_screen.dart';
import '../class_leaders_screen.dart';

class AdminDrawer extends ConsumerWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.maybeWhen(data: (u) => u, orElse: () => null);
    final role = user?.role ?? 'student';

    String title;
    IconData roleIcon;
    Color roleColor;

    switch (role) {
      case 'admin':
        title = 'Administrateur';
        roleIcon = Icons.admin_panel_settings;
        roleColor = Colors.red;
        break;
      case 'university_admin':
        title = 'Admin Université';
        roleIcon = Icons.account_balance;
        roleColor = Colors.blue;
        break;
      case 'class_leader':
        title = 'Délégué';
        roleIcon = Icons.school;
        roleColor = Colors.purple;
        break;
      default:
        title = 'Utilisateur';
        roleIcon = Icons.person;
        roleColor = Colors.grey;
    }

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: roleColor,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(roleIcon, color: roleColor, size: 32),
            ),
            accountName: Text(
              '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(title),
          ),

          // Dashboard
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
              );
            },
          ),

          // Only for admin and university_admin
          if (role == 'admin' || role == 'university_admin') ...[
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('Étudiants en attente'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PendingStudentsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Gestion des délégués'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ClassLeadersScreen()),
                );
              },
            ),
          ],

          // Moderation (admin only)
          if (role == 'admin')
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Modération'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ModerationScreen()),
                );
              },
            ),

          const Divider(),

          // Back to app
          ListTile(
            leading: const Icon(Icons.arrow_back),
            title: const Text('Retour à l\'application'),
            onTap: () => Navigator.pop(context),
          ),

          const Spacer(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
            onTap: () {
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}
