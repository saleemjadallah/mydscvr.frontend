import 'package:flutter/material.dart';
import 'event.dart';

/// Search response model with results and metadata
class SearchResponse {
  final List<Event> events;
  final int total;
  final String query;
  final int searchTimeMs;
  final Map<String, dynamic>? filters;
  final List<SearchSuggestion>? suggestions;

  const SearchResponse({
    required this.events,
    required this.total,
    required this.query,
    required this.searchTimeMs,
    this.filters,
    this.suggestions,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      events: (json['events'] as List? ?? []).map((e) => Event.fromJson(e)).toList(),
      total: json['total'] ?? 0,
      query: json['query'] ?? '',
      searchTimeMs: json['search_time_ms'] ?? 0,
      filters: json['filters'],
      suggestions: (json['suggestions'] as List? ?? [])
          .map((s) => SearchSuggestion.fromJson(s))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'events': events.map((e) => e.toJson()).toList(),
      'total': total,
      'query': query,
      'search_time_ms': searchTimeMs,
      'filters': filters,
      'suggestions': suggestions?.map((s) => s.toJson()).toList(),
    };
  }

  bool get hasResults => events.isNotEmpty;
  bool get hasSuggestions => suggestions?.isNotEmpty ?? false;
}

/// Search filters model for advanced filtering
class SearchFilters {
  final String? category;
  final List<String> areas;
  final DateTimeRange? dateRange;
  final PriceRange? priceRange;
  final AgeRange? ageRange;
  final bool familyFriendlyOnly;
  final bool freeEventsOnly;
  final bool hasParking;
  final bool wheelchairAccessible;
  final bool indoorOnly;
  final bool outdoorOnly;
  final List<String> amenities;
  final EventDuration? duration;
  final List<String> languages;
  final int? maxCapacity;
  final List<String> eventTypes;

  const SearchFilters({
    this.category,
    this.areas = const [],
    this.dateRange,
    this.priceRange,
    this.ageRange,
    this.familyFriendlyOnly = false,
    this.freeEventsOnly = false,
    this.hasParking = false,
    this.wheelchairAccessible = false,
    this.indoorOnly = false,
    this.outdoorOnly = false,
    this.amenities = const [],
    this.duration,
    this.languages = const [],
    this.maxCapacity,
    this.eventTypes = const [],
  });

  SearchFilters copyWith({
    String? category,
    List<String>? areas,
    DateTimeRange? dateRange,
    PriceRange? priceRange,
    AgeRange? ageRange,
    bool? familyFriendlyOnly,
    bool? freeEventsOnly,
    bool? hasParking,
    bool? wheelchairAccessible,
    bool? indoorOnly,
    bool? outdoorOnly,
    List<String>? amenities,
    EventDuration? duration,
    List<String>? languages,
    int? maxCapacity,
    List<String>? eventTypes,
  }) {
    return SearchFilters(
      category: category ?? this.category,
      areas: areas ?? this.areas,
      dateRange: dateRange ?? this.dateRange,
      priceRange: priceRange ?? this.priceRange,
      ageRange: ageRange ?? this.ageRange,
      familyFriendlyOnly: familyFriendlyOnly ?? this.familyFriendlyOnly,
      freeEventsOnly: freeEventsOnly ?? this.freeEventsOnly,
      hasParking: hasParking ?? this.hasParking,
      wheelchairAccessible: wheelchairAccessible ?? this.wheelchairAccessible,
      indoorOnly: indoorOnly ?? this.indoorOnly,
      outdoorOnly: outdoorOnly ?? this.outdoorOnly,
      amenities: amenities ?? this.amenities,
      duration: duration ?? this.duration,
      languages: languages ?? this.languages,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      eventTypes: eventTypes ?? this.eventTypes,
    );
  }

  bool get hasActiveFilters {
    return category != null ||
        areas.isNotEmpty ||
        dateRange != null ||
        priceRange != null ||
        ageRange != null ||
        familyFriendlyOnly ||
        freeEventsOnly ||
        hasParking ||
        wheelchairAccessible ||
        indoorOnly ||
        outdoorOnly ||
        amenities.isNotEmpty ||
        duration != null ||
        languages.isNotEmpty ||
        maxCapacity != null ||
        eventTypes.isNotEmpty;
  }

