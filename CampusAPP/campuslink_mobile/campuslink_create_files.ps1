# ============================================================
# CAMPUSLINK — Creation de tous les fichiers core
# A executer depuis : campuslink_mobile\
# -Force evite les erreurs si le fichier existe deja
# ============================================================


# ════════════════════════════════════════════════════════════
# DOSSIERS MANQUANTS (au cas ou)
# ════════════════════════════════════════════════════════════
New-Item -ItemType Directory -Force -Path "lib\core\router"
New-Item -ItemType Directory -Force -Path "lib\core\widgets"
New-Item -ItemType Directory -Force -Path "lib\core\network"
New-Item -ItemType Directory -Force -Path "lib\core\storage"
New-Item -ItemType Directory -Force -Path "lib\core\constants"
New-Item -ItemType Directory -Force -Path "lib\core\theme"
New-Item -ItemType Directory -Force -Path "lib\features\auth\providers"
New-Item -ItemType Directory -Force -Path "lib\features\auth\screens"
New-Item -ItemType Directory -Force -Path "lib\features\feed\screens"
New-Item -ItemType Directory -Force -Path "lib\features\events\screens"
New-Item -ItemType Directory -Force -Path "lib\features\groups\screens"
New-Item -ItemType Directory -Force -Path "lib\features\messaging\screens"
New-Item -ItemType Directory -Force -Path "lib\features\notifications\screens"
New-Item -ItemType Directory -Force -Path "lib\features\profile\screens"
Write-Host "Dossiers OK" -ForegroundColor Green


# ════════════════════════════════════════════════════════════
# 1. main.dart
# ════════════════════════════════════════════════════════════
@'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: CampusLinkApp(),
    ),
  );
}
'@ | Set-Content "lib\main.dart" -Encoding UTF8
Write-Host "main.dart OK" -ForegroundColor Green


# ════════════════════════════════════════════════════════════
# 2. app.dart
# ════════════════════════════════════════════════════════════
@'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class CampusLinkApp extends ConsumerWidget {
  const CampusLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'CampusLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
'@ | Set-Content "lib\app.dart" -Encoding UTF8
Write-Host "app.dart OK" -ForegroundColor Green


# ════════════════════════════════════════════════════════════
# 3. core/theme/app_theme.dart
# ════════════════════════════════════════════════════════════
@'
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary      = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark  = Color(0xFF3730A3);
  static const Color secondary    = Color(0xFF10B981);
  static const Color error        = Color(0xFFEF4444);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color surface      = Color(0xFFF9FAFB);
  static const Color surfaceDark  = Color(0xFF111827);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      error: error,
      surface: surface,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF111827),
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF111827),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      color: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: error, width: 1)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: error, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primary,
      unselectedItemColor: Color(0xFF9CA3AF),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      backgroundColor: Colors.white,
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE5E7EB), thickness: 1, space: 1),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: primaryLight,
      secondary: secondary,
      error: error,
      surface: surfaceDark,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Color(0xFF111827),
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF374151)),
      ),
      color: const Color(0xFF1F2937),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1F2937),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryLight, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 15),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primaryLight,
      unselectedItemColor: Color(0xFF6B7280),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      backgroundColor: Color(0xFF111827),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF374151), thickness: 1, space: 1),
  );
}
'@ | Set-Content "lib\core\theme\app_theme.dart" -Encoding UTF8
Write-Host "app_theme.dart OK" -ForegroundColor Green


# ════════════════════════════════════════════════════════════
# 4. core/constants/api_constants.dart
# ════════════════════════════════════════════════════════════
@'
class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'ws://10.0.2.2:8000',
  );
  static const int connectTimeout = 10000;
  static const int receiveTimeout = 30000;

  // Auth
  static const String login        = '/auth/login/';
  static const String register     = '/auth/register/';
  static const String verifyOtp    = '/auth/verify-otp/';
  static const String resendOtp    = '/auth/resend-otp/';
  static const String tokenRefresh = '/auth/token/refresh/';
  static const String logout       = '/auth/logout/';
  static const String me           = '/auth/me/';

  // Feed
  static const String posts = '/feed/posts/';
  static String postLikeUrl(int id)    => '/feed/posts/$id/like/';
  static String postCommentUrl(int id) => '/feed/posts/$id/comments/';

  // Events
  static const String events = '/events/';
  static String eventJoinUrl(int id) => '/events/$id/join/';

  // Groups
  static const String groups = '/groups/';
  static String groupJoinUrl(int id)    => '/groups/$id/join/';
  static String groupMembersUrl(int id) => '/groups/$id/members/';

  // Messaging
  static const String conversations = '/messaging/conversations/';
  static const String messages      = '/messaging/messages/';

  // Notifications
  static const String notifications     = '/notifications/';
  static const String notificationsRead = '/notifications/mark-read/';

  // Profile
  static const String profile       = '/profile/';
  static const String profileUpdate = '/profile/update/';
  static const String profileAvatar = '/profile/avatar/';

  // WebSockets
  static String chatWs(int conversationId) => '$wsBaseUrl/ws/messaging/$conversationId/';
  static String notificationsWs()          => '$wsBaseUrl/ws/notifications/';
}
'@ | Set-Content "lib\core\constants\api_constants.dart" -Encoding UTF8
Write-Host "api_constants.dart OK" -ForegroundColor Green


