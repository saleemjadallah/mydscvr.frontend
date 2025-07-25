import 'package:dio/dio.dart';
import '../models/event.dart';
import '../models/api_response.dart';
import '../models/event_stats.dart';
import '../models/ai_search_response.dart';
import 'api/dio_config.dart';
import '../core/utils/safe_event_parser.dart';

/// Response model that includes both events and total count
class EventsWithTotal {
  final List<Event> events;
  final int total;
  
  const EventsWithTotal({
    required this.events,
    required this.total,
  });
}

/// AI Search response with additional AI-generated content
class AISearchResult {
  final List<Event> events;
  final int total;
  final String aiResponse;
  final List<String> suggestions;
  final QueryAnalysis queryAnalysis;
  final int processingTimeMs;
  final bool aiEnabled;
  
  const AISearchResult({
    required this.events,
    required this.total,
    required this.aiResponse,
    required this.suggestions,
    required this.queryAnalysis,
    required this.processingTimeMs,
    required this.aiEnabled,
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
        '/events/search-titles',  // Fixed: Remove trailing slash to match backend
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

  /// Smart search for events using AI search (redirects to aiSearch)
  Future<ApiResponse<EventsWithTotal>> smartSearch({
    required String query,
    String? area,
    int page = 1,
    int perPage = 20,
  }) async {
    // Redirect to AI search since we're removing smart search
    final aiResult = await aiSearch(
      query: query,
      page: page,
      perPage: perPage,
    );
    
    if (aiResult.isSuccess) {
      return ApiResponse<EventsWithTotal>.success(
        EventsWithTotal(
          events: aiResult.data!.events,
          total: aiResult.data!.total,
        ),
      );
    } else {
      return ApiResponse<EventsWithTotal>.error(
        aiResult.error ?? 'AI search failed',
      );
    }
  }

  /// MyDscvr Super Search - Instant intelligent search powered by Algolia
  Future<ApiResponse<AISearchResult>> superSearch({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'page': page,
        'per_page': perPage,
      };

      final response = await _dio.get(
        '/algolia-search',  // MyDscvr Super Search endpoint
        queryParameters: queryParams,
        options: Options(
          receiveTimeout: const Duration(seconds: 10), // Fast timeout for Algolia
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Parse events from Algolia response
        final eventsData = responseData['events'] as List<dynamic>;
        final events = eventsData
            .map((eventJson) => SafeEventParser.parseEvent(eventJson))
            .where((event) => event != null)
            .cast<Event>()
            .toList();
        
        final pagination = responseData['pagination'] as Map<String, dynamic>;
        final suggestions = (responseData['suggestions'] as List<dynamic>?)?.cast<String>() ?? [];
        final metadata = responseData['search_metadata'] as Map<String, dynamic>;
        
        return ApiResponse<AISearchResult>.success(
          AISearchResult(
            events: events,
            total: pagination['total'] as int,
            aiResponse: 'Found ${pagination['total']} events using MyDscvr Super Search powered by Algolia in ${metadata['total_processing_time_ms']}ms',
            suggestions: suggestions,
            queryAnalysis: QueryAnalysis(
              intent: 'search',
              categories: [],
              locationPreferences: [],
              keywords: [query],
              confidence: 0.9,
            ),
            processingTimeMs: metadata['total_processing_time_ms'] as int? ?? 0,
            aiEnabled: true,
          ),
        );
      } else {
        return ApiResponse<AISearchResult>.error(
          'Failed to perform Super Search: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return ApiResponse<AISearchResult>.error(
        'Network error during Super Search: ${e.message}',
      );
    } catch (e) {
      return ApiResponse<AISearchResult>.error(
        'Unexpected error during Super Search: $e',
      );
    }
  }

  /// AI-powered search using OpenAI for intelligent event discovery
  /// Note: Redirects to superSearch for better performance
  Future<ApiResponse<AISearchResult>> aiSearch({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    // Redirect to Super Search for better performance
    return superSearch(
      query: query,
      page: page,
      perPage: perPage,
    );
  }

  /// Search with specific intent (brunch, family fun, etc.) using AI search
  Future<ApiResponse<EventsWithTotal>> searchByIntent({
    required String intent,
    String? area,
    int page = 1,
    int perPage = 20,
  }) async {
    // Use AI search with intent as query
    String query = intent;
    if (area != null) {
      query += ' in $area';
    }
    
    final aiResult = await aiSearch(
      query: query,
      page: page,
      perPage: perPage,
    );
    
    if (aiResult.isSuccess) {
      return ApiResponse<EventsWithTotal>.success(
        EventsWithTotal(
          events: aiResult.data!.events,
          total: aiResult.data!.total,
        ),
      );
    } else {
      return ApiResponse<EventsWithTotal>.error(
        aiResult.error ?? 'AI search failed',
      );
    }
  }

  /// Fetch events with optional filters - returns events and total count
  Future<ApiResponse<EventsWithTotal>> getEventsWithTotal({
    String? category,
    String? location,
    String? area,
    String? dateFilter,
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
      if (dateFilter != null) queryParams['date_filter'] = dateFilter;
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
        '/events/',  // Backend requires trailing slash for main events endpoint
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final eventsData = data['events'] as List<dynamic>;
        final total = data['pagination']?['total'] as int? ?? 0; // Extract total count from pagination
        
        final events = <Event>[];
        for (int i = 0; i < eventsData.length; i++) {
          try {
            final eventJson = eventsData[i] as Map<String, dynamic>;
            final event = SafeEventParser.parseEvent(eventJson);
            if (event != null) {
              events.add(event);
            }
          } catch (e) {
            // Log parsing errors for production debugging
            print('Error parsing event: $e');
          }
        }
        
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
    String? dateFilter,
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
      dateFilter: dateFilter,
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
        final event = SafeEventParser.parseEvent(response.data);
        if (event != null) {
          return ApiResponse.success(event);
        } else {
          return ApiResponse.error('Failed to parse event data');
        }
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
        '/search/',  // Backend requires trailing slash for search endpoint
        queryParameters: {
          'q': query,
          if (filters != null) 'filters': filters,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final eventsData = data['results'] as List<dynamic>;
        
        final events = eventsData
            .map((eventJson) => SafeEventParser.parseEvent(eventJson))
            .where((event) => event != null)
            .cast<Event>()
            .toList();

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
  Future<ApiResponse<List<Event>>> getTrendingEvents({
    int limit = 10,
    String? extractionMethod,
    bool firecrawlOnly = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit};
      
      if (firecrawlOnly) {
        queryParams['firecrawl_only'] = true;
      } else if (extractionMethod != null) {
        queryParams['extraction_method'] = extractionMethod;
      }
      
      final response = await _dio.get(
        '/events/trending/list',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final eventsData = data['events'] as List<dynamic>;
        
        final events = eventsData
            .map((eventJson) => SafeEventParser.parseEvent(eventJson))
            .where((event) => event != null)
            .cast<Event>()
            .toList();

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

  /// Get firecrawl-extracted events (high-quality verified events)
  Future<ApiResponse<List<Event>>> getFirecrawlEvents({
    int limit = 20,
    String? area,
    String sortBy = 'start_date',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'sort_by': sortBy,
        '_': DateTime.now().millisecondsSinceEpoch.toString(),
      };
      
      if (area != null) {
        queryParams['area'] = area;
      }
      
      final response = await _dio.get(
        '/events/firecrawl/list',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final eventsData = data['events'] as List<dynamic>;
        
        final events = eventsData
            .map((eventJson) => SafeEventParser.parseEvent(eventJson))
            .where((event) => event != null)
            .cast<Event>()
            .toList();

        return ApiResponse.success(events);
      } else {
        return ApiResponse.error('Failed to fetch firecrawl events: ${response.statusMessage}');
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
        '/events/recommendations/family',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final eventsData = data['events'] as List<dynamic>;
        
        final events = eventsData
            .map((eventJson) => SafeEventParser.parseEvent(eventJson))
            .where((event) => event != null)
            .cast<Event>()
            .toList();

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
  Future<ApiResponse<List<Event>>> getFeaturedEventsFromBackend({
    int limit = 12,
    bool aiImagesOnly = false,
  }) async {
    try {
      
      // Call the backend featured events endpoint directly
      final response = await _dio.get(
        '/events/featured/list',
        queryParameters: {
          'limit': limit,
          'ai_images_only': aiImagesOnly,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final eventsData = responseData['events'] as List<dynamic>;
        
        final events = eventsData
            .map((eventJson) => SafeEventParser.parseEvent(eventJson))
            .where((event) => event != null)
            .cast<Event>()
            .toList();
        
        return ApiResponse.success(events);
      } else {
        return ApiResponse.error('Backend returned status ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Unexpected error fetching featured events: $e');
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