  int get activeFilterCount {
    int count = 0;
    if (category != null) count++;
    if (areas.isNotEmpty) count++;
    if (dateRange != null) count++;
    if (priceRange != null) count++;
    if (ageRange != null) count++;
    if (familyFriendlyOnly) count++;
    if (freeEventsOnly) count++;
    if (hasParking) count++;
    if (wheelchairAccessible) count++;
    if (indoorOnly) count++;
    if (outdoorOnly) count++;
    if (amenities.isNotEmpty) count++;
    if (duration != null) count++;
    if (languages.isNotEmpty) count++;
    if (maxCapacity != null) count++;
    if (eventTypes.isNotEmpty) count++;
    return count;
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'areas': areas,
      'dateRange': dateRange != null ? {
        'start': dateRange!.start.toIso8601String(),
        'end': dateRange!.end.toIso8601String(),
      } : null,
      'priceRange': priceRange?.toJson(),
      'ageRange': ageRange?.toJson(),
      'familyFriendlyOnly': familyFriendlyOnly,
      'freeEventsOnly': freeEventsOnly,
      'hasParking': hasParking,
      'wheelchairAccessible': wheelchairAccessible,
      'indoorOnly': indoorOnly,
      'outdoorOnly': outdoorOnly,
      'amenities': amenities,
      'duration': duration?.toJson(),
      'languages': languages,
      'maxCapacity': maxCapacity,
      'eventTypes': eventTypes,
    };
  }

  factory SearchFilters.fromJson(Map<String, dynamic> json) {
    return SearchFilters(
      category: json['category'],
      areas: List<String>.from(json['areas'] ?? []),
      dateRange: json['dateRange'] != null ? DateTimeRange(
        start: DateTime.parse(json['dateRange']['start']),
        end: DateTime.parse(json['dateRange']['end']),
      ) : null,
      priceRange: json['priceRange'] != null ? PriceRange.fromJson(json['priceRange']) : null,
      ageRange: json['ageRange'] != null ? AgeRange.fromJson(json['ageRange']) : null,
      familyFriendlyOnly: json['familyFriendlyOnly'] ?? false,
      freeEventsOnly: json['freeEventsOnly'] ?? false,
      hasParking: json['hasParking'] ?? false,
      wheelchairAccessible: json['wheelchairAccessible'] ?? false,
      indoorOnly: json['indoorOnly'] ?? false,
      outdoorOnly: json['outdoorOnly'] ?? false,
      amenities: List<String>.from(json['amenities'] ?? []),
      duration: json['duration'] != null ? EventDuration.fromJson(json['duration']) : null,
      languages: List<String>.from(json['languages'] ?? []),
      maxCapacity: json['maxCapacity'],
      eventTypes: List<String>.from(json['eventTypes'] ?? []),
    );
  }
}

/// Price range filter
class PriceRange {
  final double min;
  final double max;
  final String currency;

  const PriceRange({
    required this.min,
    required this.max,
    this.currency = 'AED',
  });

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
      'currency': currency,
    };
  }

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      min: json['min'].toDouble(),
      max: json['max'].toDouble(),
      currency: json['currency'] ?? 'AED',
    );
  }

  @override
  String toString() {
    if (min == 0 && max >= 1000) return 'Free - ${max.toInt()} $currency';
    if (min == 0) return 'Free - ${max.toInt()} $currency';
    if (max >= 1000) return '${min.toInt()}+ $currency';
    return '${min.toInt()} - ${max.toInt()} $currency';
  }
}

/// Age range filter
class AgeRange {
  final int min;
  final int max;

  const AgeRange({
    required this.min,
    required this.max,
  });

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
    };
  }

  factory AgeRange.fromJson(Map<String, dynamic> json) {
    return AgeRange(
      min: json['min'],
      max: json['max'],
    );
  }

  @override
  String toString() {
    if (min == 0 && max >= 18) return 'All Ages';
    if (min == 0) return '0-${max} years';
    if (max >= 18) return '${min}+ years';
    return '$min-$max years';
  }

  static List<AgeRange> get predefinedRanges => [
    const AgeRange(min: 0, max: 100), // All ages
    const AgeRange(min: 0, max: 5),   // Toddlers
    const AgeRange(min: 6, max: 12),  // Kids
    const AgeRange(min: 13, max: 17), // Teens
    const AgeRange(min: 18, max: 100), // Adults
  ];
}

/// Event duration filter
class EventDuration {
  final int hours;
  final int minutes;

  const EventDuration({
    this.hours = 0,
    this.minutes = 0,
  });

  int get totalMinutes => hours * 60 + minutes;

  Map<String, dynamic> toJson() {
    return {
      'hours': hours,
      'minutes': minutes,
    };
  }

  factory EventDuration.fromJson(Map<String, dynamic> json) {
    return EventDuration(
      hours: json['hours'] ?? 0,
      minutes: json['minutes'] ?? 0,
    );
  }

  @override
  String toString() {
    if (hours == 0) return '${minutes}min';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}min';
  }

  static List<EventDuration> get predefinedDurations => [
    const EventDuration(minutes: 30),
    const EventDuration(hours: 1),
    const EventDuration(hours: 2),
    const EventDuration(hours: 3),
    const EventDuration(hours: 4),
    const EventDuration(hours: 8), // Full day
  ];
}

