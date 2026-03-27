import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../providers/moderation_provider.dart';

class PendingStudentsScreen extends ConsumerWidget {
  const PendingStudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingStudentsAsync = ref.watch(pendingStudentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Étudiants en attente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(pendingStudentsProvider),
          ),
        ],
      ),
      body: pendingStudentsAsync.when(
        data: (students) {
          if (students.isEmpty) {
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
                    'Aucun étudiant en attente',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tous les étudiants sont activés',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Text(
                              '${student.firstName?.substring(0, 1) ?? ''}${student.lastName?.substring(0, 1) ?? ''}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${student.firstName ?? ''} ${student.lastName ?? ''}'.trim(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  student.email,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(
                              student.verificationStatus ?? 'pending',
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.orange[100],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (student.university != null)
                        _buildInfoRow(Icons.school, student.university!),
                      if (student.department != null)
                        _buildInfoRow(Icons.business, student.department!),
                      if (student.studentId != null)
                        _buildInfoRow(Icons.numbers, 'ID: ${student.studentId}'),
                      if (student.registrationDate != null)
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Inscrit le: ${student.registrationDate!.substring(0, 10)}',
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _showRejectDialog(context, ref, student),
                            icon: const Icon(Icons.close, color: Colors.red),
                            label: const Text(
                              'Rejeter',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _activateStudent(context, ref, student.id),
                            icon: const Icon(Icons.check),
                            label: const Text('Activer'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(pendingStudentsProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _activateStudent(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activer l\'étudiant ?'),
        content: const Text('L\'étudiant pourra accéder à l\'application après activation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Activer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(adminActionsProvider.notifier).activateStudent(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Étudiant activé avec succès')),
        );
      }
    }
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref, dynamic student) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeter l\'inscription ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Veuillez indiquer la raison du rejet :'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Raison du rejet',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              await ref.read(moderationActionsProvider.notifier).rejectUser(
                student.id,
                reason: reasonController.text.isNotEmpty ? reasonController.text : null,
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Inscription rejetée')),
                );
              }
            },
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }
}
