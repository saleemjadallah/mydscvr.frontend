import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/advice_models.dart';
import 'dio_config.dart';

class AdviceApiService {
  final Dio _dio = DioConfig.createDio();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  // Circuit breaker to prevent infinite loops
  static int _consecutiveFailures = 0;
  static DateTime? _lastFailureTime;
  static const int _maxConsecutiveFailures = 3;
  static const Duration _backoffDuration = Duration(minutes: 2);

  // Get advice for an event
  Future<List<EventAdvice>> getEventAdvice(String eventId, {
    AdviceCategory? category,
    AdviceType? type,
    int limit = 20,
    int offset = 0,
  }) async {
    // Circuit breaker: check if we should skip this call
    if (_shouldSkipDueToFailures()) {
      print('🔄 AdviceApiService: Skipping getEventAdvice due to circuit breaker ($_consecutiveFailures failures)');
      return [];
    }
    
    try {
      print('🔍 Getting advice for event: $eventId');
      
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      
      if (category != null) {
        queryParams['category'] = category.name;
      }
      
      if (type != null) {
        queryParams['advice_type'] = type.name;
      }

      final response = await _dio.get(
        '/advice/event/$eventId',
        queryParameters: queryParams,
      );
      
      print('🔍 Advice response status: ${response.statusCode}');
      print('🔍 Advice response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        // Reset failure count on success
        _consecutiveFailures = 0;
        _lastFailureTime = null;
        
        final List<dynamic> adviceList = response.data is List 
            ? response.data 
            : (response.data['advice'] ?? []);
            
        print('🔍 Found ${adviceList.length} advice entries');
        
        return adviceList
            .map((json) => EventAdvice.fromJson(json))
            .toList();
      }
      
      // Handle non-200 response as failure
      print('❌ Non-200 response: ${response.statusCode}');
      _handleFailure();
      return [];
    } on DioException catch (e) {
      _handleFailure();
      print('❌ DioException fetching advice: ${e.message}');
      print('❌ Response data: ${e.response?.data}');
      print('❌ Status code: ${e.response?.statusCode}');
      return [];
    } catch (e) {
      _handleFailure();
      print('❌ Unexpected error fetching advice: $e');
      return [];
    }
  }

  // Submit new advice
  Future<AdviceSubmissionResult> submitAdvice({
    required String eventId,
    required String title,
    required String content,
    required AdviceCategory category,
    required AdviceType type,
    List<String> tags = const [],
    bool venueFamiliarity = false,
    int? similarEventsAttended,
    DateTime? experienceDate,
  }) async {
    // Circuit breaker: check if we should skip this call
    if (_shouldSkipDueToFailures()) {
      print('🔄 AdviceApiService: Skipping submitAdvice due to circuit breaker ($_consecutiveFailures failures)');
      return AdviceSubmissionResult.error('Service temporarily unavailable. Please try again later.');
    }
    
    try {
      print('📝 Submitting advice for event: $eventId');
      
      // Verify we have an access token
      final accessToken = await _storage.read(key: 'access_token');
      if (accessToken == null) {
        print('❌ No access token found');
        return AdviceSubmissionResult.error('Please log in to submit advice');
      }
      
      final adviceData = {
        'event_id': eventId,
        'title': title,
        'content': content,
        'category': _mapCategoryToBackend(category),
        'advice_type': _mapTypeToBackend(type),
        'tags': tags,
        'venue_familiarity': venueFamiliarity,
        'similar_events_attended': similarEventsAttended,
        'experience_date': experienceDate?.toIso8601String(),
        'language': 'en',
      };
      
      print('📝 Advice data: $adviceData');

      final response = await _dio.post(
        '/advice/',
        data: adviceData,
      );
      
      print('📝 Submit response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Reset failure count on success
        _consecutiveFailures = 0;
        _lastFailureTime = null;
        
        print('✅ Advice submitted successfully');
        
        return AdviceSubmissionResult.success(
          EventAdvice.fromJson(response.data),
        );
      }
      
      // Handle non-success response as failure
      print('❌ Submit failed with status: ${response.statusCode}');
      _handleFailure();
      return AdviceSubmissionResult.error(
        'Failed to submit advice: ${response.statusMessage}',
      );
    } on DioException catch (e) {
      _handleFailure();
      String errorMessage = 'Failed to submit advice';
      
      print('❌ DioException submitting advice: ${e.message}');
      print('❌ Status code: ${e.response?.statusCode}');
      print('❌ Response data: ${e.response?.data}');
      
      if (e.response?.statusCode == 400) {
        errorMessage = e.response?.data['detail'] ?? 'Invalid advice data';
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Please log in to submit advice';
      } else if (e.response?.statusCode == 403) {
        errorMessage = 'Email verification required to submit advice';
      } else if (e.response?.statusCode == 422) {
        errorMessage = 'Please check your advice content and try again';
      }
      
      return AdviceSubmissionResult.error(errorMessage);
    } catch (e) {
      _handleFailure();
      print('❌ Unexpected error submitting advice: $e');
      return AdviceSubmissionResult.error('Unexpected error: $e');
    }
  }

