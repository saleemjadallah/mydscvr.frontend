/// User profile model for Dubai families
class UserProfile {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? avatar;
  final DateTime? dateOfBirth;
  final String? gender;
  final List<String> interests;
  final UserPreferences preferences;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool onboardingCompleted;
  
  // Event interaction data
  final List<String>? savedEvents;
  final List<String>? heartedEvents;
  final List<String>? attendedEvents;
  final Map<String, double>? eventRatings;

  const UserProfile({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.avatar,
    this.dateOfBirth,
    this.gender,
    this.interests = const [],
    required this.preferences,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.onboardingCompleted = false,
    this.savedEvents,
    this.heartedEvents,
    this.attendedEvents,
    this.eventRatings,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  String get displayName => fullName.isNotEmpty ? fullName : email;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      avatar: json['avatar'] as String?,
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      interests: (json['interests'] as List<dynamic>?)?.cast<String>() ?? [],
      preferences: UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>? ?? {}),
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isPhoneVerified: json['is_phone_verified'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      savedEvents: (json['savedEvents'] as List<dynamic>?)?.cast<String>(),
      heartedEvents: (json['heartedEvents'] as List<dynamic>?)?.cast<String>(),
      attendedEvents: (json['attendedEvents'] as List<dynamic>?)?.cast<String>(),
      eventRatings: (json['eventRatings'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'avatar': avatar,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'interests': interests,
      'preferences': preferences.toJson(),
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'onboardingCompleted': onboardingCompleted,
      'savedEvents': savedEvents,
      'heartedEvents': heartedEvents,
      'attendedEvents': attendedEvents,
      'eventRatings': eventRatings,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? avatar,
    DateTime? dateOfBirth,
    String? gender,
    List<String>? interests,
    UserPreferences? preferences,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? onboardingCompleted,
    List<String>? savedEvents,
    List<String>? heartedEvents,
    List<String>? attendedEvents,
    Map<String, double>? eventRatings,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      interests: interests ?? this.interests,
      preferences: preferences ?? this.preferences,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      savedEvents: savedEvents ?? this.savedEvents,
      heartedEvents: heartedEvents ?? this.heartedEvents,
      attendedEvents: attendedEvents ?? this.attendedEvents,
      eventRatings: eventRatings ?? this.eventRatings,
    );
  }
}

/// Family member model
class FamilyMember {
  final String id;
  final String name;
  final int age;
  final String relationship; // 'child', 'spouse', 'parent', etc.
  final String? gender;
  final List<String>? interests;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.age,
    required this.relationship,
    this.gender,
    this.interests,
  });

  bool get isChild => relationship == 'child';
  bool get isAdult => age >= 18;
}

/// User preferences model
class UserPreferences {
  final List<String> favoriteCategories;
  final List<String> preferredAreas;
  final int? maxPrice;
  final List<String> ageGroups;
  final bool familyFriendlyOnly;
  final bool accessibilityRequired;
  final bool parkingRequired;
  final NotificationSettings notifications;

