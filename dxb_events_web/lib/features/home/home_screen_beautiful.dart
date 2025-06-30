import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
          
          // Categories Section with Stagger Animation
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Popular Categories',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ).animate().fadeIn(duration: 600.ms),
                      
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All'),
                      ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      _buildAnimatedCategoryCard(
                        'Food & Dining',
                        Icons.restaurant,
                        const Color(0xFFFF6B6B),
                        const Color(0xFFFFE66D),
                        0,
                      ),
                      _buildAnimatedCategoryCard(
                        'Entertainment',
                        Icons.movie,
                        const Color(0xFF845EC2),
                        const Color(0xFFB39CD0),
                        1,
                      ),
                      _buildAnimatedCategoryCard(
                        'Sports & Fitness',
                        Icons.sports_soccer,
                        const Color(0xFF4ECDC4),
                        const Color(0xFF95E1D3),
                        2,
                      ),
                      _buildAnimatedCategoryCard(
                        'Arts & Culture',
                        Icons.palette,
                        const Color(0xFFFF6B9D),
                        const Color(0xFFFECA57),
                        3,
                      ),
                      _buildAnimatedCategoryCard(
                        'Music & Concerts',
                        Icons.music_note,
                        const Color(0xFFA8E6CF),
                        const Color(0xFF7FD1AE),
                        4,
                      ),
                      _buildAnimatedCategoryCard(
                        'Family & Kids',
                        Icons.family_restroom,
                        const Color(0xFFFFD93D),
                        const Color(0xFFF6A192),
                        5,
                      ),
                    ],
                  ),
                ],
              ),
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
  
  Widget _buildAnimatedCategoryCard(
    String title,
    IconData icon,
    Color startColor,
    Color endColor,
    int index,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor.withOpacity(0.1), endColor.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: startColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title category selected'),
                backgroundColor: startColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [startColor, endColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 100))
      .scale(duration: 400.ms, delay: Duration(milliseconds: index * 100));
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