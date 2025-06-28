import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

// Core imports  
import '../../core/constants/app_colors.dart';

// Animation imports
import '../../core/animations/animations.dart';

// Data imports
import '../../models/event.dart';
import '../../models/event_stats.dart';

// Widget imports
import '../../core/widgets/glass_morphism.dart';
import '../../core/widgets/curved_container.dart';
import '../../core/widgets/bubble_decoration.dart';

import '../../widgets/notifications/notification_bell.dart';
import '../../widgets/home/home_search_widget_simple.dart';
import '../../widgets/home/interactive_category_explorer.dart';
import '../../widgets/featured_events_section_riverpod.dart';
import '../../widgets/home/weekend_highlights.dart';
import '../../widgets/home/smart_trending_section.dart';
import '../../widgets/home/hidden_gem_card.dart';
import '../../widgets/common/footer.dart';
import '../../core/widgets/error_boundary.dart';

// Provider imports
import '../../services/providers/auth_provider_mongodb.dart';

// Feature imports
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../event_details/event_details_screen.dart';
import '../../services/events_service.dart';

class AnimatedHomeScreen extends ConsumerStatefulWidget {
  const AnimatedHomeScreen({super.key});

  @override
  ConsumerState<AnimatedHomeScreen> createState() => _AnimatedHomeScreenState();
}

