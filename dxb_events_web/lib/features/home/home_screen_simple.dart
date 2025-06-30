import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Simplified beautiful homepage - production ready
class SimpleHomeScreen extends ConsumerWidget {
  const SimpleHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Beautiful App Bar
          SliverAppBar(
            expandedHeight: 200,
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
              ),
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
                child: const Center(
                  child: Icon(
                    Icons.explore,
                    size: 64,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 800.ms),
          
          // Hero Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Discover Dubai Events',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().slideY(begin: 0.3, duration: 600.ms),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Find amazing events happening around you',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().slideY(begin: 0.3, duration: 600.ms, delay: 200.ms),
                  
                  const SizedBox(height: 32),
                  
                  // Search Button
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Search feature coming soon!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Search Events'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ).animate().scale(duration: 400.ms, delay: 400.ms),
                ],
              ),
            ),
          ),
          
          // Categories Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Popular Categories',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildCategoryCard('Food & Dining', Icons.restaurant, Colors.orange),
                      _buildCategoryCard('Entertainment', Icons.movie, Colors.purple),
                      _buildCategoryCard('Sports', Icons.sports_soccer, Colors.green),
                      _buildCategoryCard('Culture', Icons.museum, Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Footer
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.only(top: 32),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
              ),
              child: Text(
                '© 2024 MyDscvr. Discover Dubai Events.',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
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
    ).animate().scale(duration: 400.ms);
  }
}