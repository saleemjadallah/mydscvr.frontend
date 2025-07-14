import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../providers/search_provider.dart';
import '../../models/search.dart';

/// Home page search widget with suggestions overlay
class HomeSearchWidget extends ConsumerStatefulWidget {
  const HomeSearchWidget({super.key});

  @override
  ConsumerState<HomeSearchWidget> createState() => _HomeSearchWidgetState();
}

class _HomeSearchWidgetState extends ConsumerState<HomeSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _searchKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    
    // Initialize search provider with default suggestions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchProvider.notifier).updateQuery('');
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
    
    print('HomeSearchWidget: Focus changed to $_hasFocus');
    
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      // Delay removing overlay to allow for tap events
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    }
  }

  void _showOverlay() {
    _removeOverlay();
    
    print('HomeSearchWidget: Showing overlay');
    
    final RenderBox renderBox = _searchKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible full-screen barrier to capture clicks
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _removeOverlay();
                _focusNode.unfocus();
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
              child: _buildSuggestionsOverlay(),
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

  Widget _buildSuggestionsOverlay() {
    print('HomeSearchWidget: Building suggestions overlay, hasFocus: $_hasFocus');
    
    return Consumer(
      builder: (context, ref, _) {
        final searchState = ref.watch(searchProvider);
        final suggestions = searchState.suggestions;
        
        print('HomeSearchWidget: Suggestions count: ${suggestions.length}, Query: "${searchState.query}"');

        // Show overlay when focused, regardless of query or suggestions
        if (!_hasFocus) {
          return const SizedBox.shrink();
        }

        return Container(
          constraints: const BoxConstraints(maxHeight: 300),
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
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (suggestions.isNotEmpty) ...[
                    _buildSectionHeader('Suggestions', LucideIcons.lightbulb),
                    ...suggestions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final suggestion = entry.value;
                      return _buildSuggestionItem(suggestion, index);
                    }).toList(),
                  ],
                  
                  // Always show popular searches when focused
                  _buildSectionHeader('Popular Searches', LucideIcons.trendingUp),
                  _buildPopularItem('Dubai Aquarium', 0),
                  _buildPopularItem('Desert Safari', 1),
                  _buildPopularItem('Beach Activities', 2),
                  _buildPopularItem('Family Fun', 3),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.dubaiTeal),
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

  Widget _buildSuggestionItem(SearchSuggestion suggestion, int index) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          // Handle on tap down to ensure immediate response
          print('HomeSearchWidget: Tapped suggestion "${suggestion.text}"');
          
          // Update state immediately
          setState(() {
            _controller.text = suggestion.text;
          });
          
          // Remove overlay and unfocus
          _removeOverlay();
          _focusNode.unfocus();
          
          // Navigate after a brief delay to ensure UI updates
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToSearch(suggestion.text);
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.dubaiTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForType(suggestion.type),
                size: 14,
                color: AppColors.dubaiTeal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion.text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              LucideIcons.arrowUpLeft,
              size: 14,
              color: AppColors.textSecondary,
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularItem(String text, int index) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          // Handle on tap down to ensure immediate response
          print('HomeSearchWidget: Tapped popular item "$text"');
          
          // Update state immediately
          setState(() {
            _controller.text = text;
          });
          
          // Remove overlay and unfocus
          _removeOverlay();
          _focusNode.unfocus();
          
          // Navigate after a brief delay to ensure UI updates
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToSearch(text);
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Row(
          children: [
            Icon(
              LucideIcons.trendingUp,
              size: 14,
              color: AppColors.dubaiGold,
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
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(SearchSuggestionType type) {
    switch (type) {
      case SearchSuggestionType.category:
        return LucideIcons.tag;
      case SearchSuggestionType.area:
        return LucideIcons.mapPin;
      case SearchSuggestionType.venue:
        return LucideIcons.building;
      case SearchSuggestionType.event:
        return LucideIcons.calendar;
      case SearchSuggestionType.activity:
        return LucideIcons.activity;
      case SearchSuggestionType.general:
      default:
        return LucideIcons.search;
    }
  }

  void _navigateToSearch(String query) {
    _removeOverlay();
    context.go('/super-search?query=${Uri.encodeComponent(query)}');
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      key: _searchKey,
      padding: const EdgeInsets.all(4),
      blur: 15,
      opacity: 0.2,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: (value) {
                ref.read(searchProvider.notifier).updateQuery(value);
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _navigateToSearch(value);
                }
              },
              decoration: InputDecoration(
                hintText: 'Search family events...',
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
              autocorrect: false,
              autofillHints: const [AutofillHints.name],
              keyboardType: TextInputType.text,
            ),
          ),
          GestureDetector(
            onTap: () {
              _removeOverlay();
              context.go('/super-search');
            },
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppColors.oceanGradient,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                LucideIcons.sliders,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 