import 'package:json_annotation/json_annotation.dart';
import 'event.dart';

part 'ai_search.g.dart';

@JsonSerializable()
class QueryIntent {
  final List<String> ageGroups;
  final String? budget;
  final List<String> areas;
  final List<String> activityTypes;
  final String? timeOfDay;
  final List<String> keywords;

  const QueryIntent({
    required this.ageGroups,
    this.budget,
    required this.areas,
    required this.activityTypes,
    this.timeOfDay,
    required this.keywords,
  });

  factory QueryIntent.fromJson(Map<String, dynamic> json) => _$QueryIntentFromJson(json);
  Map<String, dynamic> toJson() => _$QueryIntentToJson(this);
  
  factory QueryIntent.empty() => const QueryIntent(
    ageGroups: [],
    areas: [],
    activityTypes: [],
    keywords: [],
  );
}

@JsonSerializable()
class RankedEvent {
  final Event event;
  final int score;
  final String? reasoning;

  const RankedEvent({
    required this.event,
    required this.score,
    this.reasoning,
  });

  factory RankedEvent.fromJson(Map<String, dynamic> json) => _$RankedEventFromJson(json);
  Map<String, dynamic> toJson() => _$RankedEventToJson(this);
}

@JsonSerializable()
class AISearchResponse {
  final List<RankedEvent> results;
  final String aiResponse;
  final QueryIntent intent;
  final List<String> suggestions;

  const AISearchResponse({
    required this.results,
    required this.aiResponse,
    required this.intent,
    required this.suggestions,
  });

  factory AISearchResponse.fromJson(Map<String, dynamic> json) => _$AISearchResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AISearchResponseToJson(this);
  
  factory AISearchResponse.empty() => AISearchResponse(
    results: const [],
    aiResponse: '',
    intent: QueryIntent.empty(),
    suggestions: const [],
  );
}

@JsonSerializable()
class EventScore {
  final String id;
  final int score;
  final String? reason;

  const EventScore({
    required this.id,
    required this.score,
    this.reason,
  });

  factory EventScore.fromJson(Map<String, dynamic> json) => _$EventScoreFromJson(json);
  Map<String, dynamic> toJson() => _$EventScoreToJson(this);
}