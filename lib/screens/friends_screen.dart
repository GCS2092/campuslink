import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/messaging_service.dart';
import '../utils/app_colors.dart';
import 'user_detail_screen.dart';
import 'chat_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final UserService _userService = UserService();
  final MessagingService _messagingService = MessagingService();
  List<User> _friends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);
    try {
      final friends = await _userService.getFriends();
      setState(() {
        _friends = friends;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading friends: $e');
      setState(() {
        _friends = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleStartConversation(String userId, String username) async {
    try {
      final conversation = await _messagingService.createPrivateConversation(userId);
      if (mounted && conversation != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversationId: conversation.id, conversationName: username),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating conversation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Amis'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _friends.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun ami',
                        style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFriends,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _friends.length,
                    itemBuilder: (context, index) {
                      final friend = _friends[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              friend.username[0].toUpperCase(),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                          title: Text(friend.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('@${friend.username}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.message),
                            onPressed: () => _handleStartConversation(friend.id, friend.username),
                            tooltip: 'Message',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserDetailScreen(userId: friend.id)),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