  // Mark advice as helpful
  Future<bool> markAdviceHelpful(String adviceId) async {
    try {
      print('👍 Marking advice as helpful: $adviceId');
      
      // Verify we have an access token
      final accessToken = await _storage.read(key: 'access_token');
      if (accessToken == null) {
        print('❌ No access token found for helpful vote');
        return false;
      }
      
      final response = await _dio.post('/advice/interact/$adviceId', data: {
        'interaction_type': 'helpful'
      });
      
      print('👍 Helpful response: ${response.statusCode} - ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('❌ Error marking advice as helpful: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      return false;
    } catch (e) {
      print('❌ Unexpected error marking advice as helpful: $e');
      return false;
    }
  }

  // Map frontend category enum to backend values
  String _mapCategoryToBackend(AdviceCategory category) {
    switch (category) {
      case AdviceCategory.general:
        return 'general';
      case AdviceCategory.familyTips:
        return 'family_tips';
      case AdviceCategory.firstTime:
        return 'first_time';
      case AdviceCategory.transportation:
        return 'transportation';
      case AdviceCategory.budgetTips:
        return 'budget_tips';
      case AdviceCategory.accessibility:
        return 'accessibility';
      case AdviceCategory.whatToExpect:
        return 'what_to_expect';
      case AdviceCategory.bestTime:
        return 'best_time';
    }
  }

  // Map frontend type enum to backend values
  String _mapTypeToBackend(AdviceType type) {
    switch (type) {
      case AdviceType.attendedThis:
        return 'attended_this';
      case AdviceType.attendedSimilar:
        return 'attended_similar';
      case AdviceType.localKnowledge:
        return 'local_knowledge';
      case AdviceType.expertTip:
        return 'expert_tip';
    }
  }
  
  // Circuit breaker helper methods
  static bool _shouldSkipDueToFailures() {
    if (_consecutiveFailures < _maxConsecutiveFailures) {
      return false;
    }
    
    if (_lastFailureTime == null) {
      return true;
    }
    
    final timeSinceLastFailure = DateTime.now().difference(_lastFailureTime!);
    return timeSinceLastFailure < _backoffDuration;
  }
  
  static void _handleFailure() {
    _consecutiveFailures++;
    _lastFailureTime = DateTime.now();
    print('🔄 AdviceApiService: Failure count: $_consecutiveFailures/$_maxConsecutiveFailures');
    
    if (_consecutiveFailures >= _maxConsecutiveFailures) {
      print('🚫 AdviceApiService: Circuit breaker OPEN - will skip requests for ${_backoffDuration.inMinutes} minutes');
    }
  }
}

// Result class for advice submission
class AdviceSubmissionResult {
  final bool isSuccess;
  final EventAdvice? advice;
  final String? errorMessage;

  AdviceSubmissionResult.success(this.advice)
      : isSuccess = true,
        errorMessage = null;

  AdviceSubmissionResult.error(this.errorMessage)
      : isSuccess = false,
        advice = null;
}
