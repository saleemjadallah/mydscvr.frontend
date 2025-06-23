import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../models/search.dart';
import '../../providers/search_provider.dart';

class SearchFiltersWidget extends ConsumerStatefulWidget {
  final Function(SearchFilters)? onFiltersChanged;

  const SearchFiltersWidget({
    super.key,
    this.onFiltersChanged,
  });

  @override
  ConsumerState<SearchFiltersWidget> createState() => _SearchFiltersWidgetState();
}

class _SearchFiltersWidgetState extends ConsumerState<SearchFiltersWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  SearchFilters _currentFilters = const SearchFilters();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Get current filters from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchState = ref.read(searchProvider);
      setState(() {
        _currentFilters = searchState.filters;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateFilters(SearchFilters newFilters) {
    setState(() {
      _currentFilters = newFilters;
    });
    widget.onFiltersChanged?.call(newFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(20),
        blur: 15,
        opacity: 0.2,
        child: Column(
          children: [
            // Filter tabs
            _buildFilterTabs(),
            
            // Filter content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCategoryFilter(),
                  _buildLocationFilter(),
                  _buildPriceAgeFilter(),
                  _buildSpecialFilters(),
                ],
              ),
            ),

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        tabs: [
          Tab(
            icon: Icon(LucideIcons.tag, size: 16),
            text: 'Category',
          ),
          Tab(
            icon: Icon(LucideIcons.mapPin, size: 16),
            text: 'Location',
          ),
          Tab(
            icon: Icon(LucideIcons.dollarSign, size: 16),
            text: 'Price & Age',
          ),
          Tab(
            icon: Icon(LucideIcons.star, size: 16),
            text: 'Special',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Category',
            style: GoogleFonts.comfortaa(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: EventCategory.allCategories.length,
              itemBuilder: (context, index) {
                final category = EventCategory.allCategories[index];
                final isSelected = _currentFilters.category == category.id;

                return GestureDetector(
                  onTap: () {
                    _updateFilters(
                      _currentFilters.copyWith(
                        category: isSelected ? null : category.id,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? AppColors.goldenGradient
                          : LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white.withOpacity(0.6)
                            : Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          category.emoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category.name,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().scale(
                  delay: Duration(milliseconds: index * 50),
                  duration: 300.ms,
                  curve: Curves.elasticOut,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationFilter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Areas',
            style: GoogleFonts.comfortaa(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: DubaiArea.allAreas.length,
              itemBuilder: (context, index) {
                final area = DubaiArea.allAreas[index];
                final isSelected = _currentFilters.areas.contains(area.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      final newAreas = List<String>.from(_currentFilters.areas);
                      if (isSelected) {
                        newAreas.remove(area.id);
                      } else {
                        newAreas.add(area.id);
                      }
                      _updateFilters(
                        _currentFilters.copyWith(areas: newAreas),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppColors.goldenGradient
                            : LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white.withOpacity(0.6)
                              : Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            area.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  area.displayName,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                if (area.landmarks.isNotEmpty)
                                  Text(
                                    area.landmarks.take(2).join(', '),
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              LucideIcons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                ).animate().slideX(
                  delay: Duration(milliseconds: index * 50),
                  duration: 300.ms,
                  begin: 0.5,
                  curve: Curves.easeOut,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAgeFilter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Price Range
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price Range (AED)',
                  style: GoogleFonts.comfortaa(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPriceRangeSelector(),
                const SizedBox(height: 24),
                
                Text(
                  'Age Range',
                  style: GoogleFonts.comfortaa(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAgeRangeSelector(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeSelector() {
    final priceRanges = [
      const PriceRange(min: 0, max: 0), // Free
      const PriceRange(min: 0, max: 50),
      const PriceRange(min: 50, max: 150),
      const PriceRange(min: 150, max: 300),
      const PriceRange(min: 300, max: 1000),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: priceRanges.map((range) {
        final isSelected = _currentFilters.priceRange?.min == range.min &&
                          _currentFilters.priceRange?.max == range.max;
        
        return GestureDetector(
          onTap: () {
            _updateFilters(
              _currentFilters.copyWith(
                priceRange: isSelected ? null : range,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? AppColors.goldenGradient
                  : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withOpacity(0.6)
                    : Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              range.min == 0 && range.max == 0 
                  ? 'Free'
                  : range.toString(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAgeRangeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AgeRange.predefinedRanges.map((range) {
        final isSelected = _currentFilters.ageRange?.min == range.min &&
                          _currentFilters.ageRange?.max == range.max;
        
        return GestureDetector(
          onTap: () {
            _updateFilters(
              _currentFilters.copyWith(
                ageRange: isSelected ? null : range,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? AppColors.goldenGradient
                  : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withOpacity(0.6)
                    : Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              range.toString(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpecialFilters() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Filters',
            style: GoogleFonts.comfortaa(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFilterToggle(
            'Family Friendly Only',
            LucideIcons.heart,
            _currentFilters.familyFriendlyOnly,
            (value) => _updateFilters(
              _currentFilters.copyWith(familyFriendlyOnly: value),
            ),
          ),
          
          _buildFilterToggle(
            'Free Events Only',
            LucideIcons.gift,
            _currentFilters.freeEventsOnly,
            (value) => _updateFilters(
              _currentFilters.copyWith(freeEventsOnly: value),
            ),
          ),
          
          _buildFilterToggle(
            'Has Parking',
            LucideIcons.car,
            _currentFilters.hasParking,
            (value) => _updateFilters(
              _currentFilters.copyWith(hasParking: value),
            ),
          ),
          
          _buildFilterToggle(
            'Wheelchair Accessible',
            LucideIcons.accessibility,
            _currentFilters.wheelchairAccessible,
            (value) => _updateFilters(
              _currentFilters.copyWith(wheelchairAccessible: value),
            ),
          ),
          
          _buildFilterToggle(
            'Indoor Only',
            LucideIcons.home,
            _currentFilters.indoorOnly,
            (value) => _updateFilters(
              _currentFilters.copyWith(indoorOnly: value),
            ),
          ),
          
          _buildFilterToggle(
            'Outdoor Only',
            LucideIcons.sun,
            _currentFilters.outdoorOnly,
            (value) => _updateFilters(
              _currentFilters.copyWith(outdoorOnly: value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToggle(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: value
            ? AppColors.goldenGradient
            : LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? Colors.white.withOpacity(0.6)
              : Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.white.withOpacity(0.3),
            inactiveThumbColor: Colors.white.withOpacity(0.7),
            inactiveTrackColor: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _updateFilters(const SearchFilters());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Clear All',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                // Apply filters - handled by parent
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.dubaiTeal,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 