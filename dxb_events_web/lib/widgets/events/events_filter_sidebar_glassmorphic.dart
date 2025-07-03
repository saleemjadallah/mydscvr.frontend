import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/events/events_filter_sidebar.dart';

class EventsFilterSidebarGlassmorphic extends StatefulWidget {
  final EventFilterData filters;
  final Function(EventFilterData) onFiltersChanged;
  final bool isExpanded;
  final VoidCallback onToggle;

  const EventsFilterSidebarGlassmorphic({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<EventsFilterSidebarGlassmorphic> createState() => _EventsFilterSidebarGlassmorphicState();
}

class _EventsFilterSidebarGlassmorphicState extends State<EventsFilterSidebarGlassmorphic> {
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 60,
        maxHeight: widget.isExpanded ? MediaQuery.of(context).size.height * 0.8 : 60,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Filter header
            Row(
              children: [
                Icon(
                  LucideIcons.filter,
                  color: const Color(0xFFFF6B6B),
                  size: isMobile ? 18 : 20,
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Flexible(
                  child: Text(
                    'Filters',
                    style: GoogleFonts.comfortaa(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.filters.hasActiveFilters)
                  Flexible(
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => widget.onFiltersChanged(const EventFilterData()),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 6 : 8, 
                            vertical: 4
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFFFB347)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Clear All',
                            style: GoogleFonts.inter(
                              fontSize: isMobile ? 10 : 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: widget.onToggle,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        widget.isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                        color: const Color(0xFF666666),
                        size: isMobile ? 18 : 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            if (widget.isExpanded) ...[
              SizedBox(height: isMobile ? 12 : 16),
              
              // Scrollable content with responsive layout
              Flexible(
                child: SingleChildScrollView(
                  child: screenWidth > 1200 
                    ? _buildDesktopHorizontalLayout(isMobile)
                    : _buildVerticalLayout(isMobile),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFFF6B6B),
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            style: GoogleFonts.comfortaa(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF666666),
            ),
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
        content,
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final dateRanges = isMobile 
        ? ['Today', 'Weekend', 'Week', 'Month']  // Shorter labels for mobile
        : ['Today', 'This Weekend', 'Next Week', 'This Month'];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: isMobile ? 6 : 8,
          runSpacing: isMobile ? 6 : 8,
          children: dateRanges.map((range) {
            final isSelected = widget.filters.dateRange == range || 
                (isMobile && _getMobileEquivalent(range) == widget.filters.dateRange);
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  final actualRange = isMobile ? _getFullRangeFromMobile(range) : range;
                  final newFilters = widget.filters.copyWith(
                    dateRange: isSelected ? null : actualRange,
                  );
                  widget.onFiltersChanged(newFilters);
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * (isMobile ? 0.45 : 0.3),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 12, 
                    vertical: isMobile ? 6 : 8
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? null
                        : Colors.white,
                    gradient: isSelected 
                        ? const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFFB347)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.transparent
                          : const Color(0xFFFF6B6B),
                    ),
                  ),
                  child: Text(
                    range,
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 10 : 12,
                      color: isSelected ? Colors.white : const Color(0xFFFF6B6B),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildLocationFilter() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final locations = isMobile 
        ? ['Marina', 'Downtown', 'Jumeirah', 'DIFC', 'Bus. Bay']  // Shorter labels
        : ['Dubai Marina', 'Downtown Dubai', 'Jumeirah', 'DIFC', 'Business Bay'];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: isMobile ? 6 : 8,
          runSpacing: isMobile ? 6 : 8,
          children: locations.map((location) {
            final isSelected = widget.filters.locations.contains(location) ||
                widget.filters.locations.any((selected) => 
                    _getFullLocationFromMobile(location).contains(selected) ||
                    selected.contains(_getFullLocationFromMobile(location)));
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  final actualLocation = isMobile ? _getFullLocationFromMobile(location) : location;
                  final newLocations = List<String>.from(widget.filters.locations);
                  if (isSelected) {
                    newLocations.removeWhere((loc) => 
                        loc == actualLocation || 
                        actualLocation.contains(loc) ||
                        loc.contains(actualLocation));
                  } else {
                    newLocations.add(actualLocation);
                  }
                  final newFilters = widget.filters.copyWith(locations: newLocations);
                  widget.onFiltersChanged(newFilters);
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * (isMobile ? 0.45 : 0.35),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 12, 
                    vertical: isMobile ? 6 : 8
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? null
                        : Colors.white,
                    gradient: isSelected 
                        ? const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFFB347)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.transparent
                          : const Color(0xFFFF6B6B),
                    ),
                  ),
                  child: Text(
                    location,
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 10 : 12,
                      color: isSelected ? Colors.white : const Color(0xFFFF6B6B),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategoriesFilter() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final categories = isMobile 
        ? ['Family', 'Cultural', 'Education', 'Fun', 'Outdoor']  // Shorter labels
        : ['Family Fun', 'Cultural', 'Educational', 'Entertainment', 'Outdoor'];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: isMobile ? 6 : 8,
          runSpacing: isMobile ? 6 : 8,
          children: categories.map((category) {
            final isSelected = widget.filters.categories.contains(category) ||
                widget.filters.categories.any((selected) => 
                    _getFullCategoryFromMobile(category).contains(selected) ||
                    selected.contains(_getFullCategoryFromMobile(category)));
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  final actualCategory = isMobile ? _getFullCategoryFromMobile(category) : category;
                  final newCategories = List<String>.from(widget.filters.categories);
                  if (isSelected) {
                    newCategories.removeWhere((cat) => 
                        cat == actualCategory || 
                        actualCategory.contains(cat) ||
                        cat.contains(actualCategory));
                  } else {
                    newCategories.add(actualCategory);
                  }
                  final newFilters = widget.filters.copyWith(categories: newCategories);
                  widget.onFiltersChanged(newFilters);
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * (isMobile ? 0.45 : 0.35),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 12, 
                    vertical: isMobile ? 6 : 8
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? null
                        : Colors.white,
                    gradient: isSelected 
                        ? const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFFB347)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.transparent
                          : const Color(0xFFFF6B6B),
                    ),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 10 : 12,
                      color: isSelected ? Colors.white : const Color(0xFFFF6B6B),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAgeGroupsFilter() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final ageGroups = isMobile 
        ? ['0-3', '4-12', '13-17', 'All']  // Much shorter labels
        : ['Toddlers (0-3)', 'Kids (4-12)', 'Teens (13-17)', 'All Ages'];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: isMobile ? 6 : 8,
          runSpacing: isMobile ? 6 : 8,
          children: ageGroups.map((ageGroup) {
            final isSelected = widget.filters.ageGroups.contains(ageGroup) ||
                widget.filters.ageGroups.any((selected) => 
                    _getFullAgeGroupFromMobile(ageGroup).contains(selected) ||
                    selected.contains(_getFullAgeGroupFromMobile(ageGroup)));
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  final actualAgeGroup = isMobile ? _getFullAgeGroupFromMobile(ageGroup) : ageGroup;
                  final newAgeGroups = List<String>.from(widget.filters.ageGroups);
                  if (isSelected) {
                    newAgeGroups.removeWhere((age) => 
                        age == actualAgeGroup || 
                        actualAgeGroup.contains(age) ||
                        age.contains(actualAgeGroup));
                  } else {
                    newAgeGroups.add(actualAgeGroup);
                  }
                  final newFilters = widget.filters.copyWith(ageGroups: newAgeGroups);
                  widget.onFiltersChanged(newFilters);
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * (isMobile ? 0.22 : 0.4),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 12, 
                    vertical: isMobile ? 6 : 8
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? null
                        : Colors.white,
                    gradient: isSelected 
                        ? const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFFB347)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.transparent
                          : const Color(0xFFFF6B6B),
                    ),
                  ),
                  child: Text(
                    ageGroup,
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 10 : 12,
                      color: isSelected ? Colors.white : const Color(0xFFFF6B6B),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPriceRangeFilter() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12, 
                  vertical: isMobile ? 6 : 8
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
                ),
                child: TextField(
                  style: GoogleFonts.inter(
                    color: const Color(0xFF333333), 
                    fontSize: isMobile ? 12 : 14
                  ),
                  decoration: InputDecoration(
                    hintText: isMobile ? 'Min' : 'Min AED',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF999999),
                      fontSize: isMobile ? 12 : 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final minPrice = double.tryParse(value);
                    final newFilters = widget.filters.copyWith(minPrice: minPrice);
                    widget.onFiltersChanged(newFilters);
                  },
                ),
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12, 
                  vertical: isMobile ? 6 : 8
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
                ),
                child: TextField(
                  style: GoogleFonts.inter(
                    color: const Color(0xFF333333), 
                    fontSize: isMobile ? 12 : 14
                  ),
                  decoration: InputDecoration(
                    hintText: isMobile ? 'Max' : 'Max AED',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF999999),
                      fontSize: isMobile ? 12 : 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final maxPrice = double.tryParse(value);
                    final newFilters = widget.filters.copyWith(maxPrice: maxPrice);
                    widget.onFiltersChanged(newFilters);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturesFilter() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final features = isMobile 
        ? [
            'Stroller OK', 
            'Parking', 
            'Metro', 
            'Indoor', 
            'Outdoor', 
            'Free',
            'Education'
          ]  // Much shorter labels for mobile
        : [
            'Stroller Friendly', 
            'Parking Available', 
            'Metro Access', 
            'Indoor', 
            'Outdoor', 
            'Free Entry',
            'Educational Content'
          ];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: isMobile ? 6 : 8,
          runSpacing: isMobile ? 6 : 8,
          children: features.map((feature) {
            final isSelected = widget.filters.features.contains(feature) ||
                widget.filters.features.any((selected) => 
                    _getFullFeatureFromMobile(feature).contains(selected) ||
                    selected.contains(_getFullFeatureFromMobile(feature)));
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  final actualFeature = isMobile ? _getFullFeatureFromMobile(feature) : feature;
                  final newFeatures = List<String>.from(widget.filters.features);
                  if (isSelected) {
                    newFeatures.removeWhere((feat) => 
                        feat == actualFeature || 
                        actualFeature.contains(feat) ||
                        feat.contains(actualFeature));
                  } else {
                    newFeatures.add(actualFeature);
                  }
                  final newFilters = widget.filters.copyWith(features: newFeatures);
                  widget.onFiltersChanged(newFilters);
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * (isMobile ? 0.3 : 0.45),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 6 : 12, 
                    vertical: isMobile ? 6 : 8
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? null
                        : Colors.white,
                    gradient: isSelected 
                        ? const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFFB347)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.transparent
                          : const Color(0xFFFF6B6B),
                    ),
                  ),
                  child: Text(
                    feature,
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 9 : 12,
                      color: isSelected ? Colors.white : const Color(0xFFFF6B6B),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Helper methods to map mobile labels to full labels
  String _getMobileEquivalent(String mobileRange) {
    switch (mobileRange) {
      case 'Weekend': return 'This Weekend';
      case 'Week': return 'Next Week';
      case 'Month': return 'This Month';
      default: return mobileRange;
    }
  }

  String _getFullRangeFromMobile(String mobileRange) {
    switch (mobileRange) {
      case 'Weekend': return 'This Weekend';
      case 'Week': return 'Next Week';
      case 'Month': return 'This Month';
      default: return mobileRange;
    }
  }

  String _getFullLocationFromMobile(String mobileLocation) {
    switch (mobileLocation) {
      case 'Marina': return 'Dubai Marina';
      case 'Downtown': return 'Downtown Dubai';
      case 'Bus. Bay': return 'Business Bay';
      default: return mobileLocation;
    }
  }

  String _getFullCategoryFromMobile(String mobileCategory) {
    switch (mobileCategory) {
      case 'Family': return 'Family Fun';
      case 'Education': return 'Educational';
      case 'Fun': return 'Entertainment';
      default: return mobileCategory;
    }
  }

  String _getFullAgeGroupFromMobile(String mobileAgeGroup) {
    switch (mobileAgeGroup) {
      case '0-3': return 'Toddlers (0-3)';
      case '4-12': return 'Kids (4-12)';
      case '13-17': return 'Teens (13-17)';
      case 'All': return 'All Ages';
      default: return mobileAgeGroup;
    }
  }

  String _getFullFeatureFromMobile(String mobileFeature) {
    switch (mobileFeature) {
      case 'Stroller OK': return 'Stroller Friendly';
      case 'Parking': return 'Parking Available';
      case 'Metro': return 'Metro Access';
      case 'Free': return 'Free Entry';
      case 'Education': return 'Educational Content';
      default: return mobileFeature;
    }
  }

  // New horizontal layout for desktop screens > 1200px
  Widget _buildDesktopHorizontalLayout(bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Filter
              _buildFilterSection(
                'Date Range',
                _buildDateRangeFilter(),
                isMobile,
              ),
              
              SizedBox(height: isMobile ? 16 : 20),
              
              // Categories Filter
              _buildFilterSection(
                'Categories',
                _buildCategoriesFilter(),
                isMobile,
              ),
              
              SizedBox(height: isMobile ? 16 : 20),
              
              // Price Range Filter
              _buildFilterSection(
                'Price Range',
                _buildPriceRangeFilter(),
                isMobile,
              ),
            ],
          ),
        ),
        
        SizedBox(width: 24),
        
        // Right column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Filter
              _buildFilterSection(
                'Locations',
                _buildLocationFilter(),
                isMobile,
              ),
              
              SizedBox(height: isMobile ? 16 : 20),
              
              // Age Groups Filter
              _buildFilterSection(
                'Age Groups',
                _buildAgeGroupsFilter(),
                isMobile,
              ),
              
              SizedBox(height: isMobile ? 16 : 20),
              
              // Features Filter
              _buildFilterSection(
                'Features',
                _buildFeaturesFilter(),
                isMobile,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Original vertical layout for mobile and smaller screens
  Widget _buildVerticalLayout(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Range Filter
        _buildFilterSection(
          'Date Range',
          _buildDateRangeFilter(),
          isMobile,
        ),
        
        SizedBox(height: isMobile ? 16 : 20),
        
        // Location Filter
        _buildFilterSection(
          'Locations',
          _buildLocationFilter(),
          isMobile,
        ),
        
        SizedBox(height: isMobile ? 16 : 20),
        
        // Categories Filter
        _buildFilterSection(
          'Categories',
          _buildCategoriesFilter(),
          isMobile,
        ),
        
        SizedBox(height: isMobile ? 16 : 20),
        
        // Age Groups Filter
        _buildFilterSection(
          'Age Groups',
          _buildAgeGroupsFilter(),
          isMobile,
        ),
        
        SizedBox(height: isMobile ? 16 : 20),
        
        // Price Range Filter
        _buildFilterSection(
          'Price Range',
          _buildPriceRangeFilter(),
          isMobile,
        ),
        
        SizedBox(height: isMobile ? 16 : 20),
        
        // Features Filter
        _buildFilterSection(
          'Features',
          _buildFeaturesFilter(),
          isMobile,
        ),
        
        // Bottom padding for scroll
        SizedBox(height: isMobile ? 12 : 16),
      ],
    );
  }
} 