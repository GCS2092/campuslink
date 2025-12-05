import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../services/social_service.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import 'create_post_screen.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  final SocialService _socialService = SocialService();
  List<Post> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _socialService.getPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading posts: $e');
      setState(() {
        _posts = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLikePost(String postId, bool isLiked) async {
    try {
      if (isLiked) {
        await _socialService.unlikePost(postId);
      } else {
        await _socialService.likePost(postId);
      }
      await _loadPosts();
    } catch (e) {
      debugPrint('Error liking post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fil d\'actualité'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePostScreen()),
              ).then((_) => _loadPosts());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article_outlined, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun post',
                        style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPosts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return _PostCard(
                        post: post,
                        onLike: () => _handleLikePost(post.id, post.isLiked ?? false),
                      );
                    },
                  ),
                ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;

  const _PostCard({
    required this.post,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    post.author.username[0].toUpperCase(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author.fullName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy à HH:mm').format(post.createdAt),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.content,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
            ),
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl!.startsWith('http')
                      ? post.imageUrl!
                      : '${AppConstants.apiBaseUrl.replaceAll('/api', '')}${post.imageUrl}',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: AppColors.border,
                      child: const Icon(Icons.image, size: 64, color: AppColors.textSecondary),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.isLiked == true ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked == true ? AppColors.error : AppColors.textSecondary,
                  ),
                  onPressed: onLike,
                ),
                Text('${post.likesCount}'),
                const SizedBox(width: 16),
                const Icon(Icons.comment_outlined, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${post.commentsCount}'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary),
                  onPressed: () {
                    // TODO: Partager le post
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

