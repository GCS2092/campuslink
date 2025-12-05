import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../utils/app_colors.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final UserService _userService = UserService();
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await _userService.getFriendRequests();
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading friend requests: $e');
      setState(() {
        _requests = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAccept(String friendshipId) async {
    try {
      final result = await _userService.acceptFriendRequest(friendshipId);
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Demande acceptée'), backgroundColor: AppColors.success),
          );
          await _loadRequests();
        }
      }
    } catch (e) {
      debugPrint('Error accepting request: $e');
    }
  }

  Future<void> _handleReject(String friendshipId) async {
    try {
      final result = await _userService.rejectFriendRequest(friendshipId);
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Demande rejetée'), backgroundColor: AppColors.success),
          );
          await _loadRequests();
        }
      }
    } catch (e) {
      debugPrint('Error rejecting request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demandes d\'ami'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_outlined, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune demande',
                        style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      final fromUser = request['from_user'] ?? {};
                      final friendshipId = request['id']?.toString() ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              (fromUser['username'] ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                          title: Text(
                            '${fromUser['first_name'] ?? ''} ${fromUser['last_name'] ?? ''}'.trim().isEmpty
                                ? fromUser['username'] ?? 'Utilisateur'
                                : '${fromUser['first_name']} ${fromUser['last_name']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('@${fromUser['username'] ?? ''}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: AppColors.success),
                                onPressed: () => _handleAccept(friendshipId),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: AppColors.error),
                                onPressed: () => _handleReject(friendshipId),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

