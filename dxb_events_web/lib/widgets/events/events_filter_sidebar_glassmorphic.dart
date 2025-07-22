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
    return Container(
      width: 280,
      height: MediaQuery.of(context).size.height,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter header
            Row(
              children: [
                const Icon(
                  LucideIcons.filter,
                  color: Color(0xFFFF6B6B),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filters',
                  style: GoogleFonts.comfortaa(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.filters.hasActiveFilters)
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => widget.onFiltersChanged(const EventFilterData()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, 
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
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                const Spacer(),
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
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            if (widget.isExpanded) ...[
              const SizedBox(height: 16),
              
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: _buildVerticalLayout(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF666666),
            ),
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    final dateRanges = ['Today', 'This Weekend', 'Next Week', 'This Month'];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: dateRanges.map((range) {
        final isSelected = widget.filters.dateRange == range;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              final newFilters = widget.filters.copyWith(
                dateRange: isSelected ? null : range,
              );
              widget.onFiltersChanged(newFilters);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, 
                vertical: 8
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
                      fontSize: 12,
                      color: isSelected ? Colors.white : const Color(0xFFFF6B6B),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
  }

  Widget _buildLocationFilter() {
    final locations = ['Dubai Marina', 'Downtown Dubai', 'Jumeirah', 'DIFC', 'Business Bay'];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: locations.map((location) {
        final isSelected = widget.filters.locations.contains(location);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              final newLocations = List<String>.from(widget.filters.locations);
              if (isSelected) {
                newLocations.remove(location);
              } else {
                newLocations.add(location);
              }
              final newFilters = widget.filters.copyWith(locations: newLocations);
              widget.onFiltersChanged(newFilters);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, 
                vertical: 8
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
                      fontSize: 12,
                      color: isSelected ? Colors.white : const Color(0xFFFF6B6B),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
  }

  Widget _buildCategoriesFilter() {
    final categories = ['Family Fun', 'Cultural', 'Educational', 'Entertainment', 'Outdoor'];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = widget.filters.categories.contains(category);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              final newCategories = List<String>.from(widget.filters.categories);
              if (isSelected) {
                newCategories.remove(category);
              } else {
                newCategories.add(category);
              }
              final newFilters = widget.filters.copyWith(categories: newCategories);
              widget.onFiltersChanged(newFilters);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, 
                vertical: 8
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
                      fontSize: 12,
                      color: isSelected ? Colors.white : const Color(0xFFFF6B6B),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
  }

  Widget _buildAgeGroupsFilter() {
    final ageGroups = ['Toddlers (0-3)', 'Kids (4-12)', 'Teens (13-17)', 'All Ages'];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ageGroups.map((ageGroup) {
        final isSelected = widget.filters.ageGroups.contains(ageGroup);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              final newAgeGroups = List<String>.from(widget.filters.ageGroups);
              if (isSelected) {
                newAgeGroups.remove(ageGroup);
              } else {
                newAgeGroups.add(ageGroup);
              }
              final newFilters = widget.filters.copyWith(ageGroups: newAgeGroups);
              widget.onFiltersChanged(newFilters);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, 
                vertical: 8
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
                      fontSize: 12,
                      color: isSelected ? Colors.white : const Color(0xFFFF6B6B),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, 
                  vertical: 8
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
                ),
                child: TextField(
                  style: GoogleFonts.inter(
                    color: const Color(0xFF333333), 
                    fontSize: 14
                  ),
                  decoration: InputDecoration(
                    hintText: 'Min AED',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF999999),
                      fontSize: 14,
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
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, 
                  vertical: 8
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
                ),
                child: TextField(
                  style: GoogleFonts.inter(
                    color: const Color(0xFF333333), 
                    fontSize: 14
                  ),
                  decoration: InputDecoration(
                    hintText: 'Max AED',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF999999),
                      fontSize: 14,
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
    final features = [
      'Stroller Friendly', 
      'Parking Available', 
      'Metro Access', 
      'Indoor', 
      'Outdoor', 
      'Free Entry',
      'Educational Content'
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: features.map((feature) {
        final isSelected = widget.filters.features.contains(feature);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              final newFeatures = List<String>.from(widget.filters.features);
              if (isSelected) {
                newFeatures.remove(feature);
              } else {
                newFeatures.add(feature);
              }
              final newFilters = widget.filters.copyWith(features: newFeatures);
              widget.onFiltersChanged(newFilters);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, 
                vertical: 8
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
                      fontSize: 12,
                      color: isSelected ? Colors.white : const Color(0xFFFF6B6B),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
  }

  // Vertical layout for desktop sidebar
  Widget _buildVerticalLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Range Filter
        _buildFilterSection(
          'Date Range',
          _buildDateRangeFilter(),
        ),
        
        const SizedBox(height: 20),
        
        // Location Filter
        _buildFilterSection(
          'Locations',
          _buildLocationFilter(),
        ),
        
        const SizedBox(height: 20),
        
        // Categories Filter
        _buildFilterSection(
          'Categories',
          _buildCategoriesFilter(),
        ),
        
        const SizedBox(height: 20),
        
        // Age Groups Filter
        _buildFilterSection(
          'Age Groups',
          _buildAgeGroupsFilter(),
        ),
        
        const SizedBox(height: 20),
        
        // Price Range Filter
        _buildFilterSection(
          'Price Range',
          _buildPriceRangeFilter(),
        ),
        
        const SizedBox(height: 20),
        
        // Features Filter
        _buildFilterSection(
          'Features',
          _buildFeaturesFilter(),
        ),
        
        // Bottom padding for scroll
        const SizedBox(height: 16),
      ],
    );
  }
} 