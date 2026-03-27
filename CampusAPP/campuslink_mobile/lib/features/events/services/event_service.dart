import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/event_model.dart';

final eventServiceProvider = Provider<EventService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return EventService(dio);
});

class EventService {
  final DioClient _dio;

  EventService(this._dio);

  Future<List<Event>> getEvents({
    String? category,
    String? university,
    String? search,
    String? dateFrom,
    String? dateTo,
    bool? isFree,
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String, dynamic>{};
    if (category != null) queryParams['category'] = category;
    if (university != null) queryParams['university'] = university;
    if (search != null) queryParams['search'] = search;
    if (dateFrom != null) queryParams['date_from'] = dateFrom;
    if (dateTo != null) queryParams['date_to'] = dateTo;
    if (isFree != null) queryParams['is_free'] = isFree.toString();
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();

    final response = await _dio.get(ApiConstants.events, queryParameters: queryParams);
    final results = response.data['results'] as List;
    return results.map((e) => Event.fromJson(e)).toList();
  }

  Future<Event> getEvent(String id) async {
    final response = await _dio.get(ApiConstants.eventDetail(id));
    return Event.fromJson(response.data);
  }

  Future<Event> createEvent(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.events, data: data);
    return Event.fromJson(response.data);
  }

  Future<Event> updateEvent(String id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConstants.eventDetail(id), data: data);
    return Event.fromJson(response.data);
  }

  Future<void> deleteEvent(String id) async {
    await _dio.delete(ApiConstants.eventDetail(id));
  }

  Future<void> joinEvent(String id) async {
    await _dio.post(ApiConstants.eventJoin(id));
  }

  Future<void> leaveEvent(String id) async {
    await _dio.post(ApiConstants.eventLeave(id));
  }

  Future<void> likeEvent(String id) async {
    await _dio.post(ApiConstants.eventLike(id));
  }

  Future<List<EventParticipant>> getEventParticipants(String id) async {
    final response = await _dio.get(ApiConstants.eventParticipants(id));
    final results = response.data['results'] as List;
    return results.map((e) => EventParticipant.fromJson(e)).toList();
  }

  Future<List<Category>> getCategories() async {
    final response = await _dio.get(ApiConstants.eventCategories);
    final results = response.data as List;
    return results.map((e) => Category.fromJson(e)).toList();
  }

  Future<List<EventCalendar>> getCalendar({String? month, String? year}) async {
    final queryParams = <String, dynamic>{};
    if (month != null) queryParams['month'] = month;
    if (year != null) queryParams['year'] = year;

    final response = await _dio.get(ApiConstants.eventCalendar, queryParameters: queryParams);
    final results = response.data as List;
    return results.map((e) => EventCalendar.fromJson(e)).toList();
  }

  Future<EventFilterPreference> getFilterPreferences() async {
    final response = await _dio.get(ApiConstants.eventFilterPreferences);
    return EventFilterPreference.fromJson(response.data);
  }

  Future<EventFilterPreference> updateFilterPreferences(EventFilterPreference preferences) async {
    final response = await _dio.put(
      ApiConstants.eventFilterPreferences,
      data: preferences.toJson(),
    );
    return EventFilterPreference.fromJson(response.data);
  }
}