/// Dubai-specific area categories
class DubaiArea {
  final String id;
  final String name;
  final String displayName;
  final String emoji;
  final List<String> landmarks;
  final bool isPopular;

  const DubaiArea({
    required this.id,
    required this.name,
    required this.displayName,
    required this.emoji,
    this.landmarks = const [],
    this.isPopular = false,
  });

  static List<DubaiArea> get allAreas => [
    const DubaiArea(
      id: 'downtown',
      name: 'Downtown Dubai',
      displayName: 'Downtown',
      emoji: '🏙️',
      landmarks: ['Burj Khalifa', 'Dubai Mall', 'Dubai Fountain'],
      isPopular: true,
    ),
    const DubaiArea(
      id: 'marina',
      name: 'Dubai Marina',
      displayName: 'Marina',
      emoji: '🛥️',
      landmarks: ['Marina Walk', 'JBR Beach', 'The Beach'],
      isPopular: true,
    ),
    const DubaiArea(
      id: 'jbr',
      name: 'Jumeirah Beach Residence',
      displayName: 'JBR',
      emoji: '🏖️',
      landmarks: ['The Beach', 'The Walk', 'Ain Dubai'],
      isPopular: true,
    ),
    const DubaiArea(
      id: 'palm',
      name: 'Palm Jumeirah',
      displayName: 'Palm Jumeirah',
      emoji: '🌴',
      landmarks: ['Atlantis', 'Nakheel Mall', 'Aquaventure'],
      isPopular: true,
    ),
    const DubaiArea(
      id: 'bur_dubai',
      name: 'Bur Dubai',
      displayName: 'Bur Dubai',
      emoji: '🕌',
      landmarks: ['Dubai Museum', 'Gold Souk', 'Spice Souk'],
      isPopular: true,
    ),
    const DubaiArea(
      id: 'deira',
      name: 'Deira',
      displayName: 'Deira',
      emoji: '🛍️',
      landmarks: ['Deira City Centre', 'Fish Market', 'Heritage Village'],
      isPopular: true,
    ),
    const DubaiArea(
      id: 'business_bay',
      name: 'Business Bay',
      displayName: 'Business Bay',
      emoji: '🏢',
      landmarks: ['Business Bay Bridge', 'JW Marriott'],
      isPopular: false,
    ),
    const DubaiArea(
      id: 'jumeirah',
      name: 'Jumeirah',
      displayName: 'Jumeirah',
      emoji: '🏝️',
      landmarks: ['Burj Al Arab', 'Jumeirah Beach', 'Souk Madinat'],
      isPopular: true,
    ),
    const DubaiArea(
      id: 'city_walk',
      name: 'City Walk',
      displayName: 'City Walk',
      emoji: '🚶',
      landmarks: ['City Walk Mall', 'Green Planet'],
      isPopular: false,
    ),
    const DubaiArea(
      id: 'dubai_hills',
      name: 'Dubai Hills',
      displayName: 'Dubai Hills',
      emoji: '⛰️',
      landmarks: ['Dubai Hills Mall', 'Dubai Hills Park'],
      isPopular: false,
    ),
  ];

  static List<DubaiArea> get popularAreas => allAreas.where((area) => area.isPopular).toList();
}

/// Event categories specific to Dubai family activities
class EventCategory {
  final String id;
  final String name;
  final String emoji;
  final IconData icon;
  final Color color;
  final List<String> subcategories;
  final bool isFamilyFriendly;

