import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/moderation_model.dart';
import '../providers/moderation_provider.dart';

class BannedUsersScreen extends ConsumerWidget {
  const BannedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannedUsersAsync = ref.watch(bannedUsersProvider);

    return bannedUsersAsync.when(
      data: (users) {
        if (users.isEmpty) {
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
                  'Aucun utilisateur banni',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tous les utilisateurs respectent les règles',
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
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final isPermanent = user.bannedUntil == null;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: user.profilePicture != null
                          ? NetworkImage(user.profilePicture!)
                          : null,
                      child: user.profilePicture == null
                          ? Text(
                              '${user.firstName?[0] ?? ''}${user.lastName?[0] ?? ''}',
                              style: const TextStyle(fontSize: 18),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.block,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(user.email ?? user.username ?? ''),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPermanent ? Colors.red[100] : Colors.orange[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isPermanent
                            ? 'Bannissement permanent'
                            : 'Jusqu\'au: ${user.bannedUntil!.substring(0, 10)}',
                        style: TextStyle(
                          color: isPermanent ? Colors.red[700] : Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (user.banReason != null && user.banReason!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Raison: ${user.banReason}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Banni par: ${user.bannedByName ?? 'Admin'}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
                trailing: ElevatedButton.icon(
                  onPressed: () => _showUnbanDialog(context, ref, user),
                  icon: const Icon(Icons.restore),
                  label: const Text('Débannir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
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
              onPressed: () => ref.invalidate(bannedUsersProvider),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnbanDialog(BuildContext context, WidgetRef ref, BannedUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Débannir ${user.firstName ?? user.username} ?'),
        content: const Text(
          'L\'utilisateur pourra à nouveau accéder à l\'application.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(moderationActionsProvider.notifier).unbanUser(user.userId);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Utilisateur débanni')),
                );
              }
            },
            child: const Text('Débannir'),
          ),
        ],
      ),
    );
  }
}
