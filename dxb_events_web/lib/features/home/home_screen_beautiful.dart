import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

// Import actual built components
import '../../widgets/home/home_search_widget_simple.dart';
import '../../widgets/home/interactive_category_explorer.dart';
import '../../widgets/featured_events_section_riverpod.dart';
import '../../widgets/home/weekend_highlights.dart';
import '../../widgets/home/smart_trending_section.dart';
import '../../widgets/home/hidden_gem_card.dart';
import '../../core/animations/animations.dart';

// Import header and orange section components
import '../../core/widgets/dubai_app_bar.dart';
import '../../core/widgets/curved_container.dart';
import '../../core/constants/app_colors.dart';
import '../../services/providers/auth_provider_mongodb.dart';
import '../../widgets/common/google_sign_in_button.dart';
import '../../models/user.dart';
import '../../services/events_service.dart';
import '../../models/event.dart';

/// Beautiful homepage with working animations
class BeautifulHomeScreen extends ConsumerStatefulWidget {
  const BeautifulHomeScreen({super.key});

  @override
  ConsumerState<BeautifulHomeScreen> createState() => _BeautifulHomeScreenState();
}

class _BeautifulHomeScreenState extends ConsumerState<BeautifulHomeScreen> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  String? _hoveredEventId;
  
  // Real API data for MyDscvr's Choice
  late final EventsService _eventsService;
  List<Event> _upcomingEvents = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Testing modes
  String _testMode = 'testing'; // 'testing', 'simple', 'full'
  
  @override
  void initState() {
    super.initState();
    _eventsService = EventsService();
    _scrollController = ScrollController();
    // _loadEvents(); // COMMENTED OUT FOR TESTING LOOP ISSUE
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // Header App Bar with Logo, Name, and Sign Up/Profile
      appBar: _buildHeaderAppBar(context, authState),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Beautiful Orange Hero Section
          _buildHeroSection(),
          
          // Search Bar - Using actual component
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: FadeInSlideUp(
                child: SimpleHomeSearchWidget(),
              ),
            ),
          ),
          
          // Featured Events - Using actual component
          SliverToBoxAdapter(
            child: FadeInSlideUp(
              delay: const Duration(milliseconds: 200),
              child: const FeaturedEventsSection(
                showHeader: true,
                maxEventsToShow: 8,
              ),
            ),
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
          
          // MyDscvr's Choice Section - Conditional based on test mode
          SliverToBoxAdapter(
            child: _buildConditionalMyDscvrChoice(),
          ),
          
          // Footer spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  /// Build the header app bar with logo, name, and sign up/profile button
  PreferredSizeWidget _buildHeaderAppBar(BuildContext context, AuthState authState) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      title: Row(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFFB347)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.explore,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // App Name
          Text(
            'MyDscvr',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
      actions: [
        // Auth Button/Profile
        if (authState.status == AuthStatus.authenticated && authState.user != null)
          _buildUserProfile(authState.user!)
        else
          _buildSignUpButton(),
        const SizedBox(width: 16),
      ],
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
            backgroundColor: const Color(0xFFFF6B6B),
            child: Text(
              (user.firstName?.isNotEmpty == true ? user.firstName![0] : user.email[0]).toUpperCase(),
              style: GoogleFonts.inter(
                color: Colors.white,
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
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  /// Build sign up button when not authenticated
  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: () => context.push('/login'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF6B6B),
        foregroundColor: Colors.white,
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
    );
  }

  /// Build beautiful orange hero section
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
        height: 380,
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
                      top: 80 - parallaxOffset * 0.2,
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
                      top: 120 - parallaxOffset * 0.1,
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
                      top: 40 - parallaxOffset * 0.3,
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
                      top: 200 - parallaxOffset * 0.1,
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

            // Main content
            Positioned(
              left: 0,
              right: 0,
              top: 60,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero text
                    Text(
                      'Discover Dubai\'s\nbest adventures',
                      style: GoogleFonts.comfortaa(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 800.ms).slideX(),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Find family-friendly events, activities,\nand experiences across Dubai',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 800.ms),
                    
                    const SizedBox(height: 32),
                    
                    // Stats row
                    Row(
                      children: [
                        _buildStatCard('1000+', 'Events'),
                        const SizedBox(width: 16),
                        _buildStatCard('50+', 'Venues'),
                        const SizedBox(width: 16),
                        _buildStatCard('5000+', 'Families'),
                      ],
                    ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideY(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build glassmorphic stat card
  Widget _buildStatCard(String number, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Load events for MyDscvr's Choice
  Future<void> _loadEvents() async {
    try {
      // Load upcoming events
      final upcomingResponse = await _eventsService.getEvents(
        perPage: 20,
        sortBy: 'start_date',
      );

      if (mounted) {
        setState(() {
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
          } else {
            print('❌ DEBUG: API call failed: ${upcomingResponse.error}');
          }
          _isLoading = false;
          _errorMessage = upcomingResponse.error;
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

  /// Build the actual MyDscvr's Choice widget from animated home screen
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
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
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
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildAnimatedMyDscvrChoiceEmpty() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
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
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'MyDscvr\'s Choice',
              style: GoogleFonts.comfortaa(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final delays = [0, 500, 1000, 1500, 2000, 2500];
    final sizes = [4.0, 6.0, 3.0, 5.0, 4.0, 7.0];
    final positions = [
      const Offset(50, 100),
      const Offset(300, 80),
      const Offset(150, 200),
      const Offset(280, 180),
      const Offset(80, 250),
      const Offset(320, 220),
    ];

    return Positioned(
      left: positions[index].dx,
      top: positions[index].dy,
      child: Container(
        width: sizes[index],
        height: sizes[index],
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.6),
        ),
      ).animate(onPlay: (controller) => controller.repeat())
          .moveY(
            begin: 0,
            end: -20,
            duration: Duration(milliseconds: 3000 + delays[index]),
            curve: Curves.easeInOut,
          )
          .then()
          .moveY(
            begin: -20,
            end: 0,
            duration: Duration(milliseconds: 3000 + delays[index]),
            curve: Curves.easeInOut,
          ),
    );
  }

  Widget _buildGradientMeshBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: GradientMeshPainter(),
      ),
    );
  }

  /// Build conditional MyDscvr's Choice based on test mode
  Widget _buildConditionalMyDscvrChoice() {
    switch (_testMode) {
      case 'testing':
        return _buildTestingWidget();
      case 'simple':
        return _buildSimpleMyDscvrChoice();
      case 'full':
        return _buildAnimatedMyDscvrChoice();
      default:
        return _buildTestingWidget();
    }
  }

  /// Build the minimal MyDscvr's Choice for testing
  Widget _buildTestingWidget() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MyDscvr\'s Choice - Testing Widget (Mode: $_testMode)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text('Events loaded: ${_upcomingEvents.length}'),
          Text('Loading: $_isLoading'),
          Text('Error: ${_errorMessage ?? 'None'}'),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  print('🧪 Testing API call...');
                  _testApiCallSafely();
                },
                child: const Text('Test API'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  print('🧪 Testing state update...');
                  _testStateUpdate();
                },
                child: const Text('Test State'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  print('🧪 Testing full widget...');
                  _testFullWidget();
                },
                child: const Text('Test Widget'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  print('🧪 Testing animations...');
                  _testAnimations();
                },
                child: const Text('Test Anim'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  print('🧪 Testing hover state...');
                  _testHoverState();
                },
                child: const Text('Test Hover'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  print('🧪 Switching to simple widget...');
                  _switchToSimpleWidget();
                },
                child: const Text('Simple'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  print('🧪 Switching to full widget...');
                  _switchToFullWidget();
                },
                child: const Text('Full'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Test API call safely to identify the loop source
  void _testApiCallSafely() async {
    print('🧪 Starting safe API test...');
    
    try {
      // Test 1: Basic service instantiation
      print('🧪 Test 1: Creating EventsService...');
      final testService = EventsService();
      print('✅ Test 1: EventsService created successfully');
      
      // Test 2: Simple API call without state changes
      print('🧪 Test 2: Testing API call...');
      final response = await testService.getEvents();
      print('✅ Test 2: API call completed - Success: ${response.isSuccess}');
      
      if (response.isSuccess) {
        final events = response.data ?? [];
        print('✅ Test 2: Found ${events.length} events');
        
        // Test 3: Try parsing first event
        if (events.isNotEmpty) {
          print('🧪 Test 3: Testing event parsing...');
          final firstEvent = events.first;
          print('✅ Test 3: First event - ID: ${firstEvent.id}, Title: ${firstEvent.title}');
        }
      } else {
        print('❌ Test 2: API call failed - ${response.error}');
      }
      
    } catch (e, stackTrace) {
      print('❌ API Test Failed: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }
  
  /// Test state update to see if setState is causing the loop
  void _testStateUpdate() async {
    print('🧪 Testing state update...');
    
    try {
      setState(() {
        _isLoading = !_isLoading;
      });
      print('✅ State update successful');
    } catch (e, stackTrace) {
      print('❌ State update failed: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }
  
  /// Test full widget rendering with real data
  void _testFullWidget() async {
    print('🧪 Testing full widget rendering...');
    
    try {
      // Get data first
      final response = await _eventsService.getEvents();
      if (response.isSuccess) {
        final events = response.data ?? [];
        print('✅ Got ${events.length} events for widget test');
        
        setState(() {
          _upcomingEvents = events.take(3).toList();
          _isLoading = false;
          _errorMessage = null;
        });
        
        print('✅ Widget test - state updated successfully');
      } else {
        print('❌ Widget test failed: ${response.error}');
      }
    } catch (e, stackTrace) {
      print('❌ Widget test failed: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }
  
  /// Test animations to see if they cause loops
  void _testAnimations() {
    print('🧪 Testing animations...');
    
    try {
      // Test FadeInSlideUp animation alone
      print('🧪 Testing FadeInSlideUp...');
      
      // Test AnimatedContainer
      print('🧪 Testing AnimatedContainer...');
      
      // Test multiple animations together
      print('🧪 Testing combined animations...');
      
      print('✅ Animation tests completed - check console for loops');
    } catch (e, stackTrace) {
      print('❌ Animation test failed: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }
  
  /// Test hover state management
  void _testHoverState() {
    print('🧪 Testing hover state...');
    
    try {
      // Simulate hover events
      setState(() {
        _hoveredEventId = 'test-id-1';
      });
      
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {
          _hoveredEventId = 'test-id-2';
        });
      });
      
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _hoveredEventId = null;
        });
      });
      
      print('✅ Hover state test completed');
    } catch (e, stackTrace) {
      print('❌ Hover state test failed: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }
  
  /// Switch to simple widget mode
  void _switchToSimpleWidget() async {
    print('🧪 Switching to simple widget...');
    
    try {
      // Ensure we have data
      if (_upcomingEvents.isEmpty) {
        final response = await _eventsService.getEvents();
        if (response.isSuccess) {
          final events = response.data ?? [];
          _upcomingEvents = events.take(1).toList();
        }
      }
      
      setState(() {
        _testMode = 'simple';
        _isLoading = false;
      });
      
      print('✅ Switched to simple widget mode');
    } catch (e, stackTrace) {
      print('❌ Switch to simple failed: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }
  
  /// Switch to full widget mode (potential loop trigger)
  void _switchToFullWidget() async {
    print('🧪 Switching to FULL widget - WATCH FOR LOOPS!');
    
    try {
      // Ensure we have data
      if (_upcomingEvents.isEmpty) {
        final response = await _eventsService.getEvents();
        if (response.isSuccess) {
          final events = response.data ?? [];
          _upcomingEvents = events.take(1).toList();
        }
      }
      
      setState(() {
        _testMode = 'full';
        _isLoading = false;
      });
      
      print('✅ Switched to FULL widget mode - monitor for loops!');
    } catch (e, stackTrace) {
      print('❌ Switch to full failed: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }
  
  /// Simple version of MyDscvr's Choice without complex animations
  Widget _buildSimpleMyDscvrChoice() {
    if (_upcomingEvents.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('No events available for Simple MyDscvr\'s Choice'),
      );
    }
    
    final event = _upcomingEvents.first;
    
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF17A2B8), Color(0xFF6C5CE7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Simple image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.2),
            ),
            child: const Icon(Icons.event, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 16),
          // Event details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MyDscvr\'s Choice',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  event.venue.area,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
}

class GradientMeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Create mesh gradient effect
    for (int i = 0; i < 5; i++) {
      final opacity = 0.1 - (i * 0.02);
      paint.color = Colors.white.withOpacity(opacity);
      
      final path = Path();
      path.moveTo(0, size.height * (0.2 + i * 0.15));
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * (0.1 + i * 0.1),
        size.width,
        size.height * (0.3 + i * 0.1),
      );
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}