import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';
import '../services/messaging_service.dart';
import '../utils/app_colors.dart';
import 'chat_screen.dart';

/// Écran de liste des conversations
class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final MessagingService _messagingService = MessagingService();
  
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String _selectedTab = 'all'; // 'all', 'private', 'group'

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    
    try {
      String? type;
      if (_selectedTab == 'private') {
        type = 'private';
      } else if (_selectedTab == 'group') {
        type = 'group';
      }

      final conversations = await _messagingService.getConversations(
        type: type,
        archived: false,
      );
      
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      setState(() {
        _conversations = [];
        _isLoading = false;
      });
      
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
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ConversationSearchDelegate(_conversations),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs pour filtrer les conversations
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Tous',
                    isSelected: _selectedTab == 'all',
                    onTap: () {
                      setState(() => _selectedTab = 'all');
                      _loadConversations();
                    },
                  ),
                ),
                Expanded(
                  child: _TabButton(
                    label: 'Privés',
                    isSelected: _selectedTab == 'private',
                    onTap: () {
                      setState(() => _selectedTab = 'private');
                      _loadConversations();
                    },
                  ),
                ),
                Expanded(
                  child: _TabButton(
                    label: 'Groupes',
                    isSelected: _selectedTab == 'group',
                    onTap: () {
                      setState(() => _selectedTab = 'group');
                      _loadConversations();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Liste des conversations
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _conversations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune conversation',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadConversations,
                        child: ListView.builder(
                          itemCount: _conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = _conversations[index];
                            return _ConversationCard(
                              conversation: conversation,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      conversationId: conversation.id,
                                      conversationName: conversation.isPrivate
                                          ? conversation.participants
                                              ?.firstWhere(
                                                (p) => p.user.id != conversation.createdBy.id,
                                                orElse: () => conversation.participants!.first,
                                              )
                                              .user
                                              .username ??
                                              'Utilisateur'
                                          : conversation.name ?? conversation.group?.name ?? 'Groupe',
                                    ),
                                  ),
                                );
                              },
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

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String displayName = conversation.name ?? 'Conversation';
    if (conversation.isPrivate && conversation.participants != null) {
      // Pour les conversations privées, afficher le nom de l'autre participant
      final otherParticipant = conversation.participants!.firstWhere(
        (p) => p.user.id != conversation.createdBy.id,
        orElse: () => conversation.participants!.first,
      );
      displayName = otherParticipant.user.username;
    } else if (conversation.group != null) {
      displayName = conversation.group!.name;
    }

    String lastMessageText = 'Aucun message';
    DateTime? lastMessageDate;
    
    if (conversation.lastMessage != null) {
      lastMessageText = conversation.lastMessage!.content;
      if (lastMessageText.length > 50) {
        lastMessageText = '${lastMessageText.substring(0, 50)}...';
      }
      lastMessageDate = conversation.lastMessage!.createdAt;
    } else if (conversation.lastMessageAt != null) {
      lastMessageDate = conversation.lastMessageAt;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lastMessageDate != null)
                        Text(
                          _formatDate(lastMessageDate),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessageText,
                          style: TextStyle(
                            fontSize: 14,
                            color: conversation.hasUnreadMessages
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: conversation.hasUnreadMessages
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.hasUnreadMessages)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${conversation.unreadCount}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('dd MMM').format(date);
    }
  }
}

/// Délégué de recherche pour les conversations
class _ConversationSearchDelegate extends SearchDelegate<Conversation?> {
  final List<Conversation> conversations;

  _ConversationSearchDelegate(this.conversations);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = query.isEmpty
        ? conversations
        : conversations.where((conv) {
            final name = (conv.name ?? '').toLowerCase();
            final queryLower = query.toLowerCase();
            return name.contains(queryLower);
          }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Aucune conversation trouvée',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final conversation = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: conversation.conversationType == 'group'
                ? const Icon(Icons.group, color: AppColors.primary)
                : const Icon(Icons.person, color: AppColors.primary),
          ),
          title: Text(conversation.name ?? 'Conversation'),
          subtitle: conversation.lastMessage != null
              ? Text(
                  conversation.lastMessage!.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          onTap: () {
            close(context, conversation);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  conversationId: conversation.id,
                  conversationName: conversation.name ?? 'Conversation',
                ),
              ),
            );
          },
        );
      },
    );
  }
}

