import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/user_service.dart';
import '../utils/app_colors.dart';
import '../utils/premium_design.dart';
import '../utils/toast_service.dart';
import 'login_screen.dart';

/// Écran des paramètres avec onglets pour compte, sécurité et notifications
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserService _userService = UserService();


  // Formulaire de modification de profil
  final _profileFormKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _twitterController = TextEditingController();
  bool _isSavingProfile = false;

  // Formulaire de changement de mot de passe
  final _passwordFormKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isChangingPassword = false;

  // Préférences de notifications
  Map<String, bool> _notificationPrefs = {
    'email_notifications': true,
    'push_notifications': true,
    'event_reminders': true,
    'friend_requests': true,
    'messages': true,
    'group_updates': true,
    'event_invitations': true,
  };
  bool _isLoadingPrefs = true;
  bool _isSavingPrefs = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
    _loadNotificationPreferences();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
      _bioController.text = user.profile?['bio'] ?? '';
      _websiteController.text = user.profile?['website'] ?? '';
      _facebookController.text = user.profile?['facebook'] ?? '';
      _instagramController.text = user.profile?['instagram'] ?? '';
      _twitterController.text = user.profile?['twitter'] ?? '';
    }
  }

  Future<void> _loadNotificationPreferences() async {
    setState(() => _isLoadingPrefs = true);
    try {
      final prefs = await _userService.getNotificationPreferences();
      setState(() {
        _notificationPrefs = Map<String, bool>.from(
          prefs.map((key, value) => MapEntry(key, value is bool ? value : true)),
        );
        _isLoadingPrefs = false;
      });
    } catch (e) {
      debugPrint('Error loading notification preferences: $e');
      setState(() => _isLoadingPrefs = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    setState(() => _isSavingProfile = true);
    try {
      final profileData = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'bio': _bioController.text.trim(),
        'website': _websiteController.text.trim(),
        'facebook': _facebookController.text.trim(),
        'instagram': _instagramController.text.trim(),
        'twitter': _twitterController.text.trim(),
      };

      final result = await _userService.updateProfile(profileData);
      if (!mounted) return;
      
      if (result['success'] == true) {
        // Recharger le profil utilisateur
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.loadUserProfile();

        if (!mounted) return;
        ToastService.showSuccess('Profil mis à jour avec succès');
      } else {
        if (mounted) {
          ToastService.showError(result['error'] ?? 'Erreur lors de la mise à jour');
        }
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ToastService.showError('Erreur: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingProfile = false);
      }
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isChangingPassword = true);
    try {
      final result = await _userService.changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
        newPasswordConfirm: _confirmPasswordController.text,
      );

      if (result['success'] == true) {
        // Réinitialiser le formulaire
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        if (mounted) {
          ToastService.showSuccess('Mot de passe modifié avec succès');
        }
      } else {
        if (mounted) {
          ToastService.showError(result['error'] ?? 'Erreur lors du changement de mot de passe');
        }
      }
    } catch (e) {
      debugPrint('Error changing password: $e');
      if (mounted) {
        ToastService.showError('Erreur: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isChangingPassword = false);
      }
    }
  }

  Future<void> _saveNotificationPreferences() async {
    setState(() => _isSavingPrefs = true);
    try {
      final result = await _userService.updateNotificationPreferences(_notificationPrefs);
      if (result['success'] == true) {
        if (mounted) {
          ToastService.showSuccess('Préférences mises à jour avec succès');
        }
      } else {
        if (mounted) {
          ToastService.showError(result['error'] ?? 'Erreur lors de la mise à jour');
        }
      }
    } catch (e) {
      debugPrint('Error saving notification preferences: $e');
      if (mounted) {
        ToastService.showError('Erreur: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingPrefs = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Paramètres',
          style: PremiumDesign.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Compte'),
            Tab(icon: Icon(Icons.lock), text: 'Sécurité'),
            Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAccountTab(),
          _buildSecurityTab(),
          _buildNotificationsTab(),
        ],
      ),
    );
  }

  Widget _buildAccountTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumDesign.spacingL,
        vertical: PremiumDesign.spacingM,
      ),
      child: Form(
        key: _profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations personnelles',
              style: PremiumDesign.headlineSmall.copyWith(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: PremiumDesign.spacingL),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Prénom',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
                hintText: 'Parlez-nous de vous...',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            const Text(
              'Réseaux sociaux',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Site web',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _facebookController,
              decoration: const InputDecoration(
                labelText: 'Facebook',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.facebook),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _instagramController,
              decoration: const InputDecoration(
                labelText: 'Instagram',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.camera_alt),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _twitterController,
              decoration: const InputDecoration(
                labelText: 'Twitter',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.alternate_email),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: PremiumDesign.spacingXL),
            PremiumButton(
              text: 'Enregistrer les modifications',
              onPressed: _isSavingProfile ? null : _saveProfile,
              isLoading: _isSavingProfile,
              icon: Icons.save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Changer le mot de passe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pour votre sécurité, entrez votre mot de passe actuel avant d\'en définir un nouveau.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _oldPasswordController,
              decoration: InputDecoration(
                labelText: 'Mot de passe actuel',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showOldPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _showOldPassword = !_showOldPassword);
                  },
                ),
              ),
              obscureText: !_showOldPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showNewPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _showNewPassword = !_showNewPassword);
                  },
                ),
              ),
              obscureText: !_showNewPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est requis';
                }
                if (value.length < 8) {
                  return 'Le mot de passe doit contenir au moins 8 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirmer le nouveau mot de passe',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _showConfirmPassword = !_showConfirmPassword);
                  },
                ),
              ),
              obscureText: !_showConfirmPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est requis';
                }
                if (value != _newPasswordController.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
            ),
            const SizedBox(height: PremiumDesign.spacingXL),
            PremiumButton(
              text: 'Changer le mot de passe',
              onPressed: _isChangingPassword ? null : _changePassword,
              isLoading: _isChangingPassword,
              icon: Icons.lock,
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            const Text(
              'Déconnexion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vous serez déconnecté de votre compte et devrez vous reconnecter pour accéder à l\'application.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _handleLogout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Se déconnecter',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    // Afficher une confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (!mounted) return;

    ToastService.showSuccess('Déconnexion réussie');

    // Rediriger vers l'écran de login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildNotificationsTab() {
    if (_isLoadingPrefs) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Préférences de notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choisissez les types de notifications que vous souhaitez recevoir.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: PremiumDesign.spacingL),
          // Toggle Dark Mode premium
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return PremiumCard(
                padding: EdgeInsets.zero,
                child: SwitchListTile(
                  title: Text(
                    'Mode sombre',
                    style: PremiumDesign.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    themeProvider.themeMode == ThemeMode.dark
                        ? 'Actif'
                        : themeProvider.themeMode == ThemeMode.light
                            ? 'Désactivé'
                            : 'Suivre le système',
                    style: PremiumDesign.bodySmall.copyWith(
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                  secondary: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(PremiumDesign.radiusS),
                    ),
                    child: Icon(
                      themeProvider.themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
              );
            },
          ),
          const SizedBox(height: PremiumDesign.spacingM),
          _buildNotificationSwitchPremium(
            'Notifications par email',
            'email_notifications',
            Icons.email,
          ),
          _buildNotificationSwitchPremium(
            'Notifications push',
            'push_notifications',
            Icons.notifications_active,
          ),
          const SizedBox(height: PremiumDesign.spacingM),
          _buildNotificationSwitchPremium(
            'Rappels d\'événements',
            'event_reminders',
            Icons.event,
          ),
          _buildNotificationSwitchPremium(
            'Demandes d\'ami',
            'friend_requests',
            Icons.person_add,
          ),
          _buildNotificationSwitchPremium(
            'Messages',
            'messages',
            Icons.message,
          ),
          _buildNotificationSwitchPremium(
            'Mises à jour de groupes',
            'group_updates',
            Icons.group,
          ),
          _buildNotificationSwitchPremium(
            'Invitations à des événements',
            'event_invitations',
            Icons.event_available,
          ),
          const SizedBox(height: PremiumDesign.spacingXL),
          PremiumButton(
            text: 'Enregistrer les préférences',
            onPressed: _isSavingPrefs ? null : _saveNotificationPreferences,
            isLoading: _isSavingPrefs,
            icon: Icons.save,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSwitchPremium(String title, String key, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return PremiumCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: PremiumDesign.spacingS),
      child: SwitchListTile(
        title: Text(
          title,
          style: PremiumDesign.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          _getNotificationDescription(key),
          style: PremiumDesign.bodySmall.copyWith(
            color: isDark ? Colors.white54 : AppColors.textSecondary,
          ),
        ),
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(PremiumDesign.radiusS),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        value: _notificationPrefs[key] ?? true,
        onChanged: (value) {
          setState(() {
            _notificationPrefs[key] = value;
          });
        },
      ),
    );
  }

  String _getNotificationDescription(String key) {
    switch (key) {
      case 'email_notifications':
        return 'Recevoir des notifications par email';
      case 'push_notifications':
        return 'Recevoir des notifications push sur votre appareil';
      case 'event_reminders':
        return 'Rappels avant le début des événements';
      case 'friend_requests':
        return 'Notifications pour les demandes d\'ami';
      case 'messages':
        return 'Notifications pour les nouveaux messages';
      case 'group_updates':
        return 'Notifications pour les mises à jour de groupes';
      case 'event_invitations':
        return 'Notifications pour les invitations à des événements';
      default:
        return '';
    }
  }
}

