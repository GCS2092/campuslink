import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';
import 'api_config.dart';

/// Service de base pour communiquer avec l'API Django
/// Gère automatiquement l'authentification JWT et le refresh token.
/// L'URL de base est résolue automatiquement selon le réseau (WiFi / local ou production).
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String _baseUrl = AppConstants.apiBaseUrl;
  bool _initialized = false;
  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})> _pendingRequests = [];

  /// URL de base actuelle (résolue selon le réseau). À utiliser pour construire les URLs d'images.
  String get baseUrl => _baseUrl;

  /// Initialise le service API : résout l'URL selon le réseau puis configure Dio.
  Future<void> initialize() async {
    if (_initialized) return;
    _baseUrl = await ApiConfig.resolveBaseUrl();
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _initialized = true;

    // Intercepteur pour ajouter le token JWT dans les headers
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Récupérer le token depuis le stockage local
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.accessTokenKey);
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Si erreur 401 (Unauthorized), essayer de rafraîchir le token
          if (error.response?.statusCode == 401) {
            return _handle401Error(error, handler);
          }
          
          return handler.next(error);
        },
      ),
    );

    // Intercepteur pour logger les requêtes (en développement)
    // Réduit la verbosité pour éviter de polluer la console
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _dio.interceptors.add(LogInterceptor(
        request: false, // Ne pas afficher les détails de la requête
        requestHeader: false, // Ne pas afficher les headers
        requestBody: false, // Ne pas afficher le body de la requête
        responseHeader: false, // Ne pas afficher les headers de réponse
        responseBody: false, // Ne pas afficher le body de réponse
        error: true, // Afficher seulement les erreurs
        logPrint: (obj) {
          // Logger seulement les erreurs importantes
          if (obj.toString().contains('Error') || 
              obj.toString().contains('Exception') ||
              obj.toString().contains('Failed')) {
            debugPrint(obj.toString());
          }
        },
      ));
    }
  }

  /// Gère les erreurs 401 en rafraîchissant le token
  Future<void> _handle401Error(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = error.requestOptions;

    // Si on est déjà en train de rafraîchir, mettre la requête en attente
    if (_isRefreshing) {
      return _pendingRequests.add((options: requestOptions, handler: handler));
    }

    _isRefreshing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(AppConstants.refreshTokenKey);

      if (refreshToken == null) {
        // Pas de refresh token, déconnecter l'utilisateur
        await _clearTokens();
        return handler.reject(error);
      }

      // Essayer de rafraîchir le token
      final response = await _dio.post(
        AppConstants.refreshTokenEndpoint,
        data: {'refresh': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'] as String;
        final newRefreshToken = response.data['refresh'] as String?;

        // Sauvegarder les nouveaux tokens
        await prefs.setString(AppConstants.accessTokenKey, newAccessToken);
        if (newRefreshToken != null) {
          await prefs.setString(AppConstants.refreshTokenKey, newRefreshToken);
        }

        // Mettre à jour le header de la requête originale
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        // Réessayer la requête originale
        final retryResponse = await _dio.fetch(requestOptions);
        handler.resolve(retryResponse);

        // Traiter les requêtes en attente
        _processPendingRequests(newAccessToken);
      } else {
        // Refresh échoué, déconnecter
        await _clearTokens();
        handler.reject(error);
      }
    } catch (e) {
      // Erreur lors du refresh, déconnecter
      await _clearTokens();
      handler.reject(error);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Traite les requêtes en attente après un refresh réussi
  Future<void> _processPendingRequests(String newToken) async {
    for (final pending in _pendingRequests) {
      pending.options.headers['Authorization'] = 'Bearer $newToken';
      try {
        final response = await _dio.fetch(pending.options);
        pending.handler.resolve(response);
      } catch (e) {
        pending.handler.reject(
          DioException(
            requestOptions: pending.options,
            error: e,
          ),
        );
      }
    }
    _pendingRequests.clear();
  }

  /// Supprime les tokens du stockage local
  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.accessTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.userDataKey);
  }

  /// Vérifie si l'erreur est due à une absence de connexion
  bool isOfflineError(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.connectionError ||
           (error.error != null && error.error.toString().contains('SocketException'));
  }

  /// GET request avec support du mode hors ligne
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (isOfflineError(e)) {
        debugPrint('Offline mode: Cannot fetch $path');
        // Lancer une exception spéciale pour indiquer le mode hors ligne
        rethrow;
      }
      rethrow;
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Supprime les tokens (pour logout)
  Future<void> clearTokens() => _clearTokens();
}

