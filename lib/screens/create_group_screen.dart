import 'package:flutter/material.dart';
import '../services/group_service.dart';
import '../utils/app_colors.dart';
import 'group_detail_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final GroupService _groupService = GroupService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final groupData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'is_public': _isPublic,
      };

      final group = await _groupService.createGroup(groupData);
      if (mounted && group != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Groupe créé !'), backgroundColor: AppColors.success),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GroupDetailScreen(groupId: group.id)),
        );
      }
    } catch (e) {
      debugPrint('Error creating group: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un groupe'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : const Text('Créer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom du groupe *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Nom requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Description requise' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Groupe public'),
                subtitle: const Text('Tous les utilisateurs peuvent voir et rejoindre le groupe'),
                value: _isPublic,
                onChanged: (value) => setState(() => _isPublic = value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

