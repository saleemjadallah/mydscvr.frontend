import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

// Import actual built components
import '../../widgets/home/home_search_widget_simple.dart';
import '../../widgets/home/interactive_category_explorer.dart';
import '../../widgets/featured_events_section_riverpod.dart';
import '../../widgets/home/weekend_highlights.dart';
import '../../widgets/home/smart_trending_section.dart';
import '../../widgets/home/hidden_gem_card.dart';
import '../../core/animations/animations.dart';
import '../../widgets/search/super_search_button.dart';
// Ad imports removed - ads are now handled in index.html

// Import header and orange section components
import '../../core/widgets/curved_container.dart';
import '../../core/constants/app_colors.dart';
import '../../services/providers/auth_provider_mongodb.dart';
import '../../services/providers/preferences_provider.dart';
import '../../models/user.dart';
import '../../services/events_service.dart';
import '../../services/mydscvr_choice_service.dart';
import '../../models/event.dart';
import '../../models/api_response.dart';
import '../../widgets/common/footer.dart';
import '../../widgets/notifications/notification_bell.dart';

/// Beautiful homepage with working animations
class BeautifulHomeScreen extends ConsumerStatefulWidget {
  const BeautifulHomeScreen({super.key});

  @override
  ConsumerState<BeautifulHomeScreen> createState() => _BeautifulHomeScreenState();
}

