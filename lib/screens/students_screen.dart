import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/messaging_service.dart';
import '../utils/app_colors.dart';
import '../utils/premium_design.dart';
import '../utils/toast_service.dart';
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
  List<Map<String, dynamic>> _universities = [];
  bool _isLoadingUniversities = false;

  @override
  void initState() {
    super.initState();
    _loadUniversities();
    _loadSuggestions();
    _loadStudents();
  }

  Future<void> _loadUniversities() async {
    setState(() => _isLoadingUniversities = true);
    try {
      final universities = await _userService.getUniversities();
      setState(() {
        _universities = universities;
        _isLoadingUniversities = false;
      });
    } catch (e) {
      debugPrint('Error loading universities: $e');
      setState(() => _isLoadingUniversities = false);
    }
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
      // Debug: Afficher le filtre sélectionné
      debugPrint('=== LOADING STUDENTS ===');
      debugPrint('Selected University ID: $_selectedUniversity');
      debugPrint('Search Query: $_searchQuery');
      
      final students = await _userService.getUsers(
        verifiedOnly: true,
        university: _selectedUniversity,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      
      debugPrint('Loaded ${students.length} students');
      
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
      
      if (!mounted) return;
      if (result['success'] == true) {
        ToastService.showSuccess('Demande d\'ami envoyée');
        // Recharger le statut
        final status = await _userService.getFriendshipStatus(userId);
        if (mounted) {
          setState(() {
            _friendshipStatuses[userId] = status;
          });
        }
      } else {
        ToastService.showError(result['error'] ?? 'Erreur');
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
        ToastService.showError('Erreur: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Découvrir les Étudiants',
          style: PremiumDesign.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche premium
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PremiumDesign.spacingL,
              vertical: PremiumDesign.spacingM,
            ),
            child: PremiumCard(
              padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.spacingM),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: PremiumDesign.spacingS),
                  Expanded(
                    child: TextField(
                      style: PremiumDesign.bodyMedium.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un étudiant...',
                        hintStyle: PremiumDesign.bodyMedium.copyWith(
                          color: isDark ? Colors.white38 : AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() => _searchQuery = '');
                                  _loadStudents();
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      onSubmitted: (value) {
                        _loadStudents();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Filtre par université premium
          if (_isLoadingUniversities || _universities.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.spacingL),
              child: PremiumCard(
                padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.spacingM),
                child: Row(
                  children: [
                    Icon(
                      Icons.school,
                      size: 20,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                    const SizedBox(width: PremiumDesign.spacingS),
                    Expanded(
                      child: _isLoadingUniversities
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedUniversity,
                                isExpanded: true,
                                style: PremiumDesign.bodyMedium.copyWith(
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                                hint: Text(
                                  'Toutes les universités',
                                  style: PremiumDesign.bodyMedium.copyWith(
                                    color: isDark ? Colors.white38 : AppColors.textSecondary,
                                  ),
                                ),
                                items: [
                                  DropdownMenuItem<String>(
                                    value: null,
                                    child: Text(
                                      'Toutes les universités',
                                      style: PremiumDesign.bodyMedium.copyWith(
                                        color: isDark ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  ..._universities.map((uni) {
                                    final name = uni['name'] ?? uni['short_name'] ?? 'Université';
                                    final id = uni['id']?.toString() ?? name;
                                    return DropdownMenuItem<String>(
                                      value: id,
                                      child: Text(
                                        name,
                                        overflow: TextOverflow.ellipsis,
                                        style: PremiumDesign.bodyMedium.copyWith(
                                          color: isDark ? Colors.white : AppColors.textPrimary,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedUniversity = value;
                                  });
                                  _loadStudents();
                                },
                              ),
                            ),
                    ),
                    if (_selectedUniversity != null)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 18,
                          color: isDark ? Colors.white54 : AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() => _selectedUniversity = null);
                          _loadStudents();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: PremiumDesign.spacingM),

          // Suggestions d'amis premium
          if (_isLoadingSuggestions)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
          else if (_suggestions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.spacingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Suggestions',
                    style: PremiumDesign.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: _loadSuggestions,
                    child: Text(
                      'Actualiser',
                      style: PremiumDesign.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PremiumDesign.spacingM),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.spacingL),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final student = _suggestions[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: PremiumDesign.spacingM),
                    child: _SuggestionCardPremium(
                      student: student,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailScreen(userId: student.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: PremiumDesign.spacingL),
          ],

          // Liste des étudiants premium
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
                              size: 80,
                              color: isDark ? Colors.white38 : AppColors.textSecondary,
                            ),
                            const SizedBox(height: PremiumDesign.spacingL),
                            Text(
                              'Aucun étudiant trouvé',
                              style: PremiumDesign.titleMedium.copyWith(
                                color: isDark ? Colors.white60 : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: PremiumDesign.spacingXS),
                            Text(
                              'Essayez de modifier vos filtres',
                              style: PremiumDesign.bodySmall.copyWith(
                                color: isDark ? Colors.white38 : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadStudents,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PremiumDesign.spacingL,
                          ),
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            final status = _friendshipStatuses[student.id];
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: PremiumDesign.spacingS),
                              child: _StudentCardPremium(
                                student: student,
                                friendshipStatus: status,
                                isDark: isDark,
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
                              ),
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

class _SuggestionCardPremium extends StatelessWidget {
  final User student;
  final VoidCallback onTap;
  final bool isDark;

  const _SuggestionCardPremium({
    required this.student,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PremiumCard(
        padding: const EdgeInsets.all(PremiumDesign.spacingM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: PremiumDesign.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: PremiumDesign.shadowSmall,
              ),
              child: Center(
                child: Text(
                  student.username.isNotEmpty
                      ? student.username[0].toUpperCase()
                      : 'U',
                  style: PremiumDesign.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: PremiumDesign.spacingS),
            Text(
              student.username,
              style: PremiumDesign.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
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

class _StudentCardPremium extends StatelessWidget {
  final User student;
  final Map<String, dynamic>? friendshipStatus;
  final VoidCallback onTap;
  final VoidCallback onSendRequest;
  final VoidCallback onMessage;
  final bool isDark;

  const _StudentCardPremium({
    required this.student,
    this.friendshipStatus,
    required this.onTap,
    required this.onSendRequest,
    required this.onMessage,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final status = friendshipStatus?['status'] ?? 'none';
    final isFriend = status == 'friends';

    return PremiumCard(
      padding: const EdgeInsets.all(PremiumDesign.spacingM),
      onTap: onTap,
      child: Row(
        children: [
          // Avatar premium
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: PremiumDesign.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: PremiumDesign.shadowSmall,
            ),
            child: Center(
              child: Text(
                student.username.isNotEmpty
                    ? student.username[0].toUpperCase()
                    : 'U',
                style: PremiumDesign.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: PremiumDesign.spacingM),
          // Informations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: PremiumDesign.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: PremiumDesign.spacingXS),
                Text(
                  '@${student.username}',
                  style: PremiumDesign.bodySmall.copyWith(
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                  ),
                ),
                if (student.profile?['university'] != null) ...[
                  const SizedBox(height: PremiumDesign.spacingXS),
                  Row(
                    children: [
                      Icon(
                        Icons.school,
                        size: 14,
                        color: isDark ? Colors.white54 : AppColors.primary,
                      ),
                      const SizedBox(width: PremiumDesign.spacingXS),
                      Expanded(
                        child: Text(
                          _getUniversityName(student.profile!['university']),
                          style: PremiumDesign.labelSmall.copyWith(
                            color: isDark ? Colors.white54 : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
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
          const SizedBox(width: PremiumDesign.spacingS),
          // Boutons d'action premium
          if (isFriend)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: PremiumDesign.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: PremiumDesign.shadowSmall,
              ),
              child: IconButton(
                icon: const Icon(Icons.message, color: Colors.white, size: 20),
                onPressed: onMessage,
                tooltip: 'Message',
              ),
            )
          else if (status == 'request_sent')
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PremiumDesign.spacingM,
                vertical: PremiumDesign.spacingXS,
              ),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
                borderRadius: BorderRadius.circular(PremiumDesign.radiusM),
              ),
              child: Text(
                'Envoyée',
                style: PremiumDesign.labelSmall.copyWith(
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: PremiumDesign.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: PremiumDesign.shadowSmall,
              ),
              child: IconButton(
                icon: const Icon(Icons.person_add, color: Colors.white, size: 20),
                onPressed: onSendRequest,
                tooltip: 'Ajouter',
              ),
            ),
        ],
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

