import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../utils/app_colors.dart';
import 'event_detail_screen.dart';
import 'create_event_screen.dart';

/// Écran "Mes événements" - Affiche les événements organisés, participations et favoris
class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  final EventService _eventService = EventService();
  late TabController _tabController;
  
  List<Event> _organizedEvents = [];
  List<Event> _participations = [];
  List<Event> _favorites = [];
  
  bool _isLoading = false;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _activeTab = _tabController.index;
      });
    });
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      // Charger en parallèle
      final results = await Future.wait([
        _eventService.getMyEvents(type: 'organized'),
        _eventService.getParticipations(),
        _eventService.getFavorites(),
      ]);

      setState(() {
        _organizedEvents = results[0] as List<Event>;
        
        final participationsData = results[1] as Map<String, dynamic>;
        _participations = (participationsData['results'] as List<Event>?) ?? [];
        
        _favorites = results[2] as List<Event>;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading my events: $e');
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
        title: const Text('Mes Événements'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Organisés', icon: Icon(Icons.event)),
            Tab(text: 'Participations', icon: Icon(Icons.event_available)),
            Tab(text: 'Favoris', icon: Icon(Icons.star)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateEventScreen(),
                ),
              ).then((_) => _loadEvents());
            },
            tooltip: 'Créer un événement',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEvents,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrganizedEvents(),
                  _buildParticipations(),
                  _buildFavorites(),
                ],
              ),
            ),
    );
  }

  Widget _buildOrganizedEvents() {
    if (_organizedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Aucun événement organisé',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEventScreen(),
                  ),
                ).then((_) => _loadEvents());
              },
              icon: const Icon(Icons.add),
              label: const Text('Créer un événement'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _organizedEvents.length,
      itemBuilder: (context, index) => _buildEventCard(_organizedEvents[index], isOrganized: true),
    );
  }

  Widget _buildParticipations() {
    if (_participations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Aucune participation',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _participations.length,
      itemBuilder: (context, index) => _buildEventCard(_participations[index]),
    );
  }

  Widget _buildFavorites() {
    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Aucun favori',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      itemBuilder: (context, index) => _buildEventCard(_favorites[index]),
    );
  }

  Widget _buildEventCard(Event event, {bool isOrganized = false}) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    final isPast = event.startDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(eventId: event.id),
            ),
          ).then((_) => _loadEvents());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de l'événement
            if (event.image != null && event.image!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  event.image!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.event, size: 64, color: AppColors.primary),
                    );
                  },
                ),
              ),
            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isOrganized)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            event.status == 'published' ? 'Publié' : 'Brouillon',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (event.location != null && event.location!.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: TextStyle(color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${dateFormat.format(event.startDate)} à ${timeFormat.format(event.startDate)}',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (isPast)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Terminé',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

