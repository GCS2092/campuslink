import 'package:flutter/material.dart';
import '../models/group.dart';
import '../services/group_service.dart';
import '../services/messaging_service.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import 'chat_screen.dart';
import 'group_members_screen.dart';

/// Écran de détails d'un groupe
class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GroupService _groupService = GroupService();
  final MessagingService _messagingService = MessagingService();
  
  Group? _group;
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;
  bool _isLoadingMembers = false;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    setState(() => _isLoading = true);
    
    try {
      final group = await _groupService.getGroup(widget.groupId);
      setState(() {
        _group = group;
        _isLoading = false;
      });
      
      if (group != null) {
        _loadMembers();
      }
    } catch (e) {
      debugPrint('Error loading group: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _loadMembers() async {
    if (_group == null) return;
    
    setState(() => _isLoadingMembers = true);
    try {
      final members = await _groupService.getGroupMembers(_group!.id);
      setState(() {
        _members = members;
        _isLoadingMembers = false;
      });
    } catch (e) {
      debugPrint('Error loading members: $e');
      setState(() => _isLoadingMembers = false);
    }
  }

  Future<void> _handleJoinGroup() async {
    if (_group == null) return;

    setState(() => _isJoining = true);
    try {
      final result = await _groupService.joinGroup(_group!.id);
      
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Groupe rejoint !'),
              backgroundColor: AppColors.success,
            ),
          );
          await _loadGroup();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Erreur lors de la participation'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error joining group: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  Future<void> _handleOpenChat() async {
    if (_group == null) return;

    try {
      final conversation = await _messagingService.getGroupConversation(_group!.id);
      
      if (mounted && conversation != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversation.id,
              conversationName: _group!.name,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting group conversation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMember = _group?.userRole != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Groupe'),
        actions: [
          if (isMember)
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: _handleOpenChat,
              tooltip: 'Ouvrir le chat',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _group == null
              ? const Center(child: Text('Groupe non trouvé'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image de couverture
                      if (_group!.coverImage != null && _group!.coverImage!.isNotEmpty)
                        Image.network(
                          _group!.coverImage!.startsWith('http')
                              ? _group!.coverImage!
                              : '${AppConstants.apiBaseUrl.replaceAll('/api', '')}${_group!.coverImage}',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: AppColors.border,
                              child: const Icon(Icons.group, size: 64, color: AppColors.textSecondary),
                            );
                          },
                        ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Titre
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _group!.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (_group!.isVerified)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified, size: 16, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          'Vérifié',
                                          style: TextStyle(
                                            fontSize: 12,
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

                            // Créateur
                            Row(
                              children: [
                                const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  'Créé par ${_group!.creator.fullName}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Description
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _group!.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Statistiques
                            Row(
                              children: [
                                Expanded(
                                  child: _StatItem(
                                    icon: Icons.people,
                                    label: 'Membres',
                                    value: '${_group!.membersCount}',
                                  ),
                                ),
                                Expanded(
                                  child: _StatItem(
                                    icon: Icons.article,
                                    label: 'Posts',
                                    value: '${_group!.postsCount}',
                                  ),
                                ),
                                Expanded(
                                  child: _StatItem(
                                    icon: Icons.event,
                                    label: 'Événements',
                                    value: '${_group!.eventsCount}',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Membres
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Membres',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GroupMembersScreen(
                                          groupId: widget.groupId,
                                          groupName: _group?.name ?? 'Groupe',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Voir tout'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _isLoadingMembers
                                ? const Center(child: CircularProgressIndicator())
                                : _members.isEmpty
                                    ? const Text('Aucun membre')
                                    : SizedBox(
                                        height: 80,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _members.length > 10 ? 10 : _members.length,
                                          itemBuilder: (context, index) {
                                            final member = _members[index];
                                            final user = member['user'] ?? {};
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 12),
                                              child: Column(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 25,
                                                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                                    child: Text(
                                                      (user['username'] ?? 'U')[0].toUpperCase(),
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.primary,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  SizedBox(
                                                    width: 50,
                                                    child: Text(
                                                      user['username'] ?? '',
                                                      style: const TextStyle(fontSize: 10),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                            const SizedBox(height: 24),

                            // Bouton d'action
                            if (!isMember)
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isJoining ? null : _handleJoinGroup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isJoining
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Rejoindre le groupe',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _handleOpenChat,
                                      icon: const Icon(Icons.message),
                                      label: const Text('Ouvrir le chat'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.secondary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Quitter le groupe'),
                                            content: const Text('Êtes-vous sûr de vouloir quitter ce groupe ?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Annuler'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text('Quitter', style: TextStyle(color: AppColors.error)),
                                              ),
                                            ],
                                          ),
                                        );
                                        
                                        if (confirmed == true && mounted) {
                                          final result = await _groupService.leaveGroup(widget.groupId);
                                          if (result['success'] == true) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Groupe quitté avec succès'),
                                                  backgroundColor: AppColors.success,
                                                ),
                                              );
                                              Navigator.pop(context);
                                            }
                                          } else {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(result['error'] ?? 'Erreur'),
                                                  backgroundColor: AppColors.error,
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.exit_to_app),
                                      label: const Text('Quitter'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

