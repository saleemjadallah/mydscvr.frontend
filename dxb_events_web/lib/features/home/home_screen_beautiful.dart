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
import '../../widgets/common/footer.dart';

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
  
  @override
  void initState() {
    super.initState();
    _eventsService = EventsService();
    _scrollController = ScrollController();
    _loadEvents(); // Re-enabled for final solution
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
          
          // MyDscvr's Choice Section - Final solution
          SliverToBoxAdapter(
            child: _buildAnimatedMyDscvrChoice(),
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

  /// Build the FIXED MyDscvr's Choice widget - maintains visual appeal, prevents loops
  Widget _buildAnimatedMyDscvrChoice() {
    print('🎯 FIXED: Building MyDscvr\'s Choice with simplified architecture');
    
    // Show loading state while data is being fetched
    if (_isLoading) {
      return _buildAnimatedMyDscvrChoiceLoading();
    }
    
    // Use first available event as placeholder
    final placeholderEvent = _upcomingEvents.isNotEmpty ? _upcomingEvents.first : null;
    
    if (placeholderEvent == null) {
      return _buildAnimatedMyDscvrChoiceEmpty();
    }
    
    // SOLUTION: Simplified architecture that maintains visual appeal but prevents loops
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: FadeInSlideUp(
        delay: const Duration(milliseconds: 200),
        child: Container(
          height: 380,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
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
              // Reduced but still beautiful shadows
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
            ],
            border: Border.all(
              width: 2,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              // Image section - simplified but elegant
              Container(
                width: 160,
                height: 320,
                margin: const EdgeInsets.all(30),
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
                  child: placeholderEvent.imageUrl.isNotEmpty
                    ? Image.network(
                        placeholderEvent.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white.withOpacity(0.2),
                          child: const Icon(Icons.event, color: Colors.white, size: 60),
                        ),
                      )
                    : Container(
                        color: Colors.white.withOpacity(0.2),
                        child: Icon(
                          LucideIcons.sparkles,
                          color: Colors.white.withOpacity(0.9),
                          size: 50,
                        ).animate(onPlay: (controller) => controller.repeat())
                          .shimmer(duration: 3000.ms, color: const Color(0xFFD4AF37).withOpacity(0.6)),
                      ),
                ),
              ),
              
              // Event details - clean and elegant
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header with gold accent
                      Text(
                        'MyDscvr\'s Choice',
                        style: GoogleFonts.comfortaa(
                          fontSize: 18,
                          color: const Color(0xFFD4AF37),
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Title with single clean animation
                      Text(
                        placeholderEvent.title,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ).animate().fadeIn(duration: 600.ms),
                      
                      const SizedBox(height: 16),
                      
                      // Date and location - clean icons
                      Row(
                        children: [
                          Icon(
                            LucideIcons.calendar,
                            size: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatEventTime(placeholderEvent.startDate),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(
                            LucideIcons.mapPin,
                            size: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 6),
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
                      
                      const SizedBox(height: 16),
                      
                      // AI insight badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
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
                              size: 12,
                              color: const Color(0xFFD4AF37),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Perfect for families like yours',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.9),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // CTA Button - clean design
                      ElevatedButton(
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
                            const Icon(
                              LucideIcons.arrowRight,
                              size: 16,
                            ),
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