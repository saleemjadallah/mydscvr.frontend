import 'package:json_annotation/json_annotation.dart';

part 'family_suitability.g.dart';

/// Family suitability model for age ranges and family-friendly features
@JsonSerializable()
class FamilySuitability {
  @JsonKey(name: 'age_min')
  final int ageMin;
  @JsonKey(name: 'age_max')
  final int ageMax;
  @JsonKey(name: 'family_friendly')
  final bool familyFriendly;
  @JsonKey(name: 'stroller_friendly')
  final bool? strollerFriendly;
  @JsonKey(name: 'baby_changing_facilities')
  final bool? babyChangingFacilities;
  @JsonKey(name: 'child_supervision_required')
  final bool? childSupervisionRequired;
  @JsonKey(name: 'educational_value')
  final bool? educationalValue;
  @JsonKey(name: 'physical_activity_level')
  final String? physicalActivityLevel; // 'low', 'medium', 'high'
  @JsonKey(name: 'safety_measures')
  final List<String>? safetyMeasures;

  const FamilySuitability({
    required this.ageMin,
    required this.ageMax,
    required this.familyFriendly,
    this.strollerFriendly,
    this.babyChangingFacilities,
    this.childSupervisionRequired,
    this.educationalValue,
    this.physicalActivityLevel,
    this.safetyMeasures,
  });

  factory FamilySuitability.fromJson(Map<String, dynamic> json) => _$FamilySuitabilityFromJson(json);
  Map<String, dynamic> toJson() => _$FamilySuitabilityToJson(this);

  /// Helper methods for UI
  String get ageRange => '$ageMin-$ageMax years';
  
  bool get isBabyFriendly => ageMin == 0;
  bool get isToddlerFriendly => ageMin <= 3;
  bool get isSchoolAgeFriendly => ageMax >= 6;
  bool get isTeenFriendly => ageMax >= 13;
  
  /// Get age group classification
  String get ageGroupClassification {
    if (ageMin == 0 && ageMax <= 2) return 'Babies & Toddlers';
    if (ageMin <= 3 && ageMax <= 5) return 'Preschoolers';
    if (ageMin <= 6 && ageMax <= 12) return 'School Age';
    if (ageMin <= 13) return 'Teens & Adults';
    return 'All Ages';
  }
  
  /// Get activity level display
  String get activityLevelDisplay {
    switch (physicalActivityLevel?.toLowerCase()) {
      case 'low':
        return 'Low Activity';
      case 'medium':
        return 'Moderate Activity';
      case 'high':
        return 'High Activity';
      default:
        return 'Varied Activity';
    }
  }
  
  /// Check if suitable for specific age
  bool isSuitableForAge(int age) {
    return age >= ageMin && age <= ageMax;
  }
} 