import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event.dart';
import '../api/api_client.dart';
import 'api_provider.dart';
import 'auth_provider_mongodb.dart';

/// User preferences data class
class UserPreferences {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool weeklyDigest;
  final bool eventReminders;
  final String language;
  final String currency;
  final List<String> favoriteCategories;
  final List<String> preferredAreas;
  final int defaultSearchRadius; // in kilometers
  final String defaultAgeRange;
  final bool familyFriendlyOnly;
  final bool darkMode;
  final double textScale;
  final bool reduceAnimations;
  final String mapStyle;

  const UserPreferences({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.weeklyDigest = false,
    this.eventReminders = true,
    this.language = 'en',
    this.currency = 'AED',
    this.favoriteCategories = const [],
    this.preferredAreas = const [],
    this.defaultSearchRadius = 25,
    this.defaultAgeRange = 'all',
    this.familyFriendlyOnly = false,
    this.darkMode = false,
    this.textScale = 1.0,
    this.reduceAnimations = false,
    this.mapStyle = 'standard',
  });

  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? weeklyDigest,
    bool? eventReminders,
    String? language,
    String? currency,
    List<String>? favoriteCategories,
    List<String>? preferredAreas,
    int? defaultSearchRadius,
    String? defaultAgeRange,
    bool? familyFriendlyOnly,
    bool? darkMode,
    double? textScale,
    bool? reduceAnimations,
    String? mapStyle,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      eventReminders: eventReminders ?? this.eventReminders,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      preferredAreas: preferredAreas ?? this.preferredAreas,
      defaultSearchRadius: defaultSearchRadius ?? this.defaultSearchRadius,
      defaultAgeRange: defaultAgeRange ?? this.defaultAgeRange,
      familyFriendlyOnly: familyFriendlyOnly ?? this.familyFriendlyOnly,
      darkMode: darkMode ?? this.darkMode,
      textScale: textScale ?? this.textScale,
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,
      mapStyle: mapStyle ?? this.mapStyle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications_enabled': notificationsEnabled,
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'weekly_digest': weeklyDigest,
      'event_reminders': eventReminders,
      'language': language,
      'currency': currency,
      'favorite_categories': favoriteCategories,
      'preferred_areas': preferredAreas,
      'default_search_radius': defaultSearchRadius,
      'default_age_range': defaultAgeRange,
      'family_friendly_only': familyFriendlyOnly,
      'dark_mode': darkMode,
      'text_scale': textScale,
      'reduce_animations': reduceAnimations,
      'map_style': mapStyle,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      notificationsEnabled: json['notifications_enabled'] ?? true,
      emailNotifications: json['email_notifications'] ?? true,
      pushNotifications: json['push_notifications'] ?? true,
      weeklyDigest: json['weekly_digest'] ?? false,
      eventReminders: json['event_reminders'] ?? true,
      language: json['language'] ?? 'en',
      currency: json['currency'] ?? 'AED',
      favoriteCategories: List<String>.from(json['favorite_categories'] ?? []),
      preferredAreas: List<String>.from(json['preferred_areas'] ?? []),
      defaultSearchRadius: json['default_search_radius'] ?? 25,
      defaultAgeRange: json['default_age_range'] ?? 'all',
      familyFriendlyOnly: json['family_friendly_only'] ?? false,
      darkMode: json['dark_mode'] ?? false,
      textScale: (json['text_scale'] ?? 1.0).toDouble(),
      reduceAnimations: json['reduce_animations'] ?? false,
      mapStyle: json['map_style'] ?? 'standard',
    );
  }
}

/// User preferences notifier
class PreferencesNotifier extends StateNotifier<UserPreferences> {
  final ApiClient _apiClient;
  final Ref _ref;

  PreferencesNotifier(this._apiClient, this._ref) : super(const UserPreferences());

  /// Initialize preferences from storage and user profile
  Future<void> initialize() async {
    try {
      // Load from local storage first
      final localPrefs = await _loadLocalPreferences();
      state = localPrefs;

      // If user is authenticated, sync with server
      final isAuthenticated = _ref.read(isAuthenticatedProvider);
      if (isAuthenticated) {
        await syncWithServer();
      }
    } catch (e) {
      // Use default preferences if loading fails
      state = const UserPreferences();
    }
  }

  /// Sync preferences with server
  Future<void> syncWithServer() async {
    try {
      final isAuthenticated = _ref.read(isAuthenticatedProvider);
      if (!isAuthenticated) return;

      // Get server preferences - but don't fail if backend isn't available
      final response = await _apiClient.getUserPreferences().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          // Return a failed response if timeout
          throw Exception('Preferences sync timed out');
        },
      );
      
      if (!response.success || response.data == null) return;
      
