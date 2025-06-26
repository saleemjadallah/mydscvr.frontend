import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/duration_formatter.dart';

// Core imports
import '../../core/constants/app_colors.dart';
import '../../core/themes/app_typography.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../core/widgets/curved_container.dart';
import '../../core/widgets/dubai_app_bar.dart';

// Model imports
import '../../models/event.dart';
import '../../models/advice_models.dart';

// Widget imports
import '../../widgets/events/event_advice_widget.dart';
import '../../widgets/events/advice_submission_dialog.dart';

// Service imports
import '../../services/providers/events_provider.dart';
import '../../services/providers/preferences_provider.dart';
import '../../services/providers/auth_provider_mongodb.dart';
import '../../services/api/advice_api_service.dart';

/// Detailed event screen with full information and booking options
class EventDetailsScreen extends ConsumerStatefulWidget {
  final String eventId;
  final Event? event; // Optional pre-loaded event
  
  const EventDetailsScreen({
    super.key,
    required this.eventId,
    this.event,
  });

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  
  bool _isAppBarCollapsed = false;
  bool _showBookingButton = true;
  
  // Advice data management
  List<EventAdvice> _adviceList = [];
  AdviceStats? _adviceStats;
  bool _isLoadingAdvice = false;
  String? _adviceError;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();
    
    // Listen to scroll for app bar effects
    _scrollController.addListener(_onScroll);
    
    // Listen to tab changes for lazy loading advice
    _tabController.addListener(_onTabChanged);
    
