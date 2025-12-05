/// Modèle FeedItem représentant un élément du feed
class FeedItem {
  final String id;
  final FeedItemAuthor? author;
  final String? type; // 'event' | 'group' | 'announcement' | 'news' | 'feed'
  final String? title;
  final String? content;
  final String? image;
  final String? visibility; // 'public' | 'private'
  final dynamic university;
  final bool? isPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? eventData;
  final Map<String, dynamic>? feedData;

  FeedItem({
    required this.id,
    this.author,
    this.type,
    this.title,
    this.content,
    this.image,
    this.visibility,
    this.university,
    this.isPublished,
    this.createdAt,
    this.updatedAt,
    this.eventData,
    this.feedData,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id']?.toString() ?? '',
      author: json['author'] != null
          ? FeedItemAuthor.fromJson(json['author'])
          : null,
      type: json['type'],
      title: json['title'],
      content: json['content'],
      image: json['image'],
      visibility: json['visibility'],
      university: json['university'],
      isPublished: json['is_published'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      eventData: json['event_data'],
      feedData: json['feed_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author?.toJson(),
      'type': type,
      'title': title,
      'content': content,
      'image': image,
      'visibility': visibility,
      'university': university,
      'is_published': isPublished,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'event_data': eventData,
      'feed_data': feedData,
    };
  }
}

class FeedItemAuthor {
  final String id;
  final String username;
  final String? firstName;
  final String? lastName;

  FeedItemAuthor({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
  });

  factory FeedItemAuthor.fromJson(Map<String, dynamic> json) {
    return FeedItemAuthor(
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

