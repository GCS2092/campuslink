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

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    int? userId,
    String? email,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userId: userId ?? this.userId,
      email: email ?? this.email,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  bool _ready = false;

  @override
  AuthState build() {
    Future.microtask(_checkAuth);
    return const AuthState();
  }

  Future<void> waitUntilReady() async {
    while (!_ready) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> _checkAuth() async {
    final storage = ref.read(storageServiceProvider);
    try {
      state = state.copyWith(isLoading: true);
      final isLoggedIn = await storage.isLoggedIn();
      if (isLoggedIn) {
        final token  = await storage.getAccessToken();
        final userId = await storage.getUserId();
        final email  = await storage.getUserEmail();
        if (token != null) DioClient.setToken(token);
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userId: userId != null ? int.tryParse(userId) : null,
          email: email,
        );
      } else {
        state = state.copyWith(isAuthenticated: false, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
    } finally {
      _ready = true;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    final storage = ref.read(storageServiceProvider);
    final dio     = ref.read(dioClientProvider);
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await dio.post(ApiConstants.login, data: {'email': email, 'password': password});
      final data = response.data;
      if (data == null) throw Exception("Réponse vide");
      final access  = data['access'];
      final refresh = data['refresh'];
      final user    = data['user'];
      if (access == null || refresh == null || user == null) throw Exception("Réponse API invalide");
      await storage.saveTokens(accessToken: access, refreshToken: refresh);
      DioClient.setToken(access); // ✅ token en mémoire immédiatement
      await storage.saveUserId(user['id'].toString());
      await storage.saveUserEmail(email);
      state = state.copyWith(isAuthenticated: true, isLoading: false, userId: user['id'], email: email);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> register({required String email, required String password, required String firstName, required String lastName}) async {
    final dio = ref.read(dioClientProvider);
    try {
      state = state.copyWith(isLoading: true, error: null);
      await dio.post(ApiConstants.register, data: {'email': email, 'password': password, 'first_name': firstName, 'last_name': lastName});
      state = state.copyWith(isLoading: false, email: email);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    final storage = ref.read(storageServiceProvider);
    final dio     = ref.read(dioClientProvider);
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await dio.post(ApiConstants.verifyOtp, data: {'email': email, 'otp': otp});
      final data = response.data;
      await storage.saveTokens(accessToken: data['access'], refreshToken: data['refresh']);
      DioClient.setToken(data['access']); // ✅ token en mémoire immédiatement
      await storage.saveUserId(data['user']['id'].toString());
      await storage.saveUserEmail(email);
      state = state.copyWith(isAuthenticated: true, isLoading: false, userId: data['user']['id'], email: email);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<void> logout() async {
    final storage = ref.read(storageServiceProvider);
    await storage.clearAll();
    DioClient.clearToken(); // ✅ vider le token en mémoire
    state = const AuthState();
  }

  String _parseError(dynamic e) {
    try {
      final data = (e as dynamic).response?.data;
      if (data is Map) return data['detail'] ?? data['message'] ?? data.values.first.toString();
    } catch (_) {}
    return 'Une erreur est survenue. Vérifie ta connexion.';
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());