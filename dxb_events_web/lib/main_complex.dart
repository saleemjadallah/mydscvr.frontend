import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

// Core imports
// import 'core/themes/app_theme.dart'; // REMOVED FOR MINIMAL TEST

// Feature imports
// import 'features/home/home_screen_animated.dart'; // DISABLED FOR DEBUGGING
import 'features/home/home_screen_minimal.dart';
import 'features/events/events_list_screen.dart';
import 'features/event_details/event_details_screen.dart';
import 'features/search/ai_search_screen.dart';
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
// import 'debug_events_page.dart'; // REMOVED FOR MINIMAL TEST
// import 'core/widgets/error_boundary.dart'; // REMOVED FOR MINIMAL TEST  
// import 'core/debug/debug_config.dart'; // REMOVED FOR MINIMAL TEST

// Ultra-minimal router for testing
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MinimalHomeScreen(),
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
      path: '/debug',
      builder: (context, state) => const DebugEventsPage(),
    ),
    GoRoute(
      path: '/ai-search',
      builder: (context, state) {
        final query = state.uri.queryParameters['query'];
        return AISearchScreen(initialQuery: query);
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
  // Initialize debug configuration
  DebugConfig.initialize();
  
  // Configure URL strategy for clean URLs (remove # from URLs)
  usePathUrlStrategy();
  
  runApp(
    ErrorBoundary(
      fallbackMessage: 'Application crashed. Please refresh the page.',
      onError: () {
        print('🚨 CRITICAL: Application-level error caught by ErrorBoundary');
      },
      child: ProviderScope(
        child: const DXBEventsApp(),
      ),
    ),
  );
}

/// Root application widget with Riverpod state management
class DXBEventsApp extends ConsumerStatefulWidget {
  const DXBEventsApp({super.key});

  @override
  ConsumerState<DXBEventsApp> createState() => _DXBEventsAppState();
}

class _DXBEventsAppState extends ConsumerState<DXBEventsApp> {
  @override
  Widget build(BuildContext context) {
    // Use default values for theme preferences
    const isDarkMode = false;
    const textScale = 1.0;
    const reduceAnimations = false;
    
    return MaterialApp.router(
              title: 'MyDscvr - Discover Dubai Events',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      
      // Theme configuration
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          fontSizeFactor: textScale,
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: reduceAnimations 
            ? {
                // Disable animations for accessibility
                TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
                TargetPlatform.linux: const FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
                TargetPlatform.windows: const FadeUpwardsPageTransitionsBuilder(),
              }
            : const {
                // Default animations
                TargetPlatform.android: ZoomPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.linux: ZoomPageTransitionsBuilder(),
                TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.windows: ZoomPageTransitionsBuilder(),
              },
        ),
      ),
      
      darkTheme: AppTheme.darkTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          fontSizeFactor: textScale,
        ),
      ),
      
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // Localization settings
      locale: const Locale('en', 'US'),
    );
  }
}

/// Development configuration provider
final isDevelopmentProvider = Provider<bool>((ref) {
  return const bool.fromEnvironment('dart.vm.product') == false;
});

/// App version provider
final appVersionProvider = Provider<String>((ref) {
  return '1.0.0'; // This would normally come from pubspec.yaml
});

/// Network status provider (for future offline support)
final networkStatusProvider = StateProvider<bool>((ref) {
  return true; // Always online for web, but can be extended
});
