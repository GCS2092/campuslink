// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messaging_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Conversation {

 String get id; String get conversationType; String? get name; String? get groupId; GroupBasic? get group; String get createdById; UserBasic? get createdBy; String? get lastMessageAt; String? get createdAt; String? get updatedAt; List<Participant>? get participants; Message? get lastMessage; int? get unreadCount;
/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationCopyWith<Conversation> get copyWith => _$ConversationCopyWithImpl<Conversation>(this as Conversation, _$identity);

  /// Serializes this Conversation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Conversation&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationType, conversationType) || other.conversationType == conversationType)&&(identical(other.name, name) || other.name == name)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.group, group) || other.group == group)&&(identical(other.createdById, createdById) || other.createdById == createdById)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.participants, participants)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationType,name,groupId,group,createdById,createdBy,lastMessageAt,createdAt,updatedAt,const DeepCollectionEquality().hash(participants),lastMessage,unreadCount);

@override
String toString() {
  return 'Conversation(id: $id, conversationType: $conversationType, name: $name, groupId: $groupId, group: $group, createdById: $createdById, createdBy: $createdBy, lastMessageAt: $lastMessageAt, createdAt: $createdAt, updatedAt: $updatedAt, participants: $participants, lastMessage: $lastMessage, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class $ConversationCopyWith<$Res>  {
  factory $ConversationCopyWith(Conversation value, $Res Function(Conversation) _then) = _$ConversationCopyWithImpl;
@useResult
$Res call({
 String id, String conversationType, String? name, String? groupId, GroupBasic? group, String createdById, UserBasic? createdBy, String? lastMessageAt, String? createdAt, String? updatedAt, List<Participant>? participants, Message? lastMessage, int? unreadCount
});


$GroupBasicCopyWith<$Res>? get group;$UserBasicCopyWith<$Res>? get createdBy;$MessageCopyWith<$Res>? get lastMessage;

}
/// @nodoc
class _$ConversationCopyWithImpl<$Res>
    implements $ConversationCopyWith<$Res> {
  _$ConversationCopyWithImpl(this._self, this._then);

  final Conversation _self;
  final $Res Function(Conversation) _then;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? conversationType = null,Object? name = freezed,Object? groupId = freezed,Object? group = freezed,Object? createdById = null,Object? createdBy = freezed,Object? lastMessageAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? participants = freezed,Object? lastMessage = freezed,Object? unreadCount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationType: null == conversationType ? _self.conversationType : conversationType // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as GroupBasic?,createdById: null == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as UserBasic?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,participants: freezed == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<Participant>?,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as Message?,unreadCount: freezed == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupBasicCopyWith<$Res>? get group {
    if (_self.group == null) {
    return null;
  }

  return $GroupBasicCopyWith<$Res>(_self.group!, (value) {
    return _then(_self.copyWith(group: value));
  });
}/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserBasicCopyWith<$Res>? get createdBy {
    if (_self.createdBy == null) {
    return null;
  }

  return $UserBasicCopyWith<$Res>(_self.createdBy!, (value) {
    return _then(_self.copyWith(createdBy: value));
  });
}/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageCopyWith<$Res>? get lastMessage {
    if (_self.lastMessage == null) {
    return null;
  }

  return $MessageCopyWith<$Res>(_self.lastMessage!, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}


/// Adds pattern-matching-related methods to [Conversation].
extension ConversationPatterns on Conversation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Conversation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Conversation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Conversation value)  $default,){
final _that = this;
switch (_that) {
case _Conversation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Conversation value)?  $default,){
final _that = this;
switch (_that) {
case _Conversation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String conversationType,  String? name,  String? groupId,  GroupBasic? group,  String createdById,  UserBasic? createdBy,  String? lastMessageAt,  String? createdAt,  String? updatedAt,  List<Participant>? participants,  Message? lastMessage,  int? unreadCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Conversation() when $default != null:
return $default(_that.id,_that.conversationType,_that.name,_that.groupId,_that.group,_that.createdById,_that.createdBy,_that.lastMessageAt,_that.createdAt,_that.updatedAt,_that.participants,_that.lastMessage,_that.unreadCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String conversationType,  String? name,  String? groupId,  GroupBasic? group,  String createdById,  UserBasic? createdBy,  String? lastMessageAt,  String? createdAt,  String? updatedAt,  List<Participant>? participants,  Message? lastMessage,  int? unreadCount)  $default,) {final _that = this;
switch (_that) {
case _Conversation():
return $default(_that.id,_that.conversationType,_that.name,_that.groupId,_that.group,_that.createdById,_that.createdBy,_that.lastMessageAt,_that.createdAt,_that.updatedAt,_that.participants,_that.lastMessage,_that.unreadCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String conversationType,  String? name,  String? groupId,  GroupBasic? group,  String createdById,  UserBasic? createdBy,  String? lastMessageAt,  String? createdAt,  String? updatedAt,  List<Participant>? participants,  Message? lastMessage,  int? unreadCount)?  $default,) {final _that = this;
switch (_that) {
case _Conversation() when $default != null:
return $default(_that.id,_that.conversationType,_that.name,_that.groupId,_that.group,_that.createdById,_that.createdBy,_that.lastMessageAt,_that.createdAt,_that.updatedAt,_that.participants,_that.lastMessage,_that.unreadCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Conversation implements Conversation {
  const _Conversation({required this.id, this.conversationType = 'private', this.name, this.groupId, this.group, required this.createdById, this.createdBy, this.lastMessageAt, this.createdAt, this.updatedAt, final  List<Participant>? participants, this.lastMessage, this.unreadCount}): _participants = participants;
  factory _Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);

@override final  String id;
@override@JsonKey() final  String conversationType;
@override final  String? name;
@override final  String? groupId;
@override final  GroupBasic? group;
@override final  String createdById;
@override final  UserBasic? createdBy;
@override final  String? lastMessageAt;
@override final  String? createdAt;
@override final  String? updatedAt;
 final  List<Participant>? _participants;
@override List<Participant>? get participants {
  final value = _participants;
  if (value == null) return null;
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  Message? lastMessage;
@override final  int? unreadCount;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationCopyWith<_Conversation> get copyWith => __$ConversationCopyWithImpl<_Conversation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConversationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Conversation&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationType, conversationType) || other.conversationType == conversationType)&&(identical(other.name, name) || other.name == name)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.group, group) || other.group == group)&&(identical(other.createdById, createdById) || other.createdById == createdById)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._participants, _participants)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationType,name,groupId,group,createdById,createdBy,lastMessageAt,createdAt,updatedAt,const DeepCollectionEquality().hash(_participants),lastMessage,unreadCount);

