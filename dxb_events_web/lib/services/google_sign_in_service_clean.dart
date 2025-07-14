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
  
  /// Sign in with Google
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        // Get authentication details
        final GoogleSignInAuthentication auth = await account.authentication;
        return account;
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