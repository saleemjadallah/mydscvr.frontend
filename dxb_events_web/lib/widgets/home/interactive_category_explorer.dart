import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/animations/animations.dart';
import '../../features/events/events_list_screen_simple.dart';
import '../../services/events_service.dart';
import '../../models/event.dart';

class InteractiveCategoryExplorer extends StatefulWidget {
  const InteractiveCategoryExplorer({super.key});

  @override
  State<InteractiveCategoryExplorer> createState() => _InteractiveCategoryExplorerState();
}

class _InteractiveCategoryExplorerState extends State<InteractiveCategoryExplorer>
    with TickerProviderStateMixin {
  
  String? _hoveredCategory;
  late final EventsService _eventsService;
  Map<String, List<Event>> _categoryEvents = {};
  Map<String, int> _categoryCounts = {};
  bool _isLoading = true;
  
  // Static fallback counts for immediate display (conservative estimates)
  static const Map<String, int> _fallbackCounts = {
    'culture': 5,
    'outdoor': 8,
    'kids': 12,
    'food': 6,
    'entertainment': 4, // Conservative estimate until real data loads
    'indoor': 7,
  };
  
  // Cache for category data
  static Map<String, List<Event>>? _cachedCategoryEvents;
  static Map<String, int>? _cachedCategoryCounts;
  static DateTime? _cacheTimestamp;
  
  final categories = [
    {
      'id': 'culture',
      'name': 'Cultural',
      'emoji': '🎭',
      'icon': LucideIcons.landmark,
      'apiCategories': ['cultural', 'arts'],
      'tags': ['cultural', 'heritage', 'art', 'museum', 'gallery', 'theater', 'opera'],
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF6B35), Color(0xFFFF4757)],
      ),
      'bgImage': 'https://images.unsplash.com/photo-1544967882-4d0e306c8d68?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'subCategories': ['Museums', 'Art Galleries', 'Heritage Sites'],
    },
    {
      'id': 'outdoor',
      'name': 'Outdoor Activities',
      'emoji': '🌳',
      'icon': LucideIcons.mountain,
      'apiCategories': ['outdoor_activities', 'sports', 'adventure', 'beach', 'water_sports'],
      'tags': ['outdoor', 'sports', 'beach', 'water', 'nature', 'park', 'hiking', 'adventure'],
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
      ),
      'bgImage': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'subCategories': ['Parks', 'Beaches', 'Sports'],
    },
    {
      'id': 'kids',
      'name': 'Kids & Family',
      'emoji': '🎈',
      'icon': LucideIcons.baby,
      'apiCategories': ['family_activities', 'educational', 'kids_activities'],
      'tags': ['kids', 'family', 'children', 'educational', 'playground', 'activities'],
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
      ),
      'bgImage': 'https://images.unsplash.com/photo-1527856263669-12c3a0af2aa6?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'subCategories': ['Playgrounds', 'Activities', 'Education'],
    },
    {
      'id': 'food',
      'name': 'Food & Dining',
      'emoji': '🍽️',
      'icon': LucideIcons.utensils,
      'apiCategories': ['dining', 'nightlife'],
      'tags': ['food', 'dining', 'restaurant', 'cuisine', 'cooking', 'brunch', 'lunch', 'dinner'],
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
      ),
      'bgImage': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'subCategories': ['Restaurants', 'Brunch', 'Dining Experiences'],
    },
    {
      'id': 'entertainment',
      'name': 'Entertainment',
      'emoji': '🎪',
      'icon': LucideIcons.music,
      'apiCategories': ['entertainment', 'music', 'nightlife'],
      'tags': ['entertainment', 'music', 'concert', 'show', 'performance', 'nightlife'],
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
      ),
      'bgImage': 'https://images.unsplash.com/photo-1551632811-561732d1e306?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'subCategories': ['Concerts', 'Live Shows', 'Performances'],
    },
    {
      'id': 'indoor',
      'name': 'Indoor Activities',
      'emoji': '🏢',
      'icon': LucideIcons.building,
      'apiCategories': ['shopping', 'educational', 'workshops'],
      'tags': ['indoor', 'mall', 'shopping', 'workshop', 'class', 'lifestyle', 'wellness', 'spa'],
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
      ),
      'bgImage': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'subCategories': ['Malls', 'Workshops', 'Shopping'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _eventsService = EventsService();
    
    // Start with empty counts - show real data only
    _categoryCounts = {};
    _isLoading = true; // Show loading state until real data arrives
    
    // Load real data in background
    _loadCategoryDataOptimized();
  }

  Future<void> _loadCategoryDataOptimized() async {
    // Check if we have recent cached data (valid for 5 minutes)
    final now = DateTime.now();
    if (_cachedCategoryEvents != null && 
        _cachedCategoryCounts != null && 
        _cacheTimestamp != null &&
        now.difference(_cacheTimestamp!).inMinutes < 5) {
      
      print('📦 Using cached category data');
      if (mounted) {
        setState(() {
          _categoryEvents = Map.from(_cachedCategoryEvents!);
          _categoryCounts = Map.from(_cachedCategoryCounts!);
          _isLoading = false;
        });
      }
      return;
    }

    print('🔄 Loading fresh category data using same logic as category pages...');
    
    try {
      // Fetch all events once for filtering (same as category pages do)
      final response = await _eventsService.getEvents(
        perPage: 200, // Get comprehensive event list
        sortBy: 'start_date',
      );
      
      if (response.isSuccess && response.data != null) {
        final allEvents = response.data!;
        print('📊 Processing ${allEvents.length} events for categories');
        
        final Map<String, List<Event>> categoryEvents = {};
        final Map<String, int> categoryCounts = {};

        // Process all categories using same broad tag-based filtering as category pages
        for (final category in categories) {
          final categoryId = category['id'] as String;
          final apiCategories = category['apiCategories'] as List<String>;
          final tags = category['tags'] as List<String>;
          final categoryName = category['name'] as String;
          
          // Use the exact same filtering logic as EventsListScreenEnhanced
          final filteredEvents = allEvents.where((event) {
            // Check exact category match (case-insensitive)
            final categoryMatch = apiCategories.any((category) => 
              event.category.toLowerCase() == category.toLowerCase()
            );
            
            // Check broad tag-based matching (same as category page)
            final tagMatch = tags.any((tag) =>
              event.tags.any((eventTag) => 
                eventTag.toLowerCase().contains(tag.toLowerCase())
              ) ||
              event.category.toLowerCase().contains(tag.toLowerCase()) ||
              event.title.toLowerCase().contains(tag.toLowerCase()) ||
              event.description.toLowerCase().contains(tag.toLowerCase())
            );
            
            return categoryMatch || tagMatch;
          }).toList();
          
          // Sort by date
          filteredEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
          
          categoryEvents[categoryId] = filteredEvents.take(10).toList(); // Limit to top 10 for preview
          categoryCounts[categoryId] = filteredEvents.length;
          
          print('✅ $categoryName: ${filteredEvents.length} events (matches category page count)');
        }

        // Cache the results
        _cachedCategoryEvents = Map.from(categoryEvents);
        _cachedCategoryCounts = Map.from(categoryCounts);
        _cacheTimestamp = now;

        if (mounted) {
          setState(() {
            _categoryEvents = categoryEvents;
            _categoryCounts = categoryCounts;
            _isLoading = false;
          });
        }
        
        print('✅ Category data loaded and cached');
        print('📊 Final category counts: $categoryCounts');
        // Debug: Show unique categories in the data
        final uniqueCategories = allEvents.map((e) => e.category).toSet().toList();
        print('🏷️ Available categories in data: $uniqueCategories');
      } else {
        print('❌ Failed to load events: ${response.error}');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error loading category data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInSlideUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Explore Categories',
              style: GoogleFonts.comfortaa(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          FadeInSlideUp(
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Discover amazing experiences across Dubai',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Responsive Grid (show immediately with fallback data)
            LayoutBuilder(
              builder: (context, constraints) {
                final isLarge = constraints.maxWidth > 1200;
                final isMedium = constraints.maxWidth > 800;
                final crossAxisCount = isLarge ? 3 : (isMedium ? 2 : 1);
                
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isHovered = _hoveredCategory == category['id'];
                    
                    return FadeInSlideUp(
                      delay: Duration(milliseconds: 400 + (index * 100)),
                      child: _buildCategoryBubble(category, isHovered),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }


  Widget _buildCategoryBubble(Map<String, dynamic> category, bool isHovered) {
    final categoryId = category['id'] as String;
    final eventCount = _categoryCounts[categoryId] ?? 0;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredCategory = category['id']),
      onExit: (_) => setState(() => _hoveredCategory = null),
      child: GestureDetector(
        onTap: () {
          // Navigate to category-specific route
          final categoryId = category['id'] as String;
          String routeName;
          
          switch (categoryId) {
            case 'culture':
              routeName = '/cultural';
              break;
            case 'outdoor':
              routeName = '/outdoor-activities';
              break;
            case 'kids':
              routeName = '/kids-and-family';
              break;
            case 'food':
              routeName = '/food-and-dining';
              break;
            case 'entertainment':
              routeName = '/entertainment'; // Direct mapping to entertainment route
              break;
            case 'indoor':
              routeName = '/indoor-activities';
              break;
            default:
              routeName = '/events';
          }
          
          context.go(routeName);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()
            ..scale(isHovered ? 1.05 : 1.0)
            ..rotateZ(isHovered ? 0.01 : 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isHovered ? 0.3 : 0.15),
                blurRadius: isHovered ? 25 : 15,
                offset: Offset(0, isHovered ? 15 : 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: category['bgImage'] as String,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        gradient: category['gradient'] as LinearGradient,
                      ),
                    ),
                  ),
                ),
                
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (category['gradient'] as LinearGradient).colors.first.withOpacity(0.8),
                          (category['gradient'] as LinearGradient).colors.last.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Content
                if (!isHovered) _buildDefaultContent(category, eventCount, false),
                
                // Hover Preview
                if (isHovered) _buildHoverContent(category, categoryId),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultContent(Map<String, dynamic> category, int eventCount, bool isLoadingReal) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _hoveredCategory == category['id'] ? 0.0 : 1.0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with emoji and count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      category['emoji'] as String,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isLoading ? 'Loading...' : eventCount > 0 ? '$eventCount events' : 'No events',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (_isLoading) ...[
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            // Category Name
            Text(
              category['name'] as String,
              style: GoogleFonts.comfortaa(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Sub-categories
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (category['subCategories'] as List<String>).map((sub) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    sub,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoverContent(Map<String, dynamic> category, String categoryId) {
    final events = _categoryEvents[categoryId] ?? [];
    final previewEvents = events.take(3).toList();
    
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _hoveredCategory == category['id'] ? 1.0 : 0.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0D4F3C).withOpacity(0.92), // Dark Dubai Teal
              const Color(0xFF1A2B47).withOpacity(0.95), // Dark Dubai Navy
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Text(
                  category['emoji'] as String,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category['name'] as String,
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Upcoming Events:',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Real Events Preview
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: previewEvents.isNotEmpty
                      ? previewEvents.map((event) => _buildEventPreviewCard(event)).toList()
                      : [_buildNoEventsMessage()],
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Action Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All Events',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    LucideIcons.arrowRight,
                    size: 14,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventPreviewCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatEventTime(event),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.dubaiGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              event.displayPrice,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.dubaiGold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoEventsMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        'No upcoming events in this category',
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.white.withOpacity(0.7),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _formatEventTime(Event event) {
    final now = DateTime.now();
    final eventDate = event.startDate;
    
    if (eventDate.day == now.day && eventDate.month == now.month) {
      return 'Today ${eventDate.hour}:${eventDate.minute.toString().padLeft(2, '0')}';
    } else if (eventDate.difference(now).inDays < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${weekdays[eventDate.weekday - 1]} ${eventDate.hour}:${eventDate.minute.toString().padLeft(2, '0')}';
    } else {
      return '${eventDate.day}/${eventDate.month} ${eventDate.hour}:${eventDate.minute.toString().padLeft(2, '0')}';
    }
  }
}

// Enhanced EventsListScreen wrapper for category-based filtering
class EventsListScreenEnhanced extends StatefulWidget {
  final Map<String, dynamic> categoryData;

  const EventsListScreenEnhanced({
    super.key,
    required this.categoryData,
  });

  @override
  State<EventsListScreenEnhanced> createState() => _EventsListScreenEnhancedState();
}

class _EventsListScreenEnhancedState extends State<EventsListScreenEnhanced> {
  late final EventsService _eventsService;
  List<Event> _filteredEvents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _eventsService = EventsService();
    _loadCategoryEvents();
  }

  Future<void> _loadCategoryEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiCategories = widget.categoryData['apiCategories'] as List<String>;
      final tags = widget.categoryData['tags'] as List<String>;
      final categoryName = widget.categoryData['name'] as String;

      print('🔍 EventsListScreenEnhanced: Loading events for $categoryName');
      print('🔍 API Categories: $apiCategories');
      print('🔍 Tags: $tags');

      final Set<Event> allEvents = {};

      // Fetch events by each exact API category
      for (final category in apiCategories) {
        try {
          final response = await _eventsService.getEvents(
            category: category,
            perPage: 50,
            sortBy: 'start_date',
          );

          if (response.isSuccess && response.data != null) {
            allEvents.addAll(response.data!);
            print('🔍 Found ${response.data!.length} events for exact category "$category"');
          } else {
            print('🔍 No events found for exact category "$category" - ${response.error}');
          }
        } catch (e) {
          print('❌ Error fetching events for category $category: $e');
        }
      }

      // Also fetch all events and filter by tags and category matching
      try {
        final response = await _eventsService.getEvents(
          perPage: 200,
          sortBy: 'start_date',
        );

        if (response.isSuccess && response.data != null) {
          print('🔍 Fetched ${response.data!.length} total events for filtering');
          
          final filteredEvents = response.data!.where((event) {
            // Check category match (case-insensitive)
            final categoryMatch = apiCategories.any((category) => 
              event.category.toLowerCase() == category.toLowerCase()
            );
            
            // Check tag match (case-insensitive partial matching)
            final tagMatch = tags.any((tag) =>
              event.tags.any((eventTag) => 
                eventTag.toLowerCase().contains(tag.toLowerCase())
              ) ||
              event.category.toLowerCase().contains(tag.toLowerCase()) ||
              event.title.toLowerCase().contains(tag.toLowerCase()) ||
              event.description.toLowerCase().contains(tag.toLowerCase())
            );
            
            return categoryMatch || tagMatch;
          });
          
          allEvents.addAll(filteredEvents);
          print('🔍 Added ${filteredEvents.length} events through filtering (category + tag matching)');
        }
      } catch (e) {
        print('❌ Error fetching events for filtering: $e');
      }

      // Filter for upcoming events and sort
      final upcomingEvents = allEvents
          .toList(); // Temporarily removed .where((event) => event.isUpcoming) to show all events
          
      upcomingEvents.sort((a, b) => a.startDate.compareTo(b.startDate));

      print('🔍 Final result: ${upcomingEvents.length} events for $categoryName (showing all events for testing)');
      if (upcomingEvents.isNotEmpty) {
        print('🔍 Sample events: ${upcomingEvents.take(3).map((e) => "${e.title} (${e.category})").join(", ")}');
      } else {
        print('🔍 No events found - this might be due to filtering issues');
      }

      setState(() {
        _filteredEvents = upcomingEvents;
        _isLoading = false;
      });

    } catch (e) {
      print('❌ Error in _loadCategoryEvents: $e');
      setState(() {
        _errorMessage = 'Failed to load events: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = widget.categoryData['name'] as String;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [
                  Color(0xFF0D7377), // Dark teal
                  Color(0xFF14A085), // Medium teal
                  Color(0xFF329D9C), // Light teal
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
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                // Back button
                Material(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                ),
                
                SizedBox(width: 16),
                
                // Title
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: GoogleFonts.comfortaa(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _isLoading 
                          ? 'Loading events...' 
                          : '${_filteredEvents.length} events found',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                
                Spacer(),
                
                // Refresh button
                Material(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _loadCategoryEvents,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.refresh, color: Colors.white.withOpacity(0.9)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.dubaiTeal,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            SizedBox(height: 16),
            Text(
              'Error Loading Events',
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCategoryEvents,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No Events Found',
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No upcoming events in this category.\nCheck back later for new events!',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Grid view of events
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 
                       MediaQuery.of(context).size.width > 800 ? 2 : 1,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: event.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  color: AppColors.surfaceVariant,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surfaceVariant,
                  child: Center(
                    child: Icon(Icons.image_not_supported, 
                               color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.dubaiTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dubaiTeal,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Title
                  Text(
                    event.title,
                    style: GoogleFonts.comfortaa(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 4),
                  
                  // Location and date
                  Text(
                    '${event.venue.area} • ${_formatDate(event.startDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  Spacer(),
                  
                  // Price
                  Text(
                    event.displayPrice,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dubaiGold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}';
    }
  }
} 