@override
String toString() {
  return 'Conversation(id: $id, conversationType: $conversationType, name: $name, groupId: $groupId, group: $group, createdById: $createdById, createdBy: $createdBy, lastMessageAt: $lastMessageAt, createdAt: $createdAt, updatedAt: $updatedAt, participants: $participants, lastMessage: $lastMessage, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class _$ConversationCopyWith<$Res> implements $ConversationCopyWith<$Res> {
  factory _$ConversationCopyWith(_Conversation value, $Res Function(_Conversation) _then) = __$ConversationCopyWithImpl;
@override @useResult
$Res call({
 String id, String conversationType, String? name, String? groupId, GroupBasic? group, String createdById, UserBasic? createdBy, String? lastMessageAt, String? createdAt, String? updatedAt, List<Participant>? participants, Message? lastMessage, int? unreadCount
});


@override $GroupBasicCopyWith<$Res>? get group;@override $UserBasicCopyWith<$Res>? get createdBy;@override $MessageCopyWith<$Res>? get lastMessage;

}
/// @nodoc
class __$ConversationCopyWithImpl<$Res>
    implements _$ConversationCopyWith<$Res> {
  __$ConversationCopyWithImpl(this._self, this._then);

  final _Conversation _self;
  final $Res Function(_Conversation) _then;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? conversationType = null,Object? name = freezed,Object? groupId = freezed,Object? group = freezed,Object? createdById = null,Object? createdBy = freezed,Object? lastMessageAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? participants = freezed,Object? lastMessage = freezed,Object? unreadCount = freezed,}) {
  return _then(_Conversation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationType: null == conversationType ? _self.conversationType : conversationType // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as GroupBasic?,createdById: null == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as UserBasic?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,participants: freezed == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<Participant>?,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as Message?,unreadCount: freezed == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupBasicCopyWith<$Res>? get group {
    if (_self.group == null) {
    return null;
  }

  return $GroupBasicCopyWith<$Res>(_self.group!, (value) {
    return _then(_self.copyWith(group: value));
  });
}/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserBasicCopyWith<$Res>? get createdBy {
    if (_self.createdBy == null) {
    return null;
  }

  return $UserBasicCopyWith<$Res>(_self.createdBy!, (value) {
    return _then(_self.copyWith(createdBy: value));
  });
}/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageCopyWith<$Res>? get lastMessage {
    if (_self.lastMessage == null) {
    return null;
  }

  return $MessageCopyWith<$Res>(_self.lastMessage!, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}


/// @nodoc
mixin _$Participant {

 String get id; String get conversationId; String get userId; UserBasic? get user; String? get joinedAt; String? get leftAt; bool get isActive; String? get lastReadAt; int get unreadCount; bool get isPinned; bool get isArchived; bool get isFavorite; bool get muteNotifications;
/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParticipantCopyWith<Participant> get copyWith => _$ParticipantCopyWithImpl<Participant>(this as Participant, _$identity);

  /// Serializes this Participant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Participant&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.user, user) || other.user == user)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.leftAt, leftAt) || other.leftAt == leftAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.muteNotifications, muteNotifications) || other.muteNotifications == muteNotifications));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,userId,user,joinedAt,leftAt,isActive,lastReadAt,unreadCount,isPinned,isArchived,isFavorite,muteNotifications);

@override
String toString() {
  return 'Participant(id: $id, conversationId: $conversationId, userId: $userId, user: $user, joinedAt: $joinedAt, leftAt: $leftAt, isActive: $isActive, lastReadAt: $lastReadAt, unreadCount: $unreadCount, isPinned: $isPinned, isArchived: $isArchived, isFavorite: $isFavorite, muteNotifications: $muteNotifications)';
}


}

/// @nodoc
abstract mixin class $ParticipantCopyWith<$Res>  {
  factory $ParticipantCopyWith(Participant value, $Res Function(Participant) _then) = _$ParticipantCopyWithImpl;
@useResult
$Res call({
 String id, String conversationId, String userId, UserBasic? user, String? joinedAt, String? leftAt, bool isActive, String? lastReadAt, int unreadCount, bool isPinned, bool isArchived, bool isFavorite, bool muteNotifications
});


$UserBasicCopyWith<$Res>? get user;

}
/// @nodoc
class _$ParticipantCopyWithImpl<$Res>
    implements $ParticipantCopyWith<$Res> {
  _$ParticipantCopyWithImpl(this._self, this._then);

  final Participant _self;
  final $Res Function(Participant) _then;

/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? conversationId = null,Object? userId = null,Object? user = freezed,Object? joinedAt = freezed,Object? leftAt = freezed,Object? isActive = null,Object? lastReadAt = freezed,Object? unreadCount = null,Object? isPinned = null,Object? isArchived = null,Object? isFavorite = null,Object? muteNotifications = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserBasic?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as String?,leftAt: freezed == leftAt ? _self.leftAt : leftAt // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,lastReadAt: freezed == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as String?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,muteNotifications: null == muteNotifications ? _self.muteNotifications : muteNotifications // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of Participant
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


/// Adds pattern-matching-related methods to [Participant].
extension ParticipantPatterns on Participant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Participant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Participant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Participant value)  $default,){
final _that = this;
switch (_that) {
case _Participant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Participant value)?  $default,){
final _that = this;
switch (_that) {
case _Participant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String conversationId,  String userId,  UserBasic? user,  String? joinedAt,  String? leftAt,  bool isActive,  String? lastReadAt,  int unreadCount,  bool isPinned,  bool isArchived,  bool isFavorite,  bool muteNotifications)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Participant() when $default != null:
return $default(_that.id,_that.conversationId,_that.userId,_that.user,_that.joinedAt,_that.leftAt,_that.isActive,_that.lastReadAt,_that.unreadCount,_that.isPinned,_that.isArchived,_that.isFavorite,_that.muteNotifications);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String conversationId,  String userId,  UserBasic? user,  String? joinedAt,  String? leftAt,  bool isActive,  String? lastReadAt,  int unreadCount,  bool isPinned,  bool isArchived,  bool isFavorite,  bool muteNotifications)  $default,) {final _that = this;
switch (_that) {
case _Participant():
return $default(_that.id,_that.conversationId,_that.userId,_that.user,_that.joinedAt,_that.leftAt,_that.isActive,_that.lastReadAt,_that.unreadCount,_that.isPinned,_that.isArchived,_that.isFavorite,_that.muteNotifications);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String conversationId,  String userId,  UserBasic? user,  String? joinedAt,  String? leftAt,  bool isActive,  String? lastReadAt,  int unreadCount,  bool isPinned,  bool isArchived,  bool isFavorite,  bool muteNotifications)?  $default,) {final _that = this;
switch (_that) {
case _Participant() when $default != null:
return $default(_that.id,_that.conversationId,_that.userId,_that.user,_that.joinedAt,_that.leftAt,_that.isActive,_that.lastReadAt,_that.unreadCount,_that.isPinned,_that.isArchived,_that.isFavorite,_that.muteNotifications);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Participant implements Participant {
  const _Participant({required this.id, required this.conversationId, required this.userId, this.user, this.joinedAt, this.leftAt, this.isActive = true, this.lastReadAt, this.unreadCount = 0, this.isPinned = false, this.isArchived = false, this.isFavorite = false, this.muteNotifications = false});
  factory _Participant.fromJson(Map<String, dynamic> json) => _$ParticipantFromJson(json);

@override final  String id;
@override final  String conversationId;
@override final  String userId;
@override final  UserBasic? user;
@override final  String? joinedAt;
@override final  String? leftAt;
@override@JsonKey() final  bool isActive;
@override final  String? lastReadAt;
@override@JsonKey() final  int unreadCount;
@override@JsonKey() final  bool isPinned;
@override@JsonKey() final  bool isArchived;
@override@JsonKey() final  bool isFavorite;
@override@JsonKey() final  bool muteNotifications;

/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParticipantCopyWith<_Participant> get copyWith => __$ParticipantCopyWithImpl<_Participant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParticipantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Participant&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.user, user) || other.user == user)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.leftAt, leftAt) || other.leftAt == leftAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.muteNotifications, muteNotifications) || other.muteNotifications == muteNotifications));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,userId,user,joinedAt,leftAt,isActive,lastReadAt,unreadCount,isPinned,isArchived,isFavorite,muteNotifications);

