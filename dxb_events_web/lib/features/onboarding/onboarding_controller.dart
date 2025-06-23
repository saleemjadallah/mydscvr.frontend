import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class OnboardingState {
  final int currentStep;
  final Map<String, dynamic> preferences;
  final List<FamilyMember> familyMembers;
  final bool isCompleted;
  
  const OnboardingState({
    this.currentStep = 0,
    this.preferences = const {},
    this.familyMembers = const [],
    this.isCompleted = false,
  });
  
  OnboardingState copyWith({
    int? currentStep,
    Map<String, dynamic>? preferences,
    List<FamilyMember>? familyMembers,
    bool? isCompleted,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      preferences: preferences ?? Map.from(this.preferences),
      familyMembers: familyMembers ?? List.from(this.familyMembers),
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class FamilyMember {
  final String id;
  final String name;
  final int age;
  final String relationship;
  final String? avatarSeed; // Used for Dicebear avatar generation
  
  const FamilyMember({
    required this.id,
    required this.name,
    required this.age,
    required this.relationship,
    this.avatarSeed,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'relationship': relationship,
      'avatarSeed': avatarSeed,
    };
  }
  
  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      relationship: json['relationship'] as String,
      avatarSeed: json['avatarSeed'] as String?,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());
  
  void nextStep() {
    if (state.currentStep < 5) { // 6 steps total (0-5)
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }
  
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }
  
  void goToStep(int step) {
    if (step >= 0 && step <= 5) {
      state = state.copyWith(currentStep: step);
    }
  }
  
  void addFamilyMember(FamilyMember member) {
    state = state.copyWith(
      familyMembers: [...state.familyMembers, member],
    );
  }
  
  void removeFamilyMember(String id) {
    state = state.copyWith(
      familyMembers: state.familyMembers.where((m) => m.id != id).toList(),
    );
  }
  
  void updateFamilyMember(String id, FamilyMember updatedMember) {
    final updatedMembers = state.familyMembers.map((member) {
      return member.id == id ? updatedMember : member;
    }).toList();
    
    state = state.copyWith(familyMembers: updatedMembers);
  }
  
  void updatePreference(String key, dynamic value) {
    final updatedPreferences = Map<String, dynamic>.from(state.preferences);
    updatedPreferences[key] = value;
    
    state = state.copyWith(preferences: updatedPreferences);
  }
  
  void updateMultiplePreferences(Map<String, dynamic> newPreferences) {
    final updatedPreferences = Map<String, dynamic>.from(state.preferences);
    updatedPreferences.addAll(newPreferences);
    
    state = state.copyWith(preferences: updatedPreferences);
  }
  
  void removePreference(String key) {
    final updatedPreferences = Map<String, dynamic>.from(state.preferences);
    updatedPreferences.remove(key);
    
    state = state.copyWith(preferences: updatedPreferences);
  }
  
  void completeOnboarding() {
    state = state.copyWith(isCompleted: true);
    // Save preferences to backend/local storage
    savePreferences();
  }
  
  Future<void> savePreferences() async {
    try {
      // TODO: Implement API call to save user preferences
      // This would connect to your backend API
      
      final dataToSave = {
        'familyMembers': state.familyMembers.map((m) => m.toJson()).toList(),
        'preferences': state.preferences,
        'completedAt': DateTime.now().toIso8601String(),
      };
      
      // For now, save to local storage as fallback
      // await _saveToLocalStorage(dataToSave);
      
      print('📝 Onboarding data saved: ${dataToSave.keys}');
    } catch (e) {
      print('❌ Error saving onboarding data: $e');
      rethrow;
    }
  }
  
  void resetOnboarding() {
    state = const OnboardingState();
  }
  
  // Validation helpers
  bool canProceedFromCurrentStep() {
    switch (state.currentStep) {
      case 0: // Welcome step - always can proceed
        return true;
      case 1: // Family setup - must have at least one family member
        return state.familyMembers.isNotEmpty;
      case 2: // Interests - must have selected at least 3 interests
        final interests = state.preferences['interests'] as List<String>? ?? [];
        return interests.length >= 3;
      case 3: // Location preferences - must have selected at least one location
        final locations = state.preferences['preferredLocations'] as List<String>? ?? [];
        return locations.isNotEmpty;
      case 4: // Budget and schedule - must have set budget and days
        final hasMinPrice = state.preferences.containsKey('minPrice');
        final hasMaxPrice = state.preferences.containsKey('maxPrice');
        final hasPreferredDays = state.preferences['preferredDays'] != null &&
            (state.preferences['preferredDays'] as List).isNotEmpty;
        return hasMinPrice && hasMaxPrice && hasPreferredDays;
      case 5: // Completion step - always ready
        return true;
      default:
        return false;
    }
  }
  
  String? getValidationMessage() {
    if (canProceedFromCurrentStep()) return null;
    
    switch (state.currentStep) {
      case 1:
        return 'Please add at least one family member to continue';
      case 2:
        return 'Please select at least 3 interests to get better recommendations';
      case 3:
        return 'Please select at least one preferred area in Dubai';
      case 4:
        return 'Please set your budget range and preferred days';
      default:
        return 'Please complete this step to continue';
    }
  }
  
  // Progress calculation
  double get progress {
    return (state.currentStep + 1) / 6; // 6 total steps
  }
  
  // Get summary for completion screen
  Map<String, dynamic> get onboardingSummary {
    return {
      'familyMembers': state.familyMembers.length,
      'interests': (state.preferences['interests'] as List<String>? ?? []).length,
      'locations': (state.preferences['preferredLocations'] as List<String>? ?? []).length,
      'budgetRange': state.preferences.containsKey('minPrice') && state.preferences.containsKey('maxPrice')
          ? 'AED ${state.preferences['minPrice']?.toInt() ?? 0} - ${state.preferences['maxPrice']?.toInt() ?? 500}'
          : 'Not set',
      'preferredDays': (state.preferences['preferredDays'] as List<String>? ?? []).length,
      'preferredTime': state.preferences['preferredTime'] ?? 'Not set',
    };
  }
  
  // Convert onboarding data to API format
  Map<String, dynamic> toApiFormat() {
    return {
      'family_members': state.familyMembers.map((member) => {
        'name': member.name,
        'age': member.age,
        'age_group': _mapAgeToGroup(member.age),
        'avatar_url': member.avatarSeed != null ? 'https://api.dicebear.com/7.x/avataaars/svg?seed=${member.avatarSeed}' : null,
        'interests': <String>[], // Default empty list, can be populated from preferences
        'dietary_restrictions': <String>[], // Default empty list
        'accessibility_needs': <String>[], // Default empty list
      }).toList(),
      'preferences': {
        'interests': state.preferences['interests'] ?? [],
        'preferred_areas': state.preferences['preferredLocations'] ?? [],
        'max_travel_distance': 30,
        'budget_min': state.preferences['minPrice']?.toDouble() ?? 0.0,
        'budget_max': state.preferences['maxPrice']?.toDouble() ?? 1000.0,
        'currency': 'AED',
        'preferred_days': state.preferences['preferredDays'] ?? [],
        'preferred_times': _mapPreferredTime(state.preferences['preferredTime']),
        'language_preferences': ['English'],
        'notification_preferences': {
          'email_notifications': true,
          'push_notifications': true,
          'sms_notifications': false,
          'weekly_digest': true,
          'event_reminders': true,
          'last_minute_deals': true,
          'new_events_in_area': true,
        },
      },
    };
  }
  
  String _mapAgeToGroup(int age) {
    if (age <= 3) return 'toddler';
    if (age <= 5) return 'preschool';
    if (age <= 12) return 'school';
    if (age <= 17) return 'teen';
    return 'adult';
  }
  
  List<String> _mapPreferredTime(String? preferredTime) {
    if (preferredTime == null) return ['morning', 'afternoon', 'evening'];
    
    switch (preferredTime.toLowerCase()) {
      case 'morning':
        return ['morning'];
      case 'afternoon':
        return ['afternoon'];
      case 'evening':
        return ['evening'];
      case 'weekends':
        return ['morning', 'afternoon'];
      default:
        return ['morning', 'afternoon', 'evening'];
    }
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);

// Utility providers for specific parts of onboarding state
final currentStepProvider = Provider<int>((ref) {
  return ref.watch(onboardingProvider).currentStep;
});

final familyMembersProvider = Provider<List<FamilyMember>>((ref) {
  return ref.watch(onboardingProvider).familyMembers;
});

final onboardingPreferencesProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(onboardingProvider).preferences;
});

final canProceedProvider = Provider<bool>((ref) {
  return ref.watch(onboardingProvider.notifier).canProceedFromCurrentStep();
});

final onboardingProgressProvider = Provider<double>((ref) {
  return ref.watch(onboardingProvider.notifier).progress;
});