import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/ai_search_provider.dart';
import '../../models/ai_search.dart';
import '../../widgets/events/event_card_simple.dart';

class AISearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  
  const AISearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<AISearchScreen> createState() => _AISearchScreenState();
}

class _AISearchScreenState extends ConsumerState<AISearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Set initial query if provided
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      // Perform search automatically after a brief delay
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(aiSearchProvider);
    final popularSearches = ref.read(aiSearchProvider.notifier).getPopularSearches();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Handle browser back button same as UI back button
          if (GoRouter.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            _buildSearchHeader(),
            _buildSearchBar(),
            _buildSearchSuggestions(popularSearches),
            Expanded(
              child: searchState.when(
                data: (response) => response != null 
                    ? _buildSearchResults(response)
                    : _buildEmptyState(),
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.dubaiTeal,
            AppColors.dubaiTeal.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () {
                  // Use GoRouter's back navigation which handles browser history
                  if (GoRouter.of(context).canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'AI Search',
                style: GoogleFonts.comfortaa(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Powered by OpenAI for intelligent event discovery!',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        maxLines: 1,
        style: GoogleFonts.inter(
          fontSize: 16,
          color: Colors.grey[800],
        ),
        decoration: InputDecoration(
          hintText: 'e.g., "Indoor activities for my 4-year-old on a rainy weekend under AED 100"',
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[500],
            height: 1.4,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          suffixIcon: _isSearching
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.dubaiTeal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: _performSearch,
                ),
        ),
        onSubmitted: (_) => _performSearch(),
      ),
    );
  }

  Widget _buildSearchSuggestions(List<String> suggestions) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                _searchController.text = suggestion;
                _performSearch();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.dubaiTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.dubaiTeal.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  suggestion,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.dubaiTeal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(AISearchResponse response) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (response.aiResponse.isNotEmpty) ...[
            _buildAIResponse(response.aiResponse),
            const SizedBox(height: 24),
          ],
          
          if (response.results.isNotEmpty) ...[
            Text(
              'Found ${response.results.length} results',
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            
            ...response.results.map((rankedEvent) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildRankedEventCard(rankedEvent),
              ),
            ),
          ],
          
          if (response.suggestions.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildFollowUpSuggestions(response.suggestions),
          ],
        ],
      ),
    );
  }

  Widget _buildAIResponse(String aiResponse) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.dubaiTeal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dubaiTeal.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.dubaiTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Assistant',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dubaiTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            aiResponse,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankedEventCard(RankedEvent rankedEvent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          EventCardSimple(event: rankedEvent.event),
          if (rankedEvent.reasoning != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.dubaiGold.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getScoreColor(rankedEvent.score),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${rankedEvent.score}% match',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Why this matches:',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dubaiGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rankedEvent.reasoning!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFollowUpSuggestions(List<String> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You might also like',
          style: GoogleFonts.comfortaa(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((suggestion) =>
            GestureDetector(
              onTap: () {
                _searchController.text = suggestion;
                _performSearch();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.dubaiPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.dubaiPurple.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  suggestion,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.dubaiPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Search for Dubai family activities',
            style: GoogleFonts.comfortaa(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try asking specific questions like:\n"What can I do with a 5-year-old this weekend?"',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[500],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.dubaiTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.dubaiTeal),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'AI is analyzing your request...',
            style: GoogleFonts.comfortaa(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Finding the perfect Dubai family activities',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: GoogleFonts.comfortaa(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again or use the regular search',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _performSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dubaiTeal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Try Again',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 85) return AppColors.dubaiTeal;
    if (score >= 70) return AppColors.dubaiGold;
    return AppColors.dubaiCoral;
  }

  void _performSearch() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() => _isSearching = true);
    _searchFocus.unfocus();

    try {
      await ref.read(aiSearchProvider.notifier).performSearch(_searchController.text.trim());
    } finally {
      setState(() => _isSearching = false);
    }
  }
}