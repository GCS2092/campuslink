class AppConstants {
  static const String appName    = 'CampusLink';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String accessTokenKey  = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey       = 'user_id';
  static const String userEmailKey    = 'user_email';

  // Pagination
  static const int pageSize = 20;

  // Limites
  static const int maxPostLength      = 500;
  static const int maxBioLength       = 160;
  static const int maxGroupNameLength = 50;
  static const int maxImageSizeMb     = 5;

  // Animations
  static const Duration animFast   = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow   = Duration(milliseconds: 500);

  // Spacing
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;

  // Border radius
  static const double radiusSM   = 8.0;
  static const double radiusMD   = 12.0;
  static const double radiusLG   = 16.0;
  static const double radiusXL   = 24.0;
  static const double radiusFull = 999.0;
}
