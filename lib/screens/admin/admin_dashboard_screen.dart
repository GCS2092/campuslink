import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';
import '../../utils/app_colors.dart';
import 'admin_students_screen.dart';
import 'admin_verifications_screen.dart';
import 'admin_class_leaders_screen.dart';
import 'admin_universities_screen.dart';
import 'admin_moderation_screen.dart';
import 'admin_campuses_screen.dart';
import 'admin_departments_screen.dart';
import '../events_screen.dart';
import '../groups_screen.dart';

/// Dashboard spécifique pour les administrateurs globaux
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null || !user.isAdmin) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final stats = await _adminService.getDashboardStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (!mounted) return;
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

    // Vérifier que l'utilisateur est bien un administrateur global
    if (user == null || !user.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(
          child: Text('Accès réservé aux administrateurs globaux'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Administrateur'),
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
                    // Statistiques globales
                    if (_stats != null) ...[
                      const Text(
                        'Statistiques Globales',
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
                      _buildChartsSection(_stats!),
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

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
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
      childAspectRatio: 1.6, // Augmenté de 1.5 à 1.6 pour donner plus d'espace vertical
      children: [
        _buildStatCard(
          'Étudiants',
          safeToString(stats['total_students_count']),
          Icons.people,
          AppColors.primary,
        ),
        _buildStatCard(
          'Posts',
          safeToString(stats['posts_count']),
          Icons.article,
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
        padding: const EdgeInsets.all(12), // Réduit de 16 à 12
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Ajouté pour éviter l'overflow
          children: [
            Icon(icon, color: color, size: 28), // Réduit de 32 à 28
            const SizedBox(height: 6), // Réduit de 8 à 6
            Flexible( // Ajouté pour gérer l'overflow
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20, // Réduit de 24 à 20
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2), // Réduit de 4 à 2
            Flexible( // Ajouté pour gérer l'overflow
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11, // Réduit de 12 à 11
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

  Widget _buildChartsSection(Map<String, dynamic> stats) {
    // Préparer les données pour le graphique
    final studentsCount = (stats['total_students_count'] as num?)?.toDouble() ?? 0.0;
    final postsCount = (stats['posts_count'] as num?)?.toDouble() ?? 0.0;
    final eventsCount = (stats['events_count'] as num?)?.toDouble() ?? 0.0;
    final groupsCount = (stats['groups_count'] as num?)?.toDouble() ?? 0.0;

    final maxValue = [studentsCount, postsCount, eventsCount, groupsCount]
        .reduce((a, b) => a > b ? a : b);

    final chartData = [
      {'label': 'Étudiants', 'value': studentsCount, 'color': AppColors.primary},
      {'label': 'Posts', 'value': postsCount, 'color': AppColors.accent},
      {'label': 'Événements', 'value': eventsCount, 'color': AppColors.secondary},
      {'label': 'Groupes', 'value': groupsCount, 'color': AppColors.warning},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vue d\'ensemble',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue > 0 ? maxValue * 1.2 : 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      tooltipBgColor: AppColors.surface,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < chartData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                chartData[index]['label'] as String,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.max) return const Text('');
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxValue > 0 ? maxValue / 5 : 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.border.withValues(alpha: 0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.border,
                        width: 1,
                      ),
                      left: BorderSide(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                  ),
                  barGroups: chartData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data['value'] as double,
                          color: data['color'] as Color,
                          width: 30,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
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
                builder: (context) => const AdminStudentsScreen(),
              ),
            );
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
                builder: (context) => const AdminVerificationsScreen(),
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
                builder: (context) => const AdminClassLeadersScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          context,
          'Universités',
          Icons.school,
          AppColors.warning,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminUniversitiesScreen(),
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
                builder: (context) => const AdminModerationScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          context,
          'Campus',
          Icons.location_city,
          AppColors.info,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminCampusesScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          context,
          'Départements',
          Icons.business,
          AppColors.textSecondary,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDepartmentsScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          context,
          'Événements',
          Icons.event,
          AppColors.success,
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
          AppColors.primary,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GroupsScreen(),
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
}

