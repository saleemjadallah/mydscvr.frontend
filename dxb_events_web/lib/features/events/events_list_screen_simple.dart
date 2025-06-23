import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../models/event.dart';
import '../../services/events_service.dart';
import '../../widgets/common/breadcrumb_navigation.dart';
import '../../widgets/events/event_card_simple.dart';

class EventsListScreenSimple extends ConsumerStatefulWidget {
  final String? category;
  final String? searchQuery;
  final String? location;

  const EventsListScreenSimple({
    super.key,
    this.category,
    this.searchQuery,
    this.location,
  });

  @override
  ConsumerState<EventsListScreenSimple> createState() => _EventsListScreenSimpleState();
}

class _EventsListScreenSimpleState extends ConsumerState<EventsListScreenSimple> {
  List<Event> events = [];
  bool isLoading = true;
  String? errorMessage;
  late final EventsService _eventsService;

  @override
  void initState() {
    super.initState();
    _eventsService = EventsService();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _eventsService.getEvents(
        category: widget.category,
        location: widget.location,
        perPage: 50, // Load more events
      );

      if (response.isSuccess) {
        setState(() {
          events = response.data ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response.error ?? 'Failed to load events';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred: $e';
        isLoading = false;
      });
    }
  }

  List<Event> get filteredEvents {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      return events;
    }
    
    final query = widget.searchQuery!.toLowerCase();
    return events.where((event) {
      return event.title.toLowerCase().contains(query) ||
             event.description.toLowerCase().contains(query) ||
             event.category.toLowerCase().contains(query) ||
             event.venue.area.toLowerCase().contains(query) ||
             event.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayEvents = filteredEvents;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Breadcrumb navigation
          BreadcrumbNavigation(
            items: BreadcrumbNavigation.forAllEvents(),
          ),
          
          // Title
          Container(
            padding: const EdgeInsets.all(24),
            child: Text(
              isLoading 
                  ? 'Loading Events...'
                  : 'All Events (${displayEvents.length} events)',
              style: GoogleFonts.comfortaa(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          // Content area
          Expanded(
            child: _buildContent(displayEvents),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<Event> displayEvents) {
    // Loading state
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load events',
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: GoogleFonts.comfortaa(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadEvents,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (displayEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No events found',
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or check back later',
              style: GoogleFonts.comfortaa(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Events grid
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: displayEvents.length,
      itemBuilder: (context, index) {
        final event = displayEvents[index];
        return EventCardSimple(
          event: event,
          onTap: () {
            // Navigate to full event details page using Go Router
            context.go('/event/${event.id}');
          },
        );
      },
    );
  }
} 