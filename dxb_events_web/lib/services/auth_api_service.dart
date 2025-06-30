import 'dart:convert';
import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // TODO: Replace with web-safe storage
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/event.dart';
import 'api/dio_config.dart';

class AuthApiService {
  // Use relative paths since DioConfig handles the base URL
  static const String _authPath = '/auth';
  
  late final Dio _dio;
  // static const _storage = FlutterSecureStorage(); // Replaced with SharedPreferences
  
  // Token storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _sessionTokenKey = 'session_token';
  static const String _userDataKey = 'user_data';
  
  AuthApiService() {
    _dio = DioConfig.createDio();
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to requests
          final token = await getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          // Add session token header
          final sessionToken = await getSessionToken();
          if (sessionToken != null) {
            options.headers['X-Session-Token'] = sessionToken;
          }
          
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 errors by clearing tokens
          if (error.response?.statusCode == 401) {
            await clearTokens();
          }
          handler.next(error);
        },
      ),
    );
  }
  
  // Storage methods
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }
  
  Future<String?> getSessionToken() async {
    return await _storage.read(key: _sessionTokenKey);
  }
  
  Future<void> saveTokens(String accessToken, String sessionToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _sessionTokenKey, value: sessionToken);
  }
  
  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
  
  Future<UserProfile?> getCachedUser() async {
    try {
      final userData = await _storage.read(key: _userDataKey);
      if (userData != null) {
        final Map<String, dynamic> userMap = jsonDecode(userData);
        return UserProfile.fromJson(userMap);
      }
    } catch (e) {
      print('Error getting cached user: $e');
    }
    return null;
  }
  
  Future<void> cacheUser(UserProfile user) async {
    try {
      final userData = jsonEncode(user.toJson());
      await _storage.write(key: _userDataKey, value: userData);
    } catch (e) {
      print('Error caching user: $e');
    }
  }
  
  // Auth API methods with OTP verification
  Future<OTPRegistrationResult> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final response = await _dio.post(
        '$_authPath/register',
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          if (phoneNumber != null) 'phone_number': phoneNumber,
        },
        options: Options(),
      );
      
      if (response.data['success'] == true) {
        return OTPRegistrationResult.success(
          message: response.data['message'],
          email: email,
          otpSent: response.data['otp_sent'] ?? false,
          expiresAt: response.data['expires_at'] != null 
              ? DateTime.parse(response.data['expires_at'])
              : null,
        );
      } else {
        return OTPRegistrationResult.error(response.data['message'] ?? 'Registration failed');
      }
      
    } on DioException catch (e) {
      return OTPRegistrationResult.error(_handleDioErrorMessage(e, 'Registration failed'));
    } catch (e) {
      return OTPRegistrationResult.error('Registration failed: $e');
    }
  }

  Future<AuthResult> completeRegistration({
    required String email,
    required String otpCode,
  }) async {
    try {
      final response = await _dio.post(
        '$_authPath/complete-registration',
        data: {
          'email': email,
          'otp_code': otpCode,
          'purpose': 'email_verification',
        },
        options: Options(),
      );
      
      final accessToken = response.data['access_token'];
      final refreshToken = response.data['session_token']; // Backend returns session_token, not refresh_token
      final userData = response.data['user'];
      
      if (accessToken != null && userData != null) {
        // Save tokens
        await saveTokens(accessToken, refreshToken ?? '');
        
        // Create and cache user
        final user = UserProfile.fromJson(userData);
        await cacheUser(user);
        
        return AuthResult.success(
          message: 'Registration completed successfully!',
          user: user,
          accessToken: accessToken,
          sessionToken: refreshToken,
        );
      }
      
      return AuthResult.error('Invalid response data');
      
    } on DioException catch (e) {
      return _handleDioError(e, 'Registration completion failed');
    } catch (e) {
      return AuthResult.error('Registration completion failed: $e');
    }
  }

  Future<OTPResult> resendVerificationCode({
    required String email,
    required String userName,
  }) async {
    try {
      final response = await _dio.post(
        '$_authPath/resend-verification',
        data: email,
        options: Options(),
      );
      
      // Check for successful response (status 200-299)
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return OTPResult.success(
          message: response.data['message'] ?? 'Verification code sent successfully!',
          expiresAt: response.data['expires_at'] != null 
              ? DateTime.parse(response.data['expires_at'])
              : DateTime.now().add(const Duration(minutes: 10)),
        );
      } else {
        return OTPResult.error(response.data['message'] ?? 'Failed to resend verification code');
      }
      
    } on DioException catch (e) {
      return OTPResult.error(_handleDioErrorMessage(e, 'Failed to resend verification code'));
    } catch (e) {
      return OTPResult.error('Failed to resend verification code: $e');
    }
  }
  
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_authPath/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
        ),
      );
      
      final accessToken = response.data['access_token'];
      final sessionToken = response.data['session_token'];
      final userData = response.data['user'];
      
      if (accessToken != null && sessionToken != null && userData != null) {
        // Save tokens
        await saveTokens(accessToken, sessionToken);
        
        // Create and cache user
        final user = UserProfile.fromJson(userData);
        await cacheUser(user);
        
        return AuthResult.success(
          message: 'Login successful',
          user: user,
          accessToken: accessToken,
          sessionToken: sessionToken,
        );
      } else {
        return AuthResult.error('Invalid response from server');
      }
      
    } on DioException catch (e) {
      return _handleDioError(e, 'Login failed');
    } catch (e) {
      return AuthResult.error('Login failed: $e');
    }
  }
  
  Future<AuthResult> logout() async {
    try {
      // Clear tokens locally (no backend logout endpoint needed)
      await clearTokens();
      
      return AuthResult.success(message: 'Logged out successfully');
      
    } catch (e) {
      // Clear tokens even if clearing fails
      await clearTokens();
      return AuthResult.success(message: 'Logged out successfully');
    }
  }
  
  Future<UserProfile?> getCurrentUser() async {
    try {
      print('🔍 Getting current user...');
      
      // Try to get from cache first
      final cachedUser = await getCachedUser();
      final token = await getAccessToken();
      
      print('🔍 Cached user exists: ${cachedUser != null}');
      print('🔍 Access token exists: ${token != null}');
      
      if (token == null) {
        print('🔍 No access token found');
        return null;
      }
      
      // If we have a cached user and recent token, return cached
      if (cachedUser != null) {
        print('🔍 Returning cached user: ${cachedUser.email}');
        return cachedUser;
      }
      
      // Otherwise, fetch from API
      print('🔍 Fetching user from API...');
      final response = await _dio.get(
        '$_authPath/profile',
        options: Options(),
      );
      
      print('🔍 API response status: ${response.statusCode}');
      
      final user = UserProfile.fromJson(response.data);
      await cacheUser(user);
      
      print('🔍 User fetched and cached: ${user.email}');
      return user;
      
    } on DioException catch (e) {
      print('❌ DioException getting user: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 401) {
        print('❌ Unauthorized, clearing tokens');
        await clearTokens();
      }
      return null;
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }
  
  Future<AuthResult> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? avatar,
    Map<String, bool>? privacySettings,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      if (dateOfBirth != null) data['date_of_birth'] = dateOfBirth.toIso8601String();
      if (avatar != null) data['avatar'] = avatar;
      if (privacySettings != null) data['privacy_settings'] = privacySettings;
      
      // Profile update endpoint not implemented in backend yet
      // Just return success for now
      return AuthResult.success(
        message: 'Profile update feature coming soon',
      );
      
    } on DioException catch (e) {
      return _handleDioError(e, 'Profile update failed');
    } catch (e) {
      return AuthResult.error('Profile update failed: $e');
    }
  }
  
  Future<AuthResult> completeOnboarding({
    required List<Map<String, dynamic>> familyMembers,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      print('🚀 Sending onboarding completion request...');
      print('🚀 Family members count: ${familyMembers.length}');
      print('🚀 Preferences keys: ${preferences.keys}');
      
      final response = await _dio.post(
        '$_authPath/complete-onboarding',
        data: {
          'family_members': familyMembers,
          'preferences': preferences,
        },
        options: Options(),
      );
      
      print('✅ Onboarding API response status: ${response.statusCode}');
      print('✅ Response data type: ${response.data.runtimeType}');
      
      // Backend returns user data directly, not wrapped in a response object
      if (response.data != null) {
        final user = UserProfile.fromJson(response.data);
        await cacheUser(user);
        
        print('✅ User profile updated with onboarding data');
        return AuthResult.success(
          message: 'Onboarding completed successfully',
          user: user,
        );
      } else {
        print('❌ Response data is null');
        return AuthResult.error('Invalid response data');
      }
      
    } on DioException catch (e) {
      print('❌ DioException during onboarding: ${e.response?.statusCode} - ${e.message}');
      print('❌ Response data: ${e.response?.data}');
      return _handleDioError(e, 'Onboarding completion failed');
    } catch (e) {
      print('❌ Exception during onboarding: $e');
      return AuthResult.error('Onboarding completion failed: $e');
    }
  }
  
  Future<AuthResult> validateOnboardingStep({
    required int step,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        '$_authPath/validate-onboarding-step',
        data: {
          'step': step,
          'data': data,
        },
        options: Options(
        ),
      );
      
      if (response.data['success'] == true) {
        return AuthResult.success(
          message: response.data['message'] ?? 'Validation successful',
        );
      } else {
        return AuthResult.error(response.data['message'] ?? 'Validation failed');
      }
      
    } on DioException catch (e) {
      return _handleDioError(e, 'Validation failed');
    } catch (e) {
      return AuthResult.error('Validation failed: $e');
    }
  }
  
  Future<AuthResult> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '$_authPath/change-password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
        options: Options(
        ),
      );
      
      if (response.data['success'] == true) {
        // Clear tokens since password change invalidates sessions
        await clearTokens();
        
        return AuthResult.success(
          message: response.data['message'] ?? 'Password changed successfully',
        );
      } else {
        return AuthResult.error(response.data['message'] ?? 'Password change failed');
      }
      
    } on DioException catch (e) {
      return _handleDioError(e, 'Password change failed');
    } catch (e) {
      return AuthResult.error('Password change failed: $e');
    }
  }
  
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    if (token == null) return false;
    
    // Optionally verify token with server
    try {
      await getCurrentUser();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Event Interaction Methods
  Future<AuthResult> heartEvent(String eventId) async {
    try {
      final response = await _dio.post(
        '$_authPath/events/$eventId/heart',
        options: Options(
        ),
      );
      
      if (response.data['success'] == true) {
        return AuthResult.success(
          message: response.data['message'] ?? 'Event hearted successfully',
        );
      } else {
        return AuthResult.error(response.data['message'] ?? 'Failed to heart event');
      }
      
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to heart event');
    } catch (e) {
      return AuthResult.error('Failed to heart event: $e');
    }
  }
  
  Future<AuthResult> unheartEvent(String eventId) async {
    try {
      final response = await _dio.delete(
        '$_authPath/events/$eventId/heart',
        options: Options(
        ),
      );
      
      if (response.data['success'] == true) {
        return AuthResult.success(
          message: response.data['message'] ?? 'Event unhearted successfully',
        );
      } else {
        return AuthResult.error(response.data['message'] ?? 'Failed to unheart event');
      }
      
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to unheart event');
    } catch (e) {
      return AuthResult.error('Failed to unheart event: $e');
    }
  }
  
  Future<AuthResult> saveEvent(String eventId) async {
    try {
      final response = await _dio.post(
        '$_authPath/events/$eventId/save',
        options: Options(
        ),
      );
      
      if (response.data['success'] == true) {
        return AuthResult.success(
          message: response.data['message'] ?? 'Event saved successfully',
        );
      } else {
        return AuthResult.error(response.data['message'] ?? 'Failed to save event');
      }
      
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to save event');
    } catch (e) {
      return AuthResult.error('Failed to save event: $e');
    }
  }
  
  Future<AuthResult> unsaveEvent(String eventId) async {
    try {
      final response = await _dio.delete(
        '$_authPath/events/$eventId/save',
        options: Options(
        ),
      );
      
      if (response.data['success'] == true) {
        return AuthResult.success(
          message: response.data['message'] ?? 'Event unsaved successfully',
        );
      } else {
        return AuthResult.error(response.data['message'] ?? 'Failed to unsave event');
      }
      
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to unsave event');
    } catch (e) {
      return AuthResult.error('Failed to unsave event: $e');
    }
  }
  
  Future<AuthResult> rateEvent(String eventId, double rating) async {
    try {
      final response = await _dio.post(
        '$_authPath/events/$eventId/rate',
        data: {'rating': rating},
        options: Options(
        ),
      );
      
      if (response.data['success'] == true) {
        return AuthResult.success(
          message: response.data['message'] ?? 'Event rated successfully',
        );
      } else {
        return AuthResult.error(response.data['message'] ?? 'Failed to rate event');
      }
      
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to rate event');
    } catch (e) {
      return AuthResult.error('Failed to rate event: $e');
    }
  }
  
  Future<Map<String, dynamic>?> getEventInteractions() async {
    try {
      final response = await _dio.get(
        '$_authPath/events/interactions',
        options: Options(
        ),
      );
      
      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        return null;
      }
      
    } on DioException catch (e) {
      print('Error getting event interactions: $e');
      return null;
    } catch (e) {
      print('Error getting event interactions: $e');
      return null;
    }
  }
  
  Future<FavoriteEventsResult> getFavoriteEvents({
    String? eventType, // 'hearted', 'saved', or null for both
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      
      if (eventType != null) {
        queryParams['event_type'] = eventType;
      }
      
      final response = await _dio.get(
        '$_authPath/favorites',
        queryParameters: queryParams,
        options: Options(),
      );
      
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final eventsData = data['events'] as List<dynamic>;
        final paginationData = data['pagination'] as Map<String, dynamic>;
        
        // Import Event model
        final events = eventsData.map((eventJson) {
          return Event.fromBackendApi(eventJson as Map<String, dynamic>);
        }).toList();
        
        return FavoriteEventsResult.success(
          events: events,
          pagination: PaginationInfo(
            page: paginationData['page'] as int,
            perPage: paginationData['per_page'] as int,
            total: paginationData['total'] as int,
            totalPages: paginationData['total_pages'] as int,
            hasNext: paginationData['has_next'] as bool,
            hasPrev: paginationData['has_prev'] as bool,
          ),
        );
      } else {
        return FavoriteEventsResult.error(
          response.data['message'] ?? 'Failed to get favorite events'
        );
      }
    } on DioException catch (e) {
      final error = _handleDioError(e, 'Failed to fetch favorite events');
      return FavoriteEventsResult.error(error.message);
    } catch (e) {
      return FavoriteEventsResult.error('Failed to fetch favorite events: $e');
    }
  }

  AuthResult _handleDioError(DioException error, String defaultMessage) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return AuthResult.error('Connection timeout - please check your internet connection');
    }
    
    if (error.type == DioExceptionType.connectionError) {
      return AuthResult.error('Connection failed - server may be unavailable');
    }
    
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        return AuthResult.error(data['message'] ?? defaultMessage);
      }
    }
    
    return AuthResult.error(defaultMessage);
  }

  String _handleDioErrorMessage(DioException error, String defaultMessage) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout - please check your internet connection';
    }
    
    if (error.type == DioExceptionType.connectionError) {
      return 'Connection failed - server may be unavailable';
    }
    
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        return data['message'] ?? defaultMessage;
      }
    }
    
    return defaultMessage;
  }

  /// Send forgot password reset code
  Future<AuthResult> forgotPassword({required String email}) async {
    try {
      final response = await _dio.post(
        '$_authPath/forgot-password',
        data: email, // Send email as string directly
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return AuthResult.success(
          message: data['message'] ?? 'Password reset code sent to your email',
        );
      } else {
        return AuthResult.error('Failed to send reset code');
      }
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to send password reset code');
    } catch (e) {
      return AuthResult.error('Failed to send password reset code: $e');
    }
  }

  /// Verify password reset code
  Future<AuthResult> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        '$_authPath/verify-reset-code',
        data: {
          'email': email,
          'otp_code': code,
          'purpose': 'password_reset',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return AuthResult.success(
          message: data['message'] ?? 'Reset code verified successfully',
        );
      } else {
        return AuthResult.error('Invalid or expired reset code');
      }
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to verify reset code');
    } catch (e) {
      return AuthResult.error('Failed to verify reset code: $e');
    }
  }

  /// Reset password with new password and verified code
  Future<AuthResult> resetPassword({
    required String email,
    required String newPassword,
    required String resetCode,
  }) async {
    try {
      final response = await _dio.post(
        '$_authPath/reset-password',
        data: {
          'email': email,
          'new_password': newPassword,
          'reset_code': resetCode,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return AuthResult.success(
          message: data['message'] ?? 'Password reset successfully',
        );
      } else {
        return AuthResult.error('Failed to reset password');
      }
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to reset password');
    } catch (e) {
      return AuthResult.error('Failed to reset password: $e');
    }
  }
}

