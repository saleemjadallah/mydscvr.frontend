import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../services/trending_events_service.dart';
import '../../services/events_service.dart';

/// Smart Trending Section Widget
/// Displays algorithmically calculated trending events that refresh weekly
class SmartTrendingSection extends StatefulWidget {
  const SmartTrendingSection({super.key});

  @override
  State<SmartTrendingSection> createState() => _SmartTrendingSectionState();
}

class _SmartTrendingSectionState extends State<SmartTrendingSection> {
  late TrendingEventsService _trendingService;
  List<TrendingEventData> _trendingEvents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _trendingService = TrendingEventsService(EventsService());
    _loadTrendingEvents();
  }

  Future<void> _loadTrendingEvents() async {
    try {
      final response = await _trendingService.getSmartTrendingEvents(limit: 3);
      
      if (mounted) {
        setState(() {
          if (response.isSuccess) {
            _trendingEvents = response.data ?? [];
            _errorMessage = null;
          } else {
            _errorMessage = response.error;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load trending events: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Text(
                'Trending Now 🔥',
                style: GoogleFonts.comfortaa(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_trendingService.shouldRefreshTrendingData())
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.dubaiGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.dubaiGold.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.refreshCw,
                        size: 12,
                        color: AppColors.dubaiGold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Updated Today',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dubaiGold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Loading State
          if (_isLoading)
            _buildLoadingState()
          
          // Error State
          else if (_errorMessage != null)
            _buildErrorState()
          
          // Success State
          else if (_trendingEvents.isNotEmpty)
            ..._trendingEvents.asMap().entries.map((entry) {
              final index = entry.key;
              final trendingData = entry.value;
              return _buildTrendingEventItem(trendingData, index);
            }).toList()
          
          // Empty State
          else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(3, (index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.dubaiGold),
            strokeWidth: 2,
          ),
        ),
      )),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dubaiCoral.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dubaiCoral.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.alertTriangle,
            color: AppColors.dubaiCoral,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load trending events',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _errorMessage ?? 'Unknown error',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loadTrendingEvents,
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dubaiCoral,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.calendar,
            color: AppColors.textSecondary,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'No trending events right now',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Check back soon for the latest trending events!',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingEventItem(TrendingEventData trendingData, int index) {
    final event = trendingData.event;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dubaiGold.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          context.go('/event/${event.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Trending Rank Badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.dubaiGold,
                      AppColors.dubaiGold.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Event Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Row(
                      children: [
                        Icon(
                          LucideIcons.users,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatInterestCount(trendingData.interestedCount)} interested',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          LucideIcons.clock,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trendingData.timeAgo,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Trending Icon
              Icon(
                LucideIcons.trendingUp,
                color: AppColors.dubaiGold,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 100))
     .slideX(begin: 0.3, curve: Curves.easeOut)
     .fadeIn();
  }

  String _formatInterestCount(int count) {
    if (count >= 1000) {
      final k = count / 1000;
      return '${k.toStringAsFixed(k == k.roundToDouble() ? 0 : 1)}k';
    }
    return count.toString();
  }
} 