import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import 'settings_screen.dart';
import 'friends_screen.dart';
import 'my_events_screen.dart';
import 'groups_screen.dart';
import 'notifications_screen.dart';
import 'feed_screen.dart';
import 'students_screen.dart';
import 'conversations_screen.dart';

/// Écran de profil - Design épuré et professionnel style GoBus (bleu)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _getProfilePictureUrl(User user) {
    if (user.profile == null) return null;
    final profilePicture = user.profile!['profile_picture'];
    if (profilePicture is String && profilePicture.isNotEmpty) {
      return profilePicture;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Couleur bleue pas trop foncée (style GoBus mais en bleu)
    const primaryBlue = Color(0xFF4A90E2); // Bleu clair professionnel
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: Text(
          'Mon Profil',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authProvider.user!;
          final profilePictureUrl = _getProfilePictureUrl(user);
          final String? imageUrl = profilePictureUrl;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header avec photo de profil et informations
                Container(
                  width: double.infinity,
                  color: primaryBlue,
                  padding: const EdgeInsets.only(
                    top: 20,
                    bottom: 30,
                  ),
                  child: Column(
                    children: [
                      // Photo de profil
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: imageUrl != null
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => _AvatarPlaceholder(
                                    initial: user.username.isNotEmpty
                                        ? user.username[0].toUpperCase()
                                        : 'U',
                                    color: primaryBlue,
                                  ),
                                ),
                              )
                            : _AvatarPlaceholder(
                                initial: user.username.isNotEmpty
                                    ? user.username[0].toUpperCase()
                                    : 'U',
                                color: primaryBlue,
                              ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1.0, 1.0),
                            duration: 500.ms,
                          ),
                      const SizedBox(height: 16),
                      // Nom
                      Text(
                        user.fullName,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms),
                      const SizedBox(height: 4),
                      // Email
                      Text(
                        user.email,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 400.ms),
                    ],
                  ),
                ),

                // Liste des options - Fonctionnalités réelles de CampusLink
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      _AccountOption(
                        icon: Icons.people_outlined,
                        title: 'Mes amis',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FriendsScreen(),
                            ),
                          );
                        },
                        color: primaryBlue,
                      ),
                      _AccountOption(
                        icon: Icons.event_outlined,
                        title: 'Mes événements',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyEventsScreen(),
                            ),
                          );
                        },
                        color: primaryBlue,
                      ),
                      _AccountOption(
                        icon: Icons.group_outlined,
                        title: 'Mes groupes',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GroupsScreen(),
                            ),
                          );
                        },
                        color: primaryBlue,
                      ),
                      _AccountOption(
                        icon: Icons.chat_bubble_outline,
                        title: 'Messages',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ConversationsScreen(),
                            ),
                          );
                        },
                        color: primaryBlue,
                      ),
                      _AccountOption(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                        color: primaryBlue,
                      ),
                      _AccountOption(
                        icon: Icons.article_outlined,
                        title: 'Actualités',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FeedScreen(),
                            ),
                          );
                        },
                        color: primaryBlue,
                      ),
                      _AccountOption(
                        icon: Icons.school_outlined,
                        title: 'Étudiants',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StudentsScreen(),
                            ),
                          );
                        },
                        color: primaryBlue,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),

                // Section paramètres
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      _AccountOption(
                        icon: Icons.edit_outlined,
                        title: 'Modifier le profil',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                        color: primaryBlue,
                      ),
                      _AccountOption(
                        icon: Icons.settings_outlined,
                        title: 'Paramètres',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                        color: primaryBlue,
                      ),
                      _AccountOption(
                        icon: Icons.logout_outlined,
                        title: 'Déconnexion',
                        onTap: _handleLogout,
                        color: Colors.red,
                        isDestructive: true,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Déconnexion',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: GoogleFonts.inter(
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annuler',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(
              'Déconnexion',
              style: GoogleFonts.inter(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }
}

/// Placeholder avatar
class _AvatarPlaceholder extends StatelessWidget {
  final String initial;
  final Color color;

  const _AvatarPlaceholder({
    required this.initial,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.inter(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Option de compte - Style GoBus épuré
class _AccountOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;
  final bool isDestructive;

  const _AccountOption({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.color,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Row(
            children: [
              // Icône
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isDestructive ? Colors.red : color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? Colors.red : color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              // Titre
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? Colors.red : const Color(0xFF2F4F4F),
                  ),
                ),
              ),
              // Flèche
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
