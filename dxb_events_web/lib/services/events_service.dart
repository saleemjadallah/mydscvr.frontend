import 'package:dio/dio.dart';
import '../models/event.dart';
import '../models/api_response.dart';
import '../models/event_stats.dart';
import 'api/dio_config.dart';

/// Response model that includes both events and total count
class EventsWithTotal {
  final List<Event> events;
  final int total;
  
  const EventsWithTotal({
    required this.events,
    required this.total,
  });
}

/// Service for fetching events from the real backend API
class EventsService {
  late final Dio _dio;

  EventsService() {
    // Use environment-based URL configuration
    _dio = DioConfig.createDio(useLocalHost: false);
  }

  /// Search event titles for autocomplete suggestions
  Future<ApiResponse<List<String>>> searchEventTitles({
    required String query,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'query': query,
        'limit': limit,
      };

      final response = await _dio.get(
        '/events/search-titles/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> titlesJson = response.data;
        final titles = titlesJson.cast<String>();
        
        return ApiResponse<List<String>>.success(titles);
      } else {
        return ApiResponse<List<String>>.error(
          'Failed to search event titles: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return ApiResponse<List<String>>.error(
        'Network error searching event titles: ${e.message}',
      );
    } catch (e) {
      return ApiResponse<List<String>>.error(
        'Unexpected error searching event titles: $e',
      );
    }
  }

  /// Smart search for events using backend AI search
  Future<ApiResponse<EventsWithTotal>> smartSearch({
    required String query,
    String? area,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'page': page,
        'per_page': perPage,
        'sort_by': 'relevance',
      };

      if (area != null) {
        queryParams['area'] = area;
      }

      final response = await _dio.get(
        '/search/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final eventsJson = responseData['events'] as List<dynamic>;
        final total = responseData['pagination']['total'] as int;
        
        final events = eventsJson
            .map((eventJson) => Event.fromBackendApi(eventJson as Map<String, dynamic>))
            .toList();
        
        return ApiResponse<EventsWithTotal>.success(
          EventsWithTotal(events: events, total: total),
        );
      } else {
        return ApiResponse<EventsWithTotal>.error(
          'Failed to search events: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return ApiResponse<EventsWithTotal>.error(
        'Network error searching events: ${e.message}',
      );
    } catch (e) {
      return ApiResponse<EventsWithTotal>.error(
        'Unexpected error searching events: $e',
      );
    }
  }

  /// Search with specific intent (brunch, family fun, etc.)
  Future<ApiResponse<EventsWithTotal>> searchByIntent({
    required String intent,
    String? area,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'intent': intent,
        'page': page,
        'per_page': perPage,
      };

      if (area != null) {
        queryParams['area'] = area;
      }

      final response = await _dio.get(
        '/search/smart-search/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final eventsJson = responseData['events'] as List<dynamic>;
        final total = responseData['pagination']['total'] as int;
        
        final events = eventsJson
            .map((eventJson) => Event.fromBackendApi(eventJson as Map<String, dynamic>))
            .toList();
        
        return ApiResponse<EventsWithTotal>.success(
          EventsWithTotal(events: events, total: total),
        );
      } else {
        return ApiResponse<EventsWithTotal>.error(
          'Failed to search by intent: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return ApiResponse<EventsWithTotal>.error(
        'Network error searching by intent: ${e.message}',
      );
    } catch (e) {
      return ApiResponse<EventsWithTotal>.error(
        'Unexpected error searching by intent: $e',
      );
    }
  }