  const EventCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.icon,
    required this.color,
    this.subcategories = const [],
    this.isFamilyFriendly = true,
  });

  static List<EventCategory> get allCategories => [
    EventCategory(
      id: 'family_fun',
      name: 'Family Fun',
      emoji: '👨‍👩‍👧‍👦',
      icon: Icons.family_restroom,
      color: const Color(0xFF6C63FF),
      subcategories: ['Parks', 'Playgrounds', 'Family Shows'],
    ),
    EventCategory(
      id: 'water_activities',
      name: 'Water Activities',
      emoji: '🌊',
      icon: Icons.pool,
      color: const Color(0xFF00BCD4),
      subcategories: ['Beach', 'Water Parks', 'Swimming'],
    ),
    EventCategory(
      id: 'cultural',
      name: 'Cultural',
      emoji: '🕌',
      icon: Icons.account_balance,
      color: const Color(0xFFFF9800),
      subcategories: ['Museums', 'Heritage', 'Traditional Shows'],
    ),
    EventCategory(
      id: 'adventure',
      name: 'Adventure',
      emoji: '🎢',
      icon: Icons.terrain,
      color: const Color(0xFF4CAF50),
      subcategories: ['Theme Parks', 'Desert Safari', 'Outdoor Sports'],
    ),
    EventCategory(
      id: 'educational',
      name: 'Educational',
      emoji: '📚',
      icon: Icons.school,
      color: const Color(0xFF9C27B0),
      subcategories: ['Science Centers', 'Workshops', 'Learning Centers'],
    ),
    EventCategory(
      id: 'entertainment',
      name: 'Entertainment',
      emoji: '🎭',
      icon: Icons.theater_comedy,
      color: const Color(0xFFE91E63),
      subcategories: ['Shows', 'Performances', 'Cinema'],
    ),
    EventCategory(
      id: 'shopping',
      name: 'Shopping',
      emoji: '🛒',
      icon: Icons.shopping_bag,
      color: const Color(0xFFFF5722),
      subcategories: ['Malls', 'Souks', 'Markets'],
    ),
    EventCategory(
      id: 'dining',
      name: 'Dining',
      emoji: '🍽️',
      icon: Icons.restaurant,
      color: const Color(0xFFFFEB3B),
      subcategories: ['Restaurants', 'Food Festivals', 'Cooking Classes'],
    ),
  ];

  static List<EventCategory> get familyCategories => 
      allCategories.where((cat) => cat.isFamilyFriendly).toList();
}

/// Search suggestion model
class SearchSuggestion {
  final String id;
  final String text;
  final SearchSuggestionType type;
  final String? category;
  final String? area;
  final IconData? icon;
  final int popularity;

  const SearchSuggestion({
    required this.id,
    required this.text,
    required this.type,
    this.category,
    this.area,
    this.icon,
    this.popularity = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.name,
      'category': category,
      'area': area,
      'popularity': popularity,
    };
  }

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      id: json['id'],
      text: json['text'],
      type: SearchSuggestionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SearchSuggestionType.general,
      ),
      category: json['category'],
      area: json['area'],
      popularity: json['popularity'] ?? 0,
    );
  }
}

/// Types of search suggestions
enum SearchSuggestionType {
  general,
  category,
  area,
  venue,
  event,
  activity,
}

/// Search history item
class SearchHistoryItem {
  final String id;
  final String query;
  final SearchFilters? filters;
  final DateTime timestamp;
  final int resultCount;

  const SearchHistoryItem({
    required this.id,
    required this.query,
    this.filters,
    required this.timestamp,
    this.resultCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'query': query,
      'filters': filters?.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'resultCount': resultCount,
    };
  }

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      id: json['id'],
      query: json['query'],
      filters: json['filters'] != null ? SearchFilters.fromJson(json['filters']) : null,
      timestamp: DateTime.parse(json['timestamp']),
      resultCount: json['resultCount'] ?? 0,
    );
  }
}

/// Search result model
class SearchResult {
  final List<Event> events;
  final List<SearchSuggestion> suggestions;
  final int totalCount;
  final bool hasMore;
  final String? nextPageToken;

  const SearchResult({
    required this.events,
    required this.suggestions,
    required this.totalCount,
    this.hasMore = false,
    this.nextPageToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'events': events.map((e) => e.toJson()).toList(),
      'suggestions': suggestions.map((s) => s.toJson()).toList(),
      'totalCount': totalCount,
      'hasMore': hasMore,
      'nextPageToken': nextPageToken,
    };
  }

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      events: (json['events'] as List).map((e) => Event.fromJson(e)).toList(),
      suggestions: (json['suggestions'] as List).map((s) => SearchSuggestion.fromJson(s)).toList(),
      totalCount: json['totalCount'] ?? 0,
      hasMore: json['hasMore'] ?? false,
      nextPageToken: json['nextPageToken'],
    );
  }
}

/// Search metadata for tracking search analytics
class SearchMetadata {
  final int totalResults;
  final int searchTime;
  final String? suggestedQuery;
  final Map<String, int>? facets;
  final bool hasMore;
  final int? nextPage;

  const SearchMetadata({
    this.totalResults = 0,
    this.searchTime = 0,
    this.suggestedQuery,
    this.facets,
    this.hasMore = false,
    this.nextPage,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalResults': totalResults,
      'searchTime': searchTime,
      'suggestedQuery': suggestedQuery,
      'facets': facets,
      'hasMore': hasMore,
      'nextPage': nextPage,
    };
  }

  factory SearchMetadata.fromJson(Map<String, dynamic> json) {
    return SearchMetadata(
      totalResults: json['totalResults'] ?? 0,
      searchTime: json['searchTime'] ?? 0,
      suggestedQuery: json['suggestedQuery'],
      facets: json['facets'] != null ? Map<String, int>.from(json['facets']) : null,
      hasMore: json['hasMore'] ?? false,
      nextPage: json['nextPage'],
    );
  }
} 