import 'package:flutter/material.dart';

class AdviceAuthPrompt extends StatelessWidget {
  final VoidCallback onSignInPressed;
  final VoidCallback? onSignUpPressed;

  const AdviceAuthPrompt({
    Key? key,
    required this.onSignInPressed,
    this.onSignUpPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1), // Purple
            Color(0xFF8B5CF6), // Purple gradient
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with gradient background
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4ECDC4), // Teal
                    Color(0xFF44A08D), // Darker teal
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            const Text(
              'Share Your Experience',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              'Help other families by sharing your tips and advice about this event. Sign in to contribute to the MyDscvr community!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Benefits list
            Row(
              children: [
                Expanded(
                  child: _buildBenefit(
                    Icons.stars_rounded,
                    'Get helpful\ninsights',
                  ),
                ),
                Expanded(
                  child: _buildBenefit(
                    Icons.family_restroom_rounded,
                    'Help other\nfamilies',
                  ),
                ),
                Expanded(
                  child: _buildBenefit(
                    Icons.thumb_up_rounded,
                    'Build your\nreputation',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Action buttons
            Column(
              children: [
                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onSignInPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ECDC4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Sign In to Share Advice',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Sign Up text
                if (onSignUpPressed != null)
                  TextButton(
                    onPressed: onSignUpPressed,
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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

  Widget _buildBenefit(IconData icon, String text) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Usage in your advice form widget
class AdviceFormWidget extends StatelessWidget {
  final bool isUserAuthenticated;
  final VoidCallback onNavigateToLogin;
  final VoidCallback? onNavigateToSignUp;

  const AdviceFormWidget({
    Key? key,
    required this.isUserAuthenticated,
    required this.onNavigateToLogin,
    this.onNavigateToSignUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isUserAuthenticated) {
      return AdviceAuthPrompt(
        onSignInPressed: onNavigateToLogin,
        onSignUpPressed: onNavigateToSignUp,
      );
    }

    // Return your actual advice form here
    return _buildAdviceForm();
  }

  Widget _buildAdviceForm() {
    // Your existing advice form implementation
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Your advice form fields
          const Text('Advice form goes here'),
        ],
      ),
    );
  }
}

// Alternative compact version for smaller spaces
class CompactAdviceAuthPrompt extends StatelessWidget {
  final VoidCallback onSignInPressed;

  const CompactAdviceAuthPrompt({
    Key? key,
    required this.onSignInPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Share Your Experience',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in to help other families with your advice',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onSignInPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Sign In to Share',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 