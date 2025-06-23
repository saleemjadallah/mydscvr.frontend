import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/search.dart';
import '../models/event.dart';
import '../services/api/api_client.dart';
import '../services/providers/api_provider.dart';
import 'dart:convert';

/// Search state class
class SearchState {
  final String query;
  final SearchFilters filters;
  final List<Event> results;
  final List<SearchSuggestion> suggestions;
  final List<SearchHistoryItem> history;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int totalCount;
  final bool hasMore;
  final String? nextPageToken;
  final List<SearchResult> searchResults;
  final SearchMetadata searchMetadata;

  const SearchState({
    this.query = '',
    this.filters = const SearchFilters(),
    this.results = const [],
    this.suggestions = const [],
    this.history = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.totalCount = 0,
    this.hasMore = false,
    this.nextPageToken,
    this.searchResults = const [],
    this.searchMetadata = const SearchMetadata(),
  });

  SearchState copyWith({
    String? query,
    SearchFilters? filters,
    List<Event>? results,
    List<SearchSuggestion>? suggestions,
    List<SearchHistoryItem>? history,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? totalCount,
    bool? hasMore,
    String? nextPageToken,
    List<SearchResult>? searchResults,
    SearchMetadata? searchMetadata,
  }) {
    return SearchState(
      query: query ?? this.query,
      filters: filters ?? this.filters,
      results: results ?? this.results,
      suggestions: suggestions ?? this.suggestions,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      nextPageToken: nextPageToken ?? this.nextPageToken,
      searchResults: searchResults ?? this.searchResults,
      searchMetadata: searchMetadata ?? this.searchMetadata,
    );
  }

  bool get hasResults => results.isNotEmpty;
  bool get hasQuery => query.isNotEmpty;
  bool get hasActiveFilters => filters.hasActiveFilters;
  bool get showSuggestions => query.length >= 2 && suggestions.isNotEmpty;
}

/// Search notifier for managing search functionality
class SearchNotifier extends StateNotifier<SearchState> {
  final ApiClient _apiClient;

  SearchNotifier(this._apiClient) : super(const SearchState()) {
    _loadSearchHistory();
    _loadDefaultSuggestions();
  }

  /// Update search query
  void updateQuery(String query) {
    state = state.copyWith(query: query, error: null);
    
    // Debug print
    print('SearchProvider: updateQuery called with "$query"');
    
    if (query.length >= 2) { // API requires min 2 characters
      _getSuggestions(query);
    } else if (query.length == 1) {
      // Show local suggestions for single character queries
      final localSuggestions = _generateLocalSuggestions(query);
      state = state.copyWith(suggestions: localSuggestions);
    } else {
      // Show default suggestions when query is empty
      _loadDefaultSuggestions();
    }
  }

  /// Update search filters
  void updateFilters(SearchFilters filters) {
    state = state.copyWith(filters: filters, error: null);
    if (state.hasQuery) {
      search(state.query);
    }
  }

  /// Clear specific filter
  void clearFilter(String filterType) {
    switch (filterType) {
      case 'category':
        state = state.copyWith(filters: state.filters.copyWith(category: null));
        break;
      case 'areas':
        state = state.copyWith(filters: state.filters.copyWith(areas: []));
        break;
      case 'dateRange':
        state = state.copyWith(filters: state.filters.copyWith(dateRange: null));
        break;
      case 'priceRange':
        state = state.copyWith(filters: state.filters.copyWith(priceRange: null));
        break;
      case 'ageRange':
        state = state.copyWith(filters: state.filters.copyWith(ageRange: null));
        break;
      default:
        break;
    }
    
    if (state.hasQuery) {
      search(state.query);
    }
  }

  /// Clear all filters
  void clearAllFilters() {
    state = state.copyWith(filters: const SearchFilters());
    if (state.hasQuery) {
      search(state.query);
    }
  }

  /// Perform search
  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _apiClient.searchEvents(
        query: query,
        filters: state.filters != null 
            ? jsonEncode(state.filters.toJson())
            : null,
      );
      
