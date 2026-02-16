import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Résout l'URL de base de l'API en fonction du réseau détecté (WiFi / connexion).
/// En priorité : backend local sur le même réseau, sinon production (Render).
class ApiConfig {
  ApiConfig._();
  static const _cacheKey = 'campuslink_api_base_url';
  static const _cacheTsKey = 'campuslink_api_base_url_ts';
  static const _cacheTtlSeconds = 300; // 5 min

  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 2),
    receiveTimeout: const Duration(seconds: 2),
  ));

  /// Construit la liste des URLs candidates : locales (selon IP WiFi) puis production.
  static Future<List<String>> _candidates() async {
    const production = 'https://campuslink-9knz.onrender.com/api';
    final list = <String>[];

    try {
      final info = NetworkInfo();
      final wifiIp = await info.getWifiIP();
      if (wifiIp != null &&
          wifiIp.isNotEmpty &&
          wifiIp != '0.0.0.0' &&
          !wifiIp.startsWith('127.')) {
        // Même sous-réseau : .1 (box), .125, .100, .50, .35
        final parts = wifiIp.split('.');
        if (parts.length == 4) {
          final prefix = '${parts[0]}.${parts[1]}.${parts[2]}.';
          for (final host in ['1', '2', '10', '35', '50', '100', '125', '127', '200', '254']) {
            list.add('http://${prefix}$host:8000/api');
          }
        }
      }
    } catch (_) {}

    // Émulateur Android
    list.add('http://10.0.2.2:8000/api');
    list.add(production);
    return list;
  }

  static Future<bool> _tryBaseUrl(String baseUrl) async {
    try {
      final url = baseUrl.endsWith('/') ? '${baseUrl}auth/login/' : '$baseUrl/auth/login/';
      final r = await _dio.get<dynamic>(
        url,
        options: Options(
          validateStatus: (s) => s == 200 || s == 405,
          receiveDataWhenStatusError: true,
        ),
      );
      // 200 = endpoint existe, 405 = GET non autorisé (login attend POST) → c'est notre API
      return r.statusCode == 200 || r.statusCode == 405;
    } catch (_) {
      return false;
    }
  }

  /// Résout l'URL de base : utilise le cache si valide, sinon détecte et met en cache.
  static Future<String> resolveBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    final ts = prefs.getInt(_cacheTsKey);
    if (cached != null &&
        ts != null &&
        (DateTime.now().millisecondsSinceEpoch - ts) < _cacheTtlSeconds * 1000) {
      if (kDebugMode) {
        debugPrint('[ApiConfig] Using cached base URL: $cached');
      }
      return cached;
    }

    final candidates = await _candidates();
    for (final url in candidates) {
      if (await _tryBaseUrl(url)) {
        await prefs.setString(_cacheKey, url);
        await prefs.setInt(_cacheTsKey, DateTime.now().millisecondsSinceEpoch);
        if (kDebugMode) {
          debugPrint('[ApiConfig] Resolved base URL: $url');
        }
        return url;
      }
    }

    final fallback = AppConstants.apiBaseUrl;
    await prefs.setString(_cacheKey, fallback);
    await prefs.setInt(_cacheTsKey, DateTime.now().millisecondsSinceEpoch);
    if (kDebugMode) {
      debugPrint('[ApiConfig] Fallback to production: $fallback');
    }
    return fallback;
  }

  /// Invalide le cache (utile après changement de réseau).
  static Future<void> invalidateCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTsKey);
  }
}
