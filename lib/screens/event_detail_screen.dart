import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

/// Écran de détails d'un événement
class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventService _eventService = EventService();
  
  Event? _event;
  bool _isLoading = true;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    setState(() => _isLoading = true);
    
    try {
      final event = await _eventService.getEvent(widget.eventId);
      setState(() {
        _event = event;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading event: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _handleJoinEvent() async {
    if (_event == null) return;

    setState(() => _isJoining = true);

    try {
      final result = await _eventService.joinEvent(_event!.id);
      
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Participation enregistrée !'),
              backgroundColor: AppColors.success,
            ),
          );
          // Recharger l'événement pour mettre à jour le statut
          await _loadEvent();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Erreur lors de la participation'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error joining event: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'événement'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _event == null
              ? const Center(child: Text('Événement non trouvé'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      if (_event!.imageUrl != null && _event!.imageUrl!.isNotEmpty)
                        Image.network(
                          _event!.imageUrl!.startsWith('http')
                              ? _event!.imageUrl!
                              : '${AppConstants.apiBaseUrl.replaceAll('/api', '')}${_event!.imageUrl}',
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 250,
                              color: AppColors.border,
                              child: const Icon(Icons.image, size: 64, color: AppColors.textSecondary),
                            );
                          },
                        ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Titre
                            Text(
                              _event!.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Organisateur
                            Row(
                              children: [
                                const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  'Organisé par ${_event!.organizer.fullName}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Date et heure
                            _InfoRow(
                              icon: Icons.calendar_today,
                              label: 'Date',
                              value: DateFormat('EEEE dd MMMM yyyy').format(_event!.startDate),
                            ),
                            if (_event!.endDate != null) ...[
                              _InfoRow(
                                icon: Icons.event_available,
                                label: 'Fin',
                                value: DateFormat('EEEE dd MMMM yyyy').format(_event!.endDate!),
                              ),
                            ],
                            _InfoRow(
                              icon: Icons.access_time,
                              label: 'Heure',
                              value: '${DateFormat('HH:mm').format(_event!.startDate)}${_event!.endDate != null ? ' - ${DateFormat('HH:mm').format(_event!.endDate!)}' : ''}',
                            ),

                            // Lieu
                            _InfoRow(
                              icon: Icons.location_on,
                              label: 'Lieu',
                              value: _event!.location,
                            ),

                            // Prix
                            _InfoRow(
                              icon: Icons.attach_money,
                              label: 'Prix',
                              value: _event!.isFree ? 'Gratuit' : '${_event!.price} FCFA',
                            ),

                            // Capacité
                            if (_event!.capacity != null)
                              _InfoRow(
                                icon: Icons.people,
                                label: 'Capacité',
                                value: '${_event!.participantsCount} / ${_event!.capacity} participants',
                              ),

                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Description
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _event!.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Bouton de participation
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _event!.isParticipating == true || _isJoining
                                    ? null
                                    : _handleJoinEvent,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _event!.isParticipating == true
                                      ? AppColors.success
                                      : AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isJoining
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        _event!.isParticipating == true
                                            ? 'Vous participez déjà'
                                            : 'Participer à l\'événement',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

