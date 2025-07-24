import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
// Web-specific imports
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

// Analytics service
import 'services/analytics_service.dart';

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
import 'features/help/faq_screen.dart';
import 'features/legal/contact_screen.dart';
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
      redirect: (context, state) {
        final query = state.uri.queryParameters['query'];
        return '/super-search${query != null ? "?query=$query" : ""}';
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
    
    // Legal and Help pages
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
    GoRoute(
      path: '/faq',
      builder: (context, state) => const FAQScreen(),
    ),
    GoRoute(
      path: '/contact',
      builder: (context, state) => const ContactScreen(),
    ),
  ],
);

/// Main entry point for DXB Events Flutter Web Application
void main() {
  // Configure URL strategy for clean URLs (remove # from URLs)
  usePathUrlStrategy();
  
  // Set up error handlers
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Log error to console
    if (kDebugMode) {
      print('Flutter Error: ${details.exceptionAsString()}');
      print('Stack trace: ${details.stack}');
    }
  };
  
  // Catch async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      print('Async Error: $error');
      print('Stack trace: $stack');
    }
    return true;
  };
  
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
  void initState() {
    super.initState();
    
    // Initialize analytics after Flutter app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAnalytics();
    });
  }

  /// Initialize analytics services after Flutter is ready
  Future<void> _initializeAnalytics() async {
    try {
      // Signal that Flutter is ready by dispatching a custom event
      _signalFlutterReady();
      
      await AnalyticsService.initialize();
      print('🚀 Analytics services initialized successfully');
    } catch (e) {
      print('❌ Error initializing analytics: $e');
    }
  }
  
  /// Signal to JavaScript that Flutter is ready
  void _signalFlutterReady() {
    try {
      // Dispatch custom event to notify JavaScript
      html.window.dispatchEvent(html.CustomEvent('flutter-initialized'));
      
      // Also add the class directly to body
      html.document.body?.classes.add('flutter-ready');
      
      print('🎯 Flutter ready signal sent');
    } catch (e) {
      print('Could not signal Flutter ready: $e');
    }
  }

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
      
      // Custom error widget
      builder: (context, widget) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Something went wrong',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        kDebugMode 
                          ? details.exceptionAsString()
                          : 'Please refresh the page to try again',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          html.window.location.reload();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D7377),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: Text(
                          'Refresh Page',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        };
        
        return widget!;
      },
    );
  }
}