      final serverPrefs = response.data!;
      
      // Convert server response to UserPreferences
      state = UserPreferences(
        darkMode: serverPrefs['darkMode'] ?? state.darkMode,
        language: serverPrefs['language'] ?? state.language,
        textScale: (serverPrefs['textScale'] ?? state.textScale).toDouble(),
        reduceAnimations: serverPrefs['reduceAnimations'] ?? state.reduceAnimations,
        favoriteCategories: List<String>.from(serverPrefs['categories'] ?? []),
        preferredAreas: List<String>.from(serverPrefs['areas'] ?? []),
      ).copyWith(
        notificationsEnabled: state.notificationsEnabled,
        emailNotifications: state.emailNotifications,
        pushNotifications: state.pushNotifications,
        weeklyDigest: state.weeklyDigest,
        eventReminders: state.eventReminders,
        currency: state.currency,
        defaultSearchRadius: state.defaultSearchRadius,
        defaultAgeRange: state.defaultAgeRange,
        familyFriendlyOnly: state.familyFriendlyOnly,
      );

      // Save merged preferences locally
      await _saveLocalPreferences(state);
    } catch (e) {
      // Continue with local preferences if sync fails
      print('📱 Preferences sync failed (using local): $e');
    }
  }

  /// Update preferences and sync with server
  Future<void> updatePreferences(UserPreferences newPreferences) async {
    state = newPreferences;
    
    // Save locally immediately
    await _saveLocalPreferences(newPreferences);

    // Sync with server if authenticated
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (isAuthenticated) {
      try {
        await _apiClient.updateUserPreferences(newPreferences.toJson()).timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            throw Exception('Update preferences timed out');
          },
        );
      } catch (e) {
        // Continue with local save if server sync fails
        print('📱 Preferences update failed (saved locally): $e');
      }
    }
  }

  // ==================== NOTIFICATION SETTINGS ====================

  /// Toggle notifications enabled
  Future<void> toggleNotifications() async {
    await updatePreferences(state.copyWith(
      notificationsEnabled: !state.notificationsEnabled,
    ));
  }

  /// Toggle email notifications
  Future<void> toggleEmailNotifications() async {
    await updatePreferences(state.copyWith(
      emailNotifications: !state.emailNotifications,
    ));
  }

  /// Toggle push notifications
  Future<void> togglePushNotifications() async {
    await updatePreferences(state.copyWith(
      pushNotifications: !state.pushNotifications,
    ));
  }

  /// Toggle weekly digest
  Future<void> toggleWeeklyDigest() async {
    await updatePreferences(state.copyWith(
      weeklyDigest: !state.weeklyDigest,
    ));
  }

  /// Toggle event reminders
  Future<void> toggleEventReminders() async {
    await updatePreferences(state.copyWith(
      eventReminders: !state.eventReminders,
    ));
  }

  // ==================== LOCALIZATION SETTINGS ====================

  /// Update language
  Future<void> updateLanguage(String language) async {
    await updatePreferences(state.copyWith(language: language));
  }

  /// Update currency
  Future<void> updateCurrency(String currency) async {
    await updatePreferences(state.copyWith(currency: currency));
  }

  // ==================== CONTENT PREFERENCES ====================

  /// Add favorite category
  Future<void> addFavoriteCategory(String category) async {
    if (!state.favoriteCategories.contains(category)) {
      await updatePreferences(state.copyWith(
        favoriteCategories: [...state.favoriteCategories, category],
      ));
    }
  }

  /// Remove favorite category
  Future<void> removeFavoriteCategory(String category) async {
    await updatePreferences(state.copyWith(
      favoriteCategories: state.favoriteCategories.where((c) => c != category).toList(),
    ));
  }

  /// Update favorite categories
  Future<void> updateFavoriteCategories(List<String> categories) async {
    await updatePreferences(state.copyWith(favoriteCategories: categories));
  }

  /// Add preferred area
  Future<void> addPreferredArea(String area) async {
    if (!state.preferredAreas.contains(area)) {
      await updatePreferences(state.copyWith(
        preferredAreas: [...state.preferredAreas, area],
      ));
    }
  }

  /// Remove preferred area
  Future<void> removePreferredArea(String area) async {
    await updatePreferences(state.copyWith(
      preferredAreas: state.preferredAreas.where((a) => a != area).toList(),
    ));
  }

  /// Update preferred areas
  Future<void> updatePreferredAreas(List<String> areas) async {
    await updatePreferences(state.copyWith(preferredAreas: areas));
  }

  /// Update search radius
  Future<void> updateSearchRadius(int radius) async {
    await updatePreferences(state.copyWith(defaultSearchRadius: radius));
  }

  /// Update default age range
  Future<void> updateDefaultAgeRange(String ageRange) async {
    await updatePreferences(state.copyWith(defaultAgeRange: ageRange));
  }

  /// Toggle family friendly only
  Future<void> toggleFamilyFriendlyOnly() async {
    await updatePreferences(state.copyWith(
      familyFriendlyOnly: !state.familyFriendlyOnly,
    ));
  }

  // ==================== UI PREFERENCES ====================

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    await updatePreferences(state.copyWith(darkMode: !state.darkMode));
  }

  /// Update text scale
  Future<void> updateTextScale(double scale) async {
    await updatePreferences(state.copyWith(textScale: scale));
  }

  /// Toggle reduced animations
  Future<void> toggleReduceAnimations() async {
    await updatePreferences(state.copyWith(
      reduceAnimations: !state.reduceAnimations,
    ));
  }

  /// Update map style
  Future<void> updateMapStyle(String style) async {
    await updatePreferences(state.copyWith(mapStyle: style));
  }

  // ==================== PRIVATE METHODS ====================

  /// Load preferences from local storage
  Future<UserPreferences> _loadLocalPreferences() async {
    // TODO: Implement with shared_preferences
    // For now, return default preferences
    return const UserPreferences();
  }

  /// Save preferences to local storage
  Future<void> _saveLocalPreferences(UserPreferences preferences) async {
    // TODO: Implement with shared_preferences
  }
}

