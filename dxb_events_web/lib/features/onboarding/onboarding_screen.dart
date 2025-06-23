import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../services/providers/auth_provider_mongodb.dart';
import 'onboarding_controller.dart';
import 'steps/welcome_step.dart';
import 'steps/family_setup_step.dart';
import 'steps/interests_step.dart';
import 'steps/location_preferences_step.dart';
import 'steps/budget_schedule_step.dart';
import 'steps/completion_step.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final canProceed = ref.watch(canProceedProvider);
    
    // Update page controller when step changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          onboardingState.currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      
      // Update progress animation
      _progressAnimationController.animateTo(
        (onboardingState.currentStep + 1) / 6,
      );
    });
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (only show if not on completion step)
            if (onboardingState.currentStep < 5)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _handleSkip(ref),
                  child: Text(
                    'Skip for now',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.dubaiTeal,
                    ),
                  ),
                ),
              ),
            
            // Progress bar
            _buildProgressBar(context, onboardingState.currentStep),
            
            // Main content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  WelcomeStep(),
                  FamilySetupStep(),
                  InterestsStep(),
                  LocationPreferencesStep(),
                  BudgetScheduleStep(),
                  CompletionStep(),
                ],
              ),
            ),
            
            // Navigation buttons
            _buildNavigationButtons(context, ref, onboardingState, canProceed),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressBar(BuildContext context, int currentStep) {
    const totalSteps = 5; // Excluding completion screen from progress
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Step indicator text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${currentStep + 1} of 6',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _getStepTitle(currentStep),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dubaiTeal,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress bar
          Stack(
            children: [
              // Background
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              
              // Progress
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Container(
                    height: 8,
                    width: MediaQuery.of(context).size.width * 
                           _progressAnimation.value * 0.9, // 90% of screen width minus padding
                    decoration: BoxDecoration(
                      gradient: AppColors.sunsetGradient,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.dubaiTeal.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              // Step dots
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  final isActive = index <= currentStep;
                  final isCompleted = index < currentStep;
                  
                  return Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isActive 
                          ? AppColors.dubaiTeal 
                          : Colors.grey.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: isActive ? [
                        BoxShadow(
                          color: AppColors.dubaiTeal.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          )
                        : Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive ? Colors.white : AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }
  
  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Welcome';
      case 1:
        return 'Family Setup';
      case 2:
        return 'Interests';
      case 3:
        return 'Locations';
      case 4:
        return 'Preferences';
      case 5:
        return 'Complete';
      default:
        return '';
    }
  }
  
  Widget _buildNavigationButtons(
    BuildContext context, 
    WidgetRef ref, 
    OnboardingState state,
    bool canProceed,
  ) {
    final isLastStep = state.currentStep == 4; // Before completion screen
    final isCompletionStep = state.currentStep == 5; // Completion screen
    final validationMessage = ref.watch(onboardingProvider.notifier).getValidationMessage();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Validation message
          if (validationMessage != null && !canProceed)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      validationMessage,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Navigation buttons
          Row(
            children: [
              // Back button
              if (state.currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref.read(onboardingProvider.notifier).previousStep(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: AppColors.dubaiTeal),
                    ),
                    child: Text(
                      'Back',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dubaiTeal,
                      ),
                    ),
                  ),
                ),
              
              if (state.currentStep > 0) const SizedBox(width: 16),
              
              // Continue/Finish button
              Expanded(
                flex: state.currentStep == 0 ? 1 : 2,
                child: ElevatedButton(
                  onPressed: canProceed ? () => _handleContinue(ref, state) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canProceed ? AppColors.dubaiTeal : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: canProceed ? 4 : 0,
                  ),
                  child: Text(
                    _getButtonText(state.currentStep, isLastStep, isCompletionStep),
                    style: GoogleFonts.inter(
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
  
  String _getButtonText(int currentStep, bool isLastStep, bool isCompletionStep) {
    if (isCompletionStep) {
      return 'Get Started!';
    } else if (isLastStep) {
      return 'Finish Setup';
    } else {
      return 'Continue';
    }
  }
  
  void _handleContinue(WidgetRef ref, OnboardingState state) async {
    final notifier = ref.read(onboardingProvider.notifier);
    final authNotifier = ref.read(authProvider.notifier);
    
    if (state.currentStep == 4) { // Last step before completion
      // Complete onboarding locally
      notifier.completeOnboarding();
      
      // Send onboarding data to backend if user is authenticated
      final authState = ref.read(authProvider);
      print('🔍 Auth state during onboarding completion: ${authState.status}');
      print('🔍 User exists: ${authState.user != null}');
      print('🔍 Access token exists: ${authState.accessToken != null}');
      
      if (authState.status == AuthStatus.authenticated && authState.user != null) {
        try {
          final onboardingData = notifier.toApiFormat();
          print('🔍 Sending onboarding data: ${onboardingData.keys}');
          
          final result = await authNotifier.completeOnboarding(
            familyMembers: onboardingData['family_members'],
            preferences: onboardingData['preferences'],
          );
          
          if (!result) {
            final authError = ref.read(authProvider).error;
            print('❌ Onboarding completion failed: $authError');
            
            // Show error but still proceed to completion screen
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Onboarding data saved locally. ${authError ?? "Sync will happen when connection is restored."}'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          } else {
            print('✅ Onboarding completed successfully!');
          }
        } catch (e) {
          print('❌ Exception during onboarding completion: $e');
          // Continue with local completion even if API fails
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Onboarding completed locally. Error: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        print('❌ User not authenticated, skipping backend sync');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to sync your preferences.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
      
      // Move to completion screen
      notifier.nextStep();
    } else if (state.currentStep == 5) { // Completion screen
      // Navigate to home
      context.go('/home');
    } else {
      notifier.nextStep();
    }
  }
  
  void _handleSkip(WidgetRef ref) {
    // Navigate to home without completing onboarding
    // User can still complete onboarding later from profile menu
    context.go('/home');
  }
}