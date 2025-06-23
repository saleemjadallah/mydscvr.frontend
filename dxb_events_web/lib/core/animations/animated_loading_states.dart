import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animate_do/animate_do.dart';
import '../animations/animations.dart';
import '../constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// Animated loading screen with Lottie animation
class AnimatedLoadingScreen extends StatelessWidget {
  final String? message;
  final String? lottieAsset;
  
  const AnimatedLoadingScreen({
    super.key,
    this.message,
    this.lottieAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation or fallback
            if (lottieAsset != null)
              SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset(
                  lottieAsset!,
                  repeat: true,
                  animate: true,
                ),
              )
            else
              SpinPerfect(
                infinite: true,
                duration: const Duration(seconds: 2),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.sunsetGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Loading message
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Text(
                message ?? 'Loading amazing events...',
                style: GoogleFonts.comfortaa(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Progress indicator
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: SizedBox(
                width: 150,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.dubaiTeal.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.dubaiTeal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pull to refresh with custom animation
class AnimatedRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  
  const AnimatedRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? AppColors.dubaiTeal,
      backgroundColor: Colors.white,
      strokeWidth: 3,
      displacement: 60,
      child: child,
    );
  }
}

/// Empty state with animation
class AnimatedEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  
  const AnimatedEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon
            BounceInDown(
              duration: const Duration(milliseconds: 1000),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.dubaiTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 60,
                  color: AppColors.dubaiTeal,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Text(
                title,
                style: GoogleFonts.comfortaa(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            
            if (onAction != null) ...[
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: PulsingButton(
                  onPressed: onAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.sunsetGradient,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      actionLabel ?? 'Try Again',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with animation
class AnimatedErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const AnimatedErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon with shake animation
            ShakeX(
              duration: const Duration(milliseconds: 1000),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.dubaiCoral.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 50,
                  color: AppColors.dubaiCoral,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Error message
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Text(
                'Oops! Something went wrong',
                style: GoogleFonts.comfortaa(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: PulsingButton(
                  onPressed: onRetry,
                  pulseColor: AppColors.dubaiCoral,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dubaiCoral,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Success state with celebration animation
class AnimatedSuccessState extends StatelessWidget {
  final String message;
  final VoidCallback? onContinue;
  final String? continueLabel;
  
  const AnimatedSuccessState({
    super.key,
    required this.message,
    this.onContinue,
    this.continueLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success icon with zoom animation
            ZoomIn(
              duration: const Duration(milliseconds: 800),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.forestGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Success message
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Text(
                'Success!',
                style: GoogleFonts.comfortaa(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            if (onContinue != null) ...[
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: PulsingButton(
                  onPressed: onContinue,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.forestGradient,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Text(
                      continueLabel ?? 'Continue',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 