# ════════════════════════════════════════════════════════════
# 5. core/constants/app_constants.dart
# ════════════════════════════════════════════════════════════
@'
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
'@ | Set-Content "lib\core\constants\app_constants.dart" -Encoding UTF8
Write-Host "app_constants.dart OK" -ForegroundColor Green


# ════════════════════════════════════════════════════════════
# 6. core/storage/storage_service.dart
# ════════════════════════════════════════════════════════════
@'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await Future.wait([
      _storage.write(key: AppConstants.accessTokenKey,  value: accessToken),
      _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken()  => _storage.read(key: AppConstants.accessTokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: AppConstants.refreshTokenKey);
  Future<void> saveAccessToken(String token) => _storage.write(key: AppConstants.accessTokenKey, value: token);

  Future<void> saveUserId(String id)       => _storage.write(key: AppConstants.userIdKey, value: id);
  Future<String?> getUserId()              => _storage.read(key: AppConstants.userIdKey);
  Future<void> saveUserEmail(String email) => _storage.write(key: AppConstants.userEmailKey, value: email);
  Future<String?> getUserEmail()           => _storage.read(key: AppConstants.userEmailKey);

  Future<void> clearAll()    => _storage.deleteAll();
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: AppConstants.accessTokenKey),
      _storage.delete(key: AppConstants.refreshTokenKey),
    ]);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
'@ | Set-Content "lib\core\storage\storage_service.dart" -Encoding UTF8
Write-Host "storage_service.dart OK" -ForegroundColor Green


# ════════════════════════════════════════════════════════════
# 7. core/network/dio_client.dart
# ════════════════════════════════════════════════════════════
@'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../storage/storage_service.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return DioClient(storage);
});

class DioClient {
  late final Dio _dio;
  final StorageService _storage;

  DioClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
    _dio.interceptors.addAll([
      _AuthInterceptor(_storage, _dio),
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    ]);
  }

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) =>
      _dio.get(path, queryParameters: queryParameters, options: options);

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) =>
      _dio.post(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response> put(String path, {dynamic data, Options? options}) =>
      _dio.put(path, data: data, options: options);

  Future<Response> patch(String path, {dynamic data, Options? options}) =>
      _dio.patch(path, data: data, options: options);

  Future<Response> delete(String path, {Options? options}) =>
      _dio.delete(path, options: options);

  Future<Response> postFormData(String path, FormData formData) =>
      _dio.post(path, data: formData, options: Options(contentType: 'multipart/form-data'));
}

class _AuthInterceptor extends Interceptor {
  final StorageService _storage;
  final Dio _dio;
  _AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        try {
          final response = await _dio.post(
            ApiConstants.tokenRefresh,
            data: {'refresh': refreshToken},
            options: Options(headers: {'Authorization': null}),
          );
          final newToken = response.data['access'];
          await _storage.saveAccessToken(newToken);
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retry = await _dio.fetch(err.requestOptions);
          handler.resolve(retry);
          return;
        } catch (_) {
          await _storage.clearAll();
        }
      }
    }
    handler.next(err);
  }
}
'@ | Set-Content "lib\core\network\dio_client.dart" -Encoding UTF8
Write-Host "dio_client.dart OK" -ForegroundColor Green


