import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_model.freezed.dart';
part 'admin_model.g.dart';

// ============ DASHBOARD STATS ============

@freezed
abstract class AdminDashboardStats with _$AdminDashboardStats {
  const factory AdminDashboardStats({
    @Default(0) int totalUsers,
    @Default(0) int activeUsers,
    @Default(0) int pendingUsers,
    @Default(0) int bannedUsers,
    @Default(0) int totalEvents,
    @Default(0) int totalGroups,
    @Default(0) int totalPosts,
    @Default(0) int reportsToday,
    Map<String, dynamic>? userGrowth,
    Map<String, dynamic>? activityStats,
  }) = _AdminDashboardStats;

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) =>
      _$AdminDashboardStatsFromJson(json);
}

@freezed
abstract class UniversityAdminDashboardStats with _$UniversityAdminDashboardStats {
  const factory UniversityAdminDashboardStats({
    @Default(0) int totalStudents,
    @Default(0) int activeStudents,
    @Default(0) int pendingStudents,
    @Default(0) int classLeaders,
    @Default(0) int totalGroups,
    @Default(0) int totalEvents,
    String? universityName,
    Map<String, dynamic>? departmentStats,
    Map<String, dynamic>? recentActivity,
  }) = _UniversityAdminDashboardStats;

  factory UniversityAdminDashboardStats.fromJson(Map<String, dynamic> json) =>
      _$UniversityAdminDashboardStatsFromJson(json);
}

@freezed
abstract class ClassLeaderDashboardStats with _$ClassLeaderDashboardStats {
  const factory ClassLeaderDashboardStats({
    @Default(0) int classSize,
    @Default(0) int activeStudents,
    @Default(0) int pendingStudents,
    @Default(0) int classEvents,
    @Default(0) int classGroups,
    String? className,
    String? departmentName,
    List<StudentActivity>? recentActivities,
  }) = _ClassLeaderDashboardStats;

  factory ClassLeaderDashboardStats.fromJson(Map<String, dynamic> json) =>
      _$ClassLeaderDashboardStatsFromJson(json);
}

@freezed
abstract class StudentActivity with _$StudentActivity {
  const factory StudentActivity({
    required String id,
    String? studentName,
    String? studentId,
    required String activityType,
    String? description,
    String? timestamp,
  }) = _StudentActivity;

  factory StudentActivity.fromJson(Map<String, dynamic> json) =>
      _$StudentActivityFromJson(json);
}

// ============ PENDING STUDENTS ============

@freezed
abstract class PendingStudent with _$PendingStudent {
  const factory PendingStudent({
    required String id,
    required String email,
    required String username,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? university,
    String? department,
    String? studentId,
    String? registrationDate,
    String? verificationStatus,
  }) = _PendingStudent;

  factory PendingStudent.fromJson(Map<String, dynamic> json) =>
      _$PendingStudentFromJson(json);
}

// ============ CLASS LEADERS ============

@freezed
abstract class ClassLeader with _$ClassLeader {
  const factory ClassLeader({
    required String id,
    required String userId,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? profilePicture,
    String? university,
    String? department,
    String? className,
    @Default(0) int studentsCount,
    String? assignedAt,
  }) = _ClassLeader;

  factory ClassLeader.fromJson(Map<String, dynamic> json) =>
      _$ClassLeaderFromJson(json);
}