/// Provider for user preferences
final preferencesProvider = StateNotifierProvider<PreferencesNotifier, UserPreferences>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PreferencesNotifier(apiClient, ref);
});

/// Provider for dark mode setting
final darkModeProvider = Provider<bool>((ref) {
  final preferences = ref.watch(preferencesProvider);
  return preferences.darkMode;
});

/// Provider for text scale setting
final textScaleProvider = Provider<double>((ref) {
  final preferences = ref.watch(preferencesProvider);
  return preferences.textScale;
});

/// Provider for reduced animations setting
final reduceAnimationsProvider = Provider<bool>((ref) {
  final preferences = ref.watch(preferencesProvider);
  return preferences.reduceAnimations;
});

/// Provider for language setting
final languageProvider = Provider<String>((ref) {
  final preferences = ref.watch(preferencesProvider);
  return preferences.language;
});

/// Provider for currency setting
final currencyProvider = Provider<String>((ref) {
  final preferences = ref.watch(preferencesProvider);
  return preferences.currency;
});

/// Favorites management provider
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FavoritesNotifier(apiClient, ref);
});

/// Favorites notifier for managing saved events
class FavoritesNotifier extends StateNotifier<List<String>> {
  final ApiClient _apiClient;
  final Ref _ref;

  FavoritesNotifier(this._apiClient, this._ref) : super([]);

  /// Initialize favorites from server
  Future<void> initialize() async {
    try {
      final isAuthenticated = _ref.read(isAuthenticatedProvider);
      if (!isAuthenticated) {
        // Load from local storage if not authenticated
        state = await _loadLocalFavorites();
        return;
      }

      // Get favorites from server with timeout
      final response = await _apiClient.getFavoriteEvents().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          // Return an error response on timeout
          throw Exception('Favorites request timed out');
        },
      );
      
      if (response.success && response.data != null) {
        final favoriteEvents = List<Map<String, dynamic>>.from(response.data!);
        state = favoriteEvents.map((event) => event['id'] as String).toList();
        
        // Save to local storage
        await _saveLocalFavorites(state);
      } else {
        // Use local favorites if server response is not successful
        state = await _loadLocalFavorites();
      }
    } catch (e) {
      // Fallback to local storage on any error
      print('Failed to load favorites from server: $e');
      state = await _loadLocalFavorites();
    }
  }

  /// Add event to favorites
  Future<void> addToFavorites(String eventId) async {
    if (state.contains(eventId)) return;

    // Update local state immediately
    state = [...state, eventId];
    await _saveLocalFavorites(state);

    // Sync with server if authenticated
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (isAuthenticated) {
      try {
        await _apiClient.addToFavorites(eventId);
      } catch (e) {
        // Revert if server call fails
        state = state.where((id) => id != eventId).toList();
        await _saveLocalFavorites(state);
        rethrow;
      }
    }
  }

  /// Remove event from favorites
  Future<void> removeFromFavorites(String eventId) async {
    if (!state.contains(eventId)) return;

    // Update local state immediately
    state = state.where((id) => id != eventId).toList();
    await _saveLocalFavorites(state);

    // Sync with server if authenticated
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (isAuthenticated) {
      try {
        await _apiClient.removeFromFavorites(eventId);
      } catch (e) {
        // Revert if server call fails
        state = [...state, eventId];
        await _saveLocalFavorites(state);
        rethrow;
      }
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String eventId) async {
    if (state.contains(eventId)) {
      await removeFromFavorites(eventId);
    } else {
      await addToFavorites(eventId);
    }
  }

  /// Check if event is favorited
  bool isFavorite(String eventId) {
    return state.contains(eventId);
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    state = [];
    await _saveLocalFavorites(state);

    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (isAuthenticated) {
      try {
        await _apiClient.clearFavorites();
      } catch (e) {
        // Continue with local clear even if server fails
      }
    }
  }

  /// Sync favorites with server
  Future<void> syncWithServer() async {
    try {
      final isAuthenticated = _ref.read(isAuthenticatedProvider);
      if (!isAuthenticated) return;

      final response = await _apiClient.getFavoriteEvents();
      final favoriteEvents = List<Map<String, dynamic>>.from(response.data ?? []);
      state = favoriteEvents.map((event) => event['id'] as String).toList();
      await _saveLocalFavorites(state);
    } catch (e) {
      // Continue with local favorites if sync fails
    }
  }

  /// Load favorites from local storage
  Future<List<String>> _loadLocalFavorites() async {
    // TODO: Implement with shared_preferences
    return [];
  }

  /// Save favorites to local storage
  Future<void> _saveLocalFavorites(List<String> favorites) async {
    // TODO: Implement with shared_preferences
  }
}

