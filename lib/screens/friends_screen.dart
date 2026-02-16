import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/messaging_service.dart';
import '../utils/app_colors.dart';
import '../utils/premium_design.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Mes Amis',
          style: PremiumDesign.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _friends.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: isDark ? Colors.white38 : AppColors.textSecondary,
                      ),
                      const SizedBox(height: PremiumDesign.spacingL),
                      Text(
                        'Aucun ami',
                        style: PremiumDesign.titleMedium.copyWith(
                          color: isDark ? Colors.white60 : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: PremiumDesign.spacingXS),
                      Text(
                        'Ajoutez des amis pour commencer',
                        style: PremiumDesign.bodySmall.copyWith(
                          color: isDark ? Colors.white38 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFriends,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PremiumDesign.spacingL,
                      vertical: PremiumDesign.spacingM,
                    ),
                    itemCount: _friends.length,
                    itemBuilder: (context, index) {
                      final friend = _friends[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: PremiumDesign.spacingS),
                        child: PremiumCard(
                          padding: const EdgeInsets.all(PremiumDesign.spacingM),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserDetailScreen(userId: friend.id)),
                            );
                          },
                          child: Row(
                            children: [
                              // Avatar premium
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: PremiumDesign.primaryGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: PremiumDesign.shadowSmall,
                                ),
                                child: Center(
                                  child: Text(
                                    friend.username.isNotEmpty
                                        ? friend.username[0].toUpperCase()
                                        : 'U',
                                    style: PremiumDesign.titleLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: PremiumDesign.spacingM),
                              // Informations
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      friend.fullName,
                                      style: PremiumDesign.titleMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: PremiumDesign.spacingXS),
                                    Text(
                                      '@${friend.username}',
                                      style: PremiumDesign.bodySmall.copyWith(
                                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Bouton message premium
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: PremiumDesign.primaryGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: PremiumDesign.shadowSmall,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.message, color: Colors.white, size: 20),
                                  onPressed: () => _handleStartConversation(friend.id, friend.username),
                                  tooltip: 'Message',
                                ),
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

