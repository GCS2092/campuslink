/// Modèle Post représentant un post social
class Post {
  final String id;
  final PostAuthor author;
  final String content;
  final String postType; // 'text' | 'image' | 'video'
  final String? imageUrl;
  final String? videoUrl;
  final bool isPublic;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool? isLiked;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.author,
    required this.content,
    required this.postType,
    this.imageUrl,
    this.videoUrl,
    required this.isPublic,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    this.isLiked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id']?.toString() ?? '',
      author: PostAuthor.fromJson(json['author'] ?? {}),
      content: json['content'] ?? '',
      postType: json['post_type'] ?? 'text',
      imageUrl: json['image_url'],
      videoUrl: json['video_url'],
      isPublic: json['is_public'] ?? true,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      isLiked: json['is_liked'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'content': content,
      'post_type': postType,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'is_public': isPublic,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'is_liked': isLiked,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class PostAuthor {
  final String id;
  final String username;
  final String? firstName;
  final String? lastName;
  final PostAuthorProfile? profile;

  PostAuthor({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.profile,
  });

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      profile: json['profile'] != null
          ? PostAuthorProfile.fromJson(json['profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'profile': profile?.toJson(),
    };
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    }
    return username;
  }
}

class PostAuthorProfile {
  final String? profilePicture;

  PostAuthorProfile({this.profilePicture});

  factory PostAuthorProfile.fromJson(Map<String, dynamic> json) {
    return PostAuthorProfile(
      profilePicture: json['profile_picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_picture': profilePicture,
    };
  }
}

