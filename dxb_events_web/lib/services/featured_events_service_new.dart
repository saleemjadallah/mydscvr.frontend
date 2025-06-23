import '../models/event.dart';
import '../models/api_response.dart';
import 'events_service.dart';

/// Simplified Featured Events Service that uses backend algorithm
class FeaturedEventsServiceNew {
  final EventsService _eventsService;
  
  FeaturedEventsServiceNew(this._eventsService);

  /// Get featured events from backend (uses enhanced server-side algorithm)
  Future<ApiResponse<List<Event>>> getFeaturedEvents({
    int limit = 12,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? environmentalFactors,
  }) async {
    try {
      print('🔄 FeaturedEventsService: Fetching featured events from backend...');
      print('🔄 FeaturedEventsService: Limit requested: $limit');
      
      // Use the backend featured events endpoint (with enhanced algorithm)
      final response = await _eventsService.getFeaturedEventsFromBackend(
        limit: limit,
      );

      print('🔄 FeaturedEventsService: Backend API response isSuccess: ${response.isSuccess}');
      
      if (response.isSuccess && response.data != null) {
        final featuredEvents = response.data!;
        print('✨ FeaturedEventsService: Backend returned ${featuredEvents.length} featured events');
        
        // Log the events we got from backend
        for (int i = 0; i < featuredEvents.length && i < 3; i++) {
          final event = featuredEvents[i];
          print('🎯   ${i + 1}. ${event.title} - Start: ${event.startDate}');
        }
        
        return ApiResponse.success(featuredEvents);
      } else {
        final error = response.error ?? 'Unknown error fetching featured events';
        print('🚨 FeaturedEventsService: Failed to fetch featured events from backend: $error');
        return ApiResponse.error('Failed to fetch featured events: $error');
      }
    } catch (e, stackTrace) {
      print('🚨 FeaturedEventsService: Critical error in getFeaturedEvents: $e');
      print('🚨 FeaturedEventsService: Stack trace: $stackTrace');
      return ApiResponse.error('Error fetching featured events: $e');
    }
  }
}