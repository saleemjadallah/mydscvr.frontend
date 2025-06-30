import 'dart:async';
import 'dart:js' as js;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api/dio_config.dart';
import '../core/config/environment_config.dart';

/// Simplified Google Sign-In service using button-based authentication
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

  /// Wait for Google API to load with better error handling
  Future<void> _waitForGoogleAPI() async {
    var attempts = 0;
    const maxAttempts = 150; // 30 seconds total
    
    // Helper function to check if script is loaded
    bool isScriptLoaded() {
      try {
        return js.context['googleScriptLoaded'] == true;
      } catch (e) {
        return false;
      }
    }
    
    debugPrint('🔍 Starting Google API loading check...');
    debugPrint('   - Initial script loaded flag: ${isScriptLoaded()}');
    
    while (attempts < maxAttempts) {
      try {
        if (js.context.hasProperty('google') && 
            js.context['google'] != null &&
            js.context['google']['accounts'] != null &&
            js.context['google']['accounts']['id'] != null) {
          debugPrint('✅ Google API loaded successfully after ${attempts + 1} attempts (script loaded: ${isScriptLoaded()})');
          return;
        }
        
        if (attempts < 5) {
          debugPrint('⏳ Attempt ${attempts + 1}: Waiting for Google API...');
          debugPrint('   - Script loaded flag: ${isScriptLoaded()}');
          debugPrint('   - Google object: ${js.context.hasProperty('google')}');
        } else if (attempts % 10 == 0) {
          debugPrint('⏳ Still waiting for Google API (attempt ${attempts + 1}/$maxAttempts)...');
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

  /// Simplified Google Sign-In without One Tap to avoid CORS and policy issues
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      if (!kIsWeb) {
        throw Exception('This service is only for web platform');
      }

      await initialize();

      // Skip One Tap and popup complications, go directly to manual button
      debugPrint('🔄 Starting Google Sign-In with button authentication...');
      final buttonResult = await signInWithButton();
      
      if (buttonResult != null) {
        debugPrint('✅ Button authentication successful!');
        return await _verifyWithBackend(buttonResult);
      }

      // If button fails, provide helpful error
      throw Exception('Google Sign-In is not available. Please check your browser settings, disable ad blockers, and try again.');
      
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      if (e is DioException) {
        debugPrint('Dio error details: ${e.response?.data}');
        throw Exception('Authentication failed: ${e.response?.data?['message'] ?? e.message}');
      }
      rethrow;
    }
  }


  /// Manual sign-in button method for when all else fails
  Future<String?> signInWithButton() async {
    try {
      final completer = Completer<String?>();
      final callbackName = 'googleButtonCallback_${DateTime.now().millisecondsSinceEpoch}';
      
      // Set up callback function
      js.context[callbackName] = (response) {
        try {
          if (response != null && response['credential'] != null) {
            final idToken = response['credential'] as String;
            debugPrint('✅ Button sign-in credential received');
            completer.complete(idToken);
          } else {
            debugPrint('❌ No credential in button response');
            completer.complete(null);
          }
        } catch (e) {
          debugPrint('❌ Button callback error: $e');
          completer.complete(null);
        }
      };

      // Create a visible sign-in button
      js.context.callMethod('eval', ['''
        try {
          if (typeof google !== 'undefined' && google.accounts && google.accounts.id) {
            // Create a modal or overlay
            const overlay = document.createElement('div');
            overlay.style.cssText = `
              position: fixed;
              top: 0;
              left: 0;
              width: 100%;
              height: 100%;
              background: rgba(0,0,0,0.5);
              display: flex;
              justify-content: center;
              align-items: center;
              z-index: 10000;
            `;
            
            const modal = document.createElement('div');
            modal.style.cssText = `
              background: white;
              padding: 30px;
              border-radius: 10px;
              text-align: center;
              box-shadow: 0 4px 20px rgba(0,0,0,0.3);
              max-width: 400px;
              width: 90%;
            `;
            
            modal.innerHTML = `
              <h3 style="margin: 0 0 20px 0; color: #333;">Sign in with Google</h3>
              <p style="margin: 0 0 20px 0; color: #666;">Please click the button below to continue with Google Sign-In</p>
              <div id="google-signin-button-container" style="margin: 20px 0;"></div>
              <button id="cancel-signin" style="
                background: #f5f5f5;
                border: 1px solid #ddd;
                padding: 10px 20px;
                border-radius: 5px;
                cursor: pointer;
                margin-top: 10px;
              ">Cancel</button>
            `;
            
            overlay.appendChild(modal);
            document.body.appendChild(overlay);
            
            // Handle cancel button
            document.getElementById('cancel-signin').onclick = () => {
              document.body.removeChild(overlay);
              $callbackName(null);
            };
            
            // Handle overlay click to close
            overlay.onclick = (e) => {
              if (e.target === overlay) {
                document.body.removeChild(overlay);
                $callbackName(null);
              }
            };
            
            google.accounts.id.initialize({
              client_id: '$_clientId',
              callback: (response) => {
                document.body.removeChild(overlay);
                $callbackName(response);
              },
              auto_select: false,
              cancel_on_tap_outside: false
            });
            
            google.accounts.id.renderButton(
              document.getElementById('google-signin-button-container'),
              {
                theme: 'outline',
                size: 'large',
                type: 'standard',
                text: 'signin_with',
                shape: 'rectangular',
                logo_alignment: 'left'
              }
            );
            
          } else {
            console.error('❌ Google Identity Services not available for manual button');
            $callbackName(null);
          }
        } catch (error) {
          console.error('💥 Manual button setup error:', error);
          $callbackName(null);
        }
      ''']);

      // Wait for manual sign-in result
      final result = await completer.future.timeout(
        const Duration(minutes: 5), // Longer timeout for manual interaction
        onTimeout: () {
          debugPrint('⏰ Manual sign-in timeout');
          return null;
        },
      );

      // Cleanup
      js.context.deleteProperty(callbackName);
      return result;
      
    } catch (e) {
      debugPrint('❌ Manual sign-in failed: $e');
      return null;
    }
  }

  /// Verify ID token with backend
  Future<Map<String, dynamic>?> _verifyWithBackend(String idToken) async {
    try {
      debugPrint('🔐 Verifying ID token with backend...');
      
      final response = await _dio.post(
        '/auth/google/verify',
        data: {'id_token': idToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        debugPrint('✅ Backend verification successful');
        return {
          'access_token': responseData['access_token'],
          'refresh_token': responseData['refresh_token'],
          'user': responseData['user'],
        };
      } else {
        throw Exception('Backend verification failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Backend verification error: $e');
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