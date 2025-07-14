import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/curved_container.dart';
import '../../core/widgets/bubble_decoration.dart';
import '../../core/widgets/glass_morphism.dart';

import '../../core/widgets/dubai_app_bar.dart';
import '../../widgets/notifications/notification_bell.dart';
import '../../providers/search_provider.dart';
import '../../models/search.dart';
import '../../widgets/home/home_search_widget.dart';
import '../../widgets/home/home_search_widget_simple.dart';
import '../../services/providers/auth_provider_mongodb.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/events/events_list_screen_simple.dart';
import '../../models/event.dart';
import '../../models/event_stats.dart';
import '../../services/events_service.dart';
import '../../widgets/home/hero_section.dart';
import '../../widgets/home/quick_stats.dart';
import '../../widgets/home/featured_events_section.dart';
import '../../widgets/home/categories_grid.dart';
import '../../widgets/home/trending_events_carousel.dart';
import '../../widgets/home/search_bar_section.dart';
import '../../widgets/home/testimonials_section.dart';
import '../../widgets/home/newsletter_signup.dart';
import '../../widgets/home/footer_section.dart';
import '../../widgets/common/search_bar_glassmorphic.dart';
import '../../widgets/common/bubble_decoration.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/curved_container.dart';
import '../../widgets/common/pulsing_button.dart';
import '../../widgets/featured_events_section.dart';
import '../../widgets/home/interactive_category_explorer.dart';
import '../../widgets/home/weekend_highlights.dart';
import '../../widgets/home/smart_trending_section.dart';
import '../../widgets/common/footer.dart';
import '../../widgets/common/ad_placeholder.dart';
import '../../widgets/search/super_search_button.dart';

// Add animation imports for gradual integration
import '../../core/animations/animations.dart';

