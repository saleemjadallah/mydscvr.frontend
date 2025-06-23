import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_morphism.dart';

class EventFilterData {
  final String? dateRange;
  final List<String> locations;
  final List<String> categories;
  final List<String> ageGroups;
  final double? minPrice;
  final double? maxPrice;
  final List<String> timeOfDay;
  final List<String> features;
  final DateTime? customDateStart;
  final DateTime? customDateEnd;

  const EventFilterData({
    this.dateRange,
    this.locations = const [],
    this.categories = const [],
    this.ageGroups = const [],
    this.minPrice,
    this.maxPrice,
    this.timeOfDay = const [],
    this.features = const [],
    this.customDateStart,
    this.customDateEnd,
  });

  EventFilterData copyWith({
    String? dateRange,
    List<String>? locations,
    List<String>? categories,
    List<String>? ageGroups,
    double? minPrice,
    double? maxPrice,
    List<String>? timeOfDay,
    List<String>? features,
    DateTime? customDateStart,
    DateTime? customDateEnd,
  }) {
    return EventFilterData(
      dateRange: dateRange ?? this.dateRange,
      locations: locations ?? this.locations,
      categories: categories ?? this.categories,
      ageGroups: ageGroups ?? this.ageGroups,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      features: features ?? this.features,
      customDateStart: customDateStart ?? this.customDateStart,
      customDateEnd: customDateEnd ?? this.customDateEnd,
    );
  }

  bool get hasActiveFilters =>
      dateRange != null ||
      locations.isNotEmpty ||
      categories.isNotEmpty ||
      ageGroups.isNotEmpty ||
      minPrice != null ||
      maxPrice != null ||
      timeOfDay.isNotEmpty ||
      features.isNotEmpty ||
      customDateStart != null ||
      customDateEnd != null;

  int get activeFilterCount {
    int count = 0;
    if (dateRange != null) count++;
    if (locations.isNotEmpty) count++;
    if (categories.isNotEmpty) count++;
    if (ageGroups.isNotEmpty) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (timeOfDay.isNotEmpty) count++;
    if (features.isNotEmpty) count++;
    if (customDateStart != null || customDateEnd != null) count++;
    return count;
  }
}

class EventsFilterSidebar extends ConsumerStatefulWidget {
  final EventFilterData filters;
  final Function(EventFilterData) onFiltersChanged;
  final bool isExpanded;
  final VoidCallback onToggle;

