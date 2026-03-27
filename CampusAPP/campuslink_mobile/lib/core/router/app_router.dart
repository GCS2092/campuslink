import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/screens/role_based_dashboard_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/feed/screens/feed_screen.dart';
import '../../features/events/screens/events_screen.dart';
import '../../features/events/screens/event_detail_screen.dart';
import '../../features/groups/screens/groups_screen.dart';
import '../../features/groups/screens/group_detail_screen.dart';
import '../../features/messaging/screens/conversations_screen.dart';
import '../../features/messaging/screens/chat_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../widgets/main_shell.dart';

class AppRoutes {
  static const String splash        = '/';
  static const String login         = '/login';
  static const String register      = '/register';
  static const String otp           = '/otp';
  static const String feed          = '/feed';
  static const String events        = '/events';
  static const String groups        = '/groups';
  static const String conversations = '/messages';
  static const String notifications = '/notifications';
  static const String profile       = '/profile';
  static const String admin         = '/admin';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuth      = authState.isAuthenticated;
      final isAuthRoute = [AppRoutes.login, AppRoutes.register, AppRoutes.otp]
          .contains(state.matchedLocation);
      final isSplash    = state.matchedLocation == AppRoutes.splash;
      if (isSplash)               return null;
      if (!isAuth && !isAuthRoute) return AppRoutes.login;
      if (isAuth && isAuthRoute)   return AppRoutes.feed;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash,   builder: (_, _) => const SplashScreen()),
      GoRoute(path: AppRoutes.login,    builder: (_, _) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, _) => const RegisterScreen()),
      GoRoute(path: AppRoutes.admin,    builder: (_, _) => const RoleBasedDashboardScreen()),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) => OtpScreen(email: state.extra as String? ?? ''),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.feed,  builder: (_, _) => const FeedScreen()),
          GoRoute(
            path: AppRoutes.events,
            builder: (_, _) => const EventsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => EventDetailScreen(eventId: int.parse(state.pathParameters['id']!)),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.groups,
            builder: (_, _) => const GroupsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => GroupDetailScreen(groupId: int.parse(state.pathParameters['id']!)),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.conversations,
            builder: (_, _) => const ConversationsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => ChatScreen(conversationId: int.parse(state.pathParameters['id']!)),
              ),
            ],
          ),
          GoRoute(path: AppRoutes.notifications, builder: (_, _) => const NotificationsScreen()),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, _) => const ProfileScreen(),
            routes: [
              GoRoute(path: 'edit', builder: (_, _) => const EditProfileScreen()),
            ],
          ),
        ],
      ),
      // Admin routes (outside MainShell for full-screen admin interface)
      GoRoute(
        path: AppRoutes.admin,
        builder: (_, _) => const RoleBasedDashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page introuvable: ${state.error}')),
    ),
  );
});
