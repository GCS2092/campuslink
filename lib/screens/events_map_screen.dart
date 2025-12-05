import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import 'event_detail_screen.dart';

/// Écran affichant les événements sur une carte
class EventsMapScreen extends StatefulWidget {
  const EventsMapScreen({super.key});

  @override
  State<EventsMapScreen> createState() => _EventsMapScreenState();
}

class _EventsMapScreenState extends State<EventsMapScreen> {
  final EventService _eventService = EventService();
  List<Event> _events = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'upcoming', 'today'

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      String? dateFrom;
      
      if (_selectedFilter == 'today') {
        dateFrom = DateTime(now.year, now.month, now.day).toIso8601String();
      } else if (_selectedFilter == 'upcoming') {
        dateFrom = now.toIso8601String();
      }

      final eventsData = await _eventService.getEvents(
        status: 'published',
        dateFrom: dateFrom,
      );

      // Filtrer les événements qui ont une localisation
      final events = (eventsData['results'] as List<Event>?) ?? [];
      final eventsWithLocation = events.where((e) {
        return e.locationLat != null && e.locationLng != null;
      }).toList();

      setState(() {
        _events = eventsWithLocation;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading events for map: $e');
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
        title: const Text('Carte des Événements'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _selectedFilter = value);
              _loadEvents();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Tous'),
              ),
              const PopupMenuItem(
                value: 'upcoming',
                child: Text('À venir'),
              ),
              const PopupMenuItem(
                value: 'today',
                child: Text('Aujourd\'hui'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun événement avec localisation',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Les événements doivent avoir une localisation pour apparaître sur la carte',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Liste des événements
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                          bottom: BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(16),
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          return _buildEventCard(event);
                        },
                      ),
                    ),
                    // Zone de carte (simplifiée - affichage de la liste)
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadEvents,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _events.length,
                          itemBuilder: (context, index) {
                            final event = _events[index];
                            return _buildEventListItem(event);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailScreen(eventId: event.id),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.image != null && event.image!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    event.image!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.event, color: AppColors.primary),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (event.location != null && event.location!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  Widget _buildEventListItem(Event event) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: event.image != null && event.image!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  event.image!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.event, color: AppColors.primary),
                    );
                  },
                ),
              )
            : Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.event, color: AppColors.primary),
              ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.location != null && event.location!.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location!,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${dateFormat.format(event.startDate)} à ${timeFormat.format(event.startDate)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            if (event.locationLat != null && event.locationLng != null)
              Row(
                children: [
                  Icon(Icons.map, size: 12, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${event.locationLat!.toStringAsFixed(4)}, ${event.locationLng!.toStringAsFixed(4)}',
                    style: TextStyle(fontSize: 11, color: AppColors.primary),
                  ),
                ],
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
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
  }
}

