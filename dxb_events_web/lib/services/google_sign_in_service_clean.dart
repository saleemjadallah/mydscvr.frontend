import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';

/// Service for handling Google Sign In authentication
class GoogleSignInServiceClean {
  late final GoogleSignIn _googleSignIn;
  
  GoogleSignInServiceClean() {
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'profile',
      ],
    );
  }
  
  /// Initialize the Google Sign In service
  Future<void> initialize() async {
    // Initialization logic if needed
  }
  
  /// Sign in with Google and return auth data as Map
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        // Get authentication details
        final GoogleSignInAuthentication auth = await account.authentication;
        
        // Return data in the format expected by auth provider
        return {
          'access_token': auth.accessToken,
          'refresh_token': auth.idToken, // Using idToken as refresh token
          'session_token': auth.idToken,
          'user': {
            'id': account.id,
            'email': account.email,
            'name': account.displayName ?? '',
            'photoUrl': account.photoUrl,
          }
        };
      }
      return null;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }
  
  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error signing out from Google: $e');
    }
  }
  
  /// Get the current signed in account
  GoogleSignInAccount? get currentAccount => _googleSignIn.currentUser;
  
  /// Check if user is signed in
  bool get isSignedIn => _googleSignIn.currentUser != null;
}