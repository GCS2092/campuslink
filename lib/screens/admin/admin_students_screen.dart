import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/confirm_dialog.dart';
import '../../utils/toast_service.dart';
import '../user_detail_screen.dart';

/// Écran de gestion de tous les étudiants pour les administrateurs globaux
class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  late TabController _tabController;

  List<Map<String, dynamic>> _allStudents = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedUniversity;
  String? _selectedStatus;
  String? _selectedActiveStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _loadStudents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _studentDisplayName(Map<String, dynamic> s) {
    final fn = s['first_name'] ?? '';
    final ln = s['last_name'] ?? '';
    final full = '$fn $ln'.trim();
    return full.isEmpty ? (s['username'] ?? s['email'] ?? 'cet étudiant') : full;
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final students = await _adminService.getAllStudents(
        university: _selectedUniversity,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        verificationStatus: _selectedStatus,
        isActive: _selectedActiveStatus,
      );
      setState(() {
        _allStudents = students;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading students: $e');
      setState(() {
        _allStudents = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleActivateStudent(String userId, String displayName) async {
    try {
      final result = await _adminService.activateStudent(userId);
      if (mounted) {
        if (result['success'] == true) {
          ToastService.showSuccess('Étudiant activé');
          _loadStudents();
        } else {
          ToastService.showError(result['error'] ?? 'Erreur');
        }
      }
    } catch (e) {
      debugPrint('Error activating student: $e');
      if (mounted) ToastService.showError('Erreur lors de l\'activation');
    }
  }

  Future<void> _handleDeactivateStudent(String userId, String displayName) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Désactiver l\'étudiant',
      message: 'Êtes-vous sûr de vouloir désactiver $displayName ? Il ne pourra plus se connecter.',
      confirmText: 'Désactiver',
      cancelText: 'Annuler',
      isDanger: true,
    );
    if (!confirmed || !mounted) return;
    try {
      final result = await _adminService.deactivateStudent(userId);
      if (mounted) {
        if (result['success'] == true) {
          ToastService.showSuccess('Étudiant désactivé');
          _loadStudents();
        } else {
          ToastService.showError(result['error'] ?? 'Erreur');
        }
      }
    } catch (e) {
      debugPrint('Error deactivating student: $e');
      if (mounted) ToastService.showError('Erreur lors de la désactivation');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null || !user.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(
          child: Text('Accès réservé aux administrateurs globaux'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Étudiants'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tous les Étudiants', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Rechercher',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _loadStudents();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStudentsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _allStudents.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun étudiant',
                      style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadStudents,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _allStudents.length,
                  itemBuilder: (context, index) {
                    final student = _allStudents[index];
                    final isActive = student['is_active'] ?? false;
                    return _StudentCard(
                      student: student,
                      onActivate: isActive ? null : () => _handleActivateStudent(student['id'].toString(), _studentDisplayName(student)),
                      onDeactivate: isActive ? () => _handleDeactivateStudent(student['id'].toString(), _studentDisplayName(student)) : null,
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

