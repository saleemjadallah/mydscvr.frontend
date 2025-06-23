import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

/// Dio HTTP client configuration for DXB Events API
class DioConfig {
  static const String defaultBaseUrl = '/api'; // Netlify proxy to backend
  static const String localUrl = 'http://localhost:8000'; // For local development
  static const String productionUrl = 'https://mydscvr.xyz'; // Production backend
  static const String stagingUrl = 'http://3.29.102.4:8000'; // Staging backend
  
  /// Get the API base URL from environment variables
  static String getApiBaseUrl() {
    // Use compile-time constants for Flutter web compatibility
    const customApiUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    
    // If custom API URL is provided at compile time, use it
    if (customApiUrl.isNotEmpty) {
      print('🔧 DioConfig: Using environment API_BASE_URL: $customApiUrl');
      return customApiUrl;
    }
    
    // Check if we're running on mobile platforms (Android/iOS)
    if (!kIsWeb) {
      // For mobile platforms, we need absolute URLs
      // Default to production backend for mobile
      print('🔧 DioConfig: Mobile platform detected, using: $productionUrl');
      return productionUrl;
    }
    
    // For web platforms, check the current domain and use Netlify proxy
    try {
      if (Uri.base.host.contains('mydscvr.xyz') || Uri.base.host.contains('mydscvr.ai')) {
        print('🔧 DioConfig: Production domain detected, using Netlify proxy: /api');
        return '/api'; // Use Netlify proxy for CORS handling
      } else if (Uri.base.host.contains('localhost')) {
        print('🔧 DioConfig: Localhost detected, using: $localUrl');
        return localUrl;
      }
    } catch (e) {
      print('Error detecting environment: $e');
    }
    
    // For web development and other cases, use Netlify proxy
    print('🔧 DioConfig: Default fallback, using Netlify proxy: /api');
    return '/api'; // Use Netlify proxy for CORS handling
  }
  
  /// Create configured Dio instance with interceptors
  static Dio createDio({bool useLocalHost = false}) {
    final baseUrl = useLocalHost ? localUrl : getApiBaseUrl();
    
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      followRedirects: true,
      maxRedirects: 5,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    print('🌐 DioConfig initialized:');
    print('   Base URL: $baseUrl');
    print('   Use Local Host: $useLocalHost');

    // Add interceptors
    dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);

    return dio;
  }

  /// Create configured API client instance
  static ApiClient createApiClient() {
    // Always use environment-based URL configuration now
    final dio = createDio(useLocalHost: false);
    return ApiClient(dio);
  }
}

/// Authentication interceptor for automatic token management
class AuthInterceptor extends Interceptor {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth for login/register endpoints
    if (_isAuthEndpoint(options.path)) {
      return handler.next(options);
    }

    try {
      final accessToken = await _storage.read(key: 'access_token');
      
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    } catch (e) {
      print('Error reading access token: $e');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle token refresh on 401 errors
    if (err.response?.statusCode == 401 && !_isAuthEndpoint(err.requestOptions.path)) {
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the original request with new token
          final retryResponse = await _retryRequest(err.requestOptions);
          return handler.resolve(retryResponse);
        }
      } catch (e) {
        print('Token refresh failed: $e');
        // Clear stored tokens
        await _clearTokens();
      }
    }

    handler.next(err);
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') || 
           path.contains('/auth/register') || 
           path.contains('/auth/refresh');
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final dio = Dio();
      final response = await dio.post(
        '${DioConfig.getApiBaseUrl()}/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.write(key: 'access_token', value: data['access_token']);
        await _storage.write(key: 'refresh_token', value: data['refresh_token']);
        return true;
      }
    } catch (e) {
      print('Refresh token error: $e');
    }

    return false;
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final dio = Dio();
    final accessToken = await _storage.read(key: 'access_token');
    
    if (accessToken != null) {
      requestOptions.headers['Authorization'] = 'Bearer $accessToken';
    }

    return dio.request(
      requestOptions.path,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
    );
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }
}

/// Error handling interceptor for consistent error responses
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    ApiException apiException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        apiException = ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          type: ApiExceptionType.timeout,
          statusCode: null,
        );
        break;

      case DioExceptionType.badResponse:
        apiException = _handleResponseError(err);
        break;

      case DioExceptionType.cancel:
        apiException = ApiException(
          message: 'Request was cancelled',
          type: ApiExceptionType.cancel,
          statusCode: null,
        );
        break;

      case DioExceptionType.connectionError:
        apiException = ApiException(
          message: 'No internet connection. Please check your network.',
          type: ApiExceptionType.network,
          statusCode: null,
        );
        break;

      default:
        apiException = ApiException(
          message: err.message ?? 'An unexpected error occurred',
          type: ApiExceptionType.unknown,
          statusCode: err.response?.statusCode,
        );
    }

    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: apiException,
      type: err.type,
      response: err.response,
    ));
  }

  ApiException _handleResponseError(DioException err) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    String message = 'An error occurred';
    ApiExceptionType type = ApiExceptionType.server;

    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['detail'] ?? message;
    }

    switch (statusCode) {
      case 400:
        type = ApiExceptionType.badRequest;
        message = message.isNotEmpty ? message : 'Invalid request';
        break;
      case 401:
        type = ApiExceptionType.unauthorized;
        message = 'Please log in to continue';
        break;
      case 403:
        type = ApiExceptionType.forbidden;
        message = 'Access denied';
        break;
      case 404:
        type = ApiExceptionType.notFound;
        message = 'Resource not found';
        break;
      case 422:
        type = ApiExceptionType.validation;
        message = _extractValidationErrors(data);
        break;
      case 500:
        type = ApiExceptionType.server;
        message = 'Server error. Please try again later.';
        break;
      default:
        type = ApiExceptionType.server;
    }

    return ApiException(
      message: message,
      type: type,
      statusCode: statusCode,
    );
  }

  String _extractValidationErrors(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('detail')) {
      final detail = data['detail'];
      if (detail is List) {
        return detail
            .map((error) => error['msg'] ?? error.toString())
            .join(', ');
      }
    }
    return 'Validation error';
  }
}

/// Logging interceptor for debugging
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
    print('🚀 Headers: ${options.headers}');
    if (options.data != null) {
      print('🚀 Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print('✅ Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('❌ Message: ${err.message}');
    if (err.response?.data != null) {
      print('❌ Error Data: ${err.response?.data}');
    }
    handler.next(err);
  }
}

/// Custom API exception class
class ApiException implements Exception {
  final String message;
  final ApiExceptionType type;
  final int? statusCode;

  const ApiException({
    required this.message,
    required this.type,
    this.statusCode,
  });

  @override
  String toString() => 'ApiException: $message (${type.name})';
}

/// API exception types for better error handling
enum ApiExceptionType {
  network,
  timeout,
  server,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  validation,
  cancel,
  unknown,
} 