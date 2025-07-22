import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    // Company information
    const String companyName = "MyDscvr";
    final int currentYear = DateTime.now().year;
    
    // Useful links - customize these as needed
    final List<Map<String, String>> usefulLinks = [
      {"name": "Home", "url": "/"},
      {"name": "All Events", "url": "/events"},
      {"name": "Categories", "url": "/events"},
      {"name": "About Us", "url": "/about"},
      {"name": "Contact", "url": "/contact"},
    ];
    
    // Legal links
    final List<Map<String, String>> legalLinks = [
      {"name": "Terms & Conditions", "url": "/terms"},
      {"name": "Privacy Policy", "url": "/privacy"},
      {"name": "Cookies Policy", "url": "/cookies"},
    ];

    return Container(
      width: double.infinity,
      color: AppColors.textPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
      child: Center(
        child: Container(
          width: 1200,
          child: Column(
            children: [
              // Main footer content - Three-column layout
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Info
                  SizedBox(
                    width: 500,
                    child: _buildCompanySection(companyName, currentYear),
                  ),
                  const SizedBox(width: 64),
                  
                  // Useful Links
                  SizedBox(
                    width: 250,
                    child: _buildLinksSection("Useful Links", usefulLinks, context),
                  ),
                  const SizedBox(width: 64),
                  
                  // Legal Links
                  SizedBox(
                    width: 250,
                    child: _buildLinksSection("Legal", legalLinks, context),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // Separator line
              Container(
                height: 1,
                color: Colors.white.withOpacity(0.2),
              ),
              
              const SizedBox(height: 24),
              
              // Bottom copyright row
              Text(
                "© $currentYear $companyName. All rights reserved.",
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanySection(String companyName, int currentYear) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          companyName,
          style: GoogleFonts.comfortaa(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Your trusted companion for discovering amazing family activities and events in Dubai.",
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Making every family moment memorable.",
          style: GoogleFonts.inter(
            color: AppColors.dubaiGold,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactSection(),
      ],
    );
  }

  Widget _buildLinksSection(String title, List<Map<String, String>> links, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.comfortaa(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((link) => _buildFooterLink(link["name"]!, link["url"]!, context)),
      ],
    );
  }

  Widget _buildFooterLink(String name, String url, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Handle navigation
          if (url.startsWith('/')) {
            context.go(url);
          } else {
            // Handle external URLs if needed
            // You can add URL launcher functionality here
          }
        },
        child: Text(
          name,
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Row(
      children: [
        Text(
          "Contact: ",
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: () => _copyToClipboard("support@mydscvr.ai"),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "support@mydscvr.ai",
                  style: GoogleFonts.inter(
                    color: AppColors.dubaiGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.copy,
                  size: 16,
                  color: AppColors.dubaiGold,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }
}