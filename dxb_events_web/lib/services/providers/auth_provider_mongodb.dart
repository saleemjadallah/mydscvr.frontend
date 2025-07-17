import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../auth_api_service.dart';
import '../google_sign_in_service_clean.dart';

/// Authentication state enumeration
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Authentication state class
class AuthState {
  final AuthStatus status;
  final UserProfile? user;
  final String? error;
  final String? accessToken;
  final String? sessionToken;
  final bool requiresVerification;
  final String? pendingVerificationEmail;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.accessToken,
    this.sessionToken,
    this.requiresVerification = false,
    this.pendingVerificationEmail,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    String? error,
    String? accessToken,
    String? sessionToken,
    bool? requiresVerification,
    String? pendingVerificationEmail,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      accessToken: accessToken ?? this.accessToken,
      sessionToken: sessionToken ?? this.sessionToken,
      requiresVerification: requiresVerification ?? this.requiresVerification,
      pendingVerificationEmail: pendingVerificationEmail ?? this.pendingVerificationEmail,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null && !requiresVerification;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error && error != null;
  bool get needsEmailVerification => requiresVerification && pendingVerificationEmail != null;
}

/// MongoDB-based authentication notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApiService _authService;
  final GoogleSignInServiceClean _googleSignInService;

  AuthNotifier(this._authService, this._googleSignInService) : super(const AuthState()) {
    _initializeAuth();
    _googleSignInService.initialize();
  }

  /// Initialize authentication state from stored data
  Future<void> _initializeAuth() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      print('🔄 Initializing authentication...');
      
      // First, try to get cached user data
      final cachedUser = await _authService.getCachedUser();
      final accessToken = await _authService.getAccessToken();
      final sessionToken = await _authService.getSessionToken();
      
      print('🔄 Cached user: ${cachedUser?.email}');
      print('🔄 Access token exists: ${accessToken != null}');
      print('🔄 Session token exists: ${sessionToken != null}');
      
      if (cachedUser != null && accessToken != null) {
        // We have cached user data and tokens, authenticate immediately
        print('✅ Restoring session from cache');
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: cachedUser,
          accessToken: accessToken,
          sessionToken: sessionToken,
        );
      } else if (accessToken != null) {
        // We have tokens but no cached user, try to fetch from API
        print('🔄 Fetching user from API...');
        final user = await _authService.getCurrentUser();
        if (user != null) {
          print('✅ User fetched from API successfully');
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            accessToken: accessToken,
            sessionToken: sessionToken,
          );
        } else {
          print('❌ Failed to fetch user from API, clearing tokens');
          await _authService.clearTokens();
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      } else {
        print('ℹ️ No tokens found, user not authenticated');
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      print('❌ Error during auth initialization: $e');
      // Clear potentially corrupted data
      await _authService.clearTokens();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Failed to restore session: $e',
      );
    }
  }

  /// Login with email and password
  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final result = await _authService.login(email: email, password: password);
      
      if (result.isSuccess) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.user,
          accessToken: result.accessToken,
          sessionToken: result.sessionToken,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          error: result.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Login failed: $e',
      );
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final result = await _authService.register(
        email: email,
        password: password,
        fullName: '${firstName ?? ''} ${lastName ?? ''}'.trim(),
        phoneNumber: phoneNumber,
      );
      
      if (result.isSuccess) {
        // Registration successful, user needs to verify email via OTP
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          requiresVerification: true,
          pendingVerificationEmail: email,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          error: result.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Registration failed: $e',
      );
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      print('🔵 Starting Google Sign-In...');
      final googleResult = await _googleSignInService.signInWithGoogle();
      
      if (googleResult != null) {
        
        // Extract user data from Google response
        final user = UserProfile.fromJson(googleResult['user']);
        
        // Get session token from either refresh_token or session_token field
        final sessionToken = googleResult['refresh_token'] ?? googleResult['session_token'] ?? '';
        
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          accessToken: googleResult['access_token'],
          sessionToken: sessionToken,
          error: null,
        );
        
        // Store tokens for persistence
        print('🔵 Storing tokens for persistence...');
        await _authService.saveTokens(
          googleResult['access_token'],
          sessionToken,
        );
        
        // Cache user data for persistence
        print('🔵 Caching user data...');
        await _authService.cacheUser(user);
        
        print('✅ Google Sign-In completed successfully');
        return true;
      } else {
        print('❌ Google Sign-In returned null result');
        state = state.copyWith(
          status: AuthStatus.error,
          error: 'Google Sign-In was cancelled or failed',
        );
        return false;
      }
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Google Sign-In failed: $e',
      );
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _authService.logout();
      await _googleSignInService.signOut(); // Also sign out from Google
    } catch (e) {
      print('Logout error: $e');
    }
    
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? avatar,
    Map<String, bool>? privacySettings,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final result = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        avatar: avatar,
        privacySettings: privacySettings,
      );
      
      if (result.isSuccess) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.user,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          error: result.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Profile update failed: $e',
      );
      return false;
    }
  }

  /// Complete onboarding process
  Future<bool> completeOnboarding({
    required List<Map<String, dynamic>> familyMembers,
    required Map<String, dynamic> preferences,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final result = await _authService.completeOnboarding(
        familyMembers: familyMembers,
        preferences: preferences,
      );
      
      if (result.isSuccess) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.user,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          error: result.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Onboarding completion failed: $e',
      );
      return false;
    }
  }

  /// Validate onboarding step
  Future<bool> validateOnboardingStep({
    required int step,
    required Map<String, dynamic> data,
  }) async {
    try {
      final result = await _authService.validateOnboardingStep(
        step: step,
        data: data,
      );
      
      if (!result.isSuccess) {
        state = state.copyWith(
          status: state.status,
          error: result.message,
        );
      }
      
      return result.isSuccess;
    } catch (e) {
      state = state.copyWith(
        status: state.status,
        error: 'Validation failed: $e',
      );
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final result = await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      
      if (result.isSuccess) {
        // Password change logs out all sessions, so update state
        state = const AuthState(status: AuthStatus.unauthenticated);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          error: result.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Password change failed: $e',
      );
      return false;
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    try {
      print('🔄 Refreshing user data...');
      final user = await _authService.getCurrentUser();
      if (user != null) {
        print('🔄 Updated user data - hearted: ${user.heartedEvents?.length ?? 0}, saved: ${user.savedEvents?.length ?? 0}');
        state = state.copyWith(user: user);
      } else {
        print('🔄 No user data available, logging out');
        // User data not available, logout
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      print('❌ Error refreshing user: $e');
    }
  }

  /// Check authentication status
  Future<bool> checkAuthStatus() async {
    try {
      return await _authService.isLoggedIn();
    } catch (e) {
      return false;
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Event Interaction Methods
  Future<bool> heartEvent(String eventId) async {
    try {
      print('💖 Attempting to heart event: $eventId');
      final result = await _authService.heartEvent(eventId);
      print('💖 Heart API result: ${result.isSuccess}, message: ${result.message}');
      
      if (result.isSuccess) {
        // Refresh user data to get updated hearted events
        print('💖 Refreshing user data after hearting...');
        await refreshUser();
        final updatedUser = state.user;
        print('💖 Updated hearted events: ${updatedUser?.heartedEvents}');
        return true;
      } else {
        print('❌ Failed to heart event: ${result.message}');
        state = state.copyWith(error: result.message);
        return false;
      }
    } catch (e) {
      print('❌ Exception while hearting event: $e');
      state = state.copyWith(error: 'Failed to heart event: $e');
      return false;
    }
  }

  Future<bool> unheartEvent(String eventId) async {
    try {
      final result = await _authService.unheartEvent(eventId);
      
      if (result.isSuccess) {
        // Refresh user data to get updated hearted events
        await refreshUser();
        return true;
      } else {
        state = state.copyWith(error: result.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to unheart event: $e');
      return false;
    }
  }

  Future<bool> saveEvent(String eventId) async {
    try {
      final result = await _authService.saveEvent(eventId);
      
      if (result.isSuccess) {
        // Refresh user data to get updated saved events
        await refreshUser();
        return true;
      } else {
        state = state.copyWith(error: result.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to save event: $e');
      return false;
    }
  }

  Future<bool> unsaveEvent(String eventId) async {
    try {
      final result = await _authService.unsaveEvent(eventId);
      
      if (result.isSuccess) {
        // Refresh user data to get updated saved events
        await refreshUser();
        return true;
      } else {
        state = state.copyWith(error: result.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to unsave event: $e');
      return false;
    }
  }

  Future<bool> rateEvent(String eventId, double rating) async {
    try {
      final result = await _authService.rateEvent(eventId, rating);
      
      if (result.isSuccess) {
        // Refresh user data to get updated ratings
        await refreshUser();
        return true;
      } else {
        state = state.copyWith(error: result.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to rate event: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getEventInteractions() async {
    try {
      return await _authService.getEventInteractions();
    } catch (e) {
      print('Error getting event interactions: $e');
      return null;
    }
  }

  /// Complete registration with OTP verification
  Future<bool> completeRegistration({
    required String email,
    required String otpCode,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final result = await _authService.completeRegistration(
        email: email,
        otpCode: otpCode,
      );
      
      if (result.isSuccess && result.user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.user,
          requiresVerification: false,
          pendingVerificationEmail: null,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: result.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Verification failed: $e',
      );
      return false;
    }
  }

  /// Resend verification code
  Future<bool> resendVerificationCode({
    required String email,
    required String userName,
  }) async {
    try {
      final result = await _authService.resendVerificationCode(
        email: email,
        userName: userName,
      );
      
      if (!result.isSuccess) {
        state = state.copyWith(
          error: result.message,
        );
      }
      
      return result.isSuccess;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to resend verification code: $e',
      );
      return false;
    }
  }

  /// Send forgot password reset code
  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final result = await _authService.forgotPassword(email: email);
      
      if (result.isSuccess) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          error: result.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to send reset code: $e',
      );
      return false;
    }
  }

  /// Verify password reset code
  Future<bool> verifyResetCode(String email, String code) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final result = await _authService.verifyResetCode(
        email: email,
        code: code,
      );
      
      if (result.isSuccess) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          error: result.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to verify reset code: $e',
      );
      return false;
    }
  }

  /// Reset password with new password and verified code
  Future<bool> resetPassword(String email, String newPassword, String code) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final result = await _authService.resetPassword(
        email: email,
        newPassword: newPassword,
        resetCode: code,
      );
      
      if (result.isSuccess) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          error: result.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to reset password: $e',
      );
      return false;
    }
  }
}

// Provider instances
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService();
});

final googleSignInServiceProvider = Provider<GoogleSignInServiceClean>((ref) {
  return GoogleSignInServiceClean();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authApiServiceProvider);
  final googleSignInService = ref.watch(googleSignInServiceProvider);
  return AuthNotifier(authService, googleSignInService);
});

// Computed providers for convenience
final currentUserProvider = Provider<UserProfile?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

// Event interaction providers
final heartedEventsProvider = Provider<List<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.heartedEvents != null) {
    return List<String>.from(user!.heartedEvents!);
  }
  return [];
});

final savedEventsProvider = Provider<List<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.savedEvents != null) {
    return List<String>.from(user!.savedEvents!);
  }
  return [];
});

final eventRatingsProvider = Provider<Map<String, double>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.eventRatings != null) {
    return Map<String, double>.from(user!.eventRatings!);
  }
  return {};
});

// Helper provider to check if an event is hearted
final isEventHeartedProvider = Provider.family<bool, String>((ref, eventId) {
  final heartedEvents = ref.watch(heartedEventsProvider);
  return heartedEvents.contains(eventId);
});

// Helper provider to check if an event is saved
final isEventSavedProvider = Provider.family<bool, String>((ref, eventId) {
  final savedEvents = ref.watch(savedEventsProvider);
  return savedEvents.contains(eventId);
});

// Helper provider to get event rating
final eventRatingProvider = Provider.family<double?, String>((ref, eventId) {
  final ratings = ref.watch(eventRatingsProvider);
  return ratings[eventId];
});