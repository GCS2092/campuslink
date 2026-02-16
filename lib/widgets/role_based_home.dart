import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/class_leader/class_leader_dashboard_screen.dart';
import '../screens/university_admin/university_admin_dashboard_screen.dart';

/// Affiche l'écran d'accueil adapté au rôle de l'utilisateur connecté.
/// - admin : navigation avec onglets admin (dashboard, étudiants, vérifications, modération)
/// - university_admin : dashboard administrateur d'université
/// - class_leader : dashboard responsable de classe
/// - student et autres : navigation avec onglets étudiant (accueil, événements, groupes, etc.)
class RoleBasedHome extends StatelessWidget {
  const RoleBasedHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (user.isAdmin) {
          return const MainNavigationScreen();
        }
        if (user.isUniversityAdmin) {
          return const UniversityAdminDashboardScreen();
        }
        if (user.isClassLeader) {
          return const ClassLeaderDashboardScreen();
        }
        return const MainNavigationScreen();
      },
    );
  }
}
