import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/events_screen.dart';
import '../screens/event_detail_screen.dart';
import '../screens/create_event_screen.dart';
import '../screens/conversations_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/students_screen.dart';
import '../screens/user_detail_screen.dart';
import '../screens/groups_screen.dart';
import '../screens/group_detail_screen.dart';
import '../screens/create_group_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/feed_screen.dart';
import '../screens/social_feed_screen.dart';
import '../screens/friends_screen.dart';
import '../screens/friend_requests_screen.dart';
import '../screens/class_leader/class_leader_dashboard_screen.dart';
import '../screens/university_admin/university_admin_dashboard_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/search_screen.dart';
import '../screens/my_events_screen.dart';
import '../screens/friends_activity_screen.dart';
import '../screens/events_map_screen.dart';
import '../screens/group_members_screen.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Routes de l'application
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String events = '/events';
  static const String eventDetail = '/events/:id';
  static const String conversations = '/conversations';
  static const String chat = '/chat/:id';
  static const String students = '/students';
  static const String groups = '/groups';
  static const String notifications = '/notifications';
  static const String feed = '/feed';
  static const String socialFeed = '/social-feed';
  static const String friends = '/friends';
  static const String friendRequests = '/friend-requests';
  static const String classLeaderDashboard = '/class-leader/dashboard';
  static const String universityAdminDashboard = '/university-admin/dashboard';

  /// Génère les routes de l'application
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/': (context) => Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isLoading && !authProvider.isAuthenticated) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (authProvider.isAuthenticated) {
                return const DashboardScreen();
              }
              return const LoginScreen();
            },
          ),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      dashboard: (context) => const DashboardScreen(),
      profile: (context) => const ProfileScreen(),
      events: (context) => const EventsScreen(),
      conversations: (context) => const ConversationsScreen(),
      students: (context) => const StudentsScreen(),
      groups: (context) => const GroupsScreen(),
      notifications: (context) => const NotificationsScreen(),
      feed: (context) => const FeedScreen(),
      socialFeed: (context) => const SocialFeedScreen(),
      friends: (context) => const FriendsScreen(),
      friendRequests: (context) => const FriendRequestsScreen(),
      classLeaderDashboard: (context) => const ClassLeaderDashboardScreen(),
      universityAdminDashboard: (context) => const UniversityAdminDashboardScreen(),
    };
  }

  /// Navigation vers le dashboard
  static void navigateToDashboard(BuildContext context) {
    Navigator.pushReplacementNamed(context, dashboard);
  }

  /// Navigation vers les événements
  static void navigateToEvents(BuildContext context) {
    Navigator.pushNamed(context, events);
  }

  /// Navigation vers les détails d'un événement
  static void navigateToEventDetail(BuildContext context, String eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(eventId: eventId),
      ),
    );
  }

  /// Navigation vers les conversations
  static void navigateToConversations(BuildContext context) {
    Navigator.pushNamed(context, conversations);
  }

  /// Navigation vers un chat
  static void navigateToChat(
    BuildContext context,
    String conversationId,
    String conversationName,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversationId: conversationId,
          conversationName: conversationName,
        ),
      ),
    );
  }

  /// Navigation vers le profil utilisateur
  static void navigateToUserDetail(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailScreen(userId: userId),
      ),
    );
  }

  /// Navigation vers les détails d'un groupe
  static void navigateToGroupDetail(BuildContext context, String groupId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailScreen(groupId: groupId),
      ),
    );
  }

  /// Navigation vers la création d'événement
  static void navigateToCreateEvent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEventScreen(),
      ),
    );
  }

  /// Navigation vers la création de groupe
  static void navigateToCreateGroup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateGroupScreen(),
      ),
    );
  }
}