      if (response.success && response.data != null) {
        final searchData = response.data!;
        
        final results = (searchData['results'] as List<dynamic>?)
            ?.map((json) => SearchResult.fromJson(json as Map<String, dynamic>))
            .toList() ?? [];
        
        final metadata = SearchMetadata.fromJson(
          searchData['metadata'] as Map<String, dynamic>? ?? {},
        );
        
        state = state.copyWith(
          searchResults: results,
          searchMetadata: metadata,
          isLoading: false,
        );
      } else {
        throw Exception(response.message ?? 'Search failed');
      }
    } catch (e, stack) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load more search results (pagination)
  Future<void> loadMoreResults() async {
    if (state.isLoading || !state.hasMore || state.nextPageToken == null) {
      return;
    }
    
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _apiClient.searchEvents(
        query: state.query,
        filters: state.filters != null 
            ? jsonEncode(state.filters.toJson())
            : null,
      );
      
      if (response.success && response.data != null) {
        final searchData = response.data!;
        
        final newResults = (searchData['results'] as List<dynamic>?)
            ?.map((json) => SearchResult.fromJson(json as Map<String, dynamic>))
            .toList() ?? [];
        
        final metadata = SearchMetadata.fromJson(
          searchData['metadata'] as Map<String, dynamic>? ?? {},
        );
        
        state = state.copyWith(
          searchResults: [...state.searchResults, ...newResults],
          searchMetadata: metadata,
          isLoading: false,
        );
      } else {
        throw Exception(response.message ?? 'Search failed');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load more results',
      );
    }
  }

  /// Get search suggestions
  Future<void> _getSuggestions(String query) async {
    print('SearchProvider: Getting suggestions for "$query"');
    
    // Always generate local suggestions first as fallback
    final localSuggestions = _generateLocalSuggestions(query);
    print('SearchProvider: Generated ${localSuggestions.length} local suggestions');
    
    // Update state with local suggestions immediately
    state = state.copyWith(suggestions: localSuggestions);
    
    try {
      final response = await _apiClient.getSearchSuggestions(query: query, limit: 8);
      
      if (response.success && response.data != null) {
        final suggestionsData = response.data!;
        final suggestions = suggestionsData['suggestions'] as List? ?? [];
        
        final apiSuggestions = suggestions
            .map((s) => _convertBackendSuggestion(s as Map<String, dynamic>))
            .toList();

        print('SearchProvider: Got ${apiSuggestions.length} API suggestions');
        
        // If we got API suggestions, use them, otherwise keep local ones
        if (apiSuggestions.isNotEmpty) {
          state = state.copyWith(suggestions: apiSuggestions);
        }
      }
    } catch (e) {
      print('SearchProvider: API suggestions failed, using local suggestions: $e');
      // Local suggestions are already set above, so no need to do anything
    }
  }

  /// Convert backend suggestion format to frontend SearchSuggestion
  SearchSuggestion _convertBackendSuggestion(Map<String, dynamic> backendSuggestion) {
    final text = backendSuggestion['text'] as String;
    final type = backendSuggestion['type'] as String;
    final count = backendSuggestion['count'] as int? ?? 0;
    
    // Convert backend type to frontend SearchSuggestionType
    SearchSuggestionType suggestionType;
    String? category;
    String? area;
    
    switch (type) {
      case 'category':
        suggestionType = SearchSuggestionType.category;
        // Try to map display name back to category ID for filtering
        category = _getCategoryIdFromDisplayName(text);
        break;
      case 'area':
        suggestionType = SearchSuggestionType.area;
        area = _getAreaIdFromDisplayName(text);
        break;
      case 'venue':
        suggestionType = SearchSuggestionType.venue;
        break;
      case 'event':
        suggestionType = SearchSuggestionType.event;
        break;
      case 'tag':
        suggestionType = SearchSuggestionType.activity;
        break;
      case 'smart':
        suggestionType = SearchSuggestionType.general;
        break;
      default:
        suggestionType = SearchSuggestionType.general;
    }
    
    return SearchSuggestion(
      id: 'api_${type}_${text.hashCode}',
      text: text,
      type: suggestionType,
      category: category,
      area: area,
      popularity: count,
    );
  }

  /// Helper to get category ID from display name
  String? _getCategoryIdFromDisplayName(String displayName) {
    switch (displayName.toLowerCase()) {
      case 'food & dining':
        return 'food_and_dining';
      case 'kids & family':
        return 'kids_and_family';
      case 'indoor activities':
        return 'indoor_activities';
      case 'outdoor activities':
        return 'outdoor_activities';
      case 'tours & sightseeing':
        return 'tours_and_sightseeing';
      case 'water sports':
        return 'water_sports';
      case 'music & concerts':
        return 'music_and_concerts';
      case 'comedy & shows':
        return 'comedy_and_shows';
      case 'sports & fitness':
        return 'sports_and_fitness';
      case 'business & networking':
        return 'business_and_networking';
      case 'festivals & celebrations':
        return 'festivals_and_celebrations';
      default:
        return null;
    }
  }

  /// Helper to get area ID from display name
  String? _getAreaIdFromDisplayName(String displayName) {
    final areas = DubaiArea.allAreas;
    for (final area in areas) {
      if (area.displayName.toLowerCase() == displayName.toLowerCase()) {
        return area.id;
      }
    }
    return null;
  }

  /// Generate local suggestions as fallback
  List<SearchSuggestion> _generateLocalSuggestions(String query) {
    final suggestions = <SearchSuggestion>[];
    final lowercaseQuery = query.toLowerCase();

    // Enhanced common search terms with better matching
    final smartTerms = {
      'a': ['aquarium', 'adventure', 'art galleries', 'amusement parks'],
      'b': ['beach', 'burj khalifa', 'boat tours', 'brunch'],
      'c': ['cultural events', 'cooking classes', 'concerts', 'comedy shows'],
      'd': ['desert safari', 'dubai mall', 'dining', 'dance classes'],
      'e': ['entertainment', 'exhibitions', 'escape rooms', 'educational'],
      'f': ['family fun', 'fountain show', 'festivals', 'food tours'],
      'g': ['golf', 'gardens', 'gaming', 'group activities'],
      'h': ['heritage tours', 'hiking', 'horse riding', 'happy hour'],
      'i': ['indoor activities', 'ice skating', 'interactive museums'],
      'j': ['jet skiing', 'jungle safari', 'jewelry shopping'],
      'k': ['kids activities', 'kayaking', 'karting'],
      'l': ['live shows', 'luxury experiences', 'local tours'],
      'm': ['museums', 'music concerts', 'marina walks', 'malls'],
      'n': ['nightlife', 'nature tours', 'new year events'],
      'o': ['outdoor adventures', 'opera shows', 'observation decks'],
      'p': ['parks', 'photography tours', 'pool parties', 'puppet shows'],
      'q': ['quad biking', 'quiet cafes', 'quiz nights'],
      'r': ['restaurants', 'rooftop dining', 'romantic dinners'],
      's': ['shopping', 'sports', 'spa treatments', 'skydiving'],
      't': ['theme parks', 'tours', 'theater shows', 'team building'],
      'u': ['underwater dining', 'unique experiences', 'urban exploration'],
      'v': ['vintage markets', 'virtual reality', 'volleyball'],
      'w': ['water sports', 'wildlife', 'walking tours', 'weekend activities'],
      'x': ['extreme sports', 'exhibitions'],
      'y': ['yacht tours', 'yoga classes', 'youth activities'],
      'z': ['zoo visits', 'zip lining', 'zumba classes'],
    };

    // Smart matching based on first character and partial matches
    if (lowercaseQuery.isNotEmpty) {
      final firstChar = lowercaseQuery[0];
      final charTerms = smartTerms[firstChar] ?? [];
      
      for (final term in charTerms) {
        if (term.startsWith(lowercaseQuery) || term.contains(lowercaseQuery)) {
          suggestions.add(SearchSuggestion(
            id: 'smart_$term',
            text: term,
            type: SearchSuggestionType.general,
            popularity: term.startsWith(lowercaseQuery) ? 100 : 80,
          ));
        }
      }
    }

    // Category suggestions (only if query length > 1)
    if (query.length > 1) {
      for (final category in EventCategory.allCategories) {
        if (category.name.toLowerCase().contains(lowercaseQuery)) {
          suggestions.add(SearchSuggestion(
            id: 'cat_${category.id}',
            text: category.name,
            type: SearchSuggestionType.category,
            category: category.id,
            icon: category.icon,
            popularity: 90,
          ));
        }
      }

      // Area suggestions
      for (final area in DubaiArea.allAreas) {
        if (area.name.toLowerCase().contains(lowercaseQuery) ||
            area.displayName.toLowerCase().contains(lowercaseQuery)) {
          suggestions.add(SearchSuggestion(
            id: 'area_${area.id}',
            text: '${area.emoji} ${area.displayName}',
            type: SearchSuggestionType.area,
            area: area.id,
            popularity: 85,
          ));
        }
      }
    }

    // Sort by popularity and relevance
    suggestions.sort((a, b) {
      final aStartsWithQuery = a.text.toLowerCase().startsWith(lowercaseQuery);
      final bStartsWithQuery = b.text.toLowerCase().startsWith(lowercaseQuery);
      
      if (aStartsWithQuery && !bStartsWithQuery) return -1;
      if (!aStartsWithQuery && bStartsWithQuery) return 1;
      
      return (b.popularity ?? 0).compareTo(a.popularity ?? 0);
    });

    return suggestions.take(6).toList();
  }

  /// Add to search history
  void _addToSearchHistory(String query, int resultCount) {
    final historyItem = SearchHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      query: query,
      filters: state.filters.hasActiveFilters ? state.filters : null,
      timestamp: DateTime.now(),
      resultCount: resultCount,
    );

    final updatedHistory = [historyItem, ...state.history]
        .where((item) => item.query.toLowerCase() != query.toLowerCase())
        .take(10)
        .toList();

    state = state.copyWith(history: updatedHistory);
    _saveSearchHistory();
  }

  /// Load search history from storage
  Future<void> _loadSearchHistory() async {
    // TODO: Implement with shared_preferences
    // For now, return empty list
    state = state.copyWith(history: []);
  }

  /// Save search history to storage
  Future<void> _saveSearchHistory() async {
    // TODO: Implement with shared_preferences
  }

  /// Clear search history
  void clearSearchHistory() {
    state = state.copyWith(history: []);
    _saveSearchHistory();
  }

  /// Remove item from search history
  void removeFromHistory(String historyId) {
    final updatedHistory = state.history
        .where((item) => item.id != historyId)
        .toList();
    
    state = state.copyWith(history: updatedHistory);
    _saveSearchHistory();
  }

  /// Load default suggestions
  void _loadDefaultSuggestions() {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    final hour = now.hour;
    
    // Time and day-based suggestions
    List<SearchSuggestion> defaultSuggestions = [];
    
    if (dayOfWeek >= 6) { // Weekend
      defaultSuggestions = [
        const SearchSuggestion(
          id: 'weekend_1',
          text: 'Weekend Family Activities',
          type: SearchSuggestionType.general,
          popularity: 100,
        ),
        const SearchSuggestion(
          id: 'weekend_2',
          text: 'Outdoor Adventures',
          type: SearchSuggestionType.category,
          category: 'outdoor_activities',
          popularity: 95,
        ),
        const SearchSuggestion(
          id: 'weekend_3',
          text: 'Beach Activities',
          type: SearchSuggestionType.general,
          popularity: 90,
        ),
      ];
    } else if (hour >= 18) { // Evening
      defaultSuggestions = [
        const SearchSuggestion(
          id: 'evening_1',
          text: 'Evening Entertainment',
          type: SearchSuggestionType.general,
          popularity: 100,
        ),
        const SearchSuggestion(
          id: 'evening_2',
          text: 'Dinner Shows',
          type: SearchSuggestionType.general,
          popularity: 95,
        ),
        const SearchSuggestion(
          id: 'evening_3',
          text: 'Night Markets',
          type: SearchSuggestionType.general,
          popularity: 90,
        ),
      ];
    } else { // Regular day suggestions
      defaultSuggestions = [
        const SearchSuggestion(
          id: 'popular_1',
          text: 'Kids & Family',
          type: SearchSuggestionType.category,
          category: 'kids_and_family',
          popularity: 100,
        ),
        const SearchSuggestion(
          id: 'popular_2',
          text: 'Indoor Activities',
          type: SearchSuggestionType.category,
          category: 'indoor_activities',
          popularity: 95,
        ),
        const SearchSuggestion(
          id: 'popular_3',
          text: 'Cultural Events',
          type: SearchSuggestionType.category,
          category: 'cultural',
          popularity: 90,
        ),
      ];
    }
    
    // Add always popular suggestions
    defaultSuggestions.addAll([
      const SearchSuggestion(
        id: 'always_1',
        text: 'Dubai Aquarium',
        type: SearchSuggestionType.venue,
        popularity: 85,
      ),
      const SearchSuggestion(
        id: 'always_2',
        text: 'Food & Dining',
        type: SearchSuggestionType.category,
        category: 'food_and_dining',
        popularity: 80,
      ),
      const SearchSuggestion(
        id: 'always_3',
        text: 'Free Events',
        type: SearchSuggestionType.general,
        popularity: 75,
      ),
    ]);

    print('SearchProvider: Loading ${defaultSuggestions.length} default suggestions for ${dayOfWeek >= 6 ? 'weekend' : hour >= 18 ? 'evening' : 'daytime'}');
    state = state.copyWith(suggestions: defaultSuggestions);
  }

  /// Clear search results
  void clearResults() {
    state = state.copyWith(
      query: '',
      results: [],
      error: null,
      totalCount: 0,
      hasMore: false,
      nextPageToken: null,
    );
  }

  /// Quick search by category
  Future<void> searchByCategory(String categoryId) async {
    final category = EventCategory.allCategories
        .firstWhere((cat) => cat.id == categoryId);
    
    state = state.copyWith(
      filters: state.filters.copyWith(category: categoryId),
    );
    
    await search(category.name);
  }

  /// Quick search by area
  Future<void> searchByArea(String areaId) async {
    final area = DubaiArea.allAreas
        .firstWhere((area) => area.id == areaId);
    
    state = state.copyWith(
      filters: state.filters.copyWith(areas: [areaId]),
    );
    
    await search(area.displayName);
  }

  /// Search from history item
  Future<void> searchFromHistory(SearchHistoryItem historyItem) async {
    state = state.copyWith(
      filters: historyItem.filters ?? const SearchFilters(),
    );
    
    await search(historyItem.query);
  }
}

