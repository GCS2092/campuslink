/// Modèle Event représentant un événement
class Event {
  final String id;
  final String title;
  final String description;
  final EventOrganizer organizer;
  final EventCategory? category;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;
  final double? locationLat;
  final double? locationLng;
  final String? image;
  final String? imageUrl;
  final int? capacity;
  final double price;
  final bool isFree;
  final String status; // 'draft' | 'published' | 'cancelled' | 'completed'
  final bool isFeatured;
  final int viewsCount;
  final int participantsCount;
  final List<EventParticipant>? participants;
  final bool? isParticipating;
  final bool? isLiked;
  final int likesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.organizer,
    this.category,
    required this.startDate,
    this.endDate,
    required this.location,
    this.locationLat,
    this.locationLng,
    this.image,
    this.imageUrl,
    this.capacity,
    required this.price,
    required this.isFree,
    required this.status,
    required this.isFeatured,
    required this.viewsCount,
    required this.participantsCount,
    this.participants,
    this.isParticipating,
    this.isLiked,
    required this.likesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    // Gérer l'image qui peut être string ou object
    String? imageUrl;
    if (json['image'] != null) {
      if (json['image'] is String) {
        imageUrl = json['image'] as String;
      } else if (json['image'] is Map && json['image']['url'] != null) {
        imageUrl = json['image']['url'] as String;
      }
    }
    imageUrl ??= json['image_url'];

    // Gérer les coordonnées qui peuvent être string ou number
    double? lat;
    if (json['location_lat'] != null) {
      if (json['location_lat'] is String) {
        lat = double.tryParse(json['location_lat']);
      } else {
        lat = (json['location_lat'] as num?)?.toDouble();
      }
    }

    double? lng;
    if (json['location_lng'] != null) {
      if (json['location_lng'] is String) {
        lng = double.tryParse(json['location_lng']);
      } else {
        lng = (json['location_lng'] as num?)?.toDouble();
      }
    }

    return Event(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      organizer: EventOrganizer.fromJson(json['organizer'] ?? {}),
      category: json['category'] != null
          ? EventCategory.fromJson(json['category'])
          : null,
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      location: json['location'] ?? '',
      locationLat: lat,
      locationLng: lng,
      image: imageUrl,
      imageUrl: imageUrl,
      capacity: json['capacity'] is String 
          ? int.tryParse(json['capacity']) 
          : (json['capacity'] as int?),
      price: json['price'] is String
          ? (double.tryParse(json['price']) ?? 0.0)
          : ((json['price'] as num?)?.toDouble() ?? 0.0),
      isFree: json['is_free'] ?? false,
      status: json['status'] ?? 'draft',
      isFeatured: json['is_featured'] ?? false,
      viewsCount: json['views_count'] is String
          ? (int.tryParse(json['views_count']) ?? 0)
          : (json['views_count'] as int? ?? 0),
      participantsCount: json['participants_count'] is String
          ? (int.tryParse(json['participants_count']) ?? 0)
          : (json['participants_count'] as int? ?? 0),
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((p) => EventParticipant.fromJson(p))
              .toList()
          : null,
      isParticipating: json['is_participating'],
      isLiked: json['is_liked'],
      likesCount: json['likes_count'] is String
          ? (int.tryParse(json['likes_count']) ?? 0)
          : (json['likes_count'] as int? ?? 0),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'organizer': organizer.toJson(),
      'category': category?.toJson(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'location': location,
      'location_lat': locationLat,
      'location_lng': locationLng,
      'image': image,
      'image_url': imageUrl,
      'capacity': capacity,
      'price': price,
      'is_free': isFree,
      'status': status,
      'is_featured': isFeatured,
      'views_count': viewsCount,
      'participants_count': participantsCount,
      'participants': participants?.map((p) => p.toJson()).toList(),
      'is_participating': isParticipating,
      'is_liked': isLiked,
      'likes_count': likesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Vérifie si l'événement est terminé
  bool get isEnded {
    if (endDate != null) {
      return endDate!.isBefore(DateTime.now());
    }
    return startDate.isBefore(DateTime.now());
  }

  /// Vérifie si l'événement est en cours
  bool get isOngoing {
    if (endDate != null) {
      final now = DateTime.now();
      return now.isAfter(startDate) && now.isBefore(endDate!);
    }
    return false;
  }

  /// Vérifie si l'événement est à venir
  bool get isUpcoming => startDate.isAfter(DateTime.now());
}

class EventOrganizer {
  final String id;
  final String username;
  final String? firstName;
  final String? lastName;
  final EventOrganizerProfile? profile;

  EventOrganizer({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.profile,
  });

  factory EventOrganizer.fromJson(Map<String, dynamic> json) {
    return EventOrganizer(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      profile: json['profile'] != null
          ? EventOrganizerProfile.fromJson(json['profile'])
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

class EventOrganizerProfile {
  final dynamic university; // Peut être string ou object

  EventOrganizerProfile({this.university});

  factory EventOrganizerProfile.fromJson(Map<String, dynamic> json) {
    return EventOrganizerProfile(
      university: json['university'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'university': university,
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

class EventCategory {
  final String id;
  final String name;

  EventCategory({required this.id, required this.name});

  factory EventCategory.fromJson(Map<String, dynamic> json) {
    return EventCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class EventParticipant {
  final String id;
  final String username;
  final String? firstName;
  final String? lastName;

  EventParticipant({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
  });

  factory EventParticipant.fromJson(Map<String, dynamic> json) {
    return EventParticipant(
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

