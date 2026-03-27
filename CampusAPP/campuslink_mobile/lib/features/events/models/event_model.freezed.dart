// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Event {

 String get id; String get title; String get description; String get organizerId; UserBasic? get organizer; String? get categoryId; Category? get category; String? get universityId; String? get universityName; String get startDate; String? get endDate; String get location; double? get locationLat; double? get locationLng; String? get image; int? get capacity; double get price; bool get isFree; String? get registrationLink; String get status; bool get isFeatured; int get viewsCount; int get participantsCount; int get likesCount; bool get isJoined; bool get isLiked; String? get createdAt; String? get updatedAt;
/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventCopyWith<Event> get copyWith => _$EventCopyWithImpl<Event>(this as Event, _$identity);

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Event&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.organizerId, organizerId) || other.organizerId == organizerId)&&(identical(other.organizer, organizer) || other.organizer == organizer)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.category, category) || other.category == category)&&(identical(other.universityId, universityId) || other.universityId == universityId)&&(identical(other.universityName, universityName) || other.universityName == universityName)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.location, location) || other.location == location)&&(identical(other.locationLat, locationLat) || other.locationLat == locationLat)&&(identical(other.locationLng, locationLng) || other.locationLng == locationLng)&&(identical(other.image, image) || other.image == image)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.price, price) || other.price == price)&&(identical(other.isFree, isFree) || other.isFree == isFree)&&(identical(other.registrationLink, registrationLink) || other.registrationLink == registrationLink)&&(identical(other.status, status) || other.status == status)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.viewsCount, viewsCount) || other.viewsCount == viewsCount)&&(identical(other.participantsCount, participantsCount) || other.participantsCount == participantsCount)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.isJoined, isJoined) || other.isJoined == isJoined)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,organizerId,organizer,categoryId,category,universityId,universityName,startDate,endDate,location,locationLat,locationLng,image,capacity,price,isFree,registrationLink,status,isFeatured,viewsCount,participantsCount,likesCount,isJoined,isLiked,createdAt,updatedAt]);

@override
String toString() {
  return 'Event(id: $id, title: $title, description: $description, organizerId: $organizerId, organizer: $organizer, categoryId: $categoryId, category: $category, universityId: $universityId, universityName: $universityName, startDate: $startDate, endDate: $endDate, location: $location, locationLat: $locationLat, locationLng: $locationLng, image: $image, capacity: $capacity, price: $price, isFree: $isFree, registrationLink: $registrationLink, status: $status, isFeatured: $isFeatured, viewsCount: $viewsCount, participantsCount: $participantsCount, likesCount: $likesCount, isJoined: $isJoined, isLiked: $isLiked, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $EventCopyWith<$Res>  {
  factory $EventCopyWith(Event value, $Res Function(Event) _then) = _$EventCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String organizerId, UserBasic? organizer, String? categoryId, Category? category, String? universityId, String? universityName, String startDate, String? endDate, String location, double? locationLat, double? locationLng, String? image, int? capacity, double price, bool isFree, String? registrationLink, String status, bool isFeatured, int viewsCount, int participantsCount, int likesCount, bool isJoined, bool isLiked, String? createdAt, String? updatedAt
});


