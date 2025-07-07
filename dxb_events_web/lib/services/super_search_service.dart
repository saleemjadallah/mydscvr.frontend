import 'package:dio/dio.dart';
import '../models/event.dart';
import '../models/api_response.dart';
import 'api/dio_config.dart';
import '../core/utils/safe_event_parser.dart';
import 'dart:math';

/// Super Search filters model
class SuperSearchFilters {
  final String? category;
  final String? area;
  final double? priceMin;
  final double? priceMax;
  final bool? familyFriendly;
  final bool? isWeekend;
  final bool? isFree;
  final bool? includePastEvents;

  const SuperSearchFilters({
    this.category,
    this.area,
    this.priceMin,
    this.priceMax,
    this.familyFriendly,
    this.isWeekend,
    this.isFree,
    this.includePastEvents,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = category;
    if (area != null) params['area'] = area;
    if (priceMin != null) params['price_min'] = priceMin;
    if (priceMax != null) params['price_max'] = priceMax;
    if (familyFriendly != null) params['family_friendly'] = familyFriendly;
    if (isWeekend != null) params['is_weekend'] = isWeekend;
    if (isFree != null) params['is_free'] = isFree;
    if (includePastEvents != null) params['include_past_events'] = includePastEvents;
    return params;
  }
}

/// Super Search Result with enhanced metadata and event tracking
class SuperSearchResult {
  final List<Event> events;
  final int total;
  final int page;
  final int perPage;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;
  final List<String> suggestions;
  final SuperSearchMetadata metadata;
  final String? aiResponse;
  final EventTrackingInfo? trackingInfo;

  const SuperSearchResult({
    required this.events,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
    required this.suggestions,
    required this.metadata,
    this.aiResponse,
    this.trackingInfo,
  });

  factory SuperSearchResult.fromJson(Map<String, dynamic> json) {
    final eventsData = json['events'] as List<dynamic>;
    
    print('🔍 SuperSearchResult: Received ${eventsData.length} raw events');
    
    final events = eventsData
        .map((eventJson) {
          try {
            print('🔍 SuperSearchResult: Attempting to parse event: ${eventJson['title'] ?? 'Unknown'}');
            final parsedEvent = Event.fromBackendApi(eventJson as Map<String, dynamic>);
            print('✅ SuperSearchResult: Successfully parsed event: ${parsedEvent.title}');
            return parsedEvent;
          } catch (e) {
            print('🚨 SuperSearchResult: Failed to parse event: ${eventJson['title'] ?? 'Unknown'} - Error: $e');
            return null;
          }
        })
        .where((event) => event != null)
        .cast<Event>()
        .toList();

    print('🎯 SuperSearchResult: Final parsed events count: ${events.length}');

    final pagination = json['pagination'] as Map<String, dynamic>;
    final suggestions = (json['suggestions'] as List<dynamic>?)?.cast<String>() ?? [];
    final aiResponse = json['ai_response'] as String?;
    
    // Handle both AI search and Algolia search metadata formats
    final metadataJson = json['search_metadata'] as Map<String, dynamic>? ?? {
      'query': '',
      'enhanced_query': '',
      'filters_applied': 0,
      'total_processing_time_ms': json['processing_time_ms'] ?? 0,
      'algolia_time_ms': 0,
      'service': 'ai-search',
    };
    final metadata = SuperSearchMetadata.fromJson(metadataJson);

    // Parse event tracking info
    EventTrackingInfo? trackingInfo;
    final trackingData = metadataJson['event_tracking'] as Map<String, dynamic>?;
    if (trackingData != null) {
      trackingInfo = EventTrackingInfo.fromJson(trackingData);
    }

    return SuperSearchResult(
      events: events,
      total: pagination['total'] as int,
      page: pagination['page'] as int,
      perPage: pagination['per_page'] as int,
      totalPages: pagination['total_pages'] as int,
      hasNext: pagination['has_next'] as bool,
      hasPrev: pagination['has_prev'] as bool,
      suggestions: suggestions,
      metadata: metadata,
      aiResponse: aiResponse,
      trackingInfo: trackingInfo,
    );
  }
}

/// Event tracking information from search response
class EventTrackingInfo {
  final String? queryId;
  final String? userToken;
  final bool searchTracked;
  final bool viewTracked;

