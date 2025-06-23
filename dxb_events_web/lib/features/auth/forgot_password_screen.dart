import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../core/widgets/bubble_decoration.dart';
import '../../core/widgets/dubai_app_bar.dart';
import '../../services/providers/auth_provider_mongodb.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  
  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;
  bool _codeSent = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.forgotPassword(_emailController.text.trim());
      
      if (success && mounted) {
        setState(() {
          _codeSent = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reset code sent to ${_emailController.text}',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: AppColors.dubaiTeal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        
        // Navigate to reset password screen with email
        context.go('/reset-password', extra: _emailController.text.trim());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send reset code. Please try again.',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: AppColors.dubaiCoral,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with floating bubbles
          _buildAnimatedBackground(),
          
          // Forgot password form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Header section
                          _buildHeaderSection(),
                          
                          const SizedBox(height: 40),
                          
                          // Form section
                          _buildFormSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Back to login link
                          _buildBackToLoginLink(),
                        ],
                      ),
                    ),
                  ),
                ),
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
            Color(0xFFF8FAFC),
            Color(0xFFE2E8F0),
          ],
        ),
      ),
      child: Stack(
        children: List.generate(8, (index) => 
          Positioned(
            top: Random().nextDouble() * MediaQuery.of(context).size.height,
            left: Random().nextDouble() * MediaQuery.of(context).size.width,
            child: FloatingBubble(
              size: 30 + Random().nextDouble() * 60,
              color: AppColors.dubaiCoral.withOpacity(0.1),
            ).animate().scale(
              delay: Duration(milliseconds: index * 300),
              duration: const Duration(seconds: 3),
            ).then().moveY(
              begin: 0,
              end: -100,
              duration: const Duration(seconds: 6),
              curve: Curves.easeInOut,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeaderSection() {
    return Column(
      children: [
        // Icon with animation
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.dubaiCoral, AppColors.dubaiGold],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.dubaiCoral.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            LucideIcons.keyRound,
            size: 40,
            color: Colors.white,
          ),
        ).animate().scale(delay: 300.ms),
        
        const SizedBox(height: 24),
        
        Text(
          'Forgot Password? 🔐',
          style: GoogleFonts.comfortaa(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ).animate().slideY(
          delay: 500.ms,
          duration: 600.ms,
          begin: 1,
          end: 0,
          curve: Curves.easeOut,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'No worries! Enter your email address\nand we\'ll send you a reset code',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ).animate().slideY(
          delay: 700.ms,
          duration: 600.ms,
          begin: 1,
          end: 0,
          curve: Curves.easeOut,
        ),
      ],
    );
  }
  
  Widget _buildFormSection() {
    return BubbleDecoration(
      borderRadius: 24,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Email field
              _buildCustomTextField(
                controller: _emailController,
                label: 'Email Address',
                icon: LucideIcons.mail,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Send reset code button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendResetCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dubaiCoral,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 8,
                    shadowColor: AppColors.dubaiCoral.withOpacity(0.3),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              LucideIcons.send,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Send Reset Code',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              
              if (_codeSent) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.dubaiTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.dubaiTeal.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.checkCircle,
                        size: 16,
                        color: AppColors.dubaiTeal,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reset code sent! Check your email and follow the link below.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.dubaiTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.dubaiCoral),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.dubaiCoral, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
      ),
    );
  }
  
  Widget _buildBackToLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Remember your password? ',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () {
            context.go('/login');
          },
          child: Text(
            'Sign In',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.dubaiTeal,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}