import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import '../../services/super_search_service.dart';
import '../../widgets/events/event_card.dart';

// State Management
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedFiltersProvider = StateProvider<Map<String, Set<String>>>((ref) => {});
final isSearchActiveProvider = StateProvider<bool>((ref) => false);

// App Colors (From MyDscvr Brand)
class MyDscvrColors {
  static const Color dubaiGold = Color(0xFFD4AF37);
  static const Color dubaiTeal = Color(0xFF17A2B8);
  static const Color dubaiCoral = Color(0xFFFF6B6B);
  static const Color dubaiPurple = Color(0xFF6C5CE7);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF7B7B), Color(0xFFFFA726)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF17A2B8), Color(0xFF6C5CE7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class SuperSearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SuperSearchScreen({
    super.key,
    this.initialQuery,
  });
  
  @override
  ConsumerState<SuperSearchScreen> createState() => _SuperSearchScreenState();
}

class _SuperSearchScreenState extends ConsumerState<SuperSearchScreen>
    with TickerProviderStateMixin {
  final SuperSearchService _superSearchService = SuperSearchService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _pulseController;
  late AnimationController _searchBarController;
  
  SuperSearchResult? _searchResult;
  bool _isLoading = false;
  bool _showResults = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _searchBarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Listen to search focus
    _searchFocusNode.addListener(() {
      ref.read(isSearchActiveProvider.notifier).state = _searchFocusNode.hasFocus;
      if (_searchFocusNode.hasFocus) {
        _searchBarController.forward();
      } else {
        _searchBarController.reverse();
      }
    });

    // Set initial query if provided
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      ref.read(searchQueryProvider.notifier).state = widget.initialQuery!;
      // Perform initial search
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _pulseController.dispose();
    _searchBarController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    _searchController.text = query;
    ref.read(searchQueryProvider.notifier).state = query;
    
    setState(() {
      _isLoading = true;
      _showResults = true;
      _error = null;
    });

    final response = await _superSearchService.search(
      query: query.trim(),
      filters: const SuperSearchFilters(),
      page: 1,
      perPage: 20,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.isSuccess) {
          _searchResult = response.data;
          _error = null;
          print('🎯 SuperSearchScreen: Search successful! Events count: ${_searchResult?.events.length ?? 0}');
          print('🎯 SuperSearchScreen: Total results: ${_searchResult?.total ?? 0}');
        } else {
          _error = response.error;
          _searchResult = null;
          print('🚨 SuperSearchScreen: Search failed with error: ${response.error}');
        }
      });
    }
  }
  
  void _onFilterTap(String filter) {
    // Toggle filter selection
    final filters = ref.read(selectedFiltersProvider);
    final category = 'type';
    if (filters[category]?.contains(filter) == true) {
      filters[category]?.remove(filter);
    } else {
      filters[category] ??= {};
      filters[category]?.add(filter);
    }
    ref.read(selectedFiltersProvider.notifier).state = {...filters};
  }
  
  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdvancedFiltersModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyDscvrColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Animated App Bar
            _buildAnimatedAppBar(),
            
            // Main Search Section
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (!_showResults) ...[
                    _buildHeroSection(),
                    const SizedBox(height: 32),
                  ],
                  _buildSearchBar(),
                  if (_showResults) ...[
                    const SizedBox(height: 24),
                    _buildSearchResults(),
                  ] else ...[
                    const SizedBox(height: 24),
                    _buildQuickFilters(),
                    const SizedBox(height: 32),
                    _buildSearchSuggestions(),
                    const SizedBox(height: 24),
                    _buildTrendingSearches(),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          context.go('/');
        },
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: MyDscvrColors.dubaiTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            LucideIcons.arrowLeft,
            color: MyDscvrColors.dubaiTeal,
            size: 20,
          ),
        ),
      ).animate().scale(delay: 150.ms),
      title: Text(
        'Super Search',
        style: GoogleFonts.comfortaa(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: MyDscvrColors.textPrimary,
        ),
      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
      actions: [
        IconButton(
          onPressed: () {
            // Show search filters
            _showAdvancedFilters();
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: MyDscvrColors.oceanGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.sliders, color: Colors.white, size: 20),
          ),
        ).animate().scale(delay: 300.ms),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        // Animated Magic Wand Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: MyDscvrColors.sunsetGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: MyDscvrColors.dubaiCoral.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            LucideIcons.sparkles,
            color: Colors.white,
            size: 36,
          ),
        ).animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        ).scale(
          duration: 2000.ms,
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
        ),
        
        const SizedBox(height: 20),
        
        // Hero Text
        Text(
          'Find Amazing Events',
          style: GoogleFonts.comfortaa(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: MyDscvrColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
        
        const SizedBox(height: 8),
        
        Text(
          'Discover perfect family experiences in Dubai',
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: MyDscvrColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }
  
  Widget _buildSearchBar() {
    return AnimatedBuilder(
      animation: _searchBarController,
      builder: (context, child) {
        return Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              // Animated glow effect when focused
              if (_searchBarController.value > 0)
                BoxShadow(
                  color: MyDscvrColors.dubaiTeal.withOpacity(0.3 * _searchBarController.value),
                  blurRadius: 20,
                  offset: const Offset(0, 0),
                ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search events, venues, activities...',
              hintStyle: GoogleFonts.nunito(
                color: MyDscvrColors.textSecondary,
                fontSize: 16,
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: _showResults ? () {
                    setState(() {
                      _showResults = false;
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    });
                  } : null,
                  child: Icon(
                    _showResults ? LucideIcons.arrowLeft : LucideIcons.search,
                    color: MyDscvrColors.dubaiTeal,
                    size: 20,
                  ),
                ),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                      icon: const Icon(LucideIcons.x, size: 20),
                    )
                  : Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        LucideIcons.mic,
                        color: MyDscvrColors.textSecondary,
                        size: 20,
                      ),
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
            onSubmitted: (value) {
              _performSearch(value);
            },
          ),
        );
      },
    ).animate().slideY(begin: 0.5, duration: 600.ms);
  }
  
  Widget _buildQuickFilters() {
    final quickFilters = [
      FilterChip(emoji: '🎪', label: 'Events', color: MyDscvrColors.dubaiCoral),
      FilterChip(emoji: '🏢', label: 'Venues', color: MyDscvrColors.dubaiTeal),
      FilterChip(emoji: '🎨', label: 'Activities', color: MyDscvrColors.dubaiPurple),
      FilterChip(emoji: '🍕', label: 'Food', color: MyDscvrColors.dubaiGold),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Filters',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: MyDscvrColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        AnimationLimiter(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: quickFilters.asMap().entries.map((entry) {
              final index = entry.key;
              final filter = entry.value;
              
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 600),
                child: SlideAnimation(
                  verticalOffset: 50,
                  child: FadeInAnimation(
                    child: _buildFilterChip(filter),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFilterChip(FilterChip filter) {
    return InkWell(
      onTap: () => _onFilterTap(filter.label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              filter.color.withOpacity(0.1),
              filter.color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: filter.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filter.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              filter.label,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: filter.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchSuggestions() {
    final suggestions = [
      'Kids workshops this weekend',
      'Indoor activities near me',
      'Family brunch spots',
      'Art classes for children',
      'Outdoor adventures Dubai',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Searches',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: MyDscvrColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        AnimationLimiter(
          child: Column(
            children: suggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final suggestion = entry.value;
              
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 600),
                child: SlideAnimation(
                  horizontalOffset: 50,
                  child: FadeInAnimation(
                    child: _buildSuggestionTile(suggestion),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSuggestionTile(String suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _performSearch(suggestion),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.trendingUp,
                color: MyDscvrColors.dubaiTeal,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  suggestion,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: MyDscvrColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                LucideIcons.arrowUpRight,
                color: MyDscvrColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTrendingSearches() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: MyDscvrColors.oceanGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MyDscvrColors.dubaiTeal.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.flame,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Trending Now',
                style: GoogleFonts.comfortaa(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Summer camp registrations are heating up! Find the perfect camp for your little ones.',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _performSearch('summer camps'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: MyDscvrColors.dubaiTeal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Explore Summer Camps',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 800.ms);
  }
  
  Widget _buildSearchResults() {
    if (_isLoading) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(MyDscvrColors.dubaiTeal),
              ),
              const SizedBox(height: 16),
              Text(
                'Searching events...',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: MyDscvrColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: MyDscvrColors.dubaiCoral,
            ),
            const SizedBox(height: 16),
            Text(
              'Search Error',
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: MyDscvrColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: MyDscvrColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_searchController.text.trim().isNotEmpty) {
                  _performSearch(_searchController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyDscvrColors.dubaiTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    if (_searchResult == null || _searchResult!.events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              LucideIcons.searchX,
              size: 48,
              color: MyDscvrColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Events Found',
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: MyDscvrColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords or explore our popular searches below.',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: MyDscvrColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showResults = false;
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyDscvrColors.dubaiTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Browse Popular Searches',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    final result = _searchResult!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search metadata
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${result.total} results found',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MyDscvrColors.textPrimary,
                ),
              ),
              if (result.metadata.totalProcessingTimeMs > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: MyDscvrColors.dubaiTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${result.metadata.totalProcessingTimeMs}ms',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: MyDscvrColors.dubaiTeal,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Results list
        ...result.events.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: EventCard(
                    event: event,
                    onTap: () {
                      context.go('/event/${event.id}');
                    },
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

// Supporting Classes
class FilterChip {
  final String emoji;
  final String label;
  final Color color;
  
  const FilterChip({
    required this.emoji,
    required this.label,
    required this.color,
  });
}

class AdvancedFiltersModal extends StatelessWidget {
  const AdvancedFiltersModal({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Filter content would go here
          Expanded(
            child: Center(
              child: Text(
                'Advanced Filters Coming Soon!',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  color: MyDscvrColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1.0, duration: 300.ms);
  }
}