# ════════════════════════════════════════════════════════════
# 8. features/auth/providers/auth_provider.dart
# ════════════════════════════════════════════════════════════
@'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final int? userId;
  final String? email;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.userId,
    this.email,
  });

  AuthState copyWith({bool? isAuthenticated, bool? isLoading, String? error, int? userId, String? email}) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading:       isLoading       ?? this.isLoading,
        error:           error,
        userId:          userId          ?? this.userId,
        email:           email           ?? this.email,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final StorageService _storage;
  final DioClient _dio;

  AuthNotifier(this._storage, this._dio) : super(const AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    state = state.copyWith(isLoading: true);
    final isLoggedIn = await _storage.isLoggedIn();
    if (isLoggedIn) {
      final userId = await _storage.getUserId();
      final email  = await _storage.getUserEmail();
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        userId: userId != null ? int.tryParse(userId) : null,
        email: email,
      );
    } else {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post(ApiConstants.login, data: {'email': email, 'password': password});
      final data = response.data;
      await _storage.saveTokens(accessToken: data['access'], refreshToken: data['refresh']);
      await _storage.saveUserId(data['user']['id'].toString());
      await _storage.saveUserEmail(email);
      state = state.copyWith(isAuthenticated: true, isLoading: false, userId: data['user']['id'], email: email);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> register({required String email, required String password, required String firstName, required String lastName}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dio.post(ApiConstants.register, data: {'email': email, 'password': password, 'first_name': firstName, 'last_name': lastName});
      state = state.copyWith(isLoading: false, email: email);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post(ApiConstants.verifyOtp, data: {'email': email, 'otp': otp});
      final data = response.data;
      await _storage.saveTokens(accessToken: data['access'], refreshToken: data['refresh']);
      await _storage.saveUserId(data['user']['id'].toString());
      await _storage.saveUserEmail(email);
      state = state.copyWith(isAuthenticated: true, isLoading: false, userId: data['user']['id'], email: email);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    state = const AuthState();
  }

  String _parseError(dynamic e) {
    try {
      final data = (e as dynamic).response?.data;
      if (data is Map) return data['detail'] ?? data['message'] ?? data.values.first.toString();
    } catch (_) {}
    return 'Une erreur est survenue. Verifie ta connexion.';
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final dio     = ref.watch(dioClientProvider);
  return AuthNotifier(storage, dio);
});
'@ | Set-Content "lib\features\auth\providers\auth_provider.dart" -Encoding UTF8
Write-Host "auth_provider.dart OK" -ForegroundColor Green


# ════════════════════════════════════════════════════════════
# 9. core/router/app_router.dart
# ════════════════════════════════════════════════════════════
@'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      GoRoute(path: AppRoutes.splash,   builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.login,    builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) => OtpScreen(email: state.extra as String? ?? ''),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.feed,  builder: (_, __) => const FeedScreen()),
          GoRoute(
            path: AppRoutes.events,
            builder: (_, __) => const EventsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => EventDetailScreen(eventId: int.parse(state.pathParameters['id']!)),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.groups,
            builder: (_, __) => const GroupsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => GroupDetailScreen(groupId: int.parse(state.pathParameters['id']!)),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.conversations,
            builder: (_, __) => const ConversationsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => ChatScreen(conversationId: int.parse(state.pathParameters['id']!)),
              ),
            ],
          ),
          GoRoute(path: AppRoutes.notifications, builder: (_, __) => const NotificationsScreen()),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfileScreen(),
            routes: [
              GoRoute(path: 'edit', builder: (_, __) => const EditProfileScreen()),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page introuvable: ${state.error}')),
    ),
  );
});
'@ | Set-Content "lib\core\router\app_router.dart" -Encoding UTF8
Write-Host "app_router.dart OK" -ForegroundColor Green


# ════════════════════════════════════════════════════════════
# 10. core/widgets/main_shell.dart
# ════════════════════════════════════════════════════════════
@'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/feed'))          return 0;
    if (location.startsWith('/events'))        return 1;
    if (location.startsWith('/groups'))        return 2;
    if (location.startsWith('/messages'))      return 3;
    if (location.startsWith('/notifications')) return 4;
    if (location.startsWith('/profile'))       return 5;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go(AppRoutes.feed);          break;
      case 1: context.go(AppRoutes.events);        break;
      case 2: context.go(AppRoutes.groups);        break;
      case 3: context.go(AppRoutes.conversations); break;
      case 4: context.go(AppRoutes.notifications); break;
      case 5: context.go(AppRoutes.profile);       break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location     = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => _onTap(context, i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined),          selectedIcon: Icon(Icons.home),          label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.event_outlined),         selectedIcon: Icon(Icons.event),         label: 'Evenements'),
          NavigationDestination(icon: Icon(Icons.group_outlined),         selectedIcon: Icon(Icons.group),         label: 'Groupes'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline),    selectedIcon: Icon(Icons.chat_bubble),   label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Notifs'),
          NavigationDestination(icon: Icon(Icons.person_outline),         selectedIcon: Icon(Icons.person),        label: 'Profil'),
        ],
      ),
    );
  }
}
'@ | Set-Content "lib\core\widgets\main_shell.dart" -Encoding UTF8
Write-Host "main_shell.dart OK" -ForegroundColor Green


