import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/class_leader_service.dart';
import '../../services/event_service.dart';
import '../../services/group_service.dart';
import '../../utils/app_colors.dart';
import '../event_detail_screen.dart';
import '../group_detail_screen.dart';

/// Écran de modération pour les responsables de classe
/// Permet de modérer les événements et groupes de leur classe
class ClassLeaderModerationScreen extends StatefulWidget {
  const ClassLeaderModerationScreen({super.key});

  @override
  State<ClassLeaderModerationScreen> createState() => _ClassLeaderModerationScreenState();
}

class _ClassLeaderModerationScreenState extends State<ClassLeaderModerationScreen> with SingleTickerProviderStateMixin {
  final ClassLeaderService _classLeaderService = ClassLeaderService();
  final EventService _eventService = EventService();
  final GroupService _groupService = GroupService();

  late TabController _tabController;

  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _groups = [];
  bool _isLoadingEvents = true;
  bool _isLoadingGroups = true;
  String _eventFilter = 'all'; // 'all', 'pending', 'published', 'rejected'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEvents();
    _loadGroups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoadingEvents = true);
    try {
      final events = await _classLeaderService.getClassEvents(status: _eventFilter == 'all' ? null : _eventFilter);
      setState(() {
        _events = events;
        _isLoadingEvents = false;
      });
    } catch (e) {
      debugPrint('Error loading events: $e');
      setState(() {
        _events = [];
        _isLoadingEvents = false;
      });
    }
  }

  Future<void> _loadGroups() async {
    setState(() => _isLoadingGroups = true);
    try {
      final groups = await _classLeaderService.getClassGroups();
      setState(() {
        _groups = groups;
        _isLoadingGroups = false;
      });
    } catch (e) {
      debugPrint('Error loading groups: $e');
      setState(() {
        _groups = [];
        _isLoadingGroups = false;
      });
    }
  }

  Future<void> _handleModerateEvent(String eventId, String action) async {
    try {
      // Les actions possibles sont: 'delete', 'publish', 'cancel', 'draft'
      // Pour approuver, on utilise 'publish', pour rejeter on peut utiliser 'cancel' ou 'delete'
      final actionToSend = action == 'approve' ? 'publish' : (action == 'reject' ? 'cancel' : action);
      final result = await _eventService.moderateEvent(eventId, actionToSend);
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(action == 'approve' ? 'Événement publié' : 'Événement annulé'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadEvents();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Erreur'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error moderating event: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleModerateGroup(String groupId, String action) async {
    try {
      // Les actions possibles sont: 'delete', 'verify', 'unverify'
      // Pour approuver, on utilise 'verify', pour rejeter on peut utiliser 'delete' ou 'unverify'
      final actionToSend = action == 'approve' ? 'verify' : (action == 'reject' ? 'unverify' : action);
      final result = await _groupService.moderateGroup(groupId, actionToSend);
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(action == 'approve' ? 'Groupe vérifié' : 'Groupe non vérifié'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadGroups();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Erreur'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error moderating group: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null || !user.isClassLeader) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(
          child: Text('Accès réservé aux responsables de classe'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modération'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Événements', icon: Icon(Icons.event)),
            Tab(text: 'Groupes', icon: Icon(Icons.group)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventsTab(),
          _buildGroupsTab(),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return Column(
      children: [
        // Filtres
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.surface,
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('Tous')),
                    ButtonSegment(value: 'pending', label: Text('En attente')),
                    ButtonSegment(value: 'published', label: Text('Publiés')),
                  ],
                  selected: {_eventFilter},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _eventFilter = newSelection.first;
                      _loadEvents();
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // Liste des événements
        Expanded(
          child: _isLoadingEvents
              ? const Center(child: CircularProgressIndicator())
              : _events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 64, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun événement',
                            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadEvents,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          return _EventModerationCard(
                            event: event,
                            onApprove: () => _handleModerateEvent(event['id'].toString(), 'approve'),
                            onReject: () => _handleModerateEvent(event['id'].toString(), 'reject'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetailScreen(eventId: event['id'].toString()),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildGroupsTab() {
    return _isLoadingGroups
        ? const Center(child: CircularProgressIndicator())
        : _groups.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_off, size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun groupe',
                      style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadGroups,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _groups.length,
                  itemBuilder: (context, index) {
                    final group = _groups[index];
                    return _GroupModerationCard(
                      group: group,
                      onApprove: () => _handleModerateGroup(group['id'].toString(), 'approve'),
                      onReject: () => _handleModerateGroup(group['id'].toString(), 'reject'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupDetailScreen(groupId: group['id'].toString()),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
  }
}

class _EventModerationCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onTap;

  const _EventModerationCard({
    required this.event,
    required this.onApprove,
    required this.onReject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = event['status'] ?? 'draft';
    final statusColor = status == 'published'
        ? AppColors.success
        : status == 'rejected'
            ? AppColors.error
            : AppColors.warning;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event['title'] ?? 'Sans titre',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status == 'published'
                          ? 'Publié'
                          : status == 'rejected'
                              ? 'Rejeté'
                              : 'En attente',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (event['description'] != null)
                Text(
                  event['description'] as String,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              if (status == 'pending' || status == 'draft')
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Rejeter'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approuver'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupModerationCard extends StatelessWidget {
  final Map<String, dynamic> group;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onTap;

  const _GroupModerationCard({
    required this.group,
    required this.onApprove,
    required this.onReject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPublic = group['is_public'] ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group['name'] ?? 'Sans nom',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isPublic)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Public',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (group['description'] != null)
                Text(
                  group['description'] as String,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Rejeter'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approuver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

