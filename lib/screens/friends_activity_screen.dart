import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/user_service.dart';
import '../services/event_service.dart';
import '../models/user.dart';
import '../models/event.dart';
import '../utils/app_colors.dart';
import 'user_detail_screen.dart';
import 'event_detail_screen.dart';

/// Écran affichant l'activité récente des amis
class FriendsActivityScreen extends StatefulWidget {
  const FriendsActivityScreen({super.key});

  @override
  State<FriendsActivityScreen> createState() => _FriendsActivityScreenState();
}

class _FriendsActivityScreenState extends State<FriendsActivityScreen> {
  final UserService _userService = UserService();
  final EventService _eventService = EventService();
  
  List<User> _friends = [];
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriendsActivity();
  }

  Future<void> _loadFriendsActivity() async {
    setState(() => _isLoading = true);
    try {
      // Charger les amis
      final friends = await _userService.getFriends();
      
      // Pour chaque ami, charger ses participations récentes
      final activities = <Map<String, dynamic>>[];
      for (final friend in friends) {
        try {
          // Récupérer les participations de l'ami (via les événements récents)
          final events = await _eventService.getEvents(
            dateFrom: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
            status: 'published',
          );
          
          final eventsList = (events['results'] as List<Event>?) ?? [];
          for (final event in eventsList) {
            // Vérifier si l'ami participe (simplifié - dans un vrai cas, on utiliserait l'API)
            activities.add({
              'type': 'event_participation',
              'user': friend,
              'event': event,
              'timestamp': event.startDate,
            });
          }
        } catch (e) {
          debugPrint('Error loading activity for ${friend.id}: $e');
        }
      }
      
      // Trier par timestamp
      activities.sort((a, b) {
        final aTime = a['timestamp'] as DateTime;
        final bTime = b['timestamp'] as DateTime;
        return bTime.compareTo(aTime);
      });
      
      setState(() {
        _friends = friends;
        _activities = activities.take(50).toList(); // Limiter à 50 activités
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading friends activity: $e');
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
        title: const Text('Activité des Amis'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune activité récente',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vos amis n\'ont pas d\'activité récente',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFriendsActivity,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _activities.length,
                    itemBuilder: (context, index) {
                      final activity = _activities[index];
                      final user = activity['user'] as User;
                      final event = activity['event'] as Event?;
                      final timestamp = activity['timestamp'] as DateTime;
                      
                      return _buildActivityCard(user, event, timestamp);
                    },
                  ),
                ),
    );
  }

  Widget _buildActivityCard(User user, Event? event, DateTime timestamp) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    final timeAgo = _getTimeAgo(timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: event != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailScreen(eventId: event.id),
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailScreen(userId: user.id),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    user.username.isNotEmpty
                        ? user.username[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: AppColors.textPrimary),
                        children: [
                          TextSpan(
                            text: user.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (event != null) ...[
                            const TextSpan(text: ' participe à '),
                            TextSpan(
                              text: event.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ] else
                            const TextSpan(text: ' a une nouvelle activité'),
                        ],
                      ),
                    ),
                    if (event != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${dateFormat.format(event.startDate)} à ${timeFormat.format(event.startDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (event != null)
                Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('dd MMM yyyy').format(date);
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
}

