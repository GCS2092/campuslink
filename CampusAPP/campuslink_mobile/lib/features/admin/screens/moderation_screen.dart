import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/moderation_model.dart';
import '../providers/moderation_provider.dart';
import 'banned_users_screen.dart';
import 'pending_verifications_screen.dart';

class ModerationScreen extends ConsumerStatefulWidget {
  const ModerationScreen({super.key});

  @override
  ConsumerState<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends ConsumerState<ModerationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modération'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.report), text: 'Signalements'),
            Tab(icon: Icon(Icons.block), text: 'Bannis'),
            Tab(icon: Icon(Icons.verified_user), text: 'Vérifications'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportsTab(),
          const BannedUsersScreen(),
          const PendingVerificationsScreen(),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    final reportsAsync = ref.watch(reportsProvider(ReportFilter(status: _selectedStatus)));

    return Column(
      children: [
        // Status Filter
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'pending', label: Text('En attente')),
              ButtonSegment(value: 'resolved', label: Text('Résolus')),
              ButtonSegment(value: 'all', label: Text('Tous')),
            ],
            selected: {_selectedStatus},
            onSelectionChanged: (value) {
              setState(() {
                _selectedStatus = value.first;
              });
            },
          ),
        ),

        // Reports List
        Expanded(
          child: reportsAsync.when(
            data: (reports) {
              if (reports.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Colors.green[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun signalement',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return _buildReportCard(report);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: $err'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(Report report) {
    final Color statusColor = report.status == 'pending' ? Colors.orange : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(report.type),
                  backgroundColor: _getTypeColor(report.type),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(report.status),
                  backgroundColor: statusColor.withValues(alpha: 0.2),
                  labelStyle: TextStyle(color: statusColor, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  report.createdAt?.substring(0, 10) ?? '',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Reporter and Reported
            Row(
              children: [
                Expanded(
                  child: _buildUserInfo(
                    'Signalé par',
                    report.reporterName ?? 'Inconnu',
                    report.reporterAvatar,
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                Expanded(
                  child: _buildUserInfo(
                    'Utilisateur signalé',
                    report.reportedUserName ?? 'Inconnu',
                    report.reportedUserAvatar,
                    isRight: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Reason
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Raison: ${report.reason}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (report.description != null && report.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(report.description!),
                  ],
                ],
              ),
            ),

            // Content Preview
            if (report.contentPreview != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contenu signalé (${report.contentType ?? 'inconnu'}):',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.contentPreview!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],

            // Actions
            if (report.status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showResolveDialog(report, 'dismissed'),
                    icon: const Icon(Icons.close, color: Colors.grey),
                    label: const Text('Rejeter', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showResolveDialog(report, 'resolved'),
                    icon: const Icon(Icons.check),
                    label: const Text('Résoudre'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(String label, String name, String? avatar, {bool isRight = false}) {
    return Row(
      mainAxisAlignment: isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isRight) ...[
          CircleAvatar(
            radius: 16,
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null ? Text(name[0].toUpperCase()) : null,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (isRight) ...[
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null ? Text(name[0].toUpperCase()) : null,
          ),
        ],
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'spam':
        return Colors.orange;
      case 'harassment':
        return Colors.red;
      case 'inappropriate':
        return Colors.purple;
      case 'fake':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showResolveDialog(Report report, String action) {
    final notesController = TextEditingController();
    final isBan = action == 'resolved' && report.type.toLowerCase() == 'harassment';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action == 'resolved' ? 'Résoudre le signalement' : 'Rejeter le signalement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                hintText: 'Notes du modérateur (optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            if (isBan) ...[
              const SizedBox(height: 16),
              const Text(
                '⚠️ Cette action pourrait nécessiter un bannissement de l\'utilisateur.',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          if (isBan)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                _showBanDialog(report.reportedUserId, report.reportedUserName);
              },
              child: const Text('Bannir l\'utilisateur', style: TextStyle(color: Colors.red)),
            ),
          ElevatedButton(
            onPressed: () async {
              final dialogContext = context;
              final nav = Navigator.of(dialogContext);
              final messenger = ScaffoldMessenger.of(dialogContext);
              await ref.read(moderationActionsProvider.notifier).resolveReport(
                report.id,
                action,
                notes: notesController.text.isNotEmpty ? notesController.text : null,
              );
              nav.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('Signalement traité')),
              );
            },
            child: Text(action == 'resolved' ? 'Résoudre' : 'Rejeter'),
          ),
        ],
      ),
    );
  }

  void _showBanDialog(String userId, String? userName) {
    final reasonController = TextEditingController();
    final daysController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Bannir ${userName ?? "l'utilisateur"} ?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Raison du bannissement',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: daysController,
              decoration: const InputDecoration(
                labelText: 'Durée (jours, vide = permanent)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final dialogContext = context;
              final nav = Navigator.of(dialogContext);
              final messenger = ScaffoldMessenger.of(dialogContext);
              final days = daysController.text.isNotEmpty
                  ? int.tryParse(daysController.text)
                  : null;
              await ref.read(moderationActionsProvider.notifier).banUser(
                userId,
                reason: reasonController.text.isNotEmpty ? reasonController.text : null,
                days: days,
              );
              nav.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('Utilisateur banni')),
              );
            },
            child: const Text('Bannir'),
          ),
        ],
      ),
    );
  }
}
