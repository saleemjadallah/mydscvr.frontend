import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/themes/app_typography.dart';
import '../../../core/widgets/glass_morphism.dart';
import '../../../models/event.dart';
import '../../../services/providers/preferences_provider.dart';
import '../../../utils/duration_formatter.dart';

/// Search results list with infinite scroll and beautiful animations
class SearchResultsList extends ConsumerStatefulWidget {
  final List<Event> events;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoading;

  const SearchResultsList({
    super.key,
    required this.events,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoading = false,
  });

  @override
  ConsumerState<SearchResultsList> createState() => _SearchResultsListState();
}

class _SearchResultsListState extends ConsumerState<SearchResultsList> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      if (widget.hasMore && !widget.isLoading && widget.onLoadMore != null) {
        widget.onLoadMore!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkModeProvider);
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Show loading indicator at the end
          if (index == widget.events.length) {
            if (widget.isLoading) {
              return _buildLoadingIndicator();
            } else if (!widget.hasMore) {
              return _buildEndOfResults();
            }
            return const SizedBox.shrink();
          }

          final event = widget.events[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: EnhancedEventCard(
              event: event,
            ),
          );
        },
        childCount: widget.events.length + (widget.hasMore || widget.isLoading ? 1 : 0),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.dubaiGold),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
            .rotate(duration: 1000.ms),
          const SizedBox(width: 16),
          Text(
            'Loading more events...',
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndOfResults() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            LucideIcons.checkCircle,
            color: AppColors.success,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'That\'s all the events!',
            style: AppTypography.h4.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your filters to find more activities',
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.3, duration: 500.ms);
  }
} 