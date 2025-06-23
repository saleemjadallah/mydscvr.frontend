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

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  
  const ResetPasswordScreen({
    super.key,
    required this.email,
  });
  
  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;
  bool _showPasswordFields = false;
  bool _codeVerified = false;

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
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyCode() async {
    if (_codeController.text.trim().isEmpty) {
      _showError('Please enter the reset code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.verifyResetCode(
        widget.email,
        _codeController.text.trim(),
      );
      
      if (success && mounted) {
        setState(() {
          _codeVerified = true;
          _showPasswordFields = true;
        });
        
        _showSuccess('Code verified! Now enter your new password.');
      }
    } catch (e) {
      if (mounted) {
        _showError('Invalid or expired reset code. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.resetPassword(
        widget.email,
        _passwordController.text.trim(),
        _codeController.text.trim(),
      );
      
      if (success && mounted) {
        _showSuccess('Password reset successfully!');
        
        // Navigate to login after a delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/login');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to reset password. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: AppColors.dubaiCoral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: AppColors.dubaiTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with floating bubbles
          _buildAnimatedBackground(),
          
          // Reset password form
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
              color: AppColors.dubaiGold.withOpacity(0.1),
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
              colors: [AppColors.dubaiGold, AppColors.dubaiTeal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.dubaiGold.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            LucideIcons.shieldCheck,
            size: 40,
            color: Colors.white,
          ),
        ).animate().scale(delay: 300.ms),
        
        const SizedBox(height: 24),
        
        Text(
          'Reset Password 🔒',
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
          _codeVerified 
              ? 'Great! Now create your new password'
              : 'Enter the reset code sent to\n${widget.email}',
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
              // Reset code field
              _buildCustomTextField(
                controller: _codeController,
                label: 'Reset Code',
                icon: LucideIcons.key,
                enabled: !_codeVerified,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              
              if (!_codeVerified) ...[
                const SizedBox(height: 24),
                
                // Verify code button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleVerifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dubaiTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.dubaiTeal.withOpacity(0.3),
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
                                LucideIcons.checkCircle,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Verify Code',
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
              ],
              
              if (_showPasswordFields) ...[
                const SizedBox(height: 16),
                
                // New password field
                _buildCustomTextField(
                  controller: _passwordController,
                  label: 'New Password',
                  icon: LucideIcons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a new password';
                    }
                    if (value!.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Confirm password field
                _buildCustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  icon: LucideIcons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords don\'t match';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Reset password button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dubaiGold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.dubaiGold.withOpacity(0.3),
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
                                LucideIcons.save,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Reset Password',
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
    bool isPassword = false,
    bool enabled = true,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon, 
          color: enabled ? AppColors.dubaiGold : Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.dubaiGold, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        filled: true,
        fillColor: enabled 
            ? Colors.grey.withOpacity(0.05)
            : Colors.grey.withOpacity(0.02),
        counterText: '', // Hide character counter
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