import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../services/user_service.dart';
import 'events_screen.dart';
import 'conversations_screen.dart';
import 'students_screen.dart';
import 'groups_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'university_admin/university_admin_dashboard_screen.dart';
import 'class_leader/class_leader_dashboard_screen.dart';

/// Écran Dashboard - Écran principal après connexion
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final UserService _userService = UserService();
  Map<String, dynamic>? _stats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final stats = await _userService.getProfileStats();
      setState(() {
        _stats = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      debugPrint('Error loading stats: $e');
      setState(() {
        _stats = null;
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusLink'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              // TODO: Afficher le badge avec le nombre de notifications non lues
              // Positioned(
              //   right: 8,
              //   top: 8,
              //   child: Container(
              //     padding: const EdgeInsets.all(4),
              //     decoration: const BoxDecoration(
              //       color: AppColors.error,
              //       shape: BoxShape.circle,
              //     ),
              //     child: const Text('0', style: TextStyle(fontSize: 10, color: Colors.white)),
              //   ),
              // ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout(context);
              } else if (value == 'profile') {
                // TODO: Navigation vers profil
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil à venir')),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.person_outline, size: 20),
                      SizedBox(width: 8),
                      Text('Profil'),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.settings, size: 20),
                      SizedBox(width: 8),
                      Text('Paramètres'),
                    ],
                  ),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Déconnexion', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          // Debug: Afficher les informations de rôle pour diagnostiquer
          debugPrint('=== USER ROLE DEBUG ===');
          debugPrint('User ID: ${user.id}');
          debugPrint('Username: ${user.username}');
          debugPrint('Role: ${user.role}');
          debugPrint('isStaff: ${user.isStaff}');
          debugPrint('isSuperuser: ${user.isSuperuser}');
          debugPrint('isAdmin: ${user.isAdmin}');
          debugPrint('isUniversityAdmin: ${user.isUniversityAdmin}');
          debugPrint('isClassLeader: ${user.isClassLeader}');
          debugPrint('======================');
          
          // Si l'utilisateur est un administrateur global, afficher le dashboard spécifique
          // Vérifier d'abord isAdmin (qui inclut isStaff, isSuperuser, ou role == 'admin')
          if (user.isAdmin) {
            debugPrint('Redirecting to Admin Dashboard');
            return const AdminDashboardScreen();
          }
          
          // Si l'utilisateur est un administrateur d'université, afficher le dashboard spécifique
          if (user.isUniversityAdmin) {
            debugPrint('Redirecting to University Admin Dashboard');
            return const UniversityAdminDashboardScreen();
          }
          
          // Si l'utilisateur est un responsable de classe, afficher le dashboard spécifique
          if (user.isClassLeader) {
            debugPrint('Redirecting to Class Leader Dashboard');
            return const ClassLeaderDashboardScreen();
          }
          
          debugPrint('Redirecting to Student Dashboard');

          return RefreshIndicator(
            onRefresh: () async {
              await authProvider.loadUserProfile();
              await _loadStats();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête de bienvenue
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          child: Text(
                            user.username.isNotEmpty
                                ? user.username[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bonjour, ${user.firstName ?? user.username}!',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section Statistiques
                  if (_stats != null) ...[
                    const Text(
                      'Mes Statistiques',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatsSection(_stats!),
                    const SizedBox(height: 24),
                  ] else if (_isLoadingStats) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Section Actions Rapides
                  const Text(
                    'Actions Rapides',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.event,
                          title: 'Événements',
                          color: AppColors.primary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EventsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.message,
                          title: 'Messages',
                          color: AppColors.secondary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ConversationsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.people,
                          title: 'Étudiants',
                          color: AppColors.accent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const StudentsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.group,
                          title: 'Groupes',
                          color: AppColors.warning,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GroupsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section Informations
                  const Text(
                    'Informations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    icon: Icons.verified_user,
                    title: 'Statut de vérification',
                    value: user.isVerified ? 'Vérifié' : 'En attente',
                    color: user.isVerified ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(height: 8),
                  _InfoCard(
                    icon: Icons.phone,
                    title: 'Téléphone',
                    value: user.phoneVerified ? 'Vérifié' : 'Non vérifié',
                    color: user.phoneVerified ? AppColors.success : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> stats) {
    // Extraire les statistiques avec gestion robuste des types
    final events = stats['events'] as Map<String, dynamic>? ?? {};
    final groups = stats['groups'] as Map<String, dynamic>? ?? {};
    final friends = stats['friends'] as Map<String, dynamic>? ?? {};

    // Fonction helper pour convertir en String de manière sûre
    String safeToString(dynamic value) {
      if (value == null) return '0';
      if (value is int || value is double) return value.toString();
      if (value is String) {
        // Essayer de parser si c'est un nombre en string
        final parsed = int.tryParse(value);
        return parsed?.toString() ?? '0';
      }
      return '0';
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          'Événements\nOrganisés',
          safeToString(events['organized']),
          Icons.event,
          AppColors.primary,
        ),
        _buildStatCard(
          'Événements\nParticipés',
          safeToString(events['participated']),
          Icons.event_available,
          AppColors.accent,
        ),
        _buildStatCard(
          'Événements\nÀ venir',
          safeToString(events['upcoming']),
          Icons.event_note,
          AppColors.success,
        ),
        _buildStatCard(
          'Groupes\nCréés',
          safeToString(groups['created']),
          Icons.group_add,
          AppColors.secondary,
        ),
        _buildStatCard(
          'Groupes\nMembres',
          safeToString(groups['member']),
          Icons.group,
          AppColors.warning,
        ),
        _buildStatCard(
          'Amis',
          safeToString(friends['count']),
          Icons.people,
          AppColors.info,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Déconnexion réussie'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

/// Widget pour les cartes d'action rapide
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour les cartes d'information
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

