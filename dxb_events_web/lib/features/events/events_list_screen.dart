import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/app_colors.dart';
import '../../utils/duration_formatter.dart';
import '../../core/widgets/dubai_app_bar.dart';
import '../../models/event.dart';
import '../../services/events_service.dart';
import '../../services/enhanced_events_service.dart';
import '../../widgets/events/event_card_enhanced.dart';
import '../../widgets/events/enhanced_event_card.dart';
import '../../widgets/events/search_bar_glassmorphic.dart';
import '../../widgets/events/enhanced_events_search.dart';
// import '../../widgets/events/event_list_item.dart';
import '../../widgets/events/events_filter_sidebar.dart';
import '../../widgets/events/events_filter_sidebar_glassmorphic.dart';
import '../../widgets/filters/advanced_filter_panel.dart';
import '../../widgets/events/events_sort_controls.dart';
import '../../widgets/common/breadcrumb_navigation.dart';
import '../../widgets/common/glassmorphic_background.dart';
import '../../widgets/common/footer.dart';
import '../event_details/event_details_screen.dart';

class EventsListScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  final String? categoryDisplayName;
  final String? initialLocation;
  final String? initialSearchQuery;

  const EventsListScreen({
    super.key,
    this.initialCategory,
    this.categoryDisplayName,
    this.initialLocation,
    this.initialSearchQuery,
  });

  @override
  ConsumerState<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends ConsumerState<EventsListScreen>
    with TickerProviderStateMixin {
  
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late AnimationController _filterController;
  
  // View and sort state
  ViewMode _currentViewMode = ViewMode.grid;
  SortOption _currentSortOption = SortOption.date;
  
  // Filter state
  EventFilterData _currentFilters = const EventFilterData();
  bool _isFilterExpanded = false;
  
  // Search state
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;

  List<Event> events = [];
  String? errorMessage;
  late final EventsService _eventsService;
  
  // Add total count from database
  int _totalEventsInDb = 0;
  
  String? selectedCategory;
  String? selectedLocation;
  String? searchQuery;
  
  // Enhanced filtering state
  Map<String, dynamic> _activeFilters = {};
  bool _useEnhancedCard = true;
  bool _showQualityMetrics = true;

  @override
  void initState() {
    super.initState();
    print('🚀🚀🚀 DEBUG: EventsListScreen initState called!');
    _eventsService = EventsService();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _filterController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Add scroll listener for infinite scroll
    _scrollController.addListener(_onScroll);
    
    // Initialize with provided filters
    selectedCategory = widget.initialCategory;
    selectedLocation = widget.initialLocation;
    searchQuery = widget.initialSearchQuery;
    
    print('🚀🚀🚀 DEBUG: Initial filter values:');
    print('🚀🚀🚀 DEBUG: - initialCategory: ${widget.initialCategory}');
    print('🚀🚀🚀 DEBUG: - initialLocation: ${widget.initialLocation}');
    print('🚀🚀🚀 DEBUG: - initialSearchQuery: ${widget.initialSearchQuery}');
    print('🚀🚀🚀 DEBUG: - selectedCategory: $selectedCategory');
    print('🚀🚀🚀 DEBUG: - selectedLocation: $selectedLocation');
    print('🚀🚀🚀 DEBUG: - searchQuery: $searchQuery');
    
    print('🚀🚀🚀 DEBUG: About to call _loadEvents()');
    _loadEvents();
  }

  void _onScroll() {
    // Improved scroll detection for footer compatibility
    final double triggerPoint = _scrollController.position.maxScrollExtent - 400;
    if (_scrollController.position.pixels >= triggerPoint) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreEvents();
      }
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      errorMessage = null;
      events.clear();
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      print('🔍 DEBUG: Loading events with enhanced filtering for category: $selectedCategory');
      
      List<Event> filteredEvents;
      int totalCount;
      
      // Use enhanced filtering for specific categories to match homepage counts
      if (selectedCategory != null && _shouldUseEnhancedFiltering(selectedCategory!)) {
        print('📊 Using enhanced filtering for category: $selectedCategory');
        
        // Load ALL events to filter from (SAME as homepage does)
        final response = await _eventsService.getEvents(
          perPage: 500, // Use same method as homepage but get more events
          sortBy: 'start_date',
        );
        
        if (response.isSuccess && response.data != null) {
          final allEvents = response.data!; // getEvents returns List<Event> directly
          print('🔍 Loaded ${allEvents.length} total events to filter from (using same method as homepage)');
          
          // Debug: Show what categories exist in the data
          final uniqueCategories = allEvents.map((e) => e.category).toSet().toList();
          print('🏷️ Available categories in ${allEvents.length} events: $uniqueCategories');
          
          // Debug: Show sample event tags
          if (allEvents.isNotEmpty) {
            final sampleTags = allEvents.take(5).map((e) => '${e.title}: ${e.tags}').toList();
            print('📋 Sample event tags: $sampleTags');
          }
          
          // Apply enhanced filtering
          final allFilteredEvents = _applyEnhancedCategoryFiltering(allEvents, selectedCategory!);
          print('✅ Found ${allFilteredEvents.length} events matching enhanced criteria for $selectedCategory');
          
          // Apply pagination to filtered results
          final startIndex = (_currentPage - 1) * 20;
          filteredEvents = allFilteredEvents.skip(startIndex).take(20).toList();
          totalCount = allFilteredEvents.length;
          
          print('📄 Showing page $_currentPage: ${filteredEvents.length} events (${startIndex + 1}-${startIndex + filteredEvents.length} of $totalCount)');
        } else {
          filteredEvents = [];
          totalCount = 0;
          print('❌ Failed to load events for enhanced filtering');
        }
      } else {
        print('📊 Using standard API filtering for category: $selectedCategory');
        
        // Use standard API filtering for other categories
        final response = await _eventsService.getEventsWithTotal(
          category: selectedCategory,
          location: selectedLocation,
          page: _currentPage,
          perPage: 20,
        );
        
        if (response.isSuccess && response.data != null) {
          final eventsWithTotal = response.data!;
          filteredEvents = eventsWithTotal.events;
          totalCount = eventsWithTotal.total;
          print('🔍 DEBUG: Loaded ${filteredEvents.length} events using standard filtering, total in DB: $totalCount');
        } else {
          filteredEvents = [];
          totalCount = 0;
        }
      }

      if (filteredEvents.isNotEmpty) {
        setState(() {
          events = filteredEvents;
          _totalEventsInDb = totalCount; // Store total count
          _isLoading = false;
          _hasMore = filteredEvents.length >= 20;
          _currentPage++;
          print('🔍 DEBUG: Total events available: $_totalEventsInDb');
        });
        
        _animationController.forward();
      } else {
        print('🔍 DEBUG: No events found matching criteria');
        setState(() {
          errorMessage = totalCount == 0 ? 'No events found matching your criteria' : null;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('🔍 DEBUG: Exception in _loadEvents: $e');
      print('🔍 DEBUG: Stack trace: $stackTrace');
      setState(() {
        errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreEvents() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      print('🔍 DEBUG: Loading more events, page $_currentPage...');
      final response = await _eventsService.getEvents(
        category: selectedCategory,
        location: selectedLocation,
        page: _currentPage,
        perPage: 20,
      );

      if (response.isSuccess) {
        final newEvents = response.data ?? [];
        print('🔍 DEBUG: Loaded ${newEvents.length} more events');
        
        setState(() {
          events.addAll(newEvents);
          _isLoadingMore = false;
          _hasMore = newEvents.length >= 20;
          _currentPage++;
          print('🔍 DEBUG: Total events now: ${events.length}');
        });
      } else {
        setState(() {
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('🔍 DEBUG: Exception in _loadMoreEvents: $e');
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _filterController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMobile = screenWidth <= 800;

    return Scaffold(
      body: Column(
        children: [
          // Header with navigation and controls
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [
                  Color(0xFF0D7377), // Dark teal - matches homepage
                  Color(0xFF14A085), // Medium teal - matches homepage
                  Color(0xFF329D9C), // Light teal - matches homepage
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF0D7377).withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [

                
                // Main header
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24, 
                    vertical: isMobile ? 12 : 16
                  ),
                  child: Row(
                    children: [
                      // Back button
                      Material(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF0D7377).withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              // Use GoRouter for consistent navigation
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/');
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 16),
                      
                      // Title only
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPageTitle(),
                            style: GoogleFonts.comfortaa(
                              fontSize: isMobile ? 16 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!isMobile || _getPageSubtitle().length < 30)
                            Text(
                              _getPageSubtitle(),
                              style: TextStyle(
                                fontSize: isMobile ? 10 : 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                      
                      Spacer(),
                      
                      // View toggle between list and grid
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF0D7377).withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(isMobile ? 2 : 3),
                        child: Row(
                          children: [
                            Material(
                              color: _currentViewMode == ViewMode.list ? Colors.transparent : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              child: Container(
                                decoration: _currentViewMode == ViewMode.list 
                                    ? BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(9),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF0D7377).withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      )
                                    : null,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(9),
                                  onTap: () {
                                    setState(() {
                                      _currentViewMode = ViewMode.list;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 8 : 12, 
                                      vertical: isMobile ? 6 : 8
                                    ),
                                    child: Icon(
                                      Icons.view_list,
                                      color: _currentViewMode == ViewMode.list 
                                          ? Colors.white 
                                          : Colors.white.withOpacity(0.7),
                                      size: isMobile ? 18 : 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Material(
                              color: _currentViewMode == ViewMode.grid ? Colors.transparent : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              child: Container(
                                decoration: _currentViewMode == ViewMode.grid 
                                    ? BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(9),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF0D7377).withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      )
                                    : null,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(9),
                                  onTap: () {
                                    setState(() {
                                      _currentViewMode = ViewMode.grid;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 8 : 12, 
                                      vertical: isMobile ? 6 : 8
                                    ),
                                    child: Icon(
                                      Icons.grid_view,
                                      color: _currentViewMode == ViewMode.grid 
                                          ? Colors.white 
                                          : Colors.white.withOpacity(0.7),
                                      size: isMobile ? 18 : 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(width: isMobile ? 8 : 12),
                      
                      // Advanced Filter button
                      Material(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _activeFilters.isNotEmpty 
                                ? AppColors.dubaiGold.withOpacity(0.3)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF0D7377).withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _showAdvancedFilterPanel(),
                            child: Container(
                              padding: EdgeInsets.all(isMobile ? 8 : 10),
                              child: Stack(
                                children: [
                                  Icon(
                                    LucideIcons.filter,
                                    color: Colors.white.withOpacity(0.9),
                                    size: isMobile ? 18 : 20,
                                  ),
                                  if (_activeFilters.isNotEmpty)
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppColors.dubaiGold,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: isMobile ? 8 : 12),
                      
                      // Calendar Date Filter
                      Material(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: (_currentFilters.customDateStart != null || _currentFilters.customDateEnd != null)
                                ? AppColors.dubaiGold.withOpacity(0.3)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF0D7377).withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _showDateFilterDialog(),
                            child: Container(
                              padding: EdgeInsets.all(isMobile ? 8 : 10),
                              child: Stack(
                                children: [
                                  Icon(
                                    LucideIcons.calendar,
                                    color: Colors.white.withOpacity(0.9),
                                    size: isMobile ? 18 : 20,
                                  ),
                                  if (_currentFilters.customDateStart != null || _currentFilters.customDateEnd != null)
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppColors.dubaiGold,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      
                      // Refresh button with better styling
                      Material(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF0D7377).withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              print('Reload button clicked!');
                              _loadEvents();
                            },
                            child: Container(
                              padding: EdgeInsets.all(isMobile ? 8 : 10),
                              child: Icon(
                                Icons.refresh,
                                color: Colors.white.withOpacity(0.9),
                                size: isMobile ? 18 : 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Main content with responsive layout and footer
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController, // Connect scroll controller here
              child: Column(
                children: [
                  Container(
                    child: isLargeScreen ? _buildDesktopLayout() : _buildMobileLayout(),
                  ),
                  // Footer as part of scrollable content
                  const Footer(),
                  // Add bottom padding to ensure proper scroll detection
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF6B6B), // Coral
            Color(0xFFFFB347), // Orange
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter sidebar
          Container(
            width: 320,
            margin: EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFF6B6B).withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: EventsFilterSidebarGlassmorphic(
                filters: _currentFilters,
                onFiltersChanged: (filters) {
                  setState(() {
                    _currentFilters = filters;
                  });
                },
                isExpanded: true,
                onToggle: () {}, // Always expanded on desktop
              ),
            ),
          ),
          
          // Main content area
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 16, right: 16, bottom: 16),
              child: _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF6B6B), // Coral
            Color(0xFFFFB347), // Orange
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mobile filter toggle
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFF6B6B).withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: EventsFilterSidebarGlassmorphic(
              filters: _currentFilters,
              onFiltersChanged: (filters) {
                setState(() {
                  _currentFilters = filters;
                });
              },
              isExpanded: _isFilterExpanded,
              onToggle: () {
                setState(() {
                  _isFilterExpanded = !_isFilterExpanded;
                });
              },
            ),
          ),
          
          // Main content - no Expanded here since we're inside SingleChildScrollView
          _buildMainContent(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    final filteredEvents = _getFilteredEvents();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF6B6B).withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar and event count
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Enhanced search bar with live suggestions
                EnhancedEventsSearch(
                  controller: _searchController,
                  hintText: 'Search events, categories, locations...',
                  onSearchChanged: (value) {
                    setState(() {}); // Trigger rebuild to filter events
                  },
                ),
                
                SizedBox(height: 16),
                
                // Event count and filters
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B6B).withOpacity(0.1), Color(0xFFFFB347).withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(0xFFFF6B6B).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFFB347)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.event_available,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '${_getDisplayCount()}',
                        style: GoogleFonts.comfortaa(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B6B),
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        _getCountLabel(),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333333),
                        ),
                      ),
                      if (_hasActiveFilters() && _totalEventsInDb > 0) ...[
                        SizedBox(width: 8),
                        Text(
                          'of $_totalEventsInDb total',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                      if (_searchController.text.isNotEmpty) ...[
                        Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFFFB347)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.clear, size: 16, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'Clear search',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Events display
          _isLoading
              ? _buildLoadingCard()
              : filteredEvents.isEmpty
                  ? _buildEmptyState()
                  : _currentViewMode == ViewMode.list
                      ? _buildListView(filteredEvents)
                      : _buildGridView(filteredEvents),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SearchBarGlassmorphic(
      controller: _searchController,
      hintText: 'Search events, categories, locations...',
      onChanged: (value) {
        setState(() {}); // Trigger rebuild to filter events
      },
      onClear: () {
        setState(() {});
      },
    ).animate().slideY(
      delay: 200.ms,
      duration: 600.ms,
      begin: 1,
      end: 0,
      curve: Curves.easeOut,
    );
  }

  Widget _buildEventsList(List<Event> events) {
    print('🔍 DEBUG _buildEventsList: Building list with ${events.length} events');
    print('🔍 DEBUG _buildEventsList: _isLoading = $_isLoading');
    
    // Add debug for empty events
    if (events.isEmpty && this.events.isNotEmpty) {
      print('🔴 WARNING: All events were filtered out!');
      print('🔴 Original events count: ${this.events.length}');
      print('🔴 After filtering: 0');
    }
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.dubaiTeal,
        ),
      );
    }

    if (events.isEmpty) {
      print('🔍 DEBUG _buildEventsList: Showing empty state');
      return _buildEmptyState();
    }

    print('🔍 DEBUG _buildEventsList: Showing ${_currentViewMode == ViewMode.grid ? 'grid' : 'list'} view');
    if (_currentViewMode == ViewMode.grid) {
      return _buildGridView(events);
    } else {
      return _buildListView(events);
    }
  }

  Widget _buildGridView(List<Event> filteredEvents) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 800;
    
    // Use carousel for mobile, grid for larger screens
    if (isMobile) {
      return _buildMobileCarousel(filteredEvents);
    }
    
    // Desktop/tablet grid view
    int crossAxisCount = screenWidth > 1200 ? 3 : 2;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredEvents.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredEvents.length) {
            // Show loading indicator
            return Center(
              child: Container(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: AppColors.dubaiTeal,
                ),
              ),
            );
          }
          
          final event = filteredEvents[index];
          return _buildEventCard(event)
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: index * 100),
                duration: 600.ms,
                curve: Curves.easeOutQuart,
              )
              .slideY(
                begin: 0.2,
                end: 0,
                delay: Duration(milliseconds: index * 100),
                duration: 600.ms,
                curve: Curves.easeOutQuart,
              )
              .scale(
                begin: Offset(0.8, 0.8),
                end: Offset(1, 1),
                delay: Duration(milliseconds: index * 100),
                duration: 600.ms,
                curve: Curves.easeOutQuart,
              );
        },
      ),
    );
  }
  
  Widget _buildMobileCarousel(List<Event> filteredEvents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carousel section header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Events (${filteredEvents.length})',
                style: GoogleFonts.comfortaa(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Swipe to browse →',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        
        // Horizontal carousel
        SizedBox(
          height: 360, // Increased height for better mobile viewing
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredEvents.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == filteredEvents.length) {
                // Show loading indicator
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.dubaiTeal,
                    ),
                  ),
                );
              }
              
              final event = filteredEvents[index];
              return Container(
                width: 280, // Fixed width for carousel items
                margin: const EdgeInsets.only(right: 16),
                child: _buildMobileEventCard(event)
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: index * 80),
                      duration: 500.ms,
                      curve: Curves.easeOutQuart,
                    )
                    .slideX(
                      begin: 0.3,
                      end: 0,
                      delay: Duration(milliseconds: index * 80),
                      duration: 500.ms,
                      curve: Curves.easeOutQuart,
                    ),
              );
            },
          ),
        ),
        
        // Load more indicator or end message
        if (_hasMore && !_isLoadingMore)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: TextButton.icon(
                onPressed: _loadMoreEvents,
                icon: Icon(LucideIcons.moreHorizontal, color: AppColors.dubaiTeal),
                label: Text(
                  'Load More Events',
                  style: GoogleFonts.inter(
                    color: AppColors.dubaiTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildListView(List<Event> filteredEvents) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: filteredEvents.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredEvents.length) {
          // Show loading indicator
          return Center(
            child: Container(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: AppColors.dubaiTeal,
              ),
            ),
          );
        }
        
        final event = filteredEvents[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildEventCard(event)
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: index * 80),
                duration: 500.ms,
                curve: Curves.easeOutQuart,
              )
              .slideX(
                begin: 0.1,
                end: 0,
                delay: Duration(milliseconds: index * 80),
                duration: 500.ms,
                curve: Curves.easeOutQuart,
              ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B6B).withOpacity(0.1), Color(0xFFFFB347).withOpacity(0.1)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 64,
              color: Color(0xFFFF6B6B),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No events found',
            style: GoogleFonts.comfortaa(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 12),
          Text(
            _getEmptyStateMessage(),
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_currentFilters.hasActiveFilters || _searchController.text.isNotEmpty) ...[
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFFB347)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFF6B6B).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: _clearAllFilters,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.clear_all, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Clear Filters',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              OutlinedButton(
                onPressed: () => context.go('/'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFFFF6B6B),
                  side: BorderSide(color: Color(0xFFFF6B6B)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Browse All Events',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
      delay: 400.ms,
      duration: 800.ms,
    );
  }

  // Helper methods
  List<BreadcrumbItem> _getBreadcrumbItems() {
    if (selectedCategory != null) {
      return BreadcrumbNavigation.forCategory(selectedCategory!);
    } else if (searchQuery != null) {
      return BreadcrumbNavigation.forSearchResults(searchQuery!);
    } else if (selectedLocation != null) {
      return BreadcrumbNavigation.forLocation(selectedLocation!);
    }
    return BreadcrumbNavigation.forAllEvents();
  }

  String _getEmptyStateMessage() {
    if (_searchController.text.isNotEmpty) {
      return 'No events match your search for "${_searchController.text}". Try adjusting your search terms or filters.';
    } else if (_currentFilters.hasActiveFilters) {
      return 'No events match your current filters. Try adjusting or clearing your filters to see more events.';
    } else if (selectedCategory != null) {
      return 'No events found in the ${selectedCategory} category. Check back later for new events.';
    } else if (selectedLocation != null) {
      return 'No events found in ${selectedLocation}. Try exploring other areas or check back later.';
    }
    return 'No events are currently available. Please check back later for upcoming events.';
  }

  void _clearAllFilters() {
    setState(() {
      _currentFilters = const EventFilterData();
      _searchController.clear();
      selectedCategory = null;
      selectedLocation = null;
    });
  }

  void _navigateToEventDetail(Event event) {
    // Navigate to full event details page using Go Router
    context.go('/event/${event.id}');
  }

  List<Event> _getFilteredEvents() {
    if (_searchController.text.isEmpty && !_currentFilters.hasActiveFilters) {
      return events;
    }
    
    List<Event> filtered = List.from(events);
    
    // Apply enhanced search filter
    if (_searchController.text.isNotEmpty) {
      filtered = _applySmartSearch(filtered, _searchController.text);
    }
    
    // Apply filter data filters
    if (_currentFilters.hasActiveFilters) {
      // Category filter
      if (_currentFilters.categories.isNotEmpty) {
        filtered = filtered.where((event) => 
          _currentFilters.categories.any((displayCategory) => 
            _mapCategoryToDbValue(displayCategory).contains(event.category.toLowerCase())
          )
        ).toList();
      }
      
      // Location filter with fuzzy matching
      if (_currentFilters.locations.isNotEmpty) {
        filtered = filtered.where((event) => 
          _currentFilters.locations.any((location) => 
            _isLocationMatch(event.venue.area, location)
          )
        ).toList();
      }
      
      // Price filter
      if (_currentFilters.minPrice != null || _currentFilters.maxPrice != null) {
        filtered = filtered.where((event) {
          final price = event.pricing.basePrice;
          final minPrice = _currentFilters.minPrice ?? 0;
          final maxPrice = _currentFilters.maxPrice ?? double.infinity;
          return price >= minPrice && price <= maxPrice;
        }).toList();
      }
      
      // Age group filter
      if (_currentFilters.ageGroups.isNotEmpty) {
        filtered = filtered.where((event) => 
          _currentFilters.ageGroups.any((ageGroup) => 
            _isAgeGroupMatch(event, ageGroup)
          )
        ).toList();
      }
      
      // Date range filter
      if (_currentFilters.dateRange != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        filtered = filtered.where((event) {
          final eventDate = DateTime(event.startDate.year, event.startDate.month, event.startDate.day);
          
          switch (_currentFilters.dateRange) {
            case 'Today':
              return event.isToday;
            case 'This Weekend':
              return event.isThisWeekend;
            case 'Next Week':
              final nextWeekStart = today.add(Duration(days: 7 - now.weekday + 1)); // Next Monday
              final nextWeekEnd = nextWeekStart.add(Duration(days: 6)); // Next Sunday
              return eventDate.isAfter(nextWeekStart.subtract(Duration(days: 1))) && 
                     eventDate.isBefore(nextWeekEnd.add(Duration(days: 1)));
            case 'This Month':
              final monthStart = DateTime(now.year, now.month, 1);
              final monthEnd = DateTime(now.year, now.month + 1, 0);
              return eventDate.isAfter(monthStart.subtract(Duration(days: 1))) && 
                     eventDate.isBefore(monthEnd.add(Duration(days: 1)));
            default:
              return true;
          }
        }).toList();
      }
      
      // Custom date range filter
      if (_currentFilters.customDateStart != null || _currentFilters.customDateEnd != null) {
        filtered = filtered.where((event) {
          final eventDate = DateTime(event.startDate.year, event.startDate.month, event.startDate.day);
          
          bool matchesStart = true;
          bool matchesEnd = true;
          
          if (_currentFilters.customDateStart != null) {
            final startDate = DateTime(_currentFilters.customDateStart!.year, 
                                     _currentFilters.customDateStart!.month, 
                                     _currentFilters.customDateStart!.day);
            matchesStart = eventDate.isAtSameMomentAs(startDate) || eventDate.isAfter(startDate);
          }
          
          if (_currentFilters.customDateEnd != null) {
            final endDate = DateTime(_currentFilters.customDateEnd!.year, 
                                   _currentFilters.customDateEnd!.month, 
                                   _currentFilters.customDateEnd!.day);
            matchesEnd = eventDate.isAtSameMomentAs(endDate) || eventDate.isBefore(endDate);
          }
          
          return matchesStart && matchesEnd;
        }).toList();
      }
      
      // Time of day filter
      if (_currentFilters.timeOfDay.isNotEmpty) {
        filtered = filtered.where((event) => 
          _currentFilters.timeOfDay.any((timeSlot) => 
            _isTimeSlotMatch(event, timeSlot)
          )
        ).toList();
      }
      
      // Features filter
      if (_currentFilters.features.isNotEmpty) {
        filtered = filtered.where((event) => 
          _currentFilters.features.every((feature) => 
            _hasFeature(event, feature)
          )
        ).toList();
      }
    }
    
    // Apply widget level filters (for backward compatibility)
    if (selectedCategory != null) {
      filtered = filtered.where((event) => 
        event.category.toLowerCase() == selectedCategory!.toLowerCase()
      ).toList();
    }
    
    if (selectedLocation != null) {
      filtered = filtered.where((event) => 
        event.venue.area.toLowerCase() == selectedLocation!.toLowerCase()
      ).toList();
    }
    
    return filtered;
  }

  List<Event> _applySorting(List<Event> events) {
    List<Event> sorted = List.from(events);
    
    switch (_currentSortOption) {
      case SortOption.date:
        sorted.sort((a, b) => a.startDate.compareTo(b.startDate));
        break;
      case SortOption.popularity:
        sorted.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      case SortOption.priceLowToHigh:
        sorted.sort((a, b) => a.pricing.basePrice.compareTo(b.pricing.basePrice));
        break;
      case SortOption.priceHighToLow:
        sorted.sort((a, b) => b.pricing.basePrice.compareTo(a.pricing.basePrice));
        break;
      case SortOption.rating:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.alphabetical:
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.distance:
        // For now, just sort by area name - in real app would use user location
        sorted.sort((a, b) => a.venue.area.compareTo(b.venue.area));
        break;
    }
    
    return sorted;
  }

  int _getGridCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return 3;
    } else if (screenWidth > 800) {
      return 2;
    }
    return 1;
  }

  /// Show the advanced filter panel
  void _showAdvancedFilterPanel() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          constraints: BoxConstraints(
            maxWidth: 800,
            maxHeight: 700,
          ),
          child: AdvancedFilterPanel(
            onFiltersChanged: (filters) => _applyAdvancedFilters(filters),
            onReset: () => _resetAdvancedFilters(),
          ),
        ),
      ),
    );
  }

  /// Apply advanced filters and reload events
  void _applyAdvancedFilters(Map<String, dynamic> filters) async {
    setState(() {
      _activeFilters = filters;
      _isLoading = true;
    });

    try {
      // Use enhanced events service for filtered search
      List<Event> filteredEvents = await EnhancedEventsService.searchEventsWithFilters(filters);
      
      setState(() {
        events = filteredEvents;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found ${filteredEvents.length} events matching your filters'),
          backgroundColor: AppColors.dubaiTeal,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        errorMessage = 'Failed to apply filters: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to apply filters'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Reset advanced filters
  void _resetAdvancedFilters() {
    setState(() {
      _activeFilters.clear();
    });
    _loadEvents(); // Reload original events
  }

  /// Toggle enhanced event card view
  void _toggleEnhancedView() {
    setState(() {
      _useEnhancedCard = !_useEnhancedCard;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_useEnhancedCard 
            ? 'Enhanced event cards enabled' 
            : 'Enhanced event cards disabled'),
        backgroundColor: AppColors.dubaiTeal,
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: _currentViewMode == ViewMode.list ? EdgeInsets.only(bottom: 16) : EdgeInsets.zero,
      child: _useEnhancedCard 
          ? EnhancedEventCard(
              event: event,
              showQualityMetrics: _showQualityMetrics,
              showSocialMedia: true,
              onTap: () => _navigateToEventDetail(event),
            )
          : EventCardEnhanced(
              event: event,
              onTap: () => _navigateToEventDetail(event),
              onFavorite: () {
                // TODO: Implement favorite functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added ${event.title} to favorites'),
                    backgroundColor: AppColors.dubaiTeal,
                  ),
                );
              },
              isFavorite: false, // TODO: Get from favorites provider
            ),
    );
  }

  // Helper methods for formatting event information
  String _formatEventDateTime(Event event, bool isMobile) {
    final startDate = event.startDate;
    final now = DateTime.now();
    final isToday = startDate.day == now.day && 
                   startDate.month == now.month && 
                   startDate.year == now.year;
    
    String dayName;
    if (isToday) {
      dayName = 'Today';
    } else {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      dayName = weekdays[startDate.weekday - 1];
    }
    
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[startDate.month - 1];
    
    final startTime = '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}';
    
    if (isMobile) {
      return '$dayName, $month ${startDate.day} • $startTime';
    } else {
      final endDate = event.endDate ?? startDate.add(event.duration);
      final endTime = '${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}';
      return '$dayName, $month ${startDate.day} • $startTime - $endTime';
    }
  }

  String _formatAgeSuitability(Event event, bool isMobile) {
    final suitability = event.familySuitability;
    String ageText = event.ageRange;
    
    if (isMobile) {
      if (suitability.isAllAges) return 'All ages';
      return ageText;
    } else {
      if (suitability.isAllAges) {
        return 'All ages welcome | Perfect for families';
      } else if (suitability.isBabyFriendly) {
        return '$ageText | Toddler-friendly';
      } else {
        return '$ageText | Perfect for families';
      }
    }
  }

  String _formatDuration(Event event) {
    return '${DurationFormatter.formatForDetails(event.startDate, event.endDate)} experience';
  }

  // Enhanced filtering logic to match homepage counts
  bool _shouldUseEnhancedFiltering(String category) {
    // Categories that need enhanced tag-based filtering like homepage
    const enhancedCategories = [
      'kids_and_family',
      'entertainment',
      'outdoor_activities',
      'food_and_dining',
      'culture',
      'indoor_activities'
    ];
    return enhancedCategories.contains(category);
  }

  List<Event> _applyEnhancedCategoryFiltering(List<Event> allEvents, String categoryFilter) {
    // Get category configuration from homepage logic
    final categoryConfig = _getCategoryConfig(categoryFilter);
    if (categoryConfig == null) return [];

    final apiCategories = List<String>.from(categoryConfig['apiCategories'] ?? []);
    final tags = List<String>.from(categoryConfig['tags'] ?? []);

    print('🏷️ DEBUG: Filtering with categories: $apiCategories, tags: $tags');

    final matchedEvents = <Event>[];
    int totalChecked = 0;
    int categoryMatches = 0;
    int tagMatches = 0;
    
    for (final event in allEvents) {
      totalChecked++;
      
      // Check exact category match (case-insensitive)
      final categoryMatch = apiCategories.any((category) => 
        event.category.toLowerCase() == category.toLowerCase()
      );
      
      // Check tag match (case-insensitive partial matching)
      final tagMatch = tags.any((tag) => 
        event.tags.any((eventTag) => 
          eventTag.toLowerCase().contains(tag.toLowerCase())
        ) ||
        event.category.toLowerCase().contains(tag.toLowerCase()) ||
        event.title.toLowerCase().contains(tag.toLowerCase())
      );
      
      final matches = categoryMatch || tagMatch;
      
      if (matches) {
        matchedEvents.add(event);
        if (categoryMatch) categoryMatches++;
        if (tagMatch) tagMatches++;
        
        if (matchedEvents.length <= 5) { // Show first 5 matches for debugging
          print('✅ MATCH #${matchedEvents.length}: "${event.title}"');
          print('   Category: ${event.category} (match: $categoryMatch)');
          print('   Tags: ${event.tags} (match: $tagMatch)');
        }
      }
    }
    
    print('📊 Filtering Results: $totalChecked events checked, ${matchedEvents.length} matched');
    print('   - Category matches: $categoryMatches');
    print('   - Tag matches: $tagMatches');
    
    return matchedEvents;
  }

  Map<String, dynamic>? _getCategoryConfig(String categoryFilter) {
    // Mirror the category configurations from InteractiveCategoryExplorer
    const categoryConfigs = {
      'kids_and_family': {
        'apiCategories': ['kids_and_family', 'educational'],
        'tags': ['kids', 'family', 'children', 'educational', 'playground', 'activities'],
      },
      'entertainment': {
        'apiCategories': ['entertainment', 'music_and_concerts', 'comedy_and_shows', 'music'],
        'tags': ['entertainment', 'music', 'concert', 'show', 'performance', 'nightlife'],
      },
      'outdoor_activities': {
        'apiCategories': ['outdoor_activities', 'sports_and_fitness', 'outdoor', 'sports'],
        'tags': ['outdoor', 'sports', 'beach', 'water', 'nature', 'park', 'hiking'],
      },
      'culture': {
        'apiCategories': ['arts_and_culture', 'culture', 'arts'],
        'tags': ['culture', 'art', 'museum', 'gallery', 'heritage', 'history'],
      },
      'food_and_dining': {
        'apiCategories': ['food_and_dining', 'food'],
        'tags': ['food', 'dining', 'restaurant', 'cuisine', 'festival', 'cooking'],
      },
      'indoor_activities': {
        'apiCategories': ['indoor_activities', 'shopping_and_lifestyle', 'indoor'],
        'tags': ['indoor', 'shopping', 'mall', 'lifestyle', 'wellness', 'spa'],
      },
    };
    
    return categoryConfigs[categoryFilter];
  }

  List<String> _getKeyFeatures(Event event) {
    List<String> features = [];
    
    // Map categories and tags to features with emojis
    if (event.category.toLowerCase().contains('outdoor') || event.tags.contains('outdoor')) {
      features.add('🌲 Outdoor Fun');
    }
    if (event.category.toLowerCase().contains('water') || event.tags.contains('water')) {
      features.add('🌊 Water Activities');
    }
    if (event.category.toLowerCase().contains('arts') || event.tags.contains('arts')) {
      features.add('🎨 Arts & Crafts');
    }
    if (event.category.toLowerCase().contains('cultural') || event.tags.contains('cultural')) {
      features.add('🏛️ Cultural Experience');
    }
    if (event.category.toLowerCase().contains('food') || event.tags.contains('food')) {
      features.add('🍕 Food Included');
    }
    if (event.category.toLowerCase().contains('education') || event.tags.contains('educational')) {
      features.add('📚 Educational');
    }
    if (event.category.toLowerCase().contains('entertainment') || event.tags.contains('entertainment')) {
      features.add('🎭 Live Shows');
    }
    
    // Add accessibility features
    if (event.venue.parkingAvailable) {
      features.add('🚗 Free Parking');
    }
    if (event.familySuitability.strollerFriendly) {
      features.add('🚶‍♀️ Stroller OK');
    }
    if (event.tags.contains('indoor') || event.category.toLowerCase().contains('indoor')) {
      features.add('🌡️ Air Conditioned');
    }
    if (event.tags.contains('photography') || event.category.toLowerCase().contains('photo')) {
      features.add('📸 Photo Ops');
    }
    if (event.familySuitability.educationalContent) {
      features.add('🎓 Learn & Play');
    }
    
    // Default features if none found
    if (features.isEmpty) {
      if (event.isFree) {
        features.add('🎫 Free Entry');
      }
      features.add('👨‍👩‍👧‍👦 Family Fun');
      features.add('📍 Dubai Activity');
    }
    
    return features;
  }

  Widget _buildFeatureTag(String feature, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: Color(0xFF0D7377).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF0D7377).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        feature,
        style: GoogleFonts.inter(
          fontSize: isMobile ? 9 : 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFF0D7377),
        ),
      ),
    );
  }

  String _getEnticingDescription(Event event, bool isMobile) {
    // Use shortDescription if available, otherwise create one from the event data
    if (event.shortDescription != null && event.shortDescription!.isNotEmpty) {
      return event.shortDescription!;
    }
    
    // Generate enticing descriptions based on category and features
    if (event.category.toLowerCase().contains('miracle') || event.title.toLowerCase().contains('garden')) {
      return isMobile 
          ? "45 million flowers in stunning themed gardens with..."
          : "45 million flowers in stunning themed gardens with interactive displays and cultural performances";
    } else if (event.category.toLowerCase().contains('mall') || event.venue.name.toLowerCase().contains('mall')) {
      return isMobile
          ? "Hands-on activities, mini-golf, face painting and..."
          : "Hands-on activities, mini-golf, face painting and exclusive family discounts at 200+ stores";
    } else if (event.category.toLowerCase().contains('cultural')) {
      return isMobile
          ? "Traditional crafts, storytelling, and cultural..."
          : "Traditional crafts, storytelling, and cultural performances in historic setting";
    } else if (event.category.toLowerCase().contains('outdoor') || event.tags.contains('outdoor')) {
      return isMobile
          ? "Guided family adventure with breakfast and..."
          : "Guided family hike with breakfast and stunning mountain photography opportunities";
    } else if (event.category.toLowerCase().contains('water') || event.tags.contains('water')) {
      return isMobile
          ? "Interactive marine workshop with feeding sessions..."
          : "Interactive marine workshop with feeding sessions and behind-the-scenes tours";
    } else if (event.category.toLowerCase().contains('arts')) {
      return isMobile
          ? "Creative workshops with professional artists and..."
          : "Creative workshops with professional artists and take-home masterpieces for the family";
    } else if (event.category.toLowerCase().contains('entertainment')) {
      return isMobile
          ? "Live performances, games, and interactive..."
          : "Live performances, games, and interactive entertainment for all ages with special family packages";
    } else {
      // Fallback description
      return isMobile
          ? "Exciting family activity with interactive experiences..."
          : "Exciting family activity with interactive experiences and memories to last a lifetime";
    }
  }

  Widget _buildImageFallback() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D7377), Color(0xFF329D9C)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 40,
              color: Colors.white.withOpacity(0.8),
            ),
            SizedBox(height: 8),
            Text(
              'Dubai Family Event',
              style: GoogleFonts.comfortaa(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF0D7377).withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            height: isMobile ? 380 : 450,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image skeleton
                Container(
                  height: isMobile ? 140 : 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFF0D7377).withOpacity(0.2),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1200.ms, color: Color(0xFF329D9C).withOpacity(0.6)),
                
                // Skeleton content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title skeleton
                        Container(
                          width: double.infinity,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Color(0xFF0D7377).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        )
                            .animate(onPlay: (controller) => controller.repeat())
                            .shimmer(duration: 1200.ms, color: Color(0xFF329D9C).withOpacity(0.6)),
                        
                        SizedBox(height: 8),
                        
                        // Location skeleton
                        Container(
                          width: 150,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Color(0xFF0D7377).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        )
                            .animate(onPlay: (controller) => controller.repeat())
                            .shimmer(duration: 1200.ms, color: Color(0xFF329D9C).withOpacity(0.6)),
                        
                        SizedBox(height: 12),
                        
                        // Date/time skeleton
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Color(0xFF0D7377).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        )
                            .animate(onPlay: (controller) => controller.repeat())
                            .shimmer(duration: 1200.ms, color: Color(0xFF329D9C).withOpacity(0.6)),
                        
                        SizedBox(height: 8),
                        
                        // Age suitability skeleton
                        Container(
                          width: 180,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(0xFF0D7377).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        )
                            .animate(onPlay: (controller) => controller.repeat())
                            .shimmer(duration: 1200.ms, color: Color(0xFF329D9C).withOpacity(0.6)),
                        
                        SizedBox(height: 8),
                        
                        // Duration skeleton
                        Container(
                          width: 120,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(0xFF0D7377).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        )
                            .animate(onPlay: (controller) => controller.repeat())
                            .shimmer(duration: 1200.ms, color: Color(0xFF329D9C).withOpacity(0.6)),
                        
                        SizedBox(height: 12),
                        
                        // Feature tags skeleton
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Color(0xFF0D7377).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            )
                                .animate(onPlay: (controller) => controller.repeat())
                                .shimmer(duration: 1200.ms, color: Color(0xFF329D9C).withOpacity(0.6)),
                            SizedBox(width: 8),
                            Container(
                              width: 70,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Color(0xFF0D7377).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            )
                                .animate(onPlay: (controller) => controller.repeat())
                                .shimmer(duration: 1200.ms, color: Color(0xFF329D9C).withOpacity(0.6)),
                            if (!isMobile) ...[
                              SizedBox(width: 8),
                              Container(
                                width: 90,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color(0xFF0D7377).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              )
                                  .animate(onPlay: (controller) => controller.repeat())
                                  .shimmer(duration: 1200.ms, color: Color(0xFF329D9C).withOpacity(0.6)),
                            ],
                          ],
                        ),
                        
                        SizedBox(height: 12),
                        
                        // Description skeleton
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: Color(0xFF0D7377).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              )
                                  .animate(onPlay: (controller) => controller.repeat())
                                  .shimmer(duration: 1200.ms, color: Color(0xFF329D9C).withOpacity(0.6)),
                              SizedBox(height: 4),
                              Container(
                                width: isMobile ? double.infinity : 200,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: Color(0xFF0D7377).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              )
                                  .animate(onPlay: (controller) => controller.repeat())
                                  .shimmer(duration: 1200.ms, color: Color(0xFF329D9C).withOpacity(0.6)),
                              if (!isMobile) ...[
                                SizedBox(height: 4),
                                Container(
                                  width: 150,
                                  height: 13,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF0D7377).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                )
                                    .animate(onPlay: (controller) => controller.repeat())
                                    .shimmer(duration: 1200.ms, color: Color(0xFF329D9C).withOpacity(0.6)),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get the appropriate count to display based on filter state
  int _getDisplayCount() {
    if (_hasActiveFilters()) {
      // When filters are active, show filtered count
      return _getFilteredEvents().length;
    } else {
      // When no filters, show total from database
      return _totalEventsInDb;
    }
  }
  
  /// Get the appropriate label for the count
  String _getCountLabel() {
    final count = _getDisplayCount();
    if (_hasActiveFilters()) {
      return count == 1 ? 'event found' : 'events found';
    } else {
      return count == 1 ? 'event available' : 'events available';
    }
  }
  
  /// Check if any filters are currently active
  bool _hasActiveFilters() {
    return _searchController.text.isNotEmpty || 
           _currentFilters.hasActiveFilters ||
           selectedCategory != null ||
           selectedLocation != null;
  }
  
  /// Get the appropriate page title based on category
  String _getPageTitle() {
    return widget.categoryDisplayName ?? 'All Events';
  }
  
  /// Get the appropriate page subtitle based on category
  String _getPageSubtitle() {
    if (widget.categoryDisplayName != null) {
      return 'Discover ${widget.categoryDisplayName!.toLowerCase()} events in Dubai';
    }
    return 'Discover amazing family activities in Dubai';
  }
  
  /// Map display category names to database category values
  List<String> _mapCategoryToDbValue(String displayCategory) {
    switch (displayCategory.toLowerCase()) {
      case 'kids & family':
        return ['kids_and_family', 'family'];
      case 'outdoor activities':
        return ['outdoor_activities', 'outdoor'];
      case 'indoor activities':
        return ['indoor_activities', 'indoor'];
      case 'food & dining':
        return ['food_and_dining', 'food'];
      case 'cultural':
        return ['cultural', 'culture'];
      case 'tours & sightseeing':
        return ['tours_and_sightseeing', 'tours', 'sightseeing'];
      case 'water sports':
        return ['water_sports', 'water'];
      case 'music & concerts':
        return ['music_and_concerts', 'music', 'concerts'];
      case 'comedy & shows':
        return ['comedy_and_shows', 'comedy', 'shows', 'entertainment'];
      case 'sports & fitness':
        return ['sports_and_fitness', 'sports', 'fitness'];
      case 'business & networking':
        return ['business_and_networking', 'business', 'networking'];
      case 'festivals & celebrations':
        return ['festivals_and_celebrations', 'festivals', 'celebrations'];
      default:
        return [displayCategory.toLowerCase()];
    }
  }
  
  /// Check if event location matches filter location with fuzzy matching
  bool _isLocationMatch(String eventArea, String filterLocation) {
    final eventAreaLower = eventArea.toLowerCase();
    final filterLocationLower = filterLocation.toLowerCase();
    
    // Direct contains match
    if (eventAreaLower.contains(filterLocationLower) || 
        filterLocationLower.contains(eventAreaLower)) {
      return true;
    }
    
    // Handle common variations and abbreviations
    final locationMappings = {
      'dubai marina': ['marina', 'dmcc', 'jbr walk'],
      'jbr': ['jumeirah beach residence', 'marina', 'beach walk'],
      'downtown dubai': ['downtown', 'burj khalifa', 'dubai mall', 'souk al bahar'],
      'palm jumeirah': ['palm', 'atlantis', 'golden mile'],
      'jumeirah': ['umm suqeim', 'burj al arab', 'madinat jumeirah'],
      'deira': ['gold souk', 'spice souk', 'al rigga'],
      'bur dubai': ['al fahidi', 'bastakiya', 'dubai museum'],
      'business bay': ['bay avenue', 'bay square'],
      'al barsha': ['mall of emirates', 'barsha heights'],
      'city walk': ['al safa', 'boxpark'],
      'difc': ['financial centre', 'gate village'],
      'dubailand': ['global village', 'dragon mart']
    };
    
    // Check if filter location maps to event area
    for (String key in locationMappings.keys) {
      if (filterLocationLower.contains(key) || key.contains(filterLocationLower)) {
        for (String mapping in locationMappings[key]!) {
          if (eventAreaLower.contains(mapping)) {
            return true;
          }
        }
      }
    }
    
    // Check reverse mapping (event area maps to filter location)
    for (String key in locationMappings.keys) {
      if (eventAreaLower.contains(key) || key.contains(eventAreaLower)) {
        for (String mapping in locationMappings[key]!) {
          if (filterLocationLower.contains(mapping)) {
            return true;
          }
        }
      }
    }
    
    return false;
  }
  
  /// Check if event matches the selected age group filter
  bool _isAgeGroupMatch(Event event, String ageGroup) {
    final minAge = event.familySuitability.minAge;
    final maxAge = event.familySuitability.maxAge;
    
    switch (ageGroup) {
      case 'Toddlers (0-3)':
        // Event is suitable for toddlers if min age is 0-3 or null (all ages)
        return minAge == null || minAge <= 3;
      
      case 'Kids (4-12)':
        // Event is suitable for kids if it overlaps with 4-12 age range
        if (minAge == null && maxAge == null) return true; // All ages
        if (minAge == null) return maxAge! >= 4; // No min age, max age >= 4
        if (maxAge == null) return minAge <= 12; // No max age, min age <= 12
        return minAge <= 12 && maxAge >= 4; // Overlap with 4-12 range
      
      case 'Teens (13-17)':
        // Event is suitable for teens if it overlaps with 13-17 age range
        if (minAge == null && maxAge == null) return true; // All ages
        if (minAge == null) return maxAge! >= 13; // No min age, max age >= 13
        if (maxAge == null) return minAge <= 17; // No max age, min age <= 17
        return minAge <= 17 && maxAge >= 13; // Overlap with 13-17 range
      
      case 'All Ages':
        // All ages events have no restrictions or very broad restrictions
        return minAge == null || minAge <= 5; // No minimum or very low minimum
      
      default:
        return true;
    }
  }
  
  /// Check if event has the specified feature
  bool _hasFeature(Event event, String feature) {
    switch (feature.toLowerCase()) {
      case 'stroller friendly':
        return event.familySuitability.strollerFriendly;
      
      case 'parking available':
        return event.venue.parkingAvailable;
      
      case 'metro access':
        return event.venue.publicTransportAccess || 
               (event.metroAccessible == true);
      
      case 'indoor':
        return event.category.toLowerCase().contains('indoor') ||
               event.tags.any((tag) => tag.toLowerCase().contains('indoor')) ||
               (event.venueType?.toLowerCase().contains('indoor') == true);
      
      case 'outdoor':
        return event.category.toLowerCase().contains('outdoor') ||
               event.tags.any((tag) => tag.toLowerCase().contains('outdoor')) ||
               (event.venueType?.toLowerCase().contains('outdoor') == true);
      
      case 'air conditioned':
        // Assume indoor venues are air conditioned
        return event.category.toLowerCase().contains('indoor') ||
               event.tags.any((tag) => tag.toLowerCase().contains('indoor')) ||
               event.tags.any((tag) => tag.toLowerCase().contains('ac')) ||
               event.tags.any((tag) => tag.toLowerCase().contains('air conditioned'));
      
      case 'free entry':
        return event.isFree;
      
      case 'educational content':
        return event.familySuitability.educationalContent ||
               event.tags.any((tag) => tag.toLowerCase().contains('educational')) ||
               event.tags.any((tag) => tag.toLowerCase().contains('learning')) ||
               event.category.toLowerCase().contains('educational');
      
      default:
        // Fallback to tag matching
        return event.tags.any((tag) => 
          tag.toLowerCase().contains(feature.toLowerCase())
        );
    }
  }
  
  /// Check if event matches the selected time slot
  bool _isTimeSlotMatch(Event event, String timeSlot) {
    final hour = event.startDate.hour;
    final endHour = event.endDate?.hour;
    
    switch (timeSlot.toLowerCase()) {
      case 'morning':
        // Event starts in morning (6 AM - 12 PM)
        return hour >= 6 && hour < 12;
      
      case 'afternoon':
        // Event starts in afternoon (12 PM - 6 PM)
        return hour >= 12 && hour < 18;
      
      case 'evening':
        // Event starts in evening (6 PM - 12 AM)
        return hour >= 18 || hour < 6; // Include late night events
      
      case 'all day':
        // Multi-hour events or events with long duration
        if (endHour != null) {
          final duration = event.endDate!.difference(event.startDate).inHours;
          return duration >= 6; // Events lasting 6+ hours are considered "all day"
        } else if (event.durationHours != null) {
          return event.durationHours! >= 6;
        }
        // For events without end time, assume single time slot
        return false;
      
      default:
        return true;
    }
  }
  
  /// Apply smart search with intelligent matching and ranking
  List<Event> _applySmartSearch(List<Event> events, String query) {
    final searchQuery = query.trim().toLowerCase();
    if (searchQuery.isEmpty) return events;
    
    // Split query into keywords for multi-word search
    final keywords = searchQuery.split(' ').where((word) => word.length >= 2).toList();
    if (keywords.isEmpty) return events;
    
    // List to store events with their relevance scores
    List<MapEntry<Event, double>> scoredEvents = [];
    
    for (final event in events) {
      final score = _calculateSearchScore(event, searchQuery, keywords);
      if (score > 0) {
        scoredEvents.add(MapEntry(event, score));
      }
    }
    
    // Sort by relevance score (highest first)
    scoredEvents.sort((a, b) => b.value.compareTo(a.value));
    
    // Return sorted events
    return scoredEvents.map((entry) => entry.key).toList();
  }
  
  /// Calculate search relevance score for an event
  double _calculateSearchScore(Event event, String fullQuery, List<String> keywords) {
    double score = 0.0;
    
    final title = event.title.toLowerCase();
    final description = event.description.toLowerCase();
    final category = event.category.toLowerCase();
    final area = event.venue.area.toLowerCase();
    final venueName = event.venue.name.toLowerCase();
    final tags = event.tags.map((tag) => tag.toLowerCase()).toList();
    
    // Full query exact matches (highest priority)
    if (title.contains(fullQuery)) {
      score += title.startsWith(fullQuery) ? 100.0 : 80.0; // Bonus for title starting with query
    }
    if (description.contains(fullQuery)) score += 60.0;
    if (category.contains(fullQuery)) score += 70.0;
    if (area.contains(fullQuery)) score += 50.0;
    if (venueName.contains(fullQuery)) score += 55.0;
    
    // Tag matches for full query
    for (final tag in tags) {
      if (tag.contains(fullQuery)) {
        score += tag == fullQuery ? 75.0 : 45.0; // Bonus for exact tag match
      }
    }
    
    // Keyword-based scoring
    for (final keyword in keywords) {
      // Title keyword matches
      if (title.contains(keyword)) {
        score += title.startsWith(keyword) ? 30.0 : 20.0;
      }
      
      // Category keyword matches
      if (category.contains(keyword)) score += 25.0;
      
      // Location keyword matches
      if (area.contains(keyword)) score += 20.0;
      if (venueName.contains(keyword)) score += 18.0;
      
      // Description keyword matches
      if (description.contains(keyword)) score += 15.0;
      
      // Tag keyword matches
      for (final tag in tags) {
        if (tag.contains(keyword)) {
          score += tag == keyword ? 22.0 : 12.0;
        }
      }
      
      // Enhanced content matches (if available)
      if (event.enhancedContent != null) {
        final highlights = event.enhancedContent!.highlights?.toLowerCase() ?? '';
        final familySummary = event.enhancedContent!.familySummary?.toLowerCase() ?? '';
        final kidsDescription = event.enhancedContent!.kidsDescription?.toLowerCase() ?? '';
        final practicalInfo = event.enhancedContent!.practicalInfo?.toLowerCase() ?? '';
        final tips = event.enhancedContent!.tips?.toLowerCase() ?? '';
        
        if (highlights.contains(keyword)) score += 10.0;
        if (familySummary.contains(keyword)) score += 12.0;
        if (kidsDescription.contains(keyword)) score += 11.0;
        if (practicalInfo.contains(keyword)) score += 8.0;
        if (tips.contains(keyword)) score += 7.0;
      }
    }
    
    // Category-based bonuses for specific search terms
    score += _getCategoryBonus(fullQuery, category);
    
    // Location-based bonuses
    score += _getLocationBonus(fullQuery, area, venueName);
    
    // Family-friendly bonus for family-related searches
    if (_isFamilySearch(fullQuery) && event.familySuitability.minAge != null && event.familySuitability.minAge! <= 12) {
      score += 15.0;
    }
    
    // Free events bonus for price-related searches
    if (_isPriceSearch(fullQuery) && event.isFree) {
      score += 10.0;
    }
    
    return score;
  }
  
  /// Get category-specific bonus scores
  double _getCategoryBonus(String query, String category) {
    final Map<String, List<String>> categoryKeywords = {
      'kids_and_family': ['family', 'kids', 'children', 'playground', 'fun'],
      'outdoor_activities': ['outdoor', 'park', 'beach', 'adventure', 'nature'],
      'indoor_activities': ['indoor', 'mall', 'center', 'museum', 'gallery'],
      'food_and_dining': ['food', 'restaurant', 'dining', 'cafe', 'meal'],
      'water_sports': ['water', 'beach', 'swimming', 'boat', 'diving'],
      'cultural': ['culture', 'heritage', 'art', 'history', 'traditional'],
      'music_and_concerts': ['music', 'concert', 'show', 'performance', 'band'],
      'sports_and_fitness': ['sport', 'fitness', 'gym', 'exercise', 'training'],
    };
    
    for (final entry in categoryKeywords.entries) {
      if (category.contains(entry.key)) {
        for (final keyword in entry.value) {
          if (query.contains(keyword)) {
            return 20.0;
          }
        }
      }
    }
    
    return 0.0;
  }
  
  /// Get location-specific bonus scores
  double _getLocationBonus(String query, String area, String venueName) {
    // Popular location keywords
    final locationKeywords = {
      'marina': ['marina', 'jbr', 'beach walk'],
      'downtown': ['downtown', 'burj khalifa', 'dubai mall'],
      'jumeirah': ['jumeirah', 'burj al arab', 'palm'],
      'business bay': ['business bay', 'canal'],
      'deira': ['deira', 'gold souk', 'spice souk'],
    };
    
    for (final entry in locationKeywords.entries) {
      if (area.contains(entry.key) || venueName.contains(entry.key)) {
        for (final keyword in entry.value) {
          if (query.contains(keyword)) {
            return 15.0;
          }
        }
      }
    }
    
    return 0.0;
  }
  
  /// Check if search is family-related
  bool _isFamilySearch(String query) {
    final familyKeywords = ['family', 'kids', 'children', 'toddler', 'baby', 'playground'];
    return familyKeywords.any((keyword) => query.contains(keyword));
  }
  
  /// Check if search is price-related
  bool _isPriceSearch(String query) {
    final priceKeywords = ['free', 'cheap', 'budget', 'affordable', 'cost'];
    return priceKeywords.any((keyword) => query.contains(keyword));
  }
  
  /// Show calendar date filter dialog
  Future<void> _showDateFilterDialog() async {
    DateTime? startDate = _currentFilters.customDateStart;
    DateTime? endDate = _currentFilters.customDateEnd;
    String selectedRange = _currentFilters.dateRange ?? 'custom';
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
          title: Row(
            children: [
              Icon(LucideIcons.calendar, color: AppColors.dubaiTeal, size: 24),
              SizedBox(width: 8),
              Text('Filter by Date', style: GoogleFonts.comfortaa(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              )),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick date range options
                Text('Quick Options:', style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDateRangeChip('Today', 'today', selectedRange, (value) => setDialogState(() => selectedRange = value)),
                    _buildDateRangeChip('This Week', 'this_week', selectedRange, (value) => setDialogState(() => selectedRange = value)),
                    _buildDateRangeChip('Next Week', 'next_week', selectedRange, (value) => setDialogState(() => selectedRange = value)),
                    _buildDateRangeChip('This Month', 'this_month', selectedRange, (value) => setDialogState(() => selectedRange = value)),
                    _buildDateRangeChip('Custom Range', 'custom', selectedRange, (value) => setDialogState(() => selectedRange = value)),
                  ],
                ),
                
                if (selectedRange == 'custom') ...[
                  SizedBox(height: 20),
                  Text('Custom Date Range:', style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )),
                  SizedBox(height: 12),
                  
                  // Start date picker
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime.now().subtract(Duration(days: 30)),
                              lastDate: DateTime.now().add(Duration(days: 365)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppColors.dubaiTeal,
                                      onPrimary: Colors.white,
                                      surface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setDialogState(() {
                                startDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.calendar, size: 16, color: AppColors.dubaiTeal),
                                SizedBox(width: 8),
                                Text(
                                  startDate != null 
                                    ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                                    : 'Start Date',
                                  style: GoogleFonts.inter(
                                    color: startDate != null ? AppColors.textPrimary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('to', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                      SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? startDate ?? DateTime.now(),
                              firstDate: startDate ?? DateTime.now(),
                              lastDate: DateTime.now().add(Duration(days: 365)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppColors.dubaiTeal,
                                      onPrimary: Colors.white,
                                      surface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setDialogState(() {
                                endDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.calendar, size: 16, color: AppColors.dubaiTeal),
                                SizedBox(width: 8),
                                Text(
                                  endDate != null 
                                    ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                                    : 'End Date',
                                  style: GoogleFonts.inter(
                                    color: endDate != null ? AppColors.textPrimary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({'clear': true});
              },
              child: Text('Clear Filter', style: GoogleFonts.inter(color: AppColors.dubaiCoral)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'dateRange': selectedRange != 'custom' ? selectedRange : null,
                  'startDate': selectedRange == 'custom' ? startDate : null,
                  'endDate': selectedRange == 'custom' ? endDate : null,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dubaiTeal,
                foregroundColor: Colors.white,
              ),
              child: Text('Apply Filter'),
            ),
          ],
        );
        },
      ),
    );
    
    if (result != null) {
      setState(() {
        if (result['clear'] == true) {
          // Clear date filters
          _currentFilters = EventFilterData(
            locations: _currentFilters.locations,
            categories: _currentFilters.categories,
            ageGroups: _currentFilters.ageGroups,
            minPrice: _currentFilters.minPrice,
            maxPrice: _currentFilters.maxPrice,
            timeOfDay: _currentFilters.timeOfDay,
            features: _currentFilters.features,
            // Clear date-related fields
            dateRange: null,
            customDateStart: null,
            customDateEnd: null,
          );
        } else {
          // Apply new date filters
          _currentFilters = _currentFilters.copyWith(
            dateRange: result['dateRange'],
            customDateStart: result['startDate'],
            customDateEnd: result['endDate'],
          );
        }
        _loadEvents();
      });
    }
  }
  
  Widget _buildDateRangeChip(String label, String value, String selectedRange, Function(String) onSelected) {
    final isSelected = selectedRange == value;
    return InkWell(
      onTap: () => onSelected(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.dubaiTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.dubaiTeal : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  /// Format category name for display
  String _formatCategoryName(String category) {
    switch (category.toLowerCase()) {
      case 'tours_and_sightseeing':
        return 'Tours';
      case 'business_and_networking':
        return 'Business';
      case 'kids_and_family':
        return 'Family';
      case 'food_and_dining':
        return 'Food';
      case 'indoor_activities':
        return 'Indoor';
      case 'outdoor_activities':
        return 'Outdoor';
      case 'water_sports':
        return 'Water';
      case 'music_and_concerts':
        return 'Music';
      case 'comedy_and_shows':
        return 'Shows';
      case 'sports_and_fitness':
        return 'Sports';
      case 'festivals_and_celebrations':
        return 'Festival';
      default:
        return category.replaceAll('_', ' ').split(' ').map((word) => 
          word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
        ).join(' ');
    }
  }
  
  /// Get display description for event
  String _getDisplayDescription(Event event) {
    if (event.shortDescription != null && event.shortDescription!.isNotEmpty) {
      return event.shortDescription!;
    }
    
    if (event.description.isNotEmpty) {
      // Truncate long descriptions for mobile cards
      if (event.description.length > 150) {
        return '${event.description.substring(0, 150)}...';
      }
      return event.description;
    }
    
    // Fallback description based on category
    final area = event.venue.area;
    switch (event.category.toLowerCase()) {
      case 'kids_and_family':
        return 'Perfect family activity with fun for all ages in $area.';
      case 'food_and_dining':
        return 'Delicious dining experience in the heart of $area.';
      case 'outdoor_activities':
        return 'Exciting outdoor adventure in beautiful $area.';
      case 'cultural':
        return 'Immersive cultural experience showcasing local heritage.';
      default:
        return 'Exciting event experience in $area.';
    }
  }
  
  /// Build mobile-optimized event card for carousel
  Widget _buildMobileEventCard(Event event) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: AppColors.dubaiTeal.withOpacity(0.2),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(
                eventId: event.id,
                event: event,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large image section for mobile
            Container(
              height: 180, // Generous height for mobile viewing
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                color: Colors.grey[200],
              ),
              child: Stack(
                children: [
                  // Event image
                  if (event.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: CachedNetworkImage(
                        imageUrl: event.imageUrl,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.dubaiTeal.withOpacity(0.1),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.dubaiTeal,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => _buildImageFallback(),
                      ),
                    )
                  else
                    _buildImageFallback(),
                  
                  // Gradient overlay for better text readability
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  
                  // Price badge in top-right
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: event.isFree ? AppColors.dubaiTeal : AppColors.dubaiGold,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        event.displayPrice,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  // Category badge in top-left
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatCategoryName(event.category),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content section with generous padding
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event title
                    Text(
                      event.title,
                      style: GoogleFonts.comfortaa(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Date and time
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 14,
                          color: AppColors.dubaiTeal,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _formatEventDateTime(event, true),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Location
                    Row(
                      children: [
                        Icon(
                          LucideIcons.mapPin,
                          size: 14,
                          color: AppColors.dubaiCoral,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${event.venue.name} • ${event.venue.area}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Description
                    Expanded(
                      child: Text(
                        _getDisplayDescription(event),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Bottom row with rating and family score
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        Row(
                          children: [
                            Icon(
                              LucideIcons.star,
                              size: 14,
                              color: AppColors.dubaiGold,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.rating.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        
                        // Age range
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.dubaiTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            event.ageRange,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dubaiTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
