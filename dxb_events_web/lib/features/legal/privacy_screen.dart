import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/footer.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _contentKey = GlobalKey();
  
  // Section keys for navigation
  final Map<String, GlobalKey> _sectionKeys = {};

  @override
  void initState() {
    super.initState();
    // Initialize section keys for all 19 sections
    for (int i = 1; i <= 19; i++) {
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
          'Privacy Policy',
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
                    'Privacy Policy',
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
                      'Last Updated: June 25, 2025 • UAE PDPL Compliant',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.dubaiGold.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.shield,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Enhanced Family Privacy Protection',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
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
          Row(
            children: [
              Icon(
                LucideIcons.shield,
                size: 16,
                color: AppColors.dubaiTeal,
              ),
              const SizedBox(width: 8),
              Text(
                'Table of Contents',
                style: GoogleFonts.comfortaa(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildTOCItems(),
        ],
      ),
    );
  }

  Widget _buildMobileTableOfContents() {
    return ExpansionTile(
      leading: const Icon(LucideIcons.shield, color: AppColors.dubaiTeal),
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
      'Introduction',
      'Purpose and Consent',
      'Changes to This Policy',
      'Personal Data Protection Principles',
      'Consent for Performance of Contract',
      'Information We Collect About You and Your Family',
      'Mode of Collection',
      'Use of Information',
      'Processing Without Consent',
      'Disclosure of Your Personal Data to Third Parties',
      'International Transfer of Information',
      'Third-Party Advertising and Analytics',
      'Links to Third-Party Websites',
      'Your Rights in Relation to Your Personal Data',
      'Submission of Requests for Exercise of Rights',
      'Personal Data Retention',
      'Legal Recourse to Relevant Authorities',
      'Security Precautions and Measures',
      'Contacting Us',
    ];

    return sections.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final title = entry.value;
      
      return InkWell(
        onTap: () => _scrollToSection('section_$index'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.dubaiTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dubaiTeal,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.3,
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
          number: '1.1',
          title: 'Introduction',
          content: 'We, JASMINE ENTERTAINMENT FZE LLC (\'Company\', \'we\', \'our\' or \'us\'), are committed to protecting your privacy and that of your family. This Privacy Policy (\'Privacy Policy\' or \'Policy\') applies to all persons using our MyDscvr.ai platform for family event discovery and booking services, and when you otherwise do business or make contact with us. This Policy governs our personal data collection, processing and usage practices with special focus on family privacy protection. It also describes your choices regarding use, access and correction of your personal information.\n\nBy using our app or website www.dxbevents.ae (\'MyDscvr.ai\' or \'Website\' or \'Platform\' or \'App\'), you (\'user\', \'you\', \'your\') consent to this Policy and to the personal data practices described in it, in addition to consenting to it explicitly when using the Platform. If you do not agree with the personal data practices described in this Policy, you may choose to stop using our services and the Platform immediately.',
        ),

        _buildSection(
          key: _sectionKeys['section_2']!,
          number: '1.2',
          title: 'Purpose and Consent',
          content: 'This Policy has been developed for purposes of compliance with UAE Federal Decree-Law No. 45 of 2021 on Personal Data Protection (\'PDPL\'), Dubai Municipality data protection regulations, and other UAE data protection-oriented provisions within applicable regulations. The Policy shall serve as part of your initial customer relationship with us and our ongoing commitments to you and your family.\n\nWhen you are asked to provide personal information, you may decline, but if you choose not to provide data that is necessary to enable us to provide family event recommendations, you may not be able to sign up for or use the platform, and/or certain features may be limited.\n\nMyDscvr.ai collects certain personal information to enable us to operate the platform effectively, and to provide you with the best family-focused event discovery experiences. We pride ourselves on transparency and as such, you have choices about the personal information we collect.',
        ),

        _buildSection(
          key: _sectionKeys['section_3']!,
          number: '1.3',
          title: 'Changes to This Policy',
          content: 'From time to time, we may revise, amend, or supplement this Policy to reflect necessary changes in UAE law, our Personal Data collection and usage practices, the features of our family-focused offerings, or certain advances in technology. If any material changes are made to this Policy, the changes may be prominently posted on the Platform and we will notify registered users via email at least 30 days in advance.\n\nChanges to this Policy are effective when they are published, except for material changes which become effective 30 days after notification.',
        ),

        _buildSection(
          key: _sectionKeys['section_4']!,
          number: '1.4',
          title: 'Personal Data Protection Principles',
          content: 'Your Personal Data is collected and processed in accordance with UAE PDPL and relevant data protection principles, including: lawfulness, fairness and transparency; purpose limitation; collection limitation; data minimization; accuracy; rectification measures; storage limitation; integrity and confidentiality (security).\n\nThe data protection principles that we follow include:\n\n• Notice and Choice Principle: We capture the purposes in this Policy for which your and your family\'s Personal Data is collected and your right to request access to and correction of your Personal Data.\n\n• Disclosure Principle: We don\'t disclose your or your family\'s Personal Data without your consent, for any purposes other than the purposes provided herein in this Policy.\n\n• Security Principle: We take practical steps/measures to protect your Personal Data from any loss, misuse, modification, unauthorized or accidental access or disclosure, alteration, or destruction, with enhanced security for family and children\'s data.\n\n• Family Protection Principle: We implement additional safeguards for family composition data and children\'s information in compliance with UAE law.',
        ),

        _buildSection(
          key: _sectionKeys['section_5']!,
          number: '1.5',
          title: 'Consent for Performance of Contract, Rectification, Legal Obligations',
          content: 'You provide consent to your Personal Data being processed to satisfy all legal obligations arising from any contracts entered into with you or to deliver any family event discovery services to you which you have contracted with us to provide to you.\n\nYou can request access to your Personal Data retained with us and can further request for correction in the retained Personal Data. If you wish to submit the request, please contact us at privacy@dxbevents.ae.\n\nYou can withdraw such consent to your Personal Data. Such withdrawal will not affect the lawfulness of processing based on previously recorded consent. Such withdrawal will take effect within 30 calendar days of submission of request.',
        ),

        _buildSection(
          key: _sectionKeys['section_6']!,
          number: '1.6',
          title: 'Information We Collect About You and Your Family',
          subsections: [
            _buildHighlightedSubsection(
              'Account and Family Profile Information',
              '• Identification information: Name, email address, home address, phone number, date of birth, gender, country and city of origin/residence, profile pictures, billing address, username, along with identification details of documents confirming such details for UAE residency verification\n\n• Family composition data: Ages, interests, and basic demographics of family members (collected with parental consent for children under 18)\n\n• Cultural and religious preferences: Dietary requirements (halal, vegetarian, vegan, kosher), prayer time considerations, cultural celebration preferences, dress code sensitivities\n\n• Accessibility requirements: Special needs information for family members, mobility considerations, sensory requirements',
            ),
            _buildHighlightedSubsection(
              'Financial and Transaction Information',
              '• Payment information: Bank account and payment card numbers, digital wallet information, billing statements (processed through UAE Central Bank licensed providers)\n\n• Transaction history: Event bookings, subscription payments, refunds, and cancellations\n\n• Location and venue preferences: Preferred Dubai areas, transportation preferences (metro, car, walking), parking requirements',
            ),
            _buildHighlightedSubsection(
              'Platform Usage and Interaction Data',
              '• Event discovery patterns: Search queries, event views, recommendation interactions, saved events, calendar integrations\n\n• Community participation: Reviews submitted, ratings given, family wisdom shared, community discussions participated in\n\n• Device and technical information: Hardware model, operating system and version, unique device identifier, mobile network information, browser type and language, Internet Protocol (\'IP\') address, connection type, referring URLs, access time\n\n• Location data: Real-time location (with explicit consent), preferred areas, frequently visited venues',
            ),
            _buildHighlightedSubsection(
              'Children\'s Data (Enhanced Protection)',
              '• Age-appropriate information: Ages of children, general interests, educational levels (no personal identification beyond what\'s necessary for recommendations)\n\n• Parental consent records: Documentation of consent for data collection and processing related to children\n\n• Safety preferences: Supervision requirements, age restrictions, content filtering preferences',
              isSpecial: true,
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_7']!,
          number: '1.7',
          title: 'Mode of Collection',
          subsections: [
            _buildSubsection(
              'Information You Provide to Us Directly',
              'When you register for your family account, we collect Personal Data about you and your family members. Depending on the services you choose, we may require you to provide us with your name, postal address, telephone number, email address, family composition, cultural preferences, and identification information to establish an account.',
            ),
            _buildSubsection(
              'Information Collected Automatically',
              'We also may receive and store certain Personal Data about you and your device(s) automatically when you access or use our services. This information may include technical information associated with your activity on our Platform, including information related to your browser and operating system, IP address, unique device identifiers, and other information such as your device type.',
            ),
            _buildSubsection(
              'Information Collected from Third-Party Services',
              'We collect Personal Data from third party partners who have your consent to provide us this Personal Data, including event organizers and venue partners, payment processing partners (UAE Central Bank licensed providers), calendar and scheduling applications, social media platforms, and government tourism and cultural websites.',
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_8']!,
          number: '1.8',
          title: 'Use of Information',
          content: 'We do not sell, exchange or give to any other person your Personal Data, whether public or private, for any reason whatsoever, without your consent, other than for the express purpose of providing our family event discovery services to you.\n\nWe collect, process, and use your Personal Data for the following purposes:\n\n• Core Family Event Services: To provide personalized AI-powered event recommendations based on your family composition, cultural preferences, past attendance, and community trends\n\n• Platform Enhancement and Analytics: To improve, personalize and facilitate your family\'s use of our services and measure, customize, and enhance our services\n\n• Communication and Community: To send periodic emails about family events, facilitate community discussions, and provide customer support in multiple languages\n\n• Security and Legal Compliance: To administer our internal information processing, operate our Platform securely, and comply with UAE legal obligations\n\n• Fraud Prevention and Safety: To protect our rights, verify your identity and UAE residency status, investigate and prevent fraud, and protect the safety and security of families using our platform',
        ),

        _buildSection(
          key: _sectionKeys['section_9']!,
          number: '1.9',
          title: 'Processing Without Consent',
          content: 'We may collect and process some of your Personal Data without your knowledge or consent; and only where this is required or permitted by UAE law. We may be compelled to surrender your Personal Data to legal authorities without your express consent, if presented with a court order or similar legal or administrative order, or as required or permitted by the laws, rules and regulations of the UAE.\n\nOther situations where your Personal Data may be processed without your express consent include:\n\n• Where processing is related to Personal Data made publicly available by you\n• Where processing is necessary for the performance of any contract entered into where you are a party\n• Where processing is necessary for public interest as defined under UAE law\n• Where processing is required for the establishment, exercise or defense of legal claims\n• Where processing is necessary for compliance with UAE legal obligations including data localization requirements',
        ),

        _buildSection(
          key: _sectionKeys['section_10']!,
          number: '1.10',
          title: 'Disclosure of Your Personal Data to Third Parties',
          subsections: [
            _buildSubsection(
              'Event Partners and Organizers',
              'To event organizers and venues to facilitate your family\'s booking and attendance, including party size, special requirements, contact details for event-related communications; to venue partners to provide accessibility information, dietary accommodations, and family-specific services; to government tourism and cultural entities for official event participation and cultural program enrollment.',
            ),
            _buildSubsection(
              'Service Providers and Technical Partners',
              'To our related entities, employees, officers, agents, contractors, other companies that provide services to us; to third parties who help us to verify the identity of our clients and customers; to third parties who help us analyze the information we collect so that we can administer, support, improve or develop our business; to payment processors and financial institutions through UAE Central Bank licensed providers.',
            ),
            _buildSubsection(
              'Legal and Regulatory Requirements',
              'If the disclosure is requested by UAE law enforcement or government agency or is required by law; if the disclosure is required to enforce the terms of this policy; to our professional advisers such as consultants, bankers, professional indemnity insurers, brokers, and auditors so that we can meet our UAE regulatory obligations.',
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_11']!,
          number: '1.11',
          title: 'International Transfer of Information',
          content: 'Your Personal Data is stored and transferred in compliance with UAE Federal Decree-Law No. 45 of 2021 on Personal Data Protection and other applicable legislation or regulations of the UAE.\n\nUAE Data Localization: As required by UAE law, all personal data of UAE residents is primarily stored and processed within UAE borders. Our primary data centers are located in the UAE with appropriate security certifications.\n\nCross-Border Transfers: Any storage, processing and transfer of your Personal Data outside the UAE will adhere to the relevant legal requirements, particularly the PDPL. Cross-border transfers only occur when you have provided explicit consent for such transfer, the destination country has been deemed to have adequate protection standards by UAE authorities, appropriate contractual safeguards are in place, or the transfer is necessary for the performance of our contract with you.',
        ),

        _buildSection(
          key: _sectionKeys['section_12']!,
          number: '1.12',
          title: 'Third-Party Advertising and Analytics',
          content: 'We may allow third-party service providers to deliver content and advertisements in connection with our family event services and to provide anonymous site metrics and other analytics services to promote and improve our Services. These third parties may use cookies, web beacons, and other technologies to collect Information, such as your IP address, identifiers associated with your device, other applications on your device, the browsers you use to access our services, webpages viewed, time spent on webpages, links clicked, and conversion information.\n\nThe third-party service providers that we engage are bound by confidentiality obligations and applicable UAE laws with respect to their use and collection of your Personal Data. All such providers must comply with UAE data localization requirements.',
        ),

        _buildSection(
          key: _sectionKeys['section_13']!,
          number: '1.13',
          title: 'Links to Third-Party Websites',
          content: 'Our Platform or communications may contain links to other third-party websites including event organizer websites which are not owned or operated by us and are regulated by their own privacy policies. If you click on a third-party link, you will be directed to that third party\'s platform. We strongly advise you to review the privacy policy of every platform you visit, especially when providing family information for event bookings.\n\nThis Policy does not apply to, and we are not responsible for the privacy policies of these third-party websites regardless of whether they were accessed while using links from our Platform or communications.',
        ),

        _buildSection(
          key: _sectionKeys['section_14']!,
          number: '1.14',
          title: 'Your Rights in Relation to Your Personal Data',
          subsections: [
            _buildRightsSubsection(
              'Right to be Informed',
              'You have a right to know our identity and contact details, the purposes of processing your Personal Data, the legal basis for processing, legitimate interests pursued by us or third parties, recipients of your Personal Data, retention periods, and the existence of automated decision-making.',
            ),
            _buildRightsSubsection(
              'Right to Access to Personal Data',
              'This is your right to see what personal data is held about you and your family by us. You have the right to request categories of Personal Data processed, purpose of processing, automated decision making details, storage controls, recipients of data transfers, and a copy of Personal Data undergoing processing.',
            ),
            _buildRightsSubsection(
              'Right to Rectification',
              'You have the right to rectify any inaccurate Personal Data about you and your family retained with us and to complete any incomplete Personal Data about you, provided the requisite procedures outlined within the UAE PDPL are adhered to.',
            ),
            _buildRightsSubsection(
              'Right to Erasure',
              'You have the right to demand erasure of your Personal Data if the data is no longer necessary, you withdraw consent, you object to processing, data has been unlawfully processed, or erasure is required for legal compliance. Special consideration applies for family data - you can choose to anonymize children\'s information while maintaining event safety and recommendation functionality.',
            ),
            _buildRightsSubsection(
              'Right to Object to Automated Decision Making',
              'You have the right to object to automated decision making if it has legal or serious consequences that affect you. For family recommendation systems, you can object to automated family event recommendations while still maintaining basic platform functionality.',
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_15']!,
          number: '1.15',
          title: 'Submission of Requests for Exercise of Rights',
          content: 'We aim to respond to all legitimate requests without undue delay and within 30 calendar days of receipt of any request from you as required under UAE PDPL. Occasionally it may take us longer than 30 calendar days, if your request is particularly complex, or if you have made duplicated or numerous requests.\n\nIf you wish to exercise any of the rights mentioned above, please contact us at privacy@dxbevents.ae. We may need to request specific information from you to help us confirm your identity and ensure your entitlement to such rights.\n\nFamily Account Considerations: For family accounts, we may require verification from the primary account holder before processing requests related to family member data, especially for children\'s information.',
        ),

        _buildSection(
          key: _sectionKeys['section_16']!,
          number: '1.16',
          title: 'Personal Data Retention',
          content: 'We retain Personal Data for no period longer than required for the purposes it was collected for, for using our family event services, and for meeting any legal, accounting, reporting, government, regulatory or law enforcement requirements under UAE law.\n\nRetention periods:\n• Account and Profile Data: Retained while account is active, deleted within 30 days of account closure\n• Family Composition Data: Retained while account is active, with enhanced deletion procedures for children\'s data\n• Transaction Records: 7 years as required by UAE financial regulations\n• Event Booking History: 3 years for dispute resolution and service improvement\n• Community Content: May be retained in anonymized form for community benefit\n• Technical Logs: 12 months for security and platform improvement purposes\n\nChildren\'s Data: Special retention limits apply with maximum 2-year retention for inactive child profiles and immediate deletion upon parental request.',
        ),

        _buildSection(
          key: _sectionKeys['section_17']!,
          number: '1.17',
          title: 'Legal Recourse to Relevant Authorities',
          content: 'You have the right to make a complaint at any time to UAE data protection supervisory or regulatory authorities if you believe your rights under UAE Federal Decree-Law No. 45 of 2021 have been infringed.\n\nYou have the right to raise complaint in writing to the UAE Data Protection Authority or relevant Dubai regulatory authorities regarding any breach of your rights under the UAE PDPL or if you believe such infringement of UAE data protection law has taken place.\n\nHowever, we would appreciate the opportunity to address your concerns before you approach any such authority. Please contact us in the first instance so that we may try to resolve your complaint swiftly and satisfactorily. Please contact us via email at privacy@dxbevents.ae.',
        ),

        _buildSection(
          key: _sectionKeys['section_18']!,
          number: '1.18',
          title: 'Security Precautions and Measures',
          subsections: [
            _buildSecuritySubsection(
              'Information Security',
              'We are committed to ensuring that your Personal Data and your family\'s information is secure. To prevent unauthorized access or disclosure we have put in place suitable physical, electronic and managerial procedures to safeguard and secure the information we collect online.',
            ),
            _buildSecuritySubsection(
              'UAE-Specific Security Measures',
              '• All data stored in UAE-based data centers with appropriate security certifications\n• Compliance with UAE cybersecurity framework requirements\n• Regular security audits by UAE-certified security firms\n• Staff security clearances and background checks as required by UAE law\n• Multi-language incident response procedures',
            ),
            _buildSecuritySubsection(
              'Enhanced Family Data Protection',
              '• Additional encryption layers for children\'s data\n• Segregated storage for cultural and religious preference data\n• Enhanced access controls for family composition information\n• Special deletion procedures for sensitive family information',
            ),
            _buildSecuritySubsection(
              'Personal Data Breaches',
              'Should your Personal Data be breached, we shall promptly communicate to you the nature of the breach, likely consequences, and measures implemented to address the breach. UAE Breach Notification Requirements: We will comply with UAE PDPL breach notification requirements, including notification to UAE authorities within 72 hours where required by law.',
            ),
          ],
        ),

        _buildSection(
          key: _sectionKeys['section_19']!,
          number: '1.19',
          title: 'Contacting Us',
          content: 'If you have any questions about our Policy or any complaints, please contact us at:\n\n• General Privacy Inquiries: support@mydscvr.ai\n• Data Protection Officer: support@mydscvr.ai\n• Security Concerns: support@mydscvr.ai\n• Customer Support: support@mydscvr.ai\n• Phone: +971-50-7493651 (Arabic, English)\n• WhatsApp: +971-50-7493651\n\nMulti-Language Support: Privacy inquiries can be submitted in Arabic, English\n\nFamily-Specific Inquiries: For questions related to children\'s data, family profile management, or cultural data handling, please contact our Family Privacy Specialist at support@mydscvr.ai\n\nThis Privacy Policy demonstrates our commitment to protecting family privacy while providing excellent event discovery services for Dubai\'s diverse expat community.',
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
              Row(
                children: [
                  Icon(
                    LucideIcons.shield,
                    size: 20,
                    color: AppColors.dubaiTeal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Legal Entity and Compliance Information',
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Last Updated:', 'June 25, 2025'),
              _buildInfoRow('UAE Company Registration:', '4422193'),
              _buildInfoRow('Dubai Trade License:', '4422193'),
              _buildInfoRow('Entity:', 'JASMINE ENTERTAINMENT FZE LLC'),
              _buildInfoRow('Compliance:', 'UAE Federal Decree-Law No. 45 of 2021 (PDPL)'),
              _buildInfoRow('Data Localization:', 'UAE-based data centers'),
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
                      LucideIcons.users,
                      size: 20,
                      color: AppColors.dubaiTeal,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Enhanced family privacy protection with special safeguards for children\'s data and cultural information.',
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
                        fontSize: 12,
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
                      fontSize: 18,
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
                  fontSize: 15,
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

  Widget _buildSubsection(String title, String content) {
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
          Text(
            title,
            style: GoogleFonts.comfortaa(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
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

  Widget _buildHighlightedSubsection(String title, String content, {bool isSpecial = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSpecial ? AppColors.dubaiGold.withOpacity(0.05) : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSpecial ? AppColors.dubaiGold.withOpacity(0.3) : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isSpecial) ...[
                Icon(
                  LucideIcons.shield,
                  size: 16,
                  color: AppColors.dubaiGold,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.comfortaa(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSpecial ? AppColors.dubaiGold : AppColors.textPrimary,
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

  Widget _buildRightsSubsection(String title, String content) {
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
            children: [
              Icon(
                LucideIcons.userCheck,
                size: 16,
                color: AppColors.dubaiTeal,
              ),
              const SizedBox(width: 8),
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

  Widget _buildSecuritySubsection(String title, String content) {
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
            children: [
              Icon(
                LucideIcons.lock,
                size: 16,
                color: AppColors.dubaiTeal,
              ),
              const SizedBox(width: 8),
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