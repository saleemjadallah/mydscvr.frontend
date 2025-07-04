import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

// Feature imports
import 'features/home/home_screen_beautiful.dart';
import 'features/events/events_list_screen.dart';
import 'features/event_details/event_details_screen.dart';
import 'features/search/ai_search_screen.dart';
import 'features/search/super_search_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/otp_verification_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/reset_password_screen.dart';
import 'features/legal/terms_screen.dart';
import 'features/legal/privacy_screen.dart';
import 'features/legal/cookies_screen.dart';
import 'features/favorites/favorites_screen.dart';

// Comprehensive router with beautiful home screen
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const BeautifulHomeScreen(),
    ),
    GoRoute(
      path: '/events',
      builder: (context, state) {
        final query = state.uri.queryParameters['query'];
        return EventsListScreen(
          initialSearchQuery: query,
        );
      },
    ),
    GoRoute(
      path: '/ai-search',
      builder: (context, state) {
        final query = state.uri.queryParameters['query'];
        return AISearchScreen(initialQuery: query);
      },
    ),
    GoRoute(
      path: '/super-search',
      builder: (context, state) {
        final query = state.uri.queryParameters['query'];
        return SuperSearchScreen(initialQuery: query);
      },
    ),
    
    // Onboarding route
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    
    // Profile route
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    
    // Favorites route
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    
    // Auth routes
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/verify-email',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return OTPVerificationScreen(email: email);
      },
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return ResetPasswordScreen(email: email);
      },
    ),
    
    // Event detail route
    GoRoute(
      path: '/event/:eventId',
      builder: (context, state) {
        final eventId = state.pathParameters['eventId']!;
        return EventDetailsScreen(eventId: eventId);
      },
    ),
    
    // Category-specific routes
    GoRoute(
      path: '/food-and-dining',
      builder: (context, state) => const EventsListScreen(
        initialCategory: 'food_and_dining',
        categoryDisplayName: 'Food & Dining',
      ),
    ),
    GoRoute(
      path: '/kids-and-family',
      builder: (context, state) => const EventsListScreen(
        initialCategory: 'kids_and_family', 
        categoryDisplayName: 'Kids & Family',
      ),
    ),
    GoRoute(
      path: '/indoor-activities',
      builder: (context, state) => const EventsListScreen(
        initialCategory: 'indoor_activities',
        categoryDisplayName: 'Indoor Activities',
      ),
    ),
    GoRoute(
      path: '/outdoor-activities',
      builder: (context, state) => const EventsListScreen(
        initialCategory: 'outdoor_activities',
        categoryDisplayName: 'Outdoor Activities',
      ),
    ),
    GoRoute(
      path: '/cultural',
      builder: (context, state) => const EventsListScreen(
        initialCategory: 'cultural',
        categoryDisplayName: 'Cultural Events',
      ),
    ),
    GoRoute(
      path: '/tours-and-sightseeing',
      builder: (context, state) => const EventsListScreen(
        initialCategory: 'tours_and_sightseeing',
        categoryDisplayName: 'Tours & Sightseeing',
      ),
    ),
    GoRoute(
      path: '/water-sports',
      builder: (context, state) => const EventsListScreen(
        initialCategory: 'water_sports',
        categoryDisplayName: 'Water Sports',
      ),
    ),
    GoRoute(
      path: '/music-and-concerts',
      builder: (context, state) => const EventsListScreen(
        initialCategory: 'music_and_concerts',
        categoryDisplayName: 'Music & Concerts',
      ),
    ),
    GoRoute(
      path: '/entertainment',
      builder: (context, state) => const EventsListScreen(
        initialCategory: 'entertainment',
        categoryDisplayName: 'Entertainment',
      ),
    ),
    GoRoute(
      path: '/comedy-and-shows',
      builder: (context, state) => const EventsListScreen(
        initialCategory: 'comedy_and_shows',
        categoryDisplayName: 'Comedy & Shows',
      ),
    ),
    GoRoute(
      path: '/sports-and-fitness',
      builder: (context, state) => const EventsListScreen(
        initialCategory: 'sports_and_fitness',
        categoryDisplayName: 'Sports & Fitness',
      ),
    ),
    GoRoute(
      path: '/business-and-networking',
      builder: (context, state) => const EventsListScreen(
        initialCategory: 'business_and_networking',
        categoryDisplayName: 'Business & Networking',
      ),
    ),
    GoRoute(
      path: '/festivals-and-celebrations',
      builder: (context, state) => const EventsListScreen(
        initialCategory: 'festivals_and_celebrations',
        categoryDisplayName: 'Festivals & Celebrations',
      ),
    ),
    
    // Legal pages
    GoRoute(
      path: '/terms',
      builder: (context, state) => const TermsScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyScreen(),
    ),
    GoRoute(
      path: '/cookies',
      builder: (context, state) => const CookiesScreen(),
    ),
  ],
);

/// Main entry point for DXB Events Flutter Web Application
void main() {
  // Configure URL strategy for clean URLs (remove # from URLs)
  usePathUrlStrategy();
  
  runApp(
    ProviderScope(
      child: const DXBEventsApp(),
    ),
  );
}

/// Root application widget with comprehensive routing
class DXBEventsApp extends ConsumerStatefulWidget {
  const DXBEventsApp({super.key});

  @override
  ConsumerState<DXBEventsApp> createState() => _DXBEventsAppState();
}

class _DXBEventsAppState extends ConsumerState<DXBEventsApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MyDscvr - Discover Dubai Events',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      
      // Theme configuration
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D7377), // Dubai teal
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: ZoomPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      
      // Localization settings
      locale: const Locale('en', 'US'),
    );
  }
}