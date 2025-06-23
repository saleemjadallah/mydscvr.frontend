import 'environment_config.dart';

/// API Configuration for DXB Events
class ApiConfig {
  static String get baseUrl => EnvironmentConfig.getApiBaseUrl();
  static const String apiVersion = 'v1';
  
  // Enhanced API endpoints for new features
  static const String eventsFilteredSearch = '/api/events/search/filtered';
  static const String eventsAdvanced = '/api/events/advanced';
  static const String eventsQuality = '/api/events/quality';
  static const String eventsSocial = '/api/events/social';
  static const String eventsTrending = '/api/events/trending';
  static const String eventsRecommendations = '/api/events/recommendations';
  static const String eventsExtract = '/api/events/extract';
  static const String eventsQualityStats = '/api/events/quality/stats';
}