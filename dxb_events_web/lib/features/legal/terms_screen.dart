import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/footer.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _contentKey = GlobalKey();
  
  // Section keys for navigation
  final Map<String, GlobalKey> _sectionKeys = {};

  @override
  void initState() {
    super.initState();
    // Initialize section keys
    for (int i = 1; i <= 15; i++) {
      _sectionKeys['section_$i'] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(String sectionKey) {
    final key = _sectionKeys[sectionKey];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.comfortaa(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.dubaiTeal,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 20 : 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.dubaiTeal,
                    AppColors.dubaiTeal.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MyDscvr.ai',
                    style: GoogleFonts.comfortaa(
                      fontSize: isMobile ? 28 : 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Terms and Conditions',
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 18 : 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Effective Date: June 23, 2025 • Last Updated: June 25, 2025',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Container(
              key: _contentKey,
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: EdgeInsets.all(isMobile ? 20 : 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table of Contents (Desktop only)
                  if (!isMobile) ...[
                    Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 40),
                      child: _buildTableOfContents(),
                    ),
                  ],
                  
                  // Main Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mobile TOC
                        if (isMobile) ...[
                          _buildMobileTableOfContents(),
                          const SizedBox(height: 32),
                        ],
                        
                        // Legal Document Content
                        _buildLegalContent(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildTableOfContents() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Table of Contents',
            style: GoogleFonts.comfortaa(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildTOCItems(),
        ],
      ),
    );
  }

  Widget _buildMobileTableOfContents() {
    return ExpansionTile(
      leading: const Icon(LucideIcons.list, color: AppColors.dubaiTeal),
      title: Text(
        'Table of Contents',
        style: GoogleFonts.comfortaa(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      children: _buildTOCItems(),
    );
  }

  List<Widget> _buildTOCItems() {
    final sections = [
      'Agreement to Terms',
      'Changes to this Agreement',
      'About MyDscvr.ai',
      'Eligibility and User Registration',
      'Platform Services and Content',
      'User Content and Community Guidelines',
      'Payment Terms and Subscription Services',
      'Data Protection and Privacy',
      'Intellectual Property Rights',
      'Platform Rules and Prohibited Conduct',
      'Third-Party Services and Partnerships',
      'Limitation of Liability and Disclaimers',
      'Dispute Resolution and Governing Law',
      'Contact Information and Support',
      'Severability and Amendments',
    ];

    return sections.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final title = entry.value;
      
      return InkWell(
        onTap: () => _scrollToSection('section_$index'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.dubaiTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dubaiTeal,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildLegalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          key: _sectionKeys['section_1']!,
          number: '1',
          title: 'Agreement to Terms',
          subsections: [
            _buildSubsection(
              '1.1',
              'Introduction and Acceptance',
              'Welcome to MyDscvr.ai, Dubai\'s premier family-focused events discovery and recommendation platform. These Terms and Conditions ("Agreement" or "Terms") govern your use of the MyDscvr.ai website, mobile application, and related services (collectively, the "Platform") operated by JASMINE ENTERTAINMENT FZE LLC a Free Zone limited liability company incorporated under the laws of the United Arab Emirates with commercial registration number 442193 and licensed by the Dubai Department of Economic Development.',
            ),
            _buildSubsection(
              '1.2',
              'Consent and Binding Agreement',
              'Please read these Terms carefully before using the Platform as they stipulate your rights and obligations in relation to the Platform and the services provided thereunder. Your use or access of the Platform or the Account constitutes your consent to the Terms. If you do not agree to comply with and be bound by these Terms, you must stop using our Platform immediately.',
            ),
            _buildSubsection(
              '1.3',
              'Electronic Communications',
              'You hereby consent to the use of electronic communication to enter into agreements, contracts, make payments, and for other records, as well as to the electronic delivery of notices, policies and records of transactions initiated or completed electronically via the Platform. You waive any rights or requirements under any laws or regulations which require an original non-electronic signature or delivery or retention of non-electronic records to the extent permitted by UAE law.',
            ),
            _buildSubsection(
              '1.4',
              'Platform Ownership',
              'This document is an electronic agreement between you ("User", "you" or "your") and JASMINE ENTERTAINMENT FZE LLC ("Company", "we", "us" or "our"). The Platform is accessible through our website (www.dxbevents.ae) and mobile applications, including any subdomain of www.dxbevents.ae (hereinafter collectively referred as the "Platform").',
            ),
            _buildSubsection(
              '1.5',
              'Privacy Policy Integration',
              'By using the Platform, you also agree to our Privacy Policy available at www.dxbevents.ae/privacy-policy, which complies with UAE Federal Decree-Law No. 45 of 2021 on Personal Data Protection.',
            ),
            _buildSubsection(
              '1.6',
              'UAE Legal Compliance',
              'You agree and acknowledge that you have completely read and understood these Terms, the Privacy Policy, and any other rules or policies available on the Platform. All activities on the Platform must comply with UAE laws, regulations, and cultural standards.',
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_2']!,
          number: '2',
          title: 'Changes to this Agreement',
          subsections: [
            _buildSubsection(
              '2.1',
              'Modification Rights',
              'We reserve the exclusive right to make changes to these Terms from time to time, at our sole discretion. Your continued access to and use of the Platform after any such change constitutes your agreement to be bound by the modified terms.',
            ),
            _buildSubsection(
              '2.2',
              'Notification Period',
              'If within thirty (30) days of us posting changes or amendments to this Agreement, you decide that you do not agree to the updated Terms, you must stop using the Platform immediately and may request account closure.',
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_3']!,
          number: '3',
          title: 'About MyDscvr.ai',
          subsections: [
            _buildSubsection(
              '3.1',
              'Platform Purpose',
              'MyDscvr.ai is an AI-powered events aggregation platform specifically designed for families in Dubai and the UAE to discover, filter, and experience family-friendly events and activities. Our mission is to solve the information overload problem faced by busy expat families in Dubai\'s diverse community.',
            ),
            _buildSubsection(
              '3.2',
              'Core Services',
              'Our Platform provides:\n\n'
              '• Event Discovery: Comprehensive aggregation from TimeOut Dubai, Platinumlist, Dubai Calendar, What\'s On Dubai, and 50+ local sources\n'
              '• AI-Powered Personalization: Recommendations based on family composition, cultural preferences, and past activities\n'
              '• Family Suitability Scoring: Age-appropriate filtering with cultural sensitivity for Dubai\'s diverse communities\n'
              '• Multi-Language Support: Available in English, Arabic, Hindi, Tagalog, and Urdu to serve Dubai\'s expat population\n'
              '• Cultural Intelligence: Halal food options, prayer-friendly timings, dress code guidance, and religious holiday considerations\n'
              '• Logistics Intelligence: Parking availability, metro accessibility, stroller-friendly venues, and summer indoor alternatives\n'
              '• Community Features: Family reviews, group bookings, and community event sharing\n'
              '• Price Transparency: Clear pricing in AED with hidden cost detection and value-for-money analysis',
            ),
            _buildSubsection(
              '3.3',
              'Target Community',
              'Our Platform serves Dubai\'s 88.5% expat population, with particular focus on families from India (38.2%), Philippines (15%), Pakistan (12%), and Western countries, recognizing their unique needs and preferences.',
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_4']!,
          number: '4',
          title: 'Eligibility and User Registration',
          subsections: [
            _buildSubsection(
              '4.1',
              'Eligibility Requirements',
              'You represent and warrant that you are:\n\n'
              '• At least 18 years old and legally able to enter into binding contracts under UAE law\n'
              '• Legally residing in or visiting the UAE\n'
              '• Not prohibited from using the Platform under any applicable laws\n'
              '• Capable of providing accurate family information for personalized recommendations',
            ),
            _buildSubsection(
              '4.2',
              'UAE Legal Compliance',
              'You are solely responsible for ensuring that your use of the Platform complies with UAE Federal laws, Dubai Municipality regulations, and your visa/residency status requirements.',
            ),
            _buildSubsection(
              '4.3',
              'Account Creation and Family Profiles',
              '• Every User must register and create an Account to access full Platform features\n'
              '• Each User is permitted only one Account; duplicate accounts will be terminated\n'
              '• Parents/guardians must create profiles for children under 18\n'
              '• Family information is used exclusively for age-appropriate event recommendations and cultural filtering\n'
              '• You must provide accurate information about family composition, cultural preferences, and contact details',
            ),
            _buildSubsection(
              '4.4',
              'Account Security',
              '• Maintain confidentiality of Account credentials\n'
              '• Notify us immediately of any unauthorized access\n'
              '• You are responsible for all activities under your Account\n'
              '• Accounts inactive for 12 weeks may be suspended',
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_5']!,
          number: '5',
          title: 'Platform Services and Content',
          subsections: [
            _buildSubsection(
              '5.1',
              'Event Aggregation Services',
              'We aggregate event information from multiple sources including:\n\n'
              '• Official Sources: Dubai Calendar (Dubai Department of Tourism), DFRE, venue websites\n'
              '• Partner Platforms: TimeOut Dubai, Platinumlist, What\'s On Dubai, Eventbrite\n'
              '• Community Sources: User-submitted events, school activities, cultural center programs\n'
              '• Government Sources: Dubai Municipality events, cultural authority programs',
            ),
            _buildSubsection(
              '5.2',
              'AI Recommendation Engine',
              'Our AI system provides personalized recommendations considering:\n\n'
              '• Family Demographics: Ages, interests, previous attendance, cultural background\n'
              '• Cultural Preferences: Dietary requirements (halal, vegetarian, kosher), religious considerations\n'
              '• Practical Factors: Budget range, preferred locations, transportation preferences\n'
              '• Seasonal Intelligence: Indoor alternatives during summer, outdoor events during cool months\n'
              '• Community Trends: Popular events among similar families in your area',
            ),
            _buildSubsection(
              '5.3',
              'Booking and Ticketing Services',
              '• We act as an intermediary connecting users with event organizers\n'
              '• Payment processing through UAE-licensed providers compliant with Central Bank regulations\n'
              '• Booking confirmations provided by respective organizers\n'
              '• Cancellation and refund policies determined by individual event organizers\n'
              '• Group booking coordination for community events',
            ),
            _buildSubsection(
              '5.4',
              'Cultural Intelligence Features',
              '• Ramadan Mode: Adjusted recommendations during holy month with evening event focus\n'
              '• Prayer Time Integration: Event scheduling considering daily prayer times\n'
              '• Dietary Filtering: Comprehensive halal, vegetarian, vegan, and allergen options\n'
              '• Dress Code Guidance: Clear information about cultural dress expectations\n'
              '• Multi-Language Support: Content available in community languages',
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_6']!,
          number: '6',
          title: 'User Content and Community Guidelines',
          subsections: [
            _buildSubsection(
              '6.1',
              'User-Generated Content Policy',
              'Users may submit reviews, photos, event information, and community insights. By submitting content, you:\n\n'
              '• Grant us a non-exclusive, royalty-free, worldwide license to use, display, and distribute your content\n'
              '• Represent that you own or have permission to share the content\n'
              '• Agree that content must respect UAE cultural standards and laws\n'
              '• Confirm content is family-appropriate and culturally sensitive',
            ),
            _buildSubsection(
              '6.2',
              'Community Standards',
              'All user content must:\n\n'
              '• Respect Dubai\'s multicultural environment and religious diversity\n'
              '• Comply with UAE Cybercrime Law and content regulations\n'
              '• Be appropriate for family audiences across all cultures\n'
              '• Not promote discrimination based on nationality, religion, race, or culture\n'
              '• Provide accurate information about events and experiences',
            ),
            _buildSubsection(
              '6.3',
              'Content Moderation',
              'We reserve the right to remove content that:\n\n'
              '• Violates UAE laws, regulations, or cultural standards\n'
              '• Contains inappropriate material for family audiences\n'
              '• Promotes alcohol consumption inappropriately or violates Islamic values\n'
              '• Contains false or misleading information about events\n'
              '• Shows disrespect to any cultural or religious group\n'
              '• Includes personal information about children without guardian consent',
            ),
            _buildSubsection(
              '6.4',
              'Community Reviews and Family Wisdom',
              '• Reviews must be based on actual event attendance with family members\n'
              '• Focus on family-specific insights: child engagement, cultural appropriateness, practical logistics\n'
              '• Anonymous "Family Wisdom" sharing for sensitive cultural guidance\n'
              '• Constructive feedback to help other families make informed decisions',
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_7']!,
          number: '7',
          title: 'Payment Terms and Subscription Services',
          subsections: [
            _buildSubsection(
              '7.1',
              'Subscription Tiers',
              'Free Tier:\n'
              '• Basic event discovery and search\n'
              '• Limited AI recommendations (5 per week)\n'
              '• Access to user reviews\n'
              '• Basic cultural filtering\n\n'
              'Family Plus (AED 99/month):\n'
              '• Unlimited AI-powered recommendations\n'
              '• Advanced cultural and dietary filtering\n'
              '• Ad-free experience\n'
              '• Saved events and calendar integration\n'
              '• Priority customer support in English and Arabic\n\n'
              'Premium Family (AED 299/month):\n'
              '• All Family Plus features\n'
              '• Early access to popular events\n'
              '• Group booking coordination tools\n'
              '• Exclusive family-focused events\n'
              '• Multi-language customer support\n'
              '• Advanced analytics on family preferences\n\n'
              'Community Pro (AED 499/month):\n'
              '• All Premium features\n'
              '• Multiple family profile management\n'
              '• Community event organization tools\n'
              '• API access for schools and community groups\n'
              '• Priority partnership opportunities',
            ),
            _buildSubsection(
              '7.2',
              'Payment Processing',
              '• All payments processed through UAE Central Bank licensed providers\n'
              '• Pricing in AED with VAT included where applicable\n'
              '• Automatic renewal unless cancelled 24 hours before billing cycle\n'
              '• Subscription management through app store or direct billing',
            ),
            _buildSubsection(
              '7.3',
              'Refund Policy',
              '• Refunds handled according to UAE consumer protection laws\n'
              '• No refunds for unused portions of active subscriptions\n'
              '• Full refund available within 7 days of initial subscription for technical issues\n'
              '• Prorated refunds for extended service unavailability (>48 hours)',
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_8']!,
          number: '8',
          title: 'Data Protection and Privacy',
          subsections: [
            _buildSubsection(
              '8.1',
              'UAE PDPL Compliance',
              'Our data practices comply with UAE Federal Decree-Law No. 45 of 2021 on Personal Data Protection, which provides stronger protections than GDPR in several areas.',
            ),
            _buildSubsection(
              '8.2',
              'Data Localization',
              'All user data is stored within UAE borders in compliance with local data residency requirements. Cross-border transfers occur only with explicit consent and to countries with adequate protection standards.',
            ),
            _buildSubsection(
              '8.3',
              'Family Data Protection',
              '• Enhanced protection for children\'s data under UAE law\n'
              '• Parental consent required for all child-related data processing\n'
              '• Option to anonymize family data while retaining personalization benefits\n'
              '• Right to data deletion while preserving community safety requirements',
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_9']!,
          number: '9',
          title: 'Intellectual Property Rights',
          subsections: [
            _buildSubsection(
              '9.1',
              'Platform Ownership',
              'All Platform content, including AI algorithms, recommendation engines, cultural intelligence features, and aggregated event data, is protected by UAE and international intellectual property laws.',
            ),
            _buildSubsection(
              '9.2',
              'User License',
              'You are granted a limited, non-transferable license to use the Platform for personal, non-commercial family purposes only. This license does not include rights to:\n\n'
              '• Scrape or systematically collect Platform data\n'
              '• Reverse engineer our AI recommendation algorithms\n'
              '• Create derivative works or competing platforms\n'
              '• Use Platform data for commercial event promotion',
            ),
            _buildSubsection(
              '9.3',
              'Third-Party Content',
              'We respect intellectual property rights of event organizers and content partners. All aggregated event information is used under fair use provisions or explicit partnership agreements.',
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_10']!,
          number: '10',
          title: 'Platform Rules and Prohibited Conduct',
          subsections: [
            _buildSubsection(
              '10.1',
              'Prohibited Activities',
              'Users may not:\n\n'
              '• Create multiple accounts or use false identity information\n'
              '• Share inappropriate content for family audiences\n'
              '• Manipulate reviews or ratings for events\n'
              '• Use the Platform for commercial promotion without authorization\n'
              '• Violate UAE cybercrime laws or cultural standards\n'
              '• Discriminate against any cultural, religious, or ethnic group\n'
              '• Share personal information about other families without consent',
            ),
            _buildSubsection(
              '10.2',
              'Cultural Sensitivity Requirements',
              '• Respect Islamic values and cultural practices\n'
              '• Show consideration for diverse religious observances\n'
              '• Use appropriate language suitable for multicultural families\n'
              '• Respect privacy expectations of different cultural communities',
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_11']!,
          number: '11',
          title: 'Third-Party Services and Partnerships',
          subsections: [
            _buildSubsection(
              '11.1',
              'Event Partner Integration',
              'We partner with licensed UAE event organizers, venues, and ticketing platforms. These partnerships are subject to their own terms and conditions.',
            ),
            _buildSubsection(
              '11.2',
              'Government Integration',
              'Integration with Dubai Calendar and government event sources is subject to Dubai Department of Tourism regulations and may be updated based on policy changes.',
            ),
            _buildSubsection(
              '11.3',
              'Payment Provider Terms',
              'Payment processing is subject to UAE Central Bank regulations and individual payment provider terms.',
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_12']!,
          number: '12',
          title: 'Limitation of Liability and Disclaimers',
          subsections: [
            _buildSubsection(
              '12.1',
              'Service Availability',
              'We provide event information aggregation and recommendation services "as is" without guarantees of:\n\n'
              '• Event accuracy or organizer reliability\n'
              '• Venue accessibility or safety standards\n'
              '• Cultural appropriateness for all family situations\n'
              '• Availability of advertised amenities',
            ),
            _buildSubsection(
              '12.2',
              'Liability Limitations',
              'Our liability is limited to the greater of:\n\n'
              '• AED 1,000 or\n'
              '• Total subscription fees paid in the six months prior to the incident',
            ),
            _buildSubsection(
              '12.3',
              'Event Organizer Responsibility',
              'We are not responsible for:\n\n'
              '• Event cancellations, changes, or quality issues\n'
              '• Venue safety or accessibility problems\n'
              '• Organizer compliance with advertised amenities\n'
              '• Actual event content matching our family suitability scores',
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_13']!,
          number: '13',
          title: 'Dispute Resolution and Governing Law',
          subsections: [
            _buildSubsection(
              '13.1',
              'UAE Jurisdiction',
              'These Terms are governed by UAE Federal law and Dubai local regulations. Any disputes shall be resolved in Dubai courts with competent jurisdiction.',
            ),
            _buildSubsection(
              '13.2',
              'Alternative Dispute Resolution',
              'Before initiating formal proceedings, parties agree to attempt resolution through:\n\n'
              '• Direct negotiation within 30 days\n'
              '• Mediation through Dubai International Arbitration Centre if required\n'
              '• Escalation to Dubai courts only after exhausting alternative methods',
            ),
            _buildSubsection(
              '13.3',
              'Language',
              'While the Platform operates in multiple languages, the English version of these Terms shall prevail in case of conflicts with translations.',
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_14']!,
          number: '14',
          title: 'Contact Information and Support',
          subsections: [
            _buildSubsection(
              '14.1',
              'Customer Support',
              '• Email: support@dxbevents.ae\n'
              '• Phone: +971507493651 (Arabic and English)\n'
              '• WhatsApp: +971-507493651 (Arabic and English)\n'
              '• Office: [Dubai address with trade license number]',
            ),
            _buildSubsection(
              '14.2',
              'Legal Notices',
              'Legal notices should be sent to: legal@dxbevents.ae',
            ),
            _buildSubsection(
              '14.3',
              'Data Protection Officer',
              'Privacy concerns: privacy@dxbevents.ae',
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_15']!,
          number: '15',
          title: 'Severability and Amendments',
          content: 'If any provision of these Terms is found invalid under UAE law, the remaining provisions shall remain in full force and effect. We may update these Terms to reflect changes in UAE regulations, platform features, or business operations with 30 days notice to users.',
        ),

        const SizedBox(height: 40),

        // Footer Information
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Legal Entity Information',
                style: GoogleFonts.comfortaa(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Last Updated:', 'June 25, 2025'),
              _buildInfoRow('Dubai Commercial Registration:', '4422193'),
              _buildInfoRow('TDRA License:', '4422193'),
              _buildInfoRow('Entity:', 'JASMINE ENTERTAINMENT FZE LLC'),
              _buildInfoRow('Jurisdiction:', 'United Arab Emirates'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.dubaiTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.scale,
                      size: 20,
                      color: AppColors.dubaiTeal,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'These Terms are governed by UAE Federal law and Dubai local regulations.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.dubaiTeal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSection({
    required GlobalKey key,
    required String number,
    required String title,
    List<Widget>? subsections,
    String? content,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.dubaiTeal,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dubaiTeal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.comfortaa(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (content != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                content,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ],
          if (subsections != null) ...subsections,
        ],
      ),
    );
  }

  Widget _buildSubsection(String number, String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.dubaiTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  number,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dubaiTeal,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.comfortaa(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}