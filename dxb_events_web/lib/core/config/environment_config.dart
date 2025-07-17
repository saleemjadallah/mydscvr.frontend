/// Environment configuration for DXB Events Frontend
/// Handles environment variables and build-time constants
class EnvironmentConfig {
  // Google OAuth Configuration
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );

  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mydscvr.xyz',
  );

  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://mydscvr.xyz',
  );

  static const String dataCollectionUrl = String.fromEnvironment(
    'DATA_COLLECTION_URL',
    defaultValue: 'https://mydscvr.xyz',
  );

  // Fallback URLs
  static const String fallbackApiUrl = String.fromEnvironment(
    'FALLBACK_API_URL',
    defaultValue: 'http://3.29.102.4:8000',
  );

  static const String fallbackDataUrl = String.fromEnvironment(
    'FALLBACK_DATA_URL',
    defaultValue: 'http://3.29.102.4:8001',
  );

  // Development URLs
  static const String devApiUrl = String.fromEnvironment(
    'DEV_API_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String devDataUrl = String.fromEnvironment(
    'DEV_DATA_URL',
    defaultValue: 'http://localhost:8001',
  );

  // Build Configuration
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'production',
  );

  static const bool enableLogs = bool.fromEnvironment(
    'ENABLE_LOGS',
    defaultValue: false,
  );

  static const bool enablePerformanceOverlay = bool.fromEnvironment(
    'ENABLE_PERFORMANCE_OVERLAY',
    defaultValue: false,
  );

  // Analytics Configuration
  static const String gaTrackingId = String.fromEnvironment(
    'GA_TRACKING_ID',
    defaultValue: '',
  );

  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );

  static const String firebaseSiteId = String.fromEnvironment(
    'FIREBASE_SITE_ID',
    defaultValue: '',
  );

  // Domain Configuration
  static const String customDomain = String.fromEnvironment(
    'CUSTOM_DOMAIN',
    defaultValue: 'mydscvr.ai',
  );

  static const String cdnUrl = String.fromEnvironment(
    'CDN_URL',
    defaultValue: 'https://mydscvr.ai',
  );

  // Security Configuration
  static const String cspPolicy = String.fromEnvironment(
    'CSP_POLICY',
    defaultValue: "default-src 'self'; script-src 'self' 'unsafe-inline' https://apis.google.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https: blob:; font-src 'self' https://fonts.gstatic.com; connect-src 'self' https://mydscvr.xyz wss:",
  );

  // Error Monitoring
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  static const String logLevel = String.fromEnvironment(
    'LOG_LEVEL',
    defaultValue: 'info',
  );

  // Helper methods
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isProduction => environment == 'production';
  static bool get isTesting => environment == 'testing';

  /// Get the appropriate API base URL based on environment
  static String getApiBaseUrl() {
    if (isDevelopment) {
      return devApiUrl;
    } else if (isStaging || isTesting) {
      return fallbackApiUrl;
    } else {
      return apiBaseUrl;
    }
  }

  /// Get the appropriate data collection URL based on environment
  static String getDataCollectionUrl() {
    if (isDevelopment) {
      return devDataUrl;
    } else if (isStaging || isTesting) {
      return fallbackDataUrl;
    } else {
      return dataCollectionUrl;
    }
  }

  /// Check if analytics should be enabled
  static bool get shouldEnableAnalytics {
    return isProduction && gaTrackingId.isNotEmpty;
  }

  /// Check if error monitoring should be enabled
  static bool get shouldEnableErrorMonitoring {
    return (isProduction || isStaging) && sentryDsn.isNotEmpty;
  }

  /// Print current configuration (for debugging)
  static void printConfig() {
    // Production builds should not expose configuration details
    if (enableLogs && isDevelopment) {
      print('Environment Configuration:');
      print('   Environment: $environment');
      print('   API Base URL: ${getApiBaseUrl()}');
      print('   Data Collection URL: ${getDataCollectionUrl()}');
      print('   Enable Logs: $enableLogs');
      print('   Enable Performance Overlay: $enablePerformanceOverlay');
    }
  }
}