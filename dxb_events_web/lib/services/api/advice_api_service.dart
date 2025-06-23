import 'package:dio/dio.dart';
import '../../models/advice_models.dart';
import 'dio_config.dart';

class AdviceApiService {
  final Dio _dio = DioConfig.createDio();

  // Get advice for an event
  Future<List<EventAdvice>> getEventAdvice(String eventId, {
    AdviceCategory? category,
    AdviceType? type,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      
      if (category != null) {
        queryParams['category'] = category.name;
      }
      
      if (type != null) {
        queryParams['type'] = type.name;
      }

      final response = await _dio.get(
        '/advice/events/\$eventId',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> adviceList = response.data['advice'] ?? [];
        return adviceList
            .map((json) => EventAdvice.fromJson(json))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      print('Error fetching advice: \${e.message}');
      return [];
    } catch (e) {
      print('Unexpected error fetching advice: \$e');
      return [];
    }
  }

  // Submit new advice
  Future<AdviceSubmissionResult> submitAdvice({
    required String eventId,
    required String content,
    required AdviceCategory category,
    required AdviceType type,
    List<String> tags = const [],
  }) async {
    try {
      final adviceData = {
        'event_id': eventId,
        'content': content,
        'category': category.name,
        'type': type.name,
        'tags': tags,
      };

      final response = await _dio.post(
        '/advice',
        data: adviceData,
      );

      if (response.statusCode == 201) {
        return AdviceSubmissionResult.success(
          EventAdvice.fromJson(response.data['advice']),
        );
      }
      
      return AdviceSubmissionResult.error(
        'Failed to submit advice: \${response.statusMessage}',
      );
    } on DioException catch (e) {
      String errorMessage = 'Failed to submit advice';
      
      if (e.response?.statusCode == 400) {
        errorMessage = e.response?.data['detail'] ?? 'Invalid advice data';
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Please log in to submit advice';
      } else if (e.response?.statusCode == 422) {
        errorMessage = 'Please check your advice content and try again';
      }
      
      return AdviceSubmissionResult.error(errorMessage);
    } catch (e) {
      return AdviceSubmissionResult.error('Unexpected error: \$e');
    }
  }

  // Mark advice as helpful
  Future<bool> markAdviceHelpful(String adviceId) async {
    try {
      final response = await _dio.post('/advice/\$adviceId/helpful');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Error marking advice as helpful: \${e.message}');
      return false;
    } catch (e) {
      print('Unexpected error marking advice as helpful: \$e');
      return false;
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
