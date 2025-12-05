import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/university_admin_service.dart';
import '../../utils/app_colors.dart';
import '../user_detail_screen.dart';
import 'university_admin_create_student_screen.dart';

/// Écran de gestion des étudiants pour les administrateurs d'université
class UniversityAdminStudentsScreen extends StatefulWidget {
  const UniversityAdminStudentsScreen({super.key});

  @override
  State<UniversityAdminStudentsScreen> createState() => _UniversityAdminStudentsScreenState();
}

class _UniversityAdminStudentsScreenState extends State<UniversityAdminStudentsScreen> with SingleTickerProviderStateMixin {
  final UniversityAdminService _universityAdminService = UniversityAdminService();
  late TabController _tabController;

  List<Map<String, dynamic>> _pendingStudents = [];
  List<Map<String, dynamic>> _activeStudents = [];
  bool _isLoadingPending = true;
  bool _isLoadingActive = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPendingStudents();
    _loadActiveStudents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPendingStudents() async {
    setState(() => _isLoadingPending = true);
    try {
      final students = await _universityAdminService.getPendingStudents();
      setState(() {
        _pendingStudents = students;
        _isLoadingPending = false;
      });
    } catch (e) {
      debugPrint('Error loading pending students: $e');
      setState(() {
        _pendingStudents = [];
        _isLoadingPending = false;
      });
    }
  }

  Future<void> _loadActiveStudents() async {
    setState(() => _isLoadingActive = true);
    try {
      final students = await _universityAdminService.getActiveStudents();
      setState(() {
        _activeStudents = students;
        _isLoadingActive = false;
      });
    } catch (e) {
      debugPrint('Error loading active students: $e');
      setState(() {
        _activeStudents = [];
        _isLoadingActive = false;
      });
    }
  }

  Future<void> _handleActivateStudent(String userId) async {
    try {
      final result = await _universityAdminService.activateStudent(userId);
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Étudiant activé'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadPendingStudents();
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
      debugPrint('Error activating student: $e');
    }
  }

  Future<void> _handleDeactivateStudent(String userId) async {
    try {
      final result = await _universityAdminService.deactivateStudent(userId);
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Étudiant désactivé'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadActiveStudents();
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
      debugPrint('Error deactivating student: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null || !user.isUniversityAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(
          child: Text('Accès réservé aux administrateurs d\'université'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Étudiants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UniversityAdminCreateStudentScreen(),
                ),
              ).then((created) {
                if (created == true) {
                  _loadPendingStudents();
                  _loadActiveStudents();
                }
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'En attente', icon: Icon(Icons.pending)),
            Tab(text: 'Actifs', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTab(),
          _buildActiveTab(),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    return _isLoadingPending
        ? const Center(child: CircularProgressIndicator())
        : _pendingStudents.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun étudiant en attente',
                      style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadPendingStudents,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingStudents.length,
                  itemBuilder: (context, index) {
                    final student = _pendingStudents[index];
                    return _StudentCard(
                      student: student,
                      onActivate: () => _handleActivateStudent(student['id'].toString()),
                      onView: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailScreen(userId: student['id'].toString()),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
  }

  Widget _buildActiveTab() {
    return _isLoadingActive
        ? const Center(child: CircularProgressIndicator())
        : _activeStudents.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun étudiant actif',
                      style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadActiveStudents,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _activeStudents.length,
                  itemBuilder: (context, index) {
                    final student = _activeStudents[index];
                    return _StudentCard(
                      student: student,
                      onDeactivate: () => _handleDeactivateStudent(student['id'].toString()),
                      onView: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailScreen(userId: student['id'].toString()),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
  }
}

class _StudentCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback? onActivate;
  final VoidCallback? onDeactivate;
  final VoidCallback onView;

  const _StudentCard({
    required this.student,
    this.onActivate,
    this.onDeactivate,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final username = student['username'] ?? 'N/A';
    final email = student['email'] ?? 'N/A';
    final firstName = student['first_name'] ?? '';
    final lastName = student['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim().isEmpty ? username : '$firstName $lastName';
    final isActive = student['is_active'] ?? false;
    final isVerified = student['is_verified'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      username[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
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
                          fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Actif',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      if (isVerified) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Vérifié',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (onActivate != null || onDeactivate != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onActivate != null)
                      ElevatedButton.icon(
                        onPressed: onActivate,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Activer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    if (onDeactivate != null) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: onDeactivate,
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Désactiver'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

