import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/group.dart';
import '../services/group_service.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import 'group_detail_screen.dart';
import 'create_group_screen.dart';

/// Écran de liste des groupes
class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final GroupService _groupService = GroupService();
  
  List<Group> _groups = [];
  List<Map<String, dynamic>> _invitations = [];
  bool _isLoading = true;
  bool _isLoadingInvitations = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadGroups();
    _loadInvitations();
  }

  Future<void> _loadGroups() async {
    setState(() => _isLoading = true);
    
    try {
      final groups = await _groupService.getGroups(
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      
      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading groups: $e');
      setState(() {
        _groups = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _loadInvitations() async {
    setState(() => _isLoadingInvitations = true);
    try {
      final invitations = await _groupService.getMyInvitations();
      setState(() {
        _invitations = invitations;
        _isLoadingInvitations = false;
      });
    } catch (e) {
      debugPrint('Error loading invitations: $e');
      setState(() => _isLoadingInvitations = false);
    }
  }

  Future<void> _handleAcceptInvitation(String groupId) async {
    try {
      final result = await _groupService.acceptInvitation(groupId);
      
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invitation acceptée'),
              backgroundColor: AppColors.success,
            ),
          );
          await _loadInvitations();
          await _loadGroups();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Erreur'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error accepting invitation: $e');
    }
  }

  Future<void> _handleRejectInvitation(String groupId) async {
    try {
      final result = await _groupService.rejectInvitation(groupId);
      
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invitation rejetée'),
              backgroundColor: AppColors.success,
            ),
          );
          await _loadInvitations();
        }
      }
    } catch (e) {
      debugPrint('Error rejecting invitation: $e');
    }
  }

  Future<void> _handleJoinGroup(String groupId) async {
    try {
      final result = await _groupService.joinGroup(groupId);
      
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Groupe rejoint'),
              backgroundColor: AppColors.success,
            ),
          );
          await _loadGroups();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Erreur'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error joining group: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final canCreateGroup = user != null && 
                          user.isVerified && 
                          !user.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groupes'),
        actions: [
          if (canCreateGroup)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateGroupScreen(),
                  ),
                ).then((_) => _loadGroups());
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un groupe...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                          _loadGroups();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onSubmitted: (value) {
                setState(() => _searchQuery = value);
                _loadGroups();
              },
            ),
          ),

          // Invitations
          if (_isLoadingInvitations)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
          else if (_invitations.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.warning.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.mail, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_invitations.length} invitation(s) en attente',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _invitations.length,
                itemBuilder: (context, index) {
                  final invitation = _invitations[index];
                  final group = invitation['group'];
                  if (group == null) return const SizedBox();
                  
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group['name'] ?? 'Groupe',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _handleAcceptInvitation(group['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                ),
                                child: const Text('Accepter', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _handleRejectInvitation(group['id']),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                ),
                                child: const Text('Rejeter', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],

          // Liste des groupes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _groups.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.group_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun groupe trouvé',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadGroups,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _groups.length,
                          itemBuilder: (context, index) {
                            final group = _groups[index];
                            return _GroupCard(
                              group: group,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GroupDetailScreen(groupId: group.id),
                                  ),
                                );
                              },
                              onJoin: () => _handleJoinGroup(group.id),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;
  final VoidCallback onJoin;

  const _GroupCard({
    required this.group,
    required this.onTap,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de couverture
            if (group.coverImage != null && group.coverImage!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  group.coverImage!.startsWith('http')
                      ? group.coverImage!
                      : '${AppConstants.apiBaseUrl.replaceAll('/api', '')}${group.coverImage}',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: AppColors.border,
                      child: const Icon(Icons.group, size: 64, color: AppColors.textSecondary),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et badge vérifié
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (group.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Vérifié',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    group.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Statistiques
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${group.membersCount} membres',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.article, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${group.postsCount} posts',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Bouton d'action
                  if (group.userRole == null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onJoin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Rejoindre'),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, color: AppColors.success, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Membre',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