  const UserPreferences({
    this.favoriteCategories = const [],
    this.preferredAreas = const [],
    this.maxPrice,
    this.ageGroups = const [],
    this.familyFriendlyOnly = false,
    this.accessibilityRequired = false,
    this.parkingRequired = false,
    required this.notifications,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      favoriteCategories: (json['favorite_categories'] as List<dynamic>?)?.cast<String>() ?? [],
      preferredAreas: (json['preferred_areas'] as List<dynamic>?)?.cast<String>() ?? [],
      maxPrice: json['max_price'] as int?,
      ageGroups: (json['age_groups'] as List<dynamic>?)?.cast<String>() ?? [],
      familyFriendlyOnly: json['family_friendly_only'] as bool? ?? false,
      accessibilityRequired: json['accessibility_required'] as bool? ?? false,
      parkingRequired: json['parking_required'] as bool? ?? false,
      notifications: NotificationSettings.fromJson(json['notifications'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'favorite_categories': favoriteCategories,
      'preferred_areas': preferredAreas,
      'max_price': maxPrice,
      'age_groups': ageGroups,
      'family_friendly_only': familyFriendlyOnly,
      'accessibility_required': accessibilityRequired,
      'parking_required': parkingRequired,
      'notifications': notifications.toJson(),
    };
  }

  factory UserPreferences.defaultPreferences() {
    return UserPreferences(
      notifications: NotificationSettings.defaultSettings(),
    );
  }

  UserPreferences copyWith({
    List<String>? favoriteCategories,
    List<String>? preferredAreas,
    int? maxPrice,
    List<String>? ageGroups,
    bool? familyFriendlyOnly,
    bool? accessibilityRequired,
    bool? parkingRequired,
    NotificationSettings? notifications,
  }) {
    return UserPreferences(
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      preferredAreas: preferredAreas ?? this.preferredAreas,
      maxPrice: maxPrice ?? this.maxPrice,
      ageGroups: ageGroups ?? this.ageGroups,
      familyFriendlyOnly: familyFriendlyOnly ?? this.familyFriendlyOnly,
      accessibilityRequired: accessibilityRequired ?? this.accessibilityRequired,
      parkingRequired: parkingRequired ?? this.parkingRequired,
      notifications: notifications ?? this.notifications,
    );
  }
}

/// Notification settings model
class NotificationSettings {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool eventReminders;
  final bool weeklyDigest;
  final bool priceDropAlerts;
  final bool newEventsInArea;
  final bool familyRecommendations;

  const NotificationSettings({
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.eventReminders = true,
    this.weeklyDigest = false,
    this.priceDropAlerts = false,
    this.newEventsInArea = true,
    this.familyRecommendations = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      emailNotifications: json['email_notifications'] as bool? ?? true,
      pushNotifications: json['push_notifications'] as bool? ?? true,
      eventReminders: json['event_reminders'] as bool? ?? true,
      weeklyDigest: json['weekly_digest'] as bool? ?? false,
      priceDropAlerts: json['price_drop_alerts'] as bool? ?? false,
      newEventsInArea: json['new_events_in_area'] as bool? ?? true,
      familyRecommendations: json['family_recommendations'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'event_reminders': eventReminders,
      'weekly_digest': weeklyDigest,
      'price_drop_alerts': priceDropAlerts,
      'new_events_in_area': newEventsInArea,
      'family_recommendations': familyRecommendations,
    };
  }

  factory NotificationSettings.defaultSettings() {
    return const NotificationSettings();
  }

  NotificationSettings copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? eventReminders,
    bool? weeklyDigest,
    bool? priceDropAlerts,
    bool? newEventsInArea,
    bool? familyRecommendations,
  }) {
    return NotificationSettings(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      eventReminders: eventReminders ?? this.eventReminders,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      priceDropAlerts: priceDropAlerts ?? this.priceDropAlerts,
      newEventsInArea: newEventsInArea ?? this.newEventsInArea,
      familyRecommendations: familyRecommendations ?? this.familyRecommendations,
    );
  }
}

/// Authentication request models
class AuthCredentials {
  final String email;
  final String password;

  const AuthCredentials({
    required this.email,
    required this.password,
  });

