import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated welcome icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.sunsetGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.dubaiTeal.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.family_restroom,
              color: Colors.white,
              size: 64,
            ),
          ).animate().scale(
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
          ).then().shimmer(
            duration: const Duration(milliseconds: 1000),
            color: Colors.white.withOpacity(0.3),
          ),
          
          const SizedBox(height: 40),
          
          // Welcome text
          Text(
            'Personalize Your Experience',
            style: GoogleFonts.comfortaa(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms).slideY(
            begin: 20,
            end: 0,
            duration: 500.ms,
            curve: Curves.easeOutQuad,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Let\'s set up your family profile to find the perfect Dubai events for you!',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms).slideY(
            begin: 20,
            end: 0,
            duration: 500.ms,
            curve: Curves.easeOutQuad,
          ),
          
          const SizedBox(height: 40),
          
          // Benefits list
          ..._buildBenefitItems().animate(
            interval: 200.ms,
          ).fadeIn(
            duration: 600.ms,
            curve: Curves.easeOutQuad,
          ).slideX(
            begin: -20,
            end: 0,
            duration: 500.ms,
            curve: Curves.easeOutQuad,
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildBenefitItems() {
    final benefits = [
      {
        'icon': Icons.family_restroom,
        'text': 'Find age-appropriate events',
        'color': AppColors.dubaiTeal,
      },
      {
        'icon': Icons.location_on,
        'text': 'Discover events in your favorite areas',
        'color': AppColors.dubaiCoral,
      },
      {
        'icon': Icons.interests,
        'text': 'Match activities to your family\'s interests',
        'color': AppColors.dubaiGold,
      },
      {
        'icon': Icons.watch_later,
        'text': 'Get personalized recommendations',
        'color': AppColors.dubaiTeal,
      },
    ];
    
    return benefits.asMap().entries.map((entry) {
      final index = entry.key;
      final benefit = entry.value;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (benefit['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (benefit['color'] as Color).withOpacity(0.2),
                ),
              ),
              child: Icon(
                benefit['icon'] as IconData,
                color: benefit['color'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                benefit['text'] as String,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ).animate(delay: Duration(milliseconds: 700 + (index * 150)))
       .fadeIn(duration: 400.ms)
       .slideX(
         begin: -30,
         end: 0,
         duration: 500.ms,
         curve: Curves.easeOutBack,
       );
    }).toList();
  }
}