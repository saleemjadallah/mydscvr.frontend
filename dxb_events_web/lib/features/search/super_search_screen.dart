import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../services/super_search_service.dart';
import '../../widgets/events/event_card.dart';

// State Management
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedFiltersProvider = StateProvider<Map<String, Set<String>>>((ref) => {});
final isSearchActiveProvider = StateProvider<bool>((ref) => false);

// App Colors (From MyDscvr Brand)
class MyDscvrColors {
  static const Color dubaiGold = Color(0xFFD4AF37);
  static const Color dubaiTeal = Color(0xFF17A2B8);
  static const Color dubaiCoral = Color(0xFFFF6B6B);
  static const Color dubaiPurple = Color(0xFF6C5CE7);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF7B7B), Color(0xFFFFA726)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF17A2B8), Color(0xFF6C5CE7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class SuperSearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SuperSearchScreen({
    super.key,
    this.initialQuery,
  });
  
  @override
  ConsumerState<SuperSearchScreen> createState() => _SuperSearchScreenState();
}

class _SuperSearchScreenState extends ConsumerState<SuperSearchScreen>
    with TickerProviderStateMixin {
  final SuperSearchService _superSearchService = SuperSearchService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _pulseController;
  late AnimationController _searchBarController;
  
  SuperSearchResult? _searchResult;
  bool _isLoading = false;
  bool _showResults = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _searchBarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Listen to search focus
    _searchFocusNode.addListener(() {
      ref.read(isSearchActiveProvider.notifier).state = _searchFocusNode.hasFocus;
      if (_searchFocusNode.hasFocus) {
        _searchBarController.forward();
      } else {
        _searchBarController.reverse();
      }
    });

    // Set initial query if provided
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      ref.read(searchQueryProvider.notifier).state = widget.initialQuery!;
      // Perform initial search
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _pulseController.dispose();
    _searchBarController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    _searchController.text = query;
    ref.read(searchQueryProvider.notifier).state = query;
    
    setState(() {
      _isLoading = true;
      _showResults = true;
      _error = null;
    });

    final response = await _superSearchService.search(
      query: query.trim(),
      filters: const SuperSearchFilters(),
      page: 1,
      perPage: 20,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.isSuccess) {
          _searchResult = response.data;
          _error = null;
          print('🎯 SuperSearchScreen: Search successful! Events count: ${_searchResult?.events.length ?? 0}');
          print('🎯 SuperSearchScreen: Total results: ${_searchResult?.total ?? 0}');
        } else {
          _error = response.error;
          _searchResult = null;
          print('🚨 SuperSearchScreen: Search failed with error: ${response.error}');
        }
      });
    }
  }
  
  void _onFilterTap(String filter) {
    // Toggle filter selection
    final filters = ref.read(selectedFiltersProvider);
    final category = 'type';
    if (filters[category]?.contains(filter) == true) {
      filters[category]?.remove(filter);
    } else {
      filters[category] ??= {};
      filters[category]?.add(filter);
    }
    ref.read(selectedFiltersProvider.notifier).state = {...filters};
  }
  
  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdvancedFiltersModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyDscvrColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Animated App Bar
            _buildAnimatedAppBar(),
            
            // Main Search Section
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (!_showResults) ...[
                    _buildHeroSection(),
                    const SizedBox(height: 32),
                  ],
                  _buildSearchBar(),
                  if (_showResults) ...[
                    const SizedBox(height: 24),
                    _buildSearchResults(),
                  ] else ...[
                    const SizedBox(height: 24),
                    _buildQuickFilters(),
                    const SizedBox(height: 32),
                    _buildSearchSuggestions(),
                    const SizedBox(height: 24),
                    _buildTrendingSearches(),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          context.go('/');
        },
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: MyDscvrColors.dubaiTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            LucideIcons.arrowLeft,
            color: MyDscvrColors.dubaiTeal,
            size: 20,
          ),
        ),
      ).animate().scale(delay: 150.ms),
      title: Text(
        'Super Search',
        style: GoogleFonts.comfortaa(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: MyDscvrColors.textPrimary,
        ),
      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
      actions: [
        IconButton(
          onPressed: () {
            // Show search filters
            _showAdvancedFilters();
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: MyDscvrColors.oceanGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.sliders, color: Colors.white, size: 20),
          ),
        ).animate().scale(delay: 300.ms),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Stack(
      children: [
        // Floating Particles Background
        _buildParticlesBackground(),
        
        // Main Hero Content
        Column(
          children: [
            const SizedBox(height: 20),
            
            // Epic SUPER SEARCH Animated Title
            _buildAnimatedSuperSearchTitle(),
            
            const SizedBox(height: 24),
            
            // Subtitle with typewriter effect
            Text(
              'Discover perfect family experiences in Dubai',
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: MyDscvrColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 2400.ms).slideY(begin: 0.3),
            
            const SizedBox(height: 16),
            
            // Gaming-style stats row
            _buildGamingStatsRow(),
          ],
        ),
      ],
    );
  }
  
  Widget _buildAnimatedSuperSearchTitle() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isMediumScreen = constraints.maxWidth < 900;
        
        return Column(
          children: [
            // SUPER word
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                _buildAnimatedLetter('S', 0, const Color(0xFF00D4FF), _electricSparkAnimation, isSmallScreen, isMediumScreen),
                _buildAnimatedLetter('U', 200, const Color(0xFF39FF14), _bouncingBallAnimation, isSmallScreen, isMediumScreen),
                _buildAnimatedLetter('P', 400, const Color(0xFFFF1493), _heartbeatAnimation, isSmallScreen, isMediumScreen),
                _buildAnimatedLetter('E', 600, const Color(0xFFFFD700), _coinFlipAnimation, isSmallScreen, isMediumScreen),
                _buildAnimatedLetter('R', 800, const Color(0xFFFF4500), _fireFlickerAnimation, isSmallScreen, isMediumScreen),
              ],
            ),
            
            SizedBox(height: isSmallScreen ? 4 : 8),
            
            // SEARCH word
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                _buildAnimatedLetter('S', 1200, const Color(0xFF9932CC), _waveMotionAnimation, isSmallScreen, isMediumScreen),
                _buildAnimatedLetter('E', 1400, const Color(0xFFFF6B47), _explodingStarAnimation, isSmallScreen, isMediumScreen),
                _buildAnimatedLetter('A', 1600, const Color(0xFF40E0D0), _floatingBubbleAnimation, isSmallScreen, isMediumScreen),
                _buildAnimatedLetter('R', 1800, const Color(0xFF32CD32), _lightningBoltAnimation, isSmallScreen, isMediumScreen),
                _buildAnimatedLetter('C', 2000, const Color(0xFF4169E1), _spiralSwirlAnimation, isSmallScreen, isMediumScreen),
                _buildAnimatedLetter('H', 2200, const Color(0xFFFF00FF), _digitalGlitchAnimation, isSmallScreen, isMediumScreen),
              ],
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildAnimatedLetter(String letter, int delayMs, Color color, Widget Function(String, Color, bool, bool) animationBuilder, bool isSmallScreen, bool isMediumScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 1 : 2),
      child: animationBuilder(letter, color, isSmallScreen, isMediumScreen),
    ).animate().fadeIn(delay: Duration(milliseconds: delayMs)).scale(
      delay: Duration(milliseconds: delayMs),
      duration: 600.ms,
      begin: const Offset(0.5, 0.5),
      end: const Offset(1.0, 1.0),
    );
  }
  
  // Individual Letter Animations
  Widget _electricSparkAnimation(String letter, Color color, bool isSmallScreen, bool isMediumScreen) {
    final fontSize = isSmallScreen ? 28.0 : (isMediumScreen ? 36.0 : 48.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(seconds: isSmallScreen ? 1 : 2),
      builder: (context, value, child) {
        return Semantics(
          label: 'Letter $letter with electric spark animation',
          child: Transform.scale(
            scale: 1.0 + (0.1 * sin(value * pi * 4)),
            child: Transform.rotate(
              angle: sin(value * pi * 8) * 0.1,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(isSmallScreen ? 0.6 : 0.8),
                      blurRadius: (isSmallScreen ? 10 : 15) + (10 * sin(value * pi * 6)),
                      spreadRadius: isSmallScreen ? 1 : 2,
                    ),
                  ],
                ),
                child: Text(
                  letter,
                  style: GoogleFonts.orbitron(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: color,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _bouncingBallAnimation(String letter, Color color, bool isSmallScreen, bool isMediumScreen) {
    final fontSize = isSmallScreen ? 28.0 : (isMediumScreen ? 36.0 : 48.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: isSmallScreen ? 1200 : 1800),
      builder: (context, value, child) {
        final bounce = sin(value * pi * 3) * 0.3;
        return Semantics(
          label: 'Letter $letter with bouncing ball animation',
          child: Transform.translate(
            offset: Offset(0, -bounce.abs() * (isSmallScreen ? 15 : 20)),
            child: Transform.scale(
              scale: 1.0 + (bounce.abs() * 0.1),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(isSmallScreen ? 0.4 : 0.6),
                      blurRadius: (isSmallScreen ? 8 : 10).toDouble() + (bounce.abs() * 15),
                      offset: Offset(0, (isSmallScreen ? 3 : 5).toDouble() + (bounce.abs() * 10)),
                    ),
                  ],
                ),
                child: Text(
                  letter,
                  style: GoogleFonts.orbitron(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: color,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _heartbeatAnimation(String letter, Color color, bool isSmallScreen, bool isMediumScreen) {
    final fontSize = isSmallScreen ? 28.0 : (isMediumScreen ? 36.0 : 48.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: isSmallScreen ? 1500 : 2200),
      builder: (context, value, child) {
        double scale = 1.0;
        if (value > 0.1 && value < 0.25) {
          scale = isSmallScreen ? 1.2 : 1.3;
        } else if (value > 0.35 && value < 0.5) {
          scale = isSmallScreen ? 1.2 : 1.3;
        }
        
        return Semantics(
          label: 'Letter $letter with heartbeat animation',
          child: Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(scale > 1.0 ? (isSmallScreen ? 0.6 : 0.8) : 0.4),
                    blurRadius: scale > 1.0 ? (isSmallScreen ? 20 : 25) : (isSmallScreen ? 8 : 10),
                    spreadRadius: scale > 1.0 ? (isSmallScreen ? 2 : 3) : 1,
                  ),
                ],
              ),
              child: Text(
                letter,
                style: GoogleFonts.orbitron(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color: color,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _coinFlipAnimation(String letter, Color color, bool isSmallScreen, bool isMediumScreen) {
    final fontSize = isSmallScreen ? 28.0 : (isMediumScreen ? 36.0 : 48.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(seconds: isSmallScreen ? 1 : 2),
      builder: (context, value, child) {
        return Semantics(
          label: 'Letter $letter with coin flip animation',
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value * pi * 2),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(isSmallScreen ? 0.4 : 0.6),
                    blurRadius: isSmallScreen ? 12 : 15,
                    spreadRadius: isSmallScreen ? 1 : 2,
                  ),
                ],
              ),
              child: Text(
                letter,
                style: GoogleFonts.orbitron(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color: color,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _fireFlickerAnimation(String letter, Color color, bool isSmallScreen, bool isMediumScreen) {
    final fontSize = isSmallScreen ? 28.0 : (isMediumScreen ? 36.0 : 48.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: isSmallScreen ? 1000 : 1500),
      builder: (context, value, child) {
        return Semantics(
          label: 'Letter $letter with fire flicker animation',
          child: Transform.scale(
            scale: 1.0 + (sin(value * pi * 8) * (isSmallScreen ? 0.03 : 0.05)),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(0, 1, sin(value * pi * 6) * (isSmallScreen ? 0.05 : 0.1))
                ..setEntry(1, 0, sin(value * pi * 4) * 0.02),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(isSmallScreen ? 0.5 : 0.7),
                      blurRadius: (isSmallScreen ? 8 : 12) + (sin(value * pi * 10) * (isSmallScreen ? 5 : 8)),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  letter,
                  style: GoogleFonts.orbitron(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: color,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _waveMotionAnimation(String letter, Color color, bool isSmallScreen, bool isMediumScreen) {
    final fontSize = isSmallScreen ? 28.0 : (isMediumScreen ? 36.0 : 48.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: isSmallScreen ? 1400 : 2100),
      builder: (context, value, child) {
        return Semantics(
          label: 'Letter $letter with wave motion animation',
          child: Transform.translate(
            offset: Offset(0, sin(value * pi * 4) * (isSmallScreen ? 7 : 10)),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(isSmallScreen ? 0.4 : 0.6),
                    blurRadius: isSmallScreen ? 8 : 12,
                    offset: Offset(0, sin(value * pi * 4) * (isSmallScreen ? 3 : 5)),
                  ),
                ],
              ),
              child: Text(
                letter,
                style: GoogleFonts.orbitron(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color: color,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _explodingStarAnimation(String letter, Color color, bool isSmallScreen, bool isMediumScreen) {
    final fontSize = isSmallScreen ? 28.0 : (isMediumScreen ? 36.0 : 48.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: isSmallScreen ? 1300 : 1900),
      builder: (context, value, child) {
        final explosion = value > 0.3 && value < 0.5 ? 1.0 : 0.0;
        return Semantics(
          label: 'Letter $letter with exploding star animation',
          child: Transform.scale(
            scale: 1.0 + (explosion * (isSmallScreen ? 0.3 : 0.4)),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5 + (explosion * 0.4)),
                    blurRadius: (isSmallScreen ? 8 : 10) + (explosion * (isSmallScreen ? 15 : 20)),
                    spreadRadius: explosion * (isSmallScreen ? 3 : 5),
                  ),
                ],
              ),
              child: Text(
                letter,
                style: GoogleFonts.orbitron(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color: color,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _floatingBubbleAnimation(String letter, Color color, bool isSmallScreen, bool isMediumScreen) {
    final fontSize = isSmallScreen ? 28.0 : (isMediumScreen ? 36.0 : 48.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: isSmallScreen ? 1600 : 2300),
      builder: (context, value, child) {
        return Semantics(
          label: 'Letter $letter with floating bubble animation',
          child: Transform.translate(
            offset: Offset(0, sin(value * pi * 2) * (isSmallScreen ? 10 : 15)),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(isSmallScreen ? 0.3 : 0.5),
                    blurRadius: isSmallScreen ? 10 : 15,
                    spreadRadius: isSmallScreen ? 1 : 2,
                  ),
                ],
              ),
              child: Text(
                letter,
                style: GoogleFonts.orbitron(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color: color,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _lightningBoltAnimation(String letter, Color color, bool isSmallScreen, bool isMediumScreen) {
    final fontSize = isSmallScreen ? 28.0 : (isMediumScreen ? 36.0 : 48.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: isSmallScreen ? 1200 : 1700),
      builder: (context, value, child) {
        final flash = value > 0.2 && value < 0.3 ? 1.0 : 0.0;
        return Semantics(
          label: 'Letter $letter with lightning bolt animation',
          child: Transform.translate(
            offset: Offset(
              sin(value * pi * 12) * (isSmallScreen ? 2 : 3) * flash,
              cos(value * pi * 12) * (isSmallScreen ? 2 : 3) * flash,
            ),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4 + (flash * 0.6)),
                    blurRadius: (isSmallScreen ? 6 : 8) + (flash * (isSmallScreen ? 18 : 25)),
                    spreadRadius: flash * (isSmallScreen ? 2 : 3),
                  ),
                ],
              ),
              child: Text(
                letter,
                style: GoogleFonts.orbitron(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color: color,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _spiralSwirlAnimation(String letter, Color color, bool isSmallScreen, bool isMediumScreen) {
    final fontSize = isSmallScreen ? 28.0 : (isMediumScreen ? 36.0 : 48.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: isSmallScreen ? 1700 : 2400),
      builder: (context, value, child) {
        final radius = (isSmallScreen ? 5 : 8) * sin(value * pi * 2);
        return Semantics(
          label: 'Letter $letter with spiral swirl animation',
          child: Transform.translate(
            offset: Offset(
              cos(value * pi * 4) * radius,
              sin(value * pi * 4) * radius,
            ),
            child: Transform.scale(
              scale: 1.0 + (sin(value * pi * 4) * (isSmallScreen ? 0.05 : 0.1)),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(isSmallScreen ? 0.4 : 0.6),
                      blurRadius: isSmallScreen ? 8 : 12,
                      spreadRadius: isSmallScreen ? 1 : 2,
                    ),
                  ],
                ),
                child: Text(
                  letter,
                  style: GoogleFonts.orbitron(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: color,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _digitalGlitchAnimation(String letter, Color color, bool isSmallScreen, bool isMediumScreen) {
    final fontSize = isSmallScreen ? 28.0 : (isMediumScreen ? 36.0 : 48.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: isSmallScreen ? 1100 : 1600),
      builder: (context, value, child) {
        final glitch = value > 0.4 && value < 0.6 ? 1.0 : 0.0;
        return Semantics(
          label: 'Letter $letter with digital glitch animation',
          child: Transform.translate(
            offset: Offset(
              sin(value * pi * 20) * (isSmallScreen ? 1 : 2) * glitch,
              cos(value * pi * 25) * (isSmallScreen ? 0.5 : 1) * glitch,
            ),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: (isSmallScreen ? 7 : 10) + (glitch * (isSmallScreen ? 10 : 15)),
                    spreadRadius: 1,
                  ),
                  if (glitch > 0)
                    BoxShadow(
                      color: Colors.cyan.withOpacity(0.3),
                      blurRadius: isSmallScreen ? 3 : 5,
                      offset: Offset(isSmallScreen ? -1 : -2, 0),
                    ),
                  if (glitch > 0)
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: isSmallScreen ? 3 : 5,
                      offset: Offset(isSmallScreen ? 1 : 2, 0),
                    ),
                ],
              ),
              child: Text(
                letter,
                style: GoogleFonts.orbitron(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color: color,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildParticlesBackground() {
    return MediaQuery.of(context).accessibleNavigation || 
           MediaQuery.of(context).disableAnimations
        ? const SizedBox.shrink() // Hide particles for accessibility
        : Positioned.fill(
            child: ExcludeSemantics(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final particleCount = constraints.maxWidth < 600 ? 8 : 15;
                  return Stack(
                    children: List.generate(particleCount, (index) {
                      return Positioned(
                        left: (index * 50.0) % (constraints.maxWidth > 300 ? 300 : constraints.maxWidth),
                        top: (index * 30.0) % 200,
                        child: _buildFloatingParticle(index, constraints.maxWidth < 600),
                      );
                    }),
                  );
                },
              ),
            ),
          );
  }
  
  Widget _buildFloatingParticle(int index, bool isSmallScreen) {
    final colors = [
      const Color(0xFF00D4FF),
      const Color(0xFF39FF14),
      const Color(0xFFFF1493),
      const Color(0xFFFFD700),
      const Color(0xFFFF4500),
      const Color(0xFF9932CC),
    ];
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: (isSmallScreen ? 2000 : 3000) + (index * 200)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            sin(value * pi * 2 + index) * (isSmallScreen ? 12 : 20),
            cos(value * pi * 2 + index) * (isSmallScreen ? 8 : 15),
          ),
          child: Opacity(
            opacity: (isSmallScreen ? 0.2 : 0.3) + (sin(value * pi * 3) * 0.2),
            child: Container(
              width: isSmallScreen ? 4 : 6,
              height: isSmallScreen ? 4 : 6,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors[index % colors.length].withOpacity(isSmallScreen ? 0.3 : 0.5),
                    blurRadius: isSmallScreen ? 4 : 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildGamingStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.1),
            Colors.black.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MyDscvrColors.dubaiTeal.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('⚡', 'INSTANT', 'RESULTS'),
          _buildStatItem('🎯', 'AI-POWERED', 'SEARCH'),
          _buildStatItem('🚀', 'SUPER', 'SPEED'),
        ],
      ),
    ).animate().fadeIn(delay: 2800.ms).slideY(begin: 0.5);
  }
  
  Widget _buildStatItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: MyDscvrColors.dubaiTeal,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 8,
            fontWeight: FontWeight.w400,
            color: MyDscvrColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSearchBar() {
    return AnimatedBuilder(
      animation: _searchBarController,
      builder: (context, child) {
        return Container(
          height: 60,
          decoration: BoxDecoration(
            // Gaming-style gradient background
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1a1a2e),
                const Color(0xFF16213e),
                const Color(0xFF0f3460),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
              // Animated neon glow effect when focused
              if (_searchBarController.value > 0)
                BoxShadow(
                  color: const Color(0xFF00D4FF).withOpacity(0.6 * _searchBarController.value),
                  blurRadius: 25,
                  spreadRadius: 2,
                  offset: const Offset(0, 0),
                ),
              if (_searchBarController.value > 0)
                BoxShadow(
                  color: const Color(0xFF39FF14).withOpacity(0.4 * _searchBarController.value),
                  blurRadius: 35,
                  spreadRadius: 1,
                  offset: const Offset(0, 0),
                ),
            ],
          ),
          child: Stack(
            children: [
              // Animated border glow
              if (_searchBarController.value > 0)
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00D4FF).withOpacity(0.5 * _searchBarController.value),
                        const Color(0xFF39FF14).withOpacity(0.5 * _searchBarController.value),
                        const Color(0xFFFF1493).withOpacity(0.5 * _searchBarController.value),
                        const Color(0xFFFFD700).withOpacity(0.5 * _searchBarController.value),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              // Search input
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1a1a2e),
                        const Color(0xFF16213e),
                        const Color(0xFF0f3460),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: Semantics(
                    label: 'Search for events, venues, and activities in Dubai',
                    hint: 'Enter your search terms and press search or enter',
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search events, venues, activities...',
                        hintStyle: GoogleFonts.orbitron(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(12),
                          child: GestureDetector(
                            onTap: _showResults ? () {
                              setState(() {
                                _showResults = false;
                                _searchController.clear();
                                ref.read(searchQueryProvider.notifier).state = '';
                              });
                            } : null,
                            child: Semantics(
                              label: _showResults ? 'Go back to search' : 'Search',
                              button: true,
                              child: _buildAnimatedSearchIcon(),
                            ),
                          ),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? Semantics(
                                label: 'Clear search',
                                button: true,
                                child: IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    ref.read(searchQueryProvider.notifier).state = '';
                                  },
                                  icon: Icon(
                                    LucideIcons.x,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 20,
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(12),
                                child: Semantics(
                                  label: 'Voice search',
                                  button: true,
                                  child: _buildAnimatedMicIcon(),
                                ),
                              ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      onChanged: (value) {
                        ref.read(searchQueryProvider.notifier).state = value;
                        setState(() {}); // Trigger rebuild for suffix icon
                      },
                      onSubmitted: (value) {
                        _performSearch(value);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).animate().slideY(begin: 0.5, duration: 600.ms);
  }
  
  Widget _buildAnimatedSearchIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(0.6),
                blurRadius: 8 + (sin(value * pi * 4) * 4),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            _showResults ? LucideIcons.arrowLeft : LucideIcons.search,
            color: const Color(0xFF00D4FF),
            size: 24,
          ),
        );
      },
    );
  }
  
  Widget _buildAnimatedMicIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 3),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + (sin(value * pi * 2) * 0.1),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF39FF14).withOpacity(0.4),
                  blurRadius: 6 + (sin(value * pi * 6) * 3),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              LucideIcons.mic,
              color: const Color(0xFF39FF14),
              size: 20,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildQuickFilters() {
    final quickFilters = [
      FilterChip(emoji: '🎪', label: 'Events', color: MyDscvrColors.dubaiCoral),
      FilterChip(emoji: '🏢', label: 'Venues', color: MyDscvrColors.dubaiTeal),
      FilterChip(emoji: '🎨', label: 'Activities', color: MyDscvrColors.dubaiPurple),
      FilterChip(emoji: '🍕', label: 'Food', color: MyDscvrColors.dubaiGold),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Filters',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: MyDscvrColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        AnimationLimiter(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: quickFilters.asMap().entries.map((entry) {
              final index = entry.key;
              final filter = entry.value;
              
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 600),
                child: SlideAnimation(
                  verticalOffset: 50,
                  child: FadeInAnimation(
                    child: _buildFilterChip(filter),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFilterChip(FilterChip filter) {
    return InkWell(
      onTap: () => _onFilterTap(filter.label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              filter.color.withOpacity(0.1),
              filter.color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: filter.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filter.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              filter.label,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: filter.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchSuggestions() {
    final suggestions = [
      'Kids workshops this weekend',
      'Indoor activities near me',
      'Family brunch spots',
      'Art classes for children',
      'Outdoor adventures Dubai',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Searches',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: MyDscvrColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        AnimationLimiter(
          child: Column(
            children: suggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final suggestion = entry.value;
              
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 600),
                child: SlideAnimation(
                  horizontalOffset: 50,
                  child: FadeInAnimation(
                    child: _buildSuggestionTile(suggestion),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSuggestionTile(String suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _performSearch(suggestion),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.trendingUp,
                color: MyDscvrColors.dubaiTeal,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  suggestion,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: MyDscvrColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                LucideIcons.arrowUpRight,
                color: MyDscvrColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTrendingSearches() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: MyDscvrColors.oceanGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MyDscvrColors.dubaiTeal.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.flame,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Trending Now',
                style: GoogleFonts.comfortaa(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Summer camp registrations are heating up! Find the perfect camp for your little ones.',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _performSearch('summer camps'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: MyDscvrColors.dubaiTeal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Explore Summer Camps',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 800.ms);
  }
  
  Widget _buildSearchResults() {
    if (_isLoading) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(MyDscvrColors.dubaiTeal),
              ),
              const SizedBox(height: 16),
              Text(
                'Searching events...',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: MyDscvrColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: MyDscvrColors.dubaiCoral,
            ),
            const SizedBox(height: 16),
            Text(
              'Search Error',
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: MyDscvrColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: MyDscvrColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_searchController.text.trim().isNotEmpty) {
                  _performSearch(_searchController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyDscvrColors.dubaiTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    if (_searchResult == null || _searchResult!.events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              LucideIcons.searchX,
              size: 48,
              color: MyDscvrColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Events Found',
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: MyDscvrColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords or explore our popular searches below.',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: MyDscvrColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showResults = false;
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyDscvrColors.dubaiTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Browse Popular Searches',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    final result = _searchResult!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search metadata
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${result.total} results found',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MyDscvrColors.textPrimary,
                ),
              ),
              if (result.metadata.totalProcessingTimeMs > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: MyDscvrColors.dubaiTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${result.metadata.totalProcessingTimeMs}ms',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: MyDscvrColors.dubaiTeal,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Results list
        ...result.events.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: EventCard(
                    event: event,
                    onTap: () {
                      context.go('/event/${event.id}');
                    },
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

// Supporting Classes
class FilterChip {
  final String emoji;
  final String label;
  final Color color;
  
  const FilterChip({
    required this.emoji,
    required this.label,
    required this.color,
  });
}

class AdvancedFiltersModal extends StatelessWidget {
  const AdvancedFiltersModal({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Filter content would go here
          Expanded(
            child: Center(
              child: Text(
                'Advanced Filters Coming Soon!',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  color: MyDscvrColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1.0, duration: 300.ms);
  }
}