/// The beautiful home screen for DXB Events - family-friendly Dubai events discovery
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _heroAnimationController;
  late AnimationController _searchController;
  bool _showFloatingSearch = false;
  bool _isLoading = true; // Add loading state for shimmer
  
  // Real API data
  late final EventsService _eventsService;
  List<Event> _featuredEvents = [];
  List<Event> _trendingEvents = [];
  List<Event> _allEventsForCounting = []; // For accurate category counting
  String? _errorMessage;
  
  // Event stats for quick display
  int _totalEventsCount = 0;
  int _totalVenuesCount = 0;

  @override
  void initState() {
    super.initState();
    _eventsService = EventsService();
    _scrollController = ScrollController();
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scrollController.addListener(_scrollListener);
    
    // Start animations once on init
    _heroAnimationController.forward();
    
    // Delay search animation
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _searchController.forward();
      }
    });

    // Load real data once
    _loadEvents();
  }
  
  Timer? _scrollDebounceTimer;
  
  void _scrollListener() {
    _scrollDebounceTimer?.cancel();
    _scrollDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        final shouldShowFloatingSearch = _scrollController.offset > 200;
        if (shouldShowFloatingSearch != _showFloatingSearch) {
          setState(() {
            _showFloatingSearch = shouldShowFloatingSearch;
          });
        }
      }
    });
  }

  Future<void> _loadEvents() async {
    try {
      // Load total events count for stats
      final totalCountResponse = await _eventsService.getTotalEventsCount();
      
      // Load featured events (reduced for homepage display)
      final featuredResponse = await _eventsService.getEvents(
        perPage: 10,
        sortBy: 'start_date',
      );

      // Load ALL events for accurate category counting - increased to get all events
      final allEventsResponse = await _eventsService.getEvents(
        perPage: 100, // Increased to get all events in database (currently ~62)
        sortBy: 'start_date',
      );

      // Load trending events (prefer firecrawl for quality)
      final trendingResponse = await _eventsService.getTrendingEvents(
        limit: 10,
        firecrawlOnly: true, // Use high-quality firecrawl events
      );

      if (mounted) {
        setState(() {
          if (totalCountResponse.isSuccess) {
            _totalEventsCount = totalCountResponse.data ?? 0;
            // Estimate venues count (roughly 1 venue per 4 events)
            _totalVenuesCount = (_totalEventsCount / 4).ceil();
          }
          if (featuredResponse.isSuccess) {
            _featuredEvents = featuredResponse.data ?? [];
          }
          if (allEventsResponse.isSuccess) {
            _allEventsForCounting = allEventsResponse.data ?? [];
            print('🔍 DEBUG: Loaded ${_allEventsForCounting.length} events for category counting');
            // Debug: Show sample tags
            if (_allEventsForCounting.isNotEmpty) {
              print('🔍 DEBUG: Sample event tags: ${_allEventsForCounting.first.tags}');
            }
          }
          if (trendingResponse.isSuccess) {
            _trendingEvents = trendingResponse.data ?? [];
          }
          _isLoading = false;
          _errorMessage = featuredResponse.error ?? trendingResponse.error ?? allEventsResponse.error ?? totalCountResponse.error;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load events: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollDebounceTimer?.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _heroAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Format event count for display (150+ format)
  String _formatEventCount(int count) {
    if (count == 0) return '0';
    if (count >= 1000) {
      final k = count / 1000;
      return '${k.toStringAsFixed(k == k.roundToDouble() ? 0 : 1)}k+';
    } else if (count >= 100) {
      final hundreds = (count / 100).floor() * 100;
      return '${hundreds}+';
    } else if (count >= 50) {
      return '50+';
    } else {
      return count.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main content with optimized scrolling
          CustomScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(), // Better for web
            cacheExtent: 100, // Reduce off-screen rendering
            slivers: [
              // Top App Bar
              _buildTopAppBar(),
              
              // Beautiful hero section - optimized
              _buildHeroSection(),
              
              // MyDscvr Super Search Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: const SuperSearchButton(),
                ),
              ),
              
              // Quick filters
              SliverToBoxAdapter(
                child: _buildQuickFilters(),
              ),
              
              // Featured events
              SliverToBoxAdapter(
                child: _buildFeaturedEvents(),
              ),
              
              // Ad Placeholder 1 - Between Featured Events and Categories
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Column(
                    children: [
                      // Header text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          border: Border.all(color: const Color(0xFFDDDDDD)),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                        child: Text(
                          'This is an Ad. Please scroll to proceed with content',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF666666),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      
                      // Ad container
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: const Color(0xFFDDDDDD)),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.ad_units,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Advertisement Space',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Text(
                                  'Google AdSense - Slot: 2625901948',
                                  style: GoogleFonts.mono(
                                    fontSize: 10,
                                    color: Colors.blue[700],
                                  ),
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
              
              // Popular categories
              SliverToBoxAdapter(
                child: _buildPopularCategories(),
              ),
              
              // Weekend highlights
              SliverToBoxAdapter(
                child: _buildWeekendHighlights(),
              ),
              
              // Ad Placeholder 2 - Between Weekend Highlights and Trending
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          border: Border.all(color: const Color(0xFFDDDDDD)),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                        child: Text(
                          'This is an Ad. Please scroll to proceed with content',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF666666),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          border: Border.all(color: const Color(0xFFDDDDDD)),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                        ),
                        child: Center(
                          child: Text(
                            'AD SPACE 2',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Trending events
              SliverToBoxAdapter(
                child: _buildTrendingEvents(),
              ),
              
              // MyDscvr's Choice banner
              SliverToBoxAdapter(
                child: _buildMyDscvrChoice(),
              ),
              
              // Ad Placeholder 3 - After MyDscvr's Choice
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          border: Border.all(color: const Color(0xFFDDDDDD)),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                        child: Text(
                          'This is an Ad. Please scroll to proceed with content',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF666666),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          border: Border.all(color: const Color(0xFFDDDDDD)),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                        ),
                        child: Center(
                          child: Text(
                            'AD SPACE 3',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // TEST: Add multiple test sections to debug rendering
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Test 1: Simple colored container
                    Container(
                      height: 80,
                      margin: const EdgeInsets.all(24),
                      color: Colors.green,
                      child: const Center(
                        child: Text(
                          'TEST 1: If you see this GREEN box, rendering works!',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    
                    // Test 2: Basic button
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: ElevatedButton(
                        onPressed: () {
                          print('🎉 Test button clicked!');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Basic button works!'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.all(20),
                        ),
                        child: const Text(
                          'TEST 2: Click me to test basic buttons',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Explore All Events CTA
              SliverToBoxAdapter(
                child: _buildExploreAllEventsButton(),
              ),
              
              // Ad Placeholder 4 - Before Footer
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          border: Border.all(color: const Color(0xFFDDDDDD)),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                        child: Text(
                          'This is an Ad. Please scroll to proceed with content',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF666666),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          border: Border.all(color: const Color(0xFFDDDDDD)),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                        ),
                        child: Center(
                          child: Text(
                            'AD SPACE 4',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[700],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Footer
              SliverToBoxAdapter(
                child: _buildFooter(),
              ),
            ],
          ),
          
          // Floating search (appears on scroll)
          if (_showFloatingSearch) 
            FadeInSlideUp(
              duration: const Duration(milliseconds: 200),
              child: _buildFloatingSearch(),
            ),
        ],
      ),
    );
  }

  /// Top app bar with authentication controls
  Widget _buildTopAppBar() {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    final user = authState.user;
    


    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      floating: true,
      expandedHeight: 80,
      toolbarHeight: 80,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [
              Color(0xFF0D7377),
              Color(0xFF14A085),
              Color(0xFF329D9C),
            ],
          ),
        ),
      ),
      title: GestureDetector(
        onTap: () => context.go('/'),
        child: Row(
          children: [
            Image.asset(
              'assets/images/mydscvr-logo.png',
              height: 40,
              width: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Debug print to help identify the issue
                print('🔍 DEBUG: Logo failed to load: $error');
                print('🔍 DEBUG: StackTrace: $stackTrace');
                // Fallback to a text-based logo
                return Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'M',
                      style: GoogleFonts.comfortaa(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dubaiTeal,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Text(
              'MyDscvr',
              style: GoogleFonts.comfortaa(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (isAuthenticated) ...[
          // User is logged in - show profile and notifications
          const NotificationBell(
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 16),
          
          // Profile dropdown
          PopupMenuButton<String>(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.dubaiGold,
                  child: user?.avatar != null
                      ? ClipOval(
                          child: Image.network(
                            user!.avatar!,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Text(
                          user?.firstName?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  LucideIcons.chevronDown,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: const Row(
                  children: [
                    Icon(LucideIcons.user, size: 16),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'favorites',
                child: const Row(
                  children: [
                    Icon(LucideIcons.heart, size: 16),
                    SizedBox(width: 8),
                    Text('Favorites'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: const Row(
                  children: [
                    Icon(LucideIcons.settings, size: 16),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: const Row(
                  children: [
                    Icon(LucideIcons.logOut, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _handleProfileMenuAction(value),
          ),
        ] else ...[
          // User is not logged in - show login/signup buttons
          TextButton(
            onPressed: () => _navigateToLogin(),
            child: Text(
              'Login',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Enhanced signup button with pulse animation
          PulsingButton(
            onPressed: () => _navigateToSignUp(),
            pulseColor: AppColors.dubaiGold,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.dubaiGold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Sign Up',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(width: 16),
      ],
    );
  }

  /// Handle profile menu actions
  void _handleProfileMenuAction(String action) {
    switch (action) {
      case 'profile':
        // TODO: Navigate to profile screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile screen - coming soon!')),
        );
        break;
      case 'favorites':
        // TODO: Navigate to favorites screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Favorites screen - coming soon!')),
        );
        break;
      case 'settings':
        // TODO: Navigate to settings screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings screen - coming soon!')),
        );
        break;
      case 'logout':
        ref.read(authProvider.notifier).logout();
        break;
    }
  }

  /// Navigate to login screen
  void _navigateToLogin() {
    context.go('/login');
  }

  /// Navigate to sign up screen  
  void _navigateToSignUp() {
    context.go('/register');
  }

  /// Navigate to category page based on tag
  void _navigateToCategory(String tag) {
    switch (tag) {
      case 'kids':
      case 'family':
        context.go('/kids-and-family');
        break;
      case 'music':
        context.go('/music-and-concerts');
        break;
      case 'arts':
      case 'cultural':
        context.go('/cultural');
        break;
      case 'gaming':
      case 'indoor':
        context.go('/indoor-activities');
        break;
      case 'food':
        context.go('/food-and-dining');
        break;
      case 'beach':
      case 'outdoor':
        context.go('/outdoor-activities');
        break;
      default:
        context.go('/events');
        break;
    }
  }

  Widget _buildHeroSection() {
    return SliverToBoxAdapter(
      child: CurvedContainer(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B6B), // Coral
            Color(0xFFFFB347), // Orange
            Color(0xFFFF8E53), // Warm orange
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        curveHeight: 50,
        curvePosition: CurvePosition.bottom,
        height: 520,
        child: Stack(
          children: [
            // Enhanced animated background orbs
            AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                final parallaxOffset = scrollOffset * 0.5;
                
                return Stack(
                  children: [
                    // Large floating orb
                    Positioned(
                      left: 80 - parallaxOffset * 0.3,
                      top: 120 - parallaxOffset * 0.2,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                    
                    // Medium orb
                    Positioned(
                      right: 60 - parallaxOffset * 0.2,
                      top: 200 - parallaxOffset * 0.1,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFFD93D).withOpacity(0.3),
                              const Color(0xFFFFB347).withOpacity(0.2),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                    
                    // Small accent orbs
                    Positioned(
                      left: 200 - parallaxOffset * 0.4,
                      top: 80 - parallaxOffset * 0.3,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                    ),
                    
                    Positioned(
                      right: 150 - parallaxOffset * 0.2,
                      top: 320 - parallaxOffset * 0.1,
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            
            // Hero content with enhanced animations
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row with notification bell
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Spacer(),
                        // Notification Bell with enhanced styling
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: NotificationBell(
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ).animate(
                          onPlay: (controller) => controller.forward(),
                        ).fadeIn(
                          duration: kIsWeb ? 100.ms : 800.ms,
                          delay: kIsWeb ? Duration.zero : 400.ms,
                        ).slideX(
                          begin: 0.5,
                          end: 0,
                          duration: kIsWeb ? 100.ms : 600.ms,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Enhanced main heading with staggered animation
                    Text(
                      'Discover Dubai\'s',
                      style: GoogleFonts.comfortaa(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ],
                      ),
                    ).animate(
                      onPlay: (controller) => controller.forward(),
                    ).fadeIn(
                      duration: kIsWeb ? 100.ms : 800.ms,
                      delay: kIsWeb ? Duration.zero : 200.ms,
                    ).slideY(
                      begin: 0.3,
                      end: 0,
                      duration: kIsWeb ? 100.ms : 800.ms,
                      curve: Curves.easeOutExpo,
                    ),
                    
                    Text(
                      'best adventures',
                      style: GoogleFonts.comfortaa(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ],
                      ),
                    ).animate(
                      onPlay: (controller) => controller.forward(),
                    ).fadeIn(
                      duration: kIsWeb ? 100.ms : 800.ms,
                      delay: kIsWeb ? Duration.zero : 400.ms,
                    ).slideY(
                      begin: 0.3,
                      end: 0,
                      duration: kIsWeb ? 100.ms : 800.ms,
                      curve: Curves.easeOutExpo,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Enhanced subtitle
                    Text(
                      'From family fun to cultural experiences,\nfind your perfect Dubai moment',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.95),
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate(
                      onPlay: (controller) => controller.forward(),
                    ).fadeIn(
                      duration: kIsWeb ? 100.ms : 600.ms,
                      delay: kIsWeb ? Duration.zero : 600.ms,
                    ).slideY(
                      begin: 0.2,
                      end: 0,
                      duration: kIsWeb ? 100.ms : 600.ms,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Enhanced search bar with glassmorphism
                    Container(
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const SimpleHomeSearchWidget(),
                        ),
                      ),
                    ).animate(
                      onPlay: (controller) => controller.forward(),
                    ).fadeIn(
                      duration: kIsWeb ? 100.ms : 700.ms,
                      delay: kIsWeb ? Duration.zero : 800.ms,
                    ).slideY(
                      begin: 0.2,
                      end: 0,
                      duration: kIsWeb ? 100.ms : 700.ms,
                    ).scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.0, 1.0),
                      duration: kIsWeb ? 100.ms : 700.ms,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Enhanced glassmorphic stat cards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildEnhancedStatCard(LucideIcons.calendar, _formatEventCount(_totalEventsCount), 'Events', 0),
                        _buildEnhancedStatCard(LucideIcons.mapPin, _formatEventCount(_totalVenuesCount), 'Venues', 200),
                        _buildEnhancedStatCard(LucideIcons.heart, '5k+', 'Families', 400),
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

  Widget _buildEnhancedStatCard(IconData icon, String number, String label, int delayMs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            number,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate(
      onPlay: (controller) => controller.forward(),
    ).fadeIn(
      duration: kIsWeb ? 100.ms : 600.ms,
      delay: kIsWeb ? Duration.zero : Duration(milliseconds: 1000 + delayMs),
    ).slideY(
      begin: 0.3,
      end: 0,
      duration: kIsWeb ? 100.ms : 600.ms,
    ).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      duration: kIsWeb ? 100.ms : 600.ms,
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildQuickFilters() {
    final filters = [
      {'icon': LucideIcons.baby, 'label': 'Kids', 'tag': 'kids', 'color': AppColors.dubaiCoral},
      {'icon': LucideIcons.music, 'label': 'Music', 'tag': 'music', 'color': AppColors.dubaiPurple},
      {'icon': LucideIcons.palette, 'label': 'Arts', 'tag': 'arts', 'color': AppColors.dubaiGold},
      {'icon': LucideIcons.gamepad2, 'label': 'Games', 'tag': 'gaming', 'color': AppColors.dubaiTeal},
      {'icon': LucideIcons.utensils, 'label': 'Food', 'tag': 'food', 'color': AppColors.dubaiCoral},
    ];

    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
        final quickFiltersOffset = scrollOffset > 400 ? (scrollOffset - 400) * 0.3 : 0.0;
        
        return Transform.translate(
          offset: Offset(0, -quickFiltersOffset),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced animated section header with scroll response
                Transform.scale(
                  scale: scrollOffset > 400 ? 1.0 + ((scrollOffset - 400) * 0.0002).clamp(0.0, 0.1) : 1.0,
                  child: Text(
                    'Quick Filters',
                    style: GoogleFonts.comfortaa(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ).animate(
                    onPlay: (controller) => controller.forward(),
                  ).fadeIn(
                    duration: kIsWeb ? 100.ms : 800.ms,
                    delay: kIsWeb ? Duration.zero : 300.ms,
                  ).slideY(
                    begin: 0.3,
                    end: 0,
                    duration: kIsWeb ? 100.ms : 800.ms,
                    curve: Curves.easeOutExpo,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Enhanced filter list with scroll animations
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    itemCount: filters.length,
                    itemBuilder: (context, index) {
                      final filter = filters[index];
                      
                      // Calculate individual animation offset based on scroll
                      final itemScrollOffset = scrollOffset > 500 
                          ? (scrollOffset - 500 - (index * 50)) * 0.1 
                          : 0.0;
                      
                      return Transform.translate(
                        offset: Offset(itemScrollOffset.clamp(-20.0, 20.0), 0),
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  (filter['color'] as Color),
                                  (filter['color'] as Color).withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: (filter['color'] as Color).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  final tag = filter['tag'] as String;
                                  _navigateToCategory(tag);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          filter['icon'] as IconData,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        filter['label'] as String,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ).animate(
                            onPlay: (controller) => controller.forward(),
                          ).fadeIn(
                            duration: kIsWeb ? 100.ms : 600.ms,
                            delay: kIsWeb ? Duration.zero : Duration(milliseconds: 400 + (index * 100)),
                          ).slideY(
                            begin: 0.5,
                            end: 0,
                            duration: kIsWeb ? 100.ms : 600.ms,
                            curve: Curves.easeOutBack,
                          ).scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.0, 1.0),
                            duration: kIsWeb ? 100.ms : 600.ms,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedEvents() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInSlideUp(
            delay: const Duration(milliseconds: 600),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured Events',
                  style: GoogleFonts.comfortaa(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.go('/events');
                  },
                  child: Text(
                    'See All',
                    style: GoogleFonts.inter(
                      color: AppColors.dubaiTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // DEBUG: Test button for click functionality
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: () {
                print('DEBUG: Test button clicked successfully!');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Test button clicked! Basic functionality works.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dubaiTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: Text(
                'DEBUG: Test Click Functionality',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          SizedBox(
            height: 240, // Reduced from 280 to match smaller cards
            child: _isLoading
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 250,
                        margin: const EdgeInsets.only(right: 16),
                        child: const ShimmerEventCard(),
                      );
                    },
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    itemCount: _featuredEvents.length,
                    itemBuilder: (context, index) {
                      final event = _featuredEvents[index];
                      return Container(
                        width: 250,
                        margin: const EdgeInsets.only(right: 16),
                        child: _buildOptimizedEventCard(event, index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizedEventCard(Event event, int index) {
    // Simplified version without animations for testing
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          print('🔥 DEBUG: Event card InkWell.onTap triggered');
          print('🔥 DEBUG: Event title: ${event.title}');
          print('🔥 DEBUG: Event ID: ${event.id}');
          print('🔥 DEBUG: Navigator context available: ${Navigator.of(context) != null}');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎯 Event Card Clicked: ${event.title}'),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 3),
            ),
          );
          
          try {
            context.go('/event/${event.id}');
            print('🔥 DEBUG: Navigation successful');
          } catch (e) {
            print('🔥 DEBUG: Navigation error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Navigation error: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image - reduced height
            Container(
              height: 120, // Reduced from 150
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                color: AppColors.dubaiTeal.withOpacity(0.3),
              ),
              child: Stack(
                children: [
                  // Simple colored background instead of image for now
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.dubaiTeal.withOpacity(0.8),
                          AppColors.dubaiTeal,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        LucideIcons.calendar,
                        size: 32, // Reduced from 40
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                  
                  // Event badges
                  if (event.isFeatured)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.dubaiGold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Featured',
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
            
            // Event details - more compact
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10), // Reduced from 12
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: GoogleFonts.comfortaa(
                        fontSize: 15, // Reduced from 16
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4), // Reduced from 6
                    Row(
                      children: [
                        Icon(
                          LucideIcons.mapPin,
                          size: 12, // Reduced from 14
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.venue.area,
                            style: GoogleFonts.inter(
                              fontSize: 11, // Reduced from 12
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4), // Reduced from 6
                    
                    // Description text - NEW: Add description to fill space
                    Expanded(
                      child: Text(
                        _getDisplayDescription(event),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 3, // Increased from 2 to 3 lines
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: 4), // Reduced from 8
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          event.displayPrice,
                          style: GoogleFonts.comfortaa(
                            fontSize: 13, // Reduced from 14
                            fontWeight: FontWeight.bold,
                            color: event.isFree ? AppColors.dubaiTeal : AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.star,
                              size: 11, // Reduced from 12
                              color: AppColors.dubaiGold,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              event.rating.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                fontSize: 10, // Reduced from 11
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
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

  // Helper method to get description text for homepage cards
  String _getDisplayDescription(Event event) {
    // Priority order: shortDescription -> aiSummary -> description (truncated) -> fallback
    
    if (event.shortDescription != null && event.shortDescription!.isNotEmpty) {
      return event.shortDescription!;
    }
    
    if (event.aiSummary != null && event.aiSummary!.isNotEmpty) {
      return event.aiSummary!;
    }
    
    if (event.description.isNotEmpty) {
      // Increased max length to utilize the 3 lines better
      const maxLength = 120; // Increased from 80 for homepage
      if (event.description.length <= maxLength) {
        return event.description;
      }
      return '${event.description.substring(0, maxLength)}...';
    }
    
    // Fallback: generate description from available data
    return _generateFallbackDescription(event);
  }

  String _generateFallbackDescription(Event event) {
    // Generate description based on category and venue
    final category = event.category.toLowerCase();
    final area = event.venue.area;
    
    if (category.contains('cultural')) {
      return 'Discover rich cultural heritage with interactive experiences in $area.';
    } else if (category.contains('outdoor') || category.contains('adventure')) {
      return 'Enjoy outdoor adventures and exciting activities in $area.';
    } else if (category.contains('arts') || category.contains('craft')) {
      return 'Explore creativity through hands-on activities in $area.';
    } else if (category.contains('entertainment') || category.contains('show')) {
      return 'Experience world-class entertainment in the heart of $area.';
    } else {
      return 'Join us for an unforgettable family experience in $area.';
    }
  }

  Widget _buildPopularCategories() {
    // Enhanced categories that match our new AI tagging system
    // Use _allEventsForCounting for accurate counts instead of just _featuredEvents
    final eventsForCounting = _allEventsForCounting.isNotEmpty ? _allEventsForCounting : _featuredEvents;
    
    // IMPROVED: Better family event detection with more comprehensive matching
    final familyCount = eventsForCounting.where((e) => 
      e.tags.any((tag) {
        final tagLower = tag.toLowerCase();
        return tagLower.contains('family') || 
               tagLower.contains('kids') || 
               tagLower.contains('children') ||
               tagLower.contains('all_ages') ||
               tagLower.contains('all-ages') ||
               tag == 'Family-friendly' ||  // Exact match for hyphenated version
               tag == 'Family-Friendly';    // Exact match for title case version
      })
    ).length;
    
    // NEW: Indoor activities detection using tags AND venue information
    final indoorCount = eventsForCounting.where((e) {
      // Check tags for indoor keywords
      final hasIndoorTags = e.tags.any((tag) {
        final tagLower = tag.toLowerCase();
        return tagLower.contains('indoor') ||
               tagLower.contains('theatre') ||
               tagLower.contains('theater') ||
               tagLower.contains('museum') ||
               tagLower.contains('gallery') ||
               tagLower.contains('shopping') ||
               tagLower.contains('mall') ||
               tagLower.contains('cinema') ||
               tagLower.contains('arts'); // Arts events are often indoor
      });
      
      // Check venue name for indoor locations
      final venueName = e.venue.name.toLowerCase();
      final hasIndoorVenue = venueName.contains('mall') ||
                           venueName.contains('opera') ||
                           venueName.contains('centre') ||
                           venueName.contains('center') ||
                           venueName.contains('hall') ||
                           venueName.contains('theatre') ||
                           venueName.contains('theater') ||
                           venueName.contains('museum') ||
                           venueName.contains('gallery');
      
      return hasIndoorTags || hasIndoorVenue;
    }).length;
    
    // Debug: Check what events we're using for counting
    print('🔍 DEBUG: Using ${eventsForCounting.length} events for category counting (_allEventsForCounting: ${_allEventsForCounting.length}, _featuredEvents: ${_featuredEvents.length})');
    
    final beachCount = eventsForCounting.where((e) => 
      e.tags.any((tag) => tag.toLowerCase().contains('beach') || 
                           tag.toLowerCase().contains('water') || 
                           tag.toLowerCase().contains('outdoor'))
    ).length;
    
    final culturalCount = eventsForCounting.where((e) => 
      e.tags.any((tag) => tag.toLowerCase().contains('cultural') || 
                           tag.toLowerCase().contains('arts') || 
                           tag.toLowerCase().contains('theatre') ||
                           tag.toLowerCase().contains('traditional') ||
                           tag.toLowerCase().contains('heritage') ||
                           tag.toLowerCase().contains('festival'))
    ).length;
    
    // Enhanced debugging: Show sample tags from each category
    final familyEvents = eventsForCounting.where((e) => 
      e.tags.any((tag) {
        final tagLower = tag.toLowerCase();
        return tagLower.contains('family') || 
               tagLower.contains('kids') || 
               tagLower.contains('children') ||
               tagLower.contains('all_ages') ||
               tagLower.contains('all-ages') ||
               tag == 'Family-friendly' ||
               tag == 'Family-Friendly';
      })
    ).toList();
    
    print('🔍 DEBUG: Category counts - Family: $familyCount, Indoor: $indoorCount, Beach: $beachCount, Cultural: $culturalCount');
    if (familyEvents.isNotEmpty) {
      print('🔍 DEBUG: Sample family event tags: ${familyEvents.first.tags}');
      print('🔍 DEBUG: Sample family event title: ${familyEvents.first.title}');
    }
    
    final categories = [
      {'name': 'Family Fun', 'tag': 'family', 'count': '$familyCount events', 'gradient': AppColors.sunsetGradient},
      {'name': 'Indoor Activities', 'tag': 'indoor', 'count': '$indoorCount events', 'gradient': AppColors.royalGradient},
      {'name': 'Beach Activities', 'tag': 'beach', 'count': '$beachCount events', 'gradient': AppColors.oceanGradient},
      {'name': 'Cultural', 'tag': 'cultural', 'count': '$culturalCount events', 'gradient': AppColors.forestGradient},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInSlideUp(
            delay: const Duration(milliseconds: 800),
            child: Text(
              'Popular Categories',
              style: GoogleFonts.comfortaa(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GlassCard(
                padding: const EdgeInsets.all(20),
                blur: kIsWeb ? 2 : 6,
                opacity: 0.05,
                child: InkWell(
                  onTap: () {
                    final tag = category['tag'] as String;
                    _navigateToCategory(tag);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: category['gradient'] as LinearGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category['name'] as String,
                          style: GoogleFonts.comfortaa(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          category['count'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekendHighlights() {
    return const WeekendHighlights();
  }

  Widget _buildTrendingEvents() {
    // Use the new Smart Trending Section widget
    return const SmartTrendingSection();
  }

  Widget _buildMyDscvrChoice() {
    print('🎯 DEBUG: Building GameShow Winner Banner');
    
    // For now, use a featured event as placeholder until we implement daily choice API
    final placeholderEvent = _featuredEvents.isNotEmpty ? _featuredEvents.first : null;
    
    if (placeholderEvent == null) {
      return _buildMyDscvrChoiceLoading();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth <= 600;
        final isTablet = screenWidth > 600 && screenWidth <= 900;
        
        // Responsive dimensions
        final horizontalMargin = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
        final verticalMargin = isMobile ? 16.0 : 24.0;
        final borderRadius = isMobile ? 20.0 : 25.0;
        final contentPadding = isMobile ? 20.0 : 30.0;
        
        // Responsive heights
        final containerHeight = isMobile ? null : (isTablet ? 280.0 : 320.0);
        
        return TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 3),
          tween: Tween(begin: 1.0, end: 1.02),
          curve: Curves.easeInOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: horizontalMargin,
                  vertical: verticalMargin,
                ),
                height: containerHeight,
                constraints: isMobile ? const BoxConstraints(minHeight: 240) : null,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667eea), // Purple
                      Color(0xFF764ba2), // Blue
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.4),
                      blurRadius: isMobile ? 15 : 25,
                      offset: Offset(0, isMobile ? 8 : 12),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Animated confetti background
                    ...List.generate(15, (index) => _buildConfetti(index, isMobile)),
                    
                    // Diagonal shine effect
                    Positioned.fill(
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(seconds: 4),
                        tween: Tween(begin: -1.0, end: 1.0),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(borderRadius),
                              gradient: LinearGradient(
                                begin: Alignment(-1.0 + value, -1.0),
                                end: Alignment(1.0 + value, 1.0),
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Main content - gameshow layout
                    Padding(
                      padding: EdgeInsets.all(contentPadding),
                      child: Row(
                        children: [
                          // Trophy Section
                          _buildTrophySection(isMobile),
                          
                          SizedBox(width: isMobile ? 16 : 24),
                          
                          // Text Content Area
                          Expanded(
                            child: _buildGameshowContent(placeholderEvent, isMobile),
                          ),
                          
                          // Celebration Elements
                          if (!isMobile) _buildCelebrationElements(),
                        ],
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  // Mobile-optimized vertical layout
  Widget _buildMobileLayout(Event placeholderEvent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MyDscvr\'s Choice',
              style: GoogleFonts.comfortaa(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 6),
            
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.dubaiGold.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dubaiGold.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.zap,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'AI Curated Daily',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Event content - mobile row layout with smaller image
        Expanded(
          child: Row(
            children: [
              // Compact event image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.calendar,
                  color: Colors.white.withOpacity(0.8),
                  size: 28,
                ),
              ).animate().scale(delay: 600.ms),
              
              const SizedBox(width: 12),
              
              // Event details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      placeholderEvent.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ).animate().fadeIn(delay: 700.ms),
                    
                    const SizedBox(height: 6),
                    
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatEventTime(placeholderEvent.startDate),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Row(
                      children: [
                        Icon(
                          LucideIcons.mapPin,
                          size: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            placeholderEvent.venue.area,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Desktop/tablet layout (existing row layout with responsive adjustments)
  Widget _buildDesktopLayout(Event placeholderEvent, bool isTablet) {
    final imageSize = isTablet ? 100.0 : 120.0;
    final titleFontSize = isTablet ? 16.0 : 18.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with algorithm badge
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MyDscvr\'s Choice',
              style: GoogleFonts.comfortaa(
                fontSize: isTablet ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 8),
            
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.dubaiGold.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dubaiGold.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.zap,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'AI Curated Daily',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
        
        const SizedBox(height: isTablet ? 16 : 24),
        
        // Event content
        Expanded(
          child: Row(
            children: [
              // Event image placeholder
              Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.calendar,
                  color: Colors.white.withOpacity(0.8),
                  size: isTablet ? 32 : 40,
                ),
              ).animate().scale(delay: 600.ms),
              
              SizedBox(width: isTablet ? 16 : 20),
              
              // Event details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      placeholderEvent.title,
                      style: GoogleFonts.inter(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ).animate().fadeIn(delay: 700.ms),
                    
                    SizedBox(height: isTablet ? 8 : 12),
                    
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: isTablet ? 14 : 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        SizedBox(width: isTablet ? 6 : 8),
                        Expanded(
                          child: Text(
                            _formatEventTime(placeholderEvent.startDate),
                            style: GoogleFonts.inter(
                              fontSize: isTablet ? 12 : 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: isTablet ? 4 : 8),
                    
                    Row(
                      children: [
                        Icon(
                          LucideIcons.mapPin,
                          size: isTablet ? 14 : 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        SizedBox(width: isTablet ? 6 : 8),
                        Expanded(
                          child: Text(
                            placeholderEvent.venue.area,
                            style: GoogleFonts.inter(
                              fontSize: isTablet ? 12 : 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    if (!isTablet) ...[
                      const SizedBox(height: 16),
                      
                      // Action row
                      Row(
                        children: [
                          Text(
                            'Perfect for families',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.dubaiGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            LucideIcons.sparkles,
                            size: 14,
                            color: AppColors.dubaiGold,
                          ),
                        ],
                      ).animate().fadeIn(delay: 900.ms),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Confetti Animation Widget
  Widget _buildConfetti(int index, bool isMobile) {
    final colors = [
      const Color(0xFFff6b6b), // Red
      const Color(0xFF4ecdc4), // Teal
      const Color(0xFFffd700), // Gold
      const Color(0xFF96ceb4), // Green
      const Color(0xFFfeca57), // Yellow
    ];
    
    final random = index * 37; // Pseudo-random based on index
    final color = colors[random % colors.length];
    final size = 4.0 + (random % 4);
    final left = (random % 100).toDouble();
    
    return Positioned(
      left: left,
      top: -10,
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 2000 + (random % 1000)),
        tween: Tween(begin: -10, end: isMobile ? 250 : 320),
        curve: Curves.linear,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, value),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }

  // Trophy Section with Bounce Animation
  Widget _buildTrophySection(bool isMobile) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 2),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.bounceOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Transform.rotate(
            angle: (value - 0.5) * 0.1,
            child: Container(
              width: isMobile ? 60 : 80,
              height: isMobile ? 60 : 80,
              decoration: BoxDecoration(
                color: const Color(0xFFffd700),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFffd700).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.emoji_events,
                size: isMobile ? 30 : 40,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  // Main Gameshow Content
  Widget _buildGameshowContent(Event placeholderEvent, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Brand Text with Glow
        TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 2),
          tween: Tween(begin: 0, end: 1),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Text(
              'MyDscvr\'s Choice',
              style: GoogleFonts.comfortaa(
                fontSize: isMobile ? 14 : 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: const Color(0xFFffd700).withOpacity(value),
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            );
          },
        ),
        
        SizedBox(height: isMobile ? 4 : 8),
        
        // Main Title
        Text(
          'Event of the Day',
          style: GoogleFonts.comfortaa(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
        
        SizedBox(height: isMobile ? 6 : 10),
        
        // Event Name (Dynamic)
        Text(
          placeholderEvent.title.length > 40 
              ? '${placeholderEvent.title.substring(0, 37)}...'
              : placeholderEvent.title,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 16 : 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ).animate().fadeIn(delay: 400.ms),
        
        SizedBox(height: isMobile ? 8 : 12),
        
        // Details Row
        Row(
          children: [
            _buildDetailBadge('📅', 'This Week', isMobile),
            SizedBox(width: isMobile ? 8 : 12),
            _buildDetailBadge('📍', placeholderEvent.venue.area, isMobile),
          ],
        ).animate().fadeIn(delay: 600.ms),
        
        SizedBox(height: isMobile ? 8 : 12),
        
        // Winner Badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 6 : 8,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFff6b6b), Color(0xFFee5a24)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFff6b6b).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 14)),
              SizedBox(width: isMobile ? 4 : 6),
              Text(
                'Featured Winner',
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 800.ms),
      ],
    );
  }

  // Detail Badge Helper
  Widget _buildDetailBadge(String emoji, String text, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 10,
        vertical: isMobile ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: isMobile ? 10 : 12)),
          SizedBox(width: isMobile ? 3 : 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 10 : 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Celebration Elements (Desktop only)
  Widget _buildCelebrationElements() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Sparkle Effect
        TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 2),
          tween: Tween(begin: 0, end: 1),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: const Text(
                '✨',
                style: TextStyle(fontSize: 24),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        const Text('🎊', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 10),
        const Text('🎈', style: TextStyle(fontSize: 18)),
      ],
    );
  }
  
  Widget _buildMyDscvrChoiceLoading() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth <= 600;
        final isTablet = screenWidth > 600 && screenWidth <= 900;
        
        // Responsive dimensions
        final horizontalMargin = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
        final verticalMargin = isMobile ? 16.0 : 24.0;
        final borderRadius = isMobile ? 16.0 : 24.0;
        
        // Responsive heights
        final containerHeight = isMobile ? 180.0 : (isTablet ? 220.0 : 280.0);
        
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: horizontalMargin,
            vertical: verticalMargin,
          ),
          height: containerHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: AppColors.surface,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.dubaiTeal),
                  strokeWidth: 2,
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  'Curating today\'s perfect choice...',
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 12 : 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExploreAllEventsButton() {
    print('🔍 DEBUG: Building Explore All Events Button!');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          // Section title
          Text(
            'Ready to discover more?',
            style: GoogleFonts.comfortaa(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Explore hundreds of family-friendly events happening in Dubai',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Centered button with max width
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    print('🎯 Explore All Events button clicked!');
                    context.go('/events');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dubaiTeal,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: AppColors.dubaiTeal.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.calendar,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Explore All Events',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        LucideIcons.arrowRight,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Additional incentive text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.dubaiTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.dubaiTeal.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.sparkles,
                  size: 20,
                  color: AppColors.dubaiTeal,
                ),
                const SizedBox(width: 8),
                Text(
                  'New events added daily!',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dubaiTeal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Footer();
  }

  Widget _buildFloatingSearch() {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: GlassCard(
        padding: const EdgeInsets.all(4),
        blur: kIsWeb ? 5 : 20,
        opacity: 0.9,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onTap: () {
                  context.go('/ai-search');
                },
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Search events...',
                  hintStyle: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppColors.sunsetGradient,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                LucideIcons.sliders,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ).animate(
        onPlay: (controller) => controller.forward(),
      ).fadeIn(duration: kIsWeb ? 100.ms : 400.ms),
    );
  }

  String _formatEventTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    
    final hour = date.hour == 0 ? 12 : date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final timeString = '$hour:$minute $period';
    
    if (eventDay == today) {
      return 'Today $timeString';
    } else if (eventDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow $timeString';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} $timeString';
    }
  }
}

/// Simple shimmer loading card for events
class ShimmerEventCard extends StatelessWidget {
  const ShimmerEventCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Icon(
                Icons.image,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
          ),
          
          // Content placeholder
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle placeholder
                  Container(
                    width: 150,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Bottom row placeholder
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
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
    );
  } }
