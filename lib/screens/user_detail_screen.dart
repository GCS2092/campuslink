import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/messaging_service.dart';
import '../utils/app_colors.dart';
import 'chat_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Écran de détail d'un utilisateur
class UserDetailScreen extends StatefulWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final UserService _userService = UserService();
  final MessagingService _messagingService = MessagingService();
  
  User? _user;
  Map<String, dynamic>? _friendshipStatus;
  bool _isLoading = true;
  bool _isLoadingStatus = false;
  bool _isSendingRequest = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await _userService.getUser(widget.userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
      
      if (user != null) {
        _loadFriendshipStatus();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _loadFriendshipStatus() async {
    if (_user == null) return;
    
    setState(() => _isLoadingStatus = true);
    try {
      final status = await _userService.getFriendshipStatus(_user!.id);
      setState(() {
        _friendshipStatus = status;
        _isLoadingStatus = false;
      });
    } catch (e) {
      debugPrint('Error loading friendship status: $e');
      setState(() => _isLoadingStatus = false);
    }
  }

  Future<void> _handleSendFriendRequest() async {
    if (_user == null) return;

    setState(() => _isSendingRequest = true);
    try {
      final result = await _userService.sendFriendRequest(_user!.id);
      
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Demande d\'ami envoyée'),
              backgroundColor: AppColors.success,
            ),
          );
          await _loadFriendshipStatus();
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
        setState(() => _isSendingRequest = false);
      }
    }
  }

  Future<void> _handleStartConversation() async {
    if (_user == null) return;

    try {
      final conversation = await _messagingService.createPrivateConversation(_user!.id);
      
      if (mounted && conversation != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversation.id,
              conversationName: _user!.fullName,
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
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.id;
    final isOwnProfile = currentUserId == widget.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Utilisateur non trouvé'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // En-tête avec photo
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                color: AppColors.primary.withValues(alpha: 0.1),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      _user!.username.isNotEmpty
                                          ? _user!.username[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _user!.fullName,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '@${_user!.username}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Boutons d'action
                            if (!isOwnProfile) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: _isLoadingStatus
                                        ? const Center(child: CircularProgressIndicator())
                                        : _getActionButton(),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _handleStartConversation,
                                      icon: const Icon(Icons.message),
                                      label: const Text('Message'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.secondary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Informations
                            const Text(
                              'Informations',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.email,
                              label: 'Email',
                              value: _user!.email,
                            ),
                            if (_user!.phoneNumber != null)
                              _InfoRow(
                                icon: Icons.phone,
                                label: 'Téléphone',
                                value: _user!.phoneNumber!,
                              ),
                            if (_user!.role != null)
                              _InfoRow(
                                icon: Icons.work,
                                label: 'Rôle',
                                value: _getRoleLabel(_user!.role!),
                              ),
                            _InfoRow(
                              icon: Icons.verified_user,
                              label: 'Statut',
                              value: _user!.isVerified ? 'Vérifié' : 'En attente',
                              valueColor: _user!.isVerified ? AppColors.success : AppColors.warning,
                            ),
                            _InfoRow(
                              icon: Icons.calendar_today,
                              label: 'Membre depuis',
                              value: DateFormat('dd MMMM yyyy').format(_user!.dateJoined ?? DateTime.now()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _getActionButton() {
    final status = _friendshipStatus?['status'] ?? 'none';

    if (status == 'friends') {
      return ElevatedButton.icon(
        onPressed: () async {
          final friendshipId = _friendshipStatus?['friendship_id'];
          if (friendshipId == null) return;
          
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Retirer l\'ami'),
              content: const Text('Êtes-vous sûr de vouloir retirer cet ami ?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Retirer', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          );
          
          if (confirmed == true && mounted) {
            final result = await _userService.removeFriend(friendshipId.toString());
            if (result['success'] == true) {
              await _loadFriendshipStatus();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ami retiré avec succès'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['error'] ?? 'Erreur'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          }
        },
        icon: const Icon(Icons.check),
        label: const Text('Ami'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      );
    } else if (status == 'request_sent') {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.hourglass_empty),
        label: const Text('Demande envoyée'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.warning,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      );
    } else if (status == 'request_received') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoadingStatus ? null : () async {
                final friendshipId = _friendshipStatus?['friendship_id'];
                if (friendshipId == null) return;
                
                setState(() => _isLoadingStatus = true);
                final result = await _userService.acceptFriendRequest(friendshipId.toString());
                setState(() => _isLoadingStatus = false);
                
                if (result['success'] == true) {
                  await _loadFriendshipStatus();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Demande acceptée'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['error'] ?? 'Erreur'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Accepter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isLoadingStatus ? null : () async {
                final friendshipId = _friendshipStatus?['friendship_id'];
                if (friendshipId == null) return;
                
                setState(() => _isLoadingStatus = true);
                final result = await _userService.rejectFriendRequest(friendshipId.toString());
                setState(() => _isLoadingStatus = false);
                
                if (result['success'] == true) {
                  await _loadFriendshipStatus();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Demande rejetée'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['error'] ?? 'Erreur'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.close),
              label: const Text('Rejeter'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );
    } else {
      return ElevatedButton.icon(
        onPressed: _isSendingRequest ? null : _handleSendFriendRequest,
        icon: _isSendingRequest
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )
            : const Icon(Icons.person_add),
        label: const Text('Ajouter'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      );
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'student':
        return 'Étudiant';
      case 'class_leader':
        return 'Responsable de Classe';
      case 'association':
        return 'Association/Club';
      case 'admin':
        return 'Administrateur';
      case 'university_admin':
        return 'Administrateur d\'Université';
      default:
        return role;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

