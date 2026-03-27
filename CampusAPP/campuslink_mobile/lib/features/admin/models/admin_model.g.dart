// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminDashboardStats _$AdminDashboardStatsFromJson(Map<String, dynamic> json) =>
    _AdminDashboardStats(
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      activeUsers: (json['activeUsers'] as num?)?.toInt() ?? 0,
      pendingUsers: (json['pendingUsers'] as num?)?.toInt() ?? 0,
      bannedUsers: (json['bannedUsers'] as num?)?.toInt() ?? 0,
      totalEvents: (json['totalEvents'] as num?)?.toInt() ?? 0,
      totalGroups: (json['totalGroups'] as num?)?.toInt() ?? 0,
      totalPosts: (json['totalPosts'] as num?)?.toInt() ?? 0,
      reportsToday: (json['reportsToday'] as num?)?.toInt() ?? 0,
      userGrowth: json['userGrowth'] as Map<String, dynamic>?,
      activityStats: json['activityStats'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AdminDashboardStatsToJson(
  _AdminDashboardStats instance,
) => <String, dynamic>{
  'totalUsers': instance.totalUsers,
  'activeUsers': instance.activeUsers,
  'pendingUsers': instance.pendingUsers,
  'bannedUsers': instance.bannedUsers,
  'totalEvents': instance.totalEvents,
  'totalGroups': instance.totalGroups,
  'totalPosts': instance.totalPosts,
  'reportsToday': instance.reportsToday,
  'userGrowth': instance.userGrowth,
  'activityStats': instance.activityStats,
};

_UniversityAdminDashboardStats _$UniversityAdminDashboardStatsFromJson(
  Map<String, dynamic> json,
) => _UniversityAdminDashboardStats(
  totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
  activeStudents: (json['activeStudents'] as num?)?.toInt() ?? 0,
  pendingStudents: (json['pendingStudents'] as num?)?.toInt() ?? 0,
  classLeaders: (json['classLeaders'] as num?)?.toInt() ?? 0,
  totalGroups: (json['totalGroups'] as num?)?.toInt() ?? 0,
  totalEvents: (json['totalEvents'] as num?)?.toInt() ?? 0,
  universityName: json['universityName'] as String?,
  departmentStats: json['departmentStats'] as Map<String, dynamic>?,
  recentActivity: json['recentActivity'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$UniversityAdminDashboardStatsToJson(
  _UniversityAdminDashboardStats instance,
) => <String, dynamic>{
  'totalStudents': instance.totalStudents,
  'activeStudents': instance.activeStudents,
  'pendingStudents': instance.pendingStudents,
  'classLeaders': instance.classLeaders,
  'totalGroups': instance.totalGroups,
  'totalEvents': instance.totalEvents,
  'universityName': instance.universityName,
  'departmentStats': instance.departmentStats,
  'recentActivity': instance.recentActivity,
};

_ClassLeaderDashboardStats _$ClassLeaderDashboardStatsFromJson(
  Map<String, dynamic> json,
) => _ClassLeaderDashboardStats(
  classSize: (json['classSize'] as num?)?.toInt() ?? 0,
  activeStudents: (json['activeStudents'] as num?)?.toInt() ?? 0,
  pendingStudents: (json['pendingStudents'] as num?)?.toInt() ?? 0,
  classEvents: (json['classEvents'] as num?)?.toInt() ?? 0,
  classGroups: (json['classGroups'] as num?)?.toInt() ?? 0,
  className: json['className'] as String?,
  departmentName: json['departmentName'] as String?,
  recentActivities: (json['recentActivities'] as List<dynamic>?)
      ?.map((e) => StudentActivity.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ClassLeaderDashboardStatsToJson(
  _ClassLeaderDashboardStats instance,
) => <String, dynamic>{
  'classSize': instance.classSize,
  'activeStudents': instance.activeStudents,
  'pendingStudents': instance.pendingStudents,
  'classEvents': instance.classEvents,
  'classGroups': instance.classGroups,
  'className': instance.className,
  'departmentName': instance.departmentName,
  'recentActivities': instance.recentActivities,
};

_StudentActivity _$StudentActivityFromJson(Map<String, dynamic> json) =>
    _StudentActivity(
      id: json['id'] as String,
      studentName: json['studentName'] as String?,
      studentId: json['studentId'] as String?,
      activityType: json['activityType'] as String,
      description: json['description'] as String?,
      timestamp: json['timestamp'] as String?,
    );

Map<String, dynamic> _$StudentActivityToJson(_StudentActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentName': instance.studentName,
      'studentId': instance.studentId,
      'activityType': instance.activityType,
      'description': instance.description,
      'timestamp': instance.timestamp,
    };

_PendingStudent _$PendingStudentFromJson(Map<String, dynamic> json) =>
    _PendingStudent(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      university: json['university'] as String?,
      department: json['department'] as String?,
      studentId: json['studentId'] as String?,
      registrationDate: json['registrationDate'] as String?,
      verificationStatus: json['verificationStatus'] as String?,
    );

Map<String, dynamic> _$PendingStudentToJson(_PendingStudent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phoneNumber': instance.phoneNumber,
      'university': instance.university,
      'department': instance.department,
      'studentId': instance.studentId,
      'registrationDate': instance.registrationDate,
      'verificationStatus': instance.verificationStatus,
    };

_ClassLeader _$ClassLeaderFromJson(Map<String, dynamic> json) => _ClassLeader(
  id: json['id'] as String,
  userId: json['userId'] as String,
  username: json['username'] as String?,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  email: json['email'] as String?,
  profilePicture: json['profilePicture'] as String?,
  university: json['university'] as String?,
  department: json['department'] as String?,
  className: json['className'] as String?,
  studentsCount: (json['studentsCount'] as num?)?.toInt() ?? 0,
  assignedAt: json['assignedAt'] as String?,
);

Map<String, dynamic> _$ClassLeaderToJson(_ClassLeader instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'username': instance.username,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'profilePicture': instance.profilePicture,
      'university': instance.university,
      'department': instance.department,
      'className': instance.className,
      'studentsCount': instance.studentsCount,
      'assignedAt': instance.assignedAt,
    };
