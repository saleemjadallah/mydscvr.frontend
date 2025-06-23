import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Core imports
import '../../core/constants/app_colors.dart';
import '../../core/themes/app_typography.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../core/widgets/curved_container.dart';
import '../../core/widgets/dubai_app_bar.dart';

// Provider imports - FIX: Use correct provider path
import '../../providers/search_provider.dart';

// Widget imports
import '../../widgets/search/search_bar_widget.dart';
import '../../widgets/search/search_filters.dart';
import '../../widgets/search/search_results.dart';
import '../../widgets/search/category_browser.dart';
import '../../widgets/search/search_suggestions.dart';

/// Advanced search screen for Dubai family events
class AdvancedSearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  final String? initialCategory;
  
  const AdvancedSearchScreen({
    super.key,
    this.initialQuery,
    this.initialCategory,
  });

  @override
  ConsumerState<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late AnimationController _filterAnimationController;
  bool _showFilters = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize search if there's an initial query
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery?.isNotEmpty == true) {
        ref.read(searchProvider.notifier).search(widget.initialQuery!);
      }
      if (widget.initialCategory?.isNotEmpty == true) {
        ref.read(searchProvider.notifier).searchByCategory(widget.initialCategory!);
      }
      _animationController.forward();
    });

    // Listen for scroll to show/hide floating search
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_showFilters) {
        // Could show floating search bar here
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _filterAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final activeFiltersCount = ref.watch(activeFiltersCountProvider);

    // Debug: Print search state to help with debugging
    print('Search state - query: "${searchState.query}", hasQuery: ${searchState.hasQuery}, suggestions: ${searchState.suggestions.length}, showSuggestions: ${searchState.showSuggestions}');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Beautiful header with search
          _buildSearchHeader(activeFiltersCount),
          
          // Show different content based on search state
          if (searchState.suggestions.isNotEmpty && !searchState.hasResults)
            ..._buildSearchSuggestions()
          else if (searchState.hasResults || searchState.isLoading)
            ..._buildSearchResults()
          else
            ..._buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(int activeFiltersCount) {
    return SliverToBoxAdapter(
      child: CurvedContainer(
        gradient: AppColors.sunsetGradient,
        curveHeight: 40,
        curvePosition: CurvePosition.bottom,
        height: _showFilters ? 300 : 200,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LucideIcons.arrowLeft,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Search Dubai Events',
                        style: GoogleFonts.comfortaa(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ).animate().slideX(
                  duration: 600.ms,
                  begin: -1,
                  curve: Curves.easeOut,
                ),

                const SizedBox(height: 24),

                // Search bar
                SearchBarWidget(
                  controller: _searchController,
                  onChanged: (query) {
                    ref.read(searchProvider.notifier).updateQuery(query);
                  },
                  onSubmitted: (query) {
                    if (query.isNotEmpty) {
                      ref.read(searchProvider.notifier).search(query);
                    }
                  },
                  onFilterTap: _toggleFilters,
                  activeFiltersCount: activeFiltersCount,
                ).animate().slideY(
                  duration: 600.ms,
                  begin: 1,
                  curve: Curves.easeOut,
                  delay: 200.ms,
                ),

                // Filters panel (expandable)
                if (_showFilters) ...[
                  const SizedBox(height: 16),
                  SearchFiltersWidget(
                    onFiltersChanged: (filters) {
                      ref.read(searchProvider.notifier).updateFilters(filters);
                    },
                  ).animate(controller: _filterAnimationController)
                    .slideY(begin: -0.5, curve: Curves.easeOut)
                    .fadeIn(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEmptyState() {
    return [
      // Quick categories
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Popular Categories',
                style: GoogleFonts.comfortaa(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().slideX(
                duration: 600.ms,
                begin: -1,
                curve: Curves.easeOut,
                delay: 400.ms,
              ),
              
              const SizedBox(height: 16),
              
              CategoryBrowserWidget().animate().slideY(
                duration: 600.ms,
                begin: 1,
                curve: Curves.easeOut,
                delay: 600.ms,
              ),
            ],
          ),
        ),
      ),

      // Popular areas
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Popular Areas',
                style: GoogleFonts.comfortaa(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().slideX(
                duration: 600.ms,
                begin: -1,
                curve: Curves.easeOut,
                delay: 800.ms,
              ),
              
              const SizedBox(height: 16),
              
              _buildPopularAreas().animate().slideY(
                duration: 600.ms,
                begin: 1,
                curve: Curves.easeOut,
                delay: 1000.ms,
              ),
            ],
          ),
        ),
      ),

      // Trending searches
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trending Searches',
                style: GoogleFonts.comfortaa(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().slideX(
                duration: 600.ms,
                begin: -1,
                curve: Curves.easeOut,
                delay: 1200.ms,
              ),
              
              const SizedBox(height: 16),
              
              _buildTrendingSearches().animate().slideY(
                duration: 600.ms,
                begin: 1,
                curve: Curves.easeOut,
                delay: 1400.ms,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildSearchSuggestions() {
    return [
      SliverToBoxAdapter(
        child: SearchSuggestionsWidget(
          onSuggestionTap: (suggestion) {
            _searchController.text = suggestion.text;
            ref.read(searchProvider.notifier).search(suggestion.text);
          },
        ).animate().fadeIn(duration: 300.ms),
      ),
    ];
  }

  List<Widget> _buildSearchResults() {
    return [
      SliverToBoxAdapter(
        child: SearchResultsWidget(
          onLoadMore: () {
            ref.read(searchProvider.notifier).loadMore();
          },
        ).animate().fadeIn(duration: 300.ms),
      ),
    ];
  }

  Widget _buildPopularAreas() {
    final popularAreas = ref.watch(popularAreasProvider);

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: popularAreas.length,
        itemBuilder: (context, index) {
          final area = popularAreas[index];
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                ref.read(searchProvider.notifier).searchByArea(area.id);
              },
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                blur: 8,
                opacity: 0.05,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      area.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      area.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ).animate().scale(
            delay: Duration(milliseconds: index * 100),
            duration: 400.ms,
            curve: Curves.elasticOut,
          );
        },
      ),
    );
  }

  Widget _buildTrendingSearches() {
    final trendingSearches = ref.watch(trendingSearchesProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: trendingSearches.asMap().entries.map((entry) {
        final index = entry.key;
        final search = entry.value;
        
        return GestureDetector(
          onTap: () {
            _searchController.text = search;
            ref.read(searchProvider.notifier).search(search);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.dubaiTeal.withOpacity(0.1),
                  AppColors.dubaiTeal.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.dubaiTeal.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.trendingUp,
                  size: 14,
                  color: AppColors.dubaiTeal,
                ),
                const SizedBox(width: 6),
                Text(
                  search,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ).animate().scale(
          delay: Duration(milliseconds: index * 100),
          duration: 400.ms,
          curve: Curves.elasticOut,
        );
      }).toList(),
    );
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
    
    if (_showFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }
} 