@override
String toString() {
  return 'Participant(id: $id, conversationId: $conversationId, userId: $userId, user: $user, joinedAt: $joinedAt, leftAt: $leftAt, isActive: $isActive, lastReadAt: $lastReadAt, unreadCount: $unreadCount, isPinned: $isPinned, isArchived: $isArchived, isFavorite: $isFavorite, muteNotifications: $muteNotifications)';
}


}

/// @nodoc
abstract mixin class _$ParticipantCopyWith<$Res> implements $ParticipantCopyWith<$Res> {
  factory _$ParticipantCopyWith(_Participant value, $Res Function(_Participant) _then) = __$ParticipantCopyWithImpl;
@override @useResult
$Res call({
 String id, String conversationId, String userId, UserBasic? user, String? joinedAt, String? leftAt, bool isActive, String? lastReadAt, int unreadCount, bool isPinned, bool isArchived, bool isFavorite, bool muteNotifications
});


@override $UserBasicCopyWith<$Res>? get user;

}
/// @nodoc
class __$ParticipantCopyWithImpl<$Res>
    implements _$ParticipantCopyWith<$Res> {
  __$ParticipantCopyWithImpl(this._self, this._then);

  final _Participant _self;
  final $Res Function(_Participant) _then;

/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? conversationId = null,Object? userId = null,Object? user = freezed,Object? joinedAt = freezed,Object? leftAt = freezed,Object? isActive = null,Object? lastReadAt = freezed,Object? unreadCount = null,Object? isPinned = null,Object? isArchived = null,Object? isFavorite = null,Object? muteNotifications = null,}) {
  return _then(_Participant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserBasic?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as String?,leftAt: freezed == leftAt ? _self.leftAt : leftAt // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,lastReadAt: freezed == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as String?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,muteNotifications: null == muteNotifications ? _self.muteNotifications : muteNotifications // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Participant
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
mixin _$Message {

 String get id; String get conversationId; String get senderId; UserBasic? get sender; String get content; String get messageType; String? get attachmentUrl; String? get attachmentName; int? get attachmentSize; bool get isRead; List<String>? get readBy; String? get createdAt; String? get editedAt; String? get deletedAt; bool get isDeletedForAll; List<MessageReaction>? get reactions;
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageCopyWith<Message> get copyWith => _$MessageCopyWithImpl<Message>(this as Message, _$identity);

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Message&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.content, content) || other.content == content)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.attachmentUrl, attachmentUrl) || other.attachmentUrl == attachmentUrl)&&(identical(other.attachmentName, attachmentName) || other.attachmentName == attachmentName)&&(identical(other.attachmentSize, attachmentSize) || other.attachmentSize == attachmentSize)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&const DeepCollectionEquality().equals(other.readBy, readBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.isDeletedForAll, isDeletedForAll) || other.isDeletedForAll == isDeletedForAll)&&const DeepCollectionEquality().equals(other.reactions, reactions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,senderId,sender,content,messageType,attachmentUrl,attachmentName,attachmentSize,isRead,const DeepCollectionEquality().hash(readBy),createdAt,editedAt,deletedAt,isDeletedForAll,const DeepCollectionEquality().hash(reactions));

