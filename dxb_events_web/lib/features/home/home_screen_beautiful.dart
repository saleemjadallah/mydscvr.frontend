import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Import actual built components
import '../../widgets/home/home_search_widget_simple.dart';
import '../../widgets/home/interactive_category_explorer.dart';
import '../../widgets/featured_events_section_riverpod.dart';
import '../../widgets/home/weekend_highlights.dart';
import '../../widgets/home/smart_trending_section.dart';
import '../../widgets/home/hidden_gem_card.dart';
import '../../core/animations/animations.dart';

/// Beautiful homepage with working animations
class BeautifulHomeScreen extends ConsumerStatefulWidget {
  const BeautifulHomeScreen({super.key});

  @override
  ConsumerState<BeautifulHomeScreen> createState() => _BeautifulHomeScreenState();
}

class _BeautifulHomeScreenState extends ConsumerState<BeautifulHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Beautiful Animated App Bar
          SliverAppBar(
            expandedHeight: 260,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'MyDscvr',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 1000.ms),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF1E293B),
                      Color(0xFF334155),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Animated Background Pattern
                    Positioned.fill(
                      child: CustomPaint(
                        painter: AnimatedPatternPainter(),
                      ),
                    ),
                    // Center Icon
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.explore,
                            size: 80,
                            color: Colors.white70,
                          ).animate()
                            .scale(duration: 600.ms)
                            .then()
                            .shimmer(duration: 1200.ms, color: Colors.white24),
                          const SizedBox(height: 16),
                          Text(
                            'Discover Amazing Events',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                            ),
                          ).animate().fadeIn(delay: 300.ms, duration: 800.ms),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Hero Section with Animations
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to Dubai\'s Premier',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      color: const Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().slideX(duration: 600.ms),
                  
                  Text(
                    'Event Discovery Platform',
                    style: GoogleFonts.inter(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().slideX(duration: 600.ms, delay: 100.ms),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Find concerts, exhibitions, sports events, and more happening around you',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                  
                  const SizedBox(height: 32),
                  
                  // Beautiful Search Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Search feature coming soon!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Search Events'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ).animate()
                    .scale(duration: 400.ms, delay: 400.ms)
                    .then()
                    .shimmer(duration: 1200.ms, color: Colors.white24),
                ],
              ),
            ),
          ),
          
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
              child: _buildMyDscvrChoice(),
            ),
          ),
          
          // Call to Action Section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 48,
                    color: Colors.white,
                  ).animate()
                    .scale(duration: 600.ms)
                    .then()
                    .shimmer(duration: 1200.ms),
                  const SizedBox(height: 16),
                  Text(
                    'Don\'t Miss Out!',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join thousands discovering amazing events daily',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate()
              .slideY(begin: 0.3, duration: 600.ms)
              .fadeIn(duration: 600.ms),
          ),
          
          // Footer
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
              ),
              child: Column(
                children: [
                  Text(
                    'MyDscvr',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2024 MyDscvr. Discover Dubai Events.',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // MyDscvr's Choice Section (Placeholder until component is built)
  Widget _buildMyDscvrChoice() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                'MyDscvr\'s Choice',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star, color: Colors.amber, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Coming Soon',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our curated picks will appear here',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}

// Animated Background Pattern Painter
class AnimatedPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final x = (size.width / 5) * i + size.width / 10;
      final y = size.height / 2;
      canvas.drawCircle(Offset(x, y), 30 + i * 10, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}