import 'package:flutter/foundation.dart';
import '../models/feed_item.dart';
import 'api_service.dart';
import 'offline_cache_service.dart';
import 'package:dio/dio.dart';

/// Service pour gérer le feed
class FeedService {
  final ApiService _apiService = ApiService();
  final OfflineCacheService _cacheService = OfflineCacheService();

  /// Récupère les éléments du feed
  Future<List<FeedItem>> getFeedItems({
    String? type,
    String? university,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (type != null) params['type'] = type;
      if (university != null) params['university'] = university;

      final response = await _apiService.get(
        '/feed/',
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((f) => FeedItem.fromJson(f as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic> && data['results'] != null) {
          return (data['results'] as List).map((f) => FeedItem.fromJson(f as Map<String, dynamic>)).toList();
        }
      }
      return <FeedItem>[];
    } catch (e) {
      debugPrint('Error getting feed items: $e');
      return <FeedItem>[];
    }
  }

  /// Récupère le feed personnalisé (avec support hors ligne)
  Future<List<FeedItem>> getPersonalizedFeed() async {
    try {
      final response = await _apiService.get('/feed/personalized/');
      if (response.statusCode == 200) {
        final data = response.data;
        List<FeedItem> feedItems = [];
        
        if (data is List) {
          feedItems = data.map((f) => FeedItem.fromJson(f as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic> && data['results'] != null) {
          feedItems = (data['results'] as List).map((f) => FeedItem.fromJson(f as Map<String, dynamic>)).toList();
        }

        // Sauvegarder dans le cache
        if (feedItems.isNotEmpty) {
          await _cacheService.saveFeed(
            feedItems.map((f) => f.toJson()).toList(),
          );
        }

        return feedItems;
      }
      return <FeedItem>[];
    } on DioException catch (e) {
      // Mode hors ligne : récupérer depuis le cache
      if (_apiService.isOfflineError(e)) {
        debugPrint('Offline mode: Loading feed from cache');
        try {
          final cachedFeed = await _cacheService.getCachedFeed(limit: 20);
          if (cachedFeed.isNotEmpty) {
            return cachedFeed.map((f) => FeedItem.fromJson(f)).toList();
          }
        } catch (cacheError) {
          debugPrint('Error loading from cache: $cacheError');
        }
      }
      debugPrint('Error getting personalized feed: $e');
      return <FeedItem>[];
    } catch (e) {
      debugPrint('Error getting personalized feed: $e');
      return <FeedItem>[];
    }
  }
}

