// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Event _$EventFromJson(Map<String, dynamic> json) => _Event(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  organizerId: json['organizerId'] as String,
  organizer: json['organizer'] == null
      ? null
      : UserBasic.fromJson(json['organizer'] as Map<String, dynamic>),
  categoryId: json['categoryId'] as String?,
  category: json['category'] == null
      ? null
      : Category.fromJson(json['category'] as Map<String, dynamic>),
  universityId: json['universityId'] as String?,
  universityName: json['universityName'] as String?,
  startDate: json['startDate'] as String,
  endDate: json['endDate'] as String?,
  location: json['location'] as String,
  locationLat: (json['locationLat'] as num?)?.toDouble(),
  locationLng: (json['locationLng'] as num?)?.toDouble(),
  image: json['image'] as String?,
  capacity: (json['capacity'] as num?)?.toInt(),
  price: (json['price'] as num?)?.toDouble() ?? 0.0,
  isFree: json['isFree'] as bool? ?? true,
  registrationLink: json['registrationLink'] as String?,
  status: json['status'] as String? ?? 'draft',
  isFeatured: json['isFeatured'] as bool? ?? false,
  viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
  participantsCount: (json['participantsCount'] as num?)?.toInt() ?? 0,
  likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
  isJoined: json['isJoined'] as bool? ?? false,
  isLiked: json['isLiked'] as bool? ?? false,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$EventToJson(_Event instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'organizerId': instance.organizerId,
  'organizer': instance.organizer,
  'categoryId': instance.categoryId,
  'category': instance.category,
  'universityId': instance.universityId,
  'universityName': instance.universityName,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'location': instance.location,
  'locationLat': instance.locationLat,
  'locationLng': instance.locationLng,
  'image': instance.image,
  'capacity': instance.capacity,
  'price': instance.price,
  'isFree': instance.isFree,
  'registrationLink': instance.registrationLink,
  'status': instance.status,
  'isFeatured': instance.isFeatured,
  'viewsCount': instance.viewsCount,
  'participantsCount': instance.participantsCount,
  'likesCount': instance.likesCount,
  'isJoined': instance.isJoined,
  'isLiked': instance.isLiked,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String?,
  description: json['description'] as String?,
  icon: json['icon'] as String?,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
  'description': instance.description,
  'icon': instance.icon,
  'createdAt': instance.createdAt,
};

_EventParticipant _$EventParticipantFromJson(Map<String, dynamic> json) =>
    _EventParticipant(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      userId: json['userId'] as String,
      user: json['user'] == null
          ? null
          : UserBasic.fromJson(json['user'] as Map<String, dynamic>),
      status: json['status'] as String? ?? 'registered',
      registeredAt: json['registeredAt'] as String?,
      checkedInAt: json['checkedInAt'] as String?,
    );

Map<String, dynamic> _$EventParticipantToJson(_EventParticipant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'userId': instance.userId,
      'user': instance.user,
      'status': instance.status,
      'registeredAt': instance.registeredAt,
      'checkedInAt': instance.checkedInAt,
    };

_EventCalendar _$EventCalendarFromJson(Map<String, dynamic> json) =>
    _EventCalendar(
      date: json['date'] as String,
      events: (json['events'] as List<dynamic>)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EventCalendarToJson(_EventCalendar instance) =>
    <String, dynamic>{'date': instance.date, 'events': instance.events};

_EventFilterPreference _$EventFilterPreferenceFromJson(
  Map<String, dynamic> json,
) => _EventFilterPreference(
  id: json['id'] as String?,
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  universities: (json['universities'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  showFreeOnly: json['showFreeOnly'] as bool? ?? false,
  showUniversityOnly: json['showUniversityOnly'] as bool? ?? false,
  maxDistance: (json['maxDistance'] as num?)?.toDouble(),
  startDate: json['startDate'] as String?,
  endDate: json['endDate'] as String?,
);

Map<String, dynamic> _$EventFilterPreferenceToJson(
  _EventFilterPreference instance,
) => <String, dynamic>{
  'id': instance.id,
  'categories': instance.categories,
  'universities': instance.universities,
  'showFreeOnly': instance.showFreeOnly,
  'showUniversityOnly': instance.showUniversityOnly,
  'maxDistance': instance.maxDistance,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
};

_UserBasic _$UserBasicFromJson(Map<String, dynamic> json) => _UserBasic(
  id: json['id'] as String,
  username: json['username'] as String,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  profilePicture: json['profilePicture'] as String?,
  role: json['role'] as String?,
);

Map<String, dynamic> _$UserBasicToJson(_UserBasic instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'profilePicture': instance.profilePicture,
      'role': instance.role,
    };
