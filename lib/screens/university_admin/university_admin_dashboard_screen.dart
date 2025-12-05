import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/university_admin_service.dart';
import '../../utils/app_colors.dart';
import 'university_admin_students_screen.dart';
import 'university_admin_verifications_screen.dart';
import 'university_admin_class_leaders_screen.dart';
import 'university_admin_moderation_screen.dart';
import 'university_admin_create_student_screen.dart';
import 'university_admin_settings_screen.dart';
import 'university_admin_campuses_screen.dart';
import 'university_admin_departments_screen.dart';
import '../events_screen.dart';
import '../groups_screen.dart';

/// Dashboard spécifique pour les administrateurs d'université
class UniversityAdminDashboardScreen extends StatefulWidget {
  const UniversityAdminDashboardScreen({super.key});

  @override
  State<UniversityAdminDashboardScreen> createState() => _UniversityAdminDashboardScreenState();
}

class _UniversityAdminDashboardScreenState extends State<UniversityAdminDashboardScreen> {
  final UniversityAdminService _universityAdminService = UniversityAdminService();
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _university;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _universityAdminService.getDashboardStats();
      final university = await _universityAdminService.getMyUniversity();
      setState(() {
        _stats = stats;
        _university = university;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        _stats = null;
        _university = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Vérifier que l'utilisateur est bien un administrateur d'université
    if (user == null || !user.isUniversityAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(
          child: Text('Accès réservé aux administrateurs d\'université'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Université'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec informations de l'université
                    if (_university != null) _buildUniversityInfoCard(_university!),
                    if (_university != null) const SizedBox(height: 16),

                    // Statistiques
                    if (_stats != null) ...[
                      const Text(
                        'Statistiques de l\'Université',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStatsGrid(_stats!),
                      const SizedBox(height: 16),
                      _buildTrendsSection(_stats!),
                      const SizedBox(height: 24),
                    ],

                    // Actions rapides
                    const Text(
                      'Gestion',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActions(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUniversityInfoCard(Map<String, dynamic> university) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        university['name'] ?? 'Université',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (university['location'] != null)
                        Text(
                          university['location'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    // Fonction helper pour convertir en String de manière sûre
    String safeToString(dynamic value) {
      if (value == null) return '0';
      if (value is int || value is double) return value.toString();
      if (value is String) {
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
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Étudiants',
          safeToString(stats['total_students_count']),
          Icons.people,
          AppColors.primary,
        ),
        _buildStatCard(
          'Responsables',
          safeToString(stats['class_leaders_count']),
          Icons.person_outline,
          AppColors.accent,
        ),
        _buildStatCard(
          'Événements',
          safeToString(stats['events_count']),
          Icons.event,
          AppColors.secondary,
        ),
        _buildStatCard(
          'Groupes',
          safeToString(stats['groups_count']),
          Icons.group,
          AppColors.warning,
        ),
        _buildStatCard(
          'En attente',
          safeToString(stats['pending_students_count']),
          Icons.pending,
          AppColors.error,
        ),
        _buildStatCard(
          'Vérifiés',
          safeToString(stats['verified_students_count']),
          Icons.verified_user,
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildActionCard(
          context,
          'Étudiants',
          Icons.people,
          AppColors.primary,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UniversityAdminStudentsScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          context,
          'Créer Étudiant',
          Icons.person_add,
          AppColors.accent,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UniversityAdminCreateStudentScreen(),
              ),
            ).then((created) {
              if (created == true) {
                _loadData();
              }
            });
          },
        ),
        _buildActionCard(
          context,
          'Vérifications',
          Icons.verified_user,
          AppColors.accent,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UniversityAdminVerificationsScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          context,
          'Responsables',
          Icons.person_outline,
          AppColors.secondary,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UniversityAdminClassLeadersScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          context,
          'Modération',
          Icons.shield,
          AppColors.error,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UniversityAdminModerationScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          context,
          'Événements',
          Icons.event,
          AppColors.warning,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EventsScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          context,
          'Groupes',
          Icons.group,
          AppColors.info,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GroupsScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          context,
          'Paramètres',
          Icons.settings,
          AppColors.textSecondary,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UniversityAdminSettingsScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          context,
          'Campus',
          Icons.location_city,
          AppColors.warning,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UniversityAdminCampusesScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          context,
          'Départements',
          Icons.business,
          AppColors.secondary,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UniversityAdminDepartmentsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
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
      ),
    );
  }

  Widget _buildTrendsSection(Map<String, dynamic> stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tendances',
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
                  child: _buildTrendItem(
                    'Inscriptions (7j)',
                    stats['registrations_last_7_days']?.toString() ?? '0',
                    Icons.trending_up,
                  ),
                ),
                Expanded(
                  child: _buildTrendItem(
                    'Inscriptions (30j)',
                    stats['registrations_last_30_days']?.toString() ?? '0',
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTrendItem(
                    'Événements à venir',
                    stats['upcoming_events']?.toString() ?? '0',
                    Icons.event,
                  ),
                ),
                Expanded(
                  child: _buildTrendItem(
                    'Taux activité',
                    '${stats['activity_rate']?.toString() ?? '0'}%',
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

