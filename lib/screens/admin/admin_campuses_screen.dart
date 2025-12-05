import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../utils/app_colors.dart';

/// Écran de gestion de tous les campus pour les administrateurs globaux
class AdminCampusesScreen extends StatefulWidget {
  const AdminCampusesScreen({super.key});

  @override
  State<AdminCampusesScreen> createState() => _AdminCampusesScreenState();
}

class _AdminCampusesScreenState extends State<AdminCampusesScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _campuses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCampuses();
  }

  Future<void> _loadCampuses() async {
    setState(() => _isLoading = true);
    try {
      final campuses = await _adminService.getAllCampuses();
      setState(() {
        _campuses = campuses;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading campuses: $e');
      setState(() {
        _campuses = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete(String campusId, String campusName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le campus'),
        content: Text('Êtes-vous sûr de vouloir supprimer "$campusName" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await _adminService.deleteCampus(campusId);
        if (mounted) {
          if (result['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Campus supprimé'),
                backgroundColor: AppColors.success,
              ),
            );
            _loadCampuses();
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
        debugPrint('Error deleting campus: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Campus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigation vers création de campus
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Création de campus à venir')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _campuses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_city_outlined, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun campus',
                        style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCampuses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _campuses.length,
                    itemBuilder: (context, index) {
                      final campus = _campuses[index];
                      return _CampusCard(
                        campus: campus,
                        onEdit: () {
                          // TODO: Navigation vers édition de campus
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Édition de campus à venir')),
                          );
                        },
                        onDelete: () => _handleDelete(campus['id'].toString(), campus['name'] ?? 'Campus'),
                      );
                    },
                  ),
                ),
    );
  }
}

class _CampusCard extends StatelessWidget {
  final Map<String, dynamic> campus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CampusCard({
    required this.campus,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = campus['name'] ?? 'Sans nom';
    final location = campus['location'] ?? '';
    final isMain = campus['is_main'] ?? false;
    final isActive = campus['is_active'] ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (isMain) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Principal',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Inactif',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Modifier'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Supprimer'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

