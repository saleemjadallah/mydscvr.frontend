import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_morphism.dart';

class EventReviewsWidget extends StatefulWidget {
  final double rating;
  final int reviewCount;
  final String eventId;

  const EventReviewsWidget({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.eventId,
  });

  @override
  State<EventReviewsWidget> createState() => _EventReviewsWidgetState();
}

class _EventReviewsWidgetState extends State<EventReviewsWidget> {
  final List<ReviewItem> _sampleReviews = [
    ReviewItem(
      id: '1',
      userName: 'Sarah Ahmed',
      userInitials: 'SA',
      rating: 5.0,
      comment: 'Amazing experience! The kids loved every minute of it. Highly recommended for families.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      isVerified: true,
    ),
    ReviewItem(
      id: '2',
      userName: 'Mohammed Ali',
      userInitials: 'MA',
      rating: 4.5,
      comment: 'Great event with good organization. The venue was perfect and staff were very helpful.',
      date: DateTime.now().subtract(const Duration(days: 5)),
      isVerified: true,
    ),
    ReviewItem(
      id: '3',
      userName: 'Lisa Johnson',
      userInitials: 'LJ',
      rating: 4.0,
      comment: 'Good value for money. The activities were engaging and suitable for all ages.',
      date: DateTime.now().subtract(const Duration(days: 8)),
      isVerified: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      blur: 4,
      opacity: 0.03,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.dubaiGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.star,
                  size: 20,
                  color: AppColors.dubaiGold,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Reviews & Ratings',
                style: GoogleFonts.comfortaa(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Rating summary
          _buildRatingSummary(),
          
          const SizedBox(height: 20),
          
          // Reviews list
          if (widget.reviewCount > 0) ...[
            _buildReviewsList(),
            const SizedBox(height: 16),
            
            // View all reviews button
            Center(
              child: OutlinedButton(
                onPressed: _viewAllReviews,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.dubaiTeal,
                  side: const BorderSide(color: AppColors.dubaiTeal),
                ),
                child: Text(
                  'View All ${widget.reviewCount} Reviews',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else ...[
            _buildNoReviews(),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Row(
      children: [
        // Overall rating
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  widget.rating.toStringAsFixed(1),
                  style: GoogleFonts.comfortaa(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/ 5.0',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            
            // Star rating
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < widget.rating.floor()
                      ? LucideIcons.star
                      : index < widget.rating
                          ? LucideIcons.star // Could be half star
                          : LucideIcons.star,
                  size: 16,
                  color: index < widget.rating
                      ? AppColors.dubaiGold
                      : Colors.grey.withOpacity(0.3),
                );
              }),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              '${widget.reviewCount} ${widget.reviewCount == 1 ? 'review' : 'reviews'}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        
        const SizedBox(width: 24),
        
        // Rating breakdown
        Expanded(
          child: _buildRatingBreakdown(),
        ),
      ],
    );
  }

  Widget _buildRatingBreakdown() {
    // Mock rating distribution
    final ratingDistribution = {
      5: 0.6, // 60%
      4: 0.25, // 25%
      3: 0.1, // 10%
      2: 0.03, // 3%
      1: 0.02, // 2%
    };

    return Column(
      children: ratingDistribution.entries.map((entry) {
        final stars = entry.key;
        final percentage = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Text(
                '$stars',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                LucideIcons.star,
                size: 12,
                color: AppColors.dubaiGold,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.dubaiGold),
                  minHeight: 4,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text(
                  '${(percentage * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewsList() {
    final displayReviews = _sampleReviews.take(3).toList();
    
    return Column(
      children: [
        const Divider(color: Colors.grey, height: 1),
        const SizedBox(height: 16),
        
        ...displayReviews.map((review) => _buildReviewItem(review)).toList(),
      ],
    );
  }

  Widget _buildReviewItem(ReviewItem review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and rating
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.dubaiTeal.withOpacity(0.1),
                child: Text(
                  review.userInitials,
                  style: GoogleFonts.comfortaa(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dubaiTeal,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: GoogleFonts.comfortaa(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (review.isVerified) ...[
                          const SizedBox(width: 6),
                          Icon(
                            LucideIcons.badgeCheck,
                            size: 14,
                            color: AppColors.dubaiTeal,
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            LucideIcons.star,
                            size: 12,
                            color: index < review.rating
                                ? AppColors.dubaiGold
                                : Colors.grey.withOpacity(0.3),
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review.date),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Review comment
          Text(
            review.comment,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoReviews() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.messageSquare,
            size: 48,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: GoogleFonts.comfortaa(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your experience!',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _writeReview,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.dubaiTeal,
              side: const BorderSide(color: AppColors.dubaiTeal),
            ),
            child: Text(
              'Write a Review',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
  }

  void _viewAllReviews() {
    // TODO: Navigate to full reviews screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Full reviews screen coming soon!'),
        backgroundColor: AppColors.dubaiTeal,
      ),
    );
  }

  void _writeReview() {
    // TODO: Navigate to write review screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Write review feature coming soon!'),
        backgroundColor: AppColors.dubaiTeal,
      ),
    );
  }
}

class ReviewItem {
  final String id;
  final String userName;
  final String userInitials;
  final double rating;
  final String comment;
  final DateTime date;
  final bool isVerified;

  const ReviewItem({
    required this.id,
    required this.userName,
    required this.userInitials,
    required this.rating,
    required this.comment,
    required this.date,
    this.isVerified = false,
  });
} 