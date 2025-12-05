import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../utils/app_colors.dart';
import '../user_detail_screen.dart';

/// Écran de gestion des responsables de classe pour les administrateurs globaux
class AdminClassLeadersScreen extends StatefulWidget {
  const AdminClassLeadersScreen({super.key});

  @override
  State<AdminClassLeadersScreen> createState() => _AdminClassLeadersScreenState();
}

class _AdminClassLeadersScreenState extends State<AdminClassLeadersScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _classLeaders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClassLeaders();
  }

  Future<void> _loadClassLeaders() async {
    setState(() => _isLoading = true);
    try {
      final leaders = await _adminService.getClassLeaders();
      setState(() {
        _classLeaders = leaders;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading class leaders: $e');
      setState(() {
        _classLeaders = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAssignClassLeader(String userId) async {
    try {
      final result = await _adminService.assignClassLeader(userId);
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Responsable assigné'), backgroundColor: AppColors.success),
          );
          _loadClassLeaders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'Erreur'), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      debugPrint('Error assigning class leader: $e');
    }
  }

  Future<void> _handleRevokeClassLeader(String userId) async {
    try {
      final result = await _adminService.revokeClassLeader(userId);
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Responsable révoqué'), backgroundColor: AppColors.success),
          );
          _loadClassLeaders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'Erreur'), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      debugPrint('Error revoking class leader: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Responsables de Classe')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classLeaders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun responsable de classe',
                        style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadClassLeaders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _classLeaders.length,
                    itemBuilder: (context, index) {
                      final leader = _classLeaders[index];
                      final isClassLeader = leader['role'] == 'class_leader';
                      return _ClassLeaderCard(
                        leader: leader,
                        isClassLeader: isClassLeader,
                        onAssign: isClassLeader ? null : () => _handleAssignClassLeader(leader['id'].toString()),
                        onRevoke: isClassLeader ? () => _handleRevokeClassLeader(leader['id'].toString()) : null,
                        onView: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDetailScreen(userId: leader['id'].toString()),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _ClassLeaderCard extends StatelessWidget {
  final Map<String, dynamic> leader;
  final bool isClassLeader;
  final VoidCallback? onAssign;
  final VoidCallback? onRevoke;
  final VoidCallback onView;

  const _ClassLeaderCard({
    required this.leader,
    required this.isClassLeader,
    this.onAssign,
    this.onRevoke,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final username = leader['username'] ?? 'N/A';
    final email = leader['email'] ?? 'N/A';
    final firstName = leader['first_name'] ?? '';
    final lastName = leader['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim().isEmpty ? username : '$firstName $lastName';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                    child: Text(
                      username[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isClassLeader)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Responsable',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                ],
              ),
              if (onAssign != null || onRevoke != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onAssign != null)
                      ElevatedButton.icon(
                        onPressed: onAssign,
                        icon: const Icon(Icons.person_add, size: 18),
                        label: const Text('Assigner'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    if (onRevoke != null) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: onRevoke,
                        icon: const Icon(Icons.person_remove, size: 18),
                        label: const Text('Révoquer'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

