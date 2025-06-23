import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../models/search.dart';
import '../../providers/search_provider.dart';

class SearchSuggestionsWidget extends ConsumerWidget {
  final Function(SearchSuggestion)? onSuggestionTap;
  final bool showHistory;
  final bool showTrending;

  const SearchSuggestionsWidget({
    super.key,
    this.onSuggestionTap,
    this.showHistory = true,
    this.showTrending = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(searchSuggestionsProvider);
    final searchHistory = ref.watch(searchHistoryProvider);
    final trendingSearches = ref.watch(trendingSearchesProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: GlassCard(
        borderRadius: BorderRadius.circular(16),
        padding: EdgeInsets.zero,
        blur: 10,
        opacity: 0.95,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Suggestions from search
            if (suggestions.isNotEmpty) ...[
              _buildSectionHeader('Suggestions', LucideIcons.lightbulb),
              ...suggestions.asMap().entries.map((entry) {
                final index = entry.key;
                final suggestion = entry.value;
                return _buildSuggestionItem(
                  suggestion,
                  index,
                  onTap: () => onSuggestionTap?.call(suggestion),
                );
              }).toList(),
              if (showHistory && searchHistory.isNotEmpty || 
                  showTrending && trendingSearches.isNotEmpty)
                const Divider(height: 1, color: AppColors.border),
            ],

            // Search history
            if (showHistory && searchHistory.isNotEmpty) ...[
              _buildSectionHeader('Recent Searches', LucideIcons.clock),
              ...searchHistory.take(3).asMap().entries.map((entry) {
                final index = entry.key;
                final historyItem = entry.value;
                return _buildHistoryItem(
                  historyItem,
                  index,
                  onTap: () {
                    ref.read(searchProvider.notifier).searchFromHistory(historyItem);
                  },
                  onRemove: () {
                    ref.read(searchProvider.notifier).removeFromHistory(historyItem.id);
                  },
                );
              }).toList(),
              if (showTrending && trendingSearches.isNotEmpty)
                const Divider(height: 1, color: AppColors.border),
            ],

            // Trending searches
            if (showTrending && trendingSearches.isNotEmpty) ...[
              _buildSectionHeader('Trending in Dubai', LucideIcons.trendingUp),
              ...trendingSearches.take(4).asMap().entries.map((entry) {
                final index = entry.key;
                final trending = entry.value;
                return _buildTrendingItem(
                  trending,
                  index,
                  onTap: () {
                    final suggestion = SearchSuggestion(
                      id: 'trending_$index',
                      text: trending,
                      type: SearchSuggestionType.general,
                      popularity: 100 - index,
                    );
                    onSuggestionTap?.call(suggestion);
                  },
                );
              }).toList(),
            ],

            // Clear history option
            if (showHistory && searchHistory.isNotEmpty)
              _buildClearHistoryButton(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.dubaiTeal,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.comfortaa(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(
    SearchSuggestion suggestion,
    int index, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Suggestion type icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _getSuggestionTypeColor(suggestion.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getSuggestionTypeIcon(suggestion.type),
                size: 16,
                color: _getSuggestionTypeColor(suggestion.type),
              ),
            ),
            const SizedBox(width: 12),
            
            // Suggestion text
            Expanded(
              child: Text(
                suggestion.text,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            
            // Category or area badge
            if (suggestion.category != null || suggestion.area != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.dubaiTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  suggestion.category ?? suggestion.area ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dubaiTeal,
                  ),
                ),
              ),
            
            // Arrow icon
            const SizedBox(width: 8),
            Icon(
              LucideIcons.arrowUpLeft,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    ).animate().slideX(
      delay: Duration(milliseconds: index * 50),
      duration: 200.ms,
      begin: 0.2,
      curve: Curves.easeOut,
    ).fadeIn();
  }

  Widget _buildHistoryItem(
    SearchHistoryItem historyItem,
    int index, {
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // History icon
            Icon(
              LucideIcons.clock,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            
            // Query text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    historyItem.query,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (historyItem.resultCount > 0)
                    Text(
                      '${historyItem.resultCount} results',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            
            // Filters indicator
            if (historyItem.filters?.hasActiveFilters == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.dubaiGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.filter,
                      size: 10,
                      color: AppColors.dubaiGold,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${historyItem.filters!.activeFilterCount}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dubaiGold,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Remove button
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  LucideIcons.x,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideX(
      delay: Duration(milliseconds: index * 50),
      duration: 200.ms,
      begin: 0.2,
      curve: Curves.easeOut,
    ).fadeIn();
  }

  Widget _buildTrendingItem(
    String trending,
    int index, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Trending icon with animation
            AnimatedBuilder(
              animation: AlwaysStoppedAnimation(0.0),
              builder: (context, child) {
                return Icon(
                  LucideIcons.trendingUp,
                  size: 16,
                  color: AppColors.dubaiGold,
                );
              },
            ),
            const SizedBox(width: 12),
            
            // Trending text
            Expanded(
              child: Text(
                trending,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            
            // Trending rank
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.dubaiGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '#${index + 1}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dubaiGold,
                ),
              ),
            ),
            
            // Arrow icon
            const SizedBox(width: 8),
            Icon(
              LucideIcons.arrowUpLeft,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    ).animate().slideX(
      delay: Duration(milliseconds: index * 50),
      duration: 200.ms,
      begin: 0.2,
      curve: Curves.easeOut,
    ).fadeIn();
  }

  Widget _buildClearHistoryButton(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: TextButton(
          onPressed: () {
            ref.read(searchProvider.notifier).clearSearchHistory();
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.trash2,
                size: 14,
                color: AppColors.error,
              ),
              const SizedBox(width: 6),
              Text(
                'Clear Search History',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSuggestionTypeIcon(SearchSuggestionType type) {
    switch (type) {
      case SearchSuggestionType.category:
        return LucideIcons.tag;
      case SearchSuggestionType.area:
        return LucideIcons.mapPin;
      case SearchSuggestionType.venue:
        return LucideIcons.building;
      case SearchSuggestionType.event:
        return LucideIcons.calendar;
      case SearchSuggestionType.activity:
        return LucideIcons.activity;
      case SearchSuggestionType.general:
      default:
        return LucideIcons.search;
    }
  }

  Color _getSuggestionTypeColor(SearchSuggestionType type) {
    switch (type) {
      case SearchSuggestionType.category:
        return AppColors.dubaiTeal;
      case SearchSuggestionType.area:
        return AppColors.dubaiGold;
      case SearchSuggestionType.venue:
        return Colors.purple;
      case SearchSuggestionType.event:
        return Colors.blue;
      case SearchSuggestionType.activity:
        return Colors.green;
      case SearchSuggestionType.general:
      default:
        return AppColors.textSecondary;
    }
  }
}

/// Compact suggestions widget for smaller spaces
class CompactSearchSuggestions extends ConsumerWidget {
  final Function(String)? onSuggestionTap;
  final int maxSuggestions;

  const CompactSearchSuggestions({
    super.key,
    this.onSuggestionTap,
    this.maxSuggestions = 3,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(searchSuggestionsProvider);

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: suggestions.take(maxSuggestions).map((suggestion) {
          return InkWell(
            onTap: () => onSuggestionTap?.call(suggestion.text),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.search,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      suggestion.text,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    LucideIcons.arrowUpLeft,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
} 