  const EventsFilterSidebar({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  ConsumerState<EventsFilterSidebar> createState() => _EventsFilterSidebarState();
}

class _EventsFilterSidebarState extends ConsumerState<EventsFilterSidebar> {
  late EventFilterData _currentFilters;
  RangeValues _priceRange = const RangeValues(0, 500);

  static const List<String> _dateRangeOptions = [
    'Today',
    'This Weekend',
    'Next Week', 
    'This Month',
    'Custom Date'
  ];

  static const List<String> _locationOptions = [
    'Dubai Marina',
    'JBR',
    'DIFC',
    'Downtown Dubai',
    'Palm Jumeirah',
    'Jumeirah',
    'Deira',
    'Bur Dubai',
    'Business Bay',
    'Al Barsha',
    'Dubailand',
    'City Walk'
  ];

  static const List<String> _categoryOptions = [
    'Kids & Family',
    'Outdoor Activities', 
    'Indoor Activities',
    'Food & Dining',
    'Cultural',
    'Tours & Sightseeing',
    'Water Sports',
    'Music & Concerts',
    'Comedy & Shows',
    'Sports & Fitness',
    'Business & Networking',
    'Festivals & Celebrations'
  ];

  static const List<String> _ageGroupOptions = [
    'Toddlers (0-3)',
    'Kids (4-12)',
    'Teens (13-17)',
    'All Ages'
  ];

  static const List<String> _timeOfDayOptions = [
    'Morning',
    'Afternoon',
    'Evening',
    'All Day'
  ];

  static const List<String> _featureOptions = [
    'Stroller Friendly',
    'Parking Available',
    'Metro Access',
    'Indoor',
    'Outdoor',
    'Air Conditioned',
    'Free Entry',
    'Educational Content'
  ];

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.filters;
    if (_currentFilters.minPrice != null || _currentFilters.maxPrice != null) {
      _priceRange = RangeValues(
        _currentFilters.minPrice ?? 0,
        _currentFilters.maxPrice ?? 500,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          
          if (widget.isExpanded) ...[
            const Divider(height: 1),
            // Filter content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateRangeFilter(),
                    const SizedBox(height: 24),
                    _buildLocationFilter(),
                    const SizedBox(height: 24),
                    _buildCategoryFilter(),
                    const SizedBox(height: 24),
                    _buildAgeGroupFilter(),
                    const SizedBox(height: 24),
                    _buildPriceRangeFilter(),
                    const SizedBox(height: 24),
                    _buildTimeOfDayFilter(),
                    const SizedBox(height: 24),
                    _buildFeaturesFilter(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: widget.onToggle,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              LucideIcons.filter,
              color: AppColors.dubaiTeal,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Filters',
              style: GoogleFonts.comfortaa(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (_currentFilters.hasActiveFilters) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.dubaiCoral,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentFilters.activeFilterCount}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            const Spacer(),
            Icon(
              widget.isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return _buildFilterSection(
      title: 'Date Range',
      icon: LucideIcons.calendar,
      child: Column(
        children: [
          ..._dateRangeOptions.map((option) => _buildCheckboxTile(
                option,
                _currentFilters.dateRange == option,
                (selected) {
                  setState(() {
                    _currentFilters = _currentFilters.copyWith(
                      dateRange: selected ? option : null,
                    );
                  });
                  _notifyFiltersChanged();
                },
              )),
          if (_currentFilters.dateRange == 'Custom Date') ...[
            const SizedBox(height: 12),
            _buildCustomDatePicker(),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomDatePicker() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dubaiTeal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.dubaiTeal.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  'Start Date',
                  _currentFilters.customDateStart,
                  (date) {
                    setState(() {
                      _currentFilters = _currentFilters.copyWith(
                        customDateStart: date,
                      );
                    });
                    _notifyFiltersChanged();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  'End Date',
                  _currentFilters.customDateEnd,
                  (date) {
                    setState(() {
                      _currentFilters = _currentFilters.copyWith(
                        customDateEnd: date,
                      );
                    });
                    _notifyFiltersChanged();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? selectedDate, Function(DateTime?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            onChanged(date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              selectedDate != null
                  ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                  : 'Select date',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: selectedDate != null ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationFilter() {
    return _buildFilterSection(
      title: 'Location/Area',
      icon: LucideIcons.mapPin,
      child: Column(
        children: _locationOptions.map((location) => _buildCheckboxTile(
              location,
              _currentFilters.locations.contains(location),
              (selected) {
                setState(() {
                  final newLocations = List<String>.from(_currentFilters.locations);
                  if (selected) {
                    newLocations.add(location);
                  } else {
                    newLocations.remove(location);
                  }
                  _currentFilters = _currentFilters.copyWith(locations: newLocations);
                });
                _notifyFiltersChanged();
              },
            )).toList(),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return _buildFilterSection(
      title: 'Categories',
      icon: LucideIcons.tag,
      child: Column(
        children: _categoryOptions.map((category) => _buildCheckboxTile(
              category,
              _currentFilters.categories.contains(category),
              (selected) {
                setState(() {
                  final newCategories = List<String>.from(_currentFilters.categories);
                  if (selected) {
                    newCategories.add(category);
                  } else {
                    newCategories.remove(category);
                  }
                  _currentFilters = _currentFilters.copyWith(categories: newCategories);
                });
                _notifyFiltersChanged();
              },
            )).toList(),
      ),
    );
  }

  Widget _buildAgeGroupFilter() {
    return _buildFilterSection(
      title: 'Age Groups',
      icon: LucideIcons.users,
      child: Column(
        children: _ageGroupOptions.map((ageGroup) => _buildCheckboxTile(
              ageGroup,
              _currentFilters.ageGroups.contains(ageGroup),
              (selected) {
                setState(() {
                  final newAgeGroups = List<String>.from(_currentFilters.ageGroups);
                  if (selected) {
                    newAgeGroups.add(ageGroup);
                  } else {
                    newAgeGroups.remove(ageGroup);
                  }
                  _currentFilters = _currentFilters.copyWith(ageGroups: newAgeGroups);
                });
                _notifyFiltersChanged();
              },
            )).toList(),
      ),
    );
  }

  Widget _buildPriceRangeFilter() {
    return _buildFilterSection(
      title: 'Price Range (AED)',
      icon: LucideIcons.dollarSign,
      child: Column(
        children: [
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 500,
            divisions: 10,
            activeColor: AppColors.dubaiTeal,
            inactiveColor: AppColors.dubaiTeal.withValues(alpha: 0.3),
            labels: RangeLabels(
              _priceRange.start == 0 ? 'Free' : 'AED ${_priceRange.start.round()}',
              'AED ${_priceRange.end.round()}',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _priceRange = values;
                _currentFilters = _currentFilters.copyWith(
                  minPrice: values.start == 0 ? null : values.start,
                  maxPrice: values.end == 500 ? null : values.end,
                );
              });
              _notifyFiltersChanged();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _priceRange.start == 0 ? 'Free' : 'AED ${_priceRange.start.round()}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'AED ${_priceRange.end.round()}+',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOfDayFilter() {
    return _buildFilterSection(
      title: 'Time of Day',
      icon: LucideIcons.clock,
      child: Column(
        children: _timeOfDayOptions.map((time) => _buildCheckboxTile(
              time,
              _currentFilters.timeOfDay.contains(time),
              (selected) {
                setState(() {
                  final newTimeOfDay = List<String>.from(_currentFilters.timeOfDay);
                  if (selected) {
                    newTimeOfDay.add(time);
                  } else {
                    newTimeOfDay.remove(time);
                  }
                  _currentFilters = _currentFilters.copyWith(timeOfDay: newTimeOfDay);
                });
                _notifyFiltersChanged();
              },
            )).toList(),
      ),
    );
  }

  Widget _buildFeaturesFilter() {
    return _buildFilterSection(
      title: 'Features',
      icon: LucideIcons.star,
      child: Column(
        children: _featureOptions.map((feature) => _buildCheckboxTile(
              feature,
              _currentFilters.features.contains(feature),
              (selected) {
                setState(() {
                  final newFeatures = List<String>.from(_currentFilters.features);
                  if (selected) {
                    newFeatures.add(feature);
                  } else {
                    newFeatures.remove(feature);
                  }
                  _currentFilters = _currentFilters.copyWith(features: newFeatures);
                });
                _notifyFiltersChanged();
              },
            )).toList(),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.dubaiTeal,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildCheckboxTile(String title, bool isSelected, Function(bool) onChanged) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? AppColors.dubaiTeal : AppColors.borderLight,
                  width: 2,
                ),
                color: isSelected ? AppColors.dubaiTeal : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      LucideIcons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _currentFilters.hasActiveFilters ? _clearAllFilters : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dubaiCoral,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Clear All Filters',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Could add saved filter functionality here
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.dubaiTeal,
              side: const BorderSide(color: AppColors.dubaiTeal),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Save Filters',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _clearAllFilters() {
    setState(() {
      _currentFilters = const EventFilterData();
      _priceRange = const RangeValues(0, 500);
    });
    _notifyFiltersChanged();
  }

  void _notifyFiltersChanged() {
    widget.onFiltersChanged(_currentFilters);
  }
} 