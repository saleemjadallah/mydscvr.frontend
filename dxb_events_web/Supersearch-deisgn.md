# MyDscvr Super Search Page - Design & Implementation Guide

## Design Brief

Create a vibrant, playful "Super Search" page that embodies the fun, family-friendly spirit of MyDscvr while maintaining the established Dubai-inspired brand aesthetic. The page should feel magical and powerful while remaining intuitive for busy parents.

### Brand-Aligned Design Principles
- **Visual Style**: Modern, playful, family-oriented with Dubai vibes
- **Color Palette**: Dubai-inspired colors (gold `#D4AF37`, teal `#17A2B8`, coral `#FF6B6B`, purple `#6C5CE7`)
- **Typography**: Comfortaa for headlines, Nunito for body text
- **Animations**: Smooth, delightful micro-interactions (avoid animation loops)
- **Layout**: Curved elements, bubble effects, soft shadows, rounded corners

### Super Search Experience Goals
1. **Discovery-First**: Make finding the perfect family event feel effortless
2. **Visual Feedback**: Provide immediate visual response to user interactions
3. **Smart Filtering**: Intelligent filters that adapt to family preferences
4. **Delightful Interactions**: Subtle animations that enhance usability
5. **Mobile-Optimized**: Touch-friendly design with responsive layout

---

## Flutter Implementation

### Core Dependencies
```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  google_fonts: ^6.1.0
  flutter_animate: ^4.2.0
  lucide_icons: ^0.288.0
  flutter_staggered_animations: ^1.1.1
```

### SuperSearchScreen Implementation

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// State Management
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedFiltersProvider = StateProvider<Map<String, Set<String>>>((ref) => {});
final isSearchActiveProvider = StateProvider<bool>((ref) => false);

// App Colors (From MyDscvr Brand)
class AppColors {
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
  const SuperSearchScreen({Key? key}) : super(key: key);
  
  @override
  ConsumerState<SuperSearchScreen> createState() => _SuperSearchScreenState();
}

class _SuperSearchScreenState extends ConsumerState<SuperSearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _pulseController;
  late AnimationController _searchBarController;
  
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
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _pulseController.dispose();
    _searchBarController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isSearchActive = ref.watch(isSearchActiveProvider);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
                  _buildHeroSection(),
                  const SizedBox(height: 32),
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildQuickFilters(),
                  const SizedBox(height: 32),
                  _buildSearchSuggestions(),
                  const SizedBox(height: 24),
                  _buildTrendingSearches(),
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
      title: Text(
        'Super Search',
        style: GoogleFonts.comfortaa(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
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
              gradient: AppColors.oceanGradient,
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
            gradient: AppColors.sunsetGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.dubaiCoral.withOpacity(0.3),
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
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
        
        const SizedBox(height: 8),
        
        Text(
          'Discover perfect family experiences in Dubai',
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: AppColors.textSecondary,
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
                  color: AppColors.dubaiTeal.withOpacity(0.3 * _searchBarController.value),
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
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  LucideIcons.search,
                  color: AppColors.dubaiTeal,
                  size: 20,
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
                        color: AppColors.textSecondary,
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
      FilterChip(emoji: '🎪', label: 'Events', color: AppColors.dubaiCoral),
      FilterChip(emoji: '🏢', label: 'Venues', color: AppColors.dubaiTeal),
      FilterChip(emoji: '🎨', label: 'Activities', color: AppColors.dubaiPurple),
      FilterChip(emoji: '🍕', label: 'Food', color: AppColors.dubaiGold),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Filters',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
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
            color: AppColors.textPrimary,
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
                color: AppColors.dubaiTeal,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  suggestion,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                LucideIcons.arrowUpRight,
                color: AppColors.textSecondary,
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
        gradient: AppColors.oceanGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.dubaiTeal.withOpacity(0.3),
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
              foregroundColor: AppColors.dubaiTeal,
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
  
  void _performSearch(String query) {
    _searchController.text = query;
    ref.read(searchQueryProvider.notifier).state = query;
    // Navigate to search results
    // Navigator.pushNamed(context, '/search-results', arguments: query);
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
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1.0, duration: 300.ms);
  }
}
```

---

## Animation Guidelines

### Performance Optimizations
1. **Limited Animation Controllers**: Use maximum 2-3 animation controllers per screen
2. **Staggered Animations**: Use flutter_staggered_animations for list items
3. **Avoid Loops**: No repeating animations to prevent "animation death loops"
4. **Dispose Properly**: Always dispose animation controllers in dispose()

### Interaction Feedback
- **Search Bar Focus**: Subtle glow effect when focused
- **Button Taps**: Quick scale animation (0.95x scale on tap)
- **Filter Selection**: Color change with subtle bounce
- **Card Hovers**: Gentle lift with shadow increase

### Visual Hierarchy
- **Hero Section**: Draws attention with pulsing sparkles icon
- **Search Bar**: Central focus with animated border on focus
- **Quick Filters**: Horizontal scroll with emoji icons
- **Suggestions**: Clean list with trending indicators

---

## Brand Integration Notes

The design maintains MyDscvr's established visual identity:
- **Dubai Color Palette**: Gold, teal, coral, purple gradients
- **Typography**: Comfortaa for headlines, Nunito for body
- **Playful Elements**: Emoji icons, bubble effects, curved containers
- **Family-Friendly**: Child-appropriate colors and friendly language
- **Performance**: Optimized animations prevent the previous "death loop" issue

This Super Search page creates an engaging discovery experience while staying true to the MyDscvr brand and maintaining excellent performance standards.