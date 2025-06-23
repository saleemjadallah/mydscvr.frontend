import 'dart:convert';
import 'dart:async';
import 'dart:js' as js;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api/dio_config.dart';
import '../core/config/environment_config.dart';

/// Clean Google Sign-In service using One Tap API (no redirect URIs needed)
class GoogleSignInServiceClean {
  static String get _clientId => EnvironmentConfig.googleClientId;
  
  late final Dio _dio;
  bool _isInitialized = false;
  
  GoogleSignInServiceClean() {
    _dio = DioConfig.createDio();
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
    // First check if script failed to load
    try {
      if (js.context.hasProperty('googleScriptError') && js.context['googleScriptError'] == true) {
        throw Exception('Google Identity Services script failed to load. Please check your network connection and disable ad blockers.');
      }
    } catch (e) {
      // Continue if property doesn't exist
    }
    
    var attempts = 0;
    while (attempts < 150) { // Increased from 100 to 150 attempts
      try {
        // Check if script loaded successfully
        bool scriptLoaded = false;
        try {
          scriptLoaded = js.context.hasProperty('googleScriptLoaded') && js.context['googleScriptLoaded'] == true;
        } catch (e) {
          // Continue checking
        }
        
        if (js.context.hasProperty('google') && 
            js.context['google'] != null &&
            js.context['google']['accounts'] != null &&
            js.context['google']['accounts']['id'] != null) {
          debugPrint('✅ Google API loaded successfully after ${attempts + 1} attempts (script loaded: $scriptLoaded)');
          return;
        }
        
        // Special logging for the first few attempts
        if (attempts < 5) {
          debugPrint('⏳ Attempt ${attempts + 1}: Waiting for Google API...');
          debugPrint('   - Script loaded flag: $scriptLoaded');
          debugPrint('   - Google object: ${js.context.hasProperty('google')}');
        } else if (attempts % 10 == 0) {
          debugPrint('⏳ Still waiting for Google API (attempt ${attempts + 1}/150)...');
        }
        
      } catch (e) {
        if (attempts < 5) {
          debugPrint('⏳ Attempt ${attempts + 1}: Exception checking Google API ($e)');
        }
      }
      
      await Future.delayed(const Duration(milliseconds: 200));
      attempts++;
    }
    
    debugPrint('❌ Google API failed to load after ${attempts} attempts');
    debugPrint('🔧 Troubleshooting tips:');
    debugPrint('   1. Check if ad blockers are blocking Google scripts');
    debugPrint('   2. Verify network connectivity');
    debugPrint('   3. Try refreshing the page');
    debugPrint('   4. Check browser console for errors');
    
    throw Exception('Google API failed to load after ${attempts} attempts. Please check your network connection, disable ad blockers, and refresh the page.');
  }

  /// Clean Google Sign-In using One Tap (no redirect URI needed)
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      if (!kIsWeb) {
        throw Exception('This service is only for web platform');
      }

      await initialize();

      final completer = Completer<String?>();
      
      // Create unique callback name
      final callbackName = 'googleOneTapCallback_${DateTime.now().millisecondsSinceEpoch}';
      
      // Set up the callback function
      js.context[callbackName] = (response) {
        try {
          debugPrint('Google One Tap response received');
          if (response != null && response['credential'] != null) {
            final idToken = response['credential'] as String;
            debugPrint('ID Token received: ${idToken.substring(0, 20)}...');
            completer.complete(idToken);
          } else {
            debugPrint('No credential in response');
            completer.complete(null);
          }
        } catch (e) {
          debugPrint('Callback processing error: $e');
          completer.complete(null);
        }
      };

      try {
        // Initialize Google One Tap - this doesn't use redirect URIs
        js.context.callMethod('eval', ['''
          try {
            console.log('🔍 Setting up Google One Tap...');
            console.log('🔧 Client ID:', '$_clientId');
            console.log('🔧 Callback function:', '$callbackName');
            
            if (typeof google !== 'undefined' && google.accounts && google.accounts.id) {
              console.log('✅ Google Identity Services available');
              
              // Initialize One Tap - no redirect URI needed
              google.accounts.id.initialize({
                client_id: '$_clientId',
                callback: $callbackName,
                auto_select: true, // Changed to true for automatic sign-in
                cancel_on_tap_outside: false,
                use_fedcm_for_prompt: false,
                itp_support: true
              });
              
              console.log('✅ Google One Tap initialized, prompting user...');
              
              // Show One Tap prompt
              google.accounts.id.prompt((notification) => {
                console.log('📋 One Tap notification:', notification.getMomentType());
                
                if (notification.isNotDisplayed()) {
                  console.log('⚠️ One Tap not displayed - reason:', notification.getNotDisplayedReason());
                  // Directly call the callback with null instead of showing another button
                  console.log('🔄 One Tap failed, calling callback with null');
                  $callbackName(null);
                } else if (notification.isSkippedMoment()) {
                  console.log('👤 User skipped One Tap');
                  $callbackName(null);
                } else if (notification.isDismissedMoment()) {
                  console.log('❌ User dismissed One Tap');
                  $callbackName(null);
                }
              });
              
            } else {
              console.error('❌ Google Identity Services not available');
              console.log('🔍 Google object:', typeof google);
              console.log('🔍 Google.accounts:', typeof google?.accounts);
              console.log('🔍 Google.accounts.id:', typeof google?.accounts?.id);
              throw new Error('Google Identity Services not available');
            }
          } catch (error) {
            console.error('💥 Google One Tap setup error:', error);
            console.error('💥 Error stack:', error.stack);
            throw error;
          }
        ''']);

        debugPrint('Waiting for Google One Tap response...');

        // Wait for the result with generous timeout
        final idToken = await completer.future.timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            debugPrint('Google One Tap timeout');
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
        throw Exception('Google Sign-In setup failed: $jsError');
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
    return false;
  }
}