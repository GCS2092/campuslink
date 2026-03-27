import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

// Provider for events list
final eventsProvider = FutureProvider.family<List<Event>, EventFilterParams>((ref, params) async {
  final service = ref.watch(eventServiceProvider);
  return service.getEvents(
    category: params.category,
    university: params.university,
    search: params.search,
    dateFrom: params.dateFrom,
    dateTo: params.dateTo,
    isFree: params.isFree,
    page: params.page,
    pageSize: params.pageSize,
  );
});

// Provider for a single event
final eventProvider = FutureProvider.family<Event, String>((ref, id) async {
  final service = ref.watch(eventServiceProvider);
  return service.getEvent(id);
});

// Provider for event categories
final eventCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final service = ref.watch(eventServiceProvider);
  return service.getCategories();
});

// Provider for user's event calendar
final eventCalendarProvider = FutureProvider.family<List<EventCalendar>, CalendarParams>((ref, params) async {
  final service = ref.watch(eventServiceProvider);
  return service.getCalendar(month: params.month, year: params.year);
});

// State notifier for events with pagination and filtering
class EventsNotifier extends Notifier<EventsState> {
  EventService get _service => ref.read(eventServiceProvider);

  @override
  EventsState build() => const EventsState();

  Future<void> loadEvents({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(page: 1, events: []);
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newEvents = await _service.getEvents(
        category: state.category,
        university: state.university,
        search: state.search,
        dateFrom: state.dateFrom,
        dateTo: state.dateTo,
        isFree: state.isFree,
        page: state.page,
        pageSize: state.pageSize,
      );

      final allEvents = refresh ? newEvents : [...state.events, ...newEvents];

      state = state.copyWith(
        events: allEvents,
        isLoading: false,
        hasMore: newEvents.length == state.pageSize,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setCategory(String? category) {
    state = state.copyWith(category: category, page: 1);
    loadEvents(refresh: true);
  }

  void setUniversity(String? university) {
    state = state.copyWith(university: university, page: 1);
    loadEvents(refresh: true);
  }

  void setSearch(String? search) {
    state = state.copyWith(search: search, page: 1);
    loadEvents(refresh: true);
  }

  void setDateRange(String? from, String? to) {
    state = state.copyWith(dateFrom: from, dateTo: to, page: 1);
    loadEvents(refresh: true);
  }

  void setIsFree(bool? isFree) {
    state = state.copyWith(isFree: isFree, page: 1);
    loadEvents(refresh: true);
  }

  Future<void> joinEvent(String eventId) async {
    try {
      await _service.joinEvent(eventId);
      // Update local state
      final updatedEvents = state.events.map((e) {
        if (e.id == eventId) {
          return e.copyWith(isJoined: true, participantsCount: e.participantsCount + 1);
        }
        return e;
      }).toList();
      state = state.copyWith(events: updatedEvents);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> leaveEvent(String eventId) async {
    try {
      await _service.leaveEvent(eventId);
      // Update local state
      final updatedEvents = state.events.map((e) {
        if (e.id == eventId) {
          return e.copyWith(isJoined: false, participantsCount: e.participantsCount - 1);
        }
        return e;
      }).toList();
      state = state.copyWith(events: updatedEvents);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> likeEvent(String eventId) async {
    try {
      await _service.likeEvent(eventId);
      // Update local state
      final updatedEvents = state.events.map((e) {
        if (e.id == eventId) {
          return e.copyWith(
            isLiked: !e.isLiked,
            likesCount: e.isLiked ? e.likesCount - 1 : e.likesCount + 1,
          );
        }
        return e;
      }).toList();
      state = state.copyWith(events: updatedEvents);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final eventsNotifierProvider = NotifierProvider<EventsNotifier, EventsState>(
  EventsNotifier.new,
);

// State class
class EventsState {
  final List<Event> events;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int page;
  final int pageSize;
  final String? category;
  final String? university;
  final String? search;
  final String? dateFrom;
  final String? dateTo;
  final bool? isFree;

  const EventsState({
    this.events = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.page = 1,
    this.pageSize = 20,
    this.category,
    this.university,
    this.search,
    this.dateFrom,
    this.dateTo,
    this.isFree,
  });

  EventsState copyWith({
    List<Event>? events,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? page,
    int? pageSize,
    String? category,
    String? university,
    String? search,
    String? dateFrom,
    String? dateTo,
    bool? isFree,
  }) {
    return EventsState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      category: category ?? this.category,
      university: university ?? this.university,
      search: search ?? this.search,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      isFree: isFree ?? this.isFree,
    );
  }
}

// Filter params classes
class EventFilterParams {
  final String? category;
  final String? university;
  final String? search;
  final String? dateFrom;
  final String? dateTo;
  final bool? isFree;
  final int? page;
  final int? pageSize;

  const EventFilterParams({
    this.category,
    this.university,
    this.search,
    this.dateFrom,
    this.dateTo,
    this.isFree,
    this.page,
    this.pageSize,
  });
}

class CalendarParams {
  final String? month;
  final String? year;

  const CalendarParams({this.month, this.year});
}