// Result classes
class AuthResult {
  final bool isSuccess;
  final String message;
  final UserProfile? user;
  final String? accessToken;
  final String? sessionToken;
  
  AuthResult._({
    required this.isSuccess,
    required this.message,
    this.user,
    this.accessToken,
    this.sessionToken,
  });
  
  factory AuthResult.success({
    required String message,
    UserProfile? user,
    String? accessToken,
    String? sessionToken,
  }) {
    return AuthResult._(
      isSuccess: true,
      message: message,
      user: user,
      accessToken: accessToken,
      sessionToken: sessionToken,
    );
  }
  
  factory AuthResult.error(String message) {
    return AuthResult._(
      isSuccess: false,
      message: message,
    );
  }
}

// OTP Registration Result class
class OTPRegistrationResult {
  final bool isSuccess;
  final String message;
  final String? email;
  final bool otpSent;
  final DateTime? expiresAt;
  
  OTPRegistrationResult._({
    required this.isSuccess,
    required this.message,
    this.email,
    this.otpSent = false,
    this.expiresAt,
  });
  
  factory OTPRegistrationResult.success({
    required String message,
    required String email,
    required bool otpSent,
    DateTime? expiresAt,
  }) {
    return OTPRegistrationResult._(
      isSuccess: true,
      message: message,
      email: email,
      otpSent: otpSent,
      expiresAt: expiresAt,
    );
  }
  
