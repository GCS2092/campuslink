import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import 'widgets/admin_drawer.dart';
import 'widgets/stats_card.dart';

class ClassLeaderDashboardScreen extends ConsumerWidget {
  const ClassLeaderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(classLeaderDashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Délégué'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(classLeaderDashboardStatsProvider),
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class Header
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.class_,
                        size: 48,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stats.className ?? 'Ma Classe',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              stats.departmentName ?? 'Département',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  StatsCard(
                    title: 'Effectif',
                    value: stats.classSize.toString(),
                    subtitle: '${stats.activeStudents} actifs',
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  StatsCard(
                    title: 'En attente',
                    value: stats.pendingStudents.toString(),
                    subtitle: 'Non activés',
                    icon: Icons.pending,
                    color: Colors.orange,
                  ),
                  StatsCard(
                    title: 'Événements',
                    value: stats.classEvents.toString(),
                    subtitle: 'Classe',
                    icon: Icons.event,
                    color: Colors.green,
                  ),
                  StatsCard(
                    title: 'Groupes',
                    value: stats.classGroups.toString(),
                    subtitle: 'Actifs',
                    icon: Icons.groups,
                    color: Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Activity
              Text(
                'Activité récente',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (stats.recentActivities?.isEmpty ?? true)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Aucune activité récente',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: stats.recentActivities?.length ?? 0,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final activity = stats.recentActivities![index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getActivityColor(activity.activityType),
                          child: Icon(
                            _getActivityIcon(activity.activityType),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(activity.studentName ?? 'Étudiant'),
                        subtitle: Text(activity.description ?? activity.activityType),
                        trailing: Text(
                          _formatTimestamp(activity.timestamp),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(classLeaderDashboardStatsProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'joined':
        return Colors.green;
      case 'event_created':
        return Colors.blue;
      case 'post_created':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'joined':
        return Icons.person_add;
      case 'event_created':
        return Icons.event;
      case 'post_created':
        return Icons.post_add;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    // Simple formatting - in real app, use intl package
    return timestamp.substring(0, 10);
  }
}
