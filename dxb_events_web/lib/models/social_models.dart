import 'package:json_annotation/json_annotation.dart';

part 'social_models.g.dart';

/// User Review model
@JsonSerializable()
class UserReview {
  final String id;
  final String userId;
  final String eventId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> photos;
  final Map<String, dynamic> eventDetails;
  final int helpfulCount;
  final List<String> helpfulUsers;
  final bool isVerifiedAttendee;
  final String? eventDate;
  final List<String> tags;
  final ReviewSentiment sentiment;

  const UserReview({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.photos = const [],
    this.eventDetails = const {},
    this.helpfulCount = 0,
    this.helpfulUsers = const [],
    this.isVerifiedAttendee = false,
    this.eventDate,
    this.tags = const [],
    this.sentiment = ReviewSentiment.neutral,
  });

  UserReview copyWith({
    String? id,
    String? userId,
    String? eventId,
    String? userName,
    String? userAvatar,
    double? rating,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? photos,
    Map<String, dynamic>? eventDetails,
    int? helpfulCount,
    List<String>? helpfulUsers,
    bool? isVerifiedAttendee,
    String? eventDate,
    List<String>? tags,
    ReviewSentiment? sentiment,
  }) {
    return UserReview(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photos: photos ?? this.photos,
      eventDetails: eventDetails ?? this.eventDetails,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      helpfulUsers: helpfulUsers ?? this.helpfulUsers,
      isVerifiedAttendee: isVerifiedAttendee ?? this.isVerifiedAttendee,
      eventDate: eventDate ?? this.eventDate,
      tags: tags ?? this.tags,
      sentiment: sentiment ?? this.sentiment,
    );
  }

  factory UserReview.fromJson(Map<String, dynamic> json) => 
      _$UserReviewFromJson(json);
  Map<String, dynamic> toJson() => _$UserReviewToJson(this);
}

/// Review sentiment analysis
enum ReviewSentiment {
  positive,
  neutral,
  negative,
}

/// Review statistics
@JsonSerializable()
class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // rating -> count
  final int verifiedReviews;
  final int photosCount;
  final ReviewSentiment overallSentiment;
  final List<String> commonTags;

  const ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.verifiedReviews,
    required this.photosCount,
    required this.overallSentiment,
    required this.commonTags,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) => 
      _$ReviewStatsFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewStatsToJson(this);
}

/// User social profile
@JsonSerializable()
class UserSocialProfile {
  final String userId;
  final String displayName;
  final String? avatar;
  final String? bio;
  final String? location;
  final DateTime joinedDate;
  final int reviewsCount;
  final int eventsAttended;
  final double averageRating;
  final int followersCount;
  final int followingCount;
  final List<String> badges;
  final List<String> interests;
  final bool isVerified;
  final UserActivityStats activityStats;

  const UserSocialProfile({
    required this.userId,
    required this.displayName,
    this.avatar,
    this.bio,
    this.location,
    required this.joinedDate,
    this.reviewsCount = 0,
    this.eventsAttended = 0,
    this.averageRating = 0.0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.badges = const [],
    this.interests = const [],
    this.isVerified = false,
    this.activityStats = const UserActivityStats(),
  });

  UserSocialProfile copyWith({
    String? userId,
    String? displayName,
    String? avatar,
    String? bio,
    String? location,
    DateTime? joinedDate,
    int? reviewsCount,
    int? eventsAttended,
    double? averageRating,
    int? followersCount,
    int? followingCount,
    List<String>? badges,
    List<String>? interests,
    bool? isVerified,
    UserActivityStats? activityStats,
  }) {
    return UserSocialProfile(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      joinedDate: joinedDate ?? this.joinedDate,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      eventsAttended: eventsAttended ?? this.eventsAttended,
      averageRating: averageRating ?? this.averageRating,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      badges: badges ?? this.badges,
      interests: interests ?? this.interests,
      isVerified: isVerified ?? this.isVerified,
      activityStats: activityStats ?? this.activityStats,
    );
  }

  factory UserSocialProfile.fromJson(Map<String, dynamic> json) => 
      _$UserSocialProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserSocialProfileToJson(this);
}

/// User activity statistics
@JsonSerializable()
class UserActivityStats {
  final int totalReviews;
  final int photosShared;
  final int helpfulVotes;
  final int eventsSaved;
  final int eventsShared;
  final DateTime? lastActive;
  final int streakDays;

  const UserActivityStats({
    this.totalReviews = 0,
    this.photosShared = 0,
    this.helpfulVotes = 0,
    this.eventsSaved = 0,
    this.eventsShared = 0,
    this.lastActive,
    this.streakDays = 0,
  });

  factory UserActivityStats.fromJson(Map<String, dynamic> json) => 
      _$UserActivityStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UserActivityStatsToJson(this);
}

/// Social interaction model
@JsonSerializable()
class SocialInteraction {
  final String id;
  final String userId;
  final String targetId; // Event ID, Review ID, etc.
  final SocialInteractionType type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const SocialInteraction({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.type,
    required this.timestamp,
    this.metadata,
  });

  factory SocialInteraction.fromJson(Map<String, dynamic> json) => 
      _$SocialInteractionFromJson(json);
  Map<String, dynamic> toJson() => _$SocialInteractionToJson(this);
}

