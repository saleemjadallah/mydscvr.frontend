import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../models/event.dart';

/// Advanced filter panel that utilizes all enhanced backend filtering capabilities
class AdvancedFilterPanel extends StatefulWidget {
  final EventsFilter? initialFilter;
  final Function(Map<String, dynamic>) onFiltersChanged;
  final VoidCallback? onReset;

  const AdvancedFilterPanel({
    super.key,
    this.initialFilter,
    required this.onFiltersChanged,
    this.onReset,
  });

  @override
  State<AdvancedFilterPanel> createState() => _AdvancedFilterPanelState();
}

class _AdvancedFilterPanelState extends State<AdvancedFilterPanel> {
  // Filter state
  RangeValues _priceRange = const RangeValues(0, 500);
  List<String> _selectedAreas = [];
  List<String> _selectedCategories = [];
  List<String> _selectedFeatures = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _freeOnly = false;
  bool _familyFriendlyOnly = false;
  bool _metroAccessibleOnly = false;
  String? _selectedLanguage;
  String? _selectedVenueType;
  String? _selectedEventType;
  String? _selectedSourceReliability;
  
  // Available options
  final List<String> _dubaiAreas = [
    'Downtown',
    'Dubai Marina',
    'JBR',
    'Jumeirah',
    'Business Bay',
    'DIFC',
    'Deira',
    'Bur Dubai',
    'Al Barsha',
    'Dubai Hills',
    'Palm Jumeirah',
    'Dubai South',
    'Al Ain',
    'Sharjah',
  ];

  final List<String> _eventCategories = [
    'family',
    'dining',
    'outdoor',
    'indoor',
    'cultural',
    'entertainment',
    'sports',
    'nightlife',
    'shopping',
    'business',
    'educational',
    'festivals',
  ];

  final List<String> _eventFeatures = [
    'metro_accessible',
    'free_parking',
    'indoor',
    'outdoor',
    'child_friendly',
    'wheelchair_accessible',
    'alcohol_free',
    'stroller_friendly',
    'educational_content',
  ];

  final List<String> _languages = [
    'english',
    'arabic',
    'bilingual',
    'multilingual',
  ];

  final List<String> _venueTypes = [
    'indoor',
    'outdoor',
    'both',
  ];

  final List<String> _eventTypes = [
    'conference',
    'workshop',
    'concert',
    'party',
    'exhibition',
    'festival',
    'sports_event',
    'dining_experience',
    'tour',
    'class',
    'meetup',
    'show',
  ];

