import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import '../services/feed_service.dart';
import '../services/event_service.dart';
import '../models/feed_item.dart';
import '../models/event.dart';
import '../widgets/skeleton_loader.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'event_detail_screen.dart';
import 'group_detail_screen.dart';

/// Dashboard Premium Ultra-Moderne
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  final FeedService _feedService = FeedService();
  final EventService _eventService = EventService();
  List<FeedItem> _feedItems = [];
  List<Event> _recommendedEvents = [];
  bool _isLoadingFeed = false;
  bool _isLoadingRecommended = false;
  
  late AnimationController _headerAnimController;
  late AnimationController _contentAnimController;
  late Animation<double> _headerFadeAnim;
  late Animation<Offset> _headerSlideAnim;
  late Animation<double> _contentFadeAnim;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadFeed();
    _loadRecommendedEvents();
  }

  void _setupAnimations() {
    _headerAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _contentAnimController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOut),
    );

    _headerSlideAnim = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOutCubic));

    _contentFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentAnimController, curve: Curves.easeOut),
    );

    _headerAnimController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentAnimController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _contentAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadFeed() async {
    setState(() => _isLoadingFeed = true);
    try {
      final items = await _feedService.getPersonalizedFeed();
      if (mounted) {
        setState(() {
          // Ajouter deux actualités au début de la liste
          final additionalNews = _createAdditionalNews();
          _feedItems = [...additionalNews, ...items];
          _isLoadingFeed = false;
        });
      }
    } catch (e) {
      try {
        final items = await _feedService.getFeedItems();
        if (mounted) {
          setState(() {
            // Ajouter deux actualités au début de la liste
            final additionalNews = _createAdditionalNews();
            _feedItems = [...additionalNews, ...items];
            _isLoadingFeed = false;
          });
        }
      } catch (fallbackError) {
        if (mounted) {
          setState(() {
            // Même si le chargement échoue, afficher les deux actualités
            final additionalNews = _createAdditionalNews();
            _feedItems = additionalNews;
            _isLoadingFeed = false;
          });
        }
      }
    }
  }

  /// Crée deux actualités supplémentaires
  List<FeedItem> _createAdditionalNews() {
    return [
      FeedItem(
        id: 'news-1-${DateTime.now().millisecondsSinceEpoch}',
        type: 'news',
        title: 'Nouvelle fonctionnalité : Messagerie améliorée',
        content: 'Nous avons amélioré la messagerie avec de nouvelles fonctionnalités : envoi de photos, messages vocaux et réactions. Découvrez toutes les nouveautés !',
        image: null,
        visibility: 'public',
        isPublished: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        author: FeedItemAuthor(
          id: 'system',
          username: 'CampusLink',
          firstName: 'CampusLink',
          lastName: 'Team',
        ),
      ),
      FeedItem(
        id: 'news-2-${DateTime.now().millisecondsSinceEpoch}',
        type: 'announcement',
        title: 'Événements à venir cette semaine',
        content: 'Ne manquez pas les événements organisés cette semaine : conférences, ateliers et activités sociales. Consultez la section Événements pour plus de détails.',
        image: null,
        visibility: 'public',
        isPublished: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        author: FeedItemAuthor(
          id: 'system',
          username: 'CampusLink',
          firstName: 'CampusLink',
          lastName: 'Team',
        ),
      ),
    ];
  }

  Future<void> _loadRecommendedEvents() async {
    setState(() => _isLoadingRecommended = true);
    try {
      final events = await _eventService.getRecommendedEvents(limit: 6);
      if (mounted) {
        setState(() {
          _recommendedEvents = events;
          _isLoadingRecommended = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRecommended = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(isDark),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await authProvider.loadUserProfile();
              await _loadFeed();
              await _loadRecommendedEvents();
            },
            color: AppColors.primary,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                // Header Hero
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _headerFadeAnim,
                    child: SlideTransition(
                      position: _headerSlideAnim,
                      child: _buildHeroHeader(user, isDark),
                    ),
                  ),
                ),

                // Contenu principal
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _contentFadeAnim,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 32),
                          
                          // Section Actualités
                          _buildSectionHeader('Actualités', Icons.auto_awesome, isDark),
                          const SizedBox(height: 20),
                          _buildFeedSection(isDark),
                          
                          const SizedBox(height: 40),
                          
                          // Section Événements
                          _buildSectionHeader('Pour vous', Icons.bolt_rounded, isDark),
                          const SizedBox(height: 20),
                          _buildEventsSection(isDark),
                          
                          const SizedBox(height: 40),
                          
                          // Section Infos rapides
                          _buildQuickInfoSection(user, isDark),
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
              ? [Colors.black, Colors.black.withValues(alpha: 0)]
              : [const Color(0xFFF8F9FA), const Color(0xFFF8F9FA).withValues(alpha: 0)],
          ),
        ),
      ),
      title: Text(
        'CampusLink',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: isDark ? Colors.white : const Color(0xFF0A0A0A),
        ),
      ),
      actions: [
        _buildIconButton(Icons.notifications_none_rounded, isDark, () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => const NotificationsScreen(),
          ));
        }),
        const SizedBox(width: 8),
        _buildMenuButton(isDark),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, bool isDark, VoidCallback onTap) {
    // Style WhatsApp pour les boutons d'icônes
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark 
          ? Colors.white.withValues(alpha: 0.12)
          : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(22), // Très arrondi comme WhatsApp
        border: Border.all(
          color: isDark 
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          splashColor: const Color(0xFF25D366).withValues(alpha: 0.2),
          highlightColor: const Color(0xFF25D366).withValues(alpha: 0.1),
          child: Center(
            child: Icon(
              icon, 
              color: isDark ? Colors.white : const Color(0xFF1A1A1A), 
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(bool isDark) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      offset: const Offset(0, 50),
      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark 
            ? Colors.white.withValues(alpha: 0.12)
            : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(22), // Style WhatsApp
          border: Border.all(
            color: isDark 
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.more_vert_rounded, 
            color: isDark ? Colors.white : const Color(0xFF1A1A1A), 
            size: 22,
          ),
        ),
      ),
      itemBuilder: (context) => [
        _buildMenuItem('Profil', Icons.person_outline_rounded, isDark, () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        }),
        _buildMenuItem('Paramètres', Icons.settings_outlined, isDark, () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
        }),
        const PopupMenuDivider(),
        _buildMenuItem('Déconnexion', Icons.logout_rounded, isDark, () {
          _handleLogout(context);
        }, isDestructive: true),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String title, IconData icon, bool isDark, VoidCallback onTap, {bool isDestructive = false}) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDestructive ? const Color(0xFFFF3B30) : (isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? const Color(0xFFFF3B30) : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(dynamic user, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 110, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
            ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
            : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            child: Center(
              child: Text(
                user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour,',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.firstName ?? user.username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                if (user.isVerified) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Vérifié',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : const Color(0xFF0A0A0A),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedSection(bool isDark) {
    if (_isLoadingFeed) {
      return Column(
        children: List.generate(2, (i) => Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: SkeletonListTile(),
        )),
      );
    }

    if (_feedItems.isEmpty) {
      return _buildEmptyState(
        icon: Icons.article_outlined,
        title: 'Aucune actualité',
        subtitle: 'Les actualités apparaîtront ici',
        isDark: isDark,
      );
    }

    return Column(
      children: _feedItems.take(5).map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _FeedItemCard(item: item, isDark: isDark, onTap: () {
          if (item.type == 'event' && item.eventData?['id'] != null) {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => EventDetailScreen(eventId: item.eventData!['id'].toString()),
            ));
          } else if (item.type == 'group' && item.feedData?['id'] != null) {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => GroupDetailScreen(groupId: item.feedData!['id'].toString()),
            ));
          }
        }),
      )).toList(),
    );
  }

  Widget _buildEventsSection(bool isDark) {
    if (_isLoadingRecommended) {
      return SizedBox(
        height: 280,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (context, i) => Padding(
            padding: EdgeInsets.only(right: 16),
            child: SkeletonCard(height: 280, width: 240),
          ),
        ),
      );
    }

    if (_recommendedEvents.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_outlined,
        title: 'Aucun événement',
        subtitle: 'Pas de recommandations pour le moment',
        isDark: isDark,
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _recommendedEvents.length,
        itemBuilder: (context, i) => Padding(
          padding: EdgeInsets.only(right: 16),
          child: _EventCard(
            event: _recommendedEvents[i],
            isDark: isDark,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => EventDetailScreen(eventId: _recommendedEvents[i].id),
              ));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInfoSection(dynamic user, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildInfoCard(
              icon: Icons.verified_user_outlined,
              label: 'Compte',
              value: user.isVerified ? 'Vérifié' : 'En attente',
              color: user.isVerified ? const Color(0xFF34C759) : const Color(0xFFFF9500),
              isDark: isDark,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildInfoCard(
              icon: Icons.phone_outlined,
              label: 'Téléphone',
              value: user.phoneVerified ? 'Vérifié' : 'Non vérifié',
              color: user.phoneVerified ? const Color(0xFF34C759) : const Color(0xFF8E8E93),
              isDark: isDark,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 56, color: isDark ? Colors.white24 : Colors.black26),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Déconnexion réussie'),
          backgroundColor: Color(0xFF34C759),
        ),
      );
    }
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final bool isDark;

  const _EventCard({required this.event, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  event.imageUrl!.startsWith('http') ? event.imageUrl! : '${ApiService().baseUrl.replaceAll('/api', '')}${event.imageUrl}',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                    ),
                    child: const Icon(Icons.event, size: 48, color: Colors.white54),
                  ),
                ),
              )
            else
              Container(
                height: 140,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const Icon(Icons.event, size: 48, color: Colors.white54),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: isDark ? Colors.white54 : Colors.black54),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          DateFormat('dd MMM, HH:mm').format(event.startDate),
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (event.participantsCount > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_rounded, size: 12, color: Color(0xFF6366F1)),
                          const SizedBox(width: 4),
                          Text(
                            '${event.participantsCount}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedItemCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback onTap;
  final bool isDark;

  const _FeedItemCard({required this.item, required this.onTap, required this.isDark});

  IconData _getIcon() {
    switch (item.type) {
      case 'event': return Icons.event_rounded;
      case 'group': return Icons.group_rounded;
      case 'announcement': return Icons.campaign_rounded;
      default: return Icons.article_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = item.title ?? item.eventData?['title'] ?? item.feedData?['title'] ?? 'Actualité';
    final content = item.content ?? item.eventData?['description'] ?? item.feedData?['content'] ?? '';
    final image = item.image ?? item.eventData?['image_url'] ?? item.feedData?['image'];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null && image.toString().isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  image.toString().startsWith('http') ? image.toString() : '${ApiService().baseUrl.replaceAll('/api', '')}$image',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_getIcon(), color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (content.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (item.author != null || item.createdAt != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (item.author != null) ...[
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                item.author!.username.isNotEmpty ? item.author!.username[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.author!.firstName ?? item.author!.username,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                        if (item.createdAt != null)
                          Text(
                            DateFormat('dd MMM').format(item.createdAt!),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}