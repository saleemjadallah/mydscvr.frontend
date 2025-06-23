import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/event.dart';
import '../core/config/api_config.dart';

/// Enhanced Events Service that utilizes all new backend filtering capabilities
class EnhancedEventsService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Search events with enhanced filters using the backend's filter-to-query system
  static Future<List<Event>> searchEventsWithFilters(Map<String, dynamic> filters) async {
    try {
      final uri = Uri.parse('$baseUrl/api/events/search/filtered');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(filters),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['success'] == true && data['events'] != null) {
          final List<dynamic> eventsJson = data['events'];
          return eventsJson
              .map((eventJson) => Event.fromBackendApi(eventJson))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch filtered events');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error searching events with filters: $e');
      rethrow;
    }
  }

  /// Get events by specific categories with enhanced data
  static Future<List<Event>> getEventsByCategories(List<String> categories) async {
    try {
      final uri = Uri.parse('$baseUrl/api/events/categories').replace(
        queryParameters: {
          'categories': categories.join(','),
          'enhanced': 'true', // Request enhanced data with quality metrics
        },
      );
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['success'] == true && data['events'] != null) {
          final List<dynamic> eventsJson = data['events'];
          return eventsJson
              .map((eventJson) => Event.fromBackendApi(eventJson))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch events by categories');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching events by categories: $e');
      rethrow;
    }
  }

  /// Get events with quality metrics filtering
  static Future<List<Event>> getHighQualityEvents({
    double? minConfidence,
    double? minCompleteness,
    String? sourceReliability,
  }) async {
    try {
      final queryParams = <String, String>{
        'enhanced': 'true',
      };
      
      if (minConfidence != null) {
        queryParams['min_confidence'] = minConfidence.toString();
      }
      if (minCompleteness != null) {
        queryParams['min_completeness'] = minCompleteness.toString();
      }
      if (sourceReliability != null) {
        queryParams['source_reliability'] = sourceReliability;
      }
      
      final uri = Uri.parse('$baseUrl/api/events/quality').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['success'] == true && data['events'] != null) {
          final List<dynamic> eventsJson = data['events'];
          return eventsJson
              .map((eventJson) => Event.fromBackendApi(eventJson))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch high quality events');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching high quality events: $e');
      rethrow;
    }
  }

  /// Get events by area with enhanced filtering
  static Future<List<Event>> getEventsByArea(
    String area, {
    bool? metroAccessible,
    bool? parkingAvailable,
    String? venueType,
  }) async {
    try {
      final queryParams = <String, String>{
        'area': area,
        'enhanced': 'true',
      };
      
      if (metroAccessible != null) {
        queryParams['metro_accessible'] = metroAccessible.toString();
      }
      if (parkingAvailable != null) {
        queryParams['parking_available'] = parkingAvailable.toString();
      }
      if (venueType != null) {
        queryParams['venue_type'] = venueType;
      }
      
      final uri = Uri.parse('$baseUrl/api/events/area').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['success'] == true && data['events'] != null) {
          final List<dynamic> eventsJson = data['events'];
          return eventsJson
              .map((eventJson) => Event.fromBackendApi(eventJson))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch events by area');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching events by area: $e');
      rethrow;
    }
  }

  /// Get events with social media presence
  static Future<List<Event>> getEventsWithSocialMedia({
    List<String>? platforms,
  }) async {
    try {
      final queryParams = <String, String>{
        'has_social_media': 'true',
        'enhanced': 'true',
      };
      
      if (platforms != null && platforms.isNotEmpty) {
        queryParams['social_platforms'] = platforms.join(',');
      }
      
      final uri = Uri.parse('$baseUrl/api/events/social').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['success'] == true && data['events'] != null) {
          final List<dynamic> eventsJson = data['events'];
          return eventsJson
              .map((eventJson) => Event.fromBackendApi(eventJson))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch events with social media');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching events with social media: $e');
      rethrow;
    }
  }

  /// Get trending events based on social media and quality metrics
  static Future<List<Event>> getTrendingEvents({
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/events/trending').replace(
        queryParameters: {
          'limit': limit.toString(),
          'enhanced': 'true',
          'include_quality_metrics': 'true',
          'include_social_media': 'true',
        },
      );
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['success'] == true && data['events'] != null) {
          final List<dynamic> eventsJson = data['events'];
          return eventsJson
              .map((eventJson) => Event.fromBackendApi(eventJson))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch trending events');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching trending events: $e');
      rethrow;
    }
  }

  /// Get event recommendations based on user preferences and quality
  static Future<List<Event>> getRecommendedEvents({
    required Map<String, dynamic> userPreferences,
    double minQualityScore = 0.6,
  }) async {
    try {
      final requestBody = {
        'user_preferences': userPreferences,
        'min_quality_score': minQualityScore,
        'enhanced': true,
        'include_quality_metrics': true,
        'include_social_media': true,
      };

      final uri = Uri.parse('$baseUrl/api/events/recommendations');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['success'] == true && data['events'] != null) {
          final List<dynamic> eventsJson = data['events'];
          return eventsJson
              .map((eventJson) => Event.fromBackendApi(eventJson))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch recommended events');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching recommended events: $e');
      rethrow;
    }
  }

  /// Get events by multiple criteria with advanced filtering
  static Future<List<Event>> getEventsAdvanced({
    List<String>? categories,
    List<String>? areas,
    Map<String, dynamic>? priceRange,
    Map<String, dynamic>? dateRange,
    List<String>? features,
    String? language,
    String? venueType,
    String? eventType,
    bool? familyFriendly,
    bool? freeOnly,
    bool? metroAccessible,
    String? sourceReliability,
    double? minQualityScore,
    String? sortBy,
    String? sortOrder,
    int? limit,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'enhanced': true,
        'include_quality_metrics': true,
        'include_social_media': true,
      };

      // Add filters
      if (categories != null && categories.isNotEmpty) {
        requestBody['categories'] = categories;
      }
      if (areas != null && areas.isNotEmpty) {
        requestBody['areas'] = areas;
      }
      if (priceRange != null) {
        requestBody['price_range'] = priceRange;
      }
      if (dateRange != null) {
        requestBody['date_range'] = dateRange;
      }
      if (features != null && features.isNotEmpty) {
        requestBody['features'] = features;
      }
      if (language != null) {
        requestBody['language'] = language;
      }
      if (venueType != null) {
        requestBody['venue_type'] = venueType;
      }
      if (eventType != null) {
        requestBody['event_type'] = eventType;
      }
      if (familyFriendly != null) {
        requestBody['family_friendly'] = familyFriendly;
      }
      if (freeOnly != null) {
        requestBody['free_only'] = freeOnly;
      }
      if (metroAccessible != null) {
        requestBody['metro_accessible'] = metroAccessible;
      }
      if (sourceReliability != null) {
        requestBody['source_reliability'] = sourceReliability;
      }
      if (minQualityScore != null) {
        requestBody['min_quality_score'] = minQualityScore;
      }
      if (sortBy != null) {
        requestBody['sort_by'] = sortBy;
      }
      if (sortOrder != null) {
        requestBody['sort_order'] = sortOrder;
      }
      if (limit != null) {
        requestBody['limit'] = limit;
      }

      final uri = Uri.parse('$baseUrl/api/events/advanced');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['success'] == true && data['events'] != null) {
          final List<dynamic> eventsJson = data['events'];
          return eventsJson
              .map((eventJson) => Event.fromBackendApi(eventJson))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch advanced filtered events');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching advanced filtered events: $e');
      rethrow;
    }
  }

  /// Get extraction quality statistics from the backend
  static Future<Map<String, dynamic>> getQualityStatistics() async {
    try {
      final uri = Uri.parse('$baseUrl/api/events/quality/stats');
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          return data['statistics'] ?? {};
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch quality statistics');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching quality statistics: $e');
      rethrow;
    }
  }

  /// Trigger manual event extraction with custom filters
  static Future<Map<String, dynamic>> triggerEventExtraction({
    required Map<String, dynamic> extractionFilters,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/events/extract');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'filters': extractionFilters,
          'enhanced_extraction': true,
          'include_quality_metrics': true,
          'include_social_media': true,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to trigger event extraction');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error triggering event extraction: $e');
      rethrow;
    }
  }
}