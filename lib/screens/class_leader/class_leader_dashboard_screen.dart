import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/class_leader_service.dart';
import '../../utils/app_colors.dart';
import 'class_leader_moderation_screen.dart';
import '../events_screen.dart';
import '../groups_screen.dart';
import '../students_screen.dart';

/// Dashboard spécifique pour les responsables de classe
class ClassLeaderDashboardScreen extends StatefulWidget {
  const ClassLeaderDashboardScreen({super.key});

  @override
  State<ClassLeaderDashboardScreen> createState() => _ClassLeaderDashboardScreenState();
}

class _ClassLeaderDashboardScreenState extends State<ClassLeaderDashboardScreen> {
  final ClassLeaderService _classLeaderService = ClassLeaderService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _classLeaderService.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading stats: $e');
      setState(() {
        _stats = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Vérifier que l'utilisateur est bien un responsable de classe
    if (user == null || !user.isClassLeader) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(
          child: Text('Accès réservé aux responsables de classe'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Responsable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec informations de la classe
                    _buildClassInfoCard(user),
                    const SizedBox(height: 16),

                    // Statistiques
                    if (_stats != null) ...[
                      const Text(
                        'Statistiques de la Classe',
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
                      'Actions Rapides',
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

  Widget _buildClassInfoCard(user) {
    final university = user.profile?['university']?['name'] ?? 'Non spécifiée';
    final fieldOfStudy = user.profile?['field_of_study'] ?? 'Non spécifié';
    final academicYear = user.profile?['academic_year'] ?? 'Non spécifié';

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
                  child: const Icon(Icons.class_, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ma Classe',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        university,
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
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(Icons.school, 'Filière', fieldOfStudy),
                ),
                Expanded(
                  child: _buildInfoItem(Icons.calendar_today, 'Année', academicYear),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
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
          safeToString(stats['total_students_count'] ?? stats['students_count']),
          Icons.people,
          AppColors.primary,
        ),
        _buildStatCard(
          'Événements',
          safeToString(stats['events_count']),
          Icons.event,
          AppColors.accent,
        ),
        _buildStatCard(
          'Groupes',
          safeToString(stats['groups_count']),
          Icons.group,
          AppColors.secondary,
        ),
        _buildStatCard(
          'Posts',
          safeToString(stats['posts_count']),
          Icons.article,
          AppColors.warning,
        ),
        _buildStatCard(
          'En attente',
          safeToString(stats['pending_students_count']),
          Icons.pending,
          AppColors.error,
        ),
        _buildStatCard(
          'Actifs',
          safeToString(stats['active_students_count']),
          Icons.check_circle,
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
          'Modération',
          Icons.shield,
          AppColors.error,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ClassLeaderModerationScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          context,
          'Événements',
          Icons.event,
          AppColors.accent,
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
          AppColors.secondary,
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
          'Étudiants',
          Icons.people,
          AppColors.primary,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentsScreen(),
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

