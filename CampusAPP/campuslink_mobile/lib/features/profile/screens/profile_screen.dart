import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileNotifierProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: profileState.isLoading && profileState.user == null
          ? const Center(child: CircularProgressIndicator())
          : profileState.error != null && profileState.user == null
              ? _buildError(profileState.error!)
              : profileState.user != null
                  ? _buildProfile(profileState.user!)
                  : _buildEmpty(),
    );
  }

  Widget _buildProfile(User user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header with cover and avatar
          Stack(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[300],
                child: user.profile?.coverPicture != null
                    ? Image.network(
                        user.profile!.coverPicture!,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: user.profile?.profilePicture != null
                        ? NetworkImage(user.profile!.profilePicture!)
                        : null,
                    child: user.profile?.profilePicture == null
                        ? Text(
                            user.username.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 32),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          // User info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim().isNotEmpty
                      ? '${user.firstName} ${user.lastName}'
                      : user.username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${user.username}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                if (user.profile?.bio != null && user.profile!.bio!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(user.profile!.bio!),
                ],
                const SizedBox(height: 16),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat('Publications', user.profile?.followersCount ?? 0),
                    _buildStat('Abonnés', user.profile?.followersCount ?? 0),
                    _buildStat('Abonnements', user.profile?.followingCount ?? 0),
                    _buildStat('Amis', user.profile?.friendsCount ?? 0),
                  ],
                ),
                const SizedBox(height: 24),
                // Info section
                _buildInfoSection(user),
                const SizedBox(height: 24),
                // Actions
                _buildActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (user.profile?.university != null)
          _buildInfoRow(Icons.school, user.profile!.university!),
        if (user.profile?.department != null)
          _buildInfoRow(Icons.book, user.profile!.department!),
        if (user.profile?.academicYear != null)
          _buildInfoRow(Icons.calendar_today, 'Promotion ${user.profile!.academicYear!}'),
        if (user.profile?.website != null)
          _buildInfoRow(Icons.link, user.profile!.website!),
        _buildInfoRow(Icons.email, user.email),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => context.push('${AppRoutes.profile}/edit'),
          icon: const Icon(Icons.edit),
          label: const Text('Modifier le profil'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showFriends(context),
          icon: const Icon(Icons.people),
          label: const Text('Mes amis'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showFriendRequests(context),
          icon: const Icon(Icons.person_add),
          label: const Text('Demandes d\'ami'),
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: () => _confirmLogout(context),
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text(
            'Déconnexion',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(profileNotifierProvider.notifier).loadProfile();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text('Aucun profil trouvé'),
    );
  }

  void _showSettings(BuildContext context) {
    // Navigate to settings
  }

  void _showFriends(BuildContext context) {
    // Navigate to friends list
  }

  void _showFriendRequests(BuildContext context) {
    // Navigate to friend requests
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              context.go(AppRoutes.login);
            },
            child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
