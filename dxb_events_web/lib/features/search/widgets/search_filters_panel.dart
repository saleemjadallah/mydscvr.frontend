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
import '../../../models/search.dart';

/// Comprehensive search filters panel for Dubai Events
class SearchFiltersPanel extends ConsumerStatefulWidget {
  const SearchFiltersPanel({super.key});

  @override
  ConsumerState<SearchFiltersPanel> createState() => _SearchFiltersPanelState();
}

class _SearchFiltersPanelState extends ConsumerState<SearchFiltersPanel>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Filter state
  RangeValues _priceRange = const RangeValues(0, 1000);
  RangeValues _ageRange = const RangeValues(0, 18);
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize with current filter values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentFilters = ref.read(searchFiltersProvider);
      setState(() {
        _priceRange = RangeValues(
          currentFilters.priceMin?.toDouble() ?? 0,
          currentFilters.priceMax?.toDouble() ?? 1000,
        );
        _ageRange = RangeValues(
          currentFilters.ageMin?.toDouble() ?? 0,
          currentFilters.ageMax?.toDouble() ?? 18,
        );
        _startDate = currentFilters.dateFrom;
        _endDate = currentFilters.dateTo;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final notifier = ref.read(searchFiltersProvider.notifier);
    final currentFilters = ref.read(searchFiltersProvider);
    
    final newFilters = SearchFilters(
      category: currentFilters.category,
      areas: currentFilters.areas,
      priceMin: _priceRange.start == 0 ? null : _priceRange.start,
      priceMax: _priceRange.end == 1000 ? null : _priceRange.end,
      ageMin: _ageRange.start == 0 ? null : _ageRange.start.toInt(),
      ageMax: _ageRange.end == 18 ? null : _ageRange.end.toInt(),
      dateFrom: _startDate,
      dateTo: _endDate,
      familyFriendlyOnly: currentFilters.familyFriendlyOnly,
      freeEventsOnly: currentFilters.freeEventsOnly,
      hasParking: currentFilters.hasParking,
      wheelchairAccessible: currentFilters.wheelchairAccessible,
    );
    
    // Update filters in both providers
    notifier.updateFilters(newFilters);
    ref.read(searchProvider.notifier).updateFilters(newFilters);
  }

  void _clearAllFilters() {
    ref.read(searchFiltersProvider.notifier).clearAllFilters();
    ref.read(searchProvider.notifier).updateFilters(const SearchFilters());
    
    setState(() {
      _priceRange = const RangeValues(0, 1000);
      _ageRange = const RangeValues(0, 18);
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkModeProvider);
    final filters = ref.watch(searchFiltersProvider);
    
    return Container(
      margin: const EdgeInsets.all(16),
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.dubaiGold.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    LucideIcons.filter,
                    color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filter Events',
                    style: AppTypography.h3.copyWith(
                      color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: Text(
                      'Clear All',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.dubaiCoral,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Filter Tabs
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? AppColors.surfaceDark.withOpacity(0.5)
                      : AppColors.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: AppColors.sunsetGradient,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: isDarkMode 
                      ? AppColors.textSecondaryLight 
                      : AppColors.textSecondaryDark,
                  labelStyle: AppTypography.body2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: AppTypography.body2,
                  tabs: const [
                    Tab(text: 'Category'),
                    Tab(text: 'Location'),
                    Tab(text: 'Details'),
                    Tab(text: 'Date'),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Filter Content
              SizedBox(
                height: 300,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCategoryFilter(),
                    _buildLocationFilter(),
                    _buildDetailsFilter(),
                    _buildDateFilter(),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Apply Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dubaiGold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.check, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Apply Filters',
                        style: AppTypography.button.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate()
                .slideY(duration: 400.ms, begin: 0.3)
                .fade(delay: 200.ms),
            ],
          ),
        ),
      ),
    ).animate()
      .slideY(duration: 300.ms, begin: -0.2)
      .fade();
  }

  Widget _buildCategoryFilter() {
    return Consumer(
      builder: (context, ref, child) {
        final categoriesAsync = ref.watch(searchCategoriesProvider);
        final currentFilters = ref.watch(searchFiltersProvider);
        
        return categoriesAsync.when(
          data: (categories) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Categories',
                  style: AppTypography.h4.copyWith(
                    color: ref.watch(darkModeProvider) 
                        ? AppColors.textLight 
                        : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: categories.map((category) {
                    final isSelected = currentFilters.category == category;
                    return FilterChip(
                      selected: isSelected,
                      label: Text(category),
                      onSelected: (selected) {
                        ref.read(searchFiltersProvider.notifier).updateCategory(
                          selected ? category : null,
                        );
                      },
                      backgroundColor: Colors.transparent,
                      selectedColor: AppColors.dubaiGold.withOpacity(0.2),
                      checkmarkColor: AppColors.dubaiGold,
                      labelStyle: AppTypography.body2.copyWith(
                        color: isSelected 
                            ? AppColors.dubaiGold 
                            : (ref.watch(darkModeProvider) 
                                ? AppColors.textLight 
                                : AppColors.textDark),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected 
                            ? AppColors.dubaiGold 
                            : AppColors.textSecondaryDark.withOpacity(0.3),
                      ),
                    ).animate()
                      .scale(duration: 200.ms)
                      .fade();
                  }).toList(),
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading categories: $error'),
          ),
        );
      },
    );
  }

  Widget _buildLocationFilter() {
    return Consumer(
      builder: (context, ref, child) {
        final areasAsync = ref.watch(searchAreasProvider);
        final currentFilters = ref.watch(searchFiltersProvider);
        
        return areasAsync.when(
          data: (areas) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Areas in Dubai',
                  style: AppTypography.h4.copyWith(
                    color: ref.watch(darkModeProvider) 
                        ? AppColors.textLight 
                        : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                ...areas.map((area) {
                  final isSelected = currentFilters.areas?.contains(area) ?? false;
                  return CheckboxListTile(
                    title: Text(
                      area,
                      style: AppTypography.body1.copyWith(
                        color: ref.watch(darkModeProvider) 
                            ? AppColors.textLight 
                            : AppColors.textDark,
                      ),
                    ),
                    value: isSelected,
                    onChanged: (selected) {
                      final currentAreas = List<String>.from(currentFilters.areas ?? []);
                      if (selected == true) {
                        currentAreas.add(area);
                      } else {
                        currentAreas.remove(area);
                      }
                      ref.read(searchFiltersProvider.notifier).updateAreas(
                        currentAreas.isEmpty ? null : currentAreas,
                      );
                    },
                    activeColor: AppColors.dubaiGold,
                    checkColor: Colors.white,
                  );
                }).toList(),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading areas: $error'),
          ),
        );
      },
    );
  }

  Widget _buildDetailsFilter() {
    final isDarkMode = ref.watch(darkModeProvider);
    final currentFilters = ref.watch(searchFiltersProvider);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price Range
          Text(
            'Price Range (AED)',
            style: AppTypography.h4.copyWith(
              color: isDarkMode ? AppColors.textLight : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_priceRange.start.toInt()} - ${_priceRange.end.toInt()} AED',
            style: AppTypography.body2.copyWith(
              color: AppColors.dubaiGold,
              fontWeight: FontWeight.w600,
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.dubaiGold,
              inactiveTrackColor: AppColors.dubaiGold.withOpacity(0.3),
              thumbColor: AppColors.dubaiGold,
              overlayColor: AppColors.dubaiGold.withOpacity(0.2),
            ),
            child: RangeSlider(
              values: _priceRange,
              min: 0,
              max: 1000,
              divisions: 20,
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Age Range
          Text(
            'Age Range',
            style: AppTypography.h4.copyWith(
              color: isDarkMode ? AppColors.textLight : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_ageRange.start.toInt()} - ${_ageRange.end.toInt()} years',
            style: AppTypography.body2.copyWith(
              color: AppColors.dubaiTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.dubaiTeal,
              inactiveTrackColor: AppColors.dubaiTeal.withOpacity(0.3),
              thumbColor: AppColors.dubaiTeal,
              overlayColor: AppColors.dubaiTeal.withOpacity(0.2),
            ),
            child: RangeSlider(
              values: _ageRange,
              min: 0,
              max: 18,
              divisions: 18,
              onChanged: (values) {
                setState(() {
                  _ageRange = values;
                });
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Boolean Filters
          _buildBooleanFilter(
            'Family Friendly Only',
            currentFilters.familyFriendlyOnly ?? false,
            () => ref.read(searchFiltersProvider.notifier).toggleFamilyFriendlyOnly(),
            LucideIcons.users,
          ),
          
          _buildBooleanFilter(
            'Free Events Only',
            currentFilters.freeEventsOnly ?? false,
            () => ref.read(searchFiltersProvider.notifier).toggleFreeEventsOnly(),
            LucideIcons.gift,
          ),
          
          _buildBooleanFilter(
            'Parking Available',
            currentFilters.hasParking ?? false,
            () => ref.read(searchFiltersProvider.notifier).toggleHasParking(),
            LucideIcons.car,
          ),
          
          _buildBooleanFilter(
            'Wheelchair Accessible',
            currentFilters.wheelchairAccessible ?? false,
            () => ref.read(searchFiltersProvider.notifier).toggleWheelchairAccessible(),
            LucideIcons.accessibility,
          ),
        ],
      ),
    );
  }

  Widget _buildBooleanFilter(
    String title,
    bool value,
    VoidCallback onToggle,
    IconData icon,
  ) {
    final isDarkMode = ref.watch(darkModeProvider);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: value 
                ? AppColors.dubaiGold 
                : (isDarkMode ? AppColors.textSecondaryLight : AppColors.textSecondaryDark),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTypography.body1.copyWith(
                color: isDarkMode ? AppColors.textLight : AppColors.textDark,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: (_) => onToggle(),
            activeColor: AppColors.dubaiGold,
            activeTrackColor: AppColors.dubaiGold.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    final isDarkMode = ref.watch(darkModeProvider);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Dates',
            style: AppTypography.h4.copyWith(
              color: isDarkMode ? AppColors.textLight : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          
          // Start Date
          _buildDatePicker(
            'Start Date',
            _startDate,
            (date) => setState(() => _startDate = date),
          ),
          
          const SizedBox(height: 16),
          
          // End Date
          _buildDatePicker(
            'End Date',
            _endDate,
            (date) => setState(() => _endDate = date),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Date Filters
          Text(
            'Quick Filters',
            style: AppTypography.h4.copyWith(
              color: isDarkMode ? AppColors.textLight : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickDateFilter('Today', () {
                final now = DateTime.now();
                setState(() {
                  _startDate = now;
                  _endDate = now;
                });
              }),
              _buildQuickDateFilter('This Weekend', () {
                final now = DateTime.now();
                final friday = now.add(Duration(days: 5 - now.weekday));
                final sunday = friday.add(const Duration(days: 2));
                setState(() {
                  _startDate = friday;
                  _endDate = sunday;
                });
              }),
              _buildQuickDateFilter('Next Week', () {
                final now = DateTime.now();
                final nextMonday = now.add(Duration(days: 8 - now.weekday));
                final nextSunday = nextMonday.add(const Duration(days: 6));
                setState(() {
                  _startDate = nextMonday;
                  _endDate = nextSunday;
                });
              }),
              _buildQuickDateFilter('This Month', () {
                final now = DateTime.now();
                final firstDay = DateTime(now.year, now.month, 1);
                final lastDay = DateTime(now.year, now.month + 1, 0);
                setState(() {
                  _startDate = firstDay;
                  _endDate = lastDay;
                });
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? selectedDate,
    ValueChanged<DateTime?> onDateSelected,
  ) {
    final isDarkMode = ref.watch(darkModeProvider);
    
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.dubaiGold,
                ),
              ),
              child: child!,
            );
          },
        );
        onDateSelected(date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDarkMode 
                ? AppColors.textSecondaryLight.withOpacity(0.3)
                : AppColors.textSecondaryDark.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.calendar,
              color: isDarkMode ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.body2.copyWith(
                      color: isDarkMode ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
                    ),
                  ),
                  Text(
                    selectedDate != null 
                        ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                        : 'Select date',
                    style: AppTypography.body1.copyWith(
                      color: selectedDate != null 
                          ? (isDarkMode ? AppColors.textLight : AppColors.textDark)
                          : (isDarkMode ? AppColors.textSecondaryLight : AppColors.textSecondaryDark),
                    ),
                  ),
                ],
              ),
            ),
            if (selectedDate != null)
              GestureDetector(
                onTap: () => onDateSelected(null),
                child: Icon(
                  LucideIcons.x,
                  color: AppColors.textSecondaryDark,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateFilter(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.dubaiGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.dubaiGold.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.body2.copyWith(
            color: AppColors.dubaiGold,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
} 