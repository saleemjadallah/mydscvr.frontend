import 'package:dio/dio.dart';
import '../../models/user.dart';
import '../../models/api_response.dart';

/// Simple API client using Dio
class ApiClient {
  final Dio _dio;
  
  ApiClient(this._dio);

  // Authentication endpoints
  Future<ApiResponse<Map<String, dynamic>>> login(Map<String, dynamic> loginData) async {
    try {
      final response = await _dio.post('/auth/login', data: loginData);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Login failed');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> register(Map<String, dynamic> registerData) async {
    try {
      final response = await _dio.post('/auth/register', data: registerData);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Registration failed');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> refreshToken(Map<String, dynamic> refreshData) async {
    try {
      final response = await _dio.post('/auth/refresh', data: refreshData);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Token refresh failed');
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      await _dio.post('/auth/logout');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Logout failed');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> completeOnboarding(Map<String, dynamic> onboardingData) async {
    try {
      final response = await _dio.post('/auth/complete-onboarding', data: onboardingData);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to complete onboarding');
    }
  }

  Future<ApiResponse<UserProfile>> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/profile');
      final user = UserProfile.fromJson(response.data);
      return ApiResponse.success(user);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to get user');
    }
  }

  Future<ApiResponse<UserProfile>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _dio.put('/auth/profile', data: profileData);
      final user = UserProfile.fromJson(response.data);
      return ApiResponse.success(user);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Profile update failed');
    }
  }

  Future<ApiResponse<void>> changePassword(Map<String, dynamic> passwordData) async {
    try {
      await _dio.post('/auth/change-password', data: passwordData);
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Password change failed');
    }
  }

  Future<ApiResponse<void>> forgotPassword(Map<String, dynamic> emailData) async {
    try {
      await _dio.post('/auth/forgot-password', data: emailData);
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Password reset request failed');
    }
  }

  Future<ApiResponse<void>> resetPassword(Map<String, dynamic> resetData) async {
    try {
      await _dio.post('/auth/reset-password', data: resetData);
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Password reset failed');
    }
  }

  // Email verification endpoints
  Future<ApiResponse<Map<String, dynamic>>> sendEmailVerification(Map<String, dynamic> emailData) async {
    try {
      final response = await _dio.post('/auth/resend-verification', data: emailData);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to send verification');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyEmail(Map<String, dynamic> verificationData) async {
    try {
      final response = await _dio.post('/auth/complete-registration', data: verificationData);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Email verification failed');
    }
  }

  // Events endpoints
  Future<ApiResponse<List<Map<String, dynamic>>>> getEvents({
    String? category,
    String? location,
    String? date,
    int? priceMax,
    String? ageGroup,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get('/events', queryParameters: {
        if (category != null) 'category': category,
        if (location != null) 'location': location,
        if (date != null) 'date': date,
        if (priceMax != null) 'price_max': priceMax,
        if (ageGroup != null) 'age_group': ageGroup,
        'page': page,
      });
      return ApiResponse.success(List<Map<String, dynamic>>.from(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to get events');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getEventById(String eventId) async {
    try {
      final response = await _dio.get('/events/$eventId');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to get event');
    }
  }

  Future<ApiResponse<void>> saveEvent(String eventId) async {
    try {
      await _dio.post('/auth/events/$eventId/save');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to save event');
    }
  }

  Future<ApiResponse<void>> unsaveEvent(String eventId) async {
    try {
      await _dio.delete('/auth/events/$eventId/save');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to unsave event');
    }
  }

  // Search endpoints
  Future<ApiResponse<Map<String, dynamic>>> searchEvents({
    required String query,
    String? filters,
  }) async {
    try {
      final response = await _dio.get('/search', queryParameters: {
        'q': query,
        if (filters != null) 'filters': filters,
      });
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Search failed');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getSearchSuggestions({
    required String query,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get('/search/suggestions', queryParameters: {
        'q': query,
        'limit': limit,
      });
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to get suggestions');
    }
  }

  // User preferences endpoints
  Future<ApiResponse<Map<String, dynamic>>> getUserPreferences() async {
    try {
      final response = await _dio.get('/user/preferences');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to get preferences');
    }
  }

  Future<ApiResponse<void>> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      await _dio.put('/user/preferences/', data: preferences);
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to update preferences');
    }
  }

  // Favorites endpoints
  Future<ApiResponse<List<Map<String, dynamic>>>> getFavoriteEvents() async {
    try {
      final response = await _dio.get('/user/favorites/');
      return ApiResponse.success(List<Map<String, dynamic>>.from(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to get favorites');
    }
  }

  Future<ApiResponse<void>> addToFavorites(String eventId) async {
    try {
      await _dio.post('/user/favorites/$eventId/');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to add to favorites');
    }
  }

  Future<ApiResponse<void>> removeFromFavorites(String eventId) async {
    try {
      await _dio.delete('/user/favorites/$eventId/');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to remove from favorites');
    }
  }

  Future<ApiResponse<void>> clearFavorites() async {
    try {
      await _dio.delete('/user/favorites/');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to clear favorites');
    }
  }
}

/// API Client Provider with Environment Support
class ApiClientProvider {
  static ApiClient? _instance;
  
  // Environment-based URLs
  static const Map<String, List<String>> _environmentUrls = {
    'development': [
      'http://localhost:8000',
    ],
    'staging': [
      '/api',                      // Use Netlify proxy for staging
      'http://3.29.102.4:8000',   // Fallback to direct connection
    ],
    'testing': [
      '/api',                      // Use Netlify proxy for testing
      'http://3.29.102.4:8000',   // Fallback to direct connection
    ],
    'production': [
      'https://mydscvr.xyz',   // Primary production API
      'http://3.29.102.4:8000',   // Fallback to direct connection
    ],
  };
  
  static ApiClient get instance {
    _instance ??= _createApiClient();
    return _instance!;
  }
  
  static ApiClient _createApiClient() {
    final dio = Dio();
    
    // Get compile-time defines - simpler approach for web compatibility
    const customApiUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    const fallbackApiUrl = String.fromEnvironment('FALLBACK_API_URL', defaultValue: '');
    
    // Use custom API URL if provided, otherwise default to /api for Netlify proxy
    String baseUrl = customApiUrl.isNotEmpty ? customApiUrl : '/api';
    List<String> fallbackUrls = [];
    
    if (fallbackApiUrl.isNotEmpty) {
      fallbackUrls.add(fallbackApiUrl);
    }
    
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.followRedirects = true;
    dio.options.maxRedirects = 5;
    
    // API Client initialized
    
    // Add interceptors with fallback support
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          // TODO: Add token from secure storage
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          
          // Try fallback URLs if primary fails
          if (fallbackUrls.isNotEmpty && error.type == DioExceptionType.connectionError) {
            for (final fallbackUrl in fallbackUrls) {
              try {
                
                final fallbackOptions = error.requestOptions.copyWith(
                  baseUrl: fallbackUrl,
                );
                
                final response = await dio.fetch(fallbackOptions);
                print('✅ Fallback success: $fallbackUrl');
                handler.resolve(response);
                return;
              } catch (fallbackError) {
                print('❌ Fallback failed: $fallbackUrl - $fallbackError');
                continue;
              }
            }
          }
          
          handler.next(error);
        },
      ),
    );
    
    return ApiClient(dio);
  }
  
  /// Reset the API client instance (useful for testing different environments)
  static void reset() {
    _instance = null;
  }
  
  /// Get current base URL
  static String get currentBaseUrl {
    return instance._dio.options.baseUrl;
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  const ApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'ApiException: $message';
} 