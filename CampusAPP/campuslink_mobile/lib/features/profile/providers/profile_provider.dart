import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/models/user_model.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/services/friend_service.dart';

// Provider for current user profile
final currentUserProvider = FutureProvider<User>((ref) async {
  final service = ref.watch(authServiceProvider);
  return service.getProfile();
});

// Provider for a specific user profile
final userProvider = FutureProvider.family<User, String>((ref, id) async {
  final service = ref.watch(authServiceProvider);
  // Note: This would need a getUserById endpoint in the service
  // For now, we'll use the profile endpoint as a placeholder
  return service.getProfile();
});

// Provider for friends list
final friendsProvider = FutureProvider.family<List<User>, FriendsFilterParams>((ref, params) async {
  final service = ref.watch(friendServiceProvider);
  return service.getFriends(
    status: params.status,
    page: params.page,
    pageSize: params.pageSize,
  );
});

// Provider for friend suggestions
final friendSuggestionsProvider = FutureProvider<List<User>>((ref) async {
  final service = ref.watch(friendServiceProvider);
  return service.getFriendSuggestions();
});

// Provider for friend requests
final friendRequestsProvider = FutureProvider.family<List<Friendship>, FriendRequestsFilterParams>((ref, params) async {
  final service = ref.watch(friendServiceProvider);
  return service.getFriendRequests(
    status: params.status,
    page: params.page,
    pageSize: params.pageSize,
  );
});

// State notifier for profile
class ProfileNotifier extends Notifier<ProfileState> {
  AuthService get _authService => ref.read(authServiceProvider);
  FriendService get _friendService => ref.read(friendServiceProvider);

  @override
  ProfileState build() => const ProfileState();

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.getProfile();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.updateProfile(data);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.changePassword(oldPassword, newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadFriends({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(friendsPage: 1, friends: []);
    }

    try {
      final newFriends = await _friendService.getFriends(
        page: state.friendsPage,
        pageSize: state.friendsPageSize,
      );

      final allFriends = refresh ? newFriends : [...state.friends, ...newFriends];

      state = state.copyWith(
        friends: allFriends,
        hasMoreFriends: newFriends.length == state.friendsPageSize,
        friendsPage: state.friendsPage + 1,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadFriendRequests({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(friendRequestsPage: 1, friendRequests: []);
    }

    try {
      final newRequests = await _friendService.getFriendRequests(
        status: 'pending',
        page: state.friendRequestsPage,
        pageSize: state.friendRequestsPageSize,
      );

      final allRequests = refresh ? newRequests : [...state.friendRequests, ...newRequests];

      state = state.copyWith(
        friendRequests: allRequests,
        hasMoreFriendRequests: newRequests.length == state.friendRequestsPageSize,
        friendRequestsPage: state.friendRequestsPage + 1,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> sendFriendRequest(String userId) async {
    try {
      await _friendService.sendFriendRequest(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> acceptFriendRequest(String friendshipId) async {
    try {
      await _friendService.acceptFriendRequest(friendshipId);
      // Reload friend requests and friends
      await loadFriendRequests(refresh: true);
      await loadFriends(refresh: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> rejectFriendRequest(String friendshipId) async {
    try {
      await _friendService.rejectFriendRequest(friendshipId);
      // Reload friend requests
      await loadFriendRequests(refresh: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeFriend(String friendshipId) async {
    try {
      await _friendService.removeFriend(friendshipId);
      // Reload friends
      await loadFriends(refresh: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final profileNotifierProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);

// State class
class ProfileState {
  final User? user;
  final bool isLoading;
  final String? error;
  final List<User> friends;
  final int friendsPage;
  final int friendsPageSize;
  final bool hasMoreFriends;
  final List<Friendship> friendRequests;
  final int friendRequestsPage;
  final int friendRequestsPageSize;
  final bool hasMoreFriendRequests;

  const ProfileState({
    this.user,
    this.isLoading = false,
    this.error,
    this.friends = const [],
    this.friendsPage = 1,
    this.friendsPageSize = 20,
    this.hasMoreFriends = true,
    this.friendRequests = const [],
    this.friendRequestsPage = 1,
    this.friendRequestsPageSize = 20,
    this.hasMoreFriendRequests = true,
  });

  ProfileState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    List<User>? friends,
    int? friendsPage,
    int? friendsPageSize,
    bool? hasMoreFriends,
    List<Friendship>? friendRequests,
    int? friendRequestsPage,
    int? friendRequestsPageSize,
    bool? hasMoreFriendRequests,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      friends: friends ?? this.friends,
      friendsPage: friendsPage ?? this.friendsPage,
      friendsPageSize: friendsPageSize ?? this.friendsPageSize,
      hasMoreFriends: hasMoreFriends ?? this.hasMoreFriends,
      friendRequests: friendRequests ?? this.friendRequests,
      friendRequestsPage: friendRequestsPage ?? this.friendRequestsPage,
      friendRequestsPageSize: friendRequestsPageSize ?? this.friendRequestsPageSize,
      hasMoreFriendRequests: hasMoreFriendRequests ?? this.hasMoreFriendRequests,
    );
  }
}

// Filter params classes
class FriendsFilterParams {
  final String? status;
  final int? page;
  final int? pageSize;

  const FriendsFilterParams({
    this.status,
    this.page,
    this.pageSize,
  });
}

class FriendRequestsFilterParams {
  final String? status;
  final int? page;
  final int? pageSize;

  const FriendRequestsFilterParams({
    this.status,
    this.page,
    this.pageSize,
  });
}
