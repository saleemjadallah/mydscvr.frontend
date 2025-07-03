import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../models/search.dart';
import '../../providers/search_provider.dart';
import '../../services/events_service.dart';

class CategoryBrowserWidget extends ConsumerWidget {
  final bool showAllCategories;
  final VoidCallback? onSeeAll;

  const CategoryBrowserWidget({
    super.key,
    this.showAllCategories = false,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = showAllCategories 
        ? EventCategory.allCategories 
        : EventCategory.familyCategories.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category grid for mobile/tablet
        if (MediaQuery.of(context).size.width < 800)
          _buildCategoryGrid(categories, ref)
        else
          // Category carousel for desktop
          _buildCategoryCarousel(categories, ref),
        
        // See all button
        if (!showAllCategories && onSeeAll != null) ...[
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: AppColors.dubaiTeal.withOpacity(0.1),
                foregroundColor: AppColors.dubaiTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: AppColors.dubaiTeal.withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See All Categories',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                ],
              ),
            ),
          ).animate().slideY(
            duration: 400.ms,
            begin: 0.3,
            curve: Curves.easeOut,
            delay: Duration(milliseconds: categories.length * 100 + 200),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryGrid(List<EventCategory> categories, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category, ref, index);
      },
    );
  }

  Widget _buildCategoryCarousel(List<EventCategory> categories, WidgetRef ref) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            child: _buildCategoryCard(category, ref, index),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(EventCategory category, WidgetRef ref, int index) {
    return GestureDetector(
      onTap: () {
        ref.read(searchProvider.notifier).searchByCategory(category.id);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: category.color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: GlassCard(
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(20),
          blur: 8,
          opacity: 0.1,
          border: Border.all(
            color: category.color.withOpacity(0.3),
            width: 1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category icon and emoji
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          category.color.withOpacity(0.8),
                          category.color.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Category name
              Text(
                category.name,
                style: GoogleFonts.comfortaa(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Subcategories
              if (category.subcategories.isNotEmpty)
                Text(
                  category.subcategories.take(2).join(' • '),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

              // Family friendly indicator
              if (category.isFamilyFriendly)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.dubaiTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.dubaiTeal.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.family_restroom,
                        color: AppColors.dubaiTeal,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Family Friendly',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dubaiTeal,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate().scale(
      delay: Duration(milliseconds: index * 100),
      duration: 400.ms,
      curve: Curves.elasticOut,
    ).fadeIn();
  }
}

/// Compact category selector for filters
class CategorySelectorWidget extends ConsumerWidget {
  final String? selectedCategoryId;
  final Function(String?)? onCategorySelected;
  final bool showAllOption;

  const CategorySelectorWidget({
    super.key,
    this.selectedCategoryId,
    this.onCategorySelected,
    this.showAllOption = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = EventCategory.allCategories;

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + (showAllOption ? 1 : 0),
        itemBuilder: (context, index) {
          if (showAllOption && index == 0) {
            return _buildCategoryChip(
              id: null,
              name: 'All',
              emoji: '🌟',
              color: AppColors.dubaiTeal,
              isSelected: selectedCategoryId == null,
            );
          }

          final categoryIndex = showAllOption ? index - 1 : index;
          final category = categories[categoryIndex];

          return _buildCategoryChip(
            id: category.id,
            name: category.name,
            emoji: category.emoji,
            color: category.color,
            isSelected: selectedCategoryId == category.id,
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip({
    required String? id,
    required String name,
    required String emoji,
    required Color color,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => onCategorySelected?.call(id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      color.withOpacity(0.8),
                      color.withOpacity(0.6),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      AppColors.surface,
                      AppColors.surface,
                    ],
                  ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected
                  ? color.withOpacity(0.8)
                  : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(
      duration: 200.ms,
      curve: Curves.elasticOut,
    );
  }
}

/// Category stats widget showing number of events per category
class CategoryStatsWidget extends ConsumerStatefulWidget {
  const CategoryStatsWidget({super.key});

  @override
  ConsumerState<CategoryStatsWidget> createState() => _CategoryStatsWidgetState();
}

class _CategoryStatsWidgetState extends ConsumerState<CategoryStatsWidget> {
  late final EventsService _eventsService;
  Map<String, int> _categoryCounts = {};
  bool _isLoading = true;
  
  // Define category mappings that match exactly with category pages
  final _categoryMappings = {
    'family_fun': {
      'apiCategories': ['family', 'kids'],
      'tags': ['family', 'kids', 'children', 'all_ages', 'all-ages', 'family-friendly'],
    },
    'water_activities': {
      'apiCategories': ['water_sports', 'beach', 'outdoor_activities'],
      'tags': ['water', 'beach', 'swimming', 'marine', 'aqua', 'sea', 'ocean'],
    },
    'cultural': {
      'apiCategories': ['cultural', 'arts'],
      'tags': ['cultural', 'heritage', 'art', 'museum', 'gallery', 'theater', 'opera', 'traditional'],
    },
    'adventure': {
      'apiCategories': ['adventure', 'outdoor_activities', 'sports'],
      'tags': ['adventure', 'outdoor', 'sports', 'hiking', 'climbing', 'extreme'],
    },
    'educational': {
      'apiCategories': ['educational', 'workshops'],
      'tags': ['educational', 'workshop', 'learning', 'class', 'course', 'training'],
    },
    'entertainment': {
      'apiCategories': ['entertainment', 'shows'],
      'tags': ['entertainment', 'show', 'performance', 'comedy', 'concert', 'music'],
    },
    'shopping': {
      'apiCategories': ['shopping'],
      'tags': ['shopping', 'mall', 'retail', 'market', 'bazaar', 'souk'],
    },
    'dining': {
      'apiCategories': ['food', 'dining'],
      'tags': ['food', 'dining', 'restaurant', 'cuisine', 'culinary', 'chef', 'tasting'],
    },
  };

  @override
  void initState() {
    super.initState();
    _eventsService = EventsService();
    _loadCategoryCounts();
  }

  Future<void> _loadCategoryCounts() async {
    try {
      print('📊 Loading category counts for CategoryStatsWidget...');
      
      // Load all events using same method as Interactive Category Explorer
      final response = await _eventsService.getEvents(
        perPage: 200, // Get all events
        sortBy: 'start_date',
      );
      
      if (response.isSuccess && response.data != null) {
        final allEvents = response.data!;
        print('📊 Processing ${allEvents.length} events for category stats');
        
        final Map<String, int> categoryCounts = {};

        // Process each category using same broad tag-based filtering
        for (final entry in _categoryMappings.entries) {
          final categoryId = entry.key;
          final mapping = entry.value;
          final apiCategories = mapping['apiCategories'] as List<String>;
          final tags = mapping['tags'] as List<String>;
          
          // Use the exact same filtering logic as category pages
          final filteredEvents = allEvents.where((event) {
            // Check exact category match (case-insensitive)
            final categoryMatch = apiCategories.any((category) => 
              event.category.toLowerCase() == category.toLowerCase()
            );
            
            // Check broad tag-based matching (same as category page)
            final tagMatch = tags.any((tag) =>
              event.tags.any((eventTag) => 
                eventTag.toLowerCase().contains(tag.toLowerCase())
              ) ||
              event.category.toLowerCase().contains(tag.toLowerCase()) ||
              event.title.toLowerCase().contains(tag.toLowerCase()) ||
              event.description.toLowerCase().contains(tag.toLowerCase())
            );
            
            return categoryMatch || tagMatch;
          }).toList();
          
          categoryCounts[categoryId] = filteredEvents.length;
          print('✅ $categoryId: ${filteredEvents.length} events (matches category page count)');
        }

        if (mounted) {
          setState(() {
            _categoryCounts = categoryCounts;
            _isLoading = false;
          });
        }
        
        print('✅ CategoryStatsWidget counts loaded: $categoryCounts');
      } else {
        print('❌ Failed to load events for CategoryStatsWidget: ${response.error}');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error loading category counts: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = EventCategory.allCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories Overview',
          style: GoogleFonts.comfortaa(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...categories.map((category) {
          final eventCount = _categoryCounts[category.id] ?? 0;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.dubaiTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLoading) ...[
                        SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.dubaiTeal),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Loading...',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dubaiTeal,
                          ),
                        ),
                      ] else ...[
                        Text(
                          '$eventCount events',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dubaiTeal,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
} 