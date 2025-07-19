import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../models/event.dart';
import '../../providers/search_provider.dart';
import '../../widgets/events/event_card.dart';

class SearchResultsCarousel extends ConsumerStatefulWidget {
  final VoidCallback? onLoadMore;
  final bool showFiltersBar;

  const SearchResultsCarousel({
    super.key,
    this.onLoadMore,
    this.showFiltersBar = true,
  });

  @override
  ConsumerState<SearchResultsCarousel> createState() => _SearchResultsCarouselState();
}

class _SearchResultsCarouselState extends ConsumerState<SearchResultsCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: _getViewportFraction(),
    );
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  double _getViewportFraction() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth <= 480) {
      return 0.9; // Mobile phones - show 1 card
    } else if (screenWidth <= 768) {
      return 0.7; // Tablets - show 1.5 cards
    } else if (screenWidth <= 1200) {
      return 0.5; // Medium screens - show 2 cards
    } else {
      return 0.35; // Large screens - show 2.5-3 cards
    }
  }

  void _onPageChanged() {
    final searchState = ref.read(searchProvider);
    final currentPage = _pageController.page ?? 0;
    final totalEvents = searchState.results.length;
    
    // Update current index
    if (currentPage.round() != _currentIndex) {
      setState(() {
        _currentIndex = currentPage.round();
      });
    }
    
    // Auto-load more when reaching near the end (80% through)
    if (currentPage >= totalEvents * 0.8 && 
        searchState.hasMore && 
        !searchState.isLoadingMore && 
        !_isLoadingMore) {
      _loadMore();
    }
  }

  void _loadMore() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    // Call the load more function
    widget.onLoadMore?.call();
    
    // Wait a bit to prevent rapid calls
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results header with filters
        if (widget.showFiltersBar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: _buildResultsHeader(searchState),
          ),

        // Loading state
        if (searchState.isLoading && searchState.results.isEmpty)
          _buildLoadingState(),

        // Error state
        if (searchState.error != null)
          _buildErrorState(searchState.error!),

        // No results state
        if (!searchState.isLoading && 
            searchState.results.isEmpty && 
            searchState.hasQuery)
          _buildNoResultsState(searchState.query),

        // Results carousel
        if (searchState.results.isNotEmpty)
          _buildResultsCarousel(searchState, screenWidth),
      ],
    );
  }

  Widget _buildResultsHeader(SearchState searchState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.sunsetGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.dubaiGold.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${searchState.totalCount} Events Found',
                      style: GoogleFonts.comfortaa(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (searchState.hasQuery)
                      Text(
                        'for "${searchState.query}"',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Event counter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${searchState.results.length}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          // Active filters
          if (searchState.hasActiveFilters) ...[
            const SizedBox(height: 16),
            _buildActiveFilters(searchState.filters),
          ],
        ],
      ),
    ).animate().slideY(
      duration: 400.ms,
      begin: -0.3,
      curve: Curves.easeOut,
    ).fadeIn();
  }

  Widget _buildResultsCarousel(SearchState searchState, double screenWidth) {
    final events = searchState.results;
    
    // Determine carousel height based on screen size
    double carouselHeight;
    if (screenWidth <= 480) {
      carouselHeight = 500;
    } else if (screenWidth <= 768) {
      carouselHeight = 550;
    } else if (screenWidth <= 1200) {
      carouselHeight = 600;
    } else {
      carouselHeight = 650;
    }

    return Column(
      children: [
        // Carousel container
        Container(
          height: carouselHeight,
          child: Stack(
            children: [
              // Events carousel
              PageView.builder(
                controller: _pageController,
                padEnds: false,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: EventCard(
                      event: events[index],
                      isCompact: false,
                    ).animate().fadeIn(
                      delay: Duration(milliseconds: index * 50),
                      duration: 400.ms,
                    ),
                  );
                },
              ),
              
              // Navigation arrows (only show if more than 1 event)
              if (events.length > 1) ...[
                // Previous button
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildNavButton(
                      LucideIcons.chevronLeft,
                      _currentIndex > 0,
                      () => _previousEvent(),
                    ),
                  ),
                ),
                
                // Next button
                Positioned(
                  right: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildNavButton(
                      LucideIcons.chevronRight,
                      _currentIndex < events.length - 1,
                      () => _nextEvent(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Page indicators
        if (events.length > 1)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                events.length > 20 ? 20 : events.length, // Limit indicators to 20
                (index) {
                  // For long lists, show indicators for current area only
                  if (events.length > 20) {
                    final start = (_currentIndex - 10).clamp(0, events.length - 20);
                    final adjustedIndex = start + index;
                    return _buildIndicator(adjustedIndex, adjustedIndex == _currentIndex);
                  }
                  return _buildIndicator(index, index == _currentIndex);
                },
              ),
            ),
          ),

        // Loading more indicator
        if (searchState.isLoadingMore || _isLoadingMore)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.dubaiTeal),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loading more events...',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, bool isEnabled, VoidCallback onPressed) {
    return AnimatedOpacity(
      opacity: isEnabled ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: isEnabled ? onPressed : null,
          icon: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildIndicator(int index, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive 
            ? AppColors.dubaiTeal 
            : AppColors.dubaiTeal.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _previousEvent() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextEvent() {
    if (_currentIndex < ref.read(searchProvider).results.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Reuse the existing helper methods from SearchResultsWidget
  Widget _buildActiveFilters(SearchFilters filters) {
    final activeFilters = <Widget>[];

    if (filters.category != null) {
      final category = EventCategory.allCategories
          .firstWhere((cat) => cat.id == filters.category);
      activeFilters.add(_buildFilterChip(
        '${category.emoji} ${category.name}',
        () => ref.read(searchProvider.notifier).clearFilter('category'),
      ));
    }

    if (filters.areas.isNotEmpty) {
      for (final areaId in filters.areas.take(2)) {
        final area = DubaiArea.allAreas
            .firstWhere((area) => area.id == areaId);
        activeFilters.add(_buildFilterChip(
          '${area.emoji} ${area.displayName}',
          () => ref.read(searchProvider.notifier).clearFilter('areas'),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Active Filters:',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => ref.read(searchProvider.notifier).clearAllFilters(),
              child: Text(
                'Clear All',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: activeFilters,
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              LucideIcons.x,
              size: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.dubaiGold),
                    strokeWidth: 3,
                  ),
                ),
                Icon(
                  LucideIcons.search,
                  color: AppColors.dubaiGold,
                  size: 24,
                ),
              ],
            ).animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 2000.ms),
            
            const SizedBox(height: 24),
            Text(
              'Searching Dubai Events',
              style: GoogleFonts.comfortaa(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Finding the best family activities for you...',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                LucideIcons.alertCircle,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Search Error',
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Something went wrong while searching for events.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final searchState = ref.read(searchProvider);
                ref.read(searchProvider.notifier).search(searchState.query);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dubaiTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: Offset(0.8, 0.8));
  }

  Widget _buildNoResultsState(String query) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.tealGradient.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                LucideIcons.searchX,
                size: 48,
                color: AppColors.dubaiTeal,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Events Found',
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find any events matching "$query".\nTry adjusting your search or filters.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: Offset(0.8, 0.8));
  }
}