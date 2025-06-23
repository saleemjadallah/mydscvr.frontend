import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/footer.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.comfortaa(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Policy',
                    style: GoogleFonts.comfortaa(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: ${DateTime.now().year}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildSection(
                    'Information We Collect',
                    'We collect information you provide directly to us, such as when you create an account, make a booking, or contact us for support. This may include your name, email address, phone number, and preferences.',
                  ),
                  
                  _buildSection(
                    'How We Use Your Information',
                    'We use the information we collect to provide, maintain, and improve our services, process bookings, send notifications about events, and communicate with you about our services.',
                  ),
                  
                  _buildSection(
                    'Information Sharing',
                    'We do not sell, trade, or rent your personal information to third parties. We may share your information only in specific circumstances outlined in this policy.',
                  ),
                  
                  _buildSection(
                    'Data Security',
                    'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
                  ),
                  
                  _buildSection(
                    'Your Rights',
                    'You have the right to access, update, or delete your personal information. You can also opt out of certain communications from us.',
                  ),
                  
                  _buildSection(
                    'Contact Us',
                    'If you have any questions or concerns about this privacy policy, please contact us through our website.',
                  ),
                ],
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.comfortaa(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}