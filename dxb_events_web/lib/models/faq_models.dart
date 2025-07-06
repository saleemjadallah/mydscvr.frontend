/// FAQ models for help center functionality
class FAQ {
  final String id;
  final String question;
  final String answer;
  final FAQCategory category;
  final List<String> keywords;
  final int priority; // Higher priority items show first
  final bool isPopular;

  const FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.keywords = const [],
    this.priority = 0,
    this.isPopular = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category.name,
      'keywords': keywords,
      'priority': priority,
      'isPopular': isPopular,
    };
  }

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      category: FAQCategory.values.firstWhere(
        (cat) => cat.name == json['category'],
        orElse: () => FAQCategory.general,
      ),
      keywords: List<String>.from(json['keywords'] ?? []),
      priority: json['priority'] ?? 0,
      isPopular: json['isPopular'] ?? false,
    );
  }

  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return question.toLowerCase().contains(lowerQuery) ||
           answer.toLowerCase().contains(lowerQuery) ||
           keywords.any((keyword) => keyword.toLowerCase().contains(lowerQuery));
  }
}

enum FAQCategory {
  general('General', 'Basic questions about MyDscvr'),
  account('Account', 'User accounts and profiles'),
  events('Events', 'Finding and booking events'),
  favorites('Favorites', 'Saving and managing favorite events'),
  notifications('Notifications', 'Push notifications and alerts'),
  families('Families', 'Family-specific features'),
  payments('Payments', 'Billing and payment issues'),
  technical('Technical', 'App issues and troubleshooting'),
  privacy('Privacy', 'Data protection and privacy'),
  safety('Safety', 'Child safety and content filtering');

