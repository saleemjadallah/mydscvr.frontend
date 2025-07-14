import 'dart:convert';
import 'dart:async';
import 'dart:js' as js;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/config/environment_config.dart';

/// Simplified Google Sign-In service using pure client-side flow
class GoogleSignInServiceSimple {
  static String get _clientId => EnvironmentConfig.googleClientId;
  static String get _baseUrl => EnvironmentConfig.getApiBaseUrl();
  
  late final Dio _dio;
  bool _isInitialized = false;
  
  GoogleSignInServiceSimple() {
    _dio = Dio();
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// Initialize Google Sign-In for web
  Future<void> initialize() async {
    try {
      if (kIsWeb && !_isInitialized) {
        await _waitForGoogleAPI();
        _isInitialized = true;
        debugPrint('Google Sign-In initialized for web');
      }
    } catch (e) {
      debugPrint('Error initializing Google Sign-In: $e');
    }
  }

  /// Wait for Google API to load
  Future<void> _waitForGoogleAPI() async {
    var attempts = 0;
    while (attempts < 50) {
      try {
        if (js.context.hasProperty('google') && 
            js.context['google'] != null &&
            js.context['google']['accounts'] != null) {
          return;
        }
      } catch (e) {
        // Continue waiting
      }
      
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    throw Exception('Google API failed to load');
  }

  /// Pure client-side Google Sign-In
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      if (!kIsWeb) {
        throw Exception('This service is only for web platform');
      }

      await initialize();

      final completer = Completer<String?>();
      
      // Create unique callback name to avoid conflicts
      final callbackName = 'googleCallback_${DateTime.now().millisecondsSinceEpoch}';
      
      // Set up the callback function
      js.context[callbackName] = (credential) {
        try {
          if (credential != null && credential['credential'] != null) {
            completer.complete(credential['credential'] as String);
          } else {
            completer.complete(null);
          }
        } catch (e) {
          debugPrint('Callback error: $e');
          completer.complete(null);
        }
      };

      try {
        // Initialize Google Identity Services with no redirect URI
        js.context.callMethod('eval', ['''
          try {
            if (typeof google !== 'undefined' && google.accounts && google.accounts.id) {
              console.log('Initializing Google Identity Services...');
              
              google.accounts.id.initialize({
                client_id: '$_clientId',
                callback: $callbackName,
                auto_select: false,
                cancel_on_tap_outside: false,
                use_fedcm_for_prompt: false
              });
              
              console.log('Google Identity Services initialized, prompting...');
              
              // Use the prompt method for sign-in
              google.accounts.id.prompt((notification) => {
                console.log('Prompt notification:', notification);
                if (notification.isNotDisplayed() || notification.isSkippedMoment()) {
                  console.log('Prompt not displayed, showing alternative...');
                  // If prompt fails, we'll handle in timeout
                }
              });
              
            } else {
              console.error('Google Identity Services not available');
              throw new Error('Google Identity Services not loaded');
            }
          } catch (error) {
            console.error('Google Sign-In initialization error:', error);
            throw error;
          }
        ''']);

        // Wait for the result with longer timeout
        final idToken = await completer.future.timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            debugPrint('Google Sign-In timeout - no response received');
            return null;
          },
        );

        // Cleanup
        js.context.deleteProperty(callbackName);
        
        if (idToken == null || idToken.isEmpty) {
          throw Exception('Google Sign-In was cancelled or failed');
        }

        debugPrint('Google Sign-In successful, verifying with backend...');

        // Send ID token to backend for verification
        final response = await _dio.post(
          '/auth/google/verify',
          data: {'id_token': idToken},
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ),
        );

        if (response.statusCode == 200) {
          final responseData = response.data;
          debugPrint('Backend verification successful');
          return {
            'access_token': responseData['access_token'],
            'refresh_token': responseData['refresh_token'],
            'user': responseData['user'],
          };
        } else {
          throw Exception('Backend verification failed: ${response.statusCode}');
        }
        
      } catch (jsError) {
        js.context.deleteProperty(callbackName);
        debugPrint('JavaScript error during Google Sign-In: $jsError');
        throw Exception('Google Sign-In initialization failed: $jsError');
      }
      
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      if (e is DioException) {
        debugPrint('Dio error details: ${e.response?.data}');
        throw Exception('Authentication failed: ${e.response?.data?['message'] ?? e.message}');
      }
      rethrow;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      if (kIsWeb && _isInitialized) {
        js.context.callMethod('eval', ['''
          if (typeof google !== 'undefined' && google.accounts && google.accounts.id) {
            google.accounts.id.disableAutoSelect();
          }
        ''']);
      }
      debugPrint('Google Sign-Out successful');
    } catch (e) {
      debugPrint('Google Sign-Out error: $e');
    }
  }

  /// Check if user is signed in
  Future<bool> isSignedIn() async {
    return false; // For simplicity, always return false
  }
}