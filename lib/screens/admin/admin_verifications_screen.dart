import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../utils/app_colors.dart';
import '../user_detail_screen.dart';

/// Écran de gestion des vérifications pour les administrateurs globaux
class AdminVerificationsScreen extends StatefulWidget {
  const AdminVerificationsScreen({super.key});

  @override
  State<AdminVerificationsScreen> createState() => _AdminVerificationsScreenState();
}

class _AdminVerificationsScreenState extends State<AdminVerificationsScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _pendingVerifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingVerifications();
  }

  Future<void> _loadPendingVerifications() async {
    setState(() => _isLoading = true);
    try {
      final verifications = await _adminService.getPendingVerifications();
      setState(() {
        _pendingVerifications = verifications;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading pending verifications: $e');
      setState(() {
        _pendingVerifications = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleVerify(String userId) async {
    try {
      final result = await _adminService.verifyUser(userId);
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Utilisateur vérifié'), backgroundColor: AppColors.success),
          );
          _loadPendingVerifications();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'Erreur'), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      debugPrint('Error verifying user: $e');
    }
  }

  Future<void> _handleReject(String userId) async {
    try {
      final result = await _adminService.rejectUser(userId);
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Utilisateur rejeté'), backgroundColor: AppColors.success),
          );
          _loadPendingVerifications();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'Erreur'), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      debugPrint('Error rejecting user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérifications en Attente')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingVerifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user_outlined, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune vérification en attente',
                        style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPendingVerifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingVerifications.length,
                    itemBuilder: (context, index) {
                      final user = _pendingVerifications[index];
                      return _VerificationCard(
                        user: user,
                        onVerify: () => _handleVerify(user['id'].toString()),
                        onReject: () => _handleReject(user['id'].toString()),
                        onView: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDetailScreen(userId: user['id'].toString()),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onVerify;
  final VoidCallback onReject;
  final VoidCallback onView;

  const _VerificationCard({
    required this.user,
    required this.onVerify,
    required this.onReject,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final username = user['username'] ?? 'N/A';
    final email = user['email'] ?? 'N/A';
    final firstName = user['first_name'] ?? '';
    final lastName = user['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim().isEmpty ? username : '$firstName $lastName';

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
                    backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                    child: Text(
                      username[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
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
                ],
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
                    onPressed: onVerify,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Vérifier'),
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

