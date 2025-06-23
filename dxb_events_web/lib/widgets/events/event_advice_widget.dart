import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../models/advice_models.dart';
import '../../services/api/advice_api_service.dart';

class EventAdviceWidget extends StatefulWidget {
  final String eventId;
  final List<EventAdvice>? adviceList;
  final AdviceStats? stats;
  final VoidCallback? onAddAdvice;
  final VoidCallback? onAdviceUpdated;

  const EventAdviceWidget({
    super.key,
    required this.eventId,
    this.adviceList,
    this.stats,
    this.onAddAdvice,
    this.onAdviceUpdated,
  });

  @override
  State<EventAdviceWidget> createState() => _EventAdviceWidgetState();
}

class _EventAdviceWidgetState extends State<EventAdviceWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  AdviceCategory? _selectedCategory;
  AdviceType? _selectedType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      blur: 8,
      opacity: 0.05,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatsSection(),
          const SizedBox(height: 24),
          _buildTabBar(),
          const SizedBox(height: 16),
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.dubaiGold.withOpacity(0.2),
                AppColors.dubaiTeal.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            LucideIcons.lightbulb,
            size: 24,
            color: AppColors.dubaiGold,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Community Advice',
                style: GoogleFonts.comfortaa(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Tips from people who know this type of event',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.oceanGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.dubaiTeal.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onAddAdvice,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.plus,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Share Advice',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3);
  }

  Widget _buildStatsSection() {
    final stats = widget.stats;
    if (stats == null || stats.totalAdvice == 0) {
      return _buildNoAdviceState();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.dubaiPurple.withOpacity(0.1),
            AppColors.dubaiCoral.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dubaiPurple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildStatItem(
            icon: LucideIcons.messageSquare,
            value: stats.totalAdvice.toString(),
            label: 'Advice Tips',
            color: AppColors.dubaiTeal,
          ),
          _buildStatDivider(),
          _buildStatItem(
            icon: LucideIcons.thumbsUp,
            value: stats.averageHelpfulness.toStringAsFixed(1),
            label: 'Helpfulness',
            color: AppColors.dubaiGold,
          ),
          _buildStatDivider(),
          _buildStatItem(
            icon: LucideIcons.checkCircle,
            value: stats.verifiedAdviceCount.toString(),
            label: 'Verified',
            color: AppColors.dubaiPurple,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideY(begin: 0.3);
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.comfortaa(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.dubaiGold.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildNoAdviceState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.dubaiTeal.withOpacity(0.05),
            AppColors.dubaiGold.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.dubaiTeal.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.sunsetGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              LucideIcons.lightbulb,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Be the first to share advice!',
            style: GoogleFonts.comfortaa(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help other families by sharing your experience with similar events or local knowledge about this venue.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.oceanGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dubaiTeal.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onAddAdvice,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.plus,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Share Your Advice',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 1000.ms, delay: 400.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.oceanGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        tabs: const [
          Tab(text: 'All Advice'),
          Tab(text: 'By Category'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 400,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildAdviceList(),
          _buildCategoryView(),
        ],
      ),
    );
  }

  Widget _buildAdviceList() {
    final advice = widget.adviceList ?? [];
    
    if (advice.isEmpty) {
      return const Center(
        child: Text('No advice available yet'),
      );
    }

    return ListView.builder(
      itemCount: advice.length,
      itemBuilder: (context, index) {
        final item = advice[index];
        return _buildAdviceCard(item, index);
      },
    );
  }

  Widget _buildAdviceCard(EventAdvice advice, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16, top: index == 0 ? 8 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: advice.isFeatured 
              ? AppColors.dubaiGold.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: advice.isFeatured ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: advice.isFeatured
                ? AppColors.dubaiGold.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            blurRadius: advice.isFeatured ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAdviceHeader(advice),
            const SizedBox(height: 12),
            _buildAdviceContent(advice),
            const SizedBox(height: 16),
            _buildAdviceFooter(advice),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100))
        .slideY(begin: 0.3);
  }

  Widget _buildAdviceHeader(EventAdvice advice) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: _getCategoryColor(advice.category),
          child: Text(
            advice.userName.isNotEmpty ? advice.userName[0].toUpperCase() : '?',
            style: GoogleFonts.comfortaa(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
                    advice.userName,
                    style: GoogleFonts.comfortaa(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (advice.isVerified) ...[
                    const SizedBox(width: 6),
                    Icon(
                      LucideIcons.badgeCheck,
                      size: 16,
                      color: AppColors.dubaiTeal,
                    ),
                  ],
                  if (advice.isFeatured) ...[
                    const SizedBox(width: 6),
                    Icon(
                      LucideIcons.star,
                      size: 16,
                      color: AppColors.dubaiGold,
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  _buildCategoryChip(advice.category),
                  const SizedBox(width: 8),
                  _buildTypeChip(advice.adviceType),
                ],
              ),
            ],
          ),
        ),
        _buildHelpfulnessRating(advice),
      ],
    );
  }

  Widget _buildAdviceContent(EventAdvice advice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          advice.title,
          style: GoogleFonts.comfortaa(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          advice.content,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAdviceFooter(EventAdvice advice) {
    return Row(
      children: [
        if (advice.tags.isNotEmpty) ...[
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: advice.tags.take(3).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.dubaiTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.dubaiTeal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        Row(
          children: [
            IconButton(
              onPressed: () => _markHelpful(advice),
              icon: Icon(
                LucideIcons.thumbsUp,
                size: 18,
                color: AppColors.dubaiTeal,
              ),
            ),
            Text(
              advice.helpfulnessVotes.toString(),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(AdviceCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getCategoryColor(category).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        AdviceDisplayHelper.getCategoryDisplayName(category),
        style: GoogleFonts.inter(
          fontSize: 10,
          color: _getCategoryColor(category),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTypeChip(AdviceType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.dubaiPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        AdviceDisplayHelper.getTypeDisplayName(type),
        style: GoogleFonts.inter(
          fontSize: 10,
          color: AppColors.dubaiPurple,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHelpfulnessRating(EventAdvice advice) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.dubaiGold.withOpacity(0.1),
            AppColors.dubaiGold.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.thumbsUp,
            size: 14,
            color: AppColors.dubaiGold,
          ),
          const SizedBox(width: 4),
          Text(
            advice.helpfulnessRating.toStringAsFixed(1),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.dubaiGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryView() {
    // Build category filter view
    return Column(
      children: [
        _buildCategoryFilters(),
        const SizedBox(height: 16),
        Expanded(child: _buildAdviceList()),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AdviceCategory.values.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(AdviceDisplayHelper.getCategoryDisplayName(category)),
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : null;
                });
              },
              selectedColor: _getCategoryColor(category).withOpacity(0.2),
              backgroundColor: Colors.grey.withOpacity(0.1),
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: isSelected 
                    ? _getCategoryColor(category)
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getCategoryColor(AdviceCategory category) {
    switch (category) {
      case AdviceCategory.firstTime:
        return AppColors.dubaiGold;
      case AdviceCategory.familyTips:
        return AppColors.dubaiCoral;
      case AdviceCategory.accessibility:
        return AppColors.dubaiPurple;
      case AdviceCategory.transportation:
        return AppColors.dubaiTeal;
      case AdviceCategory.budgetTips:
        return Colors.green;
      case AdviceCategory.whatToExpect:
        return Colors.blue;
      case AdviceCategory.bestTime:
        return Colors.orange;
      case AdviceCategory.general:
        return Colors.grey;
    }
  }

  void _markHelpful(EventAdvice advice) async {
    try {
      final adviceService = AdviceApiService();
      final success = await adviceService.markAdviceHelpful(advice.id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.thumbsUp,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Thanks for marking this advice as helpful!',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.dubaiTeal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        
        // Refresh the advice list to show updated vote count
        if (widget.onAdviceUpdated != null) {
          widget.onAdviceUpdated!();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to mark advice as helpful'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
} 