/// Provider for search functionality
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SearchNotifier(apiClient);
});

/// Provider for search suggestions
final searchSuggestionsProvider = Provider<List<SearchSuggestion>>((ref) {
  final searchState = ref.watch(searchProvider);
  return searchState.suggestions;
});

/// Provider for search results
final searchResultsProvider = Provider<List<Event>>((ref) {
  final searchState = ref.watch(searchProvider);
  return searchState.results;
});

/// Provider for search history
final searchHistoryProvider = Provider<List<SearchHistoryItem>>((ref) {
  final searchState = ref.watch(searchProvider);
  return searchState.history;
});

/// Provider for active filters count
final activeFiltersCountProvider = Provider<int>((ref) {
  final searchState = ref.watch(searchProvider);
  return searchState.filters.activeFilterCount;
});

/// Provider for search loading state
final searchLoadingProvider = Provider<bool>((ref) {
  final searchState = ref.watch(searchProvider);
  return searchState.isLoading;
});

/// Provider for popular categories
final popularCategoriesProvider = Provider<List<EventCategory>>((ref) {
  return EventCategory.familyCategories.take(6).toList();
});

/// Provider for popular areas
final popularAreasProvider = Provider<List<DubaiArea>>((ref) {
  return DubaiArea.popularAreas;
});

/// Provider for trending searches
final trendingSearchesProvider = Provider<List<String>>((ref) {
  return [
    'Dubai Aquarium',
    'Desert Safari',
    'Family Fun',
    'Water Parks',
    'Cultural Events',
    'Kids Activities',
    'Shopping Malls',
    'Beach Activities',
  ];
}); 