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

/// Beautiful homepage with working animations
class BeautifulHomeScreen extends ConsumerStatefulWidget {
  const BeautifulHomeScreen({super.key});

  @override
  ConsumerState<BeautifulHomeScreen> createState() => _BeautifulHomeScreenState();
}

class _BeautifulHomeScreenState extends ConsumerState<BeautifulHomeScreen> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
          
          // MyDscvr's Choice Section
          SliverToBoxAdapter(
            child: FadeInSlideUp(
              delay: const Duration(milliseconds: 1200),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MyDscvr\'s Choice',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const FeaturedEventsSection(
                      showHeader: false,
                      maxEventsToShow: 4,
                    ),
                  ],
                ),
              ),
            ),
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
}