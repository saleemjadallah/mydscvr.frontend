import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/event.dart';
import '../../services/super_search_service.dart';
import '../../widgets/events/event_card.dart';
import '../../core/constants/app_colors.dart';
import '../event_details/event_details_screen.dart';

/// MyDscvr Super Search Screen - Powered by Algolia
/// 
/// Features:
/// - Instant search with < 100ms response time
/// - Typo tolerance and intelligent query enhancement
/// - Advanced filtering and faceted search
/// - Real-time suggestions and autocomplete
/// - Beautiful, responsive UI with glassmorphic design
class SuperSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SuperSearchScreen({
    super.key,
    this.initialQuery,
  });

  @override
  State<SuperSearchScreen> createState() => _SuperSearchScreenState();
}

class _SuperSearchScreenState extends State<SuperSearchScreen>
    with TickerProviderStateMixin {
  final SuperSearchService _superSearchService = SuperSearchService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  SuperSearchResult? _searchResult;
  SuperSearchAvailableFilters? _availableFilters;
  SuperSearchFilters _currentFilters = const SuperSearchFilters();
  List<String> _suggestions = [];
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _showFilters = false;
  bool _showSuggestions = false;
  String? _error;
  int _currentPage = 1;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Set initial query if provided
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }

    // Load available filters
    _loadAvailableFilters();

    // Setup search listener with debouncing
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.length >= 2) {
      _getSuggestions(query);
    } else {
      setState(() {
        _showSuggestions = false;
        _suggestions.clear();
      });
    }
  }

  void _onFocusChanged() {
    if (_searchFocusNode.hasFocus && _searchController.text.length >= 2) {
      _getSuggestions(_searchController.text.trim());
    } else {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  Future<void> _loadAvailableFilters() async {
    final response = await _superSearchService.getAvailableFilters();
    if (response.isSuccess) {
      setState(() {
        _availableFilters = response.data;
      });
    }
  }

  Future<void> _getSuggestions(String query) async {
    final response = await _superSearchService.getSuggestions(query: query);
    if (response.isSuccess && mounted) {
      setState(() {
        _suggestions = response.data ?? [];
        _showSuggestions = _suggestions.isNotEmpty;
      });
    }
  }

  Future<void> _performSearch(String query, {bool isLoadMore = false}) async {
    if (query.trim().isEmpty) return;

    HapticFeedback.lightImpact();

    setState(() {
      if (isLoadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
        _searchResult = null;
      }
      _showSuggestions = false;
    });

    final response = await _superSearchService.search(
      query: query.trim(),
      filters: _currentFilters,
      page: isLoadMore ? _currentPage + 1 : 1,
      perPage: 20,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;

        if (response.isSuccess) {
          final result = response.data!;
          if (isLoadMore && _searchResult != null) {
            // Append to existing results
            _searchResult = SuperSearchResult(
              events: [..._searchResult!.events, ...result.events],
              total: result.total,
              page: result.page,
              perPage: result.perPage,
              totalPages: result.totalPages,
              hasNext: result.hasNext,
              hasPrev: result.hasPrev,
              suggestions: result.suggestions,
              metadata: result.metadata,
            );
            _currentPage = result.page;
          } else {
            _searchResult = result;
            _currentPage = result.page;
          }
          _error = null;
        } else {
          _error = response.error;
        }
      });
    }
  }

  Future<void> _loadMoreResults() async {
    if (_searchResult?.hasNext == true && !_isLoadingMore) {
      await _performSearch(_searchController.text.trim(), isLoadMore: true);
    }
  }

  void _applyFilters() {
    setState(() {
      _showFilters = false;
    });
    if (_searchController.text.trim().isNotEmpty) {
      _performSearch(_searchController.text.trim());
    }
  }

  void _clearFilters() {
    setState(() {
      _currentFilters = const SuperSearchFilters();
    });
    if (_searchController.text.trim().isNotEmpty) {
      _performSearch(_searchController.text.trim());
    }
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _searchFocusNode.unfocus();
    _performSearch(suggestion);
  }

  void _selectPopularSearch(String searchTerm) {
    final query = SuperSearchService.getPopularSearchQuery(searchTerm);
    _searchController.text = query;
    _performSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                if (_showSuggestions) _buildSuggestions(),
                if (_searchResult == null && !_isLoading) _buildInitialContent(),
                if (_isLoading && _searchResult == null) _buildLoadingIndicator(),
                if (_searchResult != null) _buildSearchResults(),
                if (_error != null) _buildErrorMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MyDscvr Super Search',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Powered by Algolia • Instant Results',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (_searchResult != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.dubaiTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_searchResult!.total} results',
                style: TextStyle(
                  color: AppColors.dubaiTeal,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search events, activities, experiences...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.dubaiTeal,
                  size: 24,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _performSearch,
            ),
          ),
          if (_currentFilters != const SuperSearchFilters())
            Container(
              margin: const EdgeInsets.only(right: 8),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.dubaiTeal,
                shape: BoxShape.circle,
              ),
            ),
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list : Icons.tune,
              color: AppColors.dubaiTeal,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _suggestions.map((suggestion) {
          return ListTile(
            leading: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            title: Text(
              suggestion,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            onTap: () => _selectSuggestion(suggestion),
            dense: true,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInitialContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPopularSearches(),
            const SizedBox(height: 30),
            _buildSearchFeatures(),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Searches',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SuperSearchService.getPopularSearches().map((search) {
            return GestureDetector(
              onTap: () => _selectPopularSearch(search),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.dubaiTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.dubaiTeal.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  search,
                  style: TextStyle(
                    color: AppColors.dubaiTeal,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          Icons.flash_on,
          'Instant Results',
          'Get results in under 100ms with our lightning-fast search',
          AppColors.dubaiTeal,
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          Icons.auto_fix_high,
          'Smart Typo Tolerance',
          'Find what you\'re looking for even with typos or misspellings',
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          Icons.filter_list,
          'Advanced Filtering',
          'Filter by category, area, price, family-friendly options and more',
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          Icons.trending_up,
          'Intelligent Ranking',
          'Results ranked by relevance, popularity, and your preferences',
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Expanded(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.dubaiTeal),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final result = _searchResult!;
    
    return Expanded(
      child: Column(
        children: [
          // Search metadata
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${result.total} results in ${result.metadata.totalProcessingTimeMs}ms',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (result.suggestions.isNotEmpty)
                  Text(
                    'Page ${result.page} of ${result.totalPages}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          
          // Results list
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                    result.hasNext &&
                    !_isLoadingMore) {
                  _loadMoreResults();
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: result.events.length + (result.hasNext ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == result.events.length) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.dubaiTeal),
                        ),
                      ),
                    );
                  }
                  
                  final event = result.events[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: EventCard(
                      event: event,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailsScreen(
                              eventId: event.id,
                              event: event,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Search Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Something went wrong',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_searchController.text.trim().isNotEmpty) {
                  _performSearch(_searchController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dubaiTeal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}