@override
String toString() {
  return 'Message(id: $id, conversationId: $conversationId, senderId: $senderId, sender: $sender, content: $content, messageType: $messageType, attachmentUrl: $attachmentUrl, attachmentName: $attachmentName, attachmentSize: $attachmentSize, isRead: $isRead, readBy: $readBy, createdAt: $createdAt, editedAt: $editedAt, deletedAt: $deletedAt, isDeletedForAll: $isDeletedForAll, reactions: $reactions)';
}


}

/// @nodoc
abstract mixin class $MessageCopyWith<$Res>  {
  factory $MessageCopyWith(Message value, $Res Function(Message) _then) = _$MessageCopyWithImpl;
@useResult
$Res call({
 String id, String conversationId, String senderId, UserBasic? sender, String content, String messageType, String? attachmentUrl, String? attachmentName, int? attachmentSize, bool isRead, List<String>? readBy, String? createdAt, String? editedAt, String? deletedAt, bool isDeletedForAll, List<MessageReaction>? reactions
});


$UserBasicCopyWith<$Res>? get sender;

}
/// @nodoc
class _$MessageCopyWithImpl<$Res>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._self, this._then);

  final Message _self;
  final $Res Function(Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? conversationId = null,Object? senderId = null,Object? sender = freezed,Object? content = null,Object? messageType = null,Object? attachmentUrl = freezed,Object? attachmentName = freezed,Object? attachmentSize = freezed,Object? isRead = null,Object? readBy = freezed,Object? createdAt = freezed,Object? editedAt = freezed,Object? deletedAt = freezed,Object? isDeletedForAll = null,Object? reactions = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as UserBasic?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String,attachmentUrl: freezed == attachmentUrl ? _self.attachmentUrl : attachmentUrl // ignore: cast_nullable_to_non_nullable
as String?,attachmentName: freezed == attachmentName ? _self.attachmentName : attachmentName // ignore: cast_nullable_to_non_nullable
as String?,attachmentSize: freezed == attachmentSize ? _self.attachmentSize : attachmentSize // ignore: cast_nullable_to_non_nullable
as int?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,readBy: freezed == readBy ? _self.readBy : readBy // ignore: cast_nullable_to_non_nullable
as List<String>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as String?,isDeletedForAll: null == isDeletedForAll ? _self.isDeletedForAll : isDeletedForAll // ignore: cast_nullable_to_non_nullable
as bool,reactions: freezed == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<MessageReaction>?,
  ));
}
/// Create a copy of Message
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


