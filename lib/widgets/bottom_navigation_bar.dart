import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/events_screen.dart';
import '../screens/groups_screen.dart';
import '../screens/students_screen.dart';
import '../screens/conversations_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_students_screen.dart';
import '../screens/admin/admin_verifications_screen.dart';
import '../screens/admin/admin_moderation_screen.dart';
import 'bottom_nav_wrapper.dart';

/// Widget de navigation en bas style WhatsApp
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isAdmin;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    // Si c'est un admin, utiliser la navigation admin
    if (isAdmin) {
      return _buildAdminNavigation(context);
    }
    
    // Sinon, navigation standard pour étudiants
    return _buildStudentNavigation(context);
  }

  Widget _buildStudentNavigation(BuildContext context) {
    // Couleur violette/pourpre pour l'élément actif (comme sur l'image)
    const activeColor = Color(0xFF6366F1); // Violet comme sur l'image
    const inactiveColor = Color(0xFF8E8E93); // Gris pour les éléments inactifs
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_rounded,
                label: 'Accueil',
                index: 0,
                isActive: currentIndex == 0,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                context,
                icon: Icons.event_rounded,
                label: 'Événements',
                index: 1,
                isActive: currentIndex == 1,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                context,
                icon: Icons.group_rounded,
                label: 'Groupes',
                index: 2,
                isActive: currentIndex == 2,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                context,
                icon: Icons.people_rounded,
                label: 'Étudiants',
                index: 3,
                isActive: currentIndex == 3,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                context,
                icon: Icons.message_rounded,
                label: 'Messages',
                index: 4,
                isActive: currentIndex == 4,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                context,
                icon: Icons.person_rounded,
                label: 'Profil',
                index: 5,
                isActive: currentIndex == 5,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminNavigation(BuildContext context) {
    const activeColor = Color(0xFF6366F1);
    const inactiveColor = Color(0xFF8E8E93);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                index: 0,
                isActive: currentIndex == 0,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                context,
                icon: Icons.people_rounded,
                label: 'Étudiants',
                index: 1,
                isActive: currentIndex == 1,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                context,
                icon: Icons.verified_user_rounded,
                label: 'Vérifications',
                index: 2,
                isActive: currentIndex == 2,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                context,
                icon: Icons.shield_rounded,
                label: 'Modération',
                index: 3,
                isActive: currentIndex == 3,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                context,
                icon: Icons.message_rounded,
                label: 'Messages',
                index: 4,
                isActive: currentIndex == 4,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                context,
                icon: Icons.person_rounded,
                label: 'Profil',
                index: 5,
                isActive: currentIndex == 5,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          splashColor: activeColor.withValues(alpha: 0.1),
          highlightColor: activeColor.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône - Style WhatsApp
                Icon(
                  icon,
                  size: 24,
                  color: isActive ? activeColor : inactiveColor,
                ),
                const SizedBox(height: 4),
                // Texte - Style WhatsApp
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? activeColor : inactiveColor,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Retourne l'écran correspondant à l'index avec wrapper pour padding
  static Widget getScreenForIndex(int index, {bool isAdmin = false}) {
    Widget screen;
    if (isAdmin) {
      // Navigation admin
      switch (index) {
        case 0:
          screen = const AdminDashboardScreen();
          break;
        case 1:
          screen = const AdminStudentsScreen();
          break;
        case 2:
          screen = const AdminVerificationsScreen();
          break;
        case 3:
          screen = const AdminModerationScreen();
          break;
        case 4:
          screen = const ConversationsScreen();
          break;
        case 5:
          screen = const ProfileScreen();
          break;
        default:
          screen = const AdminDashboardScreen();
      }
    } else {
      // Navigation standard pour étudiants
      switch (index) {
        case 0:
          screen = const DashboardScreen();
          break;
        case 1:
          screen = const EventsScreen();
          break;
        case 2:
          screen = const GroupsScreen();
          break;
        case 3:
          screen = const StudentsScreen();
          break;
        case 4:
          screen = const ConversationsScreen();
          break;
        case 5:
          screen = const ProfileScreen();
          break;
        default:
          screen = const DashboardScreen();
      }
    }
    return BottomNavWrapper(child: screen);
  }

  /// Retourne le nom de la route pour l'index
  static String getRouteForIndex(int index, {bool isAdmin = false}) {
    if (isAdmin) {
      switch (index) {
        case 0:
          return '/admin/dashboard';
        case 1:
          return '/admin/students';
        case 2:
          return '/admin/verifications';
        case 3:
          return '/admin/moderation';
        case 4:
          return '/messages';
        case 5:
          return '/profile';
        default:
          return '/admin/dashboard';
      }
    } else {
      switch (index) {
        case 0:
          return '/dashboard';
        case 1:
          return '/events';
        case 2:
          return '/groups';
        case 3:
          return '/students';
        case 4:
          return '/messages';
        case 5:
          return '/profile';
        default:
          return '/dashboard';
      }
    }
  }
}