# ════════════════════════════════════════════════════════════
# 11. Ecrans Auth
# ════════════════════════════════════════════════════════════
@'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnim = Tween<double>(begin: 0.8, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final isAuth = ref.read(authStateProvider).isAuthenticated;
    context.go(isAuth ? AppRoutes.feed : AppRoutes.login);
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                  child: const Center(child: Text('CL', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppTheme.primary, fontFamily: 'Inter'))),
                ),
                const SizedBox(height: 20),
                const Text('CampusLink', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Inter')),
                const SizedBox(height: 8),
                Text('La plateforme etudiante', style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.8), fontFamily: 'Inter')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
'@ | Set-Content "lib\features\auth\screens\splash_screen.dart" -Encoding UTF8
Write-Host "splash_screen.dart OK" -ForegroundColor Green

@'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _emailCtrl.dispose(); _passwordCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authStateProvider.notifier).login(
      email: _emailCtrl.text.trim(), password: _passwordCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      context.go(AppRoutes.feed);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ref.read(authStateProvider).error ?? 'Erreur de connexion'),
        backgroundColor: AppTheme.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider).isLoading;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(16)),
                  child: const Center(child: Text('CL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20))),
                ),
                const SizedBox(height: 32),
                const Text('Bon retour !', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Connecte-toi a ton espace etudiant', style: TextStyle(fontSize: 15, color: Colors.grey[600])),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'Email universitaire', prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) { if (v == null || v.isEmpty) return 'Email requis'; if (!v.contains('@')) return 'Email invalide'; return null; },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) { if (v == null || v.isEmpty) return 'Mot de passe requis'; if (v.length < 6) return 'Minimum 6 caracteres'; return null; },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Se connecter'),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Pas encore de compte ?", style: TextStyle(color: Colors.grey[600])),
                    TextButton(onPressed: () => context.go(AppRoutes.register), child: const Text("S'inscrire")),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
'@ | Set-Content "lib\features\auth\screens\login_screen.dart" -Encoding UTF8
Write-Host "login_screen.dart OK" -ForegroundColor Green

@'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _firstNameCtrl.dispose(); _lastNameCtrl.dispose(); _emailCtrl.dispose();
    _passwordCtrl.dispose();  _confirmCtrl.dispose();  super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authStateProvider.notifier).register(
      email: _emailCtrl.text.trim(), password: _passwordCtrl.text,
      firstName: _firstNameCtrl.text.trim(), lastName: _lastNameCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      context.go(AppRoutes.otp, extra: _emailCtrl.text.trim());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ref.read(authStateProvider).error ?? 'Erreur inscription'),
        backgroundColor: AppTheme.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider).isLoading;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, leading: BackButton(onPressed: () => context.go(AppRoutes.login))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Creer un compte', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Rejoins ta communaute etudiante', style: TextStyle(fontSize: 15, color: Colors.grey[600])),
                const SizedBox(height: 32),
                Row(children: [
                  Expanded(child: TextFormField(controller: _firstNameCtrl, decoration: const InputDecoration(hintText: 'Prenom'), validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null)),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: _lastNameCtrl, decoration: const InputDecoration(hintText: 'Nom'), validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null)),
                ]),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'Email universitaire', prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) { if (v == null || v.isEmpty) return 'Email requis'; if (!v.contains('@')) return 'Email invalide'; return null; },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl, obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Mot de passe', prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscure = !_obscure)),
                  ),
                  validator: (v) { if (v == null || v.isEmpty) return 'Requis'; if (v.length < 8) return 'Minimum 8 caracteres'; return null; },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmCtrl, obscureText: _obscure,
                  decoration: const InputDecoration(hintText: 'Confirmer le mot de passe', prefixIcon: Icon(Icons.lock_outline)),
                  validator: (v) => v != _passwordCtrl.text ? 'Les mots de passe ne correspondent pas' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("S'inscrire"),
                  ),
                ),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Deja un compte ?", style: TextStyle(color: Colors.grey[600])),
                  TextButton(onPressed: () => context.go(AppRoutes.login), child: const Text("Se connecter")),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
'@ | Set-Content "lib\features\auth\screens\register_screen.dart" -Encoding UTF8
Write-Host "register_screen.dart OK" -ForegroundColor Green