/// Adds pattern-matching-related methods to [Message].
extension MessagePatterns on Message {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Message value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Message value)  $default,){
final _that = this;
switch (_that) {
case _Message():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Message value)?  $default,){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String conversationId,  String senderId,  UserBasic? sender,  String content,  String messageType,  String? attachmentUrl,  String? attachmentName,  int? attachmentSize,  bool isRead,  List<String>? readBy,  String? createdAt,  String? editedAt,  String? deletedAt,  bool isDeletedForAll,  List<MessageReaction>? reactions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.conversationId,_that.senderId,_that.sender,_that.content,_that.messageType,_that.attachmentUrl,_that.attachmentName,_that.attachmentSize,_that.isRead,_that.readBy,_that.createdAt,_that.editedAt,_that.deletedAt,_that.isDeletedForAll,_that.reactions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String conversationId,  String senderId,  UserBasic? sender,  String content,  String messageType,  String? attachmentUrl,  String? attachmentName,  int? attachmentSize,  bool isRead,  List<String>? readBy,  String? createdAt,  String? editedAt,  String? deletedAt,  bool isDeletedForAll,  List<MessageReaction>? reactions)  $default,) {final _that = this;
switch (_that) {
case _Message():
return $default(_that.id,_that.conversationId,_that.senderId,_that.sender,_that.content,_that.messageType,_that.attachmentUrl,_that.attachmentName,_that.attachmentSize,_that.isRead,_that.readBy,_that.createdAt,_that.editedAt,_that.deletedAt,_that.isDeletedForAll,_that.reactions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String conversationId,  String senderId,  UserBasic? sender,  String content,  String messageType,  String? attachmentUrl,  String? attachmentName,  int? attachmentSize,  bool isRead,  List<String>? readBy,  String? createdAt,  String? editedAt,  String? deletedAt,  bool isDeletedForAll,  List<MessageReaction>? reactions)?  $default,) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.conversationId,_that.senderId,_that.sender,_that.content,_that.messageType,_that.attachmentUrl,_that.attachmentName,_that.attachmentSize,_that.isRead,_that.readBy,_that.createdAt,_that.editedAt,_that.deletedAt,_that.isDeletedForAll,_that.reactions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Message implements Message {
  const _Message({required this.id, required this.conversationId, required this.senderId, this.sender, required this.content, this.messageType = 'text', this.attachmentUrl, this.attachmentName, this.attachmentSize, this.isRead = false, final  List<String>? readBy, this.createdAt, this.editedAt, this.deletedAt, this.isDeletedForAll = false, final  List<MessageReaction>? reactions}): _readBy = readBy,_reactions = reactions;
  factory _Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

@override final  String id;
@override final  String conversationId;
@override final  String senderId;
@override final  UserBasic? sender;
@override final  String content;
@override@JsonKey() final  String messageType;
@override final  String? attachmentUrl;
@override final  String? attachmentName;
@override final  int? attachmentSize;
@override@JsonKey() final  bool isRead;
 final  List<String>? _readBy;
@override List<String>? get readBy {
  final value = _readBy;
  if (value == null) return null;
  if (_readBy is EqualUnmodifiableListView) return _readBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? createdAt;
@override final  String? editedAt;
@override final  String? deletedAt;
@override@JsonKey() final  bool isDeletedForAll;
 final  List<MessageReaction>? _reactions;
@override List<MessageReaction>? get reactions {
  final value = _reactions;
  if (value == null) return null;
  if (_reactions is EqualUnmodifiableListView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageCopyWith<_Message> get copyWith => __$MessageCopyWithImpl<_Message>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Message&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.content, content) || other.content == content)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.attachmentUrl, attachmentUrl) || other.attachmentUrl == attachmentUrl)&&(identical(other.attachmentName, attachmentName) || other.attachmentName == attachmentName)&&(identical(other.attachmentSize, attachmentSize) || other.attachmentSize == attachmentSize)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&const DeepCollectionEquality().equals(other._readBy, _readBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.isDeletedForAll, isDeletedForAll) || other.isDeletedForAll == isDeletedForAll)&&const DeepCollectionEquality().equals(other._reactions, _reactions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,senderId,sender,content,messageType,attachmentUrl,attachmentName,attachmentSize,isRead,const DeepCollectionEquality().hash(_readBy),createdAt,editedAt,deletedAt,isDeletedForAll,const DeepCollectionEquality().hash(_reactions));

