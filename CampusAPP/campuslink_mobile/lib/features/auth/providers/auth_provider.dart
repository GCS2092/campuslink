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

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkAuth();
    return const AuthState();
  }

  Future<void> _checkAuth() async {
    state = state.copyWith(isLoading: true);
    final storage    = ref.read(storageServiceProvider);
    final isLoggedIn = await storage.isLoggedIn();
    if (isLoggedIn) {
      final userId = await storage.getUserId();
      final email  = await storage.getUserEmail();
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
    final storage = ref.read(storageServiceProvider);
    final dio     = ref.read(dioClientProvider);
    try {
      final response = await dio.post(ApiConstants.login, data: {'email': email, 'password': password});
      final data = response.data;
      await storage.saveTokens(accessToken: data['access'], refreshToken: data['refresh']);
      await storage.saveUserId(data['user']['id'].toString());
      await storage.saveUserEmail(email);
      state = state.copyWith(isAuthenticated: true, isLoading: false, userId: data['user']['id'], email: email);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> register({required String email, required String password, required String firstName, required String lastName}) async {
    state = state.copyWith(isLoading: true, error: null);
    final dio = ref.read(dioClientProvider);
    try {
      await dio.post(ApiConstants.register, data: {'email': email, 'password': password, 'first_name': firstName, 'last_name': lastName});
      state = state.copyWith(isLoading: false, email: email);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    state = state.copyWith(isLoading: true, error: null);
    final storage = ref.read(storageServiceProvider);
    final dio     = ref.read(dioClientProvider);
    try {
      final response = await dio.post(ApiConstants.verifyOtp, data: {'email': email, 'otp': otp});
      final data = response.data;
      await storage.saveTokens(accessToken: data['access'], refreshToken: data['refresh']);
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

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());
