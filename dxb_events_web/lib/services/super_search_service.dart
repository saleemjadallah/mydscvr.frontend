import 'package:dio/dio.dart';
import '../models/event.dart';
import '../models/api_response.dart';
import 'api/dio_config.dart';
import '../core/utils/safe_event_parser.dart';

/// Super Search filters model
class SuperSearchFilters {
  final String? category;
  final String? area;
  final double? priceMin;
  final double? priceMax;
  final bool? familyFriendly;
  final bool? isWeekend;
  final bool? isFree;

  const SuperSearchFilters({
    this.category,
    this.area,
    this.priceMin,
    this.priceMax,
    this.familyFriendly,
    this.isWeekend,
    this.isFree,
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
    return params;
  }
}

/// Super Search Result with enhanced metadata
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

  const SuperSearchStatus({
    required this.service,
    required this.enabled,
    required this.appId,
    required this.indexName,
    required this.status,
    required this.features,
    required this.expectedResponseTime,
  });

  factory SuperSearchStatus.fromJson(Map<String, dynamic> json) {
    return SuperSearchStatus(
      service: json['service'] as String,
      enabled: json['enabled'] as bool,
      appId: json['app_id'] as String,
      indexName: json['index_name'] as String,
      status: json['status'] as String,
      features: (json['features'] as List<dynamic>).cast<String>(),
      expectedResponseTime: json['expected_response_time'] as String,
    );
  }
}

/// MyDscvr Super Search Service - Powered by Algolia
/// 
/// Provides instant, intelligent search with typo tolerance,
/// advanced filtering, and sub-100ms response times.
class SuperSearchService {
  late final Dio _dio;

  SuperSearchService() {
    _dio = DioConfig.createDio(useLocalHost: false);
  }

  /// Perform MyDscvr Super Search with intelligent query enhancement
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
      };

      // Add filter parameters
      if (filters != null) {
        queryParams.addAll(filters.toQueryParams());
      }

      final response = await _dio.get(
        '/ai-search',
        queryParameters: queryParams,
        options: Options(
          receiveTimeout: const Duration(seconds: 15), // Longer timeout for AI processing
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final result = SuperSearchResult.fromJson(response.data);
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

  /// Get Super Search service status
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
}