  const FAQCategory(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// FAQ data source with static content
class FAQData {
  static List<FAQ> getAllFAQs() {
    return [
      // General
      FAQ(
        id: 'general_1',
        question: 'What is MyDscvr?',
        answer: 'MyDscvr is Dubai\'s premier family activities discovery platform. We help families find amazing events, activities, and experiences across Dubai and the UAE, tailored to your family\'s interests and ages.',
        category: FAQCategory.general,
        keywords: ['app', 'platform', 'family', 'dubai'],
        priority: 10,
        isPopular: true,
      ),
      FAQ(
        id: 'general_2',
        question: 'Is MyDscvr free to use?',
        answer: 'Yes! MyDscvr is completely free to download and use. You can browse events, save favorites, and get personalized recommendations at no cost. Some events may have their own ticketing fees through the event organizers.',
        category: FAQCategory.general,
        keywords: ['free', 'cost', 'price', 'subscription'],
        priority: 9,
        isPopular: true,
      ),
      FAQ(
        id: 'general_3',
        question: 'Which areas of Dubai do you cover?',
        answer: 'We cover all major areas of Dubai including Downtown, Marina, JBR, Dubai Mall, Mall of the Emirates, Dubai Parks, Global Village, and many more. We\'re constantly expanding our coverage across the UAE.',
        category: FAQCategory.general,
        keywords: ['areas', 'location', 'coverage', 'dubai', 'uae'],
        priority: 8,
      ),

      // Account
      FAQ(
        id: 'account_1',
        question: 'How do I create an account?',
        answer: 'You can create an account by clicking "Sign Up" and choosing to register with your email or Google account. We\'ll guide you through setting up your family profile and preferences.',
        category: FAQCategory.account,
        keywords: ['signup', 'register', 'create', 'account'],
        priority: 9,
        isPopular: true,
      ),
      FAQ(
        id: 'account_2',
        question: 'I forgot my password. How can I reset it?',
        answer: 'Click "Forgot Password" on the login screen and enter your email address. We\'ll send you a secure link to reset your password. Check your spam folder if you don\'t see the email within a few minutes.',
        category: FAQCategory.account,
        keywords: ['password', 'reset', 'forgot', 'email'],
        priority: 8,
      ),
      FAQ(
        id: 'account_3',
        question: 'How do I update my profile information?',
        answer: 'Go to your Profile tab, then tap the Settings section. You can update your personal information, family details, and preferences. Changes are saved automatically.',
        category: FAQCategory.account,
        keywords: ['profile', 'update', 'edit', 'information'],
        priority: 7,
      ),
      FAQ(
        id: 'account_4',
        question: 'Can I delete my account?',
        answer: 'Yes, you can delete your account by going to Profile > Settings > Account Actions > Delete Account. This will permanently remove all your data. This action cannot be undone.',
        category: FAQCategory.account,
        keywords: ['delete', 'remove', 'account', 'data'],
        priority: 5,
      ),

      // Events
      FAQ(
        id: 'events_1',
        question: 'How do I find events suitable for my family?',
        answer: 'Use our smart filters to select age ranges, interests, areas, and dates. Our AI will also learn your preferences and show personalized recommendations on your home screen.',
        category: FAQCategory.events,
        keywords: ['find', 'search', 'family', 'suitable', 'age'],
        priority: 9,
        isPopular: true,
      ),
      FAQ(
        id: 'events_2',
        question: 'How do I book tickets for an event?',
        answer: 'Click on any event to view details, then tap "Book Now" or "Get Tickets". You\'ll be directed to the event organizer\'s booking system or official ticketing partner.',
        category: FAQCategory.events,
        keywords: ['book', 'tickets', 'purchase', 'buy'],
        priority: 8,
        isPopular: true,
      ),
      FAQ(
        id: 'events_3',
        question: 'Are the event times accurate?',
        answer: 'We work hard to keep all event information up-to-date, but times and details can change. Always check with the venue or event organizer before attending, especially for outdoor events.',
        category: FAQCategory.events,
        keywords: ['times', 'accurate', 'schedule', 'updated'],
        priority: 7,
      ),
      FAQ(
        id: 'events_4',
        question: 'Can I suggest events to be added?',
        answer: 'Absolutely! We love community suggestions. Contact our support team with event details, and we\'ll review it for inclusion in our platform.',
        category: FAQCategory.events,
        keywords: ['suggest', 'add', 'submit', 'new events'],
        priority: 6,
      ),

      // Favorites
      FAQ(
        id: 'favorites_1',
        question: 'How do I save events to my favorites?',
        answer: 'Tap the heart icon on any event card or event details page. You need to be signed in to save favorites. Your saved events appear in the Favorites tab.',
        category: FAQCategory.favorites,
        keywords: ['save', 'heart', 'favorites', 'bookmark'],
        priority: 8,
        isPopular: true,
      ),
      FAQ(
        id: 'favorites_2',
        question: 'Where can I view my saved events?',
        answer: 'All your saved events are available in the Favorites tab at the bottom of the app. You can also access them from your Profile section.',
        category: FAQCategory.favorites,
        keywords: ['view', 'saved', 'favorites', 'tab'],
        priority: 7,
      ),
      FAQ(
        id: 'favorites_3',
        question: 'Can I organize my favorites into categories?',
        answer: 'Currently, favorites are displayed in a single list sorted by date added. We\'re working on adding categories and custom lists in a future update.',
        category: FAQCategory.favorites,
        keywords: ['organize', 'categories', 'lists', 'sort'],
        priority: 5,
      ),

      // Notifications
      FAQ(
        id: 'notifications_1',
        question: 'How do I turn on event notifications?',
        answer: 'Go to Profile > Settings > Preferences and toggle on "Event Notifications". You can choose to receive notifications for new events, event reminders, and weekly digests.',
        category: FAQCategory.notifications,
        keywords: ['notifications', 'alerts', 'turn on', 'enable'],
        priority: 7,
      ),
      FAQ(
        id: 'notifications_2',
        question: 'I\'m not receiving notifications. What should I do?',
        answer: 'Check that notifications are enabled in your device settings for MyDscvr. Also verify that notification preferences are turned on in the app settings.',
        category: FAQCategory.notifications,
        keywords: ['not receiving', 'missing', 'notifications', 'fix'],
        priority: 6,
      ),
      FAQ(
        id: 'notifications_3',
        question: 'Can I choose what types of notifications I receive?',
        answer: 'Yes! In Profile > Settings > Preferences, you can customize which notifications you receive: new events, event reminders, weekly digest, and special offers.',
        category: FAQCategory.notifications,
        keywords: ['customize', 'types', 'choose', 'notifications'],
        priority: 6,
      ),

      // Families
      FAQ(
        id: 'families_1',
        question: 'How do I add family members to my profile?',
        answer: 'Go to Profile > Family tab and tap "Add Family Member". Enter their name, age, and interests. This helps us recommend more suitable events for your entire family.',
        category: FAQCategory.families,
        keywords: ['add', 'family', 'members', 'children'],
        priority: 8,
      ),
      FAQ(
        id: 'families_2',
        question: 'Is there content filtering for children?',
        answer: 'Yes, we automatically filter events based on the ages in your family profile. You can also enable "Family-Friendly Only" mode in settings for additional content filtering.',
        category: FAQCategory.families,
        keywords: ['filtering', 'children', 'safe', 'family-friendly'],
        priority: 7,
        isPopular: true,
      ),
      FAQ(
        id: 'families_3',
        question: 'Can I set different preferences for different children?',
        answer: 'Currently, preferences apply to the entire family profile. We\'re working on individual member preferences in a future update.',
        category: FAQCategory.families,
        keywords: ['individual', 'different', 'preferences', 'children'],
        priority: 5,
      ),

      // Technical
      FAQ(
        id: 'technical_1',
        question: 'The app is running slowly. How can I fix this?',
        answer: 'Try closing and reopening the app. If issues persist, restart your device or check for app updates in the App Store/Play Store. Clear the app cache if problems continue.',
        category: FAQCategory.technical,
        keywords: ['slow', 'performance', 'fix', 'cache'],
        priority: 6,
      ),
      FAQ(
        id: 'technical_2',
        question: 'I can\'t see some images. What\'s wrong?',
        answer: 'This usually indicates a slow internet connection. Try switching between WiFi and mobile data, or wait for a better connection. Images should load automatically once connection improves.',
        category: FAQCategory.technical,
        keywords: ['images', 'loading', 'connection', 'internet'],
        priority: 5,
      ),
      FAQ(
        id: 'technical_3',
        question: 'The app crashed. What information should I provide?',
        answer: 'When contacting support about crashes, please include: your device model, operating system version, app version, and what you were doing when it crashed. Screenshots are helpful too.',
        category: FAQCategory.technical,
        keywords: ['crash', 'bug', 'support', 'information'],
        priority: 4,
      ),

      // Privacy
      FAQ(
        id: 'privacy_1',
        question: 'How do you protect my family\'s data?',
        answer: 'We use industry-standard encryption and follow UAE data protection laws. We never share personal information with third parties without consent. Read our Privacy Policy for complete details.',
        category: FAQCategory.privacy,
        keywords: ['data', 'protection', 'privacy', 'security'],
        priority: 7,
        isPopular: true,
      ),
      FAQ(
        id: 'privacy_2',
        question: 'Do you track my location?',
        answer: 'We only use location data to show nearby events when you choose to share your location. You can disable location access anytime in your device settings.',
        category: FAQCategory.privacy,
        keywords: ['location', 'tracking', 'privacy', 'gps'],
        priority: 6,
      ),
      FAQ(
        id: 'privacy_3',
        question: 'Can I export my data?',
        answer: 'Yes, you can request a copy of your data by contacting our support team. We\'ll provide your profile information, favorites, and activity history in a readable format.',
        category: FAQCategory.privacy,
        keywords: ['export', 'data', 'download', 'copy'],
        priority: 4,
      ),

      // Safety
      FAQ(
        id: 'safety_1',
        question: 'How do you ensure event information is safe for families?',
        answer: 'All events undergo content review before being listed. We work with trusted event organizers and venues. Users can also report inappropriate content through the app.',
        category: FAQCategory.safety,
        keywords: ['safety', 'content', 'review', 'families'],
        priority: 7,
      ),
      FAQ(
        id: 'safety_2',
        question: 'What should I do if I find inappropriate content?',
        answer: 'Please report it immediately through the app or contact our support team. We take content safety very seriously and will investigate all reports quickly.',
        category: FAQCategory.safety,
        keywords: ['report', 'inappropriate', 'content', 'safety'],
        priority: 6,
      ),
    ];
  }

  static List<FAQ> getFAQsByCategory(FAQCategory category) {
    return getAllFAQs()
        .where((faq) => faq.category == category)
        .toList()
        ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  static List<FAQ> getPopularFAQs() {
    return getAllFAQs()
        .where((faq) => faq.isPopular)
        .toList()
        ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  static List<FAQ> searchFAQs(String query) {
    if (query.trim().isEmpty) return getAllFAQs();
    
    return getAllFAQs()
        .where((faq) => faq.matchesSearch(query))
        .toList()
        ..sort((a, b) => b.priority.compareTo(a.priority));
  }
}