  /// Fetch events with optional filters - returns events and total count
  Future<ApiResponse<EventsWithTotal>> getEventsWithTotal({
    String? category,
    String? location,
    String? area,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? priceMax,
    double? priceMin,
    String? ageGroup,
    bool? familyFriendly,
    double? latitude,
    double? longitude,
    double? radiusKm,
    int page = 1,
    int perPage = 20,
    String sortBy = 'start_date',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        'sort_by': sortBy,
      };

      // Add optional filters
      if (category != null) queryParams['category'] = category;
      if (location != null) queryParams['location'] = location;
      if (area != null) queryParams['area'] = area;
      if (dateFrom != null) queryParams['date_from'] = dateFrom.toIso8601String();
      if (dateTo != null) queryParams['date_to'] = dateTo.toIso8601String();
      if (priceMax != null) queryParams['price_max'] = priceMax;
      if (priceMin != null) queryParams['price_min'] = priceMin;
      if (ageGroup != null) queryParams['age_group'] = ageGroup;
      if (familyFriendly != null) queryParams['family_friendly'] = familyFriendly;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (radiusKm != null) queryParams['radius_km'] = radiusKm;

      final response = await _dio.get(
        '/events/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('🔍 DEBUG EventsService: Raw API response received');
        print('🔍 DEBUG EventsService: Response keys: ${data.keys.toList()}');
        
        final eventsData = data['events'] as List<dynamic>;
        final total = data['pagination']?['total'] as int? ?? 0; // Extract total count from pagination
        print('🔍 DEBUG EventsService: Events data length: ${eventsData.length}');
        print('🔍 DEBUG EventsService: Total count from API: $total');
        
        if (eventsData.isNotEmpty) {
          print('🔍 DEBUG EventsService: First event raw data: ${eventsData.first}');
        }
        
        final events = <Event>[];
        for (int i = 0; i < eventsData.length; i++) {
          try {
            final eventJson = eventsData[i] as Map<String, dynamic>;
            print('🔍 DEBUG EventsService: Attempting to parse event $i: ${eventJson['title']}');
            final event = Event.fromBackendApi(eventJson);
            events.add(event);
            print('🔍 DEBUG EventsService: ✅ Successfully parsed event $i: ${event.title} - ${event.category}');
            if (i == 0) {
              print('🔍 DEBUG EventsService: First parsed event details: title=${event.title}, category=${event.category}, venue=${event.venue.name}, rating=${event.rating}');
            }
          } catch (e, stackTrace) {
            print('🔍 DEBUG EventsService: ❌ Error parsing event $i: $e');
            print('🔍 DEBUG EventsService: Stack trace: $stackTrace');
            print('🔍 DEBUG EventsService: Raw event data keys: ${(eventsData[i] as Map<String, dynamic>).keys.toList()}');
            print('🔍 DEBUG EventsService: Event title: ${eventsData[i]['title']}');
            // Don't include the full raw data to avoid cluttering logs, but show critical fields
            final eventData = eventsData[i] as Map<String, dynamic>;
            print('🔍 DEBUG EventsService: Critical fields - id: ${eventData['id']}, category: ${eventData['category']}, venue: ${eventData['venue']}, price: ${eventData['price']}');
          }
        }
        
        print('🔍 DEBUG EventsService: Successfully parsed ${events.length} events with total: $total');
        return ApiResponse.success(EventsWithTotal(events: events, total: total));
      } else {
        return ApiResponse.error('Failed to fetch events: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Fetch events with optional filters - backward compatibility method
  Future<ApiResponse<List<Event>>> getEvents({
    String? category,
    String? location,
    String? area,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? priceMax,
    double? priceMin,
    String? ageGroup,
    bool? familyFriendly,
    double? latitude,
    double? longitude,
    double? radiusKm,
    int page = 1,
    int perPage = 20,
    String sortBy = 'start_date',
  }) async {
    final response = await getEventsWithTotal(
      category: category,
      location: location,
      area: area,
      dateFrom: dateFrom,
      dateTo: dateTo,
      priceMax: priceMax,
      priceMin: priceMin,
      ageGroup: ageGroup,
      familyFriendly: familyFriendly,
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      page: page,
      perPage: perPage,
      sortBy: sortBy,
    );
    
    if (response.isSuccess) {
      return ApiResponse.success(response.data!.events);
    } else {
      return ApiResponse.error(response.error ?? 'Failed to fetch events');
    }
  }

  /// Fetch a single event by ID
  Future<ApiResponse<Event>> getEvent(String eventId) async {
    try {
      final response = await _dio.get('/events/$eventId');

      if (response.statusCode == 200) {
        final event = Event.fromBackendApi(response.data as Map<String, dynamic>);
        return ApiResponse.success(event);
      } else {
        return ApiResponse.error('Failed to fetch event: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Search events
  Future<ApiResponse<List<Event>>> searchEvents({
    required String query,
    String? filters,
  }) async {
    try {
      final response = await _dio.get(
        '/search/',
        queryParameters: {
          'q': query,
          if (filters != null) 'filters': filters,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final eventsData = data['results'] as List<dynamic>;
        
        final events = eventsData.map((eventJson) => 
          Event.fromBackendApi(eventJson as Map<String, dynamic>)
        ).toList();

        return ApiResponse.success(events);
      } else {
        return ApiResponse.error('Search failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Get trending events
  Future<ApiResponse<List<Event>>> getTrendingEvents({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/events/trending/list/',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final eventsData = data['events'] as List<dynamic>;
        
        final events = eventsData.map((eventJson) => 
          Event.fromBackendApi(eventJson as Map<String, dynamic>)
        ).toList();

        return ApiResponse.success(events);
      } else {
        return ApiResponse.error('Failed to fetch trending events: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Get family recommendations
  Future<ApiResponse<List<Event>>> getFamilyRecommendations({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/events/recommendations/family/',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final eventsData = data['events'] as List<dynamic>;
        
        final events = eventsData.map((eventJson) => 
          Event.fromBackendApi(eventJson as Map<String, dynamic>)
        ).toList();

        return ApiResponse.success(events);
      } else {
        return ApiResponse.error('Failed to fetch family recommendations: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Get events for featured selection (using main events endpoint)
  Future<ApiResponse<List<Event>>> getFeaturedEventsFromBackend({int limit = 12}) async {
    try {
      print('🎯 Featured Events Backend: Fetching events for scoring algorithm');
      
      // Fetch more events than needed so the scoring algorithm has a good pool to choose from
      final fetchLimit = limit * 4; // Get 4x more events for better selection
      
      final response = await getEventsWithTotal(
        page: 1,
        perPage: fetchLimit,
        sortBy: 'start_date',
      );

      if (response.isSuccess && response.data != null) {
        final events = response.data!.events;
        print('🎯 Featured Events Backend: Successfully fetched ${events.length} events for scoring');
        return ApiResponse.success(events);
      } else {
        return ApiResponse.error('Failed to fetch events for scoring: ${response.error}');
      }
    } catch (e) {
      print('🎯 Featured Events Backend Error: $e');
      return ApiResponse.error('Unexpected error fetching events for scoring: $e');
    }
  }

  /// Get event statistics for dashboard/quick stats
  Future<ApiResponse<EventStats>> getEventStats() async {
    try {
      final response = await _dio.get('/db/events-stats');

      if (response.statusCode == 200) {
        final stats = EventStats.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse.success(stats);
      } else {
        return ApiResponse.error('Failed to fetch event stats: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Get total events count for quick display
  Future<ApiResponse<int>> getTotalEventsCount() async {
    try {
      // Use the existing events endpoint with a small page size to get the total
      final response = await getEventsWithTotal(
        page: 1,
        perPage: 1, // Minimal page size since we only need the total
      );

      if (response.isSuccess) {
        return ApiResponse.success(response.data!.total);
      } else {
        return ApiResponse.error(response.error ?? 'Failed to get total events count');
      }
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      default:
        return e.message ?? 'An unexpected error occurred';
    }
  }
} 