  factory AuthCredentials.fromJson(Map<String, dynamic> json) {
    return AuthCredentials(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;

  const RegisterRequest({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.phoneNumber,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'email': email,
      'password': password,
    };
    
    // Only add optional fields if they have values
    if (firstName != null) json['first_name'] = firstName!;
    if (lastName != null) json['last_name'] = lastName!;
    if (phoneNumber != null) json['phone_number'] = phoneNumber!;
    
    return json;
  }
}

/// Authentication response model
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserProfile user;
  final DateTime expiresAt;
  final bool requiresVerification;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresAt,
    this.requiresVerification = false,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Handle both session_token and refresh_token for compatibility
    final refreshToken = json['session_token'] as String? ?? json['refresh_token'] as String;
    
    // Calculate expires_at from expires_in if not provided
    final DateTime expiresAt;
    if (json['expires_at'] != null) {
      expiresAt = DateTime.parse(json['expires_at'] as String);
    } else if (json['expires_in'] != null) {
      final expiresInSeconds = json['expires_in'] as int;
      expiresAt = DateTime.now().add(Duration(seconds: expiresInSeconds));
    } else {
      expiresAt = DateTime.now().add(const Duration(days: 7)); // Default 7 days
    }
    
    return AuthResponse(
      accessToken: json['access_token'] as String,
      refreshToken: refreshToken,
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
      expiresAt: expiresAt,
      requiresVerification: json['requires_verification'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.toJson(),
      'expires_at': expiresAt.toIso8601String(),
      'requires_verification': requiresVerification,
    };
  }
}

/// OTP verification models
class OTPRequest {
  final String email;
  final String? type;

  const OTPRequest({
    required this.email,
    this.type,
  });

  factory OTPRequest.fromJson(Map<String, dynamic> json) {
    return OTPRequest(
      email: json['email'] as String,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'type': type,
    };
  }
}

class OTPVerification {
  final String email;
  final String otp;
  final String? type;

  const OTPVerification({
    required this.email,
    required this.otp,
    this.type,
  });

  factory OTPVerification.fromJson(Map<String, dynamic> json) {
    return OTPVerification(
      email: json['email'] as String,
      otp: json['otp'] as String,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'type': type,
    };
  }
}

class OTPResponse {
  final bool success;
  final String message;
  final int? expiresIn;
  final bool? canResend;

  const OTPResponse({
    required this.success,
    required this.message,
    this.expiresIn,
    this.canResend,
  });

  factory OTPResponse.fromJson(Map<String, dynamic> json) {
    return OTPResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      expiresIn: json['expires_in'] as int?,
      canResend: json['can_resend'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'expires_in': expiresIn,
      'can_resend': canResend,
    };
  }
}

/// API Exception class for handling API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message';
}

/// User preferences response model
class UserPreferencesResponse {
  final bool darkMode;
  final String language;
  final double textScale;
  final bool reduceAnimations;
  final List<String> categories;
  final List<String> areas;

  const UserPreferencesResponse({
    required this.darkMode,
    required this.language,
    required this.textScale,
    required this.reduceAnimations,
    required this.categories,
    required this.areas,
  });

  factory UserPreferencesResponse.fromJson(Map<String, dynamic> json) => 
      UserPreferencesResponse(
        darkMode: json['dark_mode'] as bool,
        language: json['language'] as String,
        textScale: json['text_scale'] as double,
        reduceAnimations: json['reduce_animations'] as bool,
        categories: (json['categories'] as List<dynamic>).cast<String>(),
        areas: (json['areas'] as List<dynamic>).cast<String>(),
      );
  Map<String, dynamic> toJson() => {
    'dark_mode': darkMode,
    'language': language,
    'text_scale': textScale,
    'reduce_animations': reduceAnimations,
    'categories': categories,
    'areas': areas,
  };
}

/// Venue details response model
class VenueResponse {
  final String id;
  final String name;
  final String address;
  final String? description;
  final String? website;
  final String? phone;
  final Map<String, dynamic>? amenities;

  const VenueResponse({
    required this.id,
    required this.name,
    required this.address,
    this.description,
    this.website,
    this.phone,
    this.amenities,
  });

  factory VenueResponse.fromJson(Map<String, dynamic> json) => 
      VenueResponse(
        id: json['id'] as String,
        name: json['name'] as String,
        address: json['address'] as String,
        description: json['description'] as String?,
        website: json['website'] as String?,
        phone: json['phone'] as String?,
        amenities: json['amenities'] as Map<String, dynamic>?,
      );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'description': description,
    'website': website,
    'phone': phone,
    'amenities': amenities,
  };
} 