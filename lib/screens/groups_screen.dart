import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/group.dart';
import '../services/group_service.dart';
import '../utils/app_colors.dart';
import '../utils/toast_service.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/offline_indicator.dart';
import 'group_detail_screen.dart';
import 'create_group_screen.dart';

/// Écran de liste des groupes - Design identique à l'image fournie
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
  final bool _isOffline = false;
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
      
      if (mounted) {
        setState(() {
          _groups = groups;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading groups: $e');
      if (mounted) {
        setState(() {
          _groups = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadInvitations() async {
    setState(() => _isLoadingInvitations = true);
    try {
      final invitations = await _groupService.getMyInvitations();
      if (mounted) {
        setState(() {
          _invitations = invitations;
          _isLoadingInvitations = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading invitations: $e');
      if (mounted) {
        setState(() => _isLoadingInvitations = false);
      }
    }
  }

  Future<void> _handleAcceptInvitation(String groupId) async {
    HapticFeedback.lightImpact();
    
    try {
      final result = await _groupService.acceptInvitation(groupId);
      
      if (!mounted) return;
      if (result['success'] == true) {
        ToastService.showSuccess('Invitation acceptée');
        await _loadInvitations();
        await _loadGroups();
      } else {
        ToastService.showError(result['error'] ?? 'Erreur');
      }
    } catch (e) {
      debugPrint('Error accepting invitation: $e');
      if (mounted) {
        ToastService.showError('Erreur lors de l\'acceptation');
      }
    }
  }

  Future<void> _handleRejectInvitation(String groupId) async {
    HapticFeedback.selectionClick();
    
    try {
      final result = await _groupService.rejectInvitation(groupId);
      
      if (!mounted) return;
      if (result['success'] == true) {
        ToastService.showSuccess('Invitation rejetée');
        await _loadInvitations();
      }
    } catch (e) {
      debugPrint('Error rejecting invitation: $e');
    }
  }

  Future<void> _handleJoinGroup(String groupId) async {
    HapticFeedback.mediumImpact();
    
    try {
      final result = await _groupService.joinGroup(groupId);
      
      if (!mounted) return;
      if (result['success'] == true) {
        ToastService.showSuccess('Groupe rejoint');
        await _loadGroups();
      } else {
        ToastService.showError(result['error'] ?? 'Erreur');
      }
    } catch (e) {
      debugPrint('Error joining group: $e');
      if (mounted) {
        ToastService.showError('Erreur lors de la jointure');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final canCreateGroup = user != null && 
                          user.isVerified && 
                          !user.isAdmin && 
                          !user.isUniversityAdmin && 
                          !(user.isStaff ?? false);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Groupes',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          if (canCreateGroup)
            Container(
              margin: const EdgeInsets.only(right: 16),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateGroupScreen(),
                      ),
                    ).then((_) => _loadGroups());
                  },
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Indicateur de mode hors ligne
          OfflineIndicator(isOffline: _isOffline),
          
          // Barre de recherche - Style identique à l'image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF1A1A1A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un groupe...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() => _searchQuery = '');
                                  _loadGroups();
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                        _loadGroups();
                      },
                      onSubmitted: (value) {
                        setState(() => _searchQuery = value);
                        _loadGroups();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Invitations (si présentes) - Section horizontale scrollable
          if (!_isLoadingInvitations && _invitations.isNotEmpty) ...[
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _invitations.length,
                itemBuilder: (context, index) {
                  final invitation = _invitations[index];
                  final group = invitation['group'];
                  if (group == null) return const SizedBox();
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            group['name'] ?? 'Groupe',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _handleAcceptInvitation(group['id']),
                                  child: Container(
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Accepter',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _handleRejectInvitation(group['id']),
                                  child: Container(
                                    height: 32,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Rejeter',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Liste des groupes
          Expanded(
            child: _isLoading
                ? _GroupsSkeletonLoader(isDark: isDark)
                : _groups.isEmpty
                    ? _EmptyState(isDark: isDark)
                    : RefreshIndicator(
                        onRefresh: _loadGroups,
                        color: const Color(0xFF6366F1),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: _groups.length,
                          itemBuilder: (context, index) {
                            final group = _groups[index];
                            return _GroupCard(
                              group: group,
                              isDark: isDark,
                              index: index,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GroupDetailScreen(groupId: group.id),
                                  ),
                                );
                              },
                              onJoin: () => _handleJoinGroup(group.id),
                            )
                                .animate()
                                .fadeIn(
                                  delay: (index * 50).ms,
                                  duration: 300.ms,
                                )
                                .slideY(
                                  begin: 0.1,
                                  delay: (index * 50).ms,
                                  duration: 300.ms,
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

/// Skeleton loader pour les groupes
class _GroupsSkeletonLoader extends StatelessWidget {
  final bool isDark;

  const _GroupsSkeletonLoader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[900]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// État vide
class _EmptyState extends StatelessWidget {
  final bool isDark;

  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 80,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun groupe trouvé',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez ou rejoignez un groupe',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte de groupe - Design identique à l'image (layout horizontal)
class _GroupCard extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  final bool isDark;
  final int index;

  const _GroupCard({
    required this.group,
    required this.onTap,
    required this.onJoin,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Couleur violette pour l'avatar (comme sur l'image)
    const avatarColor = Color(0xFF6366F1);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar à gauche - Carré violet ou gradient avec 2 icônes
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: group.profileImage != null && group.profileImage!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: group.profileImage!.startsWith('http')
                                ? group.profileImage!
                                : '${ApiService().baseUrl.replaceAll('/api', '')}${group.profileImage}',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => _buildGroupAvatarIcon(),
                          ),
                        )
                      : _buildGroupAvatarIcon(),
                ),
                
                const SizedBox(width: 16),
                
                // Contenu au centre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom du groupe
                      Text(
                        group.name,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Description
                      Text(
                        group.description.isNotEmpty ? group.description : 'Aucune description',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      // Statistiques
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${group.membersCount} membres',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.article,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${group.postsCount} posts',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Bouton "Membre" ou "Rejoindre" à droite
                if (group.userRole == null)
                  _JoinButton(onPressed: onJoin)
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981), // Vert comme sur l'image
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Membre',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupAvatarIcon() {
    // Gradient violet-bleu avec 2 icônes de personnes (comme sur l'image)
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Deux icônes de personnes côte à côte
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, color: Colors.white, size: 20),
              const SizedBox(width: 4),
              Icon(Icons.person, color: Colors.white, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bouton "Rejoindre" animé
class _JoinButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _JoinButton({required this.onPressed});

  @override
  State<_JoinButton> createState() => _JoinButtonState();
}

class _JoinButtonState extends State<_JoinButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Rejoindre',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
