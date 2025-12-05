import 'package:flutter/foundation.dart';
import '../models/post.dart';
import 'api_service.dart';

/// Service pour gérer les posts sociaux
class SocialService {
  final ApiService _apiService = ApiService();

  /// Récupère la liste des posts
  Future<List<Post>> getPosts({
    String? postType,
    bool? isPublic,
    String? search,
    String? ordering,
    int? page,
    int? pageSize,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (postType != null) params['post_type'] = postType;
      if (isPublic != null) params['is_public'] = isPublic;
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (ordering != null) params['ordering'] = ordering;
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;

      final response = await _apiService.get(
        '/social/posts/',
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((p) => Post.fromJson(p as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic> && data['results'] != null) {
          return (data['results'] as List).map((p) => Post.fromJson(p as Map<String, dynamic>)).toList();
        }
      }
      return <Post>[];
    } catch (e) {
      debugPrint('Error getting posts: $e');
      return <Post>[];
    }
  }

  /// Récupère un post par son ID
  Future<Post?> getPost(String id) async {
    try {
      final response = await _apiService.get('/social/posts/$id/');
      if (response.statusCode == 200) {
        return Post.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting post $id: $e');
      return null;
    }
  }

  /// Crée un nouveau post
  Future<Post?> createPost(Map<String, dynamic> postData) async {
    try {
      final response = await _apiService.post('/social/posts/', data: postData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Post.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating post: $e');
      return null;
    }
  }

  /// Like un post
  Future<bool> likePost(String id) async {
    try {
      final response = await _apiService.post('/social/posts/$id/like/');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error liking post: $e');
      return false;
    }
  }

  /// Unlike un post
  Future<bool> unlikePost(String id) async {
    try {
      final response = await _apiService.delete('/social/posts/$id/unlike/');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error unliking post: $e');
      return false;
    }
  }

  /// Partage un post
  Future<bool> sharePost(String id) async {
    try {
      final response = await _apiService.post('/social/posts/$id/share/');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error sharing post: $e');
      return false;
    }
  }

  /// Récupère les commentaires d'un post
  Future<List<Map<String, dynamic>>> getPostComments(String postId) async {
    try {
      final response = await _apiService.get('/social/posts/$postId/comments/');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((c) => c as Map<String, dynamic>).toList();
        }
      }
      return <Map<String, dynamic>>[];
    } catch (e) {
      debugPrint('Error getting post comments: $e');
      return <Map<String, dynamic>>[];
    }
  }

  /// Ajoute un commentaire à un post
  Future<Map<String, dynamic>?> addComment(String postId, String content) async {
    try {
      final response = await _apiService.post(
        '/social/posts/$postId/comments/',
        data: {'content': content},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error adding comment: $e');
      return null;
    }
  }
}

