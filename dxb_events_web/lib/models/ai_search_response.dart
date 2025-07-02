import 'package:json_annotation/json_annotation.dart';
import 'event.dart';

part 'ai_search_response.g.dart';

/// AI Search Response model that matches the backend response format
@JsonSerializable()
class AISearchResponse {
  final List<Event> events;
  @JsonKey(name: 'ai_response')
  final String aiResponse;
  final List<String> suggestions;
  @JsonKey(name: 'query_analysis')
  final QueryAnalysis queryAnalysis;
  final Pagination pagination;
  @JsonKey(name: 'processing_time_ms')
  final int processingTimeMs;
  @JsonKey(name: 'ai_enabled')
  final bool aiEnabled;
  final AISearchFilters? filters;

  const AISearchResponse({
    required this.events,
    required this.aiResponse,
    required this.suggestions,
    required this.queryAnalysis,
    required this.pagination,
    required this.processingTimeMs,
    required this.aiEnabled,
    this.filters,
  });

  factory AISearchResponse.fromJson(Map<String, dynamic> json) => _$AISearchResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AISearchResponseToJson(this);
}

/// Query Analysis from AI search
@JsonSerializable()
class QueryAnalysis {
  final String intent;
  @JsonKey(name: 'time_period')
  final String? timePeriod;
  @JsonKey(name: 'date_from')
  final String? dateFrom;
  @JsonKey(name: 'date_to')
  final String? dateTo;
  final List<String> categories;
  @JsonKey(name: 'price_range')
  final PriceRange? priceRange;
  @JsonKey(name: 'age_group')
  final String? ageGroup;
  @JsonKey(name: 'family_friendly')
  final bool? familyFriendly;
  @JsonKey(name: 'location_preferences')
  final List<String> locationPreferences;
  final List<String> keywords;
  final double confidence;

  const QueryAnalysis({
    required this.intent,
    this.timePeriod,
    this.dateFrom,
    this.dateTo,
    required this.categories,
    this.priceRange,
    this.ageGroup,
    this.familyFriendly,
    required this.locationPreferences,
    required this.keywords,
    required this.confidence,
  });

  factory QueryAnalysis.fromJson(Map<String, dynamic> json) => _$QueryAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$QueryAnalysisToJson(this);
}

/// Price Range from query analysis
@JsonSerializable()
class PriceRange {
  final double? min;
  final double? max;

  const PriceRange({
    this.min,
    this.max,
  });

  factory PriceRange.fromJson(Map<String, dynamic> json) => _$PriceRangeFromJson(json);
  Map<String, dynamic> toJson() => _$PriceRangeToJson(this);
}

/// Pagination information
@JsonSerializable()
class Pagination {
  final int page;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'has_next')
  final bool hasNext;
  @JsonKey(name: 'has_prev')
  final bool hasPrev;

  const Pagination({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => _$PaginationFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}

/// AI Search Filters
@JsonSerializable()
class AISearchFilters {
  final List<String> categories;
  final List<String> areas;
  @JsonKey(name: 'price_ranges')
  final List<PriceRangeOption> priceRanges;
  @JsonKey(name: 'age_groups')
  final List<String> ageGroups;

  const AISearchFilters({
    required this.categories,
    required this.areas,
    required this.priceRanges,
    required this.ageGroups,
  });

  factory AISearchFilters.fromJson(Map<String, dynamic> json) => _$AISearchFiltersFromJson(json);
  Map<String, dynamic> toJson() => _$AISearchFiltersToJson(this);
}

/// Price Range Option
@JsonSerializable()
class PriceRangeOption {
  final double? min;
  final double? max;
  final String label;

  const PriceRangeOption({
    this.min,
    this.max,
    required this.label,
  });

  factory PriceRangeOption.fromJson(Map<String, dynamic> json) => _$PriceRangeOptionFromJson(json);
  Map<String, dynamic> toJson() => _$PriceRangeOptionToJson(this);
}