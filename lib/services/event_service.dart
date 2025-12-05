import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// Service pour gérer les événements
class EventService {
  final ApiService _apiService = ApiService();

  /// Récupère la liste des événements avec filtres optionnels
  Future<Map<String, dynamic>> getEvents({
    String? category,
    String? status,
    String? university,
    String? dateFrom,
    String? dateTo,
    String? search,
    String? ordering,
    int? page,
    int? pageSize,
    bool? isFree,
    double? priceMin,
    double? priceMax,
    double? lat,
    double? lng,
    double? radius,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (category != null) params['category'] = category;
      if (status != null) params['status'] = status;
      if (university != null) params['university'] = university;
      if (dateFrom != null) params['date_from'] = dateFrom;
      if (dateTo != null) params['date_to'] = dateTo;
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (ordering != null) params['ordering'] = ordering;
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;
      if (isFree != null) params['is_free'] = isFree;
      if (priceMin != null) params['price_min'] = priceMin;
      if (priceMax != null) params['price_max'] = priceMax;
      if (lat != null) params['lat'] = lat;
      if (lng != null) params['lng'] = lng;
      if (radius != null) params['radius'] = radius;

      final response = await _apiService.get(
        AppConstants.eventsEndpoint,
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return {
            'results': data.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList(),
            'count': data.length,
          };
        } else if (data is Map<String, dynamic>) {
          if (data['results'] != null) {
            return {
              'results': (data['results'] as List)
                  .map((e) => Event.fromJson(e as Map<String, dynamic>))
                  .toList(),
              'count': data['count'] ?? 0,
              'next': data['next'],
              'previous': data['previous'],
            };
          }
          return Map<String, dynamic>.from(data);
        }
        return {'results': <Event>[], 'count': 0};
      }
      return {'results': <Event>[], 'count': 0};
    } catch (e) {
      debugPrint('Error getting events: $e');
      return {'results': [], 'count': 0, 'error': e.toString()};
    }
  }

  /// Récupère un événement par son ID
  Future<Event?> getEvent(String id) async {
    try {
      final response = await _apiService.get('${AppConstants.eventsEndpoint}$id/');
      if (response.statusCode == 200) {
        return Event.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting event $id: $e');
      return null;
    }
  }

  /// Récupère les catégories d'événements
  Future<List<EventCategory>> getCategories() async {
    try {
      final response = await _apiService.get('${AppConstants.eventsEndpoint}categories/');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((c) => EventCategory.fromJson(c as Map<String, dynamic>)).toList();
        }
      }
      return <EventCategory>[];
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  /// Crée un nouvel événement
  Future<Event?> createEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await _apiService.post(
        AppConstants.eventsEndpoint,
        data: eventData,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Event.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating event: $e');
      return null;
    }
  }

  /// Participe à un événement
  Future<Map<String, dynamic>> joinEvent(String eventId) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.eventsEndpoint}$eventId/participate/',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur inconnue'};
    } catch (e) {
      debugPrint('Error joining event: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Quitte un événement
  Future<Map<String, dynamic>> leaveEvent(String eventId) async {
    try {
      final response = await _apiService.delete(
        '${AppConstants.eventsEndpoint}$eventId/leave/',
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Erreur lors de la sortie'};
    } catch (e) {
      debugPrint('Error leaving event: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Récupère les événements de l'utilisateur
  Future<List<Event>> getMyEvents({String? type}) async {
    try {
      final params = type != null && type != 'all' ? {'type': type} : null;
      final response = await _apiService.get(
        '${AppConstants.eventsEndpoint}my_events/',
        queryParameters: params,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic> && data['results'] != null) {
          return (data['results'] as List).map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return <Event>[];
    } catch (e) {
      debugPrint('Error getting my events: $e');
      return [];
    }
  }

  /// Récupère les participations de l'utilisateur
  Future<Map<String, dynamic>> getParticipations() async {
    try {
      final response = await _apiService.get('${AppConstants.eventsEndpoint}participations/');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return {
            'results': data.map((e) => Event.fromJson(e['event'] as Map<String, dynamic>)).toList(),
            'count': data.length,
          };
        } else if (data is Map<String, dynamic>) {
          if (data['results'] != null) {
            return {
              'results': (data['results'] as List).map((e) {
                final eventData = e is Map ? (e['event'] ?? e) : e;
                return Event.fromJson(eventData as Map<String, dynamic>);
              }).toList(),
              'count': data['count'] ?? 0,
            };
          }
        }
      }
      return {'results': <Event>[], 'count': 0};
    } catch (e) {
      debugPrint('Error getting participations: $e');
      return {'results': <Event>[], 'count': 0};
    }
  }

  /// Récupère les événements favoris
  Future<List<Event>> getFavorites() async {
    try {
      final response = await _apiService.get('${AppConstants.eventsEndpoint}favorites/');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic> && data['results'] != null) {
          return (data['results'] as List).map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return <Event>[];
    } catch (e) {
      debugPrint('Error getting favorites: $e');
      return [];
    }
  }

  /// Récupère les événements recommandés
  Future<List<Event>> getRecommendedEvents({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.eventsEndpoint}recommended/',
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic> && data['results'] != null) {
          return (data['results'] as List).map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return <Event>[];
    } catch (e) {
      debugPrint('Error getting recommended events: $e');
      return [];
    }
  }

  /// Récupère les événements pour le calendrier
  Future<List<Event>> getCalendarEvents({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (startDate != null) params['start_date'] = startDate;
      if (endDate != null) params['end_date'] = endDate;

      final response = await _apiService.get(
        '${AppConstants.eventsEndpoint}calendar/events/',
        queryParameters: params.isEmpty ? null : params,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic> && data['results'] != null) {
          return (data['results'] as List).map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return <Event>[];
    } catch (e) {
      debugPrint('Error getting calendar events: $e');
      return [];
    }
  }

  /// Modère un événement (approve/reject) - Admin ou Class Leader uniquement
  Future<Map<String, dynamic>> moderateEvent(String eventId, String action) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.eventsEndpoint}$eventId/moderate/',
        data: {'action': action},
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error moderating event: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}

