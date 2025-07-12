import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_morphism.dart';

enum SortOption {
  latest('Latest', LucideIcons.clock, 'Show recently added events first'),
  date('Date', LucideIcons.calendar, 'Sort events by date'),
  popularity('Popularity', LucideIcons.trendingUp, 'Sort by popularity and ratings'),
  priceLowToHigh('Price: Low to High', LucideIcons.arrowUp, 'Sort by price ascending'),
  priceHighToLow('Price: High to Low', LucideIcons.arrowDown, 'Sort by price descending'),
  distance('Distance', LucideIcons.mapPin, 'Sort by distance from you'),
  rating('Rating', LucideIcons.star, 'Sort by user ratings'),
  alphabetical('A-Z', LucideIcons.type, 'Sort alphabetically');

  const SortOption(this.label, this.icon, this.description);

  final String label;
  final IconData icon;
  final String description;
}

enum ViewMode {
  grid('Grid View', LucideIcons.grid),
  list('List View', LucideIcons.list);

  const ViewMode(this.label, this.icon);

  final String label;
  final IconData icon;
}

class EventsSortControls extends StatelessWidget {
  final SortOption selectedSort;
  final ViewMode selectedView;
  final Function(SortOption) onSortChanged;
  final Function(ViewMode) onViewChanged;
  final int eventCount;
  final bool isLoading;
  final String? filterSummary;

  const EventsSortControls({
    super.key,
    required this.selectedSort,
    required this.selectedView,
    required this.onSortChanged,
    required this.onViewChanged,
    required this.eventCount,
    this.isLoading = false,
    this.filterSummary,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          _buildTopRow(context),
          if (filterSummary != null) ...[
            const SizedBox(height: 8),
            _buildFilterSummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildTopRow(BuildContext context) {
    return Row(
      children: [
        // Event count and status
        Expanded(
          child: _buildEventCount(),
        ),
        
        const SizedBox(width: 16),
        
        // Sort dropdown
        _buildSortDropdown(),
        
        const SizedBox(width: 12),
        
        // View toggle
        _buildViewToggle(context),
      ],
    );
  }

  Widget _buildEventCount() {
    return Row(
      children: [
        if (isLoading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.dubaiTeal),
            ),
          )
        else
          const Icon(
            LucideIcons.calendar,
            size: 16,
            color: AppColors.textSecondary,
          ),
        const SizedBox(width: 8),
        Text(
          isLoading
              ? 'Loading events...'
              : '$eventCount event${eventCount != 1 ? 's' : ''} found',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSortDropdown() {
    return PopupMenuButton<SortOption>(
      initialValue: selectedSort,
      onSelected: onSortChanged,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.dubaiTeal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.dubaiTeal.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selectedSort.icon,
              size: 16,
              color: AppColors.dubaiTeal,
            ),
            const SizedBox(width: 6),
            Text(
              selectedSort.label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.dubaiTeal,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              LucideIcons.chevronDown,
              size: 14,
              color: AppColors.dubaiTeal,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => SortOption.values.map((option) {
        final isSelected = option == selectedSort;
        return PopupMenuItem<SortOption>(
          value: option,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  option.icon,
                  size: 16,
                  color: isSelected ? AppColors.dubaiTeal : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? AppColors.dubaiTeal : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        option.description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    LucideIcons.check,
                    size: 16,
                    color: AppColors.dubaiTeal,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildViewToggle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dubaiTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ViewMode.values.map((mode) {
          final isSelected = mode == selectedView;
          return GestureDetector(
            onTap: () => onViewChanged(mode),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.dubaiTeal : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mode.icon,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.dubaiTeal,
                  ),
                  if (MediaQuery.of(context).size.width > 400) ...[
                    const SizedBox(width: 6),
                    Text(
                      mode.label.split(' ')[0], // Show just "Grid" or "List"
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.dubaiTeal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.dubaiCoral.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dubaiCoral.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.filter,
            size: 14,
            color: AppColors.dubaiCoral,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              filterSummary!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.dubaiCoral,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create filter summary
  static String createFilterSummary({
    String? dateRange,
    List<String> locations = const [],
    List<String> categories = const [],
    List<String> ageGroups = const [],
    double? minPrice,
    double? maxPrice,
    List<String> timeOfDay = const [],
    List<String> features = const [],
  }) {
    List<String> summaryParts = [];

    if (dateRange != null) {
      summaryParts.add(dateRange);
    }

    if (locations.isNotEmpty) {
      if (locations.length == 1) {
        summaryParts.add(locations.first);
      } else {
        summaryParts.add('${locations.length} locations');
      }
    }

    if (categories.isNotEmpty) {
      if (categories.length == 1) {
        summaryParts.add(categories.first);
      } else {
        summaryParts.add('${categories.length} categories');
      }
    }

    if (ageGroups.isNotEmpty) {
      if (ageGroups.length == 1) {
        summaryParts.add(ageGroups.first);
      } else {
        summaryParts.add('${ageGroups.length} age groups');
      }
    }

    if (minPrice != null || maxPrice != null) {
      if (minPrice != null && maxPrice != null) {
        if (minPrice == 0) {
          summaryParts.add('Free - AED ${maxPrice.round()}');
        } else {
          summaryParts.add('AED ${minPrice.round()} - ${maxPrice.round()}');
        }
      } else if (minPrice != null) {
        summaryParts.add('From AED ${minPrice.round()}');
      } else if (maxPrice != null) {
        summaryParts.add('Up to AED ${maxPrice.round()}');
      }
    }

    if (timeOfDay.isNotEmpty) {
      if (timeOfDay.length == 1) {
        summaryParts.add(timeOfDay.first);
      } else {
        summaryParts.add('${timeOfDay.length} time slots');
      }
    }

    if (features.isNotEmpty) {
      if (features.length == 1) {
        summaryParts.add(features.first);
      } else {
        summaryParts.add('${features.length} features');
      }
    }

    if (summaryParts.isEmpty) {
      return 'No active filters';
    }

    return 'Filtered by: ${summaryParts.take(3).join(', ')}${summaryParts.length > 3 ? '...' : ''}';
  }
} 