$UserBasicCopyWith<$Res>? get organizer;$CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class _$EventCopyWithImpl<$Res>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._self, this._then);

  final Event _self;
  final $Res Function(Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? organizerId = null,Object? organizer = freezed,Object? categoryId = freezed,Object? category = freezed,Object? universityId = freezed,Object? universityName = freezed,Object? startDate = null,Object? endDate = freezed,Object? location = null,Object? locationLat = freezed,Object? locationLng = freezed,Object? image = freezed,Object? capacity = freezed,Object? price = null,Object? isFree = null,Object? registrationLink = freezed,Object? status = null,Object? isFeatured = null,Object? viewsCount = null,Object? participantsCount = null,Object? likesCount = null,Object? isJoined = null,Object? isLiked = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,organizerId: null == organizerId ? _self.organizerId : organizerId // ignore: cast_nullable_to_non_nullable
as String,organizer: freezed == organizer ? _self.organizer : organizer // ignore: cast_nullable_to_non_nullable
as UserBasic?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,universityId: freezed == universityId ? _self.universityId : universityId // ignore: cast_nullable_to_non_nullable
as String?,universityName: freezed == universityName ? _self.universityName : universityName // ignore: cast_nullable_to_non_nullable
as String?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,locationLat: freezed == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double?,locationLng: freezed == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,capacity: freezed == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,isFree: null == isFree ? _self.isFree : isFree // ignore: cast_nullable_to_non_nullable
as bool,registrationLink: freezed == registrationLink ? _self.registrationLink : registrationLink // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,viewsCount: null == viewsCount ? _self.viewsCount : viewsCount // ignore: cast_nullable_to_non_nullable
as int,participantsCount: null == participantsCount ? _self.participantsCount : participantsCount // ignore: cast_nullable_to_non_nullable
as int,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,isJoined: null == isJoined ? _self.isJoined : isJoined // ignore: cast_nullable_to_non_nullable
as bool,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserBasicCopyWith<$Res>? get organizer {
    if (_self.organizer == null) {
    return null;
  }

  return $UserBasicCopyWith<$Res>(_self.organizer!, (value) {
    return _then(_self.copyWith(organizer: value));
  });
}/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [Event].
extension EventPatterns on Event {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Event value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Event value)  $default,){
final _that = this;
switch (_that) {
case _Event():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Event value)?  $default,){
final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String organizerId,  UserBasic? organizer,  String? categoryId,  Category? category,  String? universityId,  String? universityName,  String startDate,  String? endDate,  String location,  double? locationLat,  double? locationLng,  String? image,  int? capacity,  double price,  bool isFree,  String? registrationLink,  String status,  bool isFeatured,  int viewsCount,  int participantsCount,  int likesCount,  bool isJoined,  bool isLiked,  String? createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.organizerId,_that.organizer,_that.categoryId,_that.category,_that.universityId,_that.universityName,_that.startDate,_that.endDate,_that.location,_that.locationLat,_that.locationLng,_that.image,_that.capacity,_that.price,_that.isFree,_that.registrationLink,_that.status,_that.isFeatured,_that.viewsCount,_that.participantsCount,_that.likesCount,_that.isJoined,_that.isLiked,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String organizerId,  UserBasic? organizer,  String? categoryId,  Category? category,  String? universityId,  String? universityName,  String startDate,  String? endDate,  String location,  double? locationLat,  double? locationLng,  String? image,  int? capacity,  double price,  bool isFree,  String? registrationLink,  String status,  bool isFeatured,  int viewsCount,  int participantsCount,  int likesCount,  bool isJoined,  bool isLiked,  String? createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Event():
return $default(_that.id,_that.title,_that.description,_that.organizerId,_that.organizer,_that.categoryId,_that.category,_that.universityId,_that.universityName,_that.startDate,_that.endDate,_that.location,_that.locationLat,_that.locationLng,_that.image,_that.capacity,_that.price,_that.isFree,_that.registrationLink,_that.status,_that.isFeatured,_that.viewsCount,_that.participantsCount,_that.likesCount,_that.isJoined,_that.isLiked,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String organizerId,  UserBasic? organizer,  String? categoryId,  Category? category,  String? universityId,  String? universityName,  String startDate,  String? endDate,  String location,  double? locationLat,  double? locationLng,  String? image,  int? capacity,  double price,  bool isFree,  String? registrationLink,  String status,  bool isFeatured,  int viewsCount,  int participantsCount,  int likesCount,  bool isJoined,  bool isLiked,  String? createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.organizerId,_that.organizer,_that.categoryId,_that.category,_that.universityId,_that.universityName,_that.startDate,_that.endDate,_that.location,_that.locationLat,_that.locationLng,_that.image,_that.capacity,_that.price,_that.isFree,_that.registrationLink,_that.status,_that.isFeatured,_that.viewsCount,_that.participantsCount,_that.likesCount,_that.isJoined,_that.isLiked,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Event implements Event {
  const _Event({required this.id, required this.title, required this.description, required this.organizerId, this.organizer, this.categoryId, this.category, this.universityId, this.universityName, required this.startDate, this.endDate, required this.location, this.locationLat, this.locationLng, this.image, this.capacity, this.price = 0.0, this.isFree = true, this.registrationLink, this.status = 'draft', this.isFeatured = false, this.viewsCount = 0, this.participantsCount = 0, this.likesCount = 0, this.isJoined = false, this.isLiked = false, this.createdAt, this.updatedAt});
  factory _Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String organizerId;
@override final  UserBasic? organizer;
@override final  String? categoryId;
@override final  Category? category;
@override final  String? universityId;
@override final  String? universityName;
@override final  String startDate;
@override final  String? endDate;
@override final  String location;
@override final  double? locationLat;
@override final  double? locationLng;
@override final  String? image;
@override final  int? capacity;
@override@JsonKey() final  double price;
@override@JsonKey() final  bool isFree;
@override final  String? registrationLink;
@override@JsonKey() final  String status;
@override@JsonKey() final  bool isFeatured;
@override@JsonKey() final  int viewsCount;
@override@JsonKey() final  int participantsCount;
@override@JsonKey() final  int likesCount;
@override@JsonKey() final  bool isJoined;
@override@JsonKey() final  bool isLiked;
@override final  String? createdAt;
@override final  String? updatedAt;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventCopyWith<_Event> get copyWith => __$EventCopyWithImpl<_Event>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Event&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.organizerId, organizerId) || other.organizerId == organizerId)&&(identical(other.organizer, organizer) || other.organizer == organizer)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.category, category) || other.category == category)&&(identical(other.universityId, universityId) || other.universityId == universityId)&&(identical(other.universityName, universityName) || other.universityName == universityName)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.location, location) || other.location == location)&&(identical(other.locationLat, locationLat) || other.locationLat == locationLat)&&(identical(other.locationLng, locationLng) || other.locationLng == locationLng)&&(identical(other.image, image) || other.image == image)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.price, price) || other.price == price)&&(identical(other.isFree, isFree) || other.isFree == isFree)&&(identical(other.registrationLink, registrationLink) || other.registrationLink == registrationLink)&&(identical(other.status, status) || other.status == status)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.viewsCount, viewsCount) || other.viewsCount == viewsCount)&&(identical(other.participantsCount, participantsCount) || other.participantsCount == participantsCount)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.isJoined, isJoined) || other.isJoined == isJoined)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,organizerId,organizer,categoryId,category,universityId,universityName,startDate,endDate,location,locationLat,locationLng,image,capacity,price,isFree,registrationLink,status,isFeatured,viewsCount,participantsCount,likesCount,isJoined,isLiked,createdAt,updatedAt]);

