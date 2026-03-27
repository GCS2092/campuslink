import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feed_model.dart';
import '../services/feed_service.dart';

// Provider for feed items
final feedItemsProvider = FutureProvider.family<List<FeedItem>, FeedFilterParams>((ref, params) async {
  final service = ref.watch(feedServiceProvider);
  return service.getFeed(
    type: params.type,
    university: params.university,
    visibility: params.visibility,
    page: params.page,
    pageSize: params.pageSize,
  );
});

// Provider for a single feed item
final feedItemProvider = FutureProvider.family<FeedItem, String>((ref, id) async {
  final service = ref.watch(feedServiceProvider);
  return service.getFeedItem(id);
});

// Provider for social posts
final postsProvider = FutureProvider.family<List<SocialPost>, PostFilterParams>((ref, params) async {
  final service = ref.watch(feedServiceProvider);
  return service.getPosts(
    author: params.author,
    search: params.search,
    page: params.page,
    pageSize: params.pageSize,
  );
});

// Provider for a single post
final postProvider = FutureProvider.family<SocialPost, String>((ref, id) async {
  final service = ref.watch(feedServiceProvider);
  return service.getPost(id);
});

// Provider for post comments
final postCommentsProvider = FutureProvider.family<List<Comment>, CommentParams>((ref, params) async {
  final service = ref.watch(feedServiceProvider);
  return service.getComments(params.postId, page: params.page, pageSize: params.pageSize);
});

// State notifier for feed with pagination
class FeedNotifier extends Notifier<FeedState> {
  FeedService get _service => ref.read(feedServiceProvider);

  @override
  FeedState build() => const FeedState();

  Future<void> loadFeed({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(page: 1, feedItems: []);
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newItems = await _service.getFeed(
        type: state.type,
        university: state.university,
        visibility: state.visibility,
        page: state.page,
        pageSize: state.pageSize,
      );

      final allItems = refresh ? newItems : [...state.feedItems, ...newItems];

      state = state.copyWith(
        feedItems: allItems,
        isLoading: false,
        hasMore: newItems.length == state.pageSize,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createFeedItem(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final newItem = await _service.createFeedItem(data);
      state = state.copyWith(
        feedItems: [newItem, ...state.feedItems],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _service.likePost(postId);
      // Update local state
      final updatedItems = state.feedItems.map((item) {
        if (item.id == postId) {
          return item.copyWith(
            isLiked: !item.isLiked,
            likesCount: item.isLiked ? item.likesCount - 1 : item.likesCount + 1,
          );
        }
        return item;
      }).toList();
      state = state.copyWith(feedItems: updatedItems);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setType(String? type) {
    state = state.copyWith(type: type, page: 1);
    loadFeed(refresh: true);
  }

  void setUniversity(String? university) {
    state = state.copyWith(university: university, page: 1);
    loadFeed(refresh: true);
  }

  void setVisibility(String? visibility) {
    state = state.copyWith(visibility: visibility, page: 1);
    loadFeed(refresh: true);
  }
}

final feedNotifierProvider = NotifierProvider<FeedNotifier, FeedState>(
  FeedNotifier.new,
);

// State notifier for posts
class PostsNotifier extends Notifier<PostsState> {
  FeedService get _service => ref.read(feedServiceProvider);

  @override
  PostsState build() => const PostsState();

  Future<void> loadPosts({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(page: 1, posts: []);
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newPosts = await _service.getPosts(
        author: state.author,
        search: state.search,
        page: state.page,
        pageSize: state.pageSize,
      );

      final allPosts = refresh ? newPosts : [...state.posts, ...newPosts];

      state = state.copyWith(
        posts: allPosts,
        isLoading: false,
        hasMore: newPosts.length == state.pageSize,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createPost(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final newPost = await _service.createPost(data);
      state = state.copyWith(
        posts: [newPost, ...state.posts],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _service.likePost(postId);
      // Update local state
      final updatedPosts = state.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            isLiked: !post.isLiked,
            likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
          );
        }
        return post;
      }).toList();
      state = state.copyWith(posts: updatedPosts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setAuthor(String? author) {
    state = state.copyWith(author: author, page: 1);
    loadPosts(refresh: true);
  }

  void setSearch(String? search) {
    state = state.copyWith(search: search, page: 1);
    loadPosts(refresh: true);
  }
}

final postsNotifierProvider = NotifierProvider<PostsNotifier, PostsState>(
  PostsNotifier.new,
);

// State classes
class FeedState {
  final List<FeedItem> feedItems;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int page;
  final int pageSize;
  final String? type;
  final String? university;
  final String? visibility;

  const FeedState({
    this.feedItems = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.page = 1,
    this.pageSize = 20,
    this.type,
    this.university,
    this.visibility,
  });

  FeedState copyWith({
    List<FeedItem>? feedItems,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? page,
    int? pageSize,
    String? type,
    String? university,
    String? visibility,
  }) {
    return FeedState(
      feedItems: feedItems ?? this.feedItems,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      type: type ?? this.type,
      university: university ?? this.university,
      visibility: visibility ?? this.visibility,
    );
  }
}

class PostsState {
  final List<SocialPost> posts;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int page;
  final int pageSize;
  final String? author;
  final String? search;

  const PostsState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.page = 1,
    this.pageSize = 20,
    this.author,
    this.search,
  });

  PostsState copyWith({
    List<SocialPost>? posts,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? page,
    int? pageSize,
    String? author,
    String? search,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      author: author ?? this.author,
      search: search ?? this.search,
    );
  }
}

// Filter params classes
class FeedFilterParams {
  final String? type;
  final String? university;
  final String? visibility;
  final int? page;
  final int? pageSize;

  const FeedFilterParams({
    this.type,
    this.university,
    this.visibility,
    this.page,
    this.pageSize,
  });
}

class PostFilterParams {
  final String? author;
  final String? search;
  final int? page;
  final int? pageSize;

  const PostFilterParams({
    this.author,
    this.search,
    this.page,
    this.pageSize,
  });
}

class CommentParams {
  final String postId;
  final int? page;
  final int? pageSize;

  const CommentParams({required this.postId, this.page, this.pageSize});
}
