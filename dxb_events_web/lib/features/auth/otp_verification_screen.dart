import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../services/providers/auth_provider_mongodb.dart';

class OTPVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  
  const OTPVerificationScreen({
    super.key,
    required this.email,
  });
  
  @override
  ConsumerState<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Timer _resendTimer;
  
  int _resendCountdown = 60;
  bool _canResend = false;
  bool _isVerifying = false;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _animationController.forward();
    _pulseController.repeat(reverse: true);
    _startResendTimer();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _resendTimer.cancel();
    
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
  
  void _startResendTimer() {
    _resendCountdown = 60;
    _canResend = false;
    
    _resendTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _resendCountdown > 0) {
        setState(() {
          _resendCountdown = _resendCountdown > 5 ? _resendCountdown - 5 : 0;
        });
        if (_resendCountdown <= 0) {
          setState(() {
            _canResend = true;
          });
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    // Navigate based on onboarding status after verification
    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated && !next.isLoading && next.user != null) {
        // Check if user needs onboarding (new users should complete it automatically)
        if (!next.user!.onboardingCompleted) {
          print('New user detected, redirecting to onboarding...');
          context.go('/onboarding');
        } else {
          print('Existing user, redirecting to home...');
          context.go('/');
        }
      }
    });
    
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Header
                  _buildHeader(),
                  
                  const SizedBox(height: 40),
                  
                  // OTP input section
                  _buildOTPSection(authState),
                  
                  const SizedBox(height: 30),
                  
                  // Verify button
                  _buildVerifyButton(authState),
                  
                  const SizedBox(height: 20),
                  
                  // Resend section
                  _buildResendSection(),
                  
                  const SizedBox(height: 40),
                  
                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F4C75),
            Color(0xFF3282B8),
            Color(0xFF0F4C75),
          ],
        ),
      ),
      child: Stack(
        children: List.generate(6, (index) {
          final random = Random(index);
          return Positioned(
            top: random.nextDouble() * MediaQuery.of(context).size.height,
            left: random.nextDouble() * MediaQuery.of(context).size.width,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.3),
                  child: Container(
                    width: 30 + random.nextDouble() * 50,
                    height: 30 + random.nextDouble() * 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ).animate().slideY(
              delay: Duration(milliseconds: index * 400),
              duration: const Duration(seconds: 2),
              begin: 1,
              end: 0,
              curve: Curves.easeOut,
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      children: [
        // Email icon with pulse animation
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.1),
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.dubaiTeal, AppColors.dubaiGold],
                  ),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dubaiTeal.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.mail,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            );
          },
        ).animate().slideY(
          delay: 200.ms,
          duration: 800.ms,
          begin: 1,
          end: 0,
          curve: Curves.easeOut,
        ),
        
        const SizedBox(height: 30),
        
        // Title
        Text(
          'Check Your Email! 📧',
          style: GoogleFonts.comfortaa(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ).animate().slideY(
          delay: 400.ms,
          duration: 600.ms,
          begin: 1,
          end: 0,
          curve: Curves.easeOut,
        ),
        
        const SizedBox(height: 16),
        
        // Subtitle
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'We\'ve sent a 6-digit verification code to\n'),
              TextSpan(
                text: widget.email,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.dubaiGold,
                ),
              ),
            ],
          ),
        ).animate().slideY(
          delay: 600.ms,
          duration: 600.ms,
          begin: 1,
          end: 0,
          curve: Curves.easeOut,
        ),
      ],
    );
  }
  
  Widget _buildOTPSection(AuthState authState) {
    return GlassCard(
      blur: 20,
      opacity: 0.2,
      child: Column(
        children: [
          Text(
            'Enter Verification Code',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // OTP input fields
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) => _buildOTPField(index)),
          ),
          
          // Error message
          if (authState.error != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.alertCircle, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authState.error!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().slideY(
      delay: 800.ms,
      duration: 600.ms,
      begin: 1,
      end: 0,
      curve: Curves.easeOut,
    );
  }
  
  Widget _buildOTPField(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNodes[index].hasFocus 
              ? AppColors.dubaiGold 
              : Colors.white.withOpacity(0.3),
          width: 2,
        ),
        color: Colors.black.withOpacity(0.3), // Changed from white to black for better contrast
      ),
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        autofocus: index == 0,  // Auto-focus first field
        enableInteractiveSelection: false,  // Disable text selection
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black, // Changed to black for maximum visibility
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
        cursorColor: Colors.black,  // Make cursor visible
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          print('OTP Field $index value: $value');  // Debug log
          
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            // Handle backspace
            _focusNodes[index - 1].requestFocus();
          }
          
          // Debug: Print full OTP
          final fullOTP = _getAllOTP();
          print('Full OTP: $fullOTP (length: ${fullOTP.length})');
          
          // Auto-verify when all fields are filled
          if (fullOTP.length == 6) {
            _handleVerifyOTP();
          }
        },
      ),
    );
  }
  
  Widget _buildVerifyButton(AuthState authState) {
    final isOTPComplete = _getAllOTP().length == 6;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: authState.isLoading || !isOTPComplete ? null : _handleVerifyOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dubaiGold,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 8,
          shadowColor: AppColors.dubaiGold.withOpacity(0.4),
        ),
        child: authState.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Verify & Continue',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    ).animate().slideY(
      delay: 1000.ms,
      duration: 600.ms,
      begin: 1,
      end: 0,
      curve: Curves.easeOut,
    );
  }
  
  Widget _buildResendSection() {
    return Column(
      children: [
        if (!_canResend) ...[
          Text(
            'Didn\'t receive the code?',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Resend in $_resendCountdown seconds',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.dubaiGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ] else ...[
          Text(
            'Didn\'t receive the code?',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _handleResendOTP,
            child: Text(
              'Resend Code',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.dubaiGold,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ],
    ).animate().slideY(
      delay: 1200.ms,
      duration: 600.ms,
      begin: 1,
      end: 0,
      curve: Curves.easeOut,
    );
  }
  
  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Secure Verification',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.shield,
              size: 16,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              'Your account security is our priority',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    ).animate().slideY(
      delay: 1400.ms,
      duration: 600.ms,
      begin: 1,
      end: 0,
      curve: Curves.easeOut,
    );
  }
  
  String _getAllOTP() {
    return _otpControllers.map((controller) => controller.text).join();
  }
  
  void _clearOTP() {
    for (final controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }
  
  Future<void> _handleVerifyOTP() async {
    final otp = _getAllOTP();
    print('Attempting to verify OTP: $otp (length: ${otp.length})');
    if (otp.length != 6) {
      print('OTP length is not 6, returning');
      return;
    }
    
    print('Sending OTP verification for email: ${widget.email} with OTP: $otp');
    final success = await ref.read(authProvider.notifier).completeRegistration(
      email: widget.email,
      otpCode: otp,
    );
    
    if (success) {
      print('OTP verification successful!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account verified successfully! Welcome to DXB Events! 🎉',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.dubaiTeal,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      print('OTP verification failed');
      final authState = ref.read(authProvider);
      final errorMessage = authState.error ?? 'Verification failed';
      print('Error message: $errorMessage');
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Clear OTP fields on error
      _clearOTP();
    }
  }
  
  Future<void> _handleResendOTP() async {
    final success = await ref.read(authProvider.notifier).resendVerificationCode(
      email: widget.email,
      userName: widget.email.split('@')[0], // Use email prefix as username
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Verification code sent successfully!',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.dubaiTeal,
        ),
      );
      _startResendTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to resend code. Please try again.',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 