import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import 'widgets/admin_drawer.dart';
import 'widgets/stats_card.dart';
import 'pending_students_screen.dart';
import 'class_leaders_screen.dart';
import 'moderation_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminDashboardStatsProvider),
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
              // Header
              Text(
                'Vue d\'ensemble',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

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
                    title: 'Utilisateurs',
                    value: stats.totalUsers.toString(),
                    subtitle: '${stats.activeUsers} actifs',
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PendingStudentsScreen()),
                    ),
                  ),
                  StatsCard(
                    title: 'En attente',
                    value: stats.pendingUsers.toString(),
                    subtitle: 'Activation requise',
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PendingStudentsScreen()),
                    ),
                  ),
                  StatsCard(
                    title: 'Bannis',
                    value: stats.bannedUsers.toString(),
                    subtitle: 'Comptes suspendus',
                    icon: Icons.block,
                    color: Colors.red,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ModerationScreen()),
                    ),
                  ),
                  StatsCard(
                    title: 'Événements',
                    value: stats.totalEvents.toString(),
                    subtitle: 'Total',
                    icon: Icons.event,
                    color: Colors.green,
                  ),
                  StatsCard(
                    title: 'Groupes',
                    value: stats.totalGroups.toString(),
                    subtitle: 'Actifs',
                    icon: Icons.groups,
                    color: Colors.purple,
                  ),
                  StatsCard(
                    title: 'Signalements',
                    value: stats.reportsToday.toString(),
                    subtitle: 'Aujourd\'hui',
                    icon: Icons.report,
                    color: stats.reportsToday > 0 ? Colors.red : Colors.grey,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ModerationScreen()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Actions rapides',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.person_add, color: Colors.white),
                      ),
                      title: const Text('Étudiants en attente'),
                      subtitle: Text('${stats.pendingUsers} à valider'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PendingStudentsScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.school, color: Colors.white),
                      ),
                      title: const Text('Gestion des délégués'),
                      subtitle: const Text('Assigner/révoquer'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ClassLeadersScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: stats.reportsToday > 0 ? Colors.red : Colors.grey,
                        child: const Icon(Icons.report_problem, color: Colors.white),
                      ),
                      title: const Text('Modération'),
                      subtitle: Text('${stats.reportsToday} signalements en attente'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ModerationScreen()),
                      ),
                    ),
                  ],
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
                onPressed: () => ref.invalidate(adminDashboardStatsProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