/// Types of social interactions
enum SocialInteractionType {
  like,
  save,
  share,
  follow,
  helpfulReview,
  reportReview,
  bookmark,
  comment,
}

/// Event social data
@JsonSerializable()
class EventSocialData {
  final String eventId;
  final int likesCount;
  final int savesCount;
  final int sharesCount;
  final int viewsCount;
  final ReviewStats reviewStats;
  final List<UserReview> recentReviews;
  final List<String> frequentTags;
  final double socialScore; // Calculated engagement score

  const EventSocialData({
    required this.eventId,
    this.likesCount = 0,
    this.savesCount = 0,
    this.sharesCount = 0,
    this.viewsCount = 0,
    required this.reviewStats,
    this.recentReviews = const [],
    this.frequentTags = const [],
    this.socialScore = 0.0,
  });

  factory EventSocialData.fromJson(Map<String, dynamic> json) => 
      _$EventSocialDataFromJson(json);
  Map<String, dynamic> toJson() => _$EventSocialDataToJson(this);
}

/// User feed item
@JsonSerializable()
class FeedItem {
  final String id;
  final FeedItemType type;
  final String userId;
  final String? userName;
  final String? userAvatar;
  final DateTime timestamp;
  final String title;
  final String? content;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final List<SocialInteraction> interactions;

  const FeedItem({
    required this.id,
    required this.type,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.timestamp,
    required this.title,
    this.content,
    this.imageUrl,
    this.data = const {},
    this.interactions = const [],
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) => 
      _$FeedItemFromJson(json);
  Map<String, dynamic> toJson() => _$FeedItemToJson(this);
}

/// Feed item types
enum FeedItemType {
  newReview,
  eventAttended,
  eventSaved,
  photoShared,
  achievement,
  recommendation,
  friendActivity,
}

/// Social recommendation
@JsonSerializable()
class SocialRecommendation {
  final String id;
  final String eventId;
  final String? eventTitle;
  final String? eventImageUrl;
  final RecommendationType type;
  final double confidence;
  final String reason;
  final List<String> basedOnEvents;
  final List<String> basedOnUsers;
  final DateTime createdAt;

  const SocialRecommendation({
    required this.id,
    required this.eventId,
    this.eventTitle,
    this.eventImageUrl,
    required this.type,
    required this.confidence,
    required this.reason,
    this.basedOnEvents = const [],
    this.basedOnUsers = const [],
    required this.createdAt,
  });

  factory SocialRecommendation.fromJson(Map<String, dynamic> json) => 
      _$SocialRecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$SocialRecommendationToJson(this);
}

/// Recommendation types
enum RecommendationType {
  similarEvents,
  friendsLiked,
  trending,
  personalizedMatch,
  locationBased,
  timeBased,
}

/// User badge system
@JsonSerializable()
class UserBadge {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final BadgeType type;
  final int requiredValue;
  final String? color;
  final DateTime? earnedAt;
  final bool isRare;

  const UserBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.type,
    required this.requiredValue,
    this.color,
    this.earnedAt,
    this.isRare = false,
  });

  bool get isEarned => earnedAt != null;

  factory UserBadge.fromJson(Map<String, dynamic> json) => 
      _$UserBadgeFromJson(json);
  Map<String, dynamic> toJson() => _$UserBadgeToJson(this);
}

/// Badge types
enum BadgeType {
  reviewCount,
  eventsAttended,
  photosShared,
  helpfulVotes,
  streakDays,
  socialShares,
  earlyAdopter,
  trendsetter,
  explorer,
  familyFun,
}

/// Social notification model specific to social features
@JsonSerializable()
class SocialNotification {
  final String id;
  final String recipientUserId;
  final String? actorUserId;
  final String? actorName;
  final String? actorAvatar;
  final SocialNotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final bool isRead;

  const SocialNotification({
    required this.id,
    required this.recipientUserId,
    this.actorUserId,
    this.actorName,
    this.actorAvatar,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.data = const {},
    this.isRead = false,
  });

  factory SocialNotification.fromJson(Map<String, dynamic> json) => 
      _$SocialNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$SocialNotificationToJson(this);
}

/// Social notification types
enum SocialNotificationType {
  newFollower,
  reviewLiked,
  reviewHelpful,
  eventRecommendation,
  friendActivity,
  badgeEarned,
  mentionInReview,
  photoLiked,
}

/// Trending content model
@JsonSerializable()
class TrendingContent {
  final String id;
  final TrendingContentType type;
  final String title;
  final String? description;
  final String? imageUrl;
  final double trendingScore;
  final int engagementCount;
  final List<String> tags;
  final DateTime updatedAt;
  final Map<String, dynamic> data;

  const TrendingContent({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.imageUrl,
    required this.trendingScore,
    required this.engagementCount,
    this.tags = const [],
    required this.updatedAt,
    this.data = const {},
  });

  factory TrendingContent.fromJson(Map<String, dynamic> json) => 
      _$TrendingContentFromJson(json);
  Map<String, dynamic> toJson() => _$TrendingContentToJson(this);
}

/// Trending content types
enum TrendingContentType {
  event,
  venue,
  hashtag,
  user,
  photo,
  review,
} 