class _BeautifulHomeScreenState extends ConsumerState<BeautifulHomeScreen> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  String? _hoveredEventId;
  
  // Real API data for MyDscvr's Choice and stats
  late final EventsService _eventsService;
  late final MyDscvrChoiceService _myDscvrChoiceService;
  List<Event> _upcomingEvents = [];
  List<Event> _featuredEvents = [];
  List<Event> _trendingEvents = [];
  List<Event> _allEventsForCounting = []; // For accurate category counting
  Event? _myDscvrChoiceEvent; // Today's MyDscvr's Choice
  bool _isLoading = true;
  String? _errorMessage;
  
  // Event stats for quick display
  int _totalEventsCount = 0;
  int _totalVenuesCount = 0;
  
  @override
  void initState() {
    super.initState();
    _eventsService = EventsService();
    _myDscvrChoiceService = MyDscvrChoiceService();
    _scrollController = ScrollController();
    _loadEvents(); // Re-enabled for final solution
    
    // Refresh user data when home screen loads to ensure favorites count is accurate in app bar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(authProvider.notifier).refreshUser();
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Navigate to event details page
  void _navigateToEventDetails(Event event) {
    context.go('/event/${event.id}');
  }

  /// Build AdSense ad container with header
  Widget _buildAdSenseContainer(String identifier, [Color? backgroundColor]) {
    return Container(
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
          
          // AdSense container - Placeholder that will show test ads when AdSense is approved
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.grey[50],
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
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Google AdSense Ad',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Publisher: ca-pub-2361005033053502',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Slot: 2625901948',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Test ads will appear here once approved',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Beautiful gradient app bar with logo
          _buildTopAppBar(context, authState),
          
          // Beautiful Orange Hero Section with integrated search
          _buildHeroSection(),
          
          // Featured Events - Using actual component
          SliverToBoxAdapter(
            child: FadeInSlideUp(
              delay: const Duration(milliseconds: 200),
              child: FeaturedEventsSection(
                showHeader: true,
                maxEventsToShow: 8,
                onEventTap: (event) {
                  // Navigate to event details page
                  context.go('/event/${event.id}');
                },
              ),
            ),
          ),
          
          // Ad Placeholder 1 - After Featured Events (only on web)
          if (kIsWeb)
            SliverToBoxAdapter(
              child: _buildAdSenseContainer('homepage-1', Colors.blue[50]),
            ),
          
          // Hidden Gem - Using actual component
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: FadeInSlideUp(
                delay: Duration(milliseconds: 400),
                child: HiddenGemCard(),
              ),
            ),
          ),
          
          // Ad Placeholder 2 - Between Hidden Gem and Categories
          if (kIsWeb)
            SliverToBoxAdapter(
              child: _buildAdSenseContainer('homepage-2', Colors.green[50]),
            ),
          
          // Categories Section - Using actual component
          const SliverToBoxAdapter(
            child: FadeInSlideUp(
              delay: Duration(milliseconds: 600),
              child: InteractiveCategoryExplorer(),
            ),
          ),
          
          // Weekend Highlights - Using actual component
          const SliverToBoxAdapter(
            child: FadeInSlideUp(
              delay: Duration(milliseconds: 800),
              child: WeekendHighlights(),
            ),
          ),
          
          // Trending Section - Using actual component
          const SliverToBoxAdapter(
            child: FadeInSlideUp(
              delay: Duration(milliseconds: 1000),
              child: SmartTrendingSection(),
            ),
          ),
          
          // Ad Placeholder 3 - Between Trending Now and MyDscvr's Choice
          if (kIsWeb)
            SliverToBoxAdapter(
              child: _buildAdSenseContainer('homepage-3', Colors.purple[50]),
            ),
          
          // MyDscvr's Choice Section - Final solution
          SliverToBoxAdapter(
            child: _buildAnimatedMyDscvrChoice(),
          ),
          
          // Explore All Events CTA Button
          SliverToBoxAdapter(
            child: _buildExploreAllEventsButton(),
          ),
          
          // Ad Placeholder 4 - Between Explore All Events and Footer
          if (kIsWeb)
            SliverToBoxAdapter(
              child: _buildAdSenseContainer('homepage-4', Colors.orange[50]),
            ),
          
          // Footer
          SliverToBoxAdapter(
            child: FadeInSlideUp(
              delay: const Duration(milliseconds: 1200),
              child: const Footer(),
            ),
          ),
        ],
      ),
      floatingActionButton: const SuperSearchFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Build the top app bar with gradient background and logo
  Widget _buildTopAppBar(BuildContext context, AuthState authState) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    
    // Responsive app bar height
    final appBarHeight = isMobile ? 90.0 : 80.0;
    
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      floating: true,
      expandedHeight: appBarHeight,
      toolbarHeight: appBarHeight,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isMobile = screenWidth <= 600;
            
            // Responsive logo and text sizing
            final logoHeight = isMobile ? 45.0 : 40.0;
            final logoWidth = isMobile ? 45.0 : 40.0;
            final fontSize = isMobile ? 24.0 : 26.0;
            
            return Row(
              children: [
                Image.asset(
                  'assets/images/mydscvr-logo.png',
                  height: logoHeight,
                  width: logoWidth,
                  fit: BoxFit.contain,
                  // No errorBuilder - let the logo display properly
                ),
                const SizedBox(width: 12),
                Text(
                  'MyDscvr',
                  style: GoogleFonts.comfortaa(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        // Super Search Button - only show on desktop
        if (screenWidth > 600) ...[
          const SuperSearchButtonCompact(),
          const SizedBox(width: 8),
        ],
        // Family Friendly Indicator
        _buildFamilyFriendlyIndicator(),
        // Favorites Icon (for authenticated users)
        if (authState.status == AuthStatus.authenticated && authState.user != null)
          _buildFavoritesIcon(),
        // Auth Buttons/Profile
        if (authState.status == AuthStatus.authenticated && authState.user != null)
          _buildUserProfile(authState.user!)
        else
          _buildAuthButtons(),
        const NotificationBell(
          color: Colors.white,
          size: 22,
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  /// Build favorites icon for authenticated users
  Widget _buildFavoritesIcon() {
    final heartedEvents = ref.watch(heartedEventsProvider);
    final savedEvents = ref.watch(savedEventsProvider);
    final totalFavorites = heartedEvents.length + savedEvents.length;
    
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          IconButton(
            onPressed: () => context.push('/favorites'),
            icon: const Icon(
              LucideIcons.heart,
              color: Colors.white,
              size: 24,
            ),
            tooltip: 'My Favorites',
          ),
          // Badge showing count
          if (totalFavorites > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.dubaiCoral,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  totalFavorites > 99 ? '99+' : totalFavorites.toString(),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build user profile button when authenticated
  Widget _buildUserProfile(UserProfile user) {
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Text(
              (user.firstName?.isNotEmpty == true ? user.firstName![0] : user.email[0]).toUpperCase(),
              style: GoogleFonts.inter(
                color: AppColors.dubaiTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            user.firstName ?? 'Profile',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Build both login and sign up buttons when not authenticated
  Widget _buildAuthButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Login Button
        TextButton(
          onPressed: () => context.go('/login'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            'Login',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Sign Up Button
        ElevatedButton(
          onPressed: () => context.go('/register'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.dubaiTeal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 2,
          ),
          child: Text(
            'Sign Up',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Build family friendly indicator when enabled
  Widget _buildFamilyFriendlyIndicator() {
    final preferences = ref.watch(preferencesProvider);
    
    if (!preferences.familyFriendlyOnly) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            LucideIcons.shield,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Family Friendly',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build sophisticated hero section with integrated search and real stats
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
                          child: const HomeSearchWidget(),
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
                    
                    // Enhanced glassmorphic stat cards with real data
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

  /// Build enhanced glassmorphic stat card with animations
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

  /// Load events for MyDscvr's Choice and stats
  Future<void> _loadEvents() async {
    try {
      // Load all data in parallel for better performance
      final futures = [
        _eventsService.getTotalEventsCount(),
        _eventsService.getEvents(perPage: 10, sortBy: 'start_date'),
        _eventsService.getEvents(perPage: 20, sortBy: 'start_date'),
        _eventsService.getTrendingEvents(limit: 10),
        _myDscvrChoiceService.getCurrentChoice(), // Load today's MyDscvr's Choice
      ];
      
      final results = await Future.wait(futures);
      final totalCountResponse = results[0] as ApiResponse<int>;
      final featuredResponse = results[1] as ApiResponse<List<Event>>;
      final upcomingResponse = results[2] as ApiResponse<List<Event>>;
      final trendingResponse = results[3] as ApiResponse<List<Event>>;
      final myDscvrChoiceResponse = results[4] as ApiResponse<Event>;

      print('🎯 DEBUG: MyDscvr\'s Choice response: success=${myDscvrChoiceResponse.isSuccess}, event=${myDscvrChoiceResponse.data?.title}');
      if (!myDscvrChoiceResponse.isSuccess) {
        print('🚨 DEBUG: MyDscvr\'s Choice API failed: ${myDscvrChoiceResponse.error}');
      }

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
          if (myDscvrChoiceResponse.isSuccess) {
            _myDscvrChoiceEvent = myDscvrChoiceResponse.data;
            print('🎯 DEBUG: MyDscvr\'s Choice event loaded: ${_myDscvrChoiceEvent?.title}');
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
              print('⚠️ DEBUG: No future events found, using recent events...');
              futureEvents = allEvents.take(10).toList();
            }
            
            _upcomingEvents = futureEvents;
            print('📊 DEBUG: Final curated events: ${_upcomingEvents.length}');
          }
          if (trendingResponse.isSuccess) {
            _trendingEvents = trendingResponse.data ?? [];
          }
          _isLoading = false;
          _errorMessage = upcomingResponse.error ?? totalCountResponse.error ?? featuredResponse.error ?? trendingResponse.error ?? myDscvrChoiceResponse.error;
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

  /// Build the GAMESHOW WINNER MyDscvr's Choice banner - exciting daily winner announcement!
  Widget _buildAnimatedMyDscvrChoice() {
    print('🎉 GAMESHOW: Building MyDscvr\'s Daily Winner Banner!');
    
    // Show loading state while data is being fetched
    if (_isLoading) {
      return _buildAnimatedMyDscvrChoiceLoading();
    }
    
    // Use MyDscvr's Choice event if available, otherwise fall back to first upcoming event
    final featuredEvent = _myDscvrChoiceEvent ?? (_upcomingEvents.isNotEmpty ? _upcomingEvents.first : null);
    
    print('🎯 DEBUG: Displaying event in MyDscvr\'s Choice:');
    print('   - MyDscvr\'s Choice Event: ${_myDscvrChoiceEvent?.title} (ID: ${_myDscvrChoiceEvent?.id})');
    print('   - Fallback Event: ${_upcomingEvents.isNotEmpty ? _upcomingEvents.first.title : 'none'} (ID: ${_upcomingEvents.isNotEmpty ? _upcomingEvents.first.id : 'none'})');
    print('   - Final Event Used: ${featuredEvent?.title} (ID: ${featuredEvent?.id})');
    
    if (featuredEvent == null) {
      return _buildAnimatedMyDscvrChoiceEmpty();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth <= 600;
        final isTablet = screenWidth > 600 && screenWidth <= 900;
        
        // Responsive dimensions
        final horizontalMargin = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
        final verticalMargin = isMobile ? 16.0 : 32.0;
        final borderRadius = isMobile ? 20.0 : 25.0;
        final contentPadding = isMobile ? 20.0 : 30.0;
        
        // Responsive heights
        final containerHeight = isMobile ? null : (isTablet ? 280.0 : 320.0);
        
        return Container(
          margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: verticalMargin),
          height: containerHeight,
          constraints: isMobile ? const BoxConstraints(minHeight: 240) : null,
          child: FadeInSlideUp(
            delay: const Duration(milliseconds: 200),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 3),
              tween: Tween(begin: 1.0, end: 1.02),
              curve: Curves.easeInOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: InkWell(
                      onTap: () => _navigateToEventDetails(featuredEvent),
                      borderRadius: BorderRadius.circular(borderRadius),
                      hoverColor: Colors.white.withOpacity(0.1),
                      child: Container(
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
                        
                        // Animated fireworks - left side
                        ...List.generate(3, (index) => _buildFirework(index, isMobile, isLeftSide: true)),
                        
                        // Animated fireworks - right side
                        ...List.generate(3, (index) => _buildFirework(index, isMobile, isLeftSide: false)),
                        
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
                        
                        // Main content - centered gameshow layout
                        Padding(
                          padding: EdgeInsets.all(contentPadding),
                          child: isMobile
                              ? _buildMobileGameshowLayout(featuredEvent)
                              : _buildDesktopGameshowLayout(featuredEvent, isTablet),
                        ),
                      ],
                      ),
                    ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Confetti Animation Widget with Continuous Loop
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
    final size = 6.0 + (random % 4); // Slightly larger for visibility
    final left = (random % 100).toDouble();
    final delay = random % 3000; // Stagger start times
    
    return Positioned(
      left: left,
      top: -20,
      child: _ContinuousConfetti(
        color: color,
        size: size,
        duration: Duration(milliseconds: 3000 + (random % 2000)),
        delay: Duration(milliseconds: delay),
        isMobile: isMobile,
      ),
    );
  }

  // Animated Fireworks Widget with Continuous Loop
  Widget _buildFirework(int index, bool isMobile, {required bool isLeftSide}) {
    final colors = [
      const Color(0xFFff6b6b), // Red
      const Color(0xFF4ecdc4), // Teal
      const Color(0xFFffd700), // Gold
      const Color(0xFFa855f7), // Purple
      const Color(0xFFf97316), // Orange
    ];
    
    final random = index * 73 + (isLeftSide ? 0 : 100); // Different seed for left/right
    final color = colors[random % colors.length];
    
    // Position fireworks on left or right side
    final left = isLeftSide 
        ? 20.0 + (index * 40.0) + (random % 20) // Left side positioning
        : (isMobile ? 200.0 : 400.0) + (index * 40.0) + (random % 20); // Right side positioning
    final top = 20.0 + (random % 60); // Vary vertical position
    
    return Positioned(
      left: left,
      top: top,
      child: _ContinuousFirework(
        color: color,
        delay: Duration(milliseconds: index * 1500 + (isLeftSide ? 0 : 750)), // Offset right side timing
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

  // Mobile Gameshow Layout - Centered and Spacious
  Widget _buildMobileGameshowLayout(Event featuredEvent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Top Row: Trophy and Brand Text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTrophySection(true),
            const SizedBox(width: 16),
            // Brand Text with Glow
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: 0, end: 1),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Text(
                  'MyDscvr\'s Choice',
                  style: GoogleFonts.comfortaa(
                    fontSize: 18,
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
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Main Title - Centered and Large
        Text(
          'Event of the Day',
          style: GoogleFonts.comfortaa(
            fontSize: 28,
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
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        // Event Name - Centered
        Text(
          featuredEvent.title.length > 35 
              ? '${featuredEvent.title.substring(0, 32)}...'
              : featuredEvent.title,
          style: GoogleFonts.inter(
            fontSize: 18,
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
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // Details Row - Centered
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDetailBadge('📅', 'This Week', true),
            const SizedBox(width: 12),
            _buildDetailBadge('📍', featuredEvent.venue?.area ?? 'Dubai', true),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Winner Badge - Centered
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFff6b6b), Color(0xFFee5a24)],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFff6b6b).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Featured Winner',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Desktop Gameshow Layout - Expanded and Spectacular
  Widget _buildDesktopGameshowLayout(Event featuredEvent, bool isTablet) {
    return Row(
      children: [
        // Left Side - Large Trophy with Celebration
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLargeTrophySection(isTablet),
              const SizedBox(height: 20),
              _buildCelebrationElements(),
            ],
          ),
        ),
        
        // Center Content - Main Text Area
        Expanded(
          flex: 4,
          child: Column(
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
                      fontSize: isTablet ? 22 : 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: const Color(0xFFffd700).withOpacity(value),
                          blurRadius: 15,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              
              SizedBox(height: isTablet ? 12 : 16),
              
              // Main Title - Large and Centered
              Text(
                'Event of the Day',
                style: GoogleFonts.comfortaa(
                  fontSize: isTablet ? 36 : 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(3, 3),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: isTablet ? 16 : 20),
              
              // Event Name - Large and Prominent
              Text(
                featuredEvent.title.length > 50 
                    ? '${featuredEvent.title.substring(0, 47)}...'
                    : featuredEvent.title,
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 24 : 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: isTablet ? 20 : 24),
              
              // Details Row - Larger and Centered
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLargeDetailBadge('📅', 'This Week', isTablet),
                  SizedBox(width: isTablet ? 16 : 20),
                  _buildLargeDetailBadge('📍', featuredEvent.venue?.area ?? 'Dubai', isTablet),
                ],
              ),
              
              SizedBox(height: isTablet ? 20 : 24),
              
              // Winner Badge - Large and Impressive
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 32,
                  vertical: isTablet ? 12 : 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFff6b6b), Color(0xFFee5a24)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFff6b6b).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🎉', style: TextStyle(fontSize: isTablet ? 18 : 22)),
                    SizedBox(width: isTablet ? 8 : 12),
                    Text(
                      'Featured Winner',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 16 : 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Right Side - More Celebration Elements
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRightSideCelebration(),
            ],
          ),
        ),
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

  // Large Trophy Section for Desktop
  Widget _buildLargeTrophySection(bool isTablet) {
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
              width: isTablet ? 100 : 120,
              height: isTablet ? 100 : 120,
              decoration: BoxDecoration(
                color: const Color(0xFFffd700),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFffd700).withOpacity(0.6),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.emoji_events,
                size: isTablet ? 50 : 60,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  // Large Detail Badge for Desktop
  Widget _buildLargeDetailBadge(String emoji, String text, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 20,
        vertical: isTablet ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: isTablet ? 16 : 20)),
          SizedBox(width: isTablet ? 6 : 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: isTablet ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Celebration Elements (Desktop only) - Just centered crown
  Widget _buildCelebrationElements() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pulsing Crown - Centered
        TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 2),
          tween: Tween(begin: 0.8, end: 1.2),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: const Text(
                '👑',
                style: TextStyle(fontSize: 32),
              ),
            );
          },
        ),
      ],
    );
  }

  // Right Side Celebration Elements - Minimal design with just fireworks
  Widget _buildRightSideCelebration() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Empty space - fireworks are positioned with absolute positioning
        const SizedBox(height: 80),
      ],
    );
  }

  // Special Firework Burst Animation
  Widget _buildFireworkBurst() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 4),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        // Create a burst effect that repeats
        final burstProgress = (value * 4) % 1; // Creates 4 bursts over 4 seconds
        
        if (burstProgress < 0.2) {
          // Build-up phase
          return Container(
            width: 20 + (burstProgress * 40),
            height: 20 + (burstProgress * 40),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFffd700).withOpacity(burstProgress * 5),
                  Colors.transparent,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🎆', style: TextStyle(fontSize: 26)),
            ),
          );
        } else {
          // Explosion phase
          final explosionProgress = (burstProgress - 0.2) / 0.8;
          final radius = explosionProgress * 30;
          final opacity = (1 - explosionProgress).clamp(0.0, 1.0);
          
          return SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                const Center(
                  child: Text('🎆', style: TextStyle(fontSize: 26)),
                ),
                ...List.generate(12, (index) {
                  final angle = (index * 30.0) * (math.pi / 180);
                  return Positioned(
                    left: 40 + (radius * math.cos(angle)),
                    top: 40 + (radius * math.sin(angle)),
                    child: Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFffd700).withOpacity(opacity),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFffd700).withOpacity(opacity * 0.5),
                            blurRadius: 2,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }
      },
    );
  }
}

// Continuous Confetti Widget
class _ContinuousConfetti extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;
  final Duration delay;
  final bool isMobile;

  const _ContinuousConfetti({
    required this.color,
    required this.size,
    required this.duration,
    required this.delay,
    required this.isMobile,
  });

  @override
  State<_ContinuousConfetti> createState() => _ContinuousConfettiState();
}

class _ContinuousConfettiState extends State<_ContinuousConfetti>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -20,
      end: widget.isMobile ? 280 : 360,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    // Start with delay, then repeat
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.4),
                  blurRadius: 2,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Continuous Firework Widget (outside the main class)
class _ContinuousFirework extends StatefulWidget {
  final Color color;
  final Duration delay;

  const _ContinuousFirework({
    required this.color,
    required this.delay,
  });

  @override
  State<_ContinuousFirework> createState() => _ContinuousFireworkState();
}

class _ContinuousFireworkState extends State<_ContinuousFirework>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Start with delay, then repeat
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        
        if (value < 0.1) {
          // Pre-explosion: growing dot
          final size = value * 200; // 0 to 20 pixels
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.8),
                  blurRadius: size / 2,
                  spreadRadius: 2,
                ),
              ],
            ),
          );
        } else {
          // Explosion: radiating particles
          final explosionProgress = (value - 0.1) / 0.9;
          final radius = explosionProgress * 50;
          final opacity = (1 - explosionProgress).clamp(0.0, 1.0);
          
          return SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              children: List.generate(12, (index) {
                final angle = (index * 30.0) * (math.pi / 180);
                return Positioned(
                  left: 50 + (radius * math.cos(angle)),
                  top: 50 + (radius * math.sin(angle)),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(opacity),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(opacity * 0.6),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          );
        }
      },
    );
  }
}

