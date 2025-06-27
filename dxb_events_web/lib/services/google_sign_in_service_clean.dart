import 'dart:convert';
import 'dart:async';
import 'dart:js' as js;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api/dio_config.dart';
import '../core/config/environment_config.dart';

/// Clean Google Sign-In service using One Tap API with fallback methods
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

  /// Improved Google Sign-In with graceful One Tap handling and fallbacks
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      if (!kIsWeb) {
        throw Exception('This service is only for web platform');
      }

      await initialize();

      // Try One Tap first, but don't fail if it doesn't work
      debugPrint('🔍 Attempting Google One Tap...');
      final oneTapResult = await _tryOneTap();
      
      if (oneTapResult != null) {
        debugPrint('✅ One Tap successful!');
        return await _verifyWithBackend(oneTapResult);
      }

      // If One Tap fails, try popup authentication
      debugPrint('🔄 One Tap failed, trying popup authentication...');
      final popupResult = await _tryPopupAuth();
      
      if (popupResult != null) {
        debugPrint('✅ Popup authentication successful!');
        return await _verifyWithBackend(popupResult);
      }

      // If popup fails, try manual button as final fallback
      debugPrint('🔄 Popup failed, showing manual sign-in button...');
      final buttonResult = await signInWithButton();
      
      if (buttonResult != null) {
        debugPrint('✅ Manual button authentication successful!');
        return await _verifyWithBackend(buttonResult);
      }

      // If all methods fail, provide helpful error
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

  /// Try Google One Tap (silent, non-intrusive)
  Future<String?> _tryOneTap() async {
    try {
      final completer = Completer<String?>();
      final callbackName = 'googleOneTapCallback_${DateTime.now().millisecondsSinceEpoch}';
      
      // Set up callback function
      js.context[callbackName] = (response) {
        try {
          if (response != null && response['credential'] != null) {
            final idToken = response['credential'] as String;
            debugPrint('✅ One Tap credential received');
            completer.complete(idToken);
          } else {
            debugPrint('❌ No credential in One Tap response');
            completer.complete(null);
          }
        } catch (e) {
          debugPrint('❌ One Tap callback error: $e');
          completer.complete(null);
        }
      };

      // Initialize One Tap
      js.context.callMethod('eval', ['''
        try {
          if (typeof google !== 'undefined' && google.accounts && google.accounts.id) {
            google.accounts.id.initialize({
              client_id: '$_clientId',
              callback: $callbackName,
              auto_select: false,
              cancel_on_tap_outside: false,
              use_fedcm_for_prompt: false,
              itp_support: true
            });
            
            google.accounts.id.prompt((notification) => {
              const momentType = notification.getMomentType();
              console.log('📋 One Tap notification:', momentType);
              
              if (notification.isNotDisplayed()) {
                console.log('⚠️ One Tap not displayed - reason:', notification.getNotDisplayedReason());
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
            console.error('❌ Google Identity Services not available for One Tap');
            $callbackName(null);
          }
        } catch (error) {
          console.error('💥 One Tap setup error:', error);
          $callbackName(null);
        }
      ''']);

      // Wait for One Tap result (shorter timeout since it should be quick)
      final result = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏰ One Tap timeout');
          return null;
        },
      );

      // Cleanup
      js.context.deleteProperty(callbackName);
      return result;
      
    } catch (e) {
      debugPrint('❌ One Tap attempt failed: $e');
      return null;
    }
  }

  /// Try popup-based authentication as fallback
  Future<String?> _tryPopupAuth() async {
    try {
      final completer = Completer<String?>();
      final callbackName = 'googlePopupCallback_${DateTime.now().millisecondsSinceEpoch}';
      
      // Set up callback function
      js.context[callbackName] = (response) {
        try {
          if (response != null && response['credential'] != null) {
            final idToken = response['credential'] as String;
            debugPrint('✅ Popup credential received');
            completer.complete(idToken);
          } else {
            debugPrint('❌ No credential in popup response');
            completer.complete(null);
          }
        } catch (e) {
          debugPrint('❌ Popup callback error: $e');
          completer.complete(null);
        }
      };

      // Try to render a hidden button and click it programmatically
      js.context.callMethod('eval', ['''
        try {
          if (typeof google !== 'undefined' && google.accounts && google.accounts.id) {
            // Create a temporary container
            const tempContainer = document.createElement('div');
            tempContainer.style.position = 'absolute';
            tempContainer.style.left = '-9999px';
            tempContainer.style.visibility = 'hidden';
            document.body.appendChild(tempContainer);
            
            google.accounts.id.initialize({
              client_id: '$_clientId',
              callback: $callbackName,
              auto_select: false,
              cancel_on_tap_outside: false
            });
            
            google.accounts.id.renderButton(tempContainer, {
              theme: 'outline',
              size: 'large',
              type: 'standard'
            });
            
            // Try to trigger the button programmatically
            setTimeout(() => {
              const button = tempContainer.querySelector('div[role="button"]');
              if (button) {
                console.log('🔘 Triggering Google Sign-In button...');
                button.click();
              } else {
                console.log('❌ Could not find Google Sign-In button');
                $callbackName(null);
              }
              
              // Cleanup after a delay
              setTimeout(() => {
                if (document.body.contains(tempContainer)) {
                  document.body.removeChild(tempContainer);
                }
              }, 1000);
            }, 100);
            
          } else {
            console.error('❌ Google Identity Services not available for popup');
            $callbackName(null);
          }
        } catch (error) {
          console.error('💥 Popup setup error:', error);
          $callbackName(null);
        }
      ''']);

      // Wait for popup result
      final result = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏰ Popup authentication timeout');
          return null;
        },
      );

      // Cleanup
      js.context.deleteProperty(callbackName);
      return result;
      
    } catch (e) {
      debugPrint('❌ Popup authentication failed: $e');
      return null;
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