  factory OTPRegistrationResult.error(String message) {
    return OTPRegistrationResult._(
      isSuccess: false,
      message: message,
    );
  }
}

// OTP Result class
class OTPResult {
  final bool isSuccess;
  final String message;
  final DateTime? expiresAt;
  final int? attemptsRemaining;
  
  OTPResult._({
    required this.isSuccess,
    required this.message,
    this.expiresAt,
    this.attemptsRemaining,
  });
  
  factory OTPResult.success({
    required String message,
    DateTime? expiresAt,
  }) {
    return OTPResult._(
      isSuccess: true,
      message: message,
      expiresAt: expiresAt,
    );
  }
  
  factory OTPResult.error(String message, {int? attemptsRemaining}) {
    return OTPResult._(
      isSuccess: false,
      message: message,
      attemptsRemaining: attemptsRemaining,
    );
  }
}

// Pagination Info class
class PaginationInfo {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;
  
  PaginationInfo({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });
}

// Favorite Events Result class
class FavoriteEventsResult {
  final bool isSuccess;
  final String? message;
  final List<Event>? events;
  final PaginationInfo? pagination;
  
  FavoriteEventsResult._({
    required this.isSuccess,
    this.message,
    this.events,
    this.pagination,
  });
  
  factory FavoriteEventsResult.success({
    required List<Event> events,
    required PaginationInfo pagination,
  }) {
    return FavoriteEventsResult._(
      isSuccess: true,
      events: events,
      pagination: pagination,
    );
  }
  
  factory FavoriteEventsResult.error(String message) {
    return FavoriteEventsResult._(
      isSuccess: false,
      message: message,
    );
  }
}