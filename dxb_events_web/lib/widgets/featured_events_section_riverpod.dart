import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/event.dart';
import '../services/providers/featured_events_provider.dart';
import '../widgets/events/enhanced_event_card.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Featured Events section for the homepage using Riverpod
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
  int _currentPage = 0;
  
  @override
  void initState() {
    super.initState();
    // Initialize page controller with default viewport fraction
    // Start with a common default that will be updated based on screen size
    _pageController = PageController(viewportFraction: 0.35);
    
    // Load featured events only if not already loaded to prevent infinite loops
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(featuredEventsProvider);
      if (mounted && currentState.events.isEmpty && !currentState.isLoading) {
        ref.read(featuredEventsProvider.notifier).loadFeaturedEvents();
      }
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featuredEventsState = ref.watch(featuredEventsProvider);
    final featuredEventsNotifier = ref.read(featuredEventsProvider.notifier);

    return Container(
      padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showHeader) _buildHeader(context, featuredEventsState, featuredEventsNotifier),
          const SizedBox(height: 16),
          _buildContent(context, featuredEventsState, featuredEventsNotifier),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FeaturedEventsState state, FeaturedEventsNotifier notifier) {
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
                if (state.lastRefresh != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Updated ${_getTimeAgo(state.lastRefresh!)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildRefreshButton(state, notifier),
        ],
      ),
    );
  }

  Widget _buildRefreshButton(FeaturedEventsState state, FeaturedEventsNotifier notifier) {
    return IconButton(
      onPressed: state.isLoading ? null : () => notifier.refresh(),
      icon: AnimatedRotation(
        turns: state.isLoading ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 1000),
        child: Icon(
          Icons.refresh_rounded,
          color: state.isLoading ? AppColors.textTertiary : AppColors.dubaiTeal,
        ),
      ),
      tooltip: 'Refresh featured events',
    );
  }

  Widget _buildContent(BuildContext context, FeaturedEventsState state, FeaturedEventsNotifier notifier) {
    if (state.isLoading && !state.hasFeaturedEvents) {
      return _buildLoadingState();
    }

    if (state.error != null && !state.hasFeaturedEvents) {
      return _buildErrorState(state, notifier);
    }

    if (!state.hasFeaturedEvents) {
      return _buildEmptyState();
    }

    return _buildEventsGrid(context, state, notifier);
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

  Widget _buildErrorState(FeaturedEventsState state, FeaturedEventsNotifier notifier) {
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
            state.error ?? 'Something went wrong',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => notifier.refresh(),
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

  Widget _buildEventsGrid(BuildContext context, FeaturedEventsState state, FeaturedEventsNotifier notifier) {
    final events = state.events.take(widget.maxEventsToShow).toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    if (events.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Quick filters
        _buildQuickFilters(notifier),
        const SizedBox(height: 16),
        
        // Events display - carousel for all screen sizes for better optimization
        _buildUniversalCarousel(events, screenWidth),
        
        // Load more button if there are more events
        if (state.events.length > widget.maxEventsToShow) ...[
          const SizedBox(height: 24),
          _buildViewAllButton(context),
        ],
      ],
    );
  }

  Widget _buildQuickFilters(FeaturedEventsNotifier notifier) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Consumer(
            builder: (context, ref, child) {
              final todaysEvents = ref.watch(todaysFeaturedEventsProvider);
              return _buildFilterChip(
                'Today',
                todaysEvents.length,
                Icons.today_rounded,
                () => _showFilteredEvents(context, todaysEvents, 'Today\'s Events'),
              );
            },
          ),
          const SizedBox(width: 8),
          Consumer(
            builder: (context, ref, child) {
              final weekendEvents = ref.watch(weekendFeaturedEventsProvider);
              return _buildFilterChip(
                'Weekend',
                weekendEvents.length,
                Icons.weekend_rounded,
                () => _showFilteredEvents(context, weekendEvents, 'Weekend Events'),
              );
            },
          ),
          const SizedBox(width: 8),
          Consumer(
            builder: (context, ref, child) {
              final freeEvents = ref.watch(freeFeaturedEventsProvider);
              return _buildFilterChip(
                'Free',
                freeEvents.length,
                Icons.money_off_rounded,
                () => _showFilteredEvents(context, freeEvents, 'Free Events'),
              );
            },
          ),
          const SizedBox(width: 8),
          Consumer(
            builder: (context, ref, child) {
              final indoorEvents = ref.watch(indoorFeaturedEventsProvider);
              return _buildFilterChip(
                'Indoor',
                indoorEvents.length,
                Icons.home_rounded,
                () => _showFilteredEvents(context, indoorEvents, 'Indoor Events'),
              );
            },
          ),
          const SizedBox(width: 8),
          Consumer(
            builder: (context, ref, child) {
              final outdoorEvents = ref.watch(outdoorFeaturedEventsProvider);
              return _buildFilterChip(
                'Outdoor',
                outdoorEvents.length,
                Icons.nature_rounded,
                () => _showFilteredEvents(context, outdoorEvents, 'Outdoor Events'),
              );
            },
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event, int index) {
    return EnhancedEventCard(
      event: event,
      onTap: () {
        widget.onEventTap?.call(event);
      },
    );
  }
  
  List<Widget> _buildMobileCarousel(List<Event> events) {
    return [
      Container(
        height: 420, // Increased height for more content
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    child: _buildEventCard(event, index),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                events.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? AppColors.dubaiTeal
                        : AppColors.textTertiary.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }
  
  Widget _buildUniversalCarousel(List<Event> events, double screenWidth) {
    // Determine optimal height and viewport fraction based on screen size
    double carouselHeight;
    EdgeInsets cardMargin;
    double viewportFraction;
    
    if (screenWidth <= 480) {
      // Mobile phones - show 1 card
      carouselHeight = 500;
      cardMargin = const EdgeInsets.symmetric(horizontal: 8);
      viewportFraction = 0.9;
    } else if (screenWidth <= 768) {
      // Tablets and small screens - show 1.5 cards
      carouselHeight = 550;
      cardMargin = const EdgeInsets.symmetric(horizontal: 12);
      viewportFraction = 0.7;
    } else if (screenWidth <= 1200) {
      // Medium screens - show 2 cards
      carouselHeight = 600;
      cardMargin = const EdgeInsets.symmetric(horizontal: 16);
      viewportFraction = 0.5;
    } else {
      // Large screens - show 2.5 to 3 cards
      carouselHeight = 650;
      cardMargin = const EdgeInsets.symmetric(horizontal: 16);
      viewportFraction = 0.35; // Shows about 2.5-3 cards
    }
    
    // Rebuild PageController with new viewport fraction when screen size changes
    if (_pageController.viewportFraction != viewportFraction) {
      _pageController = PageController(
        viewportFraction: viewportFraction,
        initialPage: _currentPage,
      );
    }
    
    return Container(
      height: carouselHeight,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              padEnds: false, // Prevent padding at the beginning and end
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Container(
                  margin: cardMargin,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: EnhancedEventCard(
                      event: event,
                      showQualityMetrics: screenWidth > 768, // Hide quality metrics on small screens
                      showSocialMedia: screenWidth > 480, // Hide social media on very small screens
                      onTap: () => widget.onEventTap?.call(event),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Navigation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button
              IconButton(
                onPressed: _currentPage > 0
                    ? () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: _currentPage > 0
                      ? AppColors.dubaiTeal
                      : AppColors.textTertiary,
                ),
              ),
              // Page indicators
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    events.length,
                    (index) => Container(
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.dubaiTeal
                            : AppColors.textTertiary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ).take(10).toList(), // Limit indicators to 10 for space
                ),
              ),
              // Next button
              IconButton(
                onPressed: _currentPage < events.length - 1
                    ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _currentPage < events.length - 1
                      ? AppColors.dubaiTeal
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
          // Event counter
          Text(
            '${_currentPage + 1} of ${events.length}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsGridLayout(List<Event> events, bool isTablet, bool isDesktop) {
    int crossAxisCount;
    double childAspectRatio;
    
    // Responsive breakpoints aligned with main events list:
    // Carousel for tablets/mobile (800px and below), grid for desktop only
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Use carousel for tablets and mobile to avoid cramped layout
    if (screenWidth <= 800) {
      return Column(children: _buildMobileCarousel(events));
    }
    
    // Grid for desktop only
    if (screenWidth > 1400) {
      crossAxisCount = 4; // Large desktop: 4 cards
      childAspectRatio = 0.85;
    } else if (screenWidth > 1200) {
      crossAxisCount = 3; // Wide desktop: 3 cards
      childAspectRatio = 0.9;
    } else {
      crossAxisCount = 2; // Smaller desktop: 2 cards
      childAspectRatio = 0.85;
    }

    print('🔍 DEBUG: Grid config - columns: $crossAxisCount, aspectRatio: $childAspectRatio, screenWidth: $screenWidth');

    return Container(
      constraints: const BoxConstraints(minHeight: 400),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          print('🔍 DEBUG: Building card $index: ${event.title}');
          return _buildEventCard(event, index);
        },
      ),
    );
  }

  Widget _buildViewAllButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        // Navigate to all events page
        context.go('/events');
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