@override
String toString() {
  return 'Event(id: $id, title: $title, description: $description, organizerId: $organizerId, organizer: $organizer, categoryId: $categoryId, category: $category, universityId: $universityId, universityName: $universityName, startDate: $startDate, endDate: $endDate, location: $location, locationLat: $locationLat, locationLng: $locationLng, image: $image, capacity: $capacity, price: $price, isFree: $isFree, registrationLink: $registrationLink, status: $status, isFeatured: $isFeatured, viewsCount: $viewsCount, participantsCount: $participantsCount, likesCount: $likesCount, isJoined: $isJoined, isLiked: $isLiked, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$EventCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$EventCopyWith(_Event value, $Res Function(_Event) _then) = __$EventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String organizerId, UserBasic? organizer, String? categoryId, Category? category, String? universityId, String? universityName, String startDate, String? endDate, String location, double? locationLat, double? locationLng, String? image, int? capacity, double price, bool isFree, String? registrationLink, String status, bool isFeatured, int viewsCount, int participantsCount, int likesCount, bool isJoined, bool isLiked, String? createdAt, String? updatedAt
});


@override $UserBasicCopyWith<$Res>? get organizer;@override $CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class __$EventCopyWithImpl<$Res>
    implements _$EventCopyWith<$Res> {
  __$EventCopyWithImpl(this._self, this._then);

  final _Event _self;
  final $Res Function(_Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? organizerId = null,Object? organizer = freezed,Object? categoryId = freezed,Object? category = freezed,Object? universityId = freezed,Object? universityName = freezed,Object? startDate = null,Object? endDate = freezed,Object? location = null,Object? locationLat = freezed,Object? locationLng = freezed,Object? image = freezed,Object? capacity = freezed,Object? price = null,Object? isFree = null,Object? registrationLink = freezed,Object? status = null,Object? isFeatured = null,Object? viewsCount = null,Object? participantsCount = null,Object? likesCount = null,Object? isJoined = null,Object? isLiked = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Event(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,organizerId: null == organizerId ? _self.organizerId : organizerId // ignore: cast_nullable_to_non_nullable
as String,organizer: freezed == organizer ? _self.organizer : organizer // ignore: cast_nullable_to_non_nullable
as UserBasic?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,universityId: freezed == universityId ? _self.universityId : universityId // ignore: cast_nullable_to_non_nullable
as String?,universityName: freezed == universityName ? _self.universityName : universityName // ignore: cast_nullable_to_non_nullable
as String?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,locationLat: freezed == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double?,locationLng: freezed == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,capacity: freezed == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,isFree: null == isFree ? _self.isFree : isFree // ignore: cast_nullable_to_non_nullable
as bool,registrationLink: freezed == registrationLink ? _self.registrationLink : registrationLink // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,viewsCount: null == viewsCount ? _self.viewsCount : viewsCount // ignore: cast_nullable_to_non_nullable
as int,participantsCount: null == participantsCount ? _self.participantsCount : participantsCount // ignore: cast_nullable_to_non_nullable
as int,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,isJoined: null == isJoined ? _self.isJoined : isJoined // ignore: cast_nullable_to_non_nullable
as bool,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserBasicCopyWith<$Res>? get organizer {
    if (_self.organizer == null) {
    return null;
  }

  return $UserBasicCopyWith<$Res>(_self.organizer!, (value) {
    return _then(_self.copyWith(organizer: value));
  });
}/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// @nodoc
mixin _$Category {

 String get id; String get name; String? get slug; String? get description; String? get icon; String? get createdAt;
/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryCopyWith<Category> get copyWith => _$CategoryCopyWithImpl<Category>(this as Category, _$identity);

  /// Serializes this Category to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Category&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,description,icon,createdAt);

@override
String toString() {
  return 'Category(id: $id, name: $name, slug: $slug, description: $description, icon: $icon, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CategoryCopyWith<$Res>  {
  factory $CategoryCopyWith(Category value, $Res Function(Category) _then) = _$CategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? slug, String? description, String? icon, String? createdAt
});




}
/// @nodoc
class _$CategoryCopyWithImpl<$Res>
    implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._self, this._then);

  final Category _self;
  final $Res Function(Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = freezed,Object? description = freezed,Object? icon = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Category].
extension CategoryPatterns on Category {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Category value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Category value)  $default,){
final _that = this;
switch (_that) {
case _Category():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Category value)?  $default,){
final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? slug,  String? description,  String? icon,  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.description,_that.icon,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? slug,  String? description,  String? icon,  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Category():
return $default(_that.id,_that.name,_that.slug,_that.description,_that.icon,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? slug,  String? description,  String? icon,  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.description,_that.icon,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Category implements Category {
  const _Category({required this.id, required this.name, this.slug, this.description, this.icon, this.createdAt});
  factory _Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? slug;
@override final  String? description;
@override final  String? icon;
@override final  String? createdAt;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryCopyWith<_Category> get copyWith => __$CategoryCopyWithImpl<_Category>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Category&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,description,icon,createdAt);

@override
String toString() {
  return 'Category(id: $id, name: $name, slug: $slug, description: $description, icon: $icon, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CategoryCopyWith<$Res> implements $CategoryCopyWith<$Res> {
  factory _$CategoryCopyWith(_Category value, $Res Function(_Category) _then) = __$CategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? slug, String? description, String? icon, String? createdAt
});




}
/// @nodoc
class __$CategoryCopyWithImpl<$Res>
    implements _$CategoryCopyWith<$Res> {
  __$CategoryCopyWithImpl(this._self, this._then);

  final _Category _self;
  final $Res Function(_Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = freezed,Object? description = freezed,Object? icon = freezed,Object? createdAt = freezed,}) {
  return _then(_Category(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EventParticipant {

 String get id; String get eventId; String get userId; UserBasic? get user; String get status; String? get registeredAt; String? get checkedInAt;
/// Create a copy of EventParticipant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventParticipantCopyWith<EventParticipant> get copyWith => _$EventParticipantCopyWithImpl<EventParticipant>(this as EventParticipant, _$identity);

  /// Serializes this EventParticipant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventParticipant&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.user, user) || other.user == user)&&(identical(other.status, status) || other.status == status)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt)&&(identical(other.checkedInAt, checkedInAt) || other.checkedInAt == checkedInAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,userId,user,status,registeredAt,checkedInAt);

@override
String toString() {
  return 'EventParticipant(id: $id, eventId: $eventId, userId: $userId, user: $user, status: $status, registeredAt: $registeredAt, checkedInAt: $checkedInAt)';
}


}

/// @nodoc
abstract mixin class $EventParticipantCopyWith<$Res>  {
  factory $EventParticipantCopyWith(EventParticipant value, $Res Function(EventParticipant) _then) = _$EventParticipantCopyWithImpl;
@useResult
$Res call({
 String id, String eventId, String userId, UserBasic? user, String status, String? registeredAt, String? checkedInAt
});


$UserBasicCopyWith<$Res>? get user;

}
/// @nodoc
class _$EventParticipantCopyWithImpl<$Res>
    implements $EventParticipantCopyWith<$Res> {
  _$EventParticipantCopyWithImpl(this._self, this._then);

  final EventParticipant _self;
  final $Res Function(EventParticipant) _then;

/// Create a copy of EventParticipant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = null,Object? userId = null,Object? user = freezed,Object? status = null,Object? registeredAt = freezed,Object? checkedInAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserBasic?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,registeredAt: freezed == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as String?,checkedInAt: freezed == checkedInAt ? _self.checkedInAt : checkedInAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of EventParticipant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserBasicCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserBasicCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [EventParticipant].
extension EventParticipantPatterns on EventParticipant {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventParticipant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventParticipant() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventParticipant value)  $default,){
final _that = this;
switch (_that) {
case _EventParticipant():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventParticipant value)?  $default,){
final _that = this;
switch (_that) {
case _EventParticipant() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String eventId,  String userId,  UserBasic? user,  String status,  String? registeredAt,  String? checkedInAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventParticipant() when $default != null:
return $default(_that.id,_that.eventId,_that.userId,_that.user,_that.status,_that.registeredAt,_that.checkedInAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String eventId,  String userId,  UserBasic? user,  String status,  String? registeredAt,  String? checkedInAt)  $default,) {final _that = this;
switch (_that) {
case _EventParticipant():
return $default(_that.id,_that.eventId,_that.userId,_that.user,_that.status,_that.registeredAt,_that.checkedInAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String eventId,  String userId,  UserBasic? user,  String status,  String? registeredAt,  String? checkedInAt)?  $default,) {final _that = this;
switch (_that) {
case _EventParticipant() when $default != null:
return $default(_that.id,_that.eventId,_that.userId,_that.user,_that.status,_that.registeredAt,_that.checkedInAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventParticipant implements EventParticipant {
  const _EventParticipant({required this.id, required this.eventId, required this.userId, this.user, this.status = 'registered', this.registeredAt, this.checkedInAt});
  factory _EventParticipant.fromJson(Map<String, dynamic> json) => _$EventParticipantFromJson(json);

@override final  String id;
@override final  String eventId;
@override final  String userId;
@override final  UserBasic? user;
@override@JsonKey() final  String status;
@override final  String? registeredAt;
@override final  String? checkedInAt;

/// Create a copy of EventParticipant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventParticipantCopyWith<_EventParticipant> get copyWith => __$EventParticipantCopyWithImpl<_EventParticipant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventParticipantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventParticipant&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.user, user) || other.user == user)&&(identical(other.status, status) || other.status == status)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt)&&(identical(other.checkedInAt, checkedInAt) || other.checkedInAt == checkedInAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,userId,user,status,registeredAt,checkedInAt);

@override
String toString() {
  return 'EventParticipant(id: $id, eventId: $eventId, userId: $userId, user: $user, status: $status, registeredAt: $registeredAt, checkedInAt: $checkedInAt)';
}


}

/// @nodoc
abstract mixin class _$EventParticipantCopyWith<$Res> implements $EventParticipantCopyWith<$Res> {
  factory _$EventParticipantCopyWith(_EventParticipant value, $Res Function(_EventParticipant) _then) = __$EventParticipantCopyWithImpl;
@override @useResult
$Res call({
 String id, String eventId, String userId, UserBasic? user, String status, String? registeredAt, String? checkedInAt
});


@override $UserBasicCopyWith<$Res>? get user;

}
/// @nodoc
class __$EventParticipantCopyWithImpl<$Res>
    implements _$EventParticipantCopyWith<$Res> {
  __$EventParticipantCopyWithImpl(this._self, this._then);

  final _EventParticipant _self;
  final $Res Function(_EventParticipant) _then;

/// Create a copy of EventParticipant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = null,Object? userId = null,Object? user = freezed,Object? status = null,Object? registeredAt = freezed,Object? checkedInAt = freezed,}) {
  return _then(_EventParticipant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserBasic?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,registeredAt: freezed == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as String?,checkedInAt: freezed == checkedInAt ? _self.checkedInAt : checkedInAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of EventParticipant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserBasicCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserBasicCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$EventCalendar {

 String get date; List<Event> get events;
/// Create a copy of EventCalendar
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventCalendarCopyWith<EventCalendar> get copyWith => _$EventCalendarCopyWithImpl<EventCalendar>(this as EventCalendar, _$identity);

  /// Serializes this EventCalendar to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventCalendar&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.events, events));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,const DeepCollectionEquality().hash(events));

@override
String toString() {
  return 'EventCalendar(date: $date, events: $events)';
}


}

/// @nodoc
abstract mixin class $EventCalendarCopyWith<$Res>  {
  factory $EventCalendarCopyWith(EventCalendar value, $Res Function(EventCalendar) _then) = _$EventCalendarCopyWithImpl;
@useResult
$Res call({
 String date, List<Event> events
});




}
/// @nodoc
class _$EventCalendarCopyWithImpl<$Res>
    implements $EventCalendarCopyWith<$Res> {
  _$EventCalendarCopyWithImpl(this._self, this._then);

  final EventCalendar _self;
  final $Res Function(EventCalendar) _then;

/// Create a copy of EventCalendar
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? events = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<Event>,
  ));
}

}


/// Adds pattern-matching-related methods to [EventCalendar].
extension EventCalendarPatterns on EventCalendar {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventCalendar value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventCalendar() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventCalendar value)  $default,){
final _that = this;
switch (_that) {
case _EventCalendar():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventCalendar value)?  $default,){
final _that = this;
switch (_that) {
case _EventCalendar() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  List<Event> events)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventCalendar() when $default != null:
return $default(_that.date,_that.events);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  List<Event> events)  $default,) {final _that = this;
switch (_that) {
case _EventCalendar():
return $default(_that.date,_that.events);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  List<Event> events)?  $default,) {final _that = this;
switch (_that) {
case _EventCalendar() when $default != null:
return $default(_that.date,_that.events);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventCalendar implements EventCalendar {
  const _EventCalendar({required this.date, required final  List<Event> events}): _events = events;
  factory _EventCalendar.fromJson(Map<String, dynamic> json) => _$EventCalendarFromJson(json);

@override final  String date;
 final  List<Event> _events;
@override List<Event> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}


/// Create a copy of EventCalendar
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventCalendarCopyWith<_EventCalendar> get copyWith => __$EventCalendarCopyWithImpl<_EventCalendar>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventCalendarToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventCalendar&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other._events, _events));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,const DeepCollectionEquality().hash(_events));

@override
String toString() {
  return 'EventCalendar(date: $date, events: $events)';
}


}

/// @nodoc
abstract mixin class _$EventCalendarCopyWith<$Res> implements $EventCalendarCopyWith<$Res> {
  factory _$EventCalendarCopyWith(_EventCalendar value, $Res Function(_EventCalendar) _then) = __$EventCalendarCopyWithImpl;
@override @useResult
$Res call({
 String date, List<Event> events
});




}
/// @nodoc
class __$EventCalendarCopyWithImpl<$Res>
    implements _$EventCalendarCopyWith<$Res> {
  __$EventCalendarCopyWithImpl(this._self, this._then);

  final _EventCalendar _self;
  final $Res Function(_EventCalendar) _then;

/// Create a copy of EventCalendar
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? events = null,}) {
  return _then(_EventCalendar(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<Event>,
  ));
}


}


/// @nodoc
mixin _$EventFilterPreference {

 String? get id; List<String>? get categories; List<String>? get universities; bool get showFreeOnly; bool get showUniversityOnly; double? get maxDistance; String? get startDate; String? get endDate;
/// Create a copy of EventFilterPreference
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventFilterPreferenceCopyWith<EventFilterPreference> get copyWith => _$EventFilterPreferenceCopyWithImpl<EventFilterPreference>(this as EventFilterPreference, _$identity);

  /// Serializes this EventFilterPreference to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventFilterPreference&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.universities, universities)&&(identical(other.showFreeOnly, showFreeOnly) || other.showFreeOnly == showFreeOnly)&&(identical(other.showUniversityOnly, showUniversityOnly) || other.showUniversityOnly == showUniversityOnly)&&(identical(other.maxDistance, maxDistance) || other.maxDistance == maxDistance)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(universities),showFreeOnly,showUniversityOnly,maxDistance,startDate,endDate);

@override
String toString() {
  return 'EventFilterPreference(id: $id, categories: $categories, universities: $universities, showFreeOnly: $showFreeOnly, showUniversityOnly: $showUniversityOnly, maxDistance: $maxDistance, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $EventFilterPreferenceCopyWith<$Res>  {
  factory $EventFilterPreferenceCopyWith(EventFilterPreference value, $Res Function(EventFilterPreference) _then) = _$EventFilterPreferenceCopyWithImpl;
@useResult
$Res call({
 String? id, List<String>? categories, List<String>? universities, bool showFreeOnly, bool showUniversityOnly, double? maxDistance, String? startDate, String? endDate
});




}
/// @nodoc
class _$EventFilterPreferenceCopyWithImpl<$Res>
    implements $EventFilterPreferenceCopyWith<$Res> {
  _$EventFilterPreferenceCopyWithImpl(this._self, this._then);

  final EventFilterPreference _self;
  final $Res Function(EventFilterPreference) _then;

/// Create a copy of EventFilterPreference
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? categories = freezed,Object? universities = freezed,Object? showFreeOnly = null,Object? showUniversityOnly = null,Object? maxDistance = freezed,Object? startDate = freezed,Object? endDate = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,categories: freezed == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>?,universities: freezed == universities ? _self.universities : universities // ignore: cast_nullable_to_non_nullable
as List<String>?,showFreeOnly: null == showFreeOnly ? _self.showFreeOnly : showFreeOnly // ignore: cast_nullable_to_non_nullable
as bool,showUniversityOnly: null == showUniversityOnly ? _self.showUniversityOnly : showUniversityOnly // ignore: cast_nullable_to_non_nullable
as bool,maxDistance: freezed == maxDistance ? _self.maxDistance : maxDistance // ignore: cast_nullable_to_non_nullable
as double?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventFilterPreference].
extension EventFilterPreferencePatterns on EventFilterPreference {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventFilterPreference value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventFilterPreference() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventFilterPreference value)  $default,){
final _that = this;
switch (_that) {
case _EventFilterPreference():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventFilterPreference value)?  $default,){
final _that = this;
switch (_that) {
case _EventFilterPreference() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  List<String>? categories,  List<String>? universities,  bool showFreeOnly,  bool showUniversityOnly,  double? maxDistance,  String? startDate,  String? endDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventFilterPreference() when $default != null:
return $default(_that.id,_that.categories,_that.universities,_that.showFreeOnly,_that.showUniversityOnly,_that.maxDistance,_that.startDate,_that.endDate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  List<String>? categories,  List<String>? universities,  bool showFreeOnly,  bool showUniversityOnly,  double? maxDistance,  String? startDate,  String? endDate)  $default,) {final _that = this;
switch (_that) {
case _EventFilterPreference():
return $default(_that.id,_that.categories,_that.universities,_that.showFreeOnly,_that.showUniversityOnly,_that.maxDistance,_that.startDate,_that.endDate);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  List<String>? categories,  List<String>? universities,  bool showFreeOnly,  bool showUniversityOnly,  double? maxDistance,  String? startDate,  String? endDate)?  $default,) {final _that = this;
switch (_that) {
case _EventFilterPreference() when $default != null:
return $default(_that.id,_that.categories,_that.universities,_that.showFreeOnly,_that.showUniversityOnly,_that.maxDistance,_that.startDate,_that.endDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventFilterPreference implements EventFilterPreference {
  const _EventFilterPreference({this.id, final  List<String>? categories, final  List<String>? universities, this.showFreeOnly = false, this.showUniversityOnly = false, this.maxDistance, this.startDate, this.endDate}): _categories = categories,_universities = universities;
  factory _EventFilterPreference.fromJson(Map<String, dynamic> json) => _$EventFilterPreferenceFromJson(json);

@override final  String? id;
 final  List<String>? _categories;
@override List<String>? get categories {
  final value = _categories;
  if (value == null) return null;
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _universities;
@override List<String>? get universities {
  final value = _universities;
  if (value == null) return null;
  if (_universities is EqualUnmodifiableListView) return _universities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  bool showFreeOnly;
@override@JsonKey() final  bool showUniversityOnly;
@override final  double? maxDistance;
@override final  String? startDate;
@override final  String? endDate;

/// Create a copy of EventFilterPreference
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventFilterPreferenceCopyWith<_EventFilterPreference> get copyWith => __$EventFilterPreferenceCopyWithImpl<_EventFilterPreference>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventFilterPreferenceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventFilterPreference&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._universities, _universities)&&(identical(other.showFreeOnly, showFreeOnly) || other.showFreeOnly == showFreeOnly)&&(identical(other.showUniversityOnly, showUniversityOnly) || other.showUniversityOnly == showUniversityOnly)&&(identical(other.maxDistance, maxDistance) || other.maxDistance == maxDistance)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_universities),showFreeOnly,showUniversityOnly,maxDistance,startDate,endDate);

@override
String toString() {
  return 'EventFilterPreference(id: $id, categories: $categories, universities: $universities, showFreeOnly: $showFreeOnly, showUniversityOnly: $showUniversityOnly, maxDistance: $maxDistance, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$EventFilterPreferenceCopyWith<$Res> implements $EventFilterPreferenceCopyWith<$Res> {
  factory _$EventFilterPreferenceCopyWith(_EventFilterPreference value, $Res Function(_EventFilterPreference) _then) = __$EventFilterPreferenceCopyWithImpl;
@override @useResult
$Res call({
 String? id, List<String>? categories, List<String>? universities, bool showFreeOnly, bool showUniversityOnly, double? maxDistance, String? startDate, String? endDate
});




}
/// @nodoc
class __$EventFilterPreferenceCopyWithImpl<$Res>
    implements _$EventFilterPreferenceCopyWith<$Res> {
  __$EventFilterPreferenceCopyWithImpl(this._self, this._then);

  final _EventFilterPreference _self;
  final $Res Function(_EventFilterPreference) _then;

/// Create a copy of EventFilterPreference
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? categories = freezed,Object? universities = freezed,Object? showFreeOnly = null,Object? showUniversityOnly = null,Object? maxDistance = freezed,Object? startDate = freezed,Object? endDate = freezed,}) {
  return _then(_EventFilterPreference(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,categories: freezed == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>?,universities: freezed == universities ? _self._universities : universities // ignore: cast_nullable_to_non_nullable
as List<String>?,showFreeOnly: null == showFreeOnly ? _self.showFreeOnly : showFreeOnly // ignore: cast_nullable_to_non_nullable
as bool,showUniversityOnly: null == showUniversityOnly ? _self.showUniversityOnly : showUniversityOnly // ignore: cast_nullable_to_non_nullable
as bool,maxDistance: freezed == maxDistance ? _self.maxDistance : maxDistance // ignore: cast_nullable_to_non_nullable
as double?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UserBasic {

 String get id; String get username; String? get firstName; String? get lastName; String? get profilePicture; String? get role;
/// Create a copy of UserBasic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserBasicCopyWith<UserBasic> get copyWith => _$UserBasicCopyWithImpl<UserBasic>(this as UserBasic, _$identity);

  /// Serializes this UserBasic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserBasic&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,firstName,lastName,profilePicture,role);

@override
String toString() {
  return 'UserBasic(id: $id, username: $username, firstName: $firstName, lastName: $lastName, profilePicture: $profilePicture, role: $role)';
}


}

/// @nodoc
abstract mixin class $UserBasicCopyWith<$Res>  {
  factory $UserBasicCopyWith(UserBasic value, $Res Function(UserBasic) _then) = _$UserBasicCopyWithImpl;
@useResult
$Res call({
 String id, String username, String? firstName, String? lastName, String? profilePicture, String? role
});




}
/// @nodoc
class _$UserBasicCopyWithImpl<$Res>
    implements $UserBasicCopyWith<$Res> {
  _$UserBasicCopyWithImpl(this._self, this._then);

  final UserBasic _self;
  final $Res Function(UserBasic) _then;

/// Create a copy of UserBasic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? firstName = freezed,Object? lastName = freezed,Object? profilePicture = freezed,Object? role = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserBasic].
extension UserBasicPatterns on UserBasic {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserBasic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserBasic() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserBasic value)  $default,){
final _that = this;
switch (_that) {
case _UserBasic():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserBasic value)?  $default,){
final _that = this;
switch (_that) {
case _UserBasic() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String? firstName,  String? lastName,  String? profilePicture,  String? role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserBasic() when $default != null:
return $default(_that.id,_that.username,_that.firstName,_that.lastName,_that.profilePicture,_that.role);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String? firstName,  String? lastName,  String? profilePicture,  String? role)  $default,) {final _that = this;
switch (_that) {
case _UserBasic():
return $default(_that.id,_that.username,_that.firstName,_that.lastName,_that.profilePicture,_that.role);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String? firstName,  String? lastName,  String? profilePicture,  String? role)?  $default,) {final _that = this;
switch (_that) {
case _UserBasic() when $default != null:
return $default(_that.id,_that.username,_that.firstName,_that.lastName,_that.profilePicture,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserBasic implements UserBasic {
  const _UserBasic({required this.id, required this.username, this.firstName, this.lastName, this.profilePicture, this.role});
  factory _UserBasic.fromJson(Map<String, dynamic> json) => _$UserBasicFromJson(json);

@override final  String id;
@override final  String username;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? profilePicture;
@override final  String? role;

/// Create a copy of UserBasic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserBasicCopyWith<_UserBasic> get copyWith => __$UserBasicCopyWithImpl<_UserBasic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserBasicToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserBasic&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,firstName,lastName,profilePicture,role);

@override
String toString() {
  return 'UserBasic(id: $id, username: $username, firstName: $firstName, lastName: $lastName, profilePicture: $profilePicture, role: $role)';
}


}

/// @nodoc
abstract mixin class _$UserBasicCopyWith<$Res> implements $UserBasicCopyWith<$Res> {
  factory _$UserBasicCopyWith(_UserBasic value, $Res Function(_UserBasic) _then) = __$UserBasicCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String? firstName, String? lastName, String? profilePicture, String? role
});




}
/// @nodoc
class __$UserBasicCopyWithImpl<$Res>
    implements _$UserBasicCopyWith<$Res> {
  __$UserBasicCopyWithImpl(this._self, this._then);

  final _UserBasic _self;
  final $Res Function(_UserBasic) _then;

/// Create a copy of UserBasic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? firstName = freezed,Object? lastName = freezed,Object? profilePicture = freezed,Object? role = freezed,}) {
  return _then(_UserBasic(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
