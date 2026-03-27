// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Notification {

 String get id; String get recipientId; String get type; String get title; String get message; Map<String, dynamic>? get data; String? get image; bool get isRead; String? get readAt; bool get isActioned; String? get actionedAt; String? get actionType; String? get actionUrl; String? get senderId; UserBasic? get sender; String? get createdAt; String? get updatedAt;
/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationCopyWith<Notification> get copyWith => _$NotificationCopyWithImpl<Notification>(this as Notification, _$identity);

  /// Serializes this Notification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Notification&&(identical(other.id, id) || other.id == id)&&(identical(other.recipientId, recipientId) || other.recipientId == recipientId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.image, image) || other.image == image)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.isActioned, isActioned) || other.isActioned == isActioned)&&(identical(other.actionedAt, actionedAt) || other.actionedAt == actionedAt)&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.actionUrl, actionUrl) || other.actionUrl == actionUrl)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recipientId,type,title,message,const DeepCollectionEquality().hash(data),image,isRead,readAt,isActioned,actionedAt,actionType,actionUrl,senderId,sender,createdAt,updatedAt);

@override
String toString() {
  return 'Notification(id: $id, recipientId: $recipientId, type: $type, title: $title, message: $message, data: $data, image: $image, isRead: $isRead, readAt: $readAt, isActioned: $isActioned, actionedAt: $actionedAt, actionType: $actionType, actionUrl: $actionUrl, senderId: $senderId, sender: $sender, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $NotificationCopyWith<$Res>  {
  factory $NotificationCopyWith(Notification value, $Res Function(Notification) _then) = _$NotificationCopyWithImpl;
@useResult
$Res call({
 String id, String recipientId, String type, String title, String message, Map<String, dynamic>? data, String? image, bool isRead, String? readAt, bool isActioned, String? actionedAt, String? actionType, String? actionUrl, String? senderId, UserBasic? sender, String? createdAt, String? updatedAt
});


$UserBasicCopyWith<$Res>? get sender;

}
/// @nodoc
class _$NotificationCopyWithImpl<$Res>
    implements $NotificationCopyWith<$Res> {
  _$NotificationCopyWithImpl(this._self, this._then);

  final Notification _self;
  final $Res Function(Notification) _then;

/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? recipientId = null,Object? type = null,Object? title = null,Object? message = null,Object? data = freezed,Object? image = freezed,Object? isRead = null,Object? readAt = freezed,Object? isActioned = null,Object? actionedAt = freezed,Object? actionType = freezed,Object? actionUrl = freezed,Object? senderId = freezed,Object? sender = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,recipientId: null == recipientId ? _self.recipientId : recipientId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as String?,isActioned: null == isActioned ? _self.isActioned : isActioned // ignore: cast_nullable_to_non_nullable
as bool,actionedAt: freezed == actionedAt ? _self.actionedAt : actionedAt // ignore: cast_nullable_to_non_nullable
as String?,actionType: freezed == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as String?,actionUrl: freezed == actionUrl ? _self.actionUrl : actionUrl // ignore: cast_nullable_to_non_nullable
as String?,senderId: freezed == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String?,sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as UserBasic?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserBasicCopyWith<$Res>? get sender {
    if (_self.sender == null) {
    return null;
  }

  return $UserBasicCopyWith<$Res>(_self.sender!, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// Adds pattern-matching-related methods to [Notification].
extension NotificationPatterns on Notification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Notification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Notification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Notification value)  $default,){
final _that = this;
switch (_that) {
case _Notification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Notification value)?  $default,){
final _that = this;
switch (_that) {
case _Notification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String recipientId,  String type,  String title,  String message,  Map<String, dynamic>? data,  String? image,  bool isRead,  String? readAt,  bool isActioned,  String? actionedAt,  String? actionType,  String? actionUrl,  String? senderId,  UserBasic? sender,  String? createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Notification() when $default != null:
return $default(_that.id,_that.recipientId,_that.type,_that.title,_that.message,_that.data,_that.image,_that.isRead,_that.readAt,_that.isActioned,_that.actionedAt,_that.actionType,_that.actionUrl,_that.senderId,_that.sender,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String recipientId,  String type,  String title,  String message,  Map<String, dynamic>? data,  String? image,  bool isRead,  String? readAt,  bool isActioned,  String? actionedAt,  String? actionType,  String? actionUrl,  String? senderId,  UserBasic? sender,  String? createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Notification():
return $default(_that.id,_that.recipientId,_that.type,_that.title,_that.message,_that.data,_that.image,_that.isRead,_that.readAt,_that.isActioned,_that.actionedAt,_that.actionType,_that.actionUrl,_that.senderId,_that.sender,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String recipientId,  String type,  String title,  String message,  Map<String, dynamic>? data,  String? image,  bool isRead,  String? readAt,  bool isActioned,  String? actionedAt,  String? actionType,  String? actionUrl,  String? senderId,  UserBasic? sender,  String? createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Notification() when $default != null:
return $default(_that.id,_that.recipientId,_that.type,_that.title,_that.message,_that.data,_that.image,_that.isRead,_that.readAt,_that.isActioned,_that.actionedAt,_that.actionType,_that.actionUrl,_that.senderId,_that.sender,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Notification implements Notification {
  const _Notification({required this.id, required this.recipientId, required this.type, required this.title, required this.message, final  Map<String, dynamic>? data, this.image, this.isRead = false, this.readAt, this.isActioned = false, this.actionedAt, this.actionType, this.actionUrl, this.senderId, this.sender, this.createdAt, this.updatedAt}): _data = data;
  factory _Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);

@override final  String id;
@override final  String recipientId;
@override final  String type;
@override final  String title;
@override final  String message;
 final  Map<String, dynamic>? _data;
@override Map<String, dynamic>? get data {
  final value = _data;
  if (value == null) return null;
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? image;
@override@JsonKey() final  bool isRead;
@override final  String? readAt;
@override@JsonKey() final  bool isActioned;
@override final  String? actionedAt;
@override final  String? actionType;
@override final  String? actionUrl;
@override final  String? senderId;
@override final  UserBasic? sender;
@override final  String? createdAt;
@override final  String? updatedAt;

/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationCopyWith<_Notification> get copyWith => __$NotificationCopyWithImpl<_Notification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Notification&&(identical(other.id, id) || other.id == id)&&(identical(other.recipientId, recipientId) || other.recipientId == recipientId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.image, image) || other.image == image)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.isActioned, isActioned) || other.isActioned == isActioned)&&(identical(other.actionedAt, actionedAt) || other.actionedAt == actionedAt)&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.actionUrl, actionUrl) || other.actionUrl == actionUrl)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recipientId,type,title,message,const DeepCollectionEquality().hash(_data),image,isRead,readAt,isActioned,actionedAt,actionType,actionUrl,senderId,sender,createdAt,updatedAt);

@override
String toString() {
  return 'Notification(id: $id, recipientId: $recipientId, type: $type, title: $title, message: $message, data: $data, image: $image, isRead: $isRead, readAt: $readAt, isActioned: $isActioned, actionedAt: $actionedAt, actionType: $actionType, actionUrl: $actionUrl, senderId: $senderId, sender: $sender, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$NotificationCopyWith<$Res> implements $NotificationCopyWith<$Res> {
  factory _$NotificationCopyWith(_Notification value, $Res Function(_Notification) _then) = __$NotificationCopyWithImpl;
@override @useResult
$Res call({
 String id, String recipientId, String type, String title, String message, Map<String, dynamic>? data, String? image, bool isRead, String? readAt, bool isActioned, String? actionedAt, String? actionType, String? actionUrl, String? senderId, UserBasic? sender, String? createdAt, String? updatedAt
});


@override $UserBasicCopyWith<$Res>? get sender;

}
/// @nodoc
class __$NotificationCopyWithImpl<$Res>
    implements _$NotificationCopyWith<$Res> {
  __$NotificationCopyWithImpl(this._self, this._then);

  final _Notification _self;
  final $Res Function(_Notification) _then;

/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? recipientId = null,Object? type = null,Object? title = null,Object? message = null,Object? data = freezed,Object? image = freezed,Object? isRead = null,Object? readAt = freezed,Object? isActioned = null,Object? actionedAt = freezed,Object? actionType = freezed,Object? actionUrl = freezed,Object? senderId = freezed,Object? sender = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Notification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,recipientId: null == recipientId ? _self.recipientId : recipientId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as String?,isActioned: null == isActioned ? _self.isActioned : isActioned // ignore: cast_nullable_to_non_nullable
as bool,actionedAt: freezed == actionedAt ? _self.actionedAt : actionedAt // ignore: cast_nullable_to_non_nullable
as String?,actionType: freezed == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as String?,actionUrl: freezed == actionUrl ? _self.actionUrl : actionUrl // ignore: cast_nullable_to_non_nullable
as String?,senderId: freezed == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String?,sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as UserBasic?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserBasicCopyWith<$Res>? get sender {
    if (_self.sender == null) {
    return null;
  }

  return $UserBasicCopyWith<$Res>(_self.sender!, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// @nodoc
mixin _$NotificationPreferences {

 bool get pushEnabled; bool get emailEnabled; bool get friendRequestsEnabled; bool get messagesEnabled; bool get groupUpdatesEnabled; bool get eventRemindersEnabled; bool get mentionsEnabled; bool get marketingEnabled;
/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPreferencesCopyWith<NotificationPreferences> get copyWith => _$NotificationPreferencesCopyWithImpl<NotificationPreferences>(this as NotificationPreferences, _$identity);

  /// Serializes this NotificationPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPreferences&&(identical(other.pushEnabled, pushEnabled) || other.pushEnabled == pushEnabled)&&(identical(other.emailEnabled, emailEnabled) || other.emailEnabled == emailEnabled)&&(identical(other.friendRequestsEnabled, friendRequestsEnabled) || other.friendRequestsEnabled == friendRequestsEnabled)&&(identical(other.messagesEnabled, messagesEnabled) || other.messagesEnabled == messagesEnabled)&&(identical(other.groupUpdatesEnabled, groupUpdatesEnabled) || other.groupUpdatesEnabled == groupUpdatesEnabled)&&(identical(other.eventRemindersEnabled, eventRemindersEnabled) || other.eventRemindersEnabled == eventRemindersEnabled)&&(identical(other.mentionsEnabled, mentionsEnabled) || other.mentionsEnabled == mentionsEnabled)&&(identical(other.marketingEnabled, marketingEnabled) || other.marketingEnabled == marketingEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pushEnabled,emailEnabled,friendRequestsEnabled,messagesEnabled,groupUpdatesEnabled,eventRemindersEnabled,mentionsEnabled,marketingEnabled);

@override
String toString() {
  return 'NotificationPreferences(pushEnabled: $pushEnabled, emailEnabled: $emailEnabled, friendRequestsEnabled: $friendRequestsEnabled, messagesEnabled: $messagesEnabled, groupUpdatesEnabled: $groupUpdatesEnabled, eventRemindersEnabled: $eventRemindersEnabled, mentionsEnabled: $mentionsEnabled, marketingEnabled: $marketingEnabled)';
}


}

/// @nodoc
abstract mixin class $NotificationPreferencesCopyWith<$Res>  {
  factory $NotificationPreferencesCopyWith(NotificationPreferences value, $Res Function(NotificationPreferences) _then) = _$NotificationPreferencesCopyWithImpl;
@useResult
$Res call({
 bool pushEnabled, bool emailEnabled, bool friendRequestsEnabled, bool messagesEnabled, bool groupUpdatesEnabled, bool eventRemindersEnabled, bool mentionsEnabled, bool marketingEnabled
});




}
/// @nodoc
class _$NotificationPreferencesCopyWithImpl<$Res>
    implements $NotificationPreferencesCopyWith<$Res> {
  _$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final NotificationPreferences _self;
  final $Res Function(NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pushEnabled = null,Object? emailEnabled = null,Object? friendRequestsEnabled = null,Object? messagesEnabled = null,Object? groupUpdatesEnabled = null,Object? eventRemindersEnabled = null,Object? mentionsEnabled = null,Object? marketingEnabled = null,}) {
  return _then(_self.copyWith(
pushEnabled: null == pushEnabled ? _self.pushEnabled : pushEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailEnabled: null == emailEnabled ? _self.emailEnabled : emailEnabled // ignore: cast_nullable_to_non_nullable
as bool,friendRequestsEnabled: null == friendRequestsEnabled ? _self.friendRequestsEnabled : friendRequestsEnabled // ignore: cast_nullable_to_non_nullable
as bool,messagesEnabled: null == messagesEnabled ? _self.messagesEnabled : messagesEnabled // ignore: cast_nullable_to_non_nullable
as bool,groupUpdatesEnabled: null == groupUpdatesEnabled ? _self.groupUpdatesEnabled : groupUpdatesEnabled // ignore: cast_nullable_to_non_nullable
as bool,eventRemindersEnabled: null == eventRemindersEnabled ? _self.eventRemindersEnabled : eventRemindersEnabled // ignore: cast_nullable_to_non_nullable
as bool,mentionsEnabled: null == mentionsEnabled ? _self.mentionsEnabled : mentionsEnabled // ignore: cast_nullable_to_non_nullable
as bool,marketingEnabled: null == marketingEnabled ? _self.marketingEnabled : marketingEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPreferences].
extension NotificationPreferencesPatterns on NotificationPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPreferences value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool pushEnabled,  bool emailEnabled,  bool friendRequestsEnabled,  bool messagesEnabled,  bool groupUpdatesEnabled,  bool eventRemindersEnabled,  bool mentionsEnabled,  bool marketingEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.pushEnabled,_that.emailEnabled,_that.friendRequestsEnabled,_that.messagesEnabled,_that.groupUpdatesEnabled,_that.eventRemindersEnabled,_that.mentionsEnabled,_that.marketingEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool pushEnabled,  bool emailEnabled,  bool friendRequestsEnabled,  bool messagesEnabled,  bool groupUpdatesEnabled,  bool eventRemindersEnabled,  bool mentionsEnabled,  bool marketingEnabled)  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences():
return $default(_that.pushEnabled,_that.emailEnabled,_that.friendRequestsEnabled,_that.messagesEnabled,_that.groupUpdatesEnabled,_that.eventRemindersEnabled,_that.mentionsEnabled,_that.marketingEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool pushEnabled,  bool emailEnabled,  bool friendRequestsEnabled,  bool messagesEnabled,  bool groupUpdatesEnabled,  bool eventRemindersEnabled,  bool mentionsEnabled,  bool marketingEnabled)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.pushEnabled,_that.emailEnabled,_that.friendRequestsEnabled,_that.messagesEnabled,_that.groupUpdatesEnabled,_that.eventRemindersEnabled,_that.mentionsEnabled,_that.marketingEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPreferences implements NotificationPreferences {
  const _NotificationPreferences({this.pushEnabled = true, this.emailEnabled = true, this.friendRequestsEnabled = true, this.messagesEnabled = true, this.groupUpdatesEnabled = true, this.eventRemindersEnabled = true, this.mentionsEnabled = true, this.marketingEnabled = false});
  factory _NotificationPreferences.fromJson(Map<String, dynamic> json) => _$NotificationPreferencesFromJson(json);

@override@JsonKey() final  bool pushEnabled;
@override@JsonKey() final  bool emailEnabled;
@override@JsonKey() final  bool friendRequestsEnabled;
@override@JsonKey() final  bool messagesEnabled;
@override@JsonKey() final  bool groupUpdatesEnabled;
@override@JsonKey() final  bool eventRemindersEnabled;
@override@JsonKey() final  bool mentionsEnabled;
@override@JsonKey() final  bool marketingEnabled;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPreferencesCopyWith<_NotificationPreferences> get copyWith => __$NotificationPreferencesCopyWithImpl<_NotificationPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPreferences&&(identical(other.pushEnabled, pushEnabled) || other.pushEnabled == pushEnabled)&&(identical(other.emailEnabled, emailEnabled) || other.emailEnabled == emailEnabled)&&(identical(other.friendRequestsEnabled, friendRequestsEnabled) || other.friendRequestsEnabled == friendRequestsEnabled)&&(identical(other.messagesEnabled, messagesEnabled) || other.messagesEnabled == messagesEnabled)&&(identical(other.groupUpdatesEnabled, groupUpdatesEnabled) || other.groupUpdatesEnabled == groupUpdatesEnabled)&&(identical(other.eventRemindersEnabled, eventRemindersEnabled) || other.eventRemindersEnabled == eventRemindersEnabled)&&(identical(other.mentionsEnabled, mentionsEnabled) || other.mentionsEnabled == mentionsEnabled)&&(identical(other.marketingEnabled, marketingEnabled) || other.marketingEnabled == marketingEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pushEnabled,emailEnabled,friendRequestsEnabled,messagesEnabled,groupUpdatesEnabled,eventRemindersEnabled,mentionsEnabled,marketingEnabled);

@override
String toString() {
  return 'NotificationPreferences(pushEnabled: $pushEnabled, emailEnabled: $emailEnabled, friendRequestsEnabled: $friendRequestsEnabled, messagesEnabled: $messagesEnabled, groupUpdatesEnabled: $groupUpdatesEnabled, eventRemindersEnabled: $eventRemindersEnabled, mentionsEnabled: $mentionsEnabled, marketingEnabled: $marketingEnabled)';
}


}

/// @nodoc
abstract mixin class _$NotificationPreferencesCopyWith<$Res> implements $NotificationPreferencesCopyWith<$Res> {
  factory _$NotificationPreferencesCopyWith(_NotificationPreferences value, $Res Function(_NotificationPreferences) _then) = __$NotificationPreferencesCopyWithImpl;
@override @useResult
$Res call({
 bool pushEnabled, bool emailEnabled, bool friendRequestsEnabled, bool messagesEnabled, bool groupUpdatesEnabled, bool eventRemindersEnabled, bool mentionsEnabled, bool marketingEnabled
});




}
/// @nodoc
class __$NotificationPreferencesCopyWithImpl<$Res>
    implements _$NotificationPreferencesCopyWith<$Res> {
  __$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final _NotificationPreferences _self;
  final $Res Function(_NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pushEnabled = null,Object? emailEnabled = null,Object? friendRequestsEnabled = null,Object? messagesEnabled = null,Object? groupUpdatesEnabled = null,Object? eventRemindersEnabled = null,Object? mentionsEnabled = null,Object? marketingEnabled = null,}) {
  return _then(_NotificationPreferences(
pushEnabled: null == pushEnabled ? _self.pushEnabled : pushEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailEnabled: null == emailEnabled ? _self.emailEnabled : emailEnabled // ignore: cast_nullable_to_non_nullable
as bool,friendRequestsEnabled: null == friendRequestsEnabled ? _self.friendRequestsEnabled : friendRequestsEnabled // ignore: cast_nullable_to_non_nullable
as bool,messagesEnabled: null == messagesEnabled ? _self.messagesEnabled : messagesEnabled // ignore: cast_nullable_to_non_nullable
as bool,groupUpdatesEnabled: null == groupUpdatesEnabled ? _self.groupUpdatesEnabled : groupUpdatesEnabled // ignore: cast_nullable_to_non_nullable
as bool,eventRemindersEnabled: null == eventRemindersEnabled ? _self.eventRemindersEnabled : eventRemindersEnabled // ignore: cast_nullable_to_non_nullable
as bool,mentionsEnabled: null == mentionsEnabled ? _self.mentionsEnabled : mentionsEnabled // ignore: cast_nullable_to_non_nullable
as bool,marketingEnabled: null == marketingEnabled ? _self.marketingEnabled : marketingEnabled // ignore: cast_nullable_to_non_nullable
as bool,
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
