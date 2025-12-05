import 'package:flutter/material.dart';
import '../../services/university_admin_service.dart';
import '../../utils/app_colors.dart';

/// Écran de paramètres de l'université pour les administrateurs d'université
class UniversityAdminSettingsScreen extends StatefulWidget {
  const UniversityAdminSettingsScreen({super.key});

  @override
  State<UniversityAdminSettingsScreen> createState() => _UniversityAdminSettingsScreenState();
}

class _UniversityAdminSettingsScreenState extends State<UniversityAdminSettingsScreen> {
  final UniversityAdminService _universityAdminService = UniversityAdminService();
  Map<String, dynamic>? _university;
  bool _isLoading = true;
  bool _isSaving = false;

  // Form data
  bool _requireEmailVerification = true;
  bool _requirePhoneVerification = false;
  bool _autoVerifyStudents = false;
  bool _requireAdminApproval = true;
  bool _moderatePosts = true;
  bool _moderateEvents = false;
  bool _moderateGroups = false;
  bool _allowStudentGroups = true;
  bool _allowStudentEvents = true;
  int _maxGroupsPerStudent = 5;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final university = await _universityAdminService.getMyUniversity();
      if (university != null) {
        final settings = await _universityAdminService.getUniversitySettings(university['id'].toString());
        setState(() {
          _university = university;
          if (settings != null) {
            _requireEmailVerification = settings['require_email_verification'] ?? true;
            _requirePhoneVerification = settings['require_phone_verification'] ?? false;
            _autoVerifyStudents = settings['auto_verify_students'] ?? false;
            _requireAdminApproval = settings['require_admin_approval'] ?? true;
            _moderatePosts = settings['moderate_posts'] ?? true;
            _moderateEvents = settings['moderate_events'] ?? false;
            _moderateGroups = settings['moderate_groups'] ?? false;
            _allowStudentGroups = settings['allow_student_groups'] ?? true;
            _allowStudentEvents = settings['allow_student_events'] ?? true;
            _maxGroupsPerStudent = settings['max_groups_per_student'] ?? 5;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSave() async {
    if (_university == null) return;

    setState(() => _isSaving = true);
    try {
      final result = await _universityAdminService.updateUniversitySettings(
        _university!['id'].toString(),
        {
          'require_email_verification': _requireEmailVerification,
          'require_phone_verification': _requirePhoneVerification,
          'auto_verify_students': _autoVerifyStudents,
          'require_admin_approval': _requireAdminApproval,
          'moderate_posts': _moderatePosts,
          'moderate_events': _moderateEvents,
          'moderate_groups': _moderateGroups,
          'allow_student_groups': _allowStudentGroups,
          'allow_student_events': _allowStudentEvents,
          'max_groups_per_student': _maxGroupsPerStudent,
        },
      );

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Paramètres mis à jour'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadData();
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
      debugPrint('Error saving settings: $e');
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
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres de l\'Université'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _handleSave,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : const Text('Enregistrer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_university != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _university!['name'] ?? 'Université',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'Paramètres d\'Inscription',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Exiger la vérification de l\'email'),
                    value: _requireEmailVerification,
                    onChanged: (value) => setState(() => _requireEmailVerification = value),
                  ),
                  SwitchListTile(
                    title: const Text('Exiger la vérification du téléphone'),
                    value: _requirePhoneVerification,
                    onChanged: (value) => setState(() => _requirePhoneVerification = value),
                  ),
                  SwitchListTile(
                    title: const Text('Vérifier automatiquement les étudiants'),
                    value: _autoVerifyStudents,
                    onChanged: (value) => setState(() => _autoVerifyStudents = value),
                  ),
                  SwitchListTile(
                    title: const Text('Exiger l\'approbation admin'),
                    value: _requireAdminApproval,
                    onChanged: (value) => setState(() => _requireAdminApproval = value),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Paramètres de Modération',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Modérer les posts'),
                    value: _moderatePosts,
                    onChanged: (value) => setState(() => _moderatePosts = value),
                  ),
                  SwitchListTile(
                    title: const Text('Modérer les événements'),
                    value: _moderateEvents,
                    onChanged: (value) => setState(() => _moderateEvents = value),
                  ),
                  SwitchListTile(
                    title: const Text('Modérer les groupes'),
                    value: _moderateGroups,
                    onChanged: (value) => setState(() => _moderateGroups = value),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Paramètres de Contenu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Permettre aux étudiants de créer des groupes'),
                    value: _allowStudentGroups,
                    onChanged: (value) => setState(() => _allowStudentGroups = value),
                  ),
                  SwitchListTile(
                    title: const Text('Permettre aux étudiants de créer des événements'),
                    value: _allowStudentEvents,
                    onChanged: (value) => setState(() => _allowStudentEvents = value),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: _maxGroupsPerStudent.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Nombre maximum de groupes par étudiant',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    onChanged: (value) {
                      final intValue = int.tryParse(value);
                      if (intValue != null) {
                        setState(() => _maxGroupsPerStudent = intValue);
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

