import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../providers/search_provider.dart';
import '../../services/events_service.dart';
import '../../features/search/super_search_screen.dart';

/// Simplified home search widget to test overlay functionality
class SimpleHomeSearchWidget extends ConsumerStatefulWidget {
  const SimpleHomeSearchWidget({super.key});

  @override
  ConsumerState<SimpleHomeSearchWidget> createState() => _SimpleHomeSearchWidgetState();
}

class _SimpleHomeSearchWidgetState extends ConsumerState<SimpleHomeSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _searchKey = GlobalKey();
  bool _showSuggestions = false;
  List<String> _eventTitles = [];
  bool _isLoadingTitles = false;
  final EventsService _eventsService = EventsService();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      final shouldShow = _focusNode.hasFocus && _controller.text.trim().isNotEmpty;
      if (shouldShow != _showSuggestions) {
        setState(() {
          _showSuggestions = shouldShow;
        });
        if (shouldShow) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showOverlay() {
    _removeOverlay();
    
    print('SimpleHomeSearch: Showing overlay');
    
    final RenderBox? renderBox = _searchKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible full-screen barrier to capture clicks outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _removeOverlay();
                _focusNode.unfocus();
                setState(() {
                  _showSuggestions = false;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // The actual suggestions dropdown
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 8,
            width: size.width,
            child: Material(
              color: Colors.transparent,
              elevation: 8,
              child: _buildSuggestionsContainer(),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildSuggestionsContainer() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.22,
        minHeight: 0,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Consumer(
          builder: (context, ref, _) {
            final searchState = ref.watch(searchProvider);
            final suggestions = searchState.suggestions;
            
            // Create list of all items
            final List<Widget> allItems = [];
            
            // Show event titles first if available
            if (_eventTitles.isNotEmpty) {
              allItems.add(_buildSectionHeader('Events'));
              allItems.addAll(_eventTitles.take(5).map((title) => _buildSuggestionItem(title)).toList());
            }
            
            if (suggestions.isNotEmpty) {
              allItems.add(_buildSectionHeader('Suggestions'));
              allItems.addAll(suggestions.take(3).map((s) => _buildSuggestionItem(s.text)).toList());
            }
            
            // Only show popular searches if no event titles or suggestions
            if (_eventTitles.isEmpty && suggestions.isEmpty) {
              allItems.add(_buildSectionHeader('Popular Searches'));
              allItems.addAll([
                _buildSuggestionItem('Dubai Aquarium'),
                _buildSuggestionItem('Desert Safari'),
                _buildSuggestionItem('Beach Activities'),
                _buildSuggestionItem('Family Fun'),
              ]);
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: allItems.length,
              itemBuilder: (context, index) => allItems[index],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      key: _searchKey,
      padding: const EdgeInsets.all(6),
      blur: 20,
      opacity: 0.25,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onSubmitted: _performSearch,
              onChanged: (value) {
                final shouldShow = _focusNode.hasFocus && value.trim().isNotEmpty;
                if (shouldShow != _showSuggestions) {
                  setState(() {
                    _showSuggestions = shouldShow;
                  });
                  if (shouldShow) {
                    _showOverlay();
                  } else {
                    _removeOverlay();
                  }
                }
                // Search for event titles when user types
                if (value.trim().length >= 2) {
                  _searchEventTitles(value.trim());
                  ref.read(searchProvider.notifier).updateQuery(value);
                } else {
                  setState(() {
                    _eventTitles = [];
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Try MyDscvr Super Search - Find events instantly...',
                hintStyle: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                prefixIcon: const Icon(
                  LucideIcons.search,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _performSearch(_controller.text),
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6366F1),
                    const Color(0xFF8B5CF6),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      child: Text(
        title,
        style: GoogleFonts.comfortaa(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSuggestionItem(String text) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          print('SimpleHomeSearch: onTapDown triggered for "$text"');
          
          // Remove overlay first
          _removeOverlay();
          
          // Unfocus to prevent keyboard/scroll issues
          _focusNode.unfocus();
          
          // Update controller text and state
          setState(() {
            _controller.text = text;
            _showSuggestions = false;
          });
          
          // Navigate immediately
          _performSearch(text);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: AppColors.textSecondary.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.search,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    
    // Navigate to MyDscvr Super Search with search query
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuperSearchScreen(
          initialQuery: query.trim(),
        ),
      ),
    );
  }

  Future<void> _searchEventTitles(String query) async {
    if (query.length < 2) {
      setState(() {
        _eventTitles = [];
      });
      return;
    }

    setState(() {
      _isLoadingTitles = true;
    });

    try {
      final response = await _eventsService.searchEventTitles(
        query: query,
        limit: 8,
      );

      if (response.isSuccess && mounted) {
        setState(() {
          _eventTitles = response.data ?? [];
          _isLoadingTitles = false;
        });
      } else {
        setState(() {
          _eventTitles = [];
          _isLoadingTitles = false;
        });
      }
    } catch (e) {
      print('Error searching event titles: $e');
      if (mounted) {
        setState(() {
          _eventTitles = [];
          _isLoadingTitles = false;
        });
      }
    }
  }
} 