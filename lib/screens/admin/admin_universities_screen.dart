import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/confirm_dialog.dart';
import '../../utils/toast_service.dart';

/// Écran de gestion des universités pour les administrateurs globaux
class AdminUniversitiesScreen extends StatefulWidget {
  const AdminUniversitiesScreen({super.key});

  @override
  State<AdminUniversitiesScreen> createState() => _AdminUniversitiesScreenState();
}

class _AdminUniversitiesScreenState extends State<AdminUniversitiesScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _universities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUniversities();
  }

  Future<void> _loadUniversities() async {
    setState(() => _isLoading = true);
    try {
      final universities = await _adminService.getUniversities();
      if (mounted) {
        setState(() {
          _universities = universities;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading universities: $e');
      if (mounted) {
        setState(() {
          _universities = [];
          _isLoading = false;
        });
      }
    }
  }

  /// Génère un slug à partir du nom
  String _slugFromName(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9\-]'), '');
  }

  Future<void> _showCreateDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _UniversityFormDialog(
        title: 'Ajouter une université',
        submitLabel: 'Créer',
        initialData: null,
      ),
    );
    if (result == null || !mounted) return;
    result['slug'] = _slugFromName(result['name']?.toString() ?? '');
    try {
      final apiResult = await _adminService.createUniversity(result);
      if (mounted) {
        if (apiResult['success'] == true) {
          ToastService.showSuccess('Université créée');
          _loadUniversities();
        } else {
          ToastService.showError(apiResult['error'] ?? 'Erreur');
        }
      }
    } catch (e) {
      debugPrint('Error creating university: $e');
      if (mounted) ToastService.showError('Erreur lors de la création');
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> university) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _UniversityFormDialog(
        title: 'Modifier l\'université',
        submitLabel: 'Enregistrer',
        initialData: university,
      ),
    );
    if (result == null || !mounted) return;
    final id = university['id'].toString();
    try {
      final apiResult = await _adminService.updateUniversity(id, result);
      if (mounted) {
        if (apiResult['success'] == true) {
          ToastService.showSuccess('Université mise à jour');
          _loadUniversities();
        } else {
          ToastService.showError(apiResult['error'] ?? 'Erreur');
        }
      }
    } catch (e) {
      debugPrint('Error updating university: $e');
      if (mounted) ToastService.showError('Erreur lors de la modification');
    }
  }

  Future<void> _handleDelete(String universityId, String universityName) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Supprimer l\'université',
      message: 'Êtes-vous sûr de vouloir supprimer "$universityName" ? Cette action est irréversible.',
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
      isDanger: true,
    );
    if (confirmed != true || !mounted) return;
    try {
      final result = await _adminService.deleteUniversity(universityId);
      if (mounted) {
        if (result['success'] == true) {
          ToastService.showSuccess('Université supprimée');
          _loadUniversities();
        } else {
          ToastService.showError(result['error'] ?? 'Erreur');
        }
      }
    } catch (e) {
      debugPrint('Error deleting university: $e');
      if (mounted) ToastService.showError('Erreur lors de la suppression');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Universités'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _isLoading ? null : _showCreateDialog,
            tooltip: 'Ajouter une université',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _universities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune université',
                        style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _showCreateDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter une université'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUniversities,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _universities.length,
                    itemBuilder: (context, index) {
                      final university = _universities[index];
                      return _UniversityCard(
                        university: university,
                        onEdit: () => _showEditDialog(university),
                        onDelete: () => _handleDelete(
                          university['id'].toString(),
                          university['name'] ?? 'Université',
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _UniversityCard extends StatelessWidget {
  final Map<String, dynamic> university;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UniversityCard({
    required this.university,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = university['name'] ?? 'Sans nom';
    final shortName = university['short_name'] ?? '';
    final address = university['address'] ?? '';
    final isActive = university['is_active'] ?? true;

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
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (shortName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          shortName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (address.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          address,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                      'Inactive',
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
                FilledButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Modifier'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Supprimer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UniversityFormDialog extends StatefulWidget {
  final String title;
  final String submitLabel;
  final Map<String, dynamic>? initialData;

  const _UniversityFormDialog({
    required this.title,
    required this.submitLabel,
    this.initialData,
  });

  @override
  State<_UniversityFormDialog> createState() => _UniversityFormDialogState();
}

class _UniversityFormDialogState extends State<_UniversityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _shortNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _nameController = TextEditingController(text: d?['name']?.toString() ?? '');
    _shortNameController = TextEditingController(text: d?['short_name']?.toString() ?? '');
    _descriptionController = TextEditingController(text: d?['description']?.toString() ?? '');
    _addressController = TextEditingController(text: d?['address']?.toString() ?? '');
    _phoneController = TextEditingController(text: d?['phone']?.toString() ?? '');
    _websiteController = TextEditingController(text: d?['website']?.toString() ?? '');
    _isActive = d?['is_active'] ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getData() {
    return {
      'name': _nameController.text.trim(),
      'short_name': _shortNameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'address': _addressController.text.trim(),
      'phone': _phoneController.text.trim(),
      'website': _websiteController.text.trim(),
      'is_active': _isActive,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom *',
                    border: OutlineInputBorder(),
                    hintText: 'Nom officiel de l\'université',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _shortNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom court',
                    border: OutlineInputBorder(),
                    hintText: 'ex: ESMT, UCAD',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Site web',
                    border: OutlineInputBorder(),
                    hintText: 'https://...',
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Active', style: TextStyle(color: AppColors.textPrimary)),
                    const SizedBox(width: 12),
                    Switch(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(context, _getData());
            }
          },
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}
