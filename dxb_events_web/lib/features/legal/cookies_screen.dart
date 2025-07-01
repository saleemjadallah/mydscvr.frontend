import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class CookiesScreen extends StatefulWidget {
  const CookiesScreen({Key? key}) : super(key: key);

  @override
  _CookiesScreenState createState() => _CookiesScreenState();
}

class _CookiesScreenState extends State<CookiesScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(13, (index) => GlobalKey());

  void _scrollToSection(int index) {
    final context = _sectionKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.dubaiTeal.withOpacity(0.9),
                    AppColors.dubaiGold.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Navigation Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => context.go('/'),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'MyDscvr.ai',
                          style: GoogleFonts.comfortaa(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Header Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 60),
                    child: Column(
                      children: [
                        Text(
                          'Cookies Policy',
                          style: GoogleFonts.comfortaa(
                            fontSize: isMobile ? 32 : 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Understanding How We Use Cookies and Similar Technologies',
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 16 : 20,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildHeaderInfo('Effective Date', 'June 23, 2025'),
                                  Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                                  _buildHeaderInfo('Last Updated', 'June 25, 2025'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Operated by: Jasmine Entertainment FZE LLC | Contact: support@mydscvr.ai',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Container(
              padding: const EdgeInsets.all(40),
              child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTableOfContents(isMobile: true),
        const SizedBox(height: 40),
        _buildContent(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 300,
          child: _buildTableOfContents(isMobile: false),
        ),
        const SizedBox(width: 60),
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildTableOfContents({required bool isMobile}) {
    final sections = [
      '1. Introduction',
      '2. What Are Cookies?',
      '3. Why We Use Cookies',
      '4. Categories of Cookies We Use',
      '5. Third-Party Cookies and Partners',
      '6. Your Cookie Choices and Control',
      '7. UAE Legal Compliance',
      '8. International Transfers and Safeguards',
      '9. Data Retention and Deletion',
      '10. Updates to This Policy',
      '11. Contact Us',
      '12. Cookie Categories Summary Table',
      '13. Your Rights Regarding Cookies',
    ];

    if (isMobile) {
      return ExpansionTile(
        title: Text(
          'Table of Contents',
          style: GoogleFonts.comfortaa(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.dubaiTeal,
          ),
        ),
        children: sections.asMap().entries.map((entry) {
          return ListTile(
            title: Text(
              entry.value,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            onTap: () => _scrollToSection(entry.key),
          );
        }).toList(),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Table of Contents',
            style: GoogleFonts.comfortaa(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.dubaiTeal,
            ),
          ),
          const SizedBox(height: 20),
          ...sections.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _scrollToSection(entry.key),
                child: Text(
                  entry.value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[700],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(0, '1. Introduction', _buildIntroductionContent()),
          _buildSection(1, '2. What Are Cookies?', _buildWhatAreCookiesContent()),
          _buildSection(2, '3. Why We Use Cookies', _buildWhyWeUseCookiesContent()),
          _buildSection(3, '4. Categories of Cookies We Use', _buildCategoriesContent()),
          _buildSection(4, '5. Third-Party Cookies and Partners', _buildThirdPartyContent()),
          _buildSection(5, '6. Your Cookie Choices and Control', _buildChoicesContent()),
          _buildSection(6, '7. UAE Legal Compliance', _buildUAEComplianceContent()),
          _buildSection(7, '8. International Transfers and Safeguards', _buildTransfersContent()),
          _buildSection(8, '9. Data Retention and Deletion', _buildRetentionContent()),
          _buildSection(9, '10. Updates to This Policy', _buildUpdatesContent()),
          _buildSection(10, '11. Contact Us', _buildContactContent()),
          _buildSection(11, '12. Cookie Categories Summary Table', _buildSummaryTableContent()),
          _buildSection(12, '13. Your Rights Regarding Cookies', _buildRightsContent()),
        ],
      ),
    );
  }

  Widget _buildSection(int index, String title, Widget content) {
    return Container(
      key: _sectionKeys[index],
      margin: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.comfortaa(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.dubaiTeal,
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildIntroductionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Cookies Policy explains how Jasmine Entertainment FZE LLC ("we," "us," "our," or "Company") uses cookies and similar tracking technologies on the MyDscvr.ai website and mobile applications (collectively, the "Platform") to provide our family-focused events discovery services in Dubai and the UAE.',
          style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.grey[700]),
        ),
        const SizedBox(height: 16),
        Text(
          'This policy should be read together with our Privacy Policy and Terms and Conditions, available at www.mydscvr.ai/privacy-policy and www.mydscvr.ai/terms-conditions respectively.',
          style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.grey[700]),
        ),
        const SizedBox(height: 16),
        Text(
          'By using our Platform, you consent to the use of cookies in accordance with this policy and UAE Federal Decree-Law No. 45 of 2021 on Personal Data Protection (PDPL). You can manage your cookie preferences at any time through our cookie consent center or browser settings.',
          style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildWhatAreCookiesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cookies are small text files that are downloaded and stored on your computer, smartphone, tablet, or other device when you visit our Platform. They contain information that is transferred to your device\'s hard drive and allow us to recognize your device and store some information about your preferences or past actions.',
          style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.grey[700]),
        ),
        const SizedBox(height: 20),
        Text(
          'Types of cookies we use:',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('Session Cookies: Temporary cookies that are deleted when you close your browser'),
        _buildBulletPoint('Persistent Cookies: Cookies that remain on your device for a specified period or until you delete them'),
        _buildBulletPoint('First-Party Cookies: Cookies set directly by MyDscvr.ai'),
        _buildBulletPoint('Third-Party Cookies: Cookies set by our partners and service providers'),
        const SizedBox(height: 16),
        Text(
          'Similar Technologies: We also use web beacons, pixels, local storage, and other tracking technologies that function similarly to cookies.',
          style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildWhyWeUseCookiesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'We use cookies and similar technologies to:',
          style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.grey[700]),
        ),
        const SizedBox(height: 20),
        _buildSubsection('3.1 Essential Platform Functionality', [
          'User Authentication: Keep you logged into your family account',
          'Session Management: Maintain your session while browsing events',
          'Security: Protect against fraud and unauthorized access',
          'Basic Functionality: Remember your language preferences and basic settings',
          'Form Data: Preserve information you\'ve entered while navigating the Platform',
        ]),
        _buildSubsection('3.2 Family-Focused Personalization', [
          'Cultural Preferences: Remember dietary requirements (halal, vegetarian, kosher)',
          'Family Composition: Store age ranges and interests for event recommendations',
          'Location Preferences: Remember your preferred Dubai areas and venues',
          'Event History: Track events you\'ve viewed and saved for better recommendations',
          'Accessibility Settings: Remember special needs requirements for your family',
        ]),
        _buildSubsection('3.3 Platform Performance and Analytics', [
          'Usage Analytics: Understand how families use our Platform',
          'Performance Monitoring: Identify and fix technical issues',
          'Feature Effectiveness: Measure which features are most helpful for families',
          'Popular Content: Identify trending events and popular venues',
          'Error Tracking: Monitor and resolve platform errors',
        ]),
        _buildSubsection('3.4 Communication and Marketing (With Consent)', [
          'Targeted Recommendations: Show relevant events based on your family\'s interests',
          'Email Campaign Effectiveness: Measure engagement with our family event newsletters',
          'Social Media Integration: Enable sharing of events with your community',
          'Partner Event Promotion: Show relevant events from our venue and organizer partners',
        ]),
      ],
    );
  }

  Widget _buildCategoriesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCookieCategory(
          '4.1 Strictly Necessary Cookies',
          'Essential for the Platform to function properly',
          'Legitimate interest (cannot be disabled)',
          'Session or up to 12 months',
          [
            'User authentication tokens',
            'Session identifiers',
            'Security and fraud prevention',
            'Load balancing and server allocation',
            'CSRF protection tokens',
            'Basic accessibility settings',
          ],
          'Session IDs, authentication status, security tokens, basic device information',
        ),
        _buildCookieCategory(
          '4.2 Functional Cookies',
          'Enhance your experience and remember your preferences',
          'Consent (can be disabled)',
          'Up to 24 months',
          [
            'Language and region preferences (Arabic, English, Hindi, etc.)',
            'Cultural dietary filters (halal, vegetarian, vegan)',
            'Family composition preferences',
            'Preferred Dubai areas and venues',
            'Accessibility requirements',
            'Communication preferences',
          ],
          'Language settings, location preferences, family settings, accessibility needs',
        ),
        _buildCookieCategory(
          '4.3 Analytics and Performance Cookies',
          'Help us understand how the Platform is used and improve performance',
          'Consent (can be disabled)',
          'Up to 24 months',
          [
            'Google Analytics (with IP anonymization)',
            'Platform usage patterns',
            'Event search analytics',
            'Feature engagement tracking',
            'Error and performance monitoring',
            'A/B testing for platform improvements',
          ],
          'Anonymized usage patterns, popular events, search queries, time spent on pages, device performance data',
        ),
        _buildCookieCategory(
          '4.4 Marketing and Advertising Cookies',
          'Show relevant event recommendations and measure marketing effectiveness',
          'Explicit consent (can be disabled)',
          'Up to 12 months',
          [
            'Facebook Pixel (for families who consent)',
            'Google Ads remarketing',
            'Event recommendation tracking',
            'Email campaign effectiveness',
            'Social media integration',
            'Partner event promotion tracking',
          ],
          'Event interests, family preferences, engagement with recommendations, social media interactions',
        ),
      ],
    );
  }

  Widget _buildThirdPartyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'We work with trusted third-party service providers who may set cookies on our Platform. All third-party partners are required to comply with UAE data protection laws and our data processing standards.',
          style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.grey[700]),
        ),
        const SizedBox(height: 20),
        _buildSubsection('5.1 Analytics Partners', [
          'Google Analytics: Web analytics (with UAE data residency controls)',
          'Adobe Analytics: Platform performance monitoring',
          'Hotjar: User experience analytics (anonymized)',
        ]),
        _buildSubsection('5.2 Customer Support', [
          'Zendesk: Customer support chat functionality',
          'Intercom: Family assistance and communication',
        ]),
        _buildSubsection('5.3 Payment Processing', [
          'Payment Gateway Partners: UAE Central Bank licensed providers only',
          'Fraud Prevention: Secure transaction processing',
        ]),
        _buildSubsection('5.4 Event Integration Partners', [
          'TimeOut Dubai: Event data integration',
          'Platinumlist: Ticket booking integration',
          'Dubai Calendar: Official event information',
          'Venue Partners: Direct booking capabilities',
        ]),
        _buildSubsection('5.5 Communication Services', [
          'Mailchimp: Email newsletters (with consent)',
          'Twilio: SMS notifications for event reminders',
          'WhatsApp Business API: Community communication',
        ]),
      ],
    );
  }

  Widget _buildChoicesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsection('6.1 Cookie Consent Center', [
          'Accept all cookies',
          'Accept only essential cookies',
          'Customize your cookie preferences by category',
          'Learn more about each type of cookie',
        ]),
        const SizedBox(height: 16),
        Text(
          'You can change your preferences at any time by:',
          style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.grey[700]),
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('Clicking the cookie preferences link in our website footer'),
        _buildBulletPoint('Accessing cookie settings in your account preferences'),
        _buildBulletPoint('Using the cookie consent center'),
        const SizedBox(height: 20),
        _buildSubsection('6.2 Browser Controls', [
          'Google Chrome: Settings → Privacy and Security → Cookies and other site data',
          'Safari: Preferences → Privacy → Manage Website Data',
          'Firefox: Options → Privacy & Security → Cookies and Site Data',
          'Microsoft Edge: Settings → Site permissions → Cookies and site data',
        ]),
        _buildSubsection('6.3 Mobile App Settings', [
          'App settings → Privacy → Cookie preferences',
          'Device settings → Privacy → Tracking (iOS)',
          'Device settings → Google → Ads (Android)',
        ]),
        _buildSubsection('6.4 Impact of Disabling Cookies', [
          'Essential cookies disabled: Platform may not function',
          'Functional cookies disabled: Preferences won\'t be remembered',
          'Analytics cookies disabled: We can\'t improve the Platform based on usage',
          'Marketing cookies disabled: Event recommendations may be less relevant',
        ]),
      ],
    );
  }

  Widget _buildUAEComplianceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsection('7.1 PDPL Compliance', [
          'Explicit consent for non-essential cookies',
          'Clear information about cookie purposes and data collection',
          'Easy withdrawal of consent at any time',
          'Data minimization - we only collect necessary information',
          'Retention limits - cookies expire according to stated timeframes',
        ]),
        _buildSubsection('7.2 Data Localization', [
          'All UAE user data collected through cookies is stored within UAE borders',
          'Cross-border data transfers only occur with appropriate safeguards',
          'Third-party cookie providers must comply with UAE data residency requirements',
        ]),
        _buildSubsection('7.3 Children\'s Protection', [
          'Enhanced protection for family accounts with children under 18',
          'No behavioral tracking of individual children',
          'Parental consent required for any cookies related to children\'s data',
          'Special retention limits for family composition information',
        ]),
      ],
    );
  }

  Widget _buildTransfersContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When cookies from third-party services involve data transfers outside the UAE:',
          style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.grey[700]),
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('We ensure adequate protection through contractual safeguards'),
        _buildBulletPoint('Transfers only occur to countries with appropriate data protection standards'),
        _buildBulletPoint('Users are informed about international transfers in our cookie consent center'),
        _buildBulletPoint('Data subjects can object to international transfers while maintaining Platform functionality'),
      ],
    );
  }

  Widget _buildRetentionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cookie Data Retention Periods:',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('Session cookies: Deleted when you close your browser'),
        _buildBulletPoint('Essential cookies: Maximum 12 months'),
        _buildBulletPoint('Functional cookies: Maximum 24 months'),
        _buildBulletPoint('Analytics cookies: Maximum 24 months (often shorter)'),
        _buildBulletPoint('Marketing cookies: Maximum 12 months'),
        const SizedBox(height: 20),
        _buildSubsection('Automatic Deletion:', [
          'Cookies automatically expire according to their retention period',
          'We regularly audit and delete expired cookie data',
          'User account deletion triggers immediate cookie data removal',
        ]),
        _buildSubsection('Manual Deletion:', [
          'You can delete cookies anytime through browser settings',
          'Contact support@mydscvr.ai to request immediate cookie data deletion',
          'Account deletion removes all associated cookie data within 30 days',
        ]),
      ],
    );
  }

  Widget _buildUpdatesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'We may update this Cookies Policy to reflect:',
          style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.grey[700]),
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('Changes in UAE cookie laws and regulations'),
        _buildBulletPoint('New cookie technologies we implement'),
        _buildBulletPoint('Updates to third-party services we use'),
        _buildBulletPoint('Improvements to our Platform functionality'),
        const SizedBox(height: 20),
        Text(
          'Notification Process:',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('Email notification to registered users for material changes'),
        _buildBulletPoint('Platform banner highlighting policy updates'),
        _buildBulletPoint('30 days advance notice for significant changes affecting cookie usage'),
        _buildBulletPoint('Updated effective date clearly displayed at the top of this policy'),
        const SizedBox(height: 16),
        Text(
          'Continued use of the Platform after policy updates constitutes acceptance of the new terms, unless you withdraw consent or delete your account.',
          style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildContactContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'For questions about this Cookies Policy or to exercise your rights:',
          style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.grey[700]),
        ),
        const SizedBox(height: 20),
        _buildContactInfo('General Cookie Questions:', 'support@mydscvr.ai', 'Cookie Policy Inquiry'),
        _buildContactInfo('Cookie Consent Issues:', 'support@mydscvr.ai', 'Cookie Consent Management'),
        _buildContactInfo('Data Protection Concerns:', 'support@mydscvr.ai', 'Data Protection - Cookies'),
        _buildContactInfo('Technical Cookie Problems:', 'support@mydscvr.ai', 'Technical Cookie Issue'),
        const SizedBox(height: 20),
        Text(
          'Company Information:',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        const SizedBox(height: 12),
        Text(
          'Jasmine Entertainment FZE LLC\nEmail: support@mydscvr.ai\nWebsite: www.mydscvr.ai',
          style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.grey[700]),
        ),
        const SizedBox(height: 20),
        Text(
          'Multi-Language Support: Cookie inquiries can be submitted in Arabic, English, Hindi, Tagalog, or Urdu. Please specify your preferred language for our response.',
          style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.grey[700]),
        ),
        const SizedBox(height: 16),
        Text(
          'Response Time: We respond to cookie-related inquiries within 7 business days for general questions and within 48 hours for urgent technical issues.',
          style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildSummaryTableContent() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        border: TableBorder.all(color: Colors.grey[300]!),
        children: [
          TableRow(
            decoration: BoxDecoration(color: AppColors.dubaiTeal.withOpacity(0.1)),
            children: [
              _buildTableCell('Cookie Category', isHeader: true),
              _buildTableCell('Purpose', isHeader: true),
              _buildTableCell('Consent Required', isHeader: true),
              _buildTableCell('Max Duration', isHeader: true),
            ],
          ),
          TableRow(
            children: [
              _buildTableCell('Strictly Necessary'),
              _buildTableCell('Platform functionality, security'),
              _buildTableCell('No (Legitimate Interest)'),
              _buildTableCell('12 months'),
            ],
          ),
          TableRow(
            children: [
              _buildTableCell('Functional'),
              _buildTableCell('User preferences, personalization'),
              _buildTableCell('Yes'),
              _buildTableCell('24 months'),
            ],
          ),
          TableRow(
            children: [
              _buildTableCell('Analytics'),
              _buildTableCell('Platform improvement, usage statistics'),
              _buildTableCell('Yes'),
              _buildTableCell('24 months'),
            ],
          ),
          TableRow(
            children: [
              _buildTableCell('Marketing'),
              _buildTableCell('Targeted recommendations, advertising'),
              _buildTableCell('Yes (Explicit)'),
              _buildTableCell('12 months'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Under UAE law, you have the right to:',
          style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.grey[700]),
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('Be informed about our cookie usage (this policy)'),
        _buildBulletPoint('Give or withdraw consent for non-essential cookies'),
        _buildBulletPoint('Access information about cookies stored on your device'),
        _buildBulletPoint('Request deletion of cookie data associated with your account'),
        _buildBulletPoint('Object to processing based on legitimate interests'),
        _buildBulletPoint('Lodge a complaint with UAE data protection authorities'),
        const SizedBox(height: 16),
        Text(
          'To exercise these rights, contact us at support@mydscvr.ai with "Cookie Rights Request" in the subject line.',
          style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: Colors.grey[700]),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.dubaiTeal.withOpacity(0.05),
            border: Border.all(color: AppColors.dubaiTeal.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This Cookies Policy is part of our commitment to transparency and compliance with UAE data protection laws while providing excellent family event discovery services.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Last Updated: June 25, 2025\nCompany: Jasmine Entertainment FZE LLC\nPlatform: MyDscvr.ai\nUAE Registration: 4422193',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubsection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildBulletPoint(item)).toList(),
      ],
    );
  }

  Widget _buildCookieCategory(String title, String purpose, String legalBasis, String duration, List<String> examples, String dataCollected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.dubaiTeal),
          ),
          const SizedBox(height: 12),
          _buildCategoryDetail('Purpose:', purpose),
          _buildCategoryDetail('Legal Basis:', legalBasis),
          _buildCategoryDetail('Duration:', duration),
          const SizedBox(height: 12),
          Text(
            'Examples:',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          ...examples.map((example) => _buildBulletPoint(example)).toList(),
          const SizedBox(height: 12),
          Text(
            'Data Collected: $dataCollected',
            style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
            TextSpan(
              text: ' $value',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(String type, String email, String subject) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
          ),
          Text(
            'Email: $email',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
          ),
          Text(
            'Subject Line: "$subject"',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
          color: isHeader ? AppColors.dubaiTeal : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.inter(fontSize: 16, color: AppColors.dubaiTeal),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}