  const EventTrackingInfo({
    this.queryId,
    this.userToken,
    required this.searchTracked,
    required this.viewTracked,
  });

  factory EventTrackingInfo.fromJson(Map<String, dynamic> json) {
    return EventTrackingInfo(
      queryId: json['query_id'] as String?,
      userToken: json['user_token'] as String?,
      searchTracked: json['search_tracked'] as bool? ?? false,
      viewTracked: json['view_tracked'] as bool? ?? false,
    );
  }
}

/// Super Search metadata with performance and query info
class SuperSearchMetadata {
  final String query;
  final String enhancedQuery;
  final int filtersApplied;
  final int totalProcessingTimeMs;
  final int algoliaTimeMs;
  final String service;

  const SuperSearchMetadata({
    required this.query,
    required this.enhancedQuery,
    required this.filtersApplied,
    required this.totalProcessingTimeMs,
    required this.algoliaTimeMs,
    required this.service,
  });

  factory SuperSearchMetadata.fromJson(Map<String, dynamic> json) {
    return SuperSearchMetadata(
      query: json['query'] as String? ?? '',
      enhancedQuery: json['enhanced_query'] as String? ?? '',
      filtersApplied: json['filters_applied'] as int? ?? 0,
      totalProcessingTimeMs: json['total_processing_time_ms'] as int? ?? 0,
      algoliaTimeMs: json['algolia_time_ms'] as int? ?? 0,
      service: json['service'] as String? ?? 'algolia',
    );
  }
}

/// Available filters for Super Search
class SuperSearchAvailableFilters {
  final List<String> categories;
  final List<String> areas;
  final List<PriceRange> priceRanges;
  final List<String> ageGroups;

  const SuperSearchAvailableFilters({
    required this.categories,
    required this.areas,
    required this.priceRanges,
    required this.ageGroups,
  });

  factory SuperSearchAvailableFilters.fromJson(Map<String, dynamic> json) {
    final priceRanges = (json['price_ranges'] as List<dynamic>)
        .map((range) => PriceRange.fromJson(range as Map<String, dynamic>))
        .toList();

    return SuperSearchAvailableFilters(
      categories: (json['categories'] as List<dynamic>).cast<String>(),
      areas: (json['areas'] as List<dynamic>).cast<String>(),
      priceRanges: priceRanges,
      ageGroups: (json['age_groups'] as List<dynamic>).cast<String>(),
    );
  }
}

/// Price range for filtering
class PriceRange {
  final double? min;
  final double? max;
  final String label;

  const PriceRange({
    this.min,
    this.max,
    required this.label,
  });

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      min: json['min']?.toDouble(),
      max: json['max']?.toDouble(),
      label: json['label'] as String,
    );
  }
}

/// Service status for Super Search
class SuperSearchStatus {
  final String service;
  final bool enabled;
  final String appId;
  final String indexName;
  final String status;
  final List<String> features;
  final String expectedResponseTime;
  final EventTrackingStatus eventTracking;
  final List<String> aiFeatures;

  const SuperSearchStatus({
    required this.service,
    required this.enabled,
    required this.appId,
    required this.indexName,
    required this.status,
    required this.features,
    required this.expectedResponseTime,
    required this.eventTracking,
    required this.aiFeatures,
  });

