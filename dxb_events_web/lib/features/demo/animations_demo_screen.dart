import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Core imports
import '../../core/constants/app_colors.dart';

// Animation imports
import '../../core/animations/animations.dart';

// Data imports
import '../../data/sample_events.dart';
import '../../models/event.dart';

// Widget imports
import '../../core/widgets/glass_morphism.dart';
import '../../core/widgets/curved_container.dart';
import '../../core/widgets/animated_bottom_nav.dart';

class AnimationsDemoScreen extends ConsumerStatefulWidget {
  const AnimationsDemoScreen({super.key});

  @override
  ConsumerState<AnimationsDemoScreen> createState() => _AnimationsDemoScreenState();
}

class _AnimationsDemoScreenState extends ConsumerState<AnimationsDemoScreen>
    with TickerProviderStateMixin {
  
  final ScrollController _scrollController = ScrollController();
  bool _showLoadingDemo = false;
  bool _showErrorDemo = false;
  bool _showSuccessDemo = false;
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Animations Demo',
          style: GoogleFonts.comfortaa(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.dubaiTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ParallaxBackground(
        scrollController: _scrollController,
        backgroundWidget: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.dubaiPurple,
                AppColors.dubaiTeal,
                AppColors.dubaiGold,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              FadeInSlideUp(
                child: _buildSectionHeader(
                  'Phase 7: Performance & Animations',
                  'Interactive showcase of all animation components',
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Basic Animations
              _buildBasicAnimationsSection(),
              
              const SizedBox(height: 40),
              
              // Loading States
              _buildLoadingStatesSection(),
              
              const SizedBox(height: 40),
              
              // Staggered Animations
              _buildStaggeredAnimationsSection(),
              
              const SizedBox(height: 40),
              
              // Morphing Cards
              _buildMorphingCardsSection(),
              
              const SizedBox(height: 40),
              
              // Page Transitions
              _buildPageTransitionsSection(),
              
              const SizedBox(height: 40),
              
              // Parallax Effects
              _buildParallaxSection(),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.comfortaa(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicAnimationsSection() {
    return FadeInSlideUp(
      delay: const Duration(milliseconds: 200),
      child: _buildDemoCard(
        title: '1. Basic Animations',
        subtitle: 'FadeInSlideUp and PulsingButton components',
        child: Column(
          children: [
            // FadeInSlideUp Demo
            const SizedBox(height: 20),
            Text(
              'FadeInSlideUp Animation',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FadeInSlideUp(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.dubaiTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Slides up with fade',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FadeInSlideUp(
                    delay: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.dubaiCoral.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'With staggered delay',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // PulsingButton Demo
            Text(
              'PulsingButton Animation',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PulsingButton(
                  onPressed: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.sunsetGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Tap Me!',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                PulsingButton(
                  pulseColor: AppColors.dubaiGold,
                  onPressed: () {},
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dubaiTeal,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      LucideIcons.heart,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStatesSection() {
    return FadeInSlideUp(
      delay: const Duration(milliseconds: 400),
      child: _buildDemoCard(
        title: '2. Loading States',
        subtitle: 'Shimmer loading and interactive dialogs',
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Shimmer Examples
            Text(
              'Shimmer Loading Components',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            
            const ShimmerEventCard(),
            const SizedBox(height: 12),
            const ShimmerListItem(),
            
            const SizedBox(height: 24),
            
            // Interactive Loading Dialogs
            Text(
              'Interactive Loading States',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 12,
              children: [
                PulsingButton(
                  onPressed: () async {
                    setState(() => _showLoadingDemo = true);
                    await Future.delayed(const Duration(seconds: 2));
                    if (mounted) setState(() => _showLoadingDemo = false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.info,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Show Loading',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                PulsingButton(
                  onPressed: () async {
                    setState(() => _showErrorDemo = true);
                    await Future.delayed(const Duration(seconds: 2));
                    if (mounted) setState(() => _showErrorDemo = false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Show Error',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                PulsingButton(
                  onPressed: () async {
                    setState(() => _showSuccessDemo = true);
                    await Future.delayed(const Duration(seconds: 2));
                    if (mounted) setState(() => _showSuccessDemo = false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Show Success',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Loading state overlays
            if (_showLoadingDemo) const AnimatedLoadingScreen(),
            if (_showErrorDemo) 
              AnimatedErrorState(
                message: 'Demo error message',
                onRetry: () => setState(() => _showErrorDemo = false),
              ),
            if (_showSuccessDemo) 
              AnimatedSuccessState(
                message: 'Demo completed successfully!',
                onContinue: () => setState(() => _showSuccessDemo = false),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaggeredAnimationsSection() {
    final demoItems = [
      {'title': 'Adventure Tours', 'icon': LucideIcons.mountain},
      {'title': 'Cultural Events', 'icon': LucideIcons.landmark},
      {'title': 'Food & Dining', 'icon': LucideIcons.utensils},
    ];

    return FadeInSlideUp(
      delay: const Duration(milliseconds: 600),
      child: _buildDemoCard(
        title: '3. Staggered Animations',
        subtitle: 'List animations with cascading effects',
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            Text(
              'Staggered List Animation',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            
            Column(
              children: demoItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: FadeInSlideUp(
                    delay: Duration(milliseconds: 100 + (index * 150)),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.dubaiTeal.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.dubaiTeal.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            color: AppColors.dubaiTeal,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item['title'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMorphingCardsSection() {
    final sampleEvent = SampleEvents.sampleEvents.first;
    
    return FadeInSlideUp(
      delay: const Duration(milliseconds: 800),
      child: _buildDemoCard(
        title: '4. Morphing Cards',
        subtitle: 'Smooth expand/collapse transitions',
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            Text(
              'Event Morphing Card',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            
            GestureDetector(
              onTap: () {
                // Handle tap
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sampleEvent.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sampleEvent.venue.area,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
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

  Widget _buildPageTransitionsSection() {
    return FadeInSlideUp(
      delay: const Duration(milliseconds: 1000),
      child: _buildDemoCard(
        title: '5. Page Transitions',
        subtitle: 'Custom route transitions and navigation effects',
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            Text(
              'Transition Types',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTransitionButton('Slide Right', () {
                  Navigator.of(context).push(SlideRightRoute(
                    page: _buildDemoPage('Slide Right Transition'),
                  ));
                }),
                _buildTransitionButton('Slide Up', () {
                  Navigator.of(context).push(SlideUpRoute(
                    page: _buildDemoPage('Slide Up Transition'),
                  ));
                }),
                _buildTransitionButton('Fade', () {
                  Navigator.of(context).push(FadeRoute(
                    page: _buildDemoPage('Fade Transition'),
                  ));
                }),
                _buildTransitionButton('Scale', () {
                  Navigator.of(context).push(ScaleRoute(
                    page: _buildDemoPage('Scale Transition'),
                  ));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParallaxSection() {
    return FadeInSlideUp(
      delay: const Duration(milliseconds: 1200),
      child: _buildDemoCard(
        title: '6. Parallax Effects',
        subtitle: 'Background scroll effects and depth layers',
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            Text(
              'Parallax Container',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.sunsetGradient.scale(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeInSlideUp(
                        child: Text(
                          'Parallax Background',
                          style: GoogleFonts.comfortaa(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeInSlideUp(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          'Scroll to see the effect',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.comfortaa(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildTransitionButton(String label, VoidCallback onPressed) {
    return PulsingButton(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.dubaiTeal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.dubaiTeal.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.dubaiTeal,
          ),
        ),
      ),
    );
  }

  Widget _buildDemoPage(String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.comfortaa(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.dubaiTeal,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.sunsetGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInSlideUp(
                child: Icon(
                  LucideIcons.zap,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              FadeInSlideUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  title,
                  style: GoogleFonts.comfortaa(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              FadeInSlideUp(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  'This demonstrates the custom page transition',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              FadeInSlideUp(
                delay: const Duration(milliseconds: 600),
                child: PulsingButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Go Back',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dubaiTeal,
                      ),
                    ),
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