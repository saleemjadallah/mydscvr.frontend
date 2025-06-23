import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../onboarding_controller.dart';

class CompletionStep extends ConsumerWidget {
  const CompletionStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final summary = ref.watch(onboardingProvider.notifier).onboardingSummary;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success animation
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.sunsetGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.dubaiTeal.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 60,
            ),
          ).animate().scale(
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
          ).then().shimmer(
            duration: const Duration(milliseconds: 1500),
            color: Colors.white.withOpacity(0.5),
          ),
          
          const SizedBox(height: 40),
          
          Text(
            'All Set! 🎉',
            style: GoogleFonts.comfortaa(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.dubaiTeal,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms).slideY(
            begin: 20,
            end: 0,
            duration: 500.ms,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Your family profile is ready, and we\'re personalizing your event recommendations.',
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
          ),
          
          const SizedBox(height: 40),
          
          // Profile summary
          _buildProfileSummary(onboardingState, summary).animate().fadeIn(delay: 700.ms).scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
            duration: 500.ms,
          ),
          
          const SizedBox(height: 32),
          
          // What's next section
          _buildWhatsNext().animate().fadeIn(delay: 900.ms).slideY(
            begin: 30,
            end: 0,
            duration: 500.ms,
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileSummary(OnboardingState state, Map<String, dynamic> summary) {
    // Only show if we have family members
    if (state.familyMembers.isEmpty) {
      return const SizedBox();
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.dubaiTeal.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dubaiTeal.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.dubaiTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.family_restroom,
                  color: AppColors.dubaiTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Your Family Profile',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Family members preview
          Row(
            children: [
              ...state.familyMembers.take(4).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final member = entry.value;
                return Container(
                  margin: EdgeInsets.only(
                    right: 8,
                    left: index > 0 ? -12 : 0, // Overlap avatars
                  ),
                  child: _buildAvatarStack(member, index),
                );
              }),
              
              if (state.familyMembers.length > 4)
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(left: -12),
                  decoration: BoxDecoration(
                    color: AppColors.dubaiCoral.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '+${state.familyMembers.length - 4}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dubaiCoral,
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Text(
                  '${state.familyMembers.length} family member${state.familyMembers.length != 1 ? 's' : ''}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Divider
          Container(
            height: 1,
            color: Colors.grey.withOpacity(0.2),
          ),
          
          const SizedBox(height: 20),
          
          // Summary stats
          Column(
            children: [
              _buildSummaryRow(
                Icons.favorite,
                'Interests',
                '${summary['interests']} selected',
                AppColors.dubaiCoral,
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                Icons.location_on,
                'Preferred Areas',
                '${summary['locations']} areas in Dubai',
                AppColors.dubaiTeal,
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                Icons.attach_money,
                'Budget Range',
                summary['budgetRange'] as String,
                AppColors.dubaiGold,
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                Icons.calendar_today,
                'Available Days',
                '${summary['preferredDays']} days per week',
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryRow(IconData icon, String title, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildAvatarStack(FamilyMember member, int index) {
    // Using Dicebear Avatars API for beautiful, diverse avatars
    final avatarUrl = 'https://api.dicebear.com/7.x/avataaars/svg?seed=${member.avatarSeed ?? member.name}';
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.dubaiTeal.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return CircleAvatar(
              backgroundColor: AppColors.dubaiTeal,
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildWhatsNext() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.dubaiTeal.withOpacity(0.05),
            AppColors.dubaiCoral.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dubaiTeal.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'What\'s Next?',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Column(
            children: [
              _buildNextStepItem(
                Icons.explore,
                'Discover Events',
                'Browse personalized recommendations',
                0,
              ),
              _buildNextStepItem(
                Icons.bookmark,
                'Save Favorites',
                'Keep track of events you love',
                100,
              ),
              _buildNextStepItem(
                Icons.family_restroom,
                'Enjoy Together',
                'Create amazing family memories',
                200,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNextStepItem(IconData icon, String title, String description, int delay) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.dubaiTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.dubaiTeal,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: delay))
     .fadeIn(duration: 400.ms)
     .slideX(begin: 20, end: 0);
  }
}