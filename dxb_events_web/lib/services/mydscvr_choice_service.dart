import 'package:dio/dio.dart';
import '../models/event.dart';
import '../models/api_response.dart';
import 'api/dio_config.dart';
import '../core/utils/safe_event_parser.dart';

/// Service for MyDscvr's Choice daily featured event
/// Fetches today's featured event with Firecrawl prioritization
class MyDscvrChoiceService {
  late final Dio _dio;

  MyDscvrChoiceService() {
    _dio = DioConfig.createDio(useLocalHost: false);
  }

  /// Get today's MyDscvr's Choice featured event
  Future<ApiResponse<Event>> getCurrentChoice() async {
    try {
      // Adjust API path based on base URL configuration
      final apiPath = _dio.options.baseUrl.isEmpty 
          ? 'mydscvr-choice/current'  // For Netlify proxy (mydscvr.ai)
          : '/api/mydscvr-choice/current';  // For direct backend (mydscvr.xyz)
      
      final response = await _dio.get(apiPath);

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['success'] == true && data['data'] != null) {
          final choiceData = data['data'] as Map<String, dynamic>;
          final eventData = choiceData['event_data'] as Map<String, dynamic>;
          
          final event = SafeEventParser.parseEvent(eventData);
          if (event != null) {
            return ApiResponse.success(event);
          } else {
            return ApiResponse.error('Failed to parse MyDscvr\'s Choice event data');
          }
        } else {
          return ApiResponse.error(data['message'] ?? 'No MyDscvr\'s Choice available today');
        }
      } else {
        return ApiResponse.error('Failed to fetch MyDscvr\'s Choice: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return ApiResponse.error('Network error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Manually refresh today's MyDscvr's Choice (for testing)
  Future<ApiResponse<Event>> refreshChoice() async {
    try {
      // Adjust API path based on base URL configuration
      final apiPath = _dio.options.baseUrl.isEmpty 
          ? 'mydscvr-choice/refresh'  // For Netlify proxy (mydscvr.ai)
          : '/api/mydscvr-choice/refresh';  // For direct backend (mydscvr.xyz)
      
      final response = await _dio.post(apiPath);

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['success'] == true && data['data'] != null) {
          final choiceData = data['data'] as Map<String, dynamic>;
          final eventData = choiceData['event_data'] as Map<String, dynamic>;
          
          final event = SafeEventParser.parseEvent(eventData);
          if (event != null) {
            return ApiResponse.success(event);
          } else {
            return ApiResponse.error('Failed to parse refreshed MyDscvr\'s Choice event data');
          }
        } else {
          return ApiResponse.error(data['message'] ?? 'Failed to refresh MyDscvr\'s Choice');
        }
      } else {
        return ApiResponse.error('Failed to refresh MyDscvr\'s Choice: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return ApiResponse.error('Network error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Get MyDscvr's Choice history for the last N days
  Future<ApiResponse<List<Event>>> getChoiceHistory({int days = 7}) async {
    try {
      // Adjust API path based on base URL configuration
      final apiPath = _dio.options.baseUrl.isEmpty 
          ? 'mydscvr-choice/history'  // For Netlify proxy (mydscvr.ai)
          : '/api/mydscvr-choice/history';  // For direct backend (mydscvr.xyz)
      
      final response = await _dio.get(
        apiPath,
        queryParameters: {'days': days},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['success'] == true && data['data'] != null) {
          final historyData = data['data'] as List<dynamic>;
          final events = <Event>[];
          
          for (final choiceData in historyData) {
            final eventData = choiceData['event_data'] as Map<String, dynamic>;
            final event = SafeEventParser.parseEvent(eventData);
            if (event != null) {
              events.add(event);
            }
          }
          
          return ApiResponse.success(events);
        } else {
          return ApiResponse.error('No MyDscvr\'s Choice history available');
        }
      } else {
        return ApiResponse.error('Failed to fetch MyDscvr\'s Choice history: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return ApiResponse.error('Network error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }
}