import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/moderation_provider.dart';

class PendingVerificationsScreen extends ConsumerWidget {
  const PendingVerificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingVerificationsProvider);

    return pendingAsync.when(
      data: (verifications) {
        if (verifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_user,
                  size: 64,
                  color: Colors.green[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune vérification en attente',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: verifications.length,
          itemBuilder: (context, index) {
            final verification = verifications[index];
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
                          radius: 32,
                          backgroundImage: verification.profilePicture != null
                              ? NetworkImage(verification.profilePicture!)
                              : null,
                          child: verification.profilePicture == null
                              ? Text(
                                  '${verification.firstName?[0] ?? ''}${verification.lastName?[0] ?? ''}',
                                  style: const TextStyle(fontSize: 20),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${verification.firstName ?? ''} ${verification.lastName ?? ''}'.trim(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(verification.email ?? ''),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Méthode: ${verification.verificationMethod ?? 'inconnue'}',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // University Info
                    if (verification.university != null)
                      _buildInfoRow(Icons.school, 'Université', verification.university!),
                    if (verification.studentId != null)
                      _buildInfoRow(Icons.numbers, 'Numéro étudiant', verification.studentId!),
                    if (verification.universityEmail != null)
                      _buildInfoRow(Icons.email, 'Email universitaire', verification.universityEmail!),
                    if (verification.submittedAt != null)
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Soumis le',
                        verification.submittedAt!.substring(0, 10),
                      ),

                    // Documents
                    if (verification.documents != null && verification.documents!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Documents fournis:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: verification.documents!
                            .map((doc) => Chip(
                                  label: Text(doc),
                                  avatar: const Icon(Icons.description, size: 18),
                                ))
                            .toList(),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showRejectDialog(context, ref, verification),
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: const Text(
                            'Rejeter',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _verifyUser(context, ref, verification.userId),
                          icon: const Icon(Icons.verified),
                          label: const Text('Vérifier'),
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
              onPressed: () => ref.invalidate(pendingVerificationsProvider),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyUser(BuildContext context, WidgetRef ref, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vérifier l\'utilisateur ?'),
        content: const Text(
          'L\'utilisateur sera marqué comme vérifié et pourra accéder à toutes les fonctionnalités.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Vérifier'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(moderationActionsProvider.notifier).verifyUser(userId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur vérifié avec succès')),
        );
      }
    }
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref, dynamic verification) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeter la vérification ?'),
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
                verification.userId,
                reason: reasonController.text.isNotEmpty ? reasonController.text : null,
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vérification rejetée')),
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
