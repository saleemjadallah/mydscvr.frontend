import 'package:json_annotation/json_annotation.dart';

part 'advice_models.g.dart';

/// Event advice categories
enum AdviceCategory {
  @JsonValue('first_time')
  firstTime,
  @JsonValue('family_tips')
  familyTips,
  @JsonValue('accessibility')
  accessibility,
  @JsonValue('transportation')
  transportation,
  @JsonValue('budget_tips')
  budgetTips,
  @JsonValue('what_to_expect')
  whatToExpect,
  @JsonValue('best_time')
  bestTime,
  @JsonValue('general')
  general,
}

/// Types of advice based on user experience
enum AdviceType {
  @JsonValue('attended_similar')
  attendedSimilar,
  @JsonValue('attended_this')
  attendedThis,
  @JsonValue('local_knowledge')
  localKnowledge,
  @JsonValue('expert_tip')
  expertTip,
}

/// Event advice model
@JsonSerializable()
class EventAdvice {
  final String id;
  @JsonKey(name: 'event_id')
  final String eventId;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'user_name')
  final String userName;
  @JsonKey(name: 'user_avatar')
  final String? userAvatar;
  final String title;
  final String content;
  final AdviceCategory category;
  @JsonKey(name: 'advice_type')
  final AdviceType adviceType;
  @JsonKey(name: 'experience_date')
  final DateTime? experienceDate;
  @JsonKey(name: 'venue_familiarity')
  final bool venueFamiliarity;
  @JsonKey(name: 'similar_events_attended')
  final int? similarEventsAttended;
  @JsonKey(name: 'helpfulness_rating')
  final double helpfulnessRating;
  @JsonKey(name: 'helpfulness_votes')
  final int helpfulnessVotes;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'helpful_users')
  final List<String> helpfulUsers;
  @JsonKey(name: 'reported_by')
  final List<String> reportedBy;
  final List<String> tags;
  final String language;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const EventAdvice({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.title,
    required this.content,
    required this.category,
    required this.adviceType,
    this.experienceDate,
    this.venueFamiliarity = false,
    this.similarEventsAttended,
    this.helpfulnessRating = 0.0,
    this.helpfulnessVotes = 0,
    this.isVerified = false,
    this.isFeatured = false,
    this.helpfulUsers = const [],
    this.reportedBy = const [],
    this.tags = const [],
    this.language = 'en',
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventAdvice.fromJson(Map<String, dynamic> json) {
    // Handle the _id field from MongoDB
    if (json.containsKey('_id') && !json.containsKey('id')) {
      json['id'] = json['_id'];
    }
    return _$EventAdviceFromJson(json);
  }

  Map<String, dynamic> toJson() => _$EventAdviceToJson(this);

  EventAdvice copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? userName,
    String? userAvatar,
    String? title,
    String? content,
    AdviceCategory? category,
    AdviceType? adviceType,
    DateTime? experienceDate,
    bool? venueFamiliarity,
    int? similarEventsAttended,
    double? helpfulnessRating,
    int? helpfulnessVotes,
    bool? isVerified,
    bool? isFeatured,
    List<String>? helpfulUsers,
    List<String>? reportedBy,
    List<String>? tags,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventAdvice(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      adviceType: adviceType ?? this.adviceType,
      experienceDate: experienceDate ?? this.experienceDate,
      venueFamiliarity: venueFamiliarity ?? this.venueFamiliarity,
      similarEventsAttended: similarEventsAttended ?? this.similarEventsAttended,
      helpfulnessRating: helpfulnessRating ?? this.helpfulnessRating,
      helpfulnessVotes: helpfulnessVotes ?? this.helpfulnessVotes,
      isVerified: isVerified ?? this.isVerified,
      isFeatured: isFeatured ?? this.isFeatured,
      helpfulUsers: helpfulUsers ?? this.helpfulUsers,
      reportedBy: reportedBy ?? this.reportedBy,
      tags: tags ?? this.tags,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Advice statistics model
@JsonSerializable()
class AdviceStats {
  @JsonKey(name: 'event_id')
  final String eventId;
  @JsonKey(name: 'total_advice')
  final int totalAdvice;
  @JsonKey(name: 'average_helpfulness')
  final double averageHelpfulness;
  @JsonKey(name: 'advice_by_category')
  final Map<String, int> adviceByCategory;
  @JsonKey(name: 'advice_by_type')
  final Map<String, int> adviceByType;
  @JsonKey(name: 'verified_advice_count')
  final int verifiedAdviceCount;
  @JsonKey(name: 'featured_advice_count')
  final int featuredAdviceCount;
  @JsonKey(name: 'recent_advice_count')
  final int recentAdviceCount;
  @JsonKey(name: 'top_tags')
  final List<String> topTags;
  @JsonKey(name: 'last_updated')
  final DateTime lastUpdated;

  const AdviceStats({
    required this.eventId,
    this.totalAdvice = 0,
    this.averageHelpfulness = 0.0,
    this.adviceByCategory = const {},
    this.adviceByType = const {},
    this.verifiedAdviceCount = 0,
    this.featuredAdviceCount = 0,
    this.recentAdviceCount = 0,
    this.topTags = const [],
    required this.lastUpdated,
  });

  factory AdviceStats.fromJson(Map<String, dynamic> json) => _$AdviceStatsFromJson(json);
  Map<String, dynamic> toJson() => _$AdviceStatsToJson(this);
}

/// Model for creating new advice
@JsonSerializable()
class CreateAdvice {
  @JsonKey(name: 'event_id')
  final String eventId;
  final String title;
  final String content;
  final AdviceCategory category;
  @JsonKey(name: 'advice_type')
  final AdviceType adviceType;
  @JsonKey(name: 'experience_date')
  final DateTime? experienceDate;
  @JsonKey(name: 'venue_familiarity')
  final bool venueFamiliarity;
  @JsonKey(name: 'similar_events_attended')
  final int? similarEventsAttended;
  final List<String> tags;
  final String language;

  const CreateAdvice({
    required this.eventId,
    required this.title,
    required this.content,
    required this.category,
    required this.adviceType,
    this.experienceDate,
    this.venueFamiliarity = false,
    this.similarEventsAttended,
    this.tags = const [],
    this.language = 'en',
  });

  factory CreateAdvice.fromJson(Map<String, dynamic> json) => _$CreateAdviceFromJson(json);
  Map<String, dynamic> toJson() => _$CreateAdviceToJson(this);
}

/// Helper class for advice category and type display
class AdviceDisplayHelper {
  static String getCategoryDisplayName(AdviceCategory category) {
    switch (category) {
      case AdviceCategory.firstTime:
        return 'First Time Visitor';
      case AdviceCategory.familyTips:
        return 'Family Tips';
      case AdviceCategory.accessibility:
        return 'Accessibility';
      case AdviceCategory.transportation:
        return 'Transportation';
      case AdviceCategory.budgetTips:
        return 'Budget Tips';
      case AdviceCategory.whatToExpect:
        return 'What to Expect';
      case AdviceCategory.bestTime:
        return 'Best Time to Visit';
      case AdviceCategory.general:
        return 'General Advice';
    }
  }

  static String getTypeDisplayName(AdviceType type) {
    switch (type) {
      case AdviceType.attendedSimilar:
        return 'Attended Similar Events';
      case AdviceType.attendedThis:
        return 'Attended This Event';
      case AdviceType.localKnowledge:
        return 'Local Knowledge';
      case AdviceType.expertTip:
        return 'Expert Tip';
    }
  }

  static String getCategoryIcon(AdviceCategory category) {
    switch (category) {
      case AdviceCategory.firstTime:
        return '🌟';
      case AdviceCategory.familyTips:
        return '👨‍👩‍👧‍👦';
      case AdviceCategory.accessibility:
        return '♿';
      case AdviceCategory.transportation:
        return '🚗';
      case AdviceCategory.budgetTips:
        return '💰';
      case AdviceCategory.whatToExpect:
        return '👀';
      case AdviceCategory.bestTime:
        return '⏰';
      case AdviceCategory.general:
        return '💡';
    }
  }

  static String getTypeIcon(AdviceType type) {
    switch (type) {
      case AdviceType.attendedSimilar:
        return '📝';
      case AdviceType.attendedThis:
        return '✅';
      case AdviceType.localKnowledge:
        return '📍';
      case AdviceType.expertTip:
        return '🎯';
    }
  }
} 