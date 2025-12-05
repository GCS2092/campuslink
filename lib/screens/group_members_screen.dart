import 'package:flutter/material.dart';
import '../services/group_service.dart';
import '../utils/app_colors.dart';
import 'user_detail_screen.dart';

/// Écran affichant tous les membres d'un groupe
class GroupMembersScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupMembersScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  final GroupService _groupService = GroupService();
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      final members = await _groupService.getGroupMembers(widget.groupId);
      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading members: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Membres - ${widget.groupName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun membre',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMembers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _members.length,
                    itemBuilder: (context, index) {
                      final member = _members[index];
                      final user = member['user'] as Map<String, dynamic>? ?? {};
                      final role = member['role'] as String? ?? 'member';
                      final userId = user['id']?.toString() ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              user['username']?.toString().isNotEmpty == true
                                  ? user['username'][0].toUpperCase()
                                  : 'U',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                          title: Text(
                            '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim().isEmpty
                                ? user['username']?.toString() ?? 'Utilisateur'
                                : '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim(),
                          ),
                          subtitle: Text(user['email']?.toString() ?? ''),
                          trailing: role == 'admin' || role == 'moderator'
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: role == 'admin'
                                        ? AppColors.error.withValues(alpha: 0.1)
                                        : AppColors.warning.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    role == 'admin' ? 'Admin' : 'Modérateur',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: role == 'admin' ? AppColors.error : AppColors.warning,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            if (userId.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetailScreen(userId: userId),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