@override
String toString() {
  return 'Message(id: $id, conversationId: $conversationId, senderId: $senderId, sender: $sender, content: $content, messageType: $messageType, attachmentUrl: $attachmentUrl, attachmentName: $attachmentName, attachmentSize: $attachmentSize, isRead: $isRead, readBy: $readBy, createdAt: $createdAt, editedAt: $editedAt, deletedAt: $deletedAt, isDeletedForAll: $isDeletedForAll, reactions: $reactions)';
}


}

/// @nodoc
abstract mixin class _$MessageCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$MessageCopyWith(_Message value, $Res Function(_Message) _then) = __$MessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String conversationId, String senderId, UserBasic? sender, String content, String messageType, String? attachmentUrl, String? attachmentName, int? attachmentSize, bool isRead, List<String>? readBy, String? createdAt, String? editedAt, String? deletedAt, bool isDeletedForAll, List<MessageReaction>? reactions
});


@override $UserBasicCopyWith<$Res>? get sender;

}
/// @nodoc
class __$MessageCopyWithImpl<$Res>
    implements _$MessageCopyWith<$Res> {
  __$MessageCopyWithImpl(this._self, this._then);

  final _Message _self;
  final $Res Function(_Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? conversationId = null,Object? senderId = null,Object? sender = freezed,Object? content = null,Object? messageType = null,Object? attachmentUrl = freezed,Object? attachmentName = freezed,Object? attachmentSize = freezed,Object? isRead = null,Object? readBy = freezed,Object? createdAt = freezed,Object? editedAt = freezed,Object? deletedAt = freezed,Object? isDeletedForAll = null,Object? reactions = freezed,}) {
  return _then(_Message(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as UserBasic?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String,attachmentUrl: freezed == attachmentUrl ? _self.attachmentUrl : attachmentUrl // ignore: cast_nullable_to_non_nullable
as String?,attachmentName: freezed == attachmentName ? _self.attachmentName : attachmentName // ignore: cast_nullable_to_non_nullable
as String?,attachmentSize: freezed == attachmentSize ? _self.attachmentSize : attachmentSize // ignore: cast_nullable_to_non_nullable
as int?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,readBy: freezed == readBy ? _self._readBy : readBy // ignore: cast_nullable_to_non_nullable
as List<String>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as String?,isDeletedForAll: null == isDeletedForAll ? _self.isDeletedForAll : isDeletedForAll // ignore: cast_nullable_to_non_nullable
as bool,reactions: freezed == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<MessageReaction>?,
  ));
}

