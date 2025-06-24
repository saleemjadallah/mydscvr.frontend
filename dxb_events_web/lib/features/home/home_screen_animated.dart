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
            _upcomingEvents = (upcomingResponse.data ?? [])
                .where((e) => e.startDate.isAfter(DateTime.now()))
                .take(6)
                .toList();
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
              
              // Family Spotlight
              SliverToBoxAdapter(
                child: _buildAnimatedFamilySpotlight(),
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

  Widget _buildAnimatedFamilySpotlight() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInSlideUp(
            child: Text(
              'Family Spotlight ⭐',
              style: GoogleFonts.comfortaa(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          FadeInSlideUp(
            delay: const Duration(milliseconds: 200),
            child: CurvedContainer(
              gradient: AppColors.sunsetGradient,
              curveHeight: 30,
              curvePosition: CurvePosition.both,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 400),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Icon(
                        LucideIcons.users,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 600),
                    child: Text(
                      'The Ahmed Family',
                      style: GoogleFonts.comfortaa(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 800),
                    child: Text(
                      '"DXB Events helped us discover amazing family activities we never knew existed in Dubai!"',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 1000),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          LucideIcons.star,
                          size: 16,
                          color: AppColors.dubaiGold,
                        );
                      }),
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