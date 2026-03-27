import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';

class ClassLeadersScreen extends ConsumerWidget {
  const ClassLeadersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classLeadersAsync = ref.watch(classLeadersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des délégués'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(classLeadersProvider),
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAssignDialog(context, ref),
          ),
        ],
      ),
      body: classLeadersAsync.when(
        data: (leaders) {
          if (leaders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun délégué assigné',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Appuyez sur + pour assigner un délégué',
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
            itemCount: leaders.length,
            itemBuilder: (context, index) {
              final leader = leaders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: leader.profilePicture != null
                        ? NetworkImage(leader.profilePicture!)
                        : null,
                    child: leader.profilePicture == null
                        ? Text(
                            '${leader.firstName?[0] ?? ''}${leader.lastName?[0] ?? ''}',
                            style: const TextStyle(fontSize: 18),
                          )
                        : null,
                  ),
                  title: Text(
                    '${leader.firstName ?? ''} ${leader.lastName ?? ''}'.trim(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(leader.email ?? leader.username ?? ''),
                      const SizedBox(height: 4),
                      if (leader.university != null)
                        Text(
                          leader.university!,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      if (leader.department != null)
                        Text(
                          leader.department!,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      if (leader.assignedAt != null)
                        Text(
                          'Assigné le: ${leader.assignedAt!.substring(0, 10)}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 11),
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'revoke') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Révoquer le rôle ?'),
                            content: Text(
                              'Voulez-vous retirer le rôle de délégué à ${leader.firstName ?? leader.username} ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Révoquer'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await ref.read(adminActionsProvider.notifier).revokeClassLeader(leader.userId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Rôle de délégué révoqué')),
                            );
                          }
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'revoke',
                        child: Row(
                          children: [
                            Icon(Icons.remove_circle, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Révoquer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
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
                onPressed: () => ref.invalidate(classLeadersProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignDialog(BuildContext context, WidgetRef ref) {
    final userIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assigner un délégué'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Entrez l\'ID de l\'utilisateur à nommer délégué :'),
            const SizedBox(height: 16),
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                hintText: 'ID utilisateur',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (userIdController.text.isNotEmpty) {
                await ref.read(adminActionsProvider.notifier).assignClassLeader(userIdController.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Délégué assigné avec succès')),
                  );
                }
              }
            },
            child: const Text('Assigner'),
          ),
        ],
      ),
    );
  }
}
