import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/offline_indicator.dart';
import 'event_detail_screen.dart';
import 'notifications_screen.dart';

/// Écran de liste des événements style Acara
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventService _eventService = EventService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Event> _allEvents = [];
  List<Event> _trendingEvents = [];
  Event? _featuredEvent;
  List<EventCategory> _categories = [];
  bool _isLoading = true;
  bool _isOffline = false;
  String _selectedCategory = '';
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Charger les catégories
      final categories = await _eventService.getCategories();
      
      // Charger les événements
      final result = await _eventService.getEvents(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        category: _selectedCategory.isEmpty ? null : _selectedCategory,
        status: 'published',
        ordering: '-participants_count', // Trier par popularité
      );
      
      final events = (result['results'] as List<Event>?) ?? [];
      
      // Séparer les événements featured et trending
      final featured = events.where((e) => e.isFeatured).toList();
      final trending = events.where((e) => !e.isFeatured).toList();
      
      setState(() {
        _categories = categories;
        _allEvents = events;
        _featuredEvent = featured.isNotEmpty ? featured.first : null;
        _trendingEvents = trending;
        _isOffline = result['isOffline'] == true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading events: $e');
      setState(() {
        _allEvents = [];
        _trendingEvents = [];
        _featuredEvent = null;
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

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final canCreateEvent = user != null && 
                               user.isVerified && 
                               !user.isAdmin && 
                               !user.isUniversityAdmin && 
                               !(user.isStaff ?? false);

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F5),
          body: SafeArea(
            child: Column(
              children: [
                // Header avec logo, recherche, notifications
                _buildHeader(context, isDark, canCreateEvent),
                
                // Indicateur de mode hors ligne
                OfflineIndicator(isOffline: _isOffline),
                
                // Contenu
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _isSearching
                          ? _buildSearchResults(isDark)
                          : _buildHomeContent(isDark),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool canCreateEvent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
            children: [
          // Logo CampusLink
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'C',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
              // Barre de recherche
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(25),
              ),
                child: TextField(
              controller: _searchController,
                onChanged: _handleSearch,
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: GoogleFonts.inter(
                    color: isDark ? Colors.white54 : Colors.grey[600],
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: isDark ? Colors.white54 : Colors.grey[600],
                            size: 20,
                          ),
                        onPressed: () {
                          _searchController.clear();
                            _handleSearch('');
                        },
                      )
                    : null,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Icône Notifications
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: isDark ? Colors.white70 : Colors.grey[700],
              size: 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          
          // Icône Bookmark
          IconButton(
            icon: Icon(
              Icons.bookmark_outline,
              color: isDark ? Colors.white70 : Colors.grey[700],
              size: 24,
            ),
            onPressed: () {
              // TODO: Afficher les favoris
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(bool isDark) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Section Featured
          if (_featuredEvent != null) _buildFeaturedSection(_featuredEvent!, isDark),
          
          const SizedBox(height: 24),
          
          // Section Trending
          _buildTrendingSection(isDark),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(Event event, bool isDark) {
    final dateFormat = DateFormat('dd MMM');
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Voir tous les featured
                },
                child: Text(
                  'See all',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF4A90E2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Grand banner Featured
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(eventId: event.id),
                ),
              );
            },
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Image de fond
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: event.imageUrl!.startsWith('http')
                                ? event.imageUrl!
                                : '${ApiService().baseUrl.replaceAll('/api', '')}${event.imageUrl}',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: const Color(0xFF4A90E2),
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF4A90E2),
                                    const Color(0xFF6B9BD1),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF4A90E2),
                                  const Color(0xFF6B9BD1),
                                ],
                              ),
                            ),
                          ),
                  ),
                  
                  // Overlay avec gradient
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  
                  // Contenu
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge date
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              dateFormat.format(event.startDate),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4A90E2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Titre
                          Text(
                            event.title,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          
                          // Bouton Book Now
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              'Book Now',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4A90E2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trending',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Voir tous les trending
                },
                child: Text(
                  'See all',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF4A90E2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

              // Filtres de catégories
              if (_categories.isNotEmpty)
            SizedBox(
            height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                    child: _CategoryChip(
                      label: 'All',
                      isSelected: _selectedCategory.isEmpty,
                      isDark: isDark,
                      onTap: () {
                            setState(() => _selectedCategory = '');
                            _loadData();
                        },
                      ),
                    );
                  }
                  final category = _categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                  child: _CategoryChip(
                    label: category.name,
                    isSelected: _selectedCategory == category.id,
                    isDark: isDark,
                    onTap: () {
                      setState(() => _selectedCategory = category.id);
                        _loadData();
                      },
                    ),
                  );
                },
              ),
            ),

        const SizedBox(height: 16),
        
        // Liste des événements trending
        if (_trendingEvents.isEmpty)
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: isDark ? Colors.white38 : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No events found',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _trendingEvents.length,
            itemBuilder: (context, index) {
              final event = _trendingEvents[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _EventCard(
                  event: event,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailScreen(eventId: event.id),
                      ),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSearchResults(bool isDark) {
    final results = _allEvents.where((event) {
      if (_selectedCategory.isNotEmpty && event.category?.id != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Filtres de catégories en mode recherche
        if (_categories.isNotEmpty)
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: _categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CategoryChip(
                      label: 'All',
                      isSelected: _selectedCategory.isEmpty,
                      isDark: isDark,
                      onTap: () {
                        setState(() => _selectedCategory = '');
                        _loadData();
                      },
                    ),
                  );
                }
                final category = _categories[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CategoryChip(
                    label: category.name,
                    isSelected: _selectedCategory == category.id,
                    isDark: isDark,
                    onTap: () {
                      setState(() => _selectedCategory = category.id);
                      _loadData();
                    },
                  ),
                );
              },
            ),
          ),
        
        // Résultats de recherche
              Expanded(
          child: results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                        Icons.search_off,
                              size: 64,
                        color: isDark ? Colors.white38 : Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                        'No results found',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try different keywords',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: results.length,
                          itemBuilder: (context, index) {
                    final event = results[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _EventCard(
                              event: event,
                        isDark: isDark,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EventDetailScreen(eventId: event.id),
                                  ),
                                );
                              },
                      ),
                            );
                          },
                      ),
              ),
            ],
    );
  }
}

/// Carte d'événement style Acara
class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final bool isDark;

  const _EventCard({
    required this.event,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM');
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
              ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: event.imageUrl!.startsWith('http')
                      ? event.imageUrl!
                      : '${ApiService().baseUrl.replaceAll('/api', '')}${event.imageUrl}',
                      width: 120,
                      height: 120,
                  fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 120,
                        color: const Color(0xFF4A90E2),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4A90E2),
                              const Color(0xFF6B9BD1),
                            ],
                          ),
                        ),
                        child: const Icon(Icons.event, color: Colors.white),
                      ),
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4A90E2),
                            const Color(0xFF6B9BD1),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.event, color: Colors.white),
                    ),
            ),
            
            // Contenu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // Badge date et tag catégorie
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            dateFormat.format(event.startDate),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (event.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              event.category!.name,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white70 : Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 8),

                    // Titre
                  Text(
                      event.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                    const SizedBox(height: 4),

                    // Participants et localisation
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.participantsCount >= 1000
                              ? '${(event.participantsCount / 1000).toStringAsFixed(1)}K+ Going'
                              : '${event.participantsCount}+ Going',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  Row(
                    children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                            style: GoogleFonts.inter(
                            fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                      ),
                    ],
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip de catégorie
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4A90E2)
              : (isDark ? const Color(0xFF2C2C2E) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A90E2)
                : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.3)),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}
