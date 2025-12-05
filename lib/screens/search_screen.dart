import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../services/event_service.dart';
import '../services/group_service.dart';
import '../models/user.dart';
import '../models/event.dart';
import '../models/group.dart';
import '../utils/app_colors.dart';
import 'user_detail_screen.dart';
import 'event_detail_screen.dart';
import 'group_detail_screen.dart';

/// Écran de recherche globale
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();
  final EventService _eventService = EventService();
  final GroupService _groupService = GroupService();
  
  late TabController _tabController;
  
  String _searchQuery = '';
  List<User> _users = [];
  List<Event> _events = [];
  List<Group> _groups = [];
  
  bool _isSearching = false;
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _users = [];
        _events = [];
        _groups = [];
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    try {
      // Recherche parallèle
      final results = await Future.wait([
        _userService.getUsers(search: query, verifiedOnly: true),
        _eventService.getEvents(search: query, status: 'published'),
        _groupService.getGroups(search: query),
      ]);

      setState(() {
        _users = results[0] as List<User>;
        final eventsData = results[1] as Map<String, dynamic>;
        _events = (eventsData['results'] as List<Event>?) ?? [];
        final groupsData = results[2] as Map<String, dynamic>;
        _groups = (groupsData['results'] as List<Group>?) ?? [];
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Error searching: $e');
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la recherche: ${e.toString()}'),
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
        title: const Text('Recherche'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tout'),
            Tab(text: 'Utilisateurs'),
            Tab(text: 'Événements'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onSubmitted: (_) => _performSearch(),
              onChanged: (value) {
                if (value.isEmpty) {
                  _performSearch();
                }
              },
            ),
          ),
          // Résultats
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchQuery.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Recherchez des utilisateurs, événements ou groupes',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildAllResults(),
                          _buildUsersResults(),
                          _buildEventsResults(),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllResults() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_users.isNotEmpty) ...[
            _buildSectionHeader('Utilisateurs', _users.length),
            ..._users.take(5).map((user) => _buildUserTile(user)),
            if (_users.length > 5)
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () {
                    _tabController.animateTo(1);
                  },
                  child: Text('Voir tous les utilisateurs (${_users.length})'),
                ),
              ),
          ],
          if (_events.isNotEmpty) ...[
            _buildSectionHeader('Événements', _events.length),
            ..._events.take(5).map((event) => _buildEventTile(event)),
            if (_events.length > 5)
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () {
                    _tabController.animateTo(2);
                  },
                  child: Text('Voir tous les événements (${_events.length})'),
                ),
              ),
          ],
          if (_groups.isNotEmpty) ...[
            _buildSectionHeader('Groupes', _groups.length),
            ..._groups.take(5).map((group) => _buildGroupTile(group)),
          ],
          if (_users.isEmpty && _events.isEmpty && _groups.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun résultat trouvé pour "$_searchQuery"',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUsersResults() {
    if (_users.isEmpty) {
      return Center(
        child: Text(
          'Aucun utilisateur trouvé',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) => _buildUserTile(_users[index]),
    );
  }

  Widget _buildEventsResults() {
    if (_events.isEmpty) {
      return Center(
        child: Text(
          'Aucun événement trouvé',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      itemBuilder: (context, index) => _buildEventTile(_events[index]),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        '$title ($count)',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildUserTile(User user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Text(
          user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
          style: TextStyle(color: AppColors.primary),
        ),
      ),
      title: Text(user.fullName),
      subtitle: Text(user.email),
      trailing: user.isVerified
          ? Icon(Icons.verified, color: AppColors.success, size: 20)
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailScreen(userId: user.id),
          ),
        );
      },
    );
  }

  Widget _buildEventTile(Event event) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

  Widget _buildGroupTile(Group group) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: group.profileImage != null && group.profileImage!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  group.profileImage!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      child: Icon(Icons.group, color: AppColors.secondary),
                    );
                  },
                ),
              )
            : Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.group, color: AppColors.secondary),
              ),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: group.description != null && group.description!.isNotEmpty
            ? Text(
                group.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              )
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupDetailScreen(groupId: group.id),
            ),
          );
        },
      ),
    );
  }
}