class _AnimatedHomeScreenState extends ConsumerState<AnimatedHomeScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _showFloatingSearch = false;
  String? _hoveredEventId;
  
  // Real API data
  late final EventsService _eventsService;
  List<Event> _upcomingEvents = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Event stats for quick display
  int _totalEventsCount = 0;
  int _totalVenuesCount = 0;

  @override
  void initState() {
    super.initState();
    _eventsService = EventsService();
    _scrollController = ScrollController();
    
    _scrollController.addListener(() {
      final shouldShowFloatingSearch = _scrollController.offset > 200;
      if (shouldShowFloatingSearch != _showFloatingSearch) {
        setState(() {
          _showFloatingSearch = shouldShowFloatingSearch;
        });
      }
    });
    
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      // Load total events count for stats
      final totalCountResponse = await _eventsService.getTotalEventsCount();
      
      // Load upcoming events only (featured events handled by FeaturedEventsSection)
      final upcomingResponse = await _eventsService.getEvents(
        perPage: 20,
        sortBy: 'start_date',
      );

      if (mounted) {
        setState(() {
          if (totalCountResponse.isSuccess) {
            _totalEventsCount = totalCountResponse.data ?? 0;
            // Estimate venues count (roughly 1 venue per 4 events)
            _totalVenuesCount = (_totalEventsCount / 4).ceil();
          }
          if (upcomingResponse.isSuccess) {
            final allEvents = upcomingResponse.data ?? [];
            print('📊 DEBUG: Total events from API: ${allEvents.length}');
            
            // First try future events
            var futureEvents = allEvents
                .where((e) => e.startDate.isAfter(DateTime.now()))
                .toList();
            print('📊 DEBUG: Future events found: ${futureEvents.length}');
            
            // If no future events, temporarily use all events for debugging
            if (futureEvents.isEmpty && allEvents.isNotEmpty) {
              print('⚠️ DEBUG: No future events found, checking all events for debugging...');
              futureEvents = allEvents.take(10).toList(); // Take first 10 for debugging
              for (var event in futureEvents) {
                print('📅 DEBUG: Event "${event.title}" - Date: ${event.startDate}');
              }
            }
            
            // Select the best curated event using smart algorithm
            _upcomingEvents = _selectBestCuratedEvents(futureEvents);
            print('📊 DEBUG: Final curated events: ${_upcomingEvents.length}');
          } else {
            print('❌ DEBUG: API call failed: ${upcomingResponse.error}');
          }
          _isLoading = false;
          _errorMessage = upcomingResponse.error ?? totalCountResponse.error;
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
    _scrollController.dispose();
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
          // Main content
          CustomScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            slivers: [
              // Top App Bar with authentication
              _buildAnimatedTopAppBar(),
              
              // Beautiful hero section with curves and bubbles
              _buildAnimatedHeroSection(),
              
              // Featured Events
              SliverToBoxAdapter(
                child: _buildAnimatedFeaturedEvents(),
              ),
              
              // Hidden Gem Discovery
              SliverToBoxAdapter(
                child: _buildAnimatedHiddenGem(),
              ),
              
              // Categories with proper layout
              SliverToBoxAdapter(
                child: _buildAnimatedCategories(),
              ),
              
              // Weekend Highlights
              SliverToBoxAdapter(
                child: _buildAnimatedWeekendHighlights(),
              ),
              
              // Trending Events
              SliverToBoxAdapter(
                child: _buildAnimatedTrendingEvents(),
              ),
              
              // MyDscvr's Choice banner
              SliverToBoxAdapter(
                child: _buildAnimatedMyDscvrChoice(),
              ),
              
              // Explore All Events CTA
              SliverToBoxAdapter(
                child: _buildExploreAllEventsButton(),
              ),
              
              // Footer
              SliverToBoxAdapter(
                child: _buildAnimatedFooter(),
              ),
            ],
          ),
          
          // Floating Search
          if (_showFloatingSearch) _buildFloatingSearch(),
        ],
      ),
    );
  }

  Widget _buildAnimatedTopAppBar() {
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
      flexibleSpace: FadeInSlideUp(
        child: Container(
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
      ),
      title: FadeInSlideUp(
        delay: const Duration(milliseconds: 200),
        child:         Row(
          children: [
            Image.asset(
              'assets/images/mydscvr-logo.png',
              height: 40,
              width: 40,
              fit: BoxFit.contain,
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
          FadeInSlideUp(
            delay: const Duration(milliseconds: 400),
            child: const NotificationBell(
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          
          FadeInSlideUp(
            delay: const Duration(milliseconds: 500),
            child: PopupMenuButton<String>(
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: user?.avatar != null
                    ? NetworkImage(user!.avatar!)
                    : null,
                child: user?.avatar == null
                    ? Text(
                        user?.displayName.substring(0, 2).toUpperCase() ?? 'U',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              itemBuilder: (context) {
                final authState = ref.watch(authProvider);
                final hasCompletedOnboarding = authState.user?.onboardingCompleted ?? false;
                
                return [
                  PopupMenuItem(
                    value: 'profile',
                    child: const Row(
                      children: [
                        Icon(LucideIcons.user, size: 16, color: AppColors.dubaiTeal),
                        SizedBox(width: 8),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  if (!hasCompletedOnboarding)
                    PopupMenuItem(
                      value: 'onboarding',
                      child: const Row(
                        children: [
                          Icon(LucideIcons.userPlus, size: 16, color: AppColors.dubaiGold),
                          SizedBox(width: 8),
                          Text('Complete Onboarding'),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'favorites',
                    child: const Row(
                      children: [
                        Icon(LucideIcons.heart, size: 16, color: Colors.pink),
                        SizedBox(width: 8),
                        Text('Favorites'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: const Row(
                      children: [
                        Icon(LucideIcons.settings, size: 16, color: Colors.grey),
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
                ];
              },
              onSelected: (value) => _handleProfileMenuAction(value),
            ),
          ),
        ] else ...[
          // Debug: Onboarding access for testing
          if (kDebugMode) ...[
            FadeInSlideUp(
              delay: const Duration(milliseconds: 350),
              child: TextButton(
                onPressed: () => context.go('/onboarding'),
                child: Text(
                  'Onboarding',
                  style: GoogleFonts.inter(
                    color: AppColors.dubaiGold,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          FadeInSlideUp(
            delay: const Duration(milliseconds: 400),
            child: TextButton(
              onPressed: () => _navigateToLogin(),
              child: Text(
                'Login',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          FadeInSlideUp(
            delay: const Duration(milliseconds: 500),
            child: PulsingButton(
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
          ),
        ],
        const SizedBox(width: 16),
      ],
    );
  }

  void _handleProfileMenuAction(String action) {
    switch (action) {
      case 'profile':
        context.go('/profile');
        break;
      case 'onboarding':
        context.go('/onboarding');
        break;
      case 'favorites':
        context.go('/favorites');
        break;
      case 'settings':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings screen - coming soon!')),
        );
        break;
      case 'logout':
        ref.read(authProvider.notifier).logout();
        break;
    }
  }

  void _navigateToLogin() {
    context.go('/login');
  }

  void _navigateToSignUp() {
    context.go('/register');
  }

  Widget _buildAnimatedHeroSection() {
    return SliverToBoxAdapter(
      child: FadeInSlideUp(
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
          height: 550,
          child: Stack(
            children: [
              // Enhanced animated background orbs
              Positioned(
                left: 80,
                top: 120,
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
                ).animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                ).scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: 3000.ms,
                  curve: Curves.easeInOut,
                ),
              ),
              
              // Medium orb
              Positioned(
                right: 60,
                top: 200,
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
                ).animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                ).scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.1, 1.1),
                  duration: 2000.ms,
                  curve: Curves.easeInOut,
                ),
              ),
              
              // Small accent orbs
              Positioned(
                left: 200,
                top: 80,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ).animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                ).fadeIn(
                  duration: 1500.ms,
                  curve: Curves.easeInOut,
                ),
              ),
              
              Positioned(
                right: 150,
                top: 320,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ).animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                ).scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.5, 1.5),
                  duration: 2500.ms,
                  curve: Curves.easeInOut,
                ),
              ),
              
              // Hero content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced main heading with staggered animation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FadeInSlideUp(
                                  delay: const Duration(milliseconds: 200),
                                  child: Text(
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
                                  ),
                                ),
                                FadeInSlideUp(
                                  delay: const Duration(milliseconds: 400),
                                  child: Text(
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
                                  ),
                                ),
                                const SizedBox(height: 8),
                                FadeInSlideUp(
                                  delay: const Duration(milliseconds: 600),
                                  child: Text(
                                    'From family fun to cultural experiences, find your perfect Dubai moment',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Search bar
                      FadeInSlideUp(
                        delay: const Duration(milliseconds: 600),
                        child: const SimpleHomeSearchWidget(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Quick stats
                      FadeInSlideUp(
                        delay: const Duration(milliseconds: 800),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                                        _buildStatCard(LucideIcons.calendar, _formatEventCount(_totalEventsCount), 'Events'),
            _buildStatCard(LucideIcons.mapPin, _formatEventCount(_totalVenuesCount), 'Venues'),
            _buildStatCard(LucideIcons.heart, '5k+', 'Families'),
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
    );
  }

  Widget _buildStatCard(IconData icon, String number, String label) {
    return PulsingButton(
      onPressed: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, -2),
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
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              number,
              style: GoogleFonts.comfortaa(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ).animate(
        onPlay: (controller) => controller.forward(),
      ).scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1.0, 1.0),
        duration: 600.ms,
        delay: 100.ms,
        curve: Curves.elasticOut,
      ).fadeIn(
        duration: 400.ms,
        delay: 200.ms,
      ),
    );
  }


  Widget _buildAnimatedFeaturedEvents() {
    return FadeInSlideUp(
      child: ErrorBoundary(
        fallbackMessage: 'Failed to load featured events',
        onError: () {
          print('🚨 FeaturedEventsSection error caught by ErrorBoundary');
        },
        child: FeaturedEventsSection(
          showHeader: true,
          maxEventsToShow: 8,
          padding: const EdgeInsets.all(24),
          onEventTap: (event) {
            // Navigate to event details page
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EventDetailsScreen(eventId: event.id, event: event),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedCategories() {
    return FadeInSlideUp(
      delay: const Duration(milliseconds: 200),
      child: const InteractiveCategoryExplorer(),
    );
  }

  Widget _buildAnimatedWeekendHighlights() {
    return FadeInSlideUp(
      delay: const Duration(milliseconds: 400),
      child: const WeekendHighlights(),
    );
  }

  Widget _buildAnimatedTrendingEvents() {
    // Use the new Smart Trending Section widget with animation wrapper
    return FadeInSlideUp(
      child: const SmartTrendingSection(),
    );
  }

  Widget _buildAnimatedMyDscvrChoice() {
    print('🎯 DEBUG: Building Animated MyDscvr\'s Choice Banner - isLoading: $_isLoading, events: ${_upcomingEvents.length}');
    
    // Show loading state while data is being fetched
    if (_isLoading) {
      return _buildAnimatedMyDscvrChoiceLoading();
    }
    
    // Use first available event as placeholder
    final placeholderEvent = _upcomingEvents.isNotEmpty ? _upcomingEvents.first : null;
    
    if (placeholderEvent == null) {
      return _buildAnimatedMyDscvrChoiceEmpty();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: FadeInSlideUp(
        delay: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          height: 380, // 30% taller for premium real estate
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32), // Ultra-modern radius
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF17A2B8), // Teal
                Color(0xFF6C5CE7), // Purple
                Color(0xFF17A2B8), // Back to teal
              ],
              stops: [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              // Multi-layered shadow system
              BoxShadow(
                color: AppColors.dubaiTeal.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: 5,
              ),
              BoxShadow(
                color: const Color(0xFF6C5CE7).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 25),
                spreadRadius: 10,
              ),
            ],
            // Animated gradient border
            border: Border.all(
              width: 2,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Glass morphism backdrop
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Animated floating particles
                ...List.generate(6, (index) => _buildFloatingParticle(index)),
                
                // Premium gradient mesh background
                _buildGradientMeshBackground(),
              
              // Premium floating algorithm badge
              FadeInSlideUp(
                delay: const Duration(milliseconds: 800),
                child: Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFD4AF37), // Gold
                          Color(0xFFFFD700), // Bright gold
                          Color(0xFFD4AF37), // Gold
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.zap,
                          size: 18,
                          color: Colors.white,
                        ).animate(onPlay: (controller) => controller.repeat())
                            .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.8)),
                        const SizedBox(width: 6),
                        Text(
                          'AI Choice',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.05, 1.05),
                        duration: 2000.ms,
                        curve: Curves.easeInOut,
                      ),
                ),
              ),
              
              // Main content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enhanced header with premium typography
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInSlideUp(
                          delay: const Duration(milliseconds: 300),
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                colors: [
                                  Colors.white,
                                  const Color(0xFFD4AF37), // Gold accent for "Choice"
                                  Colors.white,
                                ],
                                stops: const [0.0, 0.7, 1.0],
                              ).createShader(bounds);
                            },
                            child: Text(
                              'MyDscvr\'s Choice',
                              style: GoogleFonts.comfortaa(
                                fontSize: 32, // Larger for premium impact
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2, // Enhanced letter spacing
                                height: 1.1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ).animate()
                              .fadeIn(duration: 600.ms, delay: 300.ms)
                              .slideY(begin: 0.3, end: 0.0, duration: 800.ms, curve: Curves.easeOutCubic),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        FadeInSlideUp(
                          delay: const Duration(milliseconds: 500),
                          child: Container(
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
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Event content
                    Expanded(
                      child: Row(
                        children: [
                          // Premium event image with enhanced styling
                          FadeInSlideUp(
                            delay: const Duration(milliseconds: 700),
                            child: MouseRegion(
                              onEnter: (_) => setState(() => _hoveredEventId = placeholderEvent.id),
                              onExit: (_) => setState(() => _hoveredEventId = null),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                transform: Matrix4.identity()
                                  ..scale(_hoveredEventId == placeholderEvent.id ? 1.05 : 1.0),
                                width: 160, // Larger premium size
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24), // Increased radius
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.3),
                                      Colors.white.withOpacity(0.1),
                                      const Color(0xFFD4AF37).withOpacity(0.2), // Gold tint
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.6), // Enhanced border
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    // Multiple shadow layers for depth
                                    BoxShadow(
                                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                      spreadRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: AppColors.dubaiTeal.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 4),
                                      spreadRadius: 1,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 25,
                                      offset: const Offset(0, 12),
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Background icon with glow effect
                                    Center(
                                      child: Icon(
                                        LucideIcons.sparkles,
                                        color: Colors.white.withOpacity(0.9),
                                        size: 50,
                                      ).animate(onPlay: (controller) => controller.repeat())
                                          .shimmer(duration: 3000.ms, color: const Color(0xFFD4AF37).withOpacity(0.6))
                                          .scale(
                                            begin: const Offset(0.9, 0.9),
                                            end: const Offset(1.1, 1.1),
                                            duration: 2000.ms,
                                            curve: Curves.easeInOut,
                                          ),
                                    ),
                                    // Overlay gradient for premium look
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(21),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              const Color(0xFFD4AF37).withOpacity(0.1),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 20),
                          
                          // Event details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FadeInSlideUp(
                                  delay: const Duration(milliseconds: 900),
                                  child: Text(
                                    placeholderEvent.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 22, // Larger premium title
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.3, // Better line height
                                      letterSpacing: 0.3,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.4),
                                          offset: const Offset(0, 1),
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ).animate()
                                      .fadeIn(duration: 600.ms, delay: 900.ms)
                                      .slideX(begin: 0.3, end: 0.0, duration: 800.ms, curve: Curves.easeOutCubic),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Date and location
                                FadeInSlideUp(
                                  delay: const Duration(milliseconds: 1100),
                                  child: Row(
                                    children: [
                                      Icon(
                                        LucideIcons.calendar,
                                        size: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatEventTime(placeholderEvent.startDate),
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 4),
                                
                                FadeInSlideUp(
                                  delay: const Duration(milliseconds: 1200),
                                  child: Row(
                                    children: [
                                      Icon(
                                        LucideIcons.mapPin,
                                        size: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          placeholderEvent.venue.area,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Algorithm insight
                                FadeInSlideUp(
                                  delay: const Duration(milliseconds: 1300),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'Perfect for families like yours',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.9),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const Spacer(),
                                
                                // CTA Button
                                FadeInSlideUp(
                                  delay: const Duration(milliseconds: 1400),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context.go('/event/${placeholderEvent.id}');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.dubaiTeal,
                                      elevation: 8,
                                      shadowColor: Colors.black.withOpacity(0.2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Discover Why',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          LucideIcons.arrowRight,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ), // End Stack children
        ), // End ClipRRect
      ), // End AnimatedContainer  
    ), // End FadeInSlideUp
    ); // End Container
  }
  
  Widget _buildAnimatedMyDscvrChoiceLoading() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: FadeInSlideUp(
        delay: const Duration(milliseconds: 200),
        child: Container(
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
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
                const SizedBox(height: 16),
                Text(
                  'Curating today\'s perfect choice...',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedMyDscvrChoiceEmpty() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: FadeInSlideUp(
        delay: const Duration(milliseconds: 200),
        child: Container(
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppColors.surface,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.sparkles,
                  size: 48,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No upcoming events available',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back soon for our next curated choice!',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Smart algorithm to select the best curated events for MyDscvr's Choice
  List<Event> _selectBestCuratedEvents(List<Event> futureEvents) {
    if (futureEvents.isEmpty) return [];
    
    // Score each event based on curation criteria
    final scoredEvents = futureEvents.map((event) {
      double score = 0.0;
      
      // 1. Rating score (40% weight) - events with higher ratings get priority
      if (event.rating > 0) {
        score += (event.rating / 5.0) * 40;
      }
      
      // 2. Family-friendly bonus (25% weight) - family events are premium
      final isFamilyFriendly = event.tags.any((tag) => 
        tag.toLowerCase().contains('family') || 
        tag.toLowerCase().contains('kids') ||
        tag.toLowerCase().contains('children'));
      if (isFamilyFriendly) {
        score += 25;
      }
      
      // 3. Rich content score (20% weight) - events with more tags are better curated
      final tagCount = event.tags.length;
      if (tagCount >= 5) {
        score += 20;
      } else if (tagCount >= 3) {
        score += 15;
      } else if (tagCount >= 1) {
        score += 10;
      }
      
      // 4. Venue quality bonus (10% weight) - premium venues get priority
      final premiumVenues = ['Dubai Mall', 'Mall of the Emirates', 'JBR', 'Downtown Dubai', 'Marina'];
      final isPremiumVenue = premiumVenues.any((venue) => 
        event.venue.name.toLowerCase().contains(venue.toLowerCase()) ||
        event.venue.area.toLowerCase().contains(venue.toLowerCase()));
      if (isPremiumVenue) {
        score += 10;
      }
      
      // 5. Timing bonus (5% weight) - events happening this weekend get slight priority
      final now = DateTime.now();
      final weekend = now.add(Duration(days: (6 - now.weekday) % 7));
      final isWeekend = event.startDate.isBefore(weekend.add(const Duration(days: 2))) &&
                       event.startDate.isAfter(weekend.subtract(const Duration(days: 1)));
      if (isWeekend) {
        score += 5;
      }
      
      return MapEntry(event, score);
    }).toList();
    
    // Sort by score (highest first) and add rotation for variety
    scoredEvents.sort((a, b) => b.value.compareTo(a.value));
    
    // Add daily rotation among top-scored events to keep it fresh
    final topEvents = scoredEvents.take(5).toList();
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final rotationIndex = dayOfYear % topEvents.length;
    
    // Return the selected event(s) with rotation
    final selectedEvents = [topEvents[rotationIndex].key];
    print('🎯 DEBUG: Selected curated event: ${selectedEvents.first.title} (score: ${topEvents[rotationIndex].value.toStringAsFixed(1)})');
    
    return selectedEvents;
  }

  /// Build floating particle animation for premium background effect
  Widget _buildFloatingParticle(int index) {
    final random = Random(index * 42);
    final size = 4.0 + random.nextDouble() * 8.0;
    final left = random.nextDouble() * 300;
    final top = random.nextDouble() * 300;
    final duration = 3000 + random.nextInt(4000);
    
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.white.withOpacity(0.8),
              const Color(0xFFD4AF37).withOpacity(0.4),
              Colors.transparent,
            ],
          ),
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(0.3, 0.3),
            end: const Offset(1.5, 1.5),
            duration: duration.ms,
            curve: Curves.easeInOut,
          )
          .fadeIn(duration: (duration * 0.3).round().ms)
          .then()
          .fadeOut(duration: (duration * 0.3).round().ms),
    );
  }

  /// Build gradient mesh background for ultra-modern premium effect
  Widget _buildGradientMeshBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: GradientMeshPainter(),
      ),
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

  Widget _buildAnimatedHiddenGem() {
    final user = ref.watch(authProvider);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: FadeInSlideUp(
        delay: const Duration(milliseconds: 600),
        child: HiddenGemCard(
          userId: user?.user?.id,
          onGemRevealed: () {
            // Optional: Add any callback logic here
            // For example, analytics tracking or refreshing other sections
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedFooter() {
    return FadeInSlideUp(
      delay: const Duration(milliseconds: 400),
      child: const Footer(),
    );
  }
  
  Widget _buildExploreAllEventsButton() {
    return FadeInSlideUp(
      delay: const Duration(milliseconds: 350),
      child: Container(
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
      ),
    );
  }

  Widget _buildFloatingSearch() {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: FadeInSlideUp(
        delay: const Duration(milliseconds: 300),
        child: GlassCard(
          padding: const EdgeInsets.all(4),
          blur: kIsWeb ? 5 : 20,
          opacity: 0.9,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onTap: () {
                    // Navigate to AI search
                    context.go('/ai-search');
                  },
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Ask AI about Dubai family activities...',
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
              PulsingButton(
                onPressed: () {
                  // Navigate to AI search
                  context.go('/ai-search');
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppColors.oceanGradient,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for premium gradient mesh background effect
class GradientMeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create multiple gradient overlays for mesh effect
    final gradients = [
      RadialGradient(
        center: const Alignment(-0.3, -0.5),
        radius: 0.8,
        colors: [
          const Color(0xFFD4AF37).withOpacity(0.15), // Gold
          Colors.transparent,
        ],
      ),
      RadialGradient(
        center: const Alignment(0.7, 0.3),
        radius: 0.6,
        colors: [
          const Color(0xFF6C5CE7).withOpacity(0.1), // Purple
          Colors.transparent,
        ],
      ),
      RadialGradient(
        center: const Alignment(0.2, 0.8),
        radius: 0.5,
        colors: [
          const Color(0xFF17A2B8).withOpacity(0.12), // Teal
          Colors.transparent,
        ],
      ),
    ];

    for (int i = 0; i < gradients.length; i++) {
      final rect = Rect.fromLTWH(0, 0, size.width, size.height);
      paint.shader = gradients[i].createShader(rect);
      canvas.drawRect(rect, paint);
    }

    // Add subtle geometric pattern
    paint.shader = null;
    paint.color = Colors.white.withOpacity(0.03);
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;

    for (int i = 0; i < 6; i++) {
      final path = Path();
      final startX = (size.width / 6) * i;
      path.moveTo(startX, 0);
      path.quadraticBezierTo(
        startX + size.width / 12,
        size.height / 2,
        startX + size.width / 6,
        size.height,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 