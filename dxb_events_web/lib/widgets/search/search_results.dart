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

class SearchResultsWidget extends ConsumerStatefulWidget {
  final VoidCallback? onLoadMore;
  final bool showFiltersBar;

  const SearchResultsWidget({
    super.key,
    this.onLoadMore,
    this.showFiltersBar = true,
  });

  @override
  ConsumerState<SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends ConsumerState<SearchResultsWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results header with filters
          if (widget.showFiltersBar)
            _buildResultsHeader(searchState),

          const SizedBox(height: 24),

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

          // Results list
          if (searchState.results.isNotEmpty)
            _buildResultsList(searchState),
        ],
      ),
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
          // Results count and query
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
              
              // Sort button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.arrowUpDown,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Sort',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
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

    if (filters.priceRange != null) {
      activeFilters.add(_buildFilterChip(
        '💰 ${filters.priceRange.toString()}',
        () => ref.read(searchProvider.notifier).clearFilter('priceRange'),
      ));
    }

    if (filters.ageRange != null) {
      activeFilters.add(_buildFilterChip(
        '👶 ${filters.ageRange.toString()}',
        () => ref.read(searchProvider.notifier).clearFilter('ageRange'),
      ));
    }

    if (filters.familyFriendlyOnly) {
      activeFilters.add(_buildFilterChip(
        '👨‍👩‍👧‍👦 Family Friendly',
        () => ref.read(searchProvider.notifier).updateFilters(
          filters.copyWith(familyFriendlyOnly: false),
        ),
      ));
    }

    if (filters.freeEventsOnly) {
      activeFilters.add(_buildFilterChip(
        '🎁 Free Events',
        () => ref.read(searchProvider.notifier).updateFilters(
          filters.copyWith(freeEventsOnly: false),
        ),
      ));
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
            // Animated loading indicator
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
            const SizedBox(height: 24),
            
            // Suggestions
            Text(
              'Try searching for:',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Dubai Aquarium',
                'Family Fun',
                'Water Parks',
                'Cultural Events',
              ].map((suggestion) {
                return GestureDetector(
                  onTap: () {
                    ref.read(searchProvider.notifier).search(suggestion);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.dubaiTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.dubaiTeal.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      suggestion,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.dubaiTeal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ref.read(searchProvider.notifier).clearResults();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Text(
                    'Clear Search',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to categories or filters
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dubaiTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Browse Categories',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: Offset(0.8, 0.8));
  }

  Widget _buildResultsList(SearchState searchState) {
    return Column(
      children: [
        // Results grid/list
        _buildEventsList(searchState.results),
        
        // Load more button or loading indicator
        if (searchState.hasMore || searchState.isLoadingMore)
          _buildLoadMoreSection(searchState),
      ],
    );
  }

  Widget _buildEventsList(List<Event> events) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800;

    if (isLargeScreen) {
      // Large screen: 3 columns
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.75,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return EventCard(
            event: events[index],
            isCompact: false,
          ).animate().slideY(
            delay: Duration(milliseconds: index * 100),
            duration: 400.ms,
            begin: 0.3,
            curve: Curves.easeOut,
          ).fadeIn();
        },
      );
    } else if (isMediumScreen) {
      // Medium screen: 2 columns
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return EventCard(
            event: events[index],
            isCompact: true,
          ).animate().slideY(
            delay: Duration(milliseconds: index * 100),
            duration: 400.ms,
            begin: 0.3,
            curve: Curves.easeOut,
          ).fadeIn();
        },
      );
    } else {
      // Small screen: List view
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: EventCard(
              event: events[index],
              isCompact: true,
              layout: EventCardLayout.horizontal,
            ),
          ).animate().slideX(
            delay: Duration(milliseconds: index * 100),
            duration: 400.ms,
            begin: 0.3,
            curve: Curves.easeOut,
          ).fadeIn();
        },
      );
    }
  }

  Widget _buildLoadMoreSection(SearchState searchState) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: searchState.isLoadingMore
            ? Row(
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
              )
            : ElevatedButton(
                onPressed: widget.onLoadMore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dubaiTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Load More Events',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      LucideIcons.chevronDown,
                      size: 16,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
} 