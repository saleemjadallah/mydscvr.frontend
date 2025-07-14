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
import '../widgets/events/event_card_enhanced.dart';
import '../core/animations/fade_in_slide_up.dart';
import '../core/theme/app_text_styles.dart';
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
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Load featured events when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(featuredEventsProvider.notifier).loadFeaturedEvents();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeaturedEventsProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 24.0),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768; // Increased from 600 to 768 to include mobile browsers
    final isTablet = screenWidth <= 1200 && screenWidth > 768; // Adjusted range

    return Column(
      children: [
        // Quick filters
        _buildQuickFilters(provider),
        const SizedBox(height: 16),
        
        // Events display - carousel for mobile, grid for larger screens
        if (isMobile) 
          _buildMobileCarousel(context, events)
        else if (isTablet)
          _buildTabletGrid(context, events)
        else
          _buildDesktopGrid(context, events),
        
        // Load more button if there are more events
        if (provider.featuredEvents.length > widget.maxEventsToShow) ...[
          const SizedBox(height: 24),
          _buildViewAllButton(context),
        ],
      ],
    );
  }

  Widget _buildMobileCarousel(BuildContext context, List<Event> events) {
    if (events.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 480, // Optimized height for mobile
      child: Column(
        children: [
          // Main carousel
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: events.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildMobileEventCard(events[index]),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Navigation controls and progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button
              IconButton(
                onPressed: _currentIndex > 0 
                    ? () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                    : null,
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: _currentIndex > 0 
                      ? AppColors.dubaiTeal 
                      : AppColors.textTertiary,
                ),
              ),
              
              // Progress indicators
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    events.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: index == _currentIndex ? 24 : 8,
                      decoration: BoxDecoration(
                        color: index == _currentIndex 
                            ? AppColors.dubaiTeal 
                            : AppColors.textTertiary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Next button
              IconButton(
                onPressed: _currentIndex < events.length - 1 
                    ? () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                    : null,
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _currentIndex < events.length - 1 
                      ? AppColors.dubaiTeal 
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
          
          // Counter
          Text(
            '${_currentIndex + 1} of ${events.length}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileEventCard(Event event) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              height: 200,
              width: double.infinity,
              child: Image.network(
                event.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.oceanGradient,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.event,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Event details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: AppTextStyles.headingSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: event.isFree 
                              ? AppColors.dubaiTeal.withOpacity(0.1)
                              : AppColors.dubaiGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.displayPrice,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: event.isFree ? AppColors.dubaiTeal : AppColors.dubaiGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Date and time
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _formatEventDateTime(event),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${event.venue.name} • ${event.venue.area}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Age range and category
                  Row(
                    children: [
                      Icon(
                        Icons.people_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        event.ageRange,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.dubaiTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatCategory(event.category),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.dubaiTeal,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description
                  Expanded(
                    child: Text(
                      event.displaySummary,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => widget.onEventTap?.call(event),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dubaiTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletGrid(BuildContext context, List<Event> events) {
    // Use responsive logic aligned with main events list: carousel for 800px and below
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Switch to carousel for tablets and mobile (800px and below)
    if (screenWidth <= 800) {
      return _buildMobileCarousel(context, events);
    }
    
    // Grid only for desktop
    int crossAxisCount;
    if (screenWidth > 1200) {
      crossAxisCount = 3; // Only use 3 columns on very wide displays
    } else {
      crossAxisCount = 2; // 2 columns for smaller desktop
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event, index);
      },
    );
  }

  Widget _buildDesktopGrid(BuildContext context, List<Event> events) {
    // Use improved responsive logic for desktop
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1400 ? 4 : 3; // 4 columns only on very large screens
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event, index);
      },
    );
  }

  String _formatEventDateTime(Event event) {
    // Format the date and time for mobile display
    final now = DateTime.now();
    final eventDate = event.startDate;
    
    if (eventDate.year == now.year && 
        eventDate.month == now.month && 
        eventDate.day == now.day) {
      return 'Today at ${_formatTime(eventDate)}';
    } else if (eventDate.year == now.year && 
               eventDate.month == now.month && 
               eventDate.day == now.day + 1) {
      return 'Tomorrow at ${_formatTime(eventDate)}';
    } else {
      return '${_formatDate(eventDate)} at ${_formatTime(eventDate)}';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatCategory(String category) {
    return category.replaceAll('_', ' ').split(' ').map((word) => 
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
    ).join(' ');
  }

  Widget _buildQuickFilters(FeaturedEventsProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;
    
    return Container(
      height: isMobile ? 36 : 40, // Slightly smaller height on mobile
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;
    
    return InkWell(
      onTap: count > 0 ? onTap : null,
      borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 12, 
          vertical: isMobile ? 6 : 8
        ),
        decoration: BoxDecoration(
          color: count > 0 ? AppColors.dubaiTeal.withOpacity(0.1) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
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
              size: isMobile ? 14 : 16,
              color: count > 0 ? AppColors.dubaiTeal : AppColors.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              '$label ($count)',
              style: AppTextStyles.bodySmall.copyWith(
                color: count > 0 ? AppColors.dubaiTeal : AppColors.textTertiary,
                fontWeight: count > 0 ? FontWeight.w600 : FontWeight.normal,
                fontSize: isMobile ? 11 : 12, // Smaller text on mobile
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
        child: EventCardEnhanced(
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
                        child: EventCard(
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