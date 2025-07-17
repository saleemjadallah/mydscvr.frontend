import 'dart:convert';
import 'dart:html' as html;
import 'dart:async';
import 'dart:js' as js;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/config/environment_config.dart';

/// Google Sign-In service for web authentication
class GoogleSignInService {
  static String get _clientId => EnvironmentConfig.googleClientId;
  static String get _baseUrl => EnvironmentConfig.getApiBaseUrl();
  
  late final Dio _dio;
  bool _isInitialized = false;
  
  GoogleSignInService() {
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

  /// Sign in with Google and get backend tokens
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      if (!kIsWeb) {
        throw Exception('This service is only for web platform');
      }

      await initialize();

      // Create a completer to handle the async callback
      final completer = Completer<String?>();
      
      // Set up the credential callback
      js.context['handleCredentialResponse'] = (credential) {
        final credentialObj = credential as Map<String, dynamic>;
        final idToken = credentialObj['credential'] as String?;
        completer.complete(idToken);
      };

      // Initialize Google Identity Services
      try {
        js.context.callMethod('eval', ['''
          if (typeof google !== 'undefined' && google.accounts) {
            google.accounts.id.initialize({
              client_id: '$_clientId',
              callback: handleCredentialResponse,
              auto_select: false,
              cancel_on_tap_outside: true
            });
            
            // Show the One Tap prompt
            google.accounts.id.prompt((notification) => {
              if (notification.isNotDisplayed() || notification.isSkippedMoment()) {
                // One Tap was not displayed or skipped, show popup instead
                const popup = google.accounts.oauth2.initTokenClient({
                  client_id: '$_clientId',
                  scope: 'email profile',
                  callback: (tokenResponse) => {
                    // This won't work for our use case, we need ID token
                  }
                });
                // popup.requestAccessToken();
                
                // Instead, let's render a sign-in button
                google.accounts.id.renderButton(
                  document.createElement('div'),
                  { theme: 'outline', size: 'large' }
                );
                
                // Or prompt again
                setTimeout(() => google.accounts.id.prompt(), 1000);
              }
            });
          } else {
            throw new Error('Google Identity Services not available');
          }
        ''']);

        // Wait for the result with a timeout
        final idToken = await completer.future.timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            debugPrint('Google Sign-In timeout');
            return null;
          },
        );
        
        if (idToken == null) {
          throw Exception('Google Sign-In was cancelled or timed out');
        }

        debugPrint('Google Sign-In successful, verifying with backend...');

        // Send ID token to backend for verification
        final response = await _dio.post(
          '/auth/google/verify',
          data: {
            'id_token': idToken,
          },
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
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
        debugPrint('JavaScript error: $jsError');
        throw Exception('Google Sign-In initialization failed');
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

  /// Pure client-side Google Sign-In without redirect URIs
  Future<Map<String, dynamic>?> signInWithGooglePopup() async {
    try {
      if (!kIsWeb) {
        throw Exception('This service is only for web platform');
      }

      await initialize();

      // Create a more reliable popup-based authentication
      final completer = Completer<String?>();
      
      // Create a unique callback name
      final callbackName = 'googleSignInCallback_${DateTime.now().millisecondsSinceEpoch}';
      
      js.context[callbackName] = (credential) {
        try {
          final credentialObj = credential as Map<String, dynamic>;
          final idToken = credentialObj['credential'] as String?;
          completer.complete(idToken);
        } catch (e) {
          completer.complete(null);
        }
      };

      try {
        // Use a more direct approach with renderButton
        final buttonContainer = html.DivElement();
        html.document.body?.append(buttonContainer);
        
        js.context.callMethod('eval', ['''
          try {
            if (typeof google !== 'undefined' && google.accounts && google.accounts.id) {
              
              // Initialize without redirect URI - pure client-side
              google.accounts.id.initialize({
                client_id: '$_clientId',
                callback: $callbackName,
                auto_select: false,
                cancel_on_tap_outside: false,
                use_fedcm_for_prompt: false,
                itp_support: true
              });
              
              
              // Use prompt method which doesn't require redirect URI
              google.accounts.id.prompt((notification) => {
                if (notification.isNotDisplayed()) {
                  // Don't retry automatically
                } else if (notification.isSkippedMoment()) {
                  // User chose not to sign in
                }
              });
              
            } else {
              throw new Error('Google Identity Services not loaded');
            }
          } catch (error) {
            throw error;
          }
        ''']);

        // Wait for the result
        final idToken = await completer.future.timeout(
          const Duration(seconds: 45),
          onTimeout: () => null,
        );

        // Cleanup
        buttonContainer.remove();
        js.context.deleteProperty(callbackName);
        
        if (idToken == null) {
          throw Exception('Google Sign-In was cancelled or failed');
        }

        // Send to backend for verification
        final response = await _dio.post(
          '/auth/google/verify',
          data: {'id_token': idToken},
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ),
        );

        if (response.statusCode == 200) {
          final responseData = response.data;
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
        throw Exception('Google Sign-In failed: $jsError');
      }
      
    } catch (e) {
      debugPrint('Google Sign-In popup error: $e');
      rethrow;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      if (kIsWeb && _isInitialized) {
        js.context.callMethod('eval', ['''
          if (typeof google !== 'undefined' && google.accounts) {
            google.accounts.id.disableAutoSelect();
          }
        ''']);
      }
      debugPrint('Google Sign-Out successful');
    } catch (e) {
      debugPrint('Google Sign-Out error: $e');
      // Don't throw error for sign out failures
    }
  }

  /// Check if user is currently signed in with Google
  Future<bool> isSignedIn() async {
    try {
      // For web, we can't easily check this without more complex state management
      return false;
    } catch (e) {
      debugPrint('Error checking Google Sign-In status: $e');
      return false;
    }
  }
}