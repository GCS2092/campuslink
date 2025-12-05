import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// Service d'authentification pour gérer login, register, logout
class AuthService {
  final ApiService _apiService = ApiService();

  /// Login avec email et password
  /// Retourne les tokens et les informations de l'utilisateur
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        // Sauvegarder les tokens
        final accessToken = data['access'] as String;
        final refreshToken = data['refresh'] as String?;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.accessTokenKey, accessToken);
        if (refreshToken != null) {
          await prefs.setString(AppConstants.refreshTokenKey, refreshToken);
        }

        // Sauvegarder les données utilisateur si disponibles
        if (data.containsKey('user_id')) {
          final userData = {
            'id': data['user_id'],
            'email': data['email'] ?? email,
            'username': data['username'] ?? '',
          };
          await prefs.setString(
            AppConstants.userDataKey,
            jsonEncode(userData),
          );
        }

        return {
          'success': true,
          'access_token': accessToken,
          'refresh_token': refreshToken,
          'account_status': data['account_status'],
          'user_id': data['user_id'],
          'email': data['email'],
          'username': data['username'],
        };
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Inscription d'un nouvel utilisateur
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String passwordConfirm,
    required String phoneNumber,
    String? firstName,
    String? lastName,
    String? role,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.registerEndpoint,
        data: {
          'email': email,
          'username': username,
          'password': password,
          'password_confirm': passwordConfirm,
          'phone_number': phoneNumber,
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          if (role != null) 'role': role,
        },
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Inscription réussie',
          'user_id': response.data['user_id'],
        };
      } else {
        return {
          'success': false,
          'error': response.data['message'] ?? 'Erreur lors de l\'inscription',
          'errors': response.data['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Récupère le profil de l'utilisateur connecté
  Future<User?> getProfile() async {
    try {
      final response = await _apiService.get(AppConstants.profileEndpoint);

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting profile: $e');
      return null;
    }
  }

  /// Vérifie si l'utilisateur est connecté (a un token valide)
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Récupère le token d'accès depuis le stockage local
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.accessTokenKey);
  }

  /// Récupère le refresh token depuis le stockage local
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.refreshTokenKey);
  }

  /// Déconnexion : supprime les tokens
  Future<void> logout() async {
    await _apiService.clearTokens();
  }

  /// Vérifie le statut de vérification de l'utilisateur
  Future<Map<String, dynamic>?> getVerificationStatus() async {
    try {
      final response = await _apiService.get('/auth/verification-status/');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting verification status: $e');
      return null;
    }
  }

  /// Vérifie le numéro de téléphone avec un code OTP
  Future<Map<String, dynamic>> verifyPhone({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/verify-phone/confirm/',
        data: {
          'phone_number': phoneNumber,
          'otp_code': otpCode,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Téléphone vérifié',
        };
      } else {
        return {
          'success': false,
          'error': response.data['message'] ?? 'Code OTP invalide',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Renvoie un code OTP
  Future<Map<String, dynamic>> resendOTP(String phoneNumber) async {
    try {
      final response = await _apiService.post(
        '/auth/verify-phone/',
        data: {'phone_number': phoneNumber},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Code OTP renvoyé',
        };
      } else {
        return {
          'success': false,
          'error': response.data['message'] ?? 'Erreur lors de l\'envoi du code',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}

