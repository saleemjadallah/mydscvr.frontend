import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/footer.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            _buildHeader(isMobile),
            
            // Main Content
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: EdgeInsets.all(isMobile ? 20 : 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Introduction
                    _buildIntroduction(isMobile),
                    
                    const SizedBox(height: 40),
                    
                    // Contact Cards
                    _buildContactCards(isMobile),
                    
                    const SizedBox(height: 40),
                    
                    // Additional Information
                    _buildAdditionalInfo(isMobile),
                  ],
                ),
              ),
            ),

            // Footer
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.dubaiTeal,
            AppColors.dubaiGold,
          ],
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 40,
          vertical: isMobile ? 40 : 60,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.arrowLeft,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Contact Us',
              style: GoogleFonts.comfortaa(
                fontSize: isMobile ? 32 : 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'We\'re here to help you discover amazing family activities in Dubai',
              style: GoogleFonts.inter(
                fontSize: isMobile ? 16 : 20,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroduction(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.dubaiTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.messageCircle,
                  color: AppColors.dubaiTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Get in Touch',
                  style: GoogleFonts.comfortaa(
                    fontSize: isMobile ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Whether you have questions about events, need technical support, or want to discuss business opportunities, we\'re here to help. Choose the best way to reach us below.',
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCards(bool isMobile) {
    return Column(
      children: [
        // Support Email Card
        _buildContactCard(
          icon: LucideIcons.mail,
          iconColor: AppColors.dubaiTeal,
          title: 'Email Support',
          subtitle: 'General inquiries, technical support, and customer service',
          contactInfo: 'support@mydscvr.ai',
          actionText: 'Send Email',
          onTap: () => _sendEmail('support@mydscvr.ai'),
          onCopy: () => _copyToClipboard('support@mydscvr.ai', 'Email copied to clipboard'),
          isMobile: isMobile,
        ),
        
        const SizedBox(height: 20),
        
        // WhatsApp Business Card
        _buildContactCard(
          icon: LucideIcons.messageSquare,
          iconColor: const Color(0xFF25D366), // WhatsApp green
          title: 'Business Enquiries',
          subtitle: 'Partnerships, collaborations, and business opportunities',
          contactInfo: '+971 50 749 3651',
          actionText: 'Chat on WhatsApp',
          onTap: () => _openWhatsApp('+971507493651'),
          onCopy: () => _copyToClipboard('+971507493651', 'Phone number copied to clipboard'),
          isMobile: isMobile,
          showWhatsAppIcon: true,
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String contactInfo,
    required String actionText,
    required VoidCallback onTap,
    required VoidCallback onCopy,
    required bool isMobile,
    bool showWhatsAppIcon = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Contact Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                if (showWhatsAppIcon) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.messageSquare,
                      color: Color(0xFF25D366),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    contactInfo,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                InkWell(
                  onTap:
                   onCopy,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Icon(
                      LucideIcons.copy,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                actionText,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.dubaiTeal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dubaiTeal.withOpacity(0.1)),
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
                child: const Icon(
                  LucideIcons.info,
                  color: AppColors.dubaiTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Additional Information',
                style: GoogleFonts.comfortaa(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoItem('Response Time', 'We typically respond within 24 hours'),
          _buildInfoItem('Languages', 'Arabic, English, Hindi, Tagalog, Urdu'),
          _buildInfoItem('Business Hours', 'Sunday - Thursday: 9 AM - 6 PM (GST)'),
          _buildInfoItem('Company', 'Jasmine Entertainment FZE LLC'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: const BoxDecoration(
              color: AppColors.dubaiTeal,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=MyDscvr Support Inquiry',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showErrorSnackBar('Could not open email app');
    }
  }

  void _openWhatsApp(String phoneNumber) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber?text=Hello! I have a business inquiry regarding MyDscvr.');
    
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackBar('Could not open WhatsApp');
    }
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.dubaiTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
} 