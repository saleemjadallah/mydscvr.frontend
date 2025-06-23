import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/themes/app_typography.dart';
import '../../../core/widgets/glass_morphism.dart';
import '../../../models/search.dart';
import '../../../services/providers/preferences_provider.dart';

/// Beautiful search suggestions dropdown with smart recommendations
class SearchSuggestions extends ConsumerWidget {
  final List<SearchSuggestion> suggestions;
  final ValueChanged<SearchSuggestion> onSuggestionSelected;
  final String? currentQuery;

  const SearchSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionSelected,
    this.currentQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: GlassMorphism(
        blur: 20,
        opacity: 0.95,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.dubaiGold.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.dubaiGold.withOpacity(0.1),
                      AppColors.dubaiTeal.withOpacity(0.1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.lightBulb,
                      color: AppColors.dubaiGold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Suggestions',
                      style: AppTypography.h4.copyWith(
                        color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${suggestions.length} found',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.dubaiGold,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Suggestions List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: suggestions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: isDarkMode 
                      ? AppColors.textSecondaryLight.withOpacity(0.1)
                      : AppColors.textSecondaryDark.withOpacity(0.1),
                ),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return SearchSuggestionItem(
                    suggestion: suggestion,
                    onTap: () => onSuggestionSelected(suggestion),
                    currentQuery: currentQuery,
                    index: index,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .slideY(duration: 300.ms, begin: -0.3)
      .fade();
  }
}

/// Individual search suggestion item with smart highlighting
class SearchSuggestionItem extends ConsumerWidget {
  final SearchSuggestion suggestion;
  final VoidCallback onTap;
  final String? currentQuery;
  final int index;

  const SearchSuggestionItem({
    super.key,
    required this.suggestion,
    required this.onTap,
    this.currentQuery,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Row(
          children: [
            // Suggestion Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getSuggestionTypeColor(suggestion.type).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getSuggestionTypeIcon(suggestion.type),
                color: _getSuggestionTypeColor(suggestion.type),
                size: 18,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Suggestion Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main text with highlighting
                  RichText(
                    text: _buildHighlightedText(
                      suggestion.query,
                      currentQuery,
                      isDarkMode,
                    ),
                  ),
                  
                  // Additional info
                  if (suggestion.description != null && 
                      suggestion.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      suggestion.description!,
                      style: AppTypography.body2.copyWith(
                        color: isDarkMode 
                            ? AppColors.textSecondaryLight 
                            : AppColors.textSecondaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  // Result count
                  if (suggestion.resultCount != null && 
                      suggestion.resultCount! > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${suggestion.resultCount} events',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.dubaiTeal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Action Icon
            Icon(
              LucideIcons.arrowUpLeft,
              color: isDarkMode 
                  ? AppColors.textSecondaryLight 
                  : AppColors.textSecondaryDark,
              size: 16,
            ),
          ],
        ),
      ),
    ).animate()
      .slideX(
        duration: Duration(milliseconds: 200 + (index * 50)),
        begin: 0.3,
      )
      .fade(
        duration: Duration(milliseconds: 200 + (index * 50)),
      );
  }

  TextSpan _buildHighlightedText(
    String text,
    String? query,
    bool isDarkMode,
  ) {
    if (query == null || query.isEmpty) {
      return TextSpan(
        text: text,
        style: AppTypography.body1.copyWith(
          color: isDarkMode ? AppColors.textLight : AppColors.textDark,
        ),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final startIndex = lowerText.indexOf(lowerQuery);

    if (startIndex == -1) {
      return TextSpan(
        text: text,
        style: AppTypography.body1.copyWith(
          color: isDarkMode ? AppColors.textLight : AppColors.textDark,
        ),
      );
    }

    final endIndex = startIndex + query.length;
    
    return TextSpan(
      children: [
        if (startIndex > 0)
          TextSpan(
            text: text.substring(0, startIndex),
            style: AppTypography.body1.copyWith(
              color: isDarkMode ? AppColors.textLight : AppColors.textDark,
            ),
          ),
        TextSpan(
          text: text.substring(startIndex, endIndex),
          style: AppTypography.body1.copyWith(
            color: AppColors.dubaiGold,
            fontWeight: FontWeight.bold,
            backgroundColor: AppColors.dubaiGold.withOpacity(0.1),
          ),
        ),
        if (endIndex < text.length)
          TextSpan(
            text: text.substring(endIndex),
            style: AppTypography.body1.copyWith(
              color: isDarkMode ? AppColors.textLight : AppColors.textDark,
            ),
          ),
      ],
    );
  }

  IconData _getSuggestionTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'category':
        return LucideIcons.tag;
      case 'venue':
        return LucideIcons.mapPin;
      case 'area':
        return LucideIcons.map;
      case 'event':
        return LucideIcons.calendar;
      case 'popular':
        return LucideIcons.trendingUp;
      case 'recent':
        return LucideIcons.clock;
      default:
        return LucideIcons.search;
    }
  }

  Color _getSuggestionTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'category':
        return AppColors.dubaiPurple;
      case 'venue':
      case 'area':
        return AppColors.dubaiTeal;
      case 'event':
        return AppColors.dubaiGold;
      case 'popular':
        return AppColors.dubaiCoral;
      case 'recent':
        return AppColors.textSecondaryDark;
      default:
        return AppColors.dubaiGold;
    }
  }
}

/// Quick suggestions widget for popular searches
class QuickSuggestions extends ConsumerWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTapped;
  final String? title;

  const QuickSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionTapped,
    this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: AppTypography.h4.copyWith(
                color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final suggestion = entry.value;
              
              return GestureDetector(
                onTap: () => onSuggestionTapped(suggestion),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.dubaiGold.withOpacity(0.1),
                        AppColors.dubaiTeal.withOpacity(0.1),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.dubaiGold.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.trendingUp,
                        size: 14,
                        color: AppColors.dubaiGold,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        suggestion,
                        style: AppTypography.body2.copyWith(
                          color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate()
                .scale(
                  duration: Duration(milliseconds: 200 + (index * 50)),
                  begin: const Offset(0.8, 0.8),
                )
                .fade(
                  duration: Duration(milliseconds: 200 + (index * 50)),
                );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Empty suggestions state widget
class EmptySuggestions extends ConsumerWidget {
  final String? query;
  final VoidCallback? onClearSearch;

  const EmptySuggestions({
    super.key,
    this.query,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            LucideIcons.searchX,
            size: 64,
            color: AppColors.textSecondaryDark,
          ),
          const SizedBox(height: 16),
          Text(
            'No suggestions found',
            style: AppTypography.h3.copyWith(
              color: isDarkMode ? AppColors.textLight : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          if (query != null) ...[
            Text(
              'No suggestions for "$query"',
              style: AppTypography.body1.copyWith(
                color: isDarkMode ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (onClearSearch != null)
              ElevatedButton(
                onPressed: onClearSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dubaiTeal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Clear Search'),
              ),
          ] else ...[
            Text(
              'Try typing to see suggestions',
              style: AppTypography.body1.copyWith(
                color: isDarkMode ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.3, duration: 500.ms);
  }
}

/// Trending searches widget
class TrendingSearches extends ConsumerWidget {
  final List<String> trendingSearches;
  final ValueChanged<String> onSearchTapped;

  const TrendingSearches({
    super.key,
    required this.trendingSearches,
    required this.onSearchTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    
    if (trendingSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.dubaiCoral.withOpacity(0.1),
            AppColors.dubaiPurple.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dubaiCoral.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.trendingUp,
                color: AppColors.dubaiCoral,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Trending in Dubai',
                style: AppTypography.h4.copyWith(
                  color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: trendingSearches.asMap().entries.map((entry) {
              final index = entry.key;
              final search = entry.value;
              
              return GestureDetector(
                onTap: () => onSearchTapped(search),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.dubaiCoral.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.dubaiCoral.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#${index + 1}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.dubaiCoral,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        search,
                        style: AppTypography.body2.copyWith(
                          color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate()
                .slideX(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  begin: 0.5,
                )
                .fade(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                );
            }).toList(),
          ),
        ],
      ),
    ).animate()
      .slideY(duration: 400.ms, begin: 0.3)
      .fade(delay: 200.ms);
  }
} 