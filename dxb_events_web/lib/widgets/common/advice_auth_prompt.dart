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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    
    return Container(
      margin: EdgeInsets.all(isMobile ? 8 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1), // Purple
            Color(0xFF8B5CF6), // Purple gradient
          ],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: isMobile ? 12 : 20,
            offset: Offset(0, isMobile ? 4 : 8),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with gradient background - smaller on mobile
            Container(
              width: isMobile ? 60 : 80,
              height: isMobile ? 60 : 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4ECDC4), // Teal
                    Color(0xFF44A08D), // Darker teal
                  ],
                ),
                borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withOpacity(0.4),
                    blurRadius: isMobile ? 12 : 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: isMobile ? 30 : 40,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: isMobile ? 16 : 24),
            
            // Title - responsive font size
            Text(
              'Share Your Experience',
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: isMobile ? 8 : 12),
            
            // Description - shorter text on mobile
            Text(
              isMobile 
                  ? 'Help other families with your tips! Sign in to share your advice.'
                  : 'Help other families by sharing your tips and advice about this event. Sign in to contribute to the MyDscvr community!',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: isMobile ? 20 : 32),
            
            // Benefits list - stacked on mobile for better readability
            if (isMobile)
              Column(
                children: [
                  _buildMobileBenefit(Icons.stars_rounded, 'Get helpful insights'),
                  const SizedBox(height: 12),
                  _buildMobileBenefit(Icons.family_restroom_rounded, 'Help other families'),
                  const SizedBox(height: 12),
                  _buildMobileBenefit(Icons.thumb_up_rounded, 'Build your reputation'),
                ],
              )
            else
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
            
            SizedBox(height: isMobile ? 20 : 32),
            
            // Action buttons
            Column(
              children: [
                // Sign In Button - responsive sizing
                SizedBox(
                  width: double.infinity,
                  height: isMobile ? 48 : 56,
                  child: ElevatedButton(
                    onPressed: onSignInPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ECDC4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_rounded, size: isMobile ? 18 : 20),
                        const SizedBox(width: 8),
                        Text(
                          isMobile ? 'Sign In to Share' : 'Sign In to Share Advice',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: isMobile ? 8 : 12),
                
                // Sign Up text
                if (onSignUpPressed != null)
                  TextButton(
                    onPressed: onSignUpPressed,
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isMobile ? 12 : 14,
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

  Widget _buildMobileBenefit(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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