import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../services/user_service.dart';
import 'settings_screen.dart';
import 'friends_screen.dart';
import 'my_events_screen.dart';
import 'groups_screen.dart';

/// Écran de profil utilisateur
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      setState(() => _isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authProvider.user!;

          return RefreshIndicator(
            onRefresh: () async {
              await authProvider.loadUserProfile();
              await _loadStats();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // En-tête avec photo de profil
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: Text(
                                  user.username.isNotEmpty
                                      ? user.username[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                user.fullName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@${user.username}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Statistiques
                        if (_isLoadingStats)
                          const Center(child: CircularProgressIndicator())
                        else if (_stats != null)
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.people,
                                  label: 'Amis',
                                  value: '${_stats!['friends_count'] ?? 0}',
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.event,
                                  label: 'Événements',
                                  value: '${_stats!['events_count'] ?? 0}',
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.group,
                                  label: 'Groupes',
                                  value: '${_stats!['groups_count'] ?? 0}',
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 24),

                        // Informations
                        const Text(
                          'Informations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.email,
                          label: 'Email',
                          value: user.email,
                        ),
                        if (user.phoneNumber != null)
                          _InfoRow(
                            icon: Icons.phone,
                            label: 'Téléphone',
                            value: user.phoneNumber!,
                          ),
                        if (user.role != null)
                          _InfoRow(
                            icon: Icons.work,
                            label: 'Rôle',
                            value: _getRoleLabel(user.role!),
                          ),
                        _InfoRow(
                          icon: Icons.verified_user,
                          label: 'Statut',
                          value: user.isVerified ? 'Vérifié' : 'En attente',
                          valueColor: user.isVerified ? AppColors.success : AppColors.warning,
                        ),
                        _InfoRow(
                          icon: Icons.calendar_today,
                          label: 'Membre depuis',
                          value: DateFormat('dd MMMM yyyy').format(user.dateJoined ?? DateTime.now()),
                        ),

                        const SizedBox(height: 24),

                        // Actions
                        const Text(
                          'Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ActionTile(
                          icon: Icons.people,
                          title: 'Mes amis',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FriendsScreen(),
                              ),
                            );
                          },
                        ),
                        _ActionTile(
                          icon: Icons.event,
                          title: 'Mes événements',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyEventsScreen(),
                              ),
                            );
                          },
                        ),
                        _ActionTile(
                          icon: Icons.group,
                          title: 'Mes groupes',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GroupsScreen(),
                              ),
                            );
                          },
                        ),
                        _ActionTile(
                          icon: Icons.settings,
                          title: 'Paramètres',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'student':
        return 'Étudiant';
      case 'class_leader':
        return 'Responsable de Classe';
      case 'association':
        return 'Association/Club';
      case 'admin':
        return 'Administrateur';
      case 'university_admin':
        return 'Administrateur d\'Université';
      default:
        return role;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? AppColors.textPrimary,
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

