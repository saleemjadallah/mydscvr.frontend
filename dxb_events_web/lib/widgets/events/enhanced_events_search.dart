import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../providers/search_provider.dart';
import '../../services/events_service.dart';

/// Enhanced search widget for events page with live suggestions and autocomplete
class EnhancedEventsSearch extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearchChanged;
  final String hintText;

  const EnhancedEventsSearch({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    this.hintText = 'Search events, categories, locations...',
  });

  @override
  ConsumerState<EnhancedEventsSearch> createState() => _EnhancedEventsSearchState();
}

class _EnhancedEventsSearchState extends ConsumerState<EnhancedEventsSearch> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _searchKey = GlobalKey();
  bool _showSuggestions = false;
  List<String> _eventTitles = [];
  List<String> _locationSuggestions = [];
  List<String> _categorySuggestions = [];
  bool _isLoadingTitles = false;
  final EventsService _eventsService = EventsService();
  OverlayEntry? _overlayEntry;

  // Popular searches and suggestions
  static const List<String> _popularSearches = [
    'Dubai Aquarium',
    'Desert Safari',
    'Beach Activities',
    'Family Fun',
    'Indoor Activities',
    'Outdoor Adventures',
    'Food & Dining',
    'Cultural Events',
  ];

  static const List<String> _popularLocations = [
    'Dubai Marina',
    'Downtown Dubai',
    'JBR',
    'Palm Jumeirah',
    'Business Bay',
    'Jumeirah',
    'DIFC',
    'Deira',
  ];

  static const List<String> _popularCategories = [
    'Kids & Family',
    'Outdoor Activities',
    'Indoor Activities',
    'Food & Dining',
    'Cultural',
    'Water Sports',
    'Music & Concerts',
    'Sports & Fitness',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      final shouldShow = _focusNode.hasFocus && widget.controller.text.trim().isNotEmpty;
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
    super.dispose();
  }

  void _showOverlay() {
    _removeOverlay();
    
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
        maxHeight: MediaQuery.of(context).size.height * 0.4,
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show event titles first if available
              if (_eventTitles.isNotEmpty) ...[
                _buildSectionHeader('Events', LucideIcons.calendar),
                ..._eventTitles.take(4).map((title) => _buildSuggestionItem(title, LucideIcons.calendar)),
              ],
              
              // Location suggestions based on search
              if (_locationSuggestions.isNotEmpty) ...[
                _buildSectionHeader('Locations', LucideIcons.mapPin),
                ..._locationSuggestions.take(3).map((location) => _buildSuggestionItem(location, LucideIcons.mapPin)),
              ],
              
              // Category suggestions based on search
              if (_categorySuggestions.isNotEmpty) ...[
                _buildSectionHeader('Categories', LucideIcons.tag),
                ..._categorySuggestions.take(3).map((category) => _buildSuggestionItem(category, LucideIcons.tag)),
              ],
              
              // Popular searches if no specific results
              if (_eventTitles.isEmpty && _locationSuggestions.isEmpty && _categorySuggestions.isEmpty) ...[
                _buildSectionHeader('Popular Searches', LucideIcons.trendingUp),
                ..._popularSearches.take(4).map((search) => _buildSuggestionItem(search, LucideIcons.search)),
              ],
              
              // Quick actions
              _buildSectionHeader('Quick Actions', LucideIcons.zap),
              _buildActionItem('Clear all filters', LucideIcons.x, () {
                widget.controller.clear();
                widget.onSearchChanged('');
                _removeOverlay();
                _focusNode.unfocus();
              }),
              _buildActionItem('Show all events', LucideIcons.list, () {
                widget.controller.clear();
                widget.onSearchChanged('');
                _removeOverlay();
                _focusNode.unfocus();
              }),
            ],
          ),
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
              controller: widget.controller,
              focusNode: _focusNode,
              onSubmitted: (value) {
                widget.onSearchChanged(value);
                _removeOverlay();
                _focusNode.unfocus();
              },
              onChanged: (value) {
                widget.onSearchChanged(value);
                
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
                
                // Search for suggestions when user types
                if (value.trim().length >= 2) {
                  _searchSuggestions(value.trim());
                  ref.read(searchProvider.notifier).updateQuery(value);
                } else {
                  setState(() {
                    _eventTitles = [];
                    _locationSuggestions = [];
                    _categorySuggestions = [];
                  });
                }
              },
              decoration: InputDecoration(
                hintText: widget.hintText,
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
          if (widget.controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                widget.controller.clear();
                widget.onSearchChanged('');
                setState(() {
                  _eventTitles = [];
                  _locationSuggestions = [];
                  _categorySuggestions = [];
                });
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  LucideIcons.x,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.05),
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
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.comfortaa(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String text, IconData icon) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _removeOverlay();
          _focusNode.unfocus();
          
          setState(() {
            widget.controller.text = text;
            _showSuggestions = false;
          });
          
          widget.onSearchChanged(text);
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
                icon,
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

  Widget _buildActionItem(String text, IconData icon, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
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
                icon,
                size: 14,
                color: AppColors.dubaiTeal,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.dubaiTeal,
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

  Future<void> _searchSuggestions(String query) async {
    if (query.length < 2) {
      setState(() {
        _eventTitles = [];
        _locationSuggestions = [];
        _categorySuggestions = [];
      });
      return;
    }

    setState(() {
      _isLoadingTitles = true;
    });

    try {
      // Search for event titles
      final response = await _eventsService.searchEventTitles(
        query: query,
        limit: 6,
      );

      if (response.isSuccess && mounted) {
        setState(() {
          _eventTitles = response.data ?? [];
        });
      }

      // Generate location suggestions
      final locationMatches = _popularLocations
          .where((location) => location.toLowerCase().contains(query.toLowerCase()))
          .toList();

      // Generate category suggestions  
      final categoryMatches = _popularCategories
          .where((category) => category.toLowerCase().contains(query.toLowerCase()))
          .toList();

      if (mounted) {
        setState(() {
          _locationSuggestions = locationMatches;
          _categorySuggestions = categoryMatches;
          _isLoadingTitles = false;
        });
      }
    } catch (e) {
      print('Error searching suggestions: $e');
      if (mounted) {
        setState(() {
          _eventTitles = [];
          _locationSuggestions = [];
          _categorySuggestions = [];
          _isLoadingTitles = false;
        });
      }
    }
  }
}