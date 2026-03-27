import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../router/app_router.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/feed'))          return 0;
    if (location.startsWith('/events'))        return 1;
    if (location.startsWith('/groups'))        return 2;
    if (location.startsWith('/messages'))      return 3;
    if (location.startsWith('/notifications')) return 4;
    if (location.startsWith('/profile'))       return 5;
    return 0;
  }

  void _onTap(BuildContext context, int index, bool hasAdminAccess) {
    switch (index) {
      case 0: context.go(AppRoutes.feed);          break;
      case 1: context.go(AppRoutes.events);        break;
      case 2: context.go(AppRoutes.groups);        break;
      case 3: context.go(AppRoutes.conversations); break;
      case 4: context.go(AppRoutes.notifications); break;
      case 5: context.go(AppRoutes.profile);       break;
      case 6: context.go(AppRoutes.admin);         break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location     = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);
    final userAsync = ref.watch(currentUserProvider);
    final role = userAsync.maybeWhen(
      data: (u) => u.role,
      orElse: () => 'student',
    );

    // Roles that have admin access
    final hasAdminAccess = ['admin', 'university_admin', 'class_leader'].contains(role);

    final destinations = <NavigationDestination>[
      const NavigationDestination(icon: Icon(Icons.home_outlined),          selectedIcon: Icon(Icons.home),          label: 'Accueil'),
      const NavigationDestination(icon: Icon(Icons.event_outlined),         selectedIcon: Icon(Icons.event),         label: 'Evenements'),
      const NavigationDestination(icon: Icon(Icons.group_outlined),         selectedIcon: Icon(Icons.group),         label: 'Groupes'),
      const NavigationDestination(icon: Icon(Icons.chat_bubble_outline),    selectedIcon: Icon(Icons.chat_bubble),   label: 'Messages'),
      const NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Notifs'),
      const NavigationDestination(icon: Icon(Icons.person_outline),         selectedIcon: Icon(Icons.person),        label: 'Profil'),
      if (hasAdminAccess)
        NavigationDestination(
          icon: Icon(_getAdminIcon(role), color: Colors.grey),
          selectedIcon: Icon(_getAdminIcon(role), color: _getAdminColor(role)),
          label: _getAdminLabel(role),
        ),
    ];

    // Adjust index if we're on admin page
    var selectedIndex = currentIndex;
    if (location.startsWith('/admin')) {
      selectedIndex = destinations.length - 1;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => _onTap(context, i, hasAdminAccess),
        destinations: destinations,
      ),
    );
  }

  IconData _getAdminIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings_outlined;
      case 'university_admin':
        return Icons.account_balance_outlined;
      case 'class_leader':
        return Icons.school_outlined;
      default:
        return Icons.settings_outlined;
    }
  }

  Color _getAdminColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'university_admin':
        return Colors.blue;
      case 'class_leader':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getAdminLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'university_admin':
        return 'Univ.';
      case 'class_leader':
        return 'Délégué';
      default:
        return 'Admin';
    }
  }
}
