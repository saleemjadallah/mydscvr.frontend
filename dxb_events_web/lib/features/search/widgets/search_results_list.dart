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
            child: SearchEventCard(
              event: event,
              index: index,
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

/// Beautiful event card for search results
class SearchEventCard extends ConsumerWidget {
  final Event event;
  final int index;

  const SearchEventCard({
    super.key,
    required this.event,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    final isEventFavorited = ref.watch(isEventFavoritedProvider(event.id));
    
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to event detail
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${event.title}...'),
            backgroundColor: AppColors.dubaiTeal,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: GlassMorphism(
          blur: 20,
          opacity: 0.95,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode 
                    ? AppColors.textSecondaryLight.withOpacity(0.1)
                    : AppColors.textSecondaryDark.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Image
                    _buildEventImage(),
                    
                    const SizedBox(width: 16),
                    
                    // Event Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Favorite
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: AppTypography.h4.copyWith(
                                    color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildFavoriteButton(ref, isEventFavorited),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Venue and Area
                          Row(
                            children: [
                              Icon(
                                LucideIcons.mapPin,
                                size: 16,
                                color: AppColors.dubaiTeal,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${event.venue.name} • ${event.venue.area}',
                                  style: AppTypography.body2.copyWith(
                                    color: AppColors.dubaiTeal,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 4),
                          
                          // Date and Time
                          Row(
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 16,
                                color: AppColors.dubaiGold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatEventDate(event.startDate, event.endDate),
                                style: AppTypography.body2.copyWith(
                                  color: AppColors.dubaiGold,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 4),
                          
                          // Duration and End Date
                          Row(
                            children: [
                              // Duration
                              Icon(
                                LucideIcons.clock,
                                size: 16,
                                color: AppColors.dubaiTeal,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DurationFormatter.formatForCard(event.startDate, event.endDate),
                                style: AppTypography.body2.copyWith(
                                  color: AppColors.dubaiTeal,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // End Date (if different from start)
                              if (event.endDate != null && _shouldShowEndDate(event.startDate, event.endDate!)) ...[
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  width: 1,
                                  height: 12,
                                  color: AppColors.textSecondaryDark.withOpacity(0.3),
                                ),
                                Icon(
                                  LucideIcons.calendarDays,
                                  size: 16,
                                  color: AppColors.dubaiPurple,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Ends ${_formatEndDate(event.endDate!)}',
                                  style: AppTypography.body2.copyWith(
                                    color: AppColors.dubaiPurple,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Description
                if (event.aiSummary.isNotEmpty) ...[
                  Text(
                    event.aiSummary,
                    style: AppTypography.body2.copyWith(
                      color: isDarkMode ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Tags and Price
                Row(
                  children: [
                    // Categories
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: event.categories.take(3).map((category) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(category).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getCategoryColor(category).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              category,
                              style: AppTypography.caption.copyWith(
                                color: _getCategoryColor(category),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    // Price
                    _buildPriceTag(),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Family Suitability and Actions
                Row(
                  children: [
                    // Age Range
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.dubaiPurple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.users,
                            size: 12,
                            color: AppColors.dubaiPurple,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${event.familySuitability.ageMin}-${event.familySuitability.ageMax} years',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.dubaiPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Family Friendly Badge
                    if (event.familySuitability.familyFriendly) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.heart,
                              size: 12,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Family Friendly',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const Spacer(),
                    
                    // Action Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Share Button
                        IconButton(
                          onPressed: () => _shareEvent(event, context),
                          icon: Icon(
                            LucideIcons.share2,
                            size: 20,
                            color: AppColors.textSecondaryDark,
                          ),
                          tooltip: 'Share event',
                        ),
                        
                        // Directions Button
                        IconButton(
                          onPressed: () {
                            // TODO: Implement directions
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Opening directions...'),
                                backgroundColor: AppColors.dubaiTeal,
                              ),
                            );
                          },
                          icon: Icon(
                            LucideIcons.navigation,
                            size: 20,
                            color: AppColors.dubaiTeal,
                          ),
                          tooltip: 'Get directions',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .slideY(
        duration: Duration(milliseconds: 300 + (index * 50)),
        begin: 0.3,
      )
      .fade(
        duration: Duration(milliseconds: 300 + (index * 50)),
      );
  }

  Widget _buildEventImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: AppColors.sunsetGradient,
        ),
        child: event.imageUrls.isNotEmpty
            ? Image.network(
                event.imageUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.sunsetGradient,
      ),
      child: const Icon(
        LucideIcons.calendar,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildFavoriteButton(WidgetRef ref, bool isFavorited) {
    return GestureDetector(
      onTap: () async {
        try {
          await ref.read(favoritesProvider.notifier).toggleFavorite(event.id);
        } catch (e) {
          // Show error message for authentication failure
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      LucideIcons.alertCircle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.toString().replaceAll('Exception: ', ''),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isFavorited 
              ? AppColors.dubaiCoral.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isFavorited ? LucideIcons.heart : LucideIcons.heart,
          size: 20,
          color: isFavorited ? AppColors.dubaiCoral : AppColors.textSecondaryDark,
        ),
      ),
    ).animate(target: isFavorited ? 1 : 0)
      .scale(duration: 200.ms)
      .then()
      .shake(duration: 300.ms);
  }

  Widget _buildPriceTag() {
    final minPrice = event.pricing.minPrice;
    final maxPrice = event.pricing.maxPrice;
    final currency = event.pricing.currency;
    
    String priceText;
    Color priceColor;
    
    if (minPrice == 0 && maxPrice == 0) {
      priceText = 'FREE';
      priceColor = AppColors.success;
    } else if (minPrice == maxPrice) {
      priceText = '$minPrice $currency';
      priceColor = AppColors.dubaiGold;
    } else {
      priceText = '$minPrice-$maxPrice $currency';
      priceColor = AppColors.dubaiGold;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: priceColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: priceColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        priceText,
        style: AppTypography.body2.copyWith(
          color: priceColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'arts & crafts':
      case 'art':
        return AppColors.dubaiPurple;
      case 'sports':
      case 'fitness':
        return AppColors.dubaiTeal;
      case 'music':
      case 'entertainment':
        return AppColors.dubaiCoral;
      case 'educational':
      case 'learning':
        return AppColors.dubaiGold;
      case 'food':
      case 'dining':
        return AppColors.success;
      default:
        return AppColors.dubaiGold;
    }
  }

  String _formatEventDate(DateTime startDate, DateTime? endDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(startDate.year, startDate.month, startDate.day);
    
    String dateText;
    if (eventDay == today) {
      dateText = 'Today';
    } else if (eventDay == today.add(const Duration(days: 1))) {
      dateText = 'Tomorrow';
    } else if (eventDay.isBefore(today.add(const Duration(days: 7)))) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      dateText = weekdays[startDate.weekday - 1];
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      dateText = '${startDate.day} ${months[startDate.month - 1]}';
    }
    
    // Add time if it's not an all-day event
    final startTime = _formatTime(startDate);
    return '$dateText at $startTime';
  }
  
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }
  
  bool _shouldShowEndDate(DateTime startDate, DateTime endDate) {
    // Show end date if the event spans multiple days
    final startDay = DateTime(startDate.year, startDate.month, startDate.day);
    final endDay = DateTime(endDate.year, endDate.month, endDate.day);
    return !startDay.isAtSameMomentAs(endDay);
  }
  
  String _formatEndDate(DateTime endDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDay = DateTime(endDate.year, endDate.month, endDate.day);
    
    if (endDay == today) {
      return 'today';
    } else if (endDay == today.add(const Duration(days: 1))) {
      return 'tomorrow';
    } else if (endDay.isBefore(today.add(const Duration(days: 7)))) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[endDate.weekday - 1];
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${endDate.day} ${months[endDate.month - 1]}';
    }
  }

  void _shareEvent(Event event, BuildContext context) {
    try {
      final dateText = _formatEventDate(event.startDate, event.endDate);
      Share.share(
        'Check out this amazing event: ${event.title}\n\n'
        '📅 $dateText\n'
        '📍 ${event.venue?.name ?? 'Dubai'}, ${event.venue?.area ?? 'UAE'}\n\n'
        'Discover more family activities on MyDscvr!',
        subject: event.title,
      );
    } catch (e) {
      // Fallback for web or unsupported platforms
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sharing not supported on this platform'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
} 