  final List<String> _sourceReliabilities = [
    'high',
    'medium',
    'low',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range
                  _buildDateRangeSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Price Range
                  _buildPriceRangeSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Areas
                  _buildMultiSelectSection(
                    title: 'Areas',
                    icon: LucideIcons.mapPin,
                    options: _dubaiAreas,
                    selectedValues: _selectedAreas,
                    onChanged: (values) => setState(() => _selectedAreas = values),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Categories
                  _buildMultiSelectSection(
                    title: 'Event Categories',
                    icon: LucideIcons.tag,
                    options: _eventCategories,
                    selectedValues: _selectedCategories,
                    onChanged: (values) => setState(() => _selectedCategories = values),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Features
                  _buildMultiSelectSection(
                    title: 'Features & Amenities',
                    icon: LucideIcons.checkCircle,
                    options: _eventFeatures,
                    selectedValues: _selectedFeatures,
                    onChanged: (values) => setState(() => _selectedFeatures = values),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Single select options
                  _buildSingleSelectSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Boolean filters
                  _buildBooleanFiltersSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Quality filters
                  _buildQualityFiltersSection(),
                ],
              ),
            ),
          ),
          
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.sunsetGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.filter,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Advanced Filters',
            style: GoogleFonts.comfortaa(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              LucideIcons.x,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return _buildFilterSection(
      title: 'Date Range',
      icon: LucideIcons.calendar,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Start Date',
                  value: _startDate,
                  onTap: () => _selectStartDate(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  label: 'End Date',
                  value: _endDate,
                  onTap: () => _selectEndDate(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildQuickDateButton('This Weekend', () => _setThisWeekend()),
              const SizedBox(width: 8),
              _buildQuickDateButton('Next Week', () => _setNextWeek()),
              const SizedBox(width: 8),
              _buildQuickDateButton('This Month', () => _setThisMonth()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeSection() {
    return _buildFilterSection(
      title: 'Price Range (AED)',
      icon: LucideIcons.dollarSign,
      child: Column(
        children: [
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 1000,
            divisions: 20,
            activeColor: AppColors.dubaiTeal,
            labels: RangeLabels(
              _priceRange.start.round() == 0 ? 'Free' : 'AED ${_priceRange.start.round()}',
              'AED ${_priceRange.end.round()}',
            ),
            onChanged: (values) => setState(() => _priceRange = values),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _priceRange.start.round() == 0 ? 'Free' : 'AED ${_priceRange.start.round()}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'AED ${_priceRange.end.round()}',
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

  Widget _buildMultiSelectSection({
    required String title,
    required IconData icon,
    required List<String> options,
    required List<String> selectedValues,
    required Function(List<String>) onChanged,
  }) {
    return _buildFilterSection(
      title: title,
      icon: icon,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          final isSelected = selectedValues.contains(option);
          return FilterChip(
            label: Text(
              _formatOptionLabel(option),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              final newValues = List<String>.from(selectedValues);
              if (selected) {
                newValues.add(option);
              } else {
                newValues.remove(option);
              }
              onChanged(newValues);
            },
            selectedColor: AppColors.dubaiTeal,
            backgroundColor: Colors.grey[100],
            side: BorderSide(
              color: isSelected ? AppColors.dubaiTeal : Colors.grey[300]!,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSingleSelectSection() {
    return Column(
      children: [
        // Language
        _buildDropdownSection(
          title: 'Language Requirements',
          icon: LucideIcons.globe,
          value: _selectedLanguage,
          options: _languages,
          onChanged: (value) => setState(() => _selectedLanguage = value),
        ),
        
        const SizedBox(height: 16),
        
        // Venue Type
        _buildDropdownSection(
          title: 'Venue Type',
          icon: LucideIcons.building,
          value: _selectedVenueType,
          options: _venueTypes,
          onChanged: (value) => setState(() => _selectedVenueType = value),
        ),
        
        const SizedBox(height: 16),
        
        // Event Type
        _buildDropdownSection(
          title: 'Event Type',
          icon: LucideIcons.calendar,
          value: _selectedEventType,
          options: _eventTypes,
          onChanged: (value) => setState(() => _selectedEventType = value),
        ),
      ],
    );
  }

  Widget _buildBooleanFiltersSection() {
    return _buildFilterSection(
      title: 'Quick Filters',
      icon: LucideIcons.toggleLeft,
      child: Column(
        children: [
          _buildSwitchTile(
            title: 'Free Events Only',
            subtitle: 'Show only events with no entry fee',
            value: _freeOnly,
            onChanged: (value) => setState(() => _freeOnly = value),
          ),
          _buildSwitchTile(
            title: 'Family Friendly Only',
            subtitle: 'Show only family-suitable events',
            value: _familyFriendlyOnly,
            onChanged: (value) => setState(() => _familyFriendlyOnly = value),
          ),
          _buildSwitchTile(
            title: 'Metro Accessible',
            subtitle: 'Show only metro-accessible venues',
            value: _metroAccessibleOnly,
            onChanged: (value) => setState(() => _metroAccessibleOnly = value),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityFiltersSection() {
    return _buildFilterSection(
      title: 'Data Quality',
      icon: LucideIcons.shield,
      child: _buildDropdownSection(
        title: 'Source Reliability',
        icon: LucideIcons.checkCircle,
        value: _selectedSourceReliability,
        options: _sourceReliabilities,
        onChanged: (value) => setState(() => _selectedSourceReliability = value),
        showTitle: false,
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
              size: 18,
              color: AppColors.dubaiTeal,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.comfortaa(
                fontSize: 16,
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

  Widget _buildDropdownSection({
    required String title,
    required IconData icon,
    required String? value,
    required List<String> options,
    required Function(String?) onChanged,
    bool showTitle = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
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
          const SizedBox(height: 8),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                'Select ${title.toLowerCase()}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'Any',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ),
                ...options.map((option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    _formatOptionLabel(option),
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                )),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.calendar,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value != null 
                        ? '${value.day}/${value.month}/${value.year}'
                        : 'Select date',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: value != null ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateButton(String label, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.dubaiTeal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.dubaiTeal,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.dubaiTeal,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _resetFilters,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.textSecondary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Reset',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dubaiTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatOptionLabel(String option) {
    return option
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }

  void _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  void _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()).add(const Duration(days: 7)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  void _setThisWeekend() {
    final now = DateTime.now();
    final daysUntilSaturday = 6 - now.weekday;
    final saturday = now.add(Duration(days: daysUntilSaturday));
    final sunday = saturday.add(const Duration(days: 1));
    setState(() {
      _startDate = saturday;
      _endDate = sunday;
    });
  }

  void _setNextWeek() {
    final now = DateTime.now();
    final startOfNextWeek = now.add(Duration(days: 7 - now.weekday + 1));
    final endOfNextWeek = startOfNextWeek.add(const Duration(days: 6));
    setState(() {
      _startDate = startOfNextWeek;
      _endDate = endOfNextWeek;
    });
  }

  void _setThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    setState(() {
      _startDate = startOfMonth;
      _endDate = endOfMonth;
    });
  }

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 500);
      _selectedAreas.clear();
      _selectedCategories.clear();
      _selectedFeatures.clear();
      _startDate = null;
      _endDate = null;
      _freeOnly = false;
      _familyFriendlyOnly = false;
      _metroAccessibleOnly = false;
      _selectedLanguage = null;
      _selectedVenueType = null;
      _selectedEventType = null;
      _selectedSourceReliability = null;
    });
    
    widget.onReset?.call();
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};
    
    // Price range
    if (_priceRange.start > 0 || _priceRange.end < 500) {
      filters['price_range'] = {
        'min': _priceRange.start.round(),
        'max': _priceRange.end.round(),
      };
    }
    
    // Areas
    if (_selectedAreas.isNotEmpty) {
      filters['areas'] = _selectedAreas;
    }
    
    // Categories
    if (_selectedCategories.isNotEmpty) {
      filters['categories'] = _selectedCategories;
    }
    
    // Features
    if (_selectedFeatures.isNotEmpty) {
      filters['features'] = _selectedFeatures;
    }
    
    // Date range
    if (_startDate != null && _endDate != null) {
      filters['dates'] = {
        'start': _startDate!.toIso8601String(),
        'end': _endDate!.toIso8601String(),
      };
    }
    
    // Boolean filters
    if (_freeOnly) filters['free_only'] = true;
    if (_familyFriendlyOnly) filters['family_friendly_only'] = true;
    if (_metroAccessibleOnly) filters['metro_accessible_only'] = true;
    
    // Single select filters
    if (_selectedLanguage != null) filters['language'] = _selectedLanguage;
    if (_selectedVenueType != null) filters['venue_type'] = _selectedVenueType;
    if (_selectedEventType != null) filters['event_type'] = _selectedEventType;
    if (_selectedSourceReliability != null) filters['source_reliability'] = _selectedSourceReliability;
    
    widget.onFiltersChanged(filters);
    Navigator.of(context).pop();
  }
}