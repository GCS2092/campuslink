/// Constants used throughout the CampusLink mobile application
class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'https://campuslink-9knz.onrender.com/api';
  
  // For local development, uncomment and use:
  // static const String apiBaseUrl = 'http://172.20.1.65:8000/api';
  // static const String apiBaseUrl = 'http://localhost:8000/api';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login/';
  static const String registerEndpoint = '/auth/register/';
  static const String profileEndpoint = '/auth/profile/';
  static const String refreshTokenEndpoint = '/auth/token/refresh/';
  static const String eventsEndpoint = '/events/';
  static const String messagesEndpoint = '/messaging/messages/';
  static const String conversationsEndpoint = '/messaging/conversations/';
  static const String notificationsEndpoint = '/notifications/';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // App Info
  static const String appName = 'CampusLink';
  static const String appVersion = '1.0.0';
}

