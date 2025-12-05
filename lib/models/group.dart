/// Modèle Group représentant un groupe
class Group {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String? coverImage;
  final String? profileImage;
  final GroupCreator creator;
  final dynamic university; // Peut être string ou object
  final String? category;
  final bool isPublic;
  final bool isVerified;
  final int membersCount;
  final int postsCount;
  final int eventsCount;
  final String? userRole; // 'admin' | 'member' | 'moderator'
  final DateTime createdAt;
  final DateTime updatedAt;

  Group({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.coverImage,
    this.profileImage,
    required this.creator,
    this.university,
    this.category,
    required this.isPublic,
    required this.isVerified,
    required this.membersCount,
    required this.postsCount,
    required this.eventsCount,
    this.userRole,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      coverImage: json['cover_image'],
      profileImage: json['profile_image'],
      creator: GroupCreator.fromJson(json['creator'] ?? {}),
      university: json['university'],
      category: json['category'],
      isPublic: json['is_public'] ?? true,
      isVerified: json['is_verified'] ?? false,
      membersCount: json['members_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,
      eventsCount: json['events_count'] ?? 0,
      userRole: json['user_role'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'cover_image': coverImage,
      'profile_image': profileImage,
      'creator': creator.toJson(),
      'university': university,
      'category': category,
      'is_public': isPublic,
      'is_verified': isVerified,
      'members_count': membersCount,
      'posts_count': postsCount,
      'events_count': eventsCount,
      'user_role': userRole,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String? get universityName {
    if (university == null) return null;
    if (university is String) return university as String;
    if (university is Map) {
      return university['name'] ?? university['short_name'];
    }
    return null;
  }
}

class GroupCreator {
  final String id;
  final String username;
  final String? firstName;
  final String? lastName;

  GroupCreator({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
  });

  factory GroupCreator.fromJson(Map<String, dynamic> json) {
    return GroupCreator(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
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

