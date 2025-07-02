import 'environment_config.dart';

/// API Configuration for DXB Events
class ApiConfig {
  static String get baseUrl => EnvironmentConfig.getApiBaseUrl();
  static const String apiVersion = 'v1';
  
  // Enhanced API endpoints for new features
  static const String eventsFilteredSearch = '/events/search/filtered';
  static const String eventsAdvanced = '/events/advanced';
  static const String eventsQuality = '/events/quality';
  static const String eventsSocial = '/events/social';
  static const String eventsTrending = '/events/trending';
  static const String eventsRecommendations = '/events/recommendations';
  static const String eventsExtract = '/events/extract';
  static const String eventsQualityStats = '/events/quality/stats';
}