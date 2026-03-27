import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';

// Provider for groups list
final groupsProvider = FutureProvider.family<List<Group>, GroupFilterParams>((ref, params) async {
  final service = ref.watch(groupServiceProvider);
  return service.getGroups(
    search: params.search,
    university: params.university,
    category: params.category,
    isPublic: params.isPublic,
    page: params.page,
    pageSize: params.pageSize,
  );
});

// Provider for a single group
final groupProvider = FutureProvider.family<Group, String>((ref, id) async {
  final service = ref.watch(groupServiceProvider);
  return service.getGroup(id);
});

// Provider for group members
final groupMembersProvider = FutureProvider.family<List<Membership>, GroupMembersParams>((ref, params) async {
  final service = ref.watch(groupServiceProvider);
  return service.getGroupMembers(params.groupId, page: params.page, pageSize: params.pageSize);
});

// Provider for group posts
final groupPostsProvider = FutureProvider.family<List<GroupPost>, GroupPostsParams>((ref, params) async {
  final service = ref.watch(groupServiceProvider);
  return service.getGroupPosts(groupId: params.groupId, page: params.page, pageSize: params.pageSize);
});

// State notifier for groups with pagination and filtering
class GroupsNotifier extends Notifier<GroupsState> {
  GroupService get _service => ref.read(groupServiceProvider);

  @override
  GroupsState build() => const GroupsState();

  Future<void> loadGroups({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(page: 1, groups: []);
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newGroups = await _service.getGroups(
        search: state.search,
        university: state.university,
        category: state.category,
        isPublic: state.isPublic,
        page: state.page,
        pageSize: state.pageSize,
      );

      final allGroups = refresh ? newGroups : [...state.groups, ...newGroups];

      state = state.copyWith(
        groups: allGroups,
        isLoading: false,
        hasMore: newGroups.length == state.pageSize,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearch(String? search) {
    state = state.copyWith(search: search, page: 1);
    loadGroups(refresh: true);
  }

  void setUniversity(String? university) {
    state = state.copyWith(university: university, page: 1);
    loadGroups(refresh: true);
  }

  void setCategory(String? category) {
    state = state.copyWith(category: category, page: 1);
    loadGroups(refresh: true);
  }

  void setIsPublic(bool? isPublic) {
    state = state.copyWith(isPublic: isPublic, page: 1);
    loadGroups(refresh: true);
  }

  Future<void> joinGroup(String groupId) async {
    try {
      await _service.joinGroup(groupId);
      // Update local state
      final updatedGroups = state.groups.map((g) {
        if (g.id == groupId) {
          return g.copyWith(
            isMember: true,
            hasPendingRequest: true,
            membersCount: g.membersCount + 1,
          );
        }
        return g;
      }).toList();
      state = state.copyWith(groups: updatedGroups);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> leaveGroup(String groupId) async {
    try {
      await _service.leaveGroup(groupId);
      // Update local state
      final updatedGroups = state.groups.map((g) {
        if (g.id == groupId) {
          return g.copyWith(
            isMember: false,
            hasPendingRequest: false,
            membersCount: g.membersCount - 1,
          );
        }
        return g;
      }).toList();
      state = state.copyWith(groups: updatedGroups);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<Group?> createGroup(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final newGroup = await _service.createGroup(data);
      state = state.copyWith(
        groups: [newGroup, ...state.groups],
        isLoading: false,
      );
      return newGroup;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }
}

final groupsNotifierProvider = NotifierProvider<GroupsNotifier, GroupsState>(
  GroupsNotifier.new,
);

// State class
class GroupsState {
  final List<Group> groups;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int page;
  final int pageSize;
  final String? search;
  final String? university;
  final String? category;
  final bool? isPublic;

  const GroupsState({
    this.groups = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.page = 1,
    this.pageSize = 20,
    this.search,
    this.university,
    this.category,
    this.isPublic,
  });

  GroupsState copyWith({
    List<Group>? groups,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? page,
    int? pageSize,
    String? search,
    String? university,
    String? category,
    bool? isPublic,
  }) {
    return GroupsState(
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      university: university ?? this.university,
      category: category ?? this.category,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}

// Filter params classes
class GroupFilterParams {
  final String? search;
  final String? university;
  final String? category;
  final bool? isPublic;
  final int? page;
  final int? pageSize;

  const GroupFilterParams({
    this.search,
    this.university,
    this.category,
    this.isPublic,
    this.page,
    this.pageSize,
  });
}

class GroupMembersParams {
  final String groupId;
  final int? page;
  final int? pageSize;

  const GroupMembersParams({required this.groupId, this.page, this.pageSize});
}

class GroupPostsParams {
  final String? groupId;
  final int? page;
  final int? pageSize;

  const GroupPostsParams({this.groupId, this.page, this.pageSize});
}
