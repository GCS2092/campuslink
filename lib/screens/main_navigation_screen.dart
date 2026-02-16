import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';

/// Écran principal avec navigation en bas
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  void _initializeScreens() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    // Ne jamais afficher les onglets admin pour un étudiant
    _isAdmin = (user != null && user.isStudent) ? false : (user?.isAdmin ?? false);

    _screens = [
      CustomBottomNavigationBar.getScreenForIndex(0, isAdmin: _isAdmin),
      CustomBottomNavigationBar.getScreenForIndex(1, isAdmin: _isAdmin),
      CustomBottomNavigationBar.getScreenForIndex(2, isAdmin: _isAdmin),
      CustomBottomNavigationBar.getScreenForIndex(3, isAdmin: _isAdmin),
      CustomBottomNavigationBar.getScreenForIndex(4, isAdmin: _isAdmin),
      CustomBottomNavigationBar.getScreenForIndex(5, isAdmin: _isAdmin),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final isAdmin = (user != null && user.isStudent)
            ? false
            : (user?.isAdmin ?? false);

        // Si le statut admin a changé, réinitialiser les écrans
        if (isAdmin != _isAdmin) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _isAdmin = isAdmin;
              _initializeScreens();
            });
          });
        }

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            isAdmin: isAdmin,
          ),
        );
      },
    );
  }
}

/// Widget wrapper pour ajouter un padding en bas pour la navigation
class BottomNavWrapper extends StatelessWidget {
  final Widget child;

  const BottomNavWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 70), // Hauteur de la navigation en bas
      child: child,
    );
  }
}

