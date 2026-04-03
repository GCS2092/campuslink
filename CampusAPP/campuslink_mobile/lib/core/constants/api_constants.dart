class ApiConstants {
  // Base URLs - These should be configured based on your environment
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'ws://localhost:8000',
  );
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 60000;

  // ============ AUTH ============
  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String tokenRefresh = '/auth/token/refresh/';
  static const String verifyPhone = '/auth/verify-phone/confirm/';
  static const String resendOtp = '/auth/verify-phone/';
  static const String verifyOtp = '/auth/verify-otp/';
  static const String verifyEmail = '/auth/verify-email/';
  static const String verificationStatus = '/auth/verification-status/';
  static const String profile = '/auth/profile/';
  static const String profileStats = '/auth/profile/stats/';
  static const String profileStatsDetailed = '/auth/profile/stats/detailed/';
  static const String changePassword = '/auth/profile/change-password/';
  static const String notificationPreferences = '/auth/profile/notification-preferences/';

  // ============ USERS ============
  static const String users = '/users/';
  static String userDetail(String id) => '/users/$id/';
  static const String universities = '/users/universities/';
  static const String campuses = '/users/campuses/';
  static const String departments = '/users/departments/';

  // ============ FRIENDS ============
  static const String friends = '/auth/friends/';
  static const String friendSuggestions = '/auth/friends/suggestions/';
  static const String friendRequests = '/auth/friends/requests/';
  static const String sendFriendRequest = '/auth/friends/request/';
  static String acceptFriendRequest(String id) => '/auth/friends/$id/accept/';
  static String rejectFriendRequest(String id) => '/auth/friends/$id/reject/';
  static String removeFriend(String id) => '/auth/friends/$id/';
  static String friendshipStatus(String userId) => '/auth/friends/status/$userId/';

  // ============ FEED ============
  static const String feed = '/feed/';
  static const String feedItems = '/feed/feed/';
  static String feedItemDetail(String id) => '/feed/feed/$id/';

  // ============ SOCIAL / POSTS ============
  static const String posts = '/social/posts/';
  static String postDetail(String id) => '/social/posts/$id/';
  static String postLike(String id) => '/social/posts/$id/like/';
  static String postComments(String id) => '/social/posts/$id/comments/';

  // ============ EVENTS ============
  static const String events = '/events/';
  static String eventDetail(String id) => '/events/$id/';
  static const String eventCategories = '/events/categories/';
  static String eventJoin(String id) => '/events/$id/participate/';
  static String eventLeave(String id) => '/events/$id/leave/';
  static String eventLike(String id) => '/events/$id/like/';
  static String eventParticipants(String id) => '/events/$id/participants/';
  static const String eventCalendar = '/events/calendar/';
  static const String eventFilterPreferences = '/events/filter-preferences/';

  // ============ GROUPS ============
  static const String groups = '/groups/';
  static String groupDetail(String id) => '/groups/$id/';
  static String groupJoin(String id) => '/groups/$id/join/';
  static String groupLeave(String id) => '/groups/$id/leave/';
  static String groupMembers(String id) => '/groups/$id/members/';
  static const String groupPosts = '/groups/group-posts/';

  // ============ MESSAGING ============
  static const String conversations = '/messaging/conversations/';
  static String conversationDetail(String id) => '/messaging/conversations/$id/';
  static const String messages = '/messaging/messages/';
  static String messageDetail(String id) => '/messaging/messages/$id/';
  static String conversationMessages(String conversationId) =>
      '/messaging/messages/?conversation=$conversationId';
  static String markConversationRead(String id) =>
      '/messaging/conversations/$id/mark-read/';

  // ============ NOTIFICATIONS ============
  static const String notifications = '/notifications/';
  static const String notificationsReadAll = '/notifications/read_all/';
  static String notificationDetail(String id) => '/notifications/$id/';
  static String notificationRead(String id) => '/notifications/$id/read/';

  // ============ WEBSOCKETS ============
  static String chatWs(String conversationId) =>
      '$wsBaseUrl/ws/messaging/$conversationId/';
  static String notificationsWs() => '$wsBaseUrl/ws/notifications/';

  // ============ ADMIN / UNIVERSITY ADMIN ============
  static const String pendingStudents = '/auth/admin/pending-students/';
  static String activateStudent(String id) => '/auth/admin/students/$id/activate/';
  static String deactivateStudent(String id) => '/auth/admin/students/$id/deactivate/';
  static const String adminDashboardStats = '/auth/admin/dashboard-stats/';
  static const String classLeaderDashboardStats = '/auth/class-leader/dashboard-stats/';
  static const String universityAdminDashboardStats =
      '/auth/university-admin/dashboard-stats/';
  static const String classLeaders = '/auth/admin/class-leaders/';
  static const String classLeadersByUniversity = '/auth/admin/class-leaders/by-university/';
  static String assignClassLeader(String id) => '/auth/admin/class-leaders/$id/assign/';
  static String revokeClassLeader(String id) => '/auth/admin/class-leaders/$id/revoke/';
  static const String createStudent = '/auth/university-admin/students/create/';

  // ============ MODERATION ============
  static const String reports = '/moderation/reports/';
  static const String moderations = '/moderation/moderations/';
}