@'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});
  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() { for (final c in _controllers) c.dispose(); for (final f in _focusNodes) f.dispose(); super.dispose(); }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _submit() async {
    if (_otp.length < 6) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entre les 6 chiffres du code'))); return; }
    final ok = await ref.read(authStateProvider.notifier).verifyOtp(email: widget.email, otp: _otp);
    if (!mounted) return;
    if (ok) {
      context.go(AppRoutes.feed);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ref.read(authStateProvider).error ?? 'Code invalide'), backgroundColor: AppTheme.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider).isLoading;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Verifie ton email', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Code envoye a\n${widget.email}', style: TextStyle(fontSize: 15, color: Colors.grey[600])),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) => SizedBox(
                  width: 48, height: 56,
                  child: TextFormField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      counterText: '',
                      fillColor: const Color(0xFFF3F4F6), filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
                    ),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 5) _focusNodes[i + 1].requestFocus();
                      if (v.isEmpty && i > 0)    _focusNodes[i - 1].requestFocus();
                      if (i == 5 && v.isNotEmpty) _submit();
                    },
                  ),
                )),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Verifier'),
                ),
              ),
              const SizedBox(height: 24),
              Center(child: TextButton(onPressed: () {}, child: const Text('Renvoyer le code'))),
            ],
          ),
        ),
      ),
    );
  }
}
'@ | Set-Content "lib\features\auth\screens\otp_screen.dart" -Encoding UTF8
Write-Host "otp_screen.dart OK" -ForegroundColor Green


# ════════════════════════════════════════════════════════════
# 12. Ecrans placeholder
# ════════════════════════════════════════════════════════════
@'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Scaffold(appBar: AppBar(title: const Text('Accueil')), body: const Center(child: Text('Feed - a implementer')));
}
'@ | Set-Content "lib\features\feed\screens\feed_screen.dart" -Encoding UTF8

@'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Scaffold(appBar: AppBar(title: const Text('Evenements')), body: const Center(child: Text('Evenements - a implementer')));
}
'@ | Set-Content "lib\features\events\screens\events_screen.dart" -Encoding UTF8

@'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class EventDetailScreen extends ConsumerWidget {
  final int eventId;
  const EventDetailScreen({super.key, required this.eventId});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Scaffold(appBar: AppBar(title: Text('Evenement #$eventId')), body: Center(child: Text('Detail evenement $eventId')));
}
'@ | Set-Content "lib\features\events\screens\event_detail_screen.dart" -Encoding UTF8

@'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Scaffold(appBar: AppBar(title: const Text('Groupes')), body: const Center(child: Text('Groupes - a implementer')));
}
'@ | Set-Content "lib\features\groups\screens\groups_screen.dart" -Encoding UTF8

@'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class GroupDetailScreen extends ConsumerWidget {
  final int groupId;
  const GroupDetailScreen({super.key, required this.groupId});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Scaffold(appBar: AppBar(title: Text('Groupe #$groupId')), body: Center(child: Text('Detail groupe $groupId')));
}
'@ | Set-Content "lib\features\groups\screens\group_detail_screen.dart" -Encoding UTF8

@'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Scaffold(appBar: AppBar(title: const Text('Messages')), body: const Center(child: Text('Messagerie - a implementer')));
}
'@ | Set-Content "lib\features\messaging\screens\conversations_screen.dart" -Encoding UTF8

@'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class ChatScreen extends ConsumerWidget {
  final int conversationId;
  const ChatScreen({super.key, required this.conversationId});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Scaffold(appBar: AppBar(title: Text('Chat #$conversationId')), body: Center(child: Text('Chat $conversationId')));
}
'@ | Set-Content "lib\features\messaging\screens\chat_screen.dart" -Encoding UTF8

@'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Scaffold(appBar: AppBar(title: const Text('Notifications')), body: const Center(child: Text('Notifications - a implementer')));
}
'@ | Set-Content "lib\features\notifications\screens\notifications_screen.dart" -Encoding UTF8

@'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Scaffold(appBar: AppBar(title: const Text('Profil')), body: const Center(child: Text('Profil - a implementer')));
}
'@ | Set-Content "lib\features\profile\screens\profile_screen.dart" -Encoding UTF8

@'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Scaffold(appBar: AppBar(title: const Text('Modifier le profil')), body: const Center(child: Text('Edit profil - a implementer')));
}
'@ | Set-Content "lib\features\profile\screens\edit_profile_screen.dart" -Encoding UTF8

Write-Host "Tous les ecrans placeholder OK" -ForegroundColor Green


# ════════════════════════════════════════════════════════════
# VERIFICATION FINALE
# ════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " TOUS LES FICHIERS CREES - Lance maintenant:" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " flutter pub get" -ForegroundColor Yellow
Write-Host " flutter run" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan