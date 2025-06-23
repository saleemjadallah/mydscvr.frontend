import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/dubai_app_bar.dart';
import '../../models/event.dart';
import '../../services/events_service.dart';
import '../../services/providers/auth_provider_mongodb.dart';
import '../../services/auth_api_service.dart';
import '../../widgets/events/event_card_enhanced.dart';

/// Screen for displaying user's favorite (hearted and saved) events
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  
  late TabController _tabController;
  late AnimationController _animationController;
  late final AuthApiService _authService;
  
  List<Event> heartedEvents = [];
  List<Event> savedEvents = [];
  bool _isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authService = AuthApiService();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _loadFavoriteEvents();
    _animationController.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh when app resumes (coming back to the screen)
    if (state == AppLifecycleState.resumed) {
      _loadFavoriteEvents();
    }
  }

  Future<void> _loadFavoriteEvents() async {
    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    try {
      // Check authentication
      final authState = ref.read(authProvider);
      print('🔍 Auth state: ${authState.isAuthenticated}');
      print('🔍 User: ${authState.user?.email}');
      
      if (!authState.isAuthenticated || authState.user == null) {
        setState(() {
          _isLoading = false;
          errorMessage = 'Please sign in to view your favorite events';
        });
        return;
      }

      // Fetch hearted events
      final heartedResult = await _authService.getFavoriteEvents(
        eventType: 'hearted',
        perPage: 50, // Get more to show all at once
      );
      
      if (heartedResult.isSuccess && heartedResult.events != null) {
        heartedEvents = heartedResult.events!;
        print('🔍 Fetched ${heartedEvents.length} hearted events');
      } else {
        print('❌ Failed to fetch hearted events: ${heartedResult.message}');
      }

      // Fetch saved events
      final savedResult = await _authService.getFavoriteEvents(
        eventType: 'saved',
        perPage: 50, // Get more to show all at once
      );
      
      if (savedResult.isSuccess && savedResult.events != null) {
        savedEvents = savedResult.events!;
        print('🔍 Fetched ${savedEvents.length} saved events');
      } else {
        print('❌ Failed to fetch saved events: ${savedResult.message}');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading favorite events: $e');
      setState(() {
        _isLoading = false;
        errorMessage = 'Failed to load favorite events. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.surface : AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(),
          _buildTabBar(),
        ],
        body: _isLoading 
          ? _buildLoadingState()
          : errorMessage != null
            ? _buildErrorState()
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildEventsList(heartedEvents, 'hearted'),
                  _buildEventsList(savedEvents, 'saved'),
                ],
              ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.dubaiGold,
      leading: IconButton(
        icon: Icon(
          LucideIcons.arrowLeft,
          color: Colors.white,
        ),
        onPressed: () => context.go('/'),
        tooltip: 'Back to Home',
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.sunsetGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.heart,
                    size: 48,
                    color: Colors.white,
                  ).animate().scale(delay: 200.ms),
                  const SizedBox(height: 16),
                  Text(
                    'My Favorites',
                    style: GoogleFonts.comfortaa(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate().slideY(delay: 300.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Your hearted and saved events',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        heartedCount: heartedEvents.length,
        savedCount: savedEvents.length,
        child: Container(
          color: AppColors.background,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.dubaiGold,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.dubaiGold,
            labelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            tabs: [
              Tab(
                icon: Icon(LucideIcons.heart, size: 20),
                text: 'Hearted (${heartedEvents.length})',
              ),
              Tab(
                icon: Icon(LucideIcons.bookmark, size: 20),
                text: 'Saved (${savedEvents.length})',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.dubaiGold),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your favorites...',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Failed to load favorite events',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadFavoriteEvents,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dubaiGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(List<Event> events, String type) {
    if (events.isEmpty) {
      return _buildEmptyState(type);
    }

    // Get responsive grid count
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    if (screenWidth > 1400) {
      crossAxisCount = 4;
    } else if (screenWidth > 900) {
      crossAxisCount = 3;
    } else if (screenWidth > 600) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return RefreshIndicator(
      onRefresh: _loadFavoriteEvents,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.85,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCardEnhanced(
              event: event,
              onTap: () => _navigateToEventDetail(event),
            ).animate().fadeIn(
              delay: Duration(milliseconds: index * 100),
              duration: const Duration(milliseconds: 600),
            ).slideY(
              begin: 0.2,
              end: 0,
              delay: Duration(milliseconds: index * 100),
              duration: const Duration(milliseconds: 600),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    final isHearted = type == 'hearted';
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isHearted ? LucideIcons.heart : LucideIcons.bookmark,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              isHearted ? 'No hearted events yet' : 'No saved events yet',
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isHearted 
                ? 'Tap the heart icon on events you love to see them here'
                : 'Tap the bookmark icon on events to save them for later',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/events'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dubaiGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Browse Events'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEventDetail(Event event) {
    context.go('/event/${event.id}');
  }
}

// Custom delegate for the tab bar
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final int heartedCount;
  final int savedCount;

  _TabBarDelegate({
    required this.child,
    required this.heartedCount,
    required this.savedCount,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    // Rebuild when counts change
    return oldDelegate.heartedCount != heartedCount || 
           oldDelegate.savedCount != savedCount;
  }
}