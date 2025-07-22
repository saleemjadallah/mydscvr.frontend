import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/event.dart';
import '../services/events_service.dart';
import '../models/api_response.dart';
import '../widgets/events/enhanced_event_card.dart';
import '../core/animations/fade_in_slide_up.dart';
import '../core/theme/app_text_styles.dart';
import '../utils/image_utils.dart';
import '../providers/featured_events_provider.dart';

/// Featured Events section for the homepage
class FeaturedEventsSection extends ConsumerStatefulWidget {
  final bool showHeader;
  final int maxEventsToShow;
  final EdgeInsets? padding;
  final Function(Event)? onEventTap;

  const FeaturedEventsSection({
    Key? key,
    this.showHeader = true,
    this.maxEventsToShow = 12,
    this.padding,
    this.onEventTap,
  }) : super(key: key);

  @override
  ConsumerState<FeaturedEventsSection> createState() => _FeaturedEventsSectionState();
}

class _FeaturedEventsSectionState extends ConsumerState<FeaturedEventsSection> {
  @override
  void initState() {
    super.initState();
    // Load featured events when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(featuredEventsProvider.notifier).loadFeaturedEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeaturedEventsProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showHeader) _buildHeader(context, provider),
              const SizedBox(height: 16),
              _buildContent(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, FeaturedEventsProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.dubaiGold,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Featured Events',
                      style: AppTextStyles.headingLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Handpicked experiences perfect for Dubai families',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (provider.lastRefresh != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Updated ${_getTimeAgo(provider.lastRefresh!)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildRefreshButton(provider),
        ],
      ),
    );
  }

  Widget _buildRefreshButton(FeaturedEventsProvider provider) {
    return IconButton(
      onPressed: provider.isLoading ? null : () => provider.refresh(),
      icon: AnimatedRotation(
        turns: provider.isLoading ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 1000),
        child: Icon(
          Icons.refresh_rounded,
          color: provider.isLoading ? AppColors.textTertiary : AppColors.dubaiTeal,
        ),
      ),
      tooltip: 'Refresh featured events',
    );
  }

  Widget _buildContent(BuildContext context, FeaturedEventsProvider provider) {
    if (provider.isLoading && !provider.hasFeaturedEvents) {
      return _buildLoadingState();
    }

    if (provider.error != null && !provider.hasFeaturedEvents) {
      return _buildErrorState(provider);
    }

    if (!provider.hasFeaturedEvents) {
      return _buildEmptyState();
    }

    return _buildEventsGrid(context, provider);
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.dubaiTeal),
          ),
          SizedBox(height: 16),
          Text(
            'Finding the best events for you...',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(FeaturedEventsProvider provider) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load featured events',
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.error ?? 'Something went wrong',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => provider.refresh(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dubaiTeal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No featured events found',
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for exciting new events',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventsGrid(BuildContext context, FeaturedEventsProvider provider) {
    final events = provider.featuredEvents.take(widget.maxEventsToShow).toList();

    return Column(
      children: [
        // Quick filters
        _buildQuickFilters(provider),
        const SizedBox(height: 16),
        
        // Desktop grid with fixed 4 columns
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.85,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _buildEventCard(event, index);
          },
        ),
        
        // Load more button if there are more events
        if (provider.featuredEvents.length > widget.maxEventsToShow) ...[
          const SizedBox(height: 24),
          _buildViewAllButton(context),
        ],
      ],
    );
  }




  Widget _buildQuickFilters(FeaturedEventsProvider provider) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            'Today',
            provider.getTodaysFeaturedEvents().length,
            Icons.today_rounded,
            () => _showFilteredEvents(context, provider.getTodaysFeaturedEvents(), 'Today\'s Events'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Weekend',
            provider.getWeekendFeaturedEvents().length,
            Icons.weekend_rounded,
            () => _showFilteredEvents(context, provider.getWeekendFeaturedEvents(), 'Weekend Events'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Free',
            provider.getFreeFeaturedEvents().length,
            Icons.money_off_rounded,
            () => _showFilteredEvents(context, provider.getFreeFeaturedEvents(), 'Free Events'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Indoor',
            provider.getIndoorFeaturedEvents().length,
            Icons.home_rounded,
            () => _showFilteredEvents(context, provider.getIndoorFeaturedEvents(), 'Indoor Events'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Outdoor',
            provider.getOutdoorFeaturedEvents().length,
            Icons.nature_rounded,
            () => _showFilteredEvents(context, provider.getOutdoorFeaturedEvents(), 'Outdoor Events'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: count > 0 ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12, 
          vertical: 8
        ),
        decoration: BoxDecoration(
          color: count > 0 ? AppColors.dubaiTeal.withOpacity(0.1) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: count > 0 ? AppColors.dubaiTeal : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: count > 0 ? AppColors.dubaiTeal : AppColors.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              '$label ($count)',
              style: AppTextStyles.bodySmall.copyWith(
                color: count > 0 ? AppColors.dubaiTeal : AppColors.textTertiary,
                fontWeight: count > 0 ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event, int index) {
    return Hero(
      tag: 'featured_event_${event.id}',
      child: GestureDetector(
        onTap: () => widget.onEventTap?.call(event),
        child: EnhancedEventCard(
          event: event,
          onTap: () => widget.onEventTap?.call(event),
        ),
      ),
    );
  }

  Widget _buildViewAllButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        // Navigate to all events page
        Navigator.of(context).pushNamed('/events');
      },
      icon: const Icon(Icons.arrow_forward_rounded),
      label: const Text('View All Featured Events'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.dubaiTeal,
        side: const BorderSide(color: AppColors.dubaiTeal),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  void _showFilteredEvents(BuildContext context, List<Event> events, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => FilteredEventsSheet(
          title: title,
          events: events,
          scrollController: scrollController,
          onEventTap: widget.onEventTap,
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Bottom sheet for displaying filtered events
class FilteredEventsSheet extends StatelessWidget {
  final String title;
  final List<Event> events;
  final ScrollController scrollController;
  final Function(Event)? onEventTap;

  const FilteredEventsSheet({
    Key? key,
    required this.title,
    required this.events,
    required this.scrollController,
    this.onEventTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${events.length} events',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Events list
          Expanded(
            child: events.isEmpty
                ? const Center(
                    child: Text(
                      'No events found',
                      style: AppTextStyles.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: EnhancedEventCard(
                          event: event,
                          onTap: () {
                            Navigator.pop(context);
                            onEventTap?.call(event);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 