// Back to the main class
extension BeautifulHomeScreenExtension on _BeautifulHomeScreenState {
  // Mobile-optimized layout
  Widget _buildMobileContent(Event placeholderEvent) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gold accent
          Text(
            'MyDscvr\'s Choice',
            style: GoogleFonts.comfortaa(
              fontSize: 16,
              color: const Color(0xFFD4AF37),
              letterSpacing: 1.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Event content - mobile row layout
          Expanded(
            child: Row(
              children: [
                // Compact event image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: placeholderEvent.imageUrls.isNotEmpty
                      ? Image.network(
                          placeholderEvent.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.white.withOpacity(0.2),
                            child: const Icon(Icons.event, color: Colors.white, size: 30),
                          ),
                        )
                      : Container(
                          color: Colors.white.withOpacity(0.2),
                          child: Icon(
                            LucideIcons.sparkles,
                            color: Colors.white.withOpacity(0.9),
                            size: 30,
                          ),
                        ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Event details - clean and elegant
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title with single clean animation
                      Text(
                        placeholderEvent.title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ).animate().fadeIn(duration: 600.ms),
                      
                      const SizedBox(height: 8),
                      
                      // Date and location - clean icons
                      Row(
                        children: [
                          Icon(
                            LucideIcons.calendar,
                            size: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatEventTime(placeholderEvent.startDate),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.9),
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
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              placeholderEvent.venue.area,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // AI insight badge - mobile version
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.zap,
                              size: 10,
                              color: const Color(0xFFD4AF37),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'AI Curated',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
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
      ),
    );
  }

  // Desktop/tablet content (existing layout with responsive adjustments)
  Widget _buildDesktopContent(Event placeholderEvent, bool isTablet) {
    final imageWidth = isTablet ? 140.0 : 160.0;
    final imageHeight = isTablet ? 240.0 : 320.0;
    final contentPadding = isTablet ? 24.0 : 30.0;
    
    return Row(
      children: [
        // Image section - simplified but elegant
        Container(
          width: imageWidth,
          height: imageHeight,
          margin: EdgeInsets.all(contentPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withOpacity(0.1),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: placeholderEvent.imageUrls.isNotEmpty
              ? Image.network(
                  placeholderEvent.imageUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.white.withOpacity(0.2),
                    child: Icon(Icons.event, color: Colors.white, size: isTablet ? 50 : 60),
                  ),
                )
              : Container(
                  color: Colors.white.withOpacity(0.2),
                  child: Icon(
                    LucideIcons.sparkles,
                    color: Colors.white.withOpacity(0.9),
                    size: isTablet ? 40 : 50,
                  ).animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 3000.ms, color: const Color(0xFFD4AF37).withOpacity(0.6)),
                ),
          ),
        ),
        
        // Event details - clean and elegant
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header with gold accent
                Text(
                  'MyDscvr\'s Choice',
                  style: GoogleFonts.comfortaa(
                    fontSize: isTablet ? 16 : 18,
                    color: const Color(0xFFD4AF37),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: isTablet ? 8 : 12),
                
                // Title with single clean animation
                Text(
                  placeholderEvent.title,
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ).animate().fadeIn(duration: 600.ms),
                
                SizedBox(height: isTablet ? 12 : 16),
                
                // Date and location - clean icons
                Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: isTablet ? 12 : 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    SizedBox(width: isTablet ? 4 : 6),
                    Text(
                      _formatEventTime(placeholderEvent.startDate),
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 11 : 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: isTablet ? 6 : 8),
                
                Row(
                  children: [
                    Icon(
                      LucideIcons.mapPin,
                      size: isTablet ? 12 : 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    SizedBox(width: isTablet ? 4 : 6),
                    Expanded(
                      child: Text(
                        placeholderEvent.venue.area,
                        style: GoogleFonts.inter(
                          fontSize: isTablet ? 11 : 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: isTablet ? 12 : 16),
                
                // AI insight badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 10 : 12,
                    vertical: isTablet ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.zap,
                        size: isTablet ? 10 : 12,
                        color: const Color(0xFFD4AF37),
                      ),
                      SizedBox(width: isTablet ? 3 : 4),
                      Text(
                        'AI Curated',
                        style: GoogleFonts.inter(
                          fontSize: isTablet ? 10 : 11,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedMyDscvrChoiceLoading() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth <= 600;
        final isTablet = screenWidth > 600 && screenWidth <= 900;
        
        // Responsive dimensions
        final horizontalMargin = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
        final verticalMargin = isMobile ? 16.0 : 32.0;
        final borderRadius = isMobile ? 20.0 : 32.0;
        
        // Responsive heights
        final containerHeight = isMobile ? 180.0 : (isTablet ? 260.0 : 380.0);
        
        return Container(
          margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: verticalMargin),
          height: containerHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade200,
                Colors.grey.shade300,
              ],
            ),
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

  Widget _buildAnimatedMyDscvrChoiceEmpty() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth <= 600;
        final isTablet = screenWidth > 600 && screenWidth <= 900;
        
        // Responsive dimensions
        final horizontalMargin = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
        final verticalMargin = isMobile ? 16.0 : 32.0;
        final borderRadius = isMobile ? 20.0 : 32.0;
        
        // Responsive heights
        final containerHeight = isMobile ? 180.0 : (isTablet ? 260.0 : 380.0);
        
        return Container(
          margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: verticalMargin),
          height: containerHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF17A2B8),
                Color(0xFF6C5CE7),
                Color(0xFF17A2B8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.sparkles,
                  color: Colors.white.withOpacity(0.7),
                  size: isMobile ? 32 : 48,
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  'MyDscvr\'s Choice',
                  style: GoogleFonts.comfortaa(
                    fontSize: isMobile ? 18 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isMobile ? 6 : 8),
                Text(
                  'Coming Soon',
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 12 : 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatEventTime(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference <= 7) return 'This week';
    if (difference <= 14) return 'Next week';
    return 'Later this month';
  }

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

  /// Build the "Explore All Events" CTA button section
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
}

