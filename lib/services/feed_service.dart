import 'package:flutter/foundation.dart';
import '../models/feed_item.dart';
import 'api_service.dart';

/// Service pour gérer le feed
class FeedService {
  final ApiService _apiService = ApiService();

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

  /// Récupère le feed personnalisé
  Future<List<FeedItem>> getPersonalizedFeed() async {
    try {
      final response = await _apiService.get('/feed/personalized/');
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
      debugPrint('Error getting personalized feed: $e');
      return <FeedItem>[];
    }
  }
}