    // Load event details if not provided
    if (widget.event == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(eventsProvider.notifier).getEventById(widget.eventId);
      });
    }
  }

  void _onTabChanged() {
    // Load advice data when user switches to advice tab (index 3)
    if (_tabController.index == 3 && _adviceList.isEmpty && !_isLoadingAdvice) {
      _loadAdviceData();
    }
  }

  Future<void> _loadAdviceData() async {
    if (_isLoadingAdvice) return;
    
    setState(() {
      _isLoadingAdvice = true;
      _adviceError = null;
    });

    try {
      final apiService = AdviceApiService();
      final advice = await apiService.getEventAdvice(widget.eventId);
      
      setState(() {
        _adviceList = advice;
        _adviceStats = _generateAdviceStats(advice);
        _isLoadingAdvice = false;
      });
    } catch (e) {
      setState(() {
        _adviceError = e.toString();
        _isLoadingAdvice = false;
      });
    }
  }

  AdviceStats _generateAdviceStats(List<EventAdvice> adviceList) {
    if (adviceList.isEmpty) {
      return AdviceStats(
        eventId: widget.eventId,
        totalAdvice: 0,
        averageHelpfulness: 0.0,
        adviceByCategory: {},
        adviceByType: {},
        verifiedAdviceCount: 0,
        featuredAdviceCount: 0,
        recentAdviceCount: 0,
        topTags: [],
        lastUpdated: DateTime.now(),
      );
    }

    final Map<String, int> categoryCount = {};
    final Map<String, int> typeCount = {};
    final Set<String> allTags = {};
    int verifiedCount = 0;
    int featuredCount = 0;
    int recentCount = 0;
    double totalHelpfulness = 0.0;

    final now = DateTime.now();
    final dayAgo = now.subtract(const Duration(days: 1));

    for (final advice in adviceList) {
      // Category stats
      final category = advice.category.toString().split('.').last;
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;

      // Type stats
      final type = advice.adviceType.toString().split('.').last;
      typeCount[type] = (typeCount[type] ?? 0) + 1;

      // Tags
      allTags.addAll(advice.tags);

      // Counts
      if (advice.isVerified) verifiedCount++;
      if (advice.isFeatured) featuredCount++;
      if (advice.createdAt.isAfter(dayAgo)) recentCount++;

      totalHelpfulness += advice.helpfulnessRating;
    }

    final topTags = allTags.toList()..sort();

    return AdviceStats(
      eventId: widget.eventId,
      totalAdvice: adviceList.length,
      averageHelpfulness: totalHelpfulness / adviceList.length,
      adviceByCategory: categoryCount,
      adviceByType: typeCount,
      verifiedAdviceCount: verifiedCount,
      featuredAdviceCount: featuredCount,
      recentAdviceCount: recentCount,
      topTags: topTags.take(5).toList(),
      lastUpdated: now,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isCollapsed = _scrollController.offset > 200;
    if (isCollapsed != _isAppBarCollapsed) {
      setState(() {
        _isAppBarCollapsed = isCollapsed;
      });
    }
    
    final showButton = _scrollController.offset < 
        (_scrollController.position.maxScrollExtent - 100);
    if (showButton != _showBookingButton) {
      setState(() {
        _showBookingButton = showButton;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkModeProvider);
    final eventAsync = widget.event != null 
        ? AsyncValue.data(widget.event!)
        : ref.watch(eventDetailsProvider(widget.eventId));
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.surface : AppColors.background,
      body: eventAsync.when(
        data: (event) => _buildEventDetails(event),
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildEventDetails(Event event) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Hero Image with App Bar
        _buildHeroSection(event),
        
        // Event Title and Quick Info
        _buildEventHeader(event),
        
        // Tabs
        _buildTabBar(),
        
        // Tab Content
        _buildTabContent(event),
        
        // Bottom padding for floating button
        const SliverToBoxAdapter(
          child: SizedBox(height: 120),
        ),
      ],
    );
  }

  Widget _buildHeroSection(Event event) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.dubaiGold,
      leading: IconButton(
        onPressed: () {
          // Always try to go back to the previous page
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            // If no previous page in navigation stack, go to events list
            context.go('/events');
          }
        },
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      actions: [
        // Share button
        IconButton(
          onPressed: () => _shareEvent(event),
          icon: const Icon(LucideIcons.share, color: Colors.white),
        ),
        // Favorite button
        Consumer(
          builder: (context, ref, child) {
            final isFavorite = ref.watch(isEventHeartedProvider(event.id));
            return IconButton(
              onPressed: () => _toggleFavorite(event.id),
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? AppColors.dubaiCoral : Colors.white,
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Event Image
            Hero(
              tag: 'event-image-${event.id}',
              child: Image.network(
                event.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.sunsetGradient,
                    ),
                    child: const Icon(
                      LucideIcons.calendar,
                      size: 60,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            
            // Gradient Overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black45,
                  ],
                ),
              ),
            ),
            
            // Category Badge
            Positioned(
              top: 60,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCategoryColor(event.category),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  event.category,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animate()
                .slideX(duration: 600.ms, begin: 1)
                .fade(delay: 200.ms),
            ),
            
            // Price Badge
            if (event.pricing.basePrice > 0)
              Positioned(
                bottom: 20,
                right: 20,
                child: GlassMorphism(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.tag,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'From AED ${event.pricing.basePrice.toStringAsFixed(0)}',
                          style: AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate()
                  .slideY(duration: 600.ms, begin: 1)
                  .fade(delay: 400.ms),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventHeader(Event event) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Title
            Text(
              event.title,
              style: AppTypography.displayMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate()
              .slideX(duration: 500.ms, begin: -0.3)
              .fade(),
            
            const SizedBox(height: 12),
            
            // Quick Info Row
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildQuickInfo(
                  LucideIcons.calendar,
                  _formatDate(event.startDate),
                ),
                _buildQuickInfo(
                  LucideIcons.clock,
                  _formatTime(event.startDate, event.endDate ?? event.startDate.add(const Duration(hours: 2))),
                ),
                _buildQuickInfo(
                  LucideIcons.mapPin,
                  event.venue.area,
                ),
                if (event.familySuitability.minAge != null)
                  _buildQuickInfo(
                    LucideIcons.users,
                    'Ages ${event.familySuitability.minAge}+',
                  ),
              ],
            ).animate()
              .slideY(duration: 500.ms, begin: 0.3)
              .fade(delay: 200.ms),
            
            const SizedBox(height: 16),
            
            // Views Counter
            Row(
              children: [
                Icon(
                  LucideIcons.eye,
                  size: 20,
                  color: AppColors.dubaiTeal,
                ),
                const SizedBox(width: 8),
                Text(
                  'This Event has been Viewed ${_getViewCount(event.id)} times',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ).animate()
              .slideX(duration: 500.ms, begin: -0.3)
              .fade(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.dubaiGold,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Details'),
            Tab(text: 'Location'),
            Tab(text: 'Advice'),
          ],
          labelColor: AppColors.dubaiGold,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.dubaiGold,
          indicatorWeight: 4.0,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.dubaiGold,
          ),
          unselectedLabelStyle: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.normal,
            color: AppColors.textSecondary,
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
          isScrollable: false,
          tabAlignment: TabAlignment.fill,
        ),
      ),
    );
  }

  Widget _buildTabContent(Event event) {
    return SliverFillRemaining(
      hasScrollBody: true,
      child: TabBarView(
        controller: _tabController,
        physics: const ClampingScrollPhysics(),
        children: [
          _buildOverviewTab(event),
          _buildDetailsTab(event),
          _buildLocationTab(event),
          _buildAdviceTab(event),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Event event) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            'About This Event',
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getEventDescription(event),
            style: AppTypography.bodyLarge.copyWith(
              height: 1.6,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Highlights
          if (event.highlights.isNotEmpty) ...[
            Text(
              'Highlights',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...event.highlights.map((highlight) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      LucideIcons.check,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        highlight,
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            
            const SizedBox(height: 24),
          ],
          
          // What's Included
          if (event.included.isNotEmpty) ...[
            Text(
              'What\'s Included',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            CurvedContainer(
              padding: const EdgeInsets.all(16),
              backgroundColor: AppColors.surfaceVariant,
              child: Column(
                children: event.included.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.plus,
                          size: 16,
                          color: AppColors.dubaiGold,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: AppTypography.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          
          // Event URL and Ticket Links (Enhanced)
          if (event.eventUrl != null || event.ticketLinks.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Event Links',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (event.eventUrl != null)
              _buildLinkButton('Event Details', event.eventUrl!, LucideIcons.externalLink),
            const SizedBox(height: 8),
            ...event.ticketLinks.map((ticketUrl) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildLinkButton('Book Tickets', ticketUrl, LucideIcons.ticket),
            )).toList(),
          ],
          
          // Secondary Categories (Enhanced)
          if (event.secondaryCategories.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Categories',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCategoryChip(event.category, true), // Primary category
                ...event.secondaryCategories.map((category) => _buildCategoryChip(category, false)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinkButton(String label, String url, IconData icon) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _launchUrl(url),
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dubaiTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary 
          ? AppColors.dubaiGold.withOpacity(0.1)
          : AppColors.dubaiTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary 
            ? AppColors.dubaiGold.withOpacity(0.3)
            : AppColors.dubaiTeal.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPrimary) ...[
            Icon(
              LucideIcons.star,
              size: 12,
              color: AppColors.dubaiGold,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            category.replaceAll('_', ' ').split(' ').map((word) => 
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
            ).join(' '),
            style: AppTypography.labelSmall.copyWith(
              color: isPrimary ? AppColors.dubaiGold : AppColors.dubaiTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Event event) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Schedule
          _buildDetailSection(
            'Schedule',
            LucideIcons.calendar,
            [
              'Start: ${_formatDateTime(event.startDate)}',
              'End: ${_formatDateTime(event.endDate ?? event.startDate.add(const Duration(hours: 2)))}',
              'Duration: ${_formatDuration(event.startDate, event.endDate ?? event.startDate.add(const Duration(hours: 2)))}',
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Pricing
          _buildDetailSection(
            'Pricing',
            LucideIcons.tag,
            [
              'Base Price: AED ${event.pricing.basePrice.toStringAsFixed(0)}',
              if (event.pricing.childPrice != null)
                'Child Price: AED ${event.pricing.childPrice!.toStringAsFixed(0)}',
              if (event.pricing.groupDiscount != null)
                'Group Discount: ${event.pricing.groupDiscount}%',
              'Currency: ${event.pricing.currency}',
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Family Suitability
          _buildDetailSection(
            'Family Information',
            LucideIcons.users,
            [
              if (event.familySuitability.minAge != null)
                'Minimum Age: ${event.familySuitability.minAge} years',
              if (event.familySuitability.maxAge != null)
                'Maximum Age: ${event.familySuitability.maxAge} years',
              'Stroller Friendly: ${event.familySuitability.strollerFriendly ? "Yes" : "No"}',
              'Baby Changing: ${event.familySuitability.babyChanging ? "Yes" : "No"}',
              if (event.familySuitability.notes != null)
                _buildFamilyNotesOrScore(event),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Connect Section (renamed from Enhanced Information)
          _buildConnectSection(event),
          
          const SizedBox(height: 24),
          
          // Accessibility
          if (event.accessibility.isNotEmpty)
            _buildDetailSection(
              'Accessibility',
              LucideIcons.accessibility,
              event.accessibility,
            ),
          
          // Quality Metrics (Hidden from public - kept for internal use)
          // if (event.qualityMetrics != null)
          //   _buildQualityMetricsSection(event.qualityMetrics!),
          
          const SizedBox(height: 24),
          
          // Enhanced Event Information (other details)
          _buildEnhancedInfoSection(event),
          
          const SizedBox(height: 24),
          
          // Target Audience (Enhanced)
          if (event.targetAudience.isNotEmpty)
            _buildDetailSection(
              'Target Audience',
              LucideIcons.users,
              event.targetAudience,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, IconData icon, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.dubaiGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: AppColors.dubaiGold),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;
              
              // Parse label and value from the item
              final parts = item.split(': ');
              final label = parts.length > 1 ? parts[0] : item;
              final value = parts.length > 1 ? parts[1] : '';
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: isLast ? null : Border(
                    bottom: BorderSide(
                      color: AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    Expanded(
                      flex: 2,
                      child: Text(
                        label,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Value
                    Expanded(
                      flex: 3,
                      child: Text(
                        value.isNotEmpty ? value : label,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationTab(Event event) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Venue Information
          Text(
            event.venue.name,
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.venue.address,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Map Placeholder
          CurvedContainer(
            height: 200,
            backgroundColor: AppColors.surfaceVariant,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.map,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Interactive Map Coming Soon',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Directions Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openDirections(event.venue),
              icon: const Icon(LucideIcons.navigation),
              label: const Text('Get Directions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dubaiTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Contact Information
          if (event.venue.phone != null) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _callVenue(event.venue.phone!),
                icon: const Icon(LucideIcons.phone),
                label: Text('Call ${event.venue.phone}'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.dubaiGold,
                  side: const BorderSide(color: AppColors.dubaiGold),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdviceTab(Event event) {
    if (_isLoadingAdvice) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.dubaiGold),
          ),
        ),
      );
    }

    if (_adviceError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.alertCircle,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load advice',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _adviceError!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadAdviceData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dubaiGold,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: EventAdviceWidget(
        eventId: event.id,
        adviceList: _adviceList,
        stats: _adviceStats ?? AdviceStats(
          eventId: event.id,
          totalAdvice: 0,
          averageHelpfulness: 0.0,
          adviceByCategory: {},
          adviceByType: {},
          verifiedAdviceCount: 0,
          featuredAdviceCount: 0,
          recentAdviceCount: 0,
          topTags: [],
          lastUpdated: DateTime.now(),
        ),
        onAddAdvice: () => _showAddAdviceDialog(event),
      ),
    );
  }



  void _showAddAdviceDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => AdviceSubmissionDialog(
        event: event,
        onAdviceSubmitted: () {
          // Refresh the advice data after submission
          _loadAdviceData();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.dubaiGold),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load event',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dubaiGold,
                foregroundColor: Colors.white,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  String _buildFamilyNotesOrScore(Event event) {
    final notes = event.familySuitability.notes;
    
    // Check if notes contains only a family score (pattern: "Family Score: X/100")
    if (notes != null && notes.startsWith('Family Score: ') && notes.endsWith('/100')) {
      // Extract the score from the notes
      final scoreMatch = RegExp(r'Family Score: (\d+)/100').firstMatch(notes);
      if (scoreMatch != null) {
        final score = int.parse(scoreMatch.group(1)!);
        return 'Family Rating: ${_getFamilyRatingDescription(score)} ($score% family-friendly)';
      }
    }
    
    // If it's actual notes (not just a family score), show them as is
    return 'Notes: $notes';
  }

  String _getFamilyRatingDescription(int score) {
    if (score >= 90) return 'Perfect for Families';
    if (score >= 80) return 'Excellent for Families';
    if (score >= 70) return 'Great for Families';
    if (score >= 60) return 'Good for Families';
    if (score >= 50) return 'Suitable for Families';
    return 'Family Considerations Required';
  }

  int _getViewCount(String eventId) {
    // Generate a pseudo-random view count based on event ID
    // This ensures the same event always shows the same view count
    final hash = eventId.hashCode.abs();
    final baseCount = 50 + (hash % 450); // Range: 50-500
    final currentHour = DateTime.now().hour;
    final hourlyBoost = (currentHour * hash % 50); // Small hourly variation
    return baseCount + hourlyBoost;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'arts & crafts':
        return AppColors.artsCategory;
      case 'sports':
        return AppColors.sportsCategory;
      case 'music':
        return AppColors.musicCategory;
      case 'food & dining':
        return AppColors.foodCategory;
      case 'education':
        return AppColors.educationCategory;
      case 'outdoor':
        return AppColors.outdoorCategory;
      default:
        return AppColors.dubaiGold;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(DateTime start, DateTime end) {
    final startTime = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endTime = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '$startTime - $endTime';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${_formatTime(dateTime, dateTime)}';
  }

  String _formatDuration(DateTime start, DateTime end) {
    return DurationFormatter.formatForDetails(start, end);
  }

  String _formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference} days ago';
    if (difference < 30) return '${(difference / 7).floor()} weeks ago';
    return '${(difference / 30).floor()} months ago';
  }

  void _shareEvent(Event event) {
    Share.share(
      'Check out this amazing event: ${event.title}\n\n'
      '📅 ${_formatDateTime(event.startDate)}\n'
      '📍 ${event.venue.name}, ${event.venue.area}\n\n'
      'Discover more family activities on DXB Events!',
      subject: event.title,
    );
  }

  Future<void> _toggleFavorite(String eventId) async {
    final isFavorite = ref.read(isEventHeartedProvider(eventId));
    
    final authNotifier = ref.read(authProvider.notifier);
    if (isFavorite) {
      await authNotifier.unheartEvent(eventId);
    } else {
      await authNotifier.heartEvent(eventId);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isFavorite ? Icons.heart_broken : Icons.favorite,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isFavorite 
                    ? 'Removed from favorites' 
                    : 'Added to favorites! ❤️',
                ),
              ),
              if (!isFavorite) ...[
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    context.push('/favorites');
                  },
                  child: const Text(
                    'View',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          backgroundColor: isFavorite ? AppColors.textSecondary : AppColors.dubaiCoral,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _openDirections(Venue venue) async {
    final query = Uri.encodeComponent('${venue.name}, ${venue.address}');
    final url = 'https://maps.google.com/maps?q=$query';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch maps';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open maps. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _callVenue(String phone) {
    // TODO: Implement phone call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $phone...'),
        backgroundColor: AppColors.dubaiGold,
      ),
    );
  }

  String _getEventDescription(Event event) {
    // Use the displaySummary method which already has fallback logic
    final summary = event.displaySummary;
    if (summary.isNotEmpty) {
      return summary;
    }

    // Additional fallback for detail screen
    final category = event.category.replaceAll('_', ' ').toUpperCase();
    final area = event.venue.area;
    return 'Join us for this ${category.toLowerCase()} event at ${event.venue.name} in $area. This family-friendly activity is perfect for creating lasting memories together.';
  }

  // Enhanced Sections for Social Media, Quality Metrics, and Enhanced Info
  
  Widget _buildSocialMediaSection(SocialMediaLinks socialMedia) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.dubaiCoral.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.share2, size: 20, color: AppColors.dubaiCoral),
            ),
            const SizedBox(width: 12),
            Text(
              'Follow & Share',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (socialMedia.instagram != null) _buildSocialButton('Instagram', socialMedia.instagram!, LucideIcons.instagram),
            if (socialMedia.facebook != null) _buildSocialButton('Facebook', socialMedia.facebook!, LucideIcons.facebook),
            if (socialMedia.twitter != null) _buildSocialButton('Twitter', socialMedia.twitter!, LucideIcons.twitter),
            if (socialMedia.tiktok != null) _buildSocialButton('TikTok', socialMedia.tiktok!, LucideIcons.video),
            if (socialMedia.youtube != null) _buildSocialButton('YouTube', socialMedia.youtube!, LucideIcons.youtube),
            if (socialMedia.whatsapp != null) _buildSocialButton('WhatsApp', socialMedia.whatsapp!, LucideIcons.messageCircle),
            if (socialMedia.telegram != null) _buildSocialButton('Telegram', socialMedia.telegram!, LucideIcons.send),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(String platform, String url, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => _launchUrl(url),
      icon: Icon(icon, size: 16),
      label: Text(platform),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.dubaiTeal.withOpacity(0.1),
        foregroundColor: AppColors.dubaiTeal,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.dubaiTeal.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildQualityMetricsSection(QualityMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: metrics.qualityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.award, size: 20, color: metrics.qualityColor),
            ),
            const SizedBox(width: 12),
            Text(
              'Quality Metrics',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildQualityIndicator('Extraction Confidence', metrics.extractionConfidence, metrics.confidenceLevel),
        const SizedBox(height: 8),
        _buildQualityIndicator('Data Completeness', metrics.dataCompleteness, metrics.completenessLevel),
        const SizedBox(height: 8),
        _buildQualityInfo('Source Reliability', metrics.sourceReliability.toUpperCase()),
        const SizedBox(height: 8),
        _buildQualityInfo('Last Verified', metrics.lastVerified),
        if (metrics.hasWarnings) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.alertTriangle, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text('Data Warnings', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ...metrics.validationWarnings.map((warning) => Text('• $warning', style: AppTypography.bodySmall)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQualityIndicator(String label, double value, String level) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: AppTypography.bodyMedium),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  value >= 0.8 ? Colors.green : value >= 0.6 ? Colors.orange : Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text('$level (${(value * 100).toInt()}%)', style: AppTypography.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQualityInfo(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: AppTypography.bodyMedium),
        ),
        Expanded(
          flex: 3,
          child: Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildConnectSection(Event event) {
    final hasEventUrl = event.eventUrl != null;
    final hasSocialMedia = event.socialMedia != null && event.socialMedia!.hasAnyLinks;
    
    if (!hasEventUrl && !hasSocialMedia) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.dubaiTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.link, size: 20, color: AppColors.dubaiTeal),
            ),
            const SizedBox(width: 12),
            Text(
              'Connect',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Event URL Button
        if (hasEventUrl) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchUrl(event.eventUrl!),
              icon: const Icon(LucideIcons.externalLink, size: 18),
              label: const Text('Visit Event Page'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dubaiTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          if (hasSocialMedia) const SizedBox(height: 16),
        ],
        
        // Social Media Links
        if (hasSocialMedia) ...[
          Text(
            'Follow & Share',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (event.socialMedia!.instagram != null) 
                _buildSocialButton('Instagram', event.socialMedia!.instagram!, LucideIcons.instagram),
              if (event.socialMedia!.facebook != null) 
                _buildSocialButton('Facebook', event.socialMedia!.facebook!, LucideIcons.facebook),
              if (event.socialMedia!.twitter != null) 
                _buildSocialButton('Twitter', event.socialMedia!.twitter!, LucideIcons.twitter),
              if (event.socialMedia!.tiktok != null) 
                _buildSocialButton('TikTok', event.socialMedia!.tiktok!, LucideIcons.video),
              if (event.socialMedia!.youtube != null) 
                _buildSocialButton('YouTube', event.socialMedia!.youtube!, LucideIcons.youtube),
              if (event.socialMedia!.whatsapp != null) 
                _buildSocialButton('WhatsApp', event.socialMedia!.whatsapp!, LucideIcons.messageCircle),
              if (event.socialMedia!.telegram != null) 
                _buildSocialButton('Telegram', event.socialMedia!.telegram!, LucideIcons.send),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEnhancedInfoSection(Event event) {
    final hasAnyEnhancedInfo = event.venueType != null ||
        event.eventType != null ||
        event.indoorOutdoor != null ||
        event.durationHours != null ||
        event.languageRequirements != null ||
        event.ageRestrictions != null ||
        event.dressCode != null ||
        event.metroAccessible != null ||
        event.specialNeedsFriendly != null ||
        event.alcoholServed != null ||
        event.transportationNotes != null ||
        event.specialOccasion != null;
    
    if (!hasAnyEnhancedInfo) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.dubaiGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.info, size: 20, color: AppColors.dubaiGold),
            ),
            const SizedBox(width: 12),
            Text(
              'Enhanced Information',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Other enhanced info fields (removed Event URL from here)
              if (event.venueType != null)
                _buildEnhancedInfoItem('Venue Type', event.venueType!, isFirst: true),
              if (event.eventType != null)
                _buildEnhancedInfoItem('Event Type', event.eventType!),
              if (event.indoorOutdoor != null)
                _buildEnhancedInfoItem('Setting', event.indoorOutdoor!),
              if (event.durationHours != null)
                _buildEnhancedInfoItem('Duration', '${event.durationHours} hours'),
              if (event.languageRequirements != null)
                _buildEnhancedInfoItem('Language', event.languageRequirements!),
              if (event.ageRestrictions != null)
                _buildEnhancedInfoItem('Age Restrictions', event.ageRestrictions!),
              if (event.dressCode != null)
                _buildEnhancedInfoItem('Dress Code', event.dressCode!),
              if (event.metroAccessible != null)
                _buildEnhancedInfoItem('Metro Accessible', event.metroAccessible! ? "Yes" : "No"),
              if (event.specialNeedsFriendly != null)
                _buildEnhancedInfoItem('Special Needs Friendly', event.specialNeedsFriendly! ? "Yes" : "No"),
              if (event.alcoholServed != null)
                _buildEnhancedInfoItem('Alcohol Served', event.alcoholServed! ? "Yes" : "No"),
              if (event.transportationNotes != null)
                _buildEnhancedInfoItem('Transportation', event.transportationNotes!),
              if (event.specialOccasion != null)
                _buildEnhancedInfoItem('Special Occasion', event.specialOccasion!, isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedInfoItem(String label, String value, {bool isUrl = false, bool isFirst = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Value (clickable if URL)
          Expanded(
            flex: 3,
            child: isUrl
                ? GestureDetector(
                    onTap: () => _launchUrl(value),
                    child: Text(
                      value,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.dubaiTeal,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  )
                : Text(
                    value,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.end,
                  ),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      // Use platform-specific URL launching
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch: ${uri.toString()}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening URL: $e')),
        );
      }
    }
  }
}

// Custom TabBar Delegate
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
