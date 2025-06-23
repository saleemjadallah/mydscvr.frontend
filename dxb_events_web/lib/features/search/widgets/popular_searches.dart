import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/themes/app_typography.dart';
import '../../../core/widgets/glass_morphism.dart';
import '../../../core/widgets/curved_container.dart';
import '../../../providers/search_provider.dart';
import '../../../services/providers/preferences_provider.dart';

/// Beautiful popular searches widget for Dubai Events discovery
class PopularSearches extends ConsumerWidget {
  final ValueChanged<String> onSearchSelected;

  const PopularSearches({
    super.key,
    required this.onSearchSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    final popularSearchesAsync = ref.watch(popularSearchTermsProvider);
    final categoriesAsync = ref.watch(searchCategoriesProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              LucideIcons.trendingUp,
              color: AppColors.dubaiCoral,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Popular in Dubai',
              style: AppTypography.h3.copyWith(
                color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Icon(
              LucideIcons.sparkles,
              color: AppColors.dubaiGold,
              size: 20,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Popular Search Terms
        popularSearchesAsync.when(
          data: (popularSearches) => _buildPopularSearchTerms(
            popularSearches,
            isDarkMode,
          ),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(),
        ),
        
        const SizedBox(height: 32),
        
        // Categories Section
        Row(
          children: [
            Icon(
              LucideIcons.grid,
              color: AppColors.dubaiTeal,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Browse Categories',
              style: AppTypography.h3.copyWith(
                color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Category Grid
        categoriesAsync.when(
          data: (categories) => _buildCategoryGrid(
            categories,
            isDarkMode,
          ),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(),
        ),
      ],
    );
  }

  Widget _buildPopularSearchTerms(List<String> searchTerms, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.dubaiCoral.withOpacity(0.1),
            AppColors.dubaiPurple.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.dubaiCoral.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.dubaiCoral.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.fire,
                  color: AppColors.dubaiCoral,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Hot Searches Today',
                style: AppTypography.h4.copyWith(
                  color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Search Terms Grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: searchTerms.asMap().entries.map((entry) {
              final index = entry.key;
              final searchTerm = entry.value;
              
              return _buildPopularSearchChip(
                searchTerm,
                index + 1,
                isDarkMode,
                index,
              );
            }).toList(),
          ),
        ],
      ),
    ).animate()
      .slideY(duration: 400.ms, begin: 0.3)
      .fade();
  }

  Widget _buildPopularSearchChip(
    String searchTerm,
    int rank,
    bool isDarkMode,
    int index,
  ) {
    Color chipColor;
    Color textColor;
    IconData icon;
    
    // Different styling based on rank
    if (rank <= 3) {
      chipColor = AppColors.dubaiGold;
      textColor = Colors.white;
      icon = LucideIcons.crown;
    } else if (rank <= 6) {
      chipColor = AppColors.dubaiTeal;
      textColor = Colors.white;
      icon = LucideIcons.star;
    } else {
      chipColor = AppColors.dubaiPurple;
      textColor = Colors.white;
      icon = LucideIcons.trendingUp;
    }
    
    return GestureDetector(
      onTap: () => onSearchSelected(searchTerm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              chipColor,
              chipColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: chipColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rank indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Icon
            Icon(
              icon,
              size: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            
            const SizedBox(width: 6),
            
            // Search term
            Flexible(
              child: Text(
                searchTerm,
                style: AppTypography.body2.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .scale(
        duration: Duration(milliseconds: 200 + (index * 100)),
        begin: const Offset(0.8, 0.8),
      )
      .fade(
        duration: Duration(milliseconds: 200 + (index * 100)),
      );
  }

  Widget _buildCategoryGrid(List<String> categories, bool isDarkMode) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category, index, isDarkMode);
      },
    );
  }

  Widget _buildCategoryCard(String category, int index, bool isDarkMode) {
    final categoryData = _getCategoryData(category);
    
    return GestureDetector(
      onTap: () => onSearchSelected(category),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: GlassMorphism(
          blur: 20,
          opacity: 0.9,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  categoryData.color.withOpacity(0.1),
                  categoryData.color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: categoryData.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Category Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: categoryData.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    categoryData.icon,
                    color: categoryData.color,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Category Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category,
                        style: AppTypography.body1.copyWith(
                          color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        categoryData.description,
                        style: AppTypography.caption.copyWith(
                          color: isDarkMode ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Arrow Icon
                Icon(
                  LucideIcons.arrowRight,
                  color: categoryData.color,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .slideX(
        duration: Duration(milliseconds: 300 + (index * 100)),
        begin: 0.3,
      )
      .fade(
        duration: Duration(milliseconds: 300 + (index * 100)),
      );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.dubaiGold),
              ),
            ).animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 1000.ms),
            const SizedBox(width: 16),
            Text(
              'Loading popular searches...',
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load popular searches',
              style: AppTypography.body2.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  CategoryData _getCategoryData(String category) {
    switch (category.toLowerCase()) {
      case 'arts & crafts':
      case 'art':
        return CategoryData(
          icon: LucideIcons.palette,
          color: AppColors.dubaiPurple,
          description: 'Creative activities',
        );
      case 'sports':
      case 'fitness':
        return CategoryData(
          icon: LucideIcons.dumbbell,
          color: AppColors.dubaiTeal,
          description: 'Active & healthy',
        );
      case 'music':
      case 'entertainment':
        return CategoryData(
          icon: LucideIcons.music,
          color: AppColors.dubaiCoral,
          description: 'Live performances',
        );
      case 'educational':
      case 'learning':
        return CategoryData(
          icon: LucideIcons.graduationCap,
          color: AppColors.dubaiGold,
          description: 'Learn & discover',
        );
      case 'food & dining':
      case 'food':
        return CategoryData(
          icon: LucideIcons.utensils,
          color: AppColors.success,
          description: 'Tasty experiences',
        );
      case 'outdoor':
      case 'nature':
        return CategoryData(
          icon: LucideIcons.trees,
          color: AppColors.success,
          description: 'Nature adventures',
        );
      case 'indoor':
        return CategoryData(
          icon: LucideIcons.home,
          color: AppColors.dubaiTeal,
          description: 'Indoor fun',
        );
      default:
        return CategoryData(
          icon: LucideIcons.star,
          color: AppColors.dubaiGold,
          description: 'Family activities',
        );
    }
  }
}

/// Data class for category information
class CategoryData {
  final IconData icon;
  final Color color;
  final String description;

  const CategoryData({
    required this.icon,
    required this.color,
    required this.description,
  });
}

/// Quick search suggestions for empty search state
class QuickSearchSuggestions extends ConsumerWidget {
  final ValueChanged<String> onSuggestionTapped;

  const QuickSearchSuggestions({
    super.key,
    required this.onSuggestionTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    
    final quickSuggestions = [
      QuickSuggestionData(
        title: 'This Weekend',
        subtitle: 'Family events happening now',
        icon: LucideIcons.calendar,
        color: AppColors.dubaiGold,
        query: 'weekend events',
      ),
      QuickSuggestionData(
        title: 'Free Activities',
        subtitle: 'No cost family fun',
        icon: LucideIcons.gift,
        color: AppColors.success,
        query: 'free family activities',
      ),
      QuickSuggestionData(
        title: 'Kids Events',
        subtitle: 'Perfect for children',
        icon: LucideIcons.baby,
        color: AppColors.dubaiPurple,
        query: 'kids events',
      ),
      QuickSuggestionData(
        title: 'Near Me',
        subtitle: 'Activities in your area',
        icon: LucideIcons.mapPin,
        color: AppColors.dubaiTeal,
        query: 'events near me',
      ),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(
              LucideIcons.zap,
              color: AppColors.dubaiGold,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Quick Searches',
              style: AppTypography.h3.copyWith(
                color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Suggestions Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: quickSuggestions.length,
          itemBuilder: (context, index) {
            final suggestion = quickSuggestions[index];
            return _buildQuickSuggestionCard(suggestion, index, isDarkMode);
          },
        ),
      ],
    );
  }

  Widget _buildQuickSuggestionCard(
    QuickSuggestionData suggestion,
    int index,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: () => onSuggestionTapped(suggestion.query),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: GlassMorphism(
          blur: 20,
          opacity: 0.9,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  suggestion.color.withOpacity(0.15),
                  suggestion.color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: suggestion.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: suggestion.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    suggestion.icon,
                    color: suggestion.color,
                    size: 20,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Title
                Text(
                  suggestion.title,
                  style: AppTypography.h4.copyWith(
                    color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Subtitle
                Text(
                  suggestion.subtitle,
                  style: AppTypography.body2.copyWith(
                    color: isDarkMode ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .scale(
        duration: Duration(milliseconds: 300 + (index * 100)),
        begin: const Offset(0.9, 0.9),
      )
      .fade(
        duration: Duration(milliseconds: 300 + (index * 100)),
      );
  }
}

/// Data class for quick suggestion information
class QuickSuggestionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String query;

  const QuickSuggestionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.query,
  });
} 