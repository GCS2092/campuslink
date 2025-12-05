import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/messaging_service.dart';
import '../utils/app_colors.dart';
import 'user_detail_screen.dart';
import 'chat_screen.dart';

/// Écran pour découvrir les étudiants
class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final UserService _userService = UserService();
  final MessagingService _messagingService = MessagingService();
  
  List<User> _students = [];
  List<User> _suggestions = [];
  final Map<String, Map<String, dynamic>> _friendshipStatuses = {};
  bool _isLoading = true;
  bool _isLoadingSuggestions = false;
  String _searchQuery = '';
  String? _selectedUniversity;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
    _loadStudents();
  }

  Future<void> _loadSuggestions() async {
    setState(() => _isLoadingSuggestions = true);
    try {
      final suggestions = await _userService.getFriendSuggestions(limit: 6);
      setState(() {
        _suggestions = suggestions;
        _isLoadingSuggestions = false;
      });
    } catch (e) {
      debugPrint('Error loading suggestions: $e');
      setState(() => _isLoadingSuggestions = false);
    }
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    
    try {
      final students = await _userService.getUsers(
        verifiedOnly: true,
        university: _selectedUniversity,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      
      setState(() {
        _students = students;
        _isLoading = false;
      });
      
      // Charger les statuts d'amitié
      if (students.isNotEmpty) {
        _loadFriendshipStatuses(students);
      }
    } catch (e) {
      debugPrint('Error loading students: $e');
      setState(() {
        _students = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFriendshipStatuses(List<User> students) async {
    for (final student in students) {
      if (!mounted) break; // Arrêter si le widget est disposé
      try {
        final status = await _userService.getFriendshipStatus(student.id);
        if (mounted) {
          setState(() {
            _friendshipStatuses[student.id] = status;
          });
        }
      } catch (e) {
        debugPrint('Error loading friendship status for ${student.id}: $e');
      }
    }
  }

  Future<void> _handleSendFriendRequest(String userId) async {
    try {
      final result = await _userService.sendFriendRequest(userId);
      
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Demande d\'ami envoyée'),
              backgroundColor: AppColors.success,
            ),
          );
          // Recharger le statut
          final status = await _userService.getFriendshipStatus(userId);
          setState(() {
            _friendshipStatuses[userId] = status;
          });
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
      debugPrint('Error sending friend request: $e');
    }
  }

  Future<void> _handleStartConversation(String userId, String username) async {
    try {
      final conversation = await _messagingService.createPrivateConversation(userId);
      
      if (mounted && conversation != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversation.id,
              conversationName: username,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating conversation: $e');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Découvrir les Étudiants'),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un étudiant...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                          _loadStudents();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onSubmitted: (value) {
                setState(() => _searchQuery = value);
                _loadStudents();
              },
            ),
          ),

          // Suggestions d'amis
          if (_isLoadingSuggestions)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
          else if (_suggestions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Suggestions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: _loadSuggestions,
                    child: const Text('Actualiser'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final student = _suggestions[index];
                  return _SuggestionCard(
                    student: student,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailScreen(userId: student.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Liste des étudiants
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun étudiant trouvé',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadStudents,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            final status = _friendshipStatuses[student.id];
                            
                            return _StudentCard(
                              student: student,
                              friendshipStatus: status,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserDetailScreen(userId: student.id),
                                  ),
                                );
                              },
                              onSendRequest: () => _handleSendFriendRequest(student.id),
                              onMessage: () => _handleStartConversation(student.id, student.username),
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

class _SuggestionCard extends StatelessWidget {
  final User student;
  final VoidCallback onTap;

  const _SuggestionCard({
    required this.student,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                student.username.isNotEmpty
                    ? student.username[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              student.username,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final User student;
  final Map<String, dynamic>? friendshipStatus;
  final VoidCallback onTap;
  final VoidCallback onSendRequest;
  final VoidCallback onMessage;

  const _StudentCard({
    required this.student,
    this.friendshipStatus,
    required this.onTap,
    required this.onSendRequest,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final status = friendshipStatus?['status'] ?? 'none';
    final isFriend = status == 'friends';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  student.username.isNotEmpty
                      ? student.username[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${student.username}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (student.profile?['university'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.school, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _getUniversityName(student.profile!['university']),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (isFriend)
                ElevatedButton.icon(
                  onPressed: onMessage,
                  icon: const Icon(Icons.message, size: 16),
                  label: const Text('Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                )
              else if (status == 'request_sent')
                OutlinedButton(
                  onPressed: null,
                  child: const Text('Demande envoyée'),
                )
              else
                OutlinedButton.icon(
                  onPressed: onSendRequest,
                  icon: const Icon(Icons.person_add, size: 16),
                  label: const Text('Ajouter'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getUniversityName(dynamic university) {
    if (university == null) return '';
    if (university is String) return university;
    if (university is Map) {
      return university['name'] ?? university['short_name'] ?? '';
    }
    return '';
  }
}

