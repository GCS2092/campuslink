import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

@freezed
abstract class Event with _$Event {
  const factory Event({
    required String id,
    required String title,
    required String description,
    required String organizerId,
    UserBasic? organizer,
    String? categoryId,
    Category? category,
    String? universityId,
    String? universityName,
    required String startDate,
    String? endDate,
    required String location,
    double? locationLat,
    double? locationLng,
    String? image,
    int? capacity,
    @Default(0.0) double price,
    @Default(true) bool isFree,
    String? registrationLink,
    @Default('draft') String status,
    @Default(false) bool isFeatured,
    @Default(0) int viewsCount,
    @Default(0) int participantsCount,
    @Default(0) int likesCount,
    @Default(false) bool isJoined,
    @Default(false) bool isLiked,
    String? createdAt,
    String? updatedAt,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    String? slug,
    String? description,
    String? icon,
    String? createdAt,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}

@freezed
abstract class EventParticipant with _$EventParticipant {
  const factory EventParticipant({
    required String id,
    required String eventId,
    required String userId,
    UserBasic? user,
    @Default('registered') String status,
    String? registeredAt,
    String? checkedInAt,
  }) = _EventParticipant;

  factory EventParticipant.fromJson(Map<String, dynamic> json) =>
      _$EventParticipantFromJson(json);
}

@freezed
abstract class EventCalendar with _$EventCalendar {
  const factory EventCalendar({
    required String date,
    required List<Event> events,
  }) = _EventCalendar;

  factory EventCalendar.fromJson(Map<String, dynamic> json) =>
      _$EventCalendarFromJson(json);
}

@freezed
abstract class EventFilterPreference with _$EventFilterPreference {
  const factory EventFilterPreference({
    String? id,
    List<String>? categories,
    List<String>? universities,
    @Default(false) bool showFreeOnly,
    @Default(false) bool showUniversityOnly,
    double? maxDistance,
    String? startDate,
    String? endDate,
  }) = _EventFilterPreference;

  factory EventFilterPreference.fromJson(Map<String, dynamic> json) =>
      _$EventFilterPreferenceFromJson(json);
}

@freezed
abstract class UserBasic with _$UserBasic {
  const factory UserBasic({
    required String id,
    required String username,
    String? firstName,
    String? lastName,
    String? profilePicture,
    String? role,
  }) = _UserBasic;

  factory UserBasic.fromJson(Map<String, dynamic> json) =>
      _$UserBasicFromJson(json);
}