/// Provider for checking if specific event is favorited
final isEventFavoritedProvider = Provider.family<bool, String>((ref, eventId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.contains(eventId);
});

/// Provider for favorite events count
final favoritesCountProvider = Provider<int>((ref) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.length;
});

/// Provider for app initialization
final appInitializationProvider = FutureProvider<void>((ref) async {
  try {
    // Initialize all providers that need setup
    // Note: PreferencesNotifier doesn't have initialize() method - it loads defaults in constructor
    // await ref.read(preferencesProvider.notifier).initialize();
    
    // Initialize favorites - but don't let it block the app
    await ref.read(favoritesProvider.notifier).initialize().timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        // If initialization takes too long, just continue
        print('Favorites initialization timed out - using local defaults');
      },
    );
    
    // Auth provider doesn't need initialization anymore
  } catch (e) {
    // Log error but don't let it prevent app from loading
    print('App initialization error: $e');
  }
});

/// Initialize the application
final initProvider = FutureProvider<void>((ref) async {
  // Load user preferences if authenticated
  final isAuthenticated = ref.read(isAuthenticatedProvider);
  if (isAuthenticated) {
    await ref.read(preferencesProvider.notifier).syncWithServer();
    await ref.read(favoritesProvider.notifier).initialize();
  }
});

/// Recent searches provider
final recentSearchesProvider = StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  return RecentSearchesNotifier();
});

/// Recent searches notifier
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier() : super([]);

  /// Initialize recent searches from storage
  Future<void> initialize() async {
    state = await _loadRecentSearches();
  }

  /// Add search query to recent searches
  void addSearch(String query) {
    if (query.trim().isEmpty) return;

    final currentSearches = [...state];
    
    // Remove if already exists
    currentSearches.removeWhere((search) => 
        search.toLowerCase() == query.toLowerCase());
    
    // Add to beginning
    currentSearches.insert(0, query.trim());
    
    // Keep only last 10 searches
    if (currentSearches.length > 10) {
      currentSearches.removeLast();
    }
    
    state = currentSearches;
    _saveRecentSearches(currentSearches);
  }

  /// Remove search from recent searches
  void removeSearch(String query) {
    state = state.where((search) => search != query).toList();
    _saveRecentSearches(state);
  }

  /// Clear all recent searches
  void clearAll() {
    state = [];
    _saveRecentSearches([]);
  }

  /// Load recent searches from storage
  Future<List<String>> _loadRecentSearches() async {
    // TODO: Implement with shared_preferences
    return [];
  }

  /// Save recent searches to storage
  void _saveRecentSearches(List<String> searches) {
    // TODO: Implement with shared_preferences
  }
}

/// Quick action provider for user shortcuts
final quickActionsProvider = StateNotifierProvider<QuickActionsNotifier, List<String>>((ref) {
  return QuickActionsNotifier();
});

/// Quick actions notifier
class QuickActionsNotifier extends StateNotifier<List<String>> {
  QuickActionsNotifier() : super(['Nearby Events', 'This Weekend', 'Free Activities', 'Kids Events']);

  /// Add quick action
  void addAction(String action) {
    if (!state.contains(action)) {
      state = [...state, action];
    }
  }

  /// Remove quick action
  void removeAction(String action) {
    state = state.where((a) => a != action).toList();
  }

  /// Reorder quick actions
  void reorderActions(List<String> newOrder) {
    state = newOrder;
  }
} 