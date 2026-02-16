import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/message.dart';
import '../services/messaging_service.dart';
import '../providers/auth_provider.dart';
import '../utils/toast_service.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'main_navigation_screen.dart';

/// Écran de messages avec sidebar, contacts et chat intégré
class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final MessagingService _messagingService = MessagingService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Conversation> _allConversations = [];
  List<Conversation> _groups = [];
  List<Conversation> _peoples = [];
  String? _selectedConversationId;
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    // Rafraîchir toutes les 5 secondes
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        _loadConversations();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    try {
      final conversations = await _messagingService.getConversations(
        archived: false,
      );
      
      if (mounted) {
        setState(() {
          _allConversations = conversations;
          _groups = conversations.where((c) => c.conversationType == 'group').toList();
          _peoples = conversations.where((c) => c.conversationType == 'private').toList();
          _filterConversations();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ToastService.showError('Erreur lors du chargement');
      }
    }
  }

  void _filterConversations() {
    // La recherche filtre directement _groups et _peoples
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _groups = _allConversations.where((c) => c.conversationType == 'group').toList();
      _peoples = _allConversations.where((c) => c.conversationType == 'private').toList();
    } else {
      _groups = _allConversations.where((c) {
        return c.conversationType == 'group' &&
               _getConversationName(c).toLowerCase().contains(query);
      }).toList();
      _peoples = _allConversations.where((c) {
        return c.conversationType == 'private' &&
               _getConversationName(c).toLowerCase().contains(query);
      }).toList();
    }
  }

  String _getConversationName(Conversation conversation) {
    if (conversation.isPrivate && conversation.participants != null) {
      final otherParticipant = conversation.participants!.firstWhere(
        (p) => p.user.id != conversation.createdBy.id,
        orElse: () => conversation.participants!.first,
      );
      return otherParticipant.user.username;
    } else if (conversation.group != null) {
      return conversation.group!.name;
    }
    return conversation.name ?? 'Conversation';
  }

  String _getConversationDescription(Conversation conversation) {
    if (conversation.lastMessage != null) {
      final message = conversation.lastMessage!;
      // Si c'est une image, afficher "Image"
      if (message.messageType == 'image' || message.attachmentUrl != null) {
        return 'Image';
      }
      // Si c'est un fichier, afficher le nom du fichier
      if (message.messageType == 'file' && message.attachmentName != null) {
        return message.attachmentName!;
      }
      // Sinon, afficher le contenu du message
      return message.content;
    }
    return 'No messages yet';
  }

  String _getLastSeen(Conversation conversation) {
    if (conversation.lastMessageAt != null) {
      final now = DateTime.now();
      final lastMessage = conversation.lastMessageAt!;
      final difference = now.difference(lastMessage);
      
      if (difference.inDays == 0) {
        return DateFormat('h:mm a').format(lastMessage).toLowerCase();
      } else if (difference.inDays == 1) {
        return 'yesterday';
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE').format(lastMessage);
      } else {
        return DateFormat('MMM d').format(lastMessage);
      }
    }
    return '';
  }

  bool _isOnline(Conversation conversation) {
    // Pour l'instant, on simule avec les conversations privées
    // TODO: Implémenter la vérification réelle du statut en ligne
    return conversation.conversationType == 'private' && 
           conversation.lastMessageAt != null &&
           DateTime.now().difference(conversation.lastMessageAt!).inMinutes < 5;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isVerySmallScreen = screenWidth < 500; // Très petits écrans (mobile)
          final isSmallScreen = screenWidth < 800; // Petits écrans (tablette)
          
          // Sur très petits écrans, afficher seulement la liste ou le chat
          if (isVerySmallScreen) {
            if (_selectedConversationId != null) {
              return ChatScreen(
                conversationId: _selectedConversationId!,
                conversationName: _allConversations
                    .firstWhere((c) => c.id == _selectedConversationId)
                    .let((c) => _getConversationName(c)),
              );
            } else {
              return Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: _buildSidebar(context, user, isDark),
                  ),
                  Expanded(
                    child: Container(
                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      child: Column(
                        children: [
                          // Barre de recherche
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF5F5F5),
                              border: Border(
                                bottom: BorderSide(
                                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() => _filterConversations()),
                              style: GoogleFonts.inter(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: GoogleFonts.inter(
                                  color: isDark ? Colors.white54 : Colors.grey,
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: isDark ? Colors.white54 : Colors.grey,
                                  size: 20,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : _buildConversationsList(isDark),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          }
          
          // Sur petits écrans (500-800px), afficher sidebar + liste OU chat
          if (isSmallScreen) {
            if (_selectedConversationId != null) {
              return ChatScreen(
                conversationId: _selectedConversationId!,
                conversationName: _allConversations
                    .firstWhere((c) => c.id == _selectedConversationId)
                    .let((c) => _getConversationName(c)),
              );
            } else {
              return Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: _buildSidebar(context, user, isDark),
                  ),
                  Expanded(
                    child: Container(
                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF5F5F5),
                              border: Border(
                                bottom: BorderSide(
                                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() => _filterConversations()),
                              style: GoogleFonts.inter(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: GoogleFonts.inter(
                                  color: isDark ? Colors.white54 : Colors.grey,
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: isDark ? Colors.white54 : Colors.grey,
                                  size: 20,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : _buildConversationsList(isDark),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          }
          
          // Sur grands écrans (>= 800px), afficher les 3 panneaux
          // Calculer les largeurs de manière flexible
          final sidebarWidth = 70.0;
          final availableWidth = screenWidth - sidebarWidth;
          final centerWidth = (availableWidth * 0.4).clamp(250.0, 400.0); // Entre 250 et 400px
          
          return Row(
            children: [
              // Sidebar gauche
              SizedBox(
                width: sidebarWidth,
                child: _buildSidebar(context, user, isDark),
              ),
              
              // Panneau central (contacts et groupes)
              Container(
                width: centerWidth,
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                child: Column(
                  children: [
                    // Barre de recherche
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF5F5F5),
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() => _filterConversations()),
                        style: GoogleFonts.inter(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: GoogleFonts.inter(
                            color: isDark ? Colors.white54 : Colors.grey,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDark ? Colors.white54 : Colors.grey,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildConversationsList(isDark),
                    ),
                  ],
                ),
              ),
              
              // Panneau de chat (ou écran vide)
              Expanded(
                child: _selectedConversationId != null
                    ? ChatScreen(
                        conversationId: _selectedConversationId!,
                        conversationName: _allConversations
                            .firstWhere((c) => c.id == _selectedConversationId)
                            .let((c) => _getConversationName(c)),
                      )
                    : _buildEmptyChat(isDark),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, user, bool isDark) {
    return Container(
      width: 70,
      color: isDark ? const Color(0xFF000000) : const Color(0xFF4A90E2),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Photo de profil
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: user?.profile != null &&
                      user!.profile!['profile_picture'] != null &&
                      (user.profile!['profile_picture'] as String).isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: user.profile!['profile_picture'] as String,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(
                        user?.username.isNotEmpty == true
                            ? user.username[0].toUpperCase()
                            : 'U',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF4A90E2),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Icône Home
          _buildSidebarIcon(
            icon: Icons.home_outlined,
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
              );
            },
            isDark: isDark,
          ),
          
          // Icône Chat (active)
          _buildSidebarIcon(
            icon: Icons.chat_bubble_outline,
            isActive: true,
            onTap: () {},
            isDark: isDark,
          ),
          
          // Icône Add
          _buildSidebarIcon(
            icon: Icons.add_circle_outline,
            isActive: false,
            onTap: () {
              // TODO: Créer une nouvelle conversation
              ToastService.showInfo('Fonctionnalité à venir');
            },
            isDark: isDark,
          ),
          
          // Icône Settings
          _buildSidebarIcon(
            icon: Icons.settings_outlined,
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            isDark: isDark,
          ),
          
          const Spacer(),
          
          // Icône Logout
          _buildSidebarIcon(
            icon: Icons.logout,
            isActive: false,
            onTap: () async {
              final navigator = Navigator.of(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (!mounted) return;
              navigator.pushReplacementNamed('/login');
            },
            isDark: isDark,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSidebarIcon({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive
                  ? (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.3))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? (isDark ? Colors.white : Colors.white)
                  : (isDark ? Colors.white70 : Colors.white70),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationsList(bool isDark) {
    return ListView(
      children: [
        // Section Groups
        if (_groups.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Groups',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ),
          ..._groups.map((group) => _buildConversationItem(group, isDark)),
          if (_groups.length > 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'load more......',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF4A90E2),
                ),
              ),
            ),
        ],
        
        // Section Peoples
        if (_peoples.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Peoples',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ),
          ..._peoples.map((people) => _buildConversationItem(people, isDark)),
        ],
      ],
    );
  }

  Widget _buildConversationItem(Conversation conversation, bool isDark) {
    final name = _getConversationName(conversation);
    final description = _getConversationDescription(conversation);
    final lastSeen = _getLastSeen(conversation);
    final isOnline = _isOnline(conversation);
    final isSelected = _selectedConversationId == conversation.id;
    final hasUnread = conversation.unreadCount > 0;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedConversationId = conversation.id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE3F2FD))
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: conversation.conversationType == 'group'
                        ? const Color(0xFF4A90E2)
                        : const Color(0xFF4A90E2),
                  ),
                  child: conversation.conversationType == 'group'
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            // Deux icônes de personnes pour les groupes
                            Positioned(
                              left: 8,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            Positioned(
                              right: 8,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                ),
                if (isOnline && conversation.conversationType == 'private')
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
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
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lastSeen.isNotEmpty)
                        Text(
                          'last seen $lastSeen',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : Colors.grey[600],
                          ),
                        )
                      else if (isOnline)
                        Text(
                          'Online Now',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          description,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90E2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${conversation.unreadCount}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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

  Widget _buildEmptyChat(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF000000) : Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: isDark ? Colors.white38 : Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Select a conversation',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension NullableExtension<T> on T {
  R let<R>(R Function(T) function) => function(this);
}