/// Create a copy of Message
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
mixin _$MessageReaction {

 String get id; String get messageId; String get userId; UserBasic? get user; String get emoji; String? get createdAt;
/// Create a copy of MessageReaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageReactionCopyWith<MessageReaction> get copyWith => _$MessageReactionCopyWithImpl<MessageReaction>(this as MessageReaction, _$identity);

  /// Serializes this MessageReaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageReaction&&(identical(other.id, id) || other.id == id)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.user, user) || other.user == user)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,messageId,userId,user,emoji,createdAt);

@override
String toString() {
  return 'MessageReaction(id: $id, messageId: $messageId, userId: $userId, user: $user, emoji: $emoji, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MessageReactionCopyWith<$Res>  {
  factory $MessageReactionCopyWith(MessageReaction value, $Res Function(MessageReaction) _then) = _$MessageReactionCopyWithImpl;
@useResult
$Res call({
 String id, String messageId, String userId, UserBasic? user, String emoji, String? createdAt
});


$UserBasicCopyWith<$Res>? get user;

}
/// @nodoc
class _$MessageReactionCopyWithImpl<$Res>
    implements $MessageReactionCopyWith<$Res> {
  _$MessageReactionCopyWithImpl(this._self, this._then);

  final MessageReaction _self;
  final $Res Function(MessageReaction) _then;

/// Create a copy of MessageReaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? messageId = null,Object? userId = null,Object? user = freezed,Object? emoji = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserBasic?,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of MessageReaction
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


/// Adds pattern-matching-related methods to [MessageReaction].
extension MessageReactionPatterns on MessageReaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageReaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageReaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageReaction value)  $default,){
final _that = this;
switch (_that) {
case _MessageReaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageReaction value)?  $default,){
final _that = this;
switch (_that) {
case _MessageReaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String messageId,  String userId,  UserBasic? user,  String emoji,  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageReaction() when $default != null:
return $default(_that.id,_that.messageId,_that.userId,_that.user,_that.emoji,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String messageId,  String userId,  UserBasic? user,  String emoji,  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _MessageReaction():
return $default(_that.id,_that.messageId,_that.userId,_that.user,_that.emoji,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String messageId,  String userId,  UserBasic? user,  String emoji,  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MessageReaction() when $default != null:
return $default(_that.id,_that.messageId,_that.userId,_that.user,_that.emoji,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageReaction implements MessageReaction {
  const _MessageReaction({required this.id, required this.messageId, required this.userId, this.user, required this.emoji, this.createdAt});
  factory _MessageReaction.fromJson(Map<String, dynamic> json) => _$MessageReactionFromJson(json);

@override final  String id;
@override final  String messageId;
@override final  String userId;
@override final  UserBasic? user;
@override final  String emoji;
@override final  String? createdAt;

/// Create a copy of MessageReaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageReactionCopyWith<_MessageReaction> get copyWith => __$MessageReactionCopyWithImpl<_MessageReaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageReactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageReaction&&(identical(other.id, id) || other.id == id)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.user, user) || other.user == user)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,messageId,userId,user,emoji,createdAt);

@override
String toString() {
  return 'MessageReaction(id: $id, messageId: $messageId, userId: $userId, user: $user, emoji: $emoji, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MessageReactionCopyWith<$Res> implements $MessageReactionCopyWith<$Res> {
  factory _$MessageReactionCopyWith(_MessageReaction value, $Res Function(_MessageReaction) _then) = __$MessageReactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String messageId, String userId, UserBasic? user, String emoji, String? createdAt
});


@override $UserBasicCopyWith<$Res>? get user;

}
/// @nodoc
class __$MessageReactionCopyWithImpl<$Res>
    implements _$MessageReactionCopyWith<$Res> {
  __$MessageReactionCopyWithImpl(this._self, this._then);

  final _MessageReaction _self;
  final $Res Function(_MessageReaction) _then;

/// Create a copy of MessageReaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? messageId = null,Object? userId = null,Object? user = freezed,Object? emoji = null,Object? createdAt = freezed,}) {
  return _then(_MessageReaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserBasic?,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of MessageReaction
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


/// @nodoc
mixin _$GroupBasic {

 String get id; String get name; String? get slug; String? get profileImage;
/// Create a copy of GroupBasic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupBasicCopyWith<GroupBasic> get copyWith => _$GroupBasicCopyWithImpl<GroupBasic>(this as GroupBasic, _$identity);

  /// Serializes this GroupBasic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupBasic&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.profileImage, profileImage) || other.profileImage == profileImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,profileImage);

@override
String toString() {
  return 'GroupBasic(id: $id, name: $name, slug: $slug, profileImage: $profileImage)';
}


}

/// @nodoc
abstract mixin class $GroupBasicCopyWith<$Res>  {
  factory $GroupBasicCopyWith(GroupBasic value, $Res Function(GroupBasic) _then) = _$GroupBasicCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? slug, String? profileImage
});




}
/// @nodoc
class _$GroupBasicCopyWithImpl<$Res>
    implements $GroupBasicCopyWith<$Res> {
  _$GroupBasicCopyWithImpl(this._self, this._then);

  final GroupBasic _self;
  final $Res Function(GroupBasic) _then;

/// Create a copy of GroupBasic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = freezed,Object? profileImage = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,profileImage: freezed == profileImage ? _self.profileImage : profileImage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupBasic].
extension GroupBasicPatterns on GroupBasic {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupBasic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupBasic() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupBasic value)  $default,){
final _that = this;
switch (_that) {
case _GroupBasic():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupBasic value)?  $default,){
final _that = this;
switch (_that) {
case _GroupBasic() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? slug,  String? profileImage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupBasic() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.profileImage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? slug,  String? profileImage)  $default,) {final _that = this;
switch (_that) {
case _GroupBasic():
return $default(_that.id,_that.name,_that.slug,_that.profileImage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? slug,  String? profileImage)?  $default,) {final _that = this;
switch (_that) {
case _GroupBasic() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.profileImage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupBasic implements GroupBasic {
  const _GroupBasic({required this.id, required this.name, this.slug, this.profileImage});
  factory _GroupBasic.fromJson(Map<String, dynamic> json) => _$GroupBasicFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? slug;
@override final  String? profileImage;

/// Create a copy of GroupBasic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupBasicCopyWith<_GroupBasic> get copyWith => __$GroupBasicCopyWithImpl<_GroupBasic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupBasicToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupBasic&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.profileImage, profileImage) || other.profileImage == profileImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,profileImage);

@override
String toString() {
  return 'GroupBasic(id: $id, name: $name, slug: $slug, profileImage: $profileImage)';
}


}

/// @nodoc
abstract mixin class _$GroupBasicCopyWith<$Res> implements $GroupBasicCopyWith<$Res> {
  factory _$GroupBasicCopyWith(_GroupBasic value, $Res Function(_GroupBasic) _then) = __$GroupBasicCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? slug, String? profileImage
});




}
/// @nodoc
class __$GroupBasicCopyWithImpl<$Res>
    implements _$GroupBasicCopyWith<$Res> {
  __$GroupBasicCopyWithImpl(this._self, this._then);

  final _GroupBasic _self;
  final $Res Function(_GroupBasic) _then;

/// Create a copy of GroupBasic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = freezed,Object? profileImage = freezed,}) {
  return _then(_GroupBasic(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,profileImage: freezed == profileImage ? _self.profileImage : profileImage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
