import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/dio_config.dart';

/// Provider for API client instance
/// Automatically configured with Dio interceptors for auth, error handling, and logging
final apiClientProvider = Provider<ApiClient>((ref) {
  return DioConfig.createApiClient();
});

/// Provider for checking if we're in development mode
final isDevelopmentProvider = Provider<bool>((ref) {
  return const bool.fromEnvironment('dart.vm.product') == false;
});

/// Provider for API base URL
final apiBaseUrlProvider = Provider<String>((ref) {
  return DioConfig.getApiBaseUrl();
});

/// Provider for checking if using localhost
final useLocalHostProvider = StateProvider<bool>((ref) => false); 