  factory SuperSearchStatus.fromJson(Map<String, dynamic> json) {
    final eventTrackingData = json['event_tracking'] as Map<String, dynamic>? ?? {};
    final eventTracking = EventTrackingStatus.fromJson(eventTrackingData);

    return SuperSearchStatus(
      service: json['service'] as String,
      enabled: json['enabled'] as bool,
      appId: json['app_id'] as String,
      indexName: json['index_name'] as String,
      status: json['status'] as String,
      features: (json['features'] as List<dynamic>).cast<String>(),
      expectedResponseTime: json['expected_response_time'] as String,
      eventTracking: eventTracking,
      aiFeatures: (json['ai_features_unlocked'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

/// Event tracking status
class EventTrackingStatus {
  final bool insightsApiEnabled;
  final bool clickTracking;
  final bool conversionTracking;
  final bool viewTracking;
  final bool personalization;

  const EventTrackingStatus({
    required this.insightsApiEnabled,
    required this.clickTracking,
    required this.conversionTracking,
    required this.viewTracking,
    required this.personalization,
  });

  factory EventTrackingStatus.fromJson(Map<String, dynamic> json) {
    return EventTrackingStatus(
      insightsApiEnabled: json['insights_api_enabled'] as bool? ?? false,
      clickTracking: json['click_tracking'] as bool? ?? false,
      conversionTracking: json['conversion_tracking'] as bool? ?? false,
      viewTracking: json['view_tracking'] as bool? ?? false,
      personalization: json['personalization'] as bool? ?? false,
    );
  }
}

/// Event tracking request models
class ClickTrackingRequest {
  final String query;
  final String objectId;
  final int position;
  final String? queryId;
  final String? userToken;

  const ClickTrackingRequest({
    required this.query,
    required this.objectId,
    required this.position,
    this.queryId,
    this.userToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'object_id': objectId,
      'position': position,
      if (queryId != null) 'query_id': queryId,
      if (userToken != null) 'user_token': userToken,
    };
  }
}

class ConversionTrackingRequest {
  final String objectId;
  final String eventName;
  final String? queryId;
  final String? userToken;

  const ConversionTrackingRequest({
    required this.objectId,
    required this.eventName,
    this.queryId,
    this.userToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'object_id': objectId,
      'event_name': eventName,
      if (queryId != null) 'query_id': queryId,
      if (userToken != null) 'user_token': userToken,
    };
  }
}

class ViewTrackingRequest {
  final List<String> objectIds;
  final String eventName;
  final String? userToken;

  const ViewTrackingRequest({
    required this.objectIds,
    required this.eventName,
    this.userToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'object_ids': objectIds,
      'event_name': eventName,
      if (userToken != null) 'user_token': userToken,
    };
  }
}

/// MyDscvr Super Search Service - Powered by Algolia with AI Event Tracking
/// 
/// Provides instant, intelligent search with typo tolerance,
/// advanced filtering, sub-100ms response times, and comprehensive
/// event tracking for AI optimization including NeuralSearch,
/// Dynamic Re-Ranking, and Personalization.
class SuperSearchService {
  late final Dio _dio;
  String? _currentUserToken;
  EventTrackingInfo? _lastSearchTracking;

  SuperSearchService() {
    _dio = DioConfig.createDio(useLocalHost: false);
    _generateUserToken();
  }

  /// Generate a user token for event tracking
  void _generateUserToken() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _currentUserToken = 'anonymous-${timestamp.toString()}-${random.nextInt(1000)}';
  }

  /// Get current user token
  String get userToken => _currentUserToken ?? 'anonymous';

  /// Set authenticated user token for personalization
  Future<ApiResponse<bool>> setAuthenticatedUserToken(String userId, {String? customToken}) async {
    try {
      final response = await _dio.post(
        '/algolia-search/user/token',
        data: {
          'user_id': userId,
          if (customToken != null) 'authenticated_token': customToken,
        },
      );

      if (response.statusCode == 200) {
        _currentUserToken = response.data['user_token'] as String;
        return ApiResponse.success(response.data['success'] as bool);
      } else {
        return ApiResponse.error('Failed to set user token: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return ApiResponse.error('Network error setting user token: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error setting user token: $e');
    }
  }

  /// Generate a new user token
  Future<ApiResponse<String>> generateUserToken({String? userId}) async {
    try {
      final response = await _dio.get(
        '/algolia-search/user/token/generate',
        queryParameters: userId != null ? {'user_id': userId} : null,
      );

      if (response.statusCode == 200) {
        final token = response.data['user_token'] as String;
        _currentUserToken = token;
        return ApiResponse.success(token);
      } else {
        return ApiResponse.error('Failed to generate token: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return ApiResponse.error('Network error generating token: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error generating token: $e');
    }
  }

  /// Perform MyDscvr Super Search with intelligent query enhancement and event tracking
  Future<ApiResponse<SuperSearchResult>> search({
    required String query,
    SuperSearchFilters? filters,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'page': page,
        'per_page': perPage,
        'user_token': userToken,  // Include user token for tracking
      };

      // Add filter parameters
      if (filters != null) {
        queryParams.addAll(filters.toQueryParams());
      }

      final response = await _dio.get(
        '/algolia-search',
        queryParameters: queryParams,
        options: Options(
          receiveTimeout: const Duration(seconds: 10), // Fast Algolia AI search
          sendTimeout: const Duration(seconds: 5),
          headers: {
            'X-User-Token': userToken,  // Also send in headers
          },
        ),
      );

      if (response.statusCode == 200) {
        final result = SuperSearchResult.fromJson(response.data);
        
        // Store tracking info for future click events
        _lastSearchTracking = result.trackingInfo;
        
        print('🎯 Search completed with tracking: queryId=${result.trackingInfo?.queryId}, userToken=${result.trackingInfo?.userToken}');
        
        return ApiResponse.success(result);
      } else {
        return ApiResponse.error(
          'Super Search failed: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error(
        'Network error during Super Search: ${e.message}',
      );
    } catch (e) {
      return ApiResponse.error(
        'Unexpected error during Super Search: $e',
      );
    }
  }

  /// Track click event when user clicks on a search result
  Future<ApiResponse<bool>> trackClickEvent({
    required String query,
    required String eventId,
    required int position,
    String? queryId,
    String? userToken,
  }) async {
    try {
      // Use stored tracking info if available
      final effectiveQueryId = queryId ?? _lastSearchTracking?.queryId;
      final effectiveUserToken = userToken ?? _lastSearchTracking?.userToken ?? this.userToken;

      final request = ClickTrackingRequest(
        query: query,
        objectId: eventId,
        position: position,
        queryId: effectiveQueryId,
        userToken: effectiveUserToken,
      );

      final response = await _dio.post(
        '/algolia-search/track/click',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final tracked = response.data['tracked'] as bool;
        
        if (tracked) {
          print('✅ Click event tracked: event=$eventId, position=$position, query="$query"');
        } else {
          print('⚠️ Click event tracking failed: ${response.data['message']}');
        }
        
        return ApiResponse.success(tracked);
      } else {
        return ApiResponse.error('Failed to track click: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return ApiResponse.error('Network error tracking click: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error tracking click: $e');
    }
  }

  /// Track conversion event when user performs a meaningful action
  Future<ApiResponse<bool>> trackConversionEvent({
    required String eventId,
    required String eventName,
    String? queryId,
    String? userToken,
  }) async {
    try {
      // Use stored tracking info if available
      final effectiveQueryId = queryId ?? _lastSearchTracking?.queryId;
      final effectiveUserToken = userToken ?? _lastSearchTracking?.userToken ?? this.userToken;

      final request = ConversionTrackingRequest(
        objectId: eventId,
        eventName: eventName,
        queryId: effectiveQueryId,
        userToken: effectiveUserToken,
      );

      final response = await _dio.post(
        '/algolia-search/track/conversion',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final tracked = response.data['tracked'] as bool;
        
        if (tracked) {
          print('✅ Conversion event tracked: event=$eventId, action="$eventName"');
        } else {
          print('⚠️ Conversion event tracking failed: ${response.data['message']}');
        }
        
        return ApiResponse.success(tracked);
      } else {
        return ApiResponse.error('Failed to track conversion: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return ApiResponse.error('Network error tracking conversion: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error tracking conversion: $e');
    }
  }

  /// Track view event when user views content
  Future<ApiResponse<bool>> trackViewEvent({
    required List<String> eventIds,
    required String eventName,
    String? userToken,
  }) async {
    try {
      final effectiveUserToken = userToken ?? this.userToken;

      final request = ViewTrackingRequest(
        objectIds: eventIds,
        eventName: eventName,
        userToken: effectiveUserToken,
      );

      final response = await _dio.post(
        '/algolia-search/track/view',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final tracked = response.data['tracked'] as bool;
        
        if (tracked) {
          print('✅ View event tracked: events=${eventIds.length}, action="$eventName"');
        } else {
          print('⚠️ View event tracking failed: ${response.data['message']}');
        }
        
        return ApiResponse.success(tracked);
      } else {
        return ApiResponse.error('Failed to track view: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return ApiResponse.error('Network error tracking view: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error tracking view: $e');
    }
  }

  /// Track when user views event details (conversion event)
  Future<ApiResponse<bool>> trackEventDetailsViewed(String eventId) async {
    return trackConversionEvent(
      eventId: eventId,
      eventName: 'Event Details Viewed',
    );
  }

  /// Track when user bookmarks/saves an event (conversion event)
  Future<ApiResponse<bool>> trackEventBookmarked(String eventId) async {
    return trackConversionEvent(
      eventId: eventId,
      eventName: 'Event Bookmarked',
    );
  }

  /// Track when user shares an event (conversion event)
  Future<ApiResponse<bool>> trackEventShared(String eventId) async {
    return trackConversionEvent(
      eventId: eventId,
      eventName: 'Event Shared',
    );
  }

  /// Track when user views search results (view event)
  Future<ApiResponse<bool>> trackSearchResultsViewed(List<String> eventIds) async {
    return trackViewEvent(
      eventIds: eventIds,
      eventName: 'Search Results Viewed',
    );
  }

  /// Get search suggestions based on partial query
  Future<ApiResponse<List<String>>> getSuggestions({
    required String query,
    int limit = 5,
  }) async {
    try {
      final response = await _dio.get(
        '/algolia-search/suggest',
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final suggestions = (response.data['suggestions'] as List<dynamic>)
            .cast<String>();
        return ApiResponse.success(suggestions);
      } else {
        return ApiResponse.error(
          'Failed to get suggestions: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error(
        'Network error getting suggestions: ${e.message}',
      );
    } catch (e) {
      return ApiResponse.error(
        'Unexpected error getting suggestions: $e',
      );
    }
  }

  /// Get available filters for the search interface
  Future<ApiResponse<SuperSearchAvailableFilters>> getAvailableFilters() async {
    try {
      final response = await _dio.get('/algolia-search/facets');

      if (response.statusCode == 200) {
        final filters = SuperSearchAvailableFilters.fromJson(response.data);
        return ApiResponse.success(filters);
      } else {
        return ApiResponse.error(
          'Failed to get filters: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error(
        'Network error getting filters: ${e.message}',
      );
    } catch (e) {
      return ApiResponse.error(
        'Unexpected error getting filters: $e',
      );
    }
  }

  /// Get Super Search service status with event tracking info
  Future<ApiResponse<SuperSearchStatus>> getStatus() async {
    try {
      final response = await _dio.get('/algolia-search/status');

      if (response.statusCode == 200) {
        final status = SuperSearchStatus.fromJson(response.data);
        return ApiResponse.success(status);
      } else {
        return ApiResponse.error(
          'Failed to get status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error(
        'Network error getting status: ${e.message}',
      );
    } catch (e) {
      return ApiResponse.error(
        'Unexpected error getting status: $e',
      );
    }
  }

  /// Search with specific intents (quick search presets)
  Future<ApiResponse<SuperSearchResult>> searchByIntent({
    required String intent,
    String? area,
    int page = 1,
    int perPage = 20,
  }) async {
    String query = intent;
    if (area != null && area.isNotEmpty) {
      query += ' in $area';
    }

    return search(
      query: query,
      page: page,
      perPage: perPage,
    );
  }

  /// Search for family-friendly events
  Future<ApiResponse<SuperSearchResult>> searchFamilyFriendly({
    required String query,
    String? area,
    int page = 1,
    int perPage = 20,
  }) async {
    return search(
      query: query,
      filters: SuperSearchFilters(
        familyFriendly: true,
        area: area,
      ),
      page: page,
      perPage: perPage,
    );
  }

  /// Search for free events
  Future<ApiResponse<SuperSearchResult>> searchFreeEvents({
    required String query,
    String? area,
    int page = 1,
    int perPage = 20,
  }) async {
    return search(
      query: query,
      filters: SuperSearchFilters(
        isFree: true,
        area: area,
      ),
      page: page,
      perPage: perPage,
    );
  }

  /// Search for weekend events
  Future<ApiResponse<SuperSearchResult>> searchWeekendEvents({
    required String query,
    String? area,
    int page = 1,
    int perPage = 20,
  }) async {
    return search(
      query: query,
      filters: SuperSearchFilters(
        isWeekend: true,
        area: area,
      ),
      page: page,
      perPage: perPage,
    );
  }

  /// Search for historical/past events
  Future<ApiResponse<SuperSearchResult>> searchHistoricalEvents({
    required String query,
    String? area,
    String? category,
    int page = 1,
    int perPage = 20,
  }) async {
    return search(
      query: query,
      filters: SuperSearchFilters(
        area: area,
        category: category,
        includePastEvents: true, // Include past events
      ),
      page: page,
      perPage: perPage,
    );
  }

  /// Search with explicit date filtering control
  Future<ApiResponse<SuperSearchResult>> searchWithDateControl({
    required String query,
    required bool includePastEvents,
    SuperSearchFilters? additionalFilters,
    int page = 1,
    int perPage = 20,
  }) async {
    // Merge additional filters with date control
    final filters = SuperSearchFilters(
      category: additionalFilters?.category,
      area: additionalFilters?.area,
      priceMin: additionalFilters?.priceMin,
      priceMax: additionalFilters?.priceMax,
      familyFriendly: additionalFilters?.familyFriendly,
      isWeekend: additionalFilters?.isWeekend,
      isFree: additionalFilters?.isFree,
      includePastEvents: includePastEvents,
    );

    return search(
      query: query,
      filters: filters,
      page: page,
      perPage: perPage,
    );
  }

  /// Popular search shortcuts for quick access
  static const Map<String, String> popularSearches = {
    'Kids Activities': 'kids children family activities',
    'Weekend Events': 'weekend events',
    'Free Events': 'free events activities',
    'Food & Dining': 'food dining restaurants brunch',
    'Arts & Culture': 'art culture exhibitions museums',
    'Fitness & Sports': 'fitness sports gym activities',
    'Shopping': 'shopping malls markets',
    'Entertainment': 'entertainment shows concerts',
    'Family Fun': 'family activities kids children',
    'Date Night': 'romantic dining couples activities',
    'Outdoor Activities': 'outdoor beach park activities',
    'Live Music': 'live music concerts performances',
  };

  /// Get popular search terms
  static List<String> getPopularSearches() {
    return popularSearches.keys.toList();
  }

  /// Get query for popular search
  static String getPopularSearchQuery(String searchTerm) {
    return popularSearches[searchTerm] ?? searchTerm;
  }

  /// Helper method to track click with automatic position calculation
  Future<ApiResponse<bool>> trackSearchResultClick({
    required String query,
    required String eventId,
    required List<Event> searchResults,
  }) async {
    // Find position of event in search results
    final position = searchResults.indexWhere((event) => event.id == eventId) + 1;
    
    if (position > 0) {
      return trackClickEvent(
        query: query,
        eventId: eventId,
        position: position,
      );
    } else {
      print('⚠️ Event not found in search results for click tracking');
      return ApiResponse.error('Event not found in search results');
    }
  }

  /// Get last search tracking info (for debugging/monitoring)
  EventTrackingInfo? get lastSearchTracking => _lastSearchTracking;

  /// Check if date filtering is active (for UI display)
  bool get isDateFilteringActive => true; // Always active now

  /// Get search tips for users
  static List<String> getSearchTips() {
    return [
      'Use natural language: "kids activities this weekend"',
      'Search by area: "concerts in Marina"',
      'Find free events: "free family activities"',
      'Combine filters: "outdoor activities kids free"',
      'Search past events: Use historical search option',
      'Be specific: "cooking classes for beginners"',
    ];
  }

  /// Get information about date filtering for help/info screens
  static Map<String, dynamic> getDateFilteringInfo() {
    return {
      'title': 'Smart Date Filtering',
      'description': 'By default, only current and upcoming events are shown to help you find relevant activities.',
      'features': [
        'Automatic filtering of expired events',
        'Shows only current and future events',
        'Option to include historical events when needed',
        'Optimized for finding events you can actually attend',
      ],
      'usage': [
        'Default searches show only upcoming events',
        'Use "Include Past Events" option for historical searches',
        'Perfect for finding events you can still attend',
      ],
    };
  }
}