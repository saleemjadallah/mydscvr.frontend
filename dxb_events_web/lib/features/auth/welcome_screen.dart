import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

import '../../core/constants/app_colors.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;
  
  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Discover Amazing\nFamily Events! 🎉',
      description: 'Find the perfect activities for your family in Dubai with our AI-powered recommendations',
      icon: LucideIcons.calendar,
      primaryColor: AppColors.dubaiTeal,
      secondaryColor: AppColors.dubaiCoral,
    ),
    OnboardingData(
      title: 'Smart Family\nRecommendations 🤖',
      description: 'Our AI learns your family\'s preferences to suggest events that everyone will love',
      icon: LucideIcons.brain,
      primaryColor: AppColors.dubaiPurple,
      secondaryColor: AppColors.dubaiGold,
    ),
    OnboardingData(
      title: 'Never Miss\nThe Fun! ⏰',
      description: 'Get personalized notifications for events that match your schedule and interests',
      icon: LucideIcons.bell,
      primaryColor: AppColors.dubaiGold,
      secondaryColor: AppColors.dubaiTeal,
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with floating bubbles
          _buildAnimatedBackground(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                _buildSkipButton(),
                
                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) => _buildOnboardingPage(_pages[index]),
                  ),
                ),
                
                // Bottom section
                _buildBottomSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedBackground() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _pages[_currentPage].primaryColor.withOpacity(0.1),
            _pages[_currentPage].secondaryColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Stack(
        children: List.generate(10, (index) => 
          Positioned(
            top: Random().nextDouble() * MediaQuery.of(context).size.height,
            left: Random().nextDouble() * MediaQuery.of(context).size.width,
            child: FloatingBubble(
              size: 20 + Random().nextDouble() * 60,
              color: _pages[_currentPage].primaryColor.withOpacity(0.1),
            ).animate().scale(
              delay: Duration(milliseconds: index * 200),
              duration: const Duration(seconds: 2),
            ).then().moveY(
              begin: 0,
              end: -100,
              duration: const Duration(seconds: 8),
              curve: Curves.easeInOut,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSkipButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.topRight,
        child: TextButton(
          onPressed: () => _skipToLogin(),
          child: Text(
            'Skip',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    ).animate().slideX(
      delay: 200.ms,
      duration: 600.ms,
      begin: 1,
      end: 0,
      curve: Curves.easeOut,
    );
  }
  
  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [data.primaryColor, data.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              data.icon,
              size: 80,
              color: Colors.white,
            ),
          ).animate().scale(
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
          ),
          
          const SizedBox(height: 60),
          
          // Title
          Text(
            data.title,
            style: GoogleFonts.comfortaa(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ).animate().slideY(
            delay: 300.ms,
            duration: 600.ms,
            begin: 1,
            end: 0,
            curve: Curves.easeOut,
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            data.description,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate().slideY(
            delay: 500.ms,
            duration: 600.ms,
            begin: 1,
            end: 0,
            curve: Curves.easeOut,
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index 
                      ? _pages[_currentPage].primaryColor
                      : Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Action buttons
          Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _previousPage(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      side: BorderSide(
                        color: _pages[_currentPage].primaryColor,
                      ),
                    ),
                    child: Text(
                      'Back',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _pages[_currentPage].primaryColor,
                      ),
                    ),
                  ),
                ),
              
              if (_currentPage > 0) const SizedBox(width: 16),
              
              Expanded(
                flex: _currentPage == 0 ? 1 : 2,
                child: ElevatedButton(
                  onPressed: () => _nextPage(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _pages[_currentPage].primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started! 🚀' : 'Next',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }
  
  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  void _skipToLogin() {
    context.go('/login');
  }
  
  void _goToLogin() {
    context.go('/login');
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  
  const OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });
}

// Floating bubble widget
class FloatingBubble extends StatelessWidget {
  final double size;
  final Color color;
  
  const FloatingBubble({
    super.key,
    required this.size,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
} 