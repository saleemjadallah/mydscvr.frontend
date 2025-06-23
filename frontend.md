# DXB Events Flutter Frontend - Development Checklist

## Project Overview
Build a vibrant, family-friendly Flutter web application for the Dubai Events Intelligence Platform featuring modern design techniques, playful animations, and an intuitive user experience optimized for busy Dubai families discovering events for their children.

## Design Philosophy
- **Visual Style**: Modern, playful, family-oriented with Dubai vibes
- **Typography**: Fun, readable fonts with personality
- **Color Palette**: Vibrant Dubai-inspired colors (gold, teal, coral, purple gradients)
- **Animations**: Smooth, delightful micro-interactions throughout
- **Layout**: Curved elements, bubble effects, soft shadows, rounded corners
- **Icons**: Lucide icons + custom colorful SVG illustrations

## Backend Integration Context
- **Backend Tech Stack**: Python + FastAPI + MongoDB
- **API Base URL**: `https://api.dxbevents.com`
- **Authentication**: JWT tokens with refresh mechanism
- **Data Format**: JSON responses with family-centric event data

---

## PHASE 1: Project Setup & Architecture (Week 1)

### 1.1 Flutter Project Initialization
- [ ] Create new Flutter project:
  ```bash
  flutter create dxb_events_web --platforms web
  cd dxb_events_web
  flutter config --enable-web
  ```
- [ ] Update `pubspec.yaml` with target Flutter 3.24+
- [ ] Configure web-specific settings in `web/index.html`
- [ ] Set up folder structure:
  ```
  lib/
  ├── core/
  │   ├── constants/
  │   ├── themes/
  │   ├── utils/
  │   └── widgets/
  ├── features/
  │   ├── auth/
  │   ├── events/
  │   ├── search/
  │   ├── profile/
  │   └── home/
  ├── services/
  │   ├── api/
  │   ├── storage/
  │   └── navigation/
  └── main.dart
  ```

### 1.2 Dependencies Installation
- [ ] Add core dependencies to `pubspec.yaml`:
  ```yaml
  dependencies:
    flutter: ^3.24.0
    
    # State Management
    flutter_riverpod: ^2.4.0
    
    # Navigation
    go_router: ^12.0.0
    
    # HTTP & API
    dio: ^5.3.0
    retrofit: ^4.0.0
    
    # Local Storage
    shared_preferences: ^2.2.0
    flutter_secure_storage: ^9.0.0
    
    # UI & Animations
    animate_do: ^3.1.2
    lottie: ^2.7.0
    flutter_animate: ^4.2.0
    shimmer: ^3.0.0
    
    # Icons & SVG
    lucide_icons: ^0.288.0
    flutter_svg: ^2.0.7
    
    # Fonts
    google_fonts: ^6.1.0
    
    # Maps
    google_maps_flutter_web: ^0.5.4
    
    # Date/Time
    intl: ^0.18.1
    
    # Image handling
    cached_network_image: ^3.3.0
    
    # Responsive design
    responsive_framework: ^1.1.1
  
  dev_dependencies:
    build_runner: ^2.4.7
    retrofit_generator: ^8.0.0
    json_annotation: ^4.8.1
    json_serializable: ^6.7.1
  ```

### 1.3 Theme & Design System Setup
- [ ] Create Dubai-inspired color palette:
  ```dart
  // core/constants/app_colors.dart
  class AppColors {
    // Primary Dubai Colors
    static const Color dubaiGold = Color(0xFFD4AF37);
    static const Color dubaiTeal = Color(0xFF17A2B8);
    static const Color dubaiCoral = Color(0xFFFF6B6B);
    static const Color dubaiPurple = Color(0xFF6C5CE7);
    
    // Gradients
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
    
    // Neutral Colors
    static const Color backgroundLight = Color(0xFFF8FAFC);
    static const Color cardBackground = Colors.white;
    static const Color textPrimary = Color(0xFF2D3748);
    static const Color textSecondary = Color(0xFF718096);
  }
  ```

- [ ] Set up fun typography:
  ```dart
  // core/themes/app_typography.dart
  class AppTypography {
    static TextTheme get textTheme => TextTheme(
      // Headlines - Playful and bold
      displayLarge: GoogleFonts.comfortaa(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      
      // Body Text - Readable and friendly
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      
      // Labels - Fun and accessible
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
  ```

- [ ] Create theme configuration:
  ```dart
  // core/themes/app_theme.dart
  class AppTheme {
    static ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.dubaiTeal,
        brightness: Brightness.light,
      ),
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      
      // Custom component themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dubaiTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 8,
          shadowColor: AppColors.dubaiTeal.withOpacity(0.3),
        ),
      ),
      
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 12,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
  ```

### 1.4 Custom Widget Library
- [ ] Create bubble decorations:
  ```dart
  // core/widgets/bubble_decoration.dart
  class BubbleDecoration extends StatelessWidget {
    final Widget child;
    final Color? bubbleColor;
    final double borderRadius;
    final List<BoxShadow>? shadows;
    
    const BubbleDecoration({
      Key? key,
      required this.child,
      this.bubbleColor,
      this.borderRadius = 20,
      this.shadows,
    }) : super(key: key);
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Column(
          children: [
            // Search header
            _buildSearchHeader(),
            
            // Animated filters
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _showFilters ? _buildFiltersSection() : const SizedBox(),
            ),
            
            // Search results
            Expanded(
              child: _buildSearchResults(),
            ),
          ],
        ),
      );
    }
    
    Widget _buildSearchHeader() {
      return Container(
        decoration: const BoxDecoration(
          gradient: AppColors.oceanGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search events, venues, activities...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            prefixIcon: Icon(LucideIcons.search),
                          ),
                          onChanged: (value) => _performSearch(value),
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleFilters,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: _showFilters 
                                ? AppColors.sunsetGradient 
                                : AppColors.oceanGradient,
                            borderRadius: BorderRadius.circular(21),
                          ),
                          child: Icon(
                            LucideIcons.sliders,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().slideInUp(),
                
                const SizedBox(height: 16),
                
                // Popular searches
                _buildPopularSearches(),
              ],
            ),
          ),
        ),
      );
    }
    
    Widget _buildPopularSearches() {
      final popularSearches = [
        'Beach Activities',
        'Indoor Fun',
        'Art & Crafts',
        'Sports',
        'Educational',
      ];
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Searches',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: popularSearches.map((search) => 
              GestureDetector(
                onTap: () => _searchController.text = search,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    search,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ).animate().fadeIn(
                delay: Duration(milliseconds: popularSearches.indexOf(search) * 100),
              ),
            ).toList(),
          ),
        ],
      );
    }
    
    Widget _buildFiltersSection() {
      return BubbleDecoration(
        borderRadius: 0,
        bubbleColor: AppColors.backgroundLight,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filters',
                style: GoogleFonts.comfortaa(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              // Age group filter
              _buildFilterGroup(
                title: 'Age Group',
                options: ['0-2 years', '3-5 years', '6-12 years', '13+ years'],
                icon: LucideIcons.users,
              ),
              
              const SizedBox(height: 16),
              
              // Price range filter
              _buildFilterGroup(
                title: 'Price Range',
                options: ['Free', 'Under AED 50', 'AED 50-100', 'AED 100+'],
                icon: LucideIcons.dollarSign,
              ),
              
              const SizedBox(height: 16),
              
              // Location filter
              _buildFilterGroup(
                title: 'Location',
                options: ['Dubai Marina', 'JBR', 'Downtown', 'DIFC', 'Business Bay'],
                icon: LucideIcons.mapPin,
              ),
              
              const SizedBox(height: 16),
              
              // Date filter
              _buildFilterGroup(
                title: 'When',
                options: ['Today', 'Tomorrow', 'This Weekend', 'Next Week'],
                icon: LucideIcons.calendar,
              ),
            ],
          ),
        ),
      ).animate().slideInDown();
    }
    
    Widget _buildFilterGroup({
      required String title,
      required List<String> options,
      required IconData icon,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.dubaiTeal),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) => 
              FilterChip(
                label: Text(option),
                onSelected: (selected) => _updateFilter(title, option, selected),
                backgroundColor: Colors.white,
                selectedColor: AppColors.dubaiTeal.withOpacity(0.2),
                side: BorderSide(color: AppColors.dubaiTeal.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ).toList(),
          ),
        ],
      );
    }
    
    Widget _buildSearchResults() {
      final searchQuery = ref.watch(searchQueryProvider);
      
      if (searchQuery.isEmpty) {
        return _buildEmptySearchState();
      }
      
      final searchResults = ref.watch(searchResultsProvider(searchQuery));
      
      return searchResults.when(
        data: (results) => _buildResultsList(results),
        loading: () => _buildSearchLoading(),
        error: (error, stack) => _buildSearchError(),
      );
    }
    
    Widget _buildEmptySearchState() {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                gradient: AppColors.sunsetGradient.scale(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.search,
                size: 60,
                color: AppColors.dubaiTeal,
              ),
            ).animate().scale(),
            
            const SizedBox(height: 24),
            
            Text(
              'Discover Amazing Events',
              style: GoogleFonts.comfortaa(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeInUp(delay: 200.ms),
            
            const SizedBox(height: 8),
            
            Text(
              'Search for family-friendly activities\nand events in Dubai',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ).animate().fadeInUp(delay: 400.ms),
            
            const SizedBox(height: 32),
            
            // Suggested categories
            _buildSuggestedCategories(),
          ],
        ),
      );
    }
    
    Widget _buildSuggestedCategories() {
      final categories = [
        CategoryData('🏖️', 'Beach Fun', AppColors.dubaiTeal),
        CategoryData('🎨', 'Arts & Crafts', AppColors.dubaiCoral),
        CategoryData('⚽', 'Sports', AppColors.dubaiGold),
        CategoryData('🎭', 'Entertainment', AppColors.dubaiPurple),
      ];
      
      return Column(
        children: [
          Text(
            'Browse Categories',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: categories.map((category) => 
              GestureDetector(
                onTap: () => _searchController.text = category.name,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: category.color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ).animate().scale(
                delay: Duration(milliseconds: categories.indexOf(category) * 100),
              ),
            ).toList(),
          ),
        ],
      );
    }
    
    void _toggleFilters() {
      setState(() {
        _showFilters = !_showFilters;
      });
      
      if (_showFilters) {
        _filterAnimationController.forward();
      } else {
        _filterAnimationController.reverse();
      }
    }
    
    void _performSearch(String query) {
      ref.read(searchQueryProvider.notifier).state = query;
    }
    
    void _updateFilter(String category, String option, bool selected) {
      // Implement filter logic
    }
  }
  
  class CategoryData {
    final String emoji;
    final String name;
    final Color color;
    
    const CategoryData(this.emoji, this.name, this.color);
  }
  ```

---

## PHASE 6: Authentication & Profile (Week 6)

### 6.1 Animated Login Screen
- [ ] Create welcoming login experience:
  ```dart
  // features/auth/login_screen.dart
  class LoginScreen extends ConsumerStatefulWidget {
    const LoginScreen({Key? key}) : super(key: key);
    
    @override
    ConsumerState<LoginScreen> createState() => _LoginScreenState();
  }
  
  class _LoginScreenState extends ConsumerState<LoginScreen>
      with TickerProviderStateMixin {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    
    late AnimationController _animationController;
    late Animation<double> _fadeAnimation;
    late Animation<Offset> _slideAnimation;
    
    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
      
      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ));
      
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ));
      
      _animationController.forward();
    }
    
    @override
    void dispose() {
      _emailController.dispose();
      _passwordController.dispose();
      _animationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      final authState = ref.watch(authProvider);
      
      return Scaffold(
        body: Stack(
          children: [
            // Background with floating bubbles
            _buildAnimatedBackground(),
            
            // Login form
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo and welcome text
                            _buildWelcomeSection(),
                            
                            const SizedBox(height: 40),
                            
                            // Login form
                            _buildLoginForm(authState),
                            
                            const SizedBox(height: 24),
                            
                            // Social login options
                            _buildSocialLoginSection(),
                            
                            const SizedBox(height: 24),
                            
                            // Sign up link
                            _buildSignUpLink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    Widget _buildAnimatedBackground() {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: Stack(
          children: List.generate(8, (index) => 
            Positioned(
              top: Random().nextDouble() * MediaQuery.of(context).size.height,
              left: Random().nextDouble() * MediaQuery.of(context).size.width,
              child: FloatingBubble(
                size: 30 + Random().nextDouble() * 60,
                color: AppColors.dubaiTeal.withOpacity(0.1),
              ).animate().scale(
                delay: Duration(milliseconds: index * 300),
                duration: const Duration(seconds: 3),
              ).then().moveY(
                begin: 0,
                end: -100,
                duration: const Duration(seconds: 6),
                curve: Curves.easeInOut,
              ),
            ),
          ),
        ),
      );
    }
    
    Widget _buildWelcomeSection() {
      return Column(
        children: [
          // App logo with animation
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.oceanGradient,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dubaiTeal.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.calendar,
              size: 40,
              color: Colors.white,
            ),
          ).animate().scale(delay: 300.ms),
          
          const SizedBox(height: 24),
          
          Text(
            'Welcome to DXB Events! 🎉',
            style: GoogleFonts.comfortaa(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeInUp(delay: 500.ms),
          
          const SizedBox(height: 8),
          
          Text(
            'Discover amazing family events\nin Dubai just for you',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeInUp(delay: 700.ms),
        ],
      );
    }
    
    Widget _buildLoginForm(AuthState authState) {
      return BubbleDecoration(
        borderRadius: 24,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Email field
                _buildCustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: LucideIcons.mail,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4} Container(
        decoration: BoxDecoration(
          color: bubbleColor ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: shadows ?? [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: child,
      );
    }
  }
  ```

- [ ] Create animated curved containers:
  ```dart
  // core/widgets/curved_container.dart
  class CurvedContainer extends StatelessWidget {
    final Widget child;
    final Gradient? gradient;
    final Color? backgroundColor;
    final double curveHeight;
    final CurvePosition curvePosition;
    
    @override
    Widget build(BuildContext context) {
      return CustomPaint(
        painter: CurvePainter(
          gradient: gradient,
          backgroundColor: backgroundColor,
          curveHeight: curveHeight,
          curvePosition: curvePosition,
        ),
        child: child,
      );
    }
  }
  
  class CurvePainter extends CustomPainter {
    final Gradient? gradient;
    final Color? backgroundColor;
    final double curveHeight;
    final CurvePosition curvePosition;
    
    CurvePainter({
      this.gradient,
      this.backgroundColor,
      required this.curveHeight,
      required this.curvePosition,
    });
    
    @override
    void paint(Canvas canvas, Size size) {
      final paint = Paint();
      
      if (gradient != null) {
        paint.shader = gradient!.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        );
      } else {
        paint.color = backgroundColor ?? Colors.blue;
      }
      
      final path = Path();
      
      switch (curvePosition) {
        case CurvePosition.top:
          path.moveTo(0, curveHeight);
          path.quadraticBezierTo(
            size.width / 2, 0, 
            size.width, curveHeight
          );
          path.lineTo(size.width, size.height);
          path.lineTo(0, size.height);
          break;
          
        case CurvePosition.bottom:
          path.moveTo(0, 0);
          path.lineTo(size.width, 0);
          path.lineTo(size.width, size.height - curveHeight);
          path.quadraticBezierTo(
            size.width / 2, size.height,
            0, size.height - curveHeight
          );
          break;
      }
      
      path.close();
      canvas.drawPath(path, paint);
    }
    
    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
  }
  
  enum CurvePosition { top, bottom }
  ```

---

## PHASE 2: Navigation & Routing (Week 2)

### 2.1 Go Router Configuration
- [ ] Set up app routing:
  ```dart
  // services/navigation/app_router.dart
  final GoRouter appRouter = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/events',
        name: 'events',
        builder: (context, state) => const EventsScreen(),
        routes: [
          GoRoute(
            path: '/details/:eventId',
            name: 'event-details',
            builder: (context, state) => EventDetailsScreen(
              eventId: state.pathParameters['eventId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
        redirect: (context, state) {
          // Redirect to login if not authenticated
          final container = ProviderContainer();
          final isLoggedIn = container.read(authProvider).isAuthenticated;
          return isLoggedIn ? null : '/login';
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
  ```

### 2.2 Responsive Navigation Bar
- [ ] Create animated bottom navigation:
  ```dart
  // core/widgets/animated_bottom_nav.dart
  class AnimatedBottomNav extends StatefulWidget {
    final int currentIndex;
    final Function(int) onTap;
    
    const AnimatedBottomNav({
      Key? key,
      required this.currentIndex,
      required this.onTap,
    }) : super(key: key);
    
    @override
    State<AnimatedBottomNav> createState() => _AnimatedBottomNavState();
  }
  
  class _AnimatedBottomNavState extends State<AnimatedBottomNav> {
    @override
    Widget build(BuildContext context) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, LucideIcons.home, 'Home'),
            _buildNavItem(1, LucideIcons.calendar, 'Events'),
            _buildNavItem(2, LucideIcons.search, 'Search'),
            _buildNavItem(3, LucideIcons.user, 'Profile'),
          ],
        ),
      );
    }
    
    Widget _buildNavItem(int index, IconData icon, String label) {
      final isSelected = widget.currentIndex == index;
      return GestureDetector(
        onTap: () => widget.onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.dubaiTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(
        duration: const Duration(milliseconds: 150),
        curve: Curves.elasticOut,
      );
    }
  }
  ```

### 2.3 App Bar with Animations
- [ ] Create dynamic app bar:
  ```dart
  // core/widgets/dubai_app_bar.dart
  class DubaiAppBar extends StatelessWidget implements PreferredSizeWidget {
    final String title;
    final List<Widget>? actions;
    final bool showBackButton;
    final VoidCallback? onBackPressed;
    
    const DubaiAppBar({
      Key? key,
      required this.title,
      this.actions,
      this.showBackButton = false,
      this.onBackPressed,
    }) : super(key: key);
    
    @override
    Widget build(BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          gradient: AppColors.oceanGradient,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.dubaiTeal.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                if (showBackButton)
                  GestureDetector(
                    onTap: onBackPressed ?? () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.arrowLeft,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ).animate().fadeInLeft(),
                
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.comfortaa(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: showBackButton ? TextAlign.center : TextAlign.left,
                  ).animate().fadeInUp(),
                ),
                
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      );
    }
    
    @override
    Size get preferredSize => const Size.fromHeight(100);
  }
  ```

---

## PHASE 3: API Integration & State Management (Week 3)

### 3.1 Riverpod State Management Setup
- [ ] Create API client with Dio:
  ```dart
  // services/api/api_client.dart
  @RestApi(baseUrl: "https://api.dxbevents.com")
  abstract class ApiClient {
    factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;
    
    // Auth endpoints
    @POST("/api/auth/login")
    Future<AuthResponse> login(@Body() LoginRequest request);
    
    @POST("/api/auth/register")
    Future<AuthResponse> register(@Body() RegisterRequest request);
    
    @GET("/api/auth/me")
    Future<UserProfile> getCurrentUser();
    
    // Events endpoints
    @GET("/api/events")
    Future<EventsResponse> getEvents({
      @Query("category") String? category,
      @Query("location") String? location,
      @Query("date") String? date,
      @Query("price_max") int? priceMax,
      @Query("age_group") String? ageGroup,
      @Query("page") int page = 1,
    });
    
    @GET("/api/events/{id}")
    Future<EventDetail> getEventById(@Path("id") String eventId);
    
    @POST("/api/events/{id}/save")
    Future<void> saveEvent(@Path("id") String eventId);
    
    // Search endpoints
    @GET("/api/search")
    Future<SearchResponse> searchEvents({
      @Query("q") required String query,
      @Query("filters") Map<String, dynamic>? filters,
    });
  }
  ```

- [ ] Create data models:
  ```dart
  // models/event.dart
  @JsonSerializable()
  class Event {
    final String id;
    final String title;
    final String description;
    final String aiSummary;
    final DateTime startDate;
    final DateTime? endDate;
    final Venue venue;
    final Pricing pricing;
    final FamilySuitability familySuitability;
    final List<String> categories;
    final List<String> imageUrls;
    final bool isSaved;
    final int familyScore;
    
    const Event({
      required this.id,
      required this.title,
      required this.description,
      required this.aiSummary,
      required this.startDate,
      this.endDate,
      required this.venue,
      required this.pricing,
      required this.familySuitability,
      required this.categories,
      required this.imageUrls,
      this.isSaved = false,
      required this.familyScore,
    });
    
    factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
    Map<String, dynamic> toJson() => _$EventToJson(this);
  }
  
  @JsonSerializable()
  class Venue {
    final String name;
    final String address;
    final String area;
    final double? latitude;
    final double? longitude;
    final List<String> amenities;
    
    const Venue({
      required this.name,
      required this.address,
      required this.area,
      this.latitude,
      this.longitude,
      required this.amenities,
    });
    
    factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);
    Map<String, dynamic> toJson() => _$VenueToJson(this);
  }
  ```

- [ ] Set up providers:
  ```dart
  // services/providers/events_provider.dart
  final apiClientProvider = Provider<ApiClient>((ref) {
    final dio = Dio();
    // Add interceptors for auth, logging, etc.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors globally
          handler.next(error);
        },
      ),
    );
    return ApiClient(dio);
  });
  
  final eventsProvider = FutureProvider.family<EventsResponse, EventsFilter>(
    (ref, filter) async {
      final apiClient = ref.read(apiClientProvider);
      return await apiClient.getEvents(
        category: filter.category,
        location: filter.location,
        date: filter.date,
        priceMax: filter.priceMax,
        ageGroup: filter.ageGroup,
        page: filter.page,
      );
    },
  );
  
  final savedEventsProvider = StateNotifierProvider<SavedEventsNotifier, Set<String>>(
    (ref) => SavedEventsNotifier(),
  );
  
  class SavedEventsNotifier extends StateNotifier<Set<String>> {
    SavedEventsNotifier() : super(<String>{});
    
    void toggleSaveEvent(String eventId) {
      if (state.contains(eventId)) {
        state = {...state}..remove(eventId);
      } else {
        state = {...state, eventId};
      }
    }
  }
  ```

### 3.2 Authentication State
- [ ] Create auth provider:
  ```dart
  // services/providers/auth_provider.dart
  class AuthState {
    final bool isAuthenticated;
    final bool isLoading;
    final UserProfile? user;
    final String? error;
    
    const AuthState({
      this.isAuthenticated = false,
      this.isLoading = false,
      this.user,
      this.error,
    });
    
    AuthState copyWith({
      bool? isAuthenticated,
      bool? isLoading,
      UserProfile? user,
      String? error,
    }) {
      return AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading: isLoading ?? this.isLoading,
        user: user ?? this.user,
        error: error ?? this.error,
      );
    }
  }
  
  class AuthNotifier extends StateNotifier<AuthState> {
    final ApiClient _apiClient;
    final FlutterSecureStorage _storage;
    
    AuthNotifier(this._apiClient, this._storage) : super(const AuthState());
    
    Future<void> login(String email, String password) async {
      state = state.copyWith(isLoading: true, error: null);
      try {
        final response = await _apiClient.login(
          LoginRequest(email: email, password: password),
        );
        await _storage.write(key: 'access_token', value: response.accessToken);
        await _storage.write(key: 'refresh_token', value: response.refreshToken);
        
        final user = await _apiClient.getCurrentUser();
        state = AuthState(isAuthenticated: true, user: user);
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
    
    Future<void> logout() async {
      await _storage.deleteAll();
      state = const AuthState();
    }
  }
  
  final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
    final apiClient = ref.read(apiClientProvider);
    const storage = FlutterSecureStorage();
    return AuthNotifier(apiClient, storage);
  });
  ```

---

## PHASE 4: Home Screen & Event Discovery (Week 4)

### 4.1 Animated Home Screen
- [ ] Create engaging home screen:
  ```dart
  // features/home/home_screen.dart
  class HomeScreen extends ConsumerStatefulWidget {
    const HomeScreen({Key? key}) : super(key: key);
    
    @override
    ConsumerState<HomeScreen> createState() => _HomeScreenState();
  }
  
  class _HomeScreenState extends ConsumerState<HomeScreen>
      with TickerProviderStateMixin {
    late AnimationController _headerAnimationController;
    late AnimationController _cardsAnimationController;
    
    @override
    void initState() {
      super.initState();
      _headerAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );
      _cardsAnimationController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      
      // Start animations
      _headerAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _cardsAnimationController.forward();
      });
    }
    
    @override
    void dispose() {
      _headerAnimationController.dispose();
      _cardsAnimationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildAnimatedHeader(),
            _buildQuickFilters(),
            _buildFeaturedEvents(),
            _buildTrendingEvents(),
            _buildCategoriesGrid(),
          ],
        ),
      );
    }
    
    Widget _buildAnimatedHeader() {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          decoration: const BoxDecoration(
            gradient: AppColors.sunsetGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Stack(
            children: [
              // Floating bubbles background
              ...List.generate(6, (index) => 
                Positioned(
                  top: Random().nextDouble() * 200,
                  left: Random().nextDouble() * 300,
                  child: FloatingBubble(
                    size: 20 + Random().nextDouble() * 40,
                    color: Colors.white.withOpacity(0.1),
                  ).animate().scale(
                    delay: Duration(milliseconds: index * 200),
                    duration: const Duration(seconds: 2),
                  ).then().moveY(
                    begin: 0,
                    end: -50,
                    duration: const Duration(seconds: 4),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
              
              // Main header content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello Dubai Families! 👋',
                                style: GoogleFonts.comfortaa(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ).animate().fadeInLeft(),
                              const SizedBox(height: 8),
                              Text(
                                'Discover amazing family events',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ).animate().fadeInLeft(delay: 200.ms),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              LucideIcons.bell,
                              color: Colors.white,
                              size: 24,
                            ),
                          ).animate().scale(delay: 400.ms),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Search bar
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search family events...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppColors.oceanGradient,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: const Icon(
                                LucideIcons.search,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ).animate().slideInUp(delay: 600.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
  
  // Floating bubble widget
  class FloatingBubble extends StatelessWidget {
    final double size;
    final Color color;
    
    const FloatingBubble({
      Key? key,
      required this.size,
      required this.color,
    }) : super(key: key);
    
    @override
    Widget build(BuildContext context) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
    }
  }
  ```

### 4.2 Quick Filters Component
- [ ] Create animated filter chips:
  ```dart
  // features/home/widgets/quick_filters.dart
  class QuickFilters extends StatefulWidget {
    final Function(String) onFilterSelected;
    
    const QuickFilters({Key? key, required this.onFilterSelected}) : super(key: key);
    
    @override
    State<QuickFilters> createState() => _QuickFiltersState();
  }
  
  class _QuickFiltersState extends State<QuickFilters> {
    String? selectedFilter;
    
    @override
    Widget build(BuildContext context) {
      final filters = [
        FilterData(label: 'Today', icon: LucideIcons.calendar),
        FilterData(label: 'Free Events', icon: LucideIcons.gift),
        FilterData(label: 'Indoor', icon: LucideIcons.home),
        FilterData(label: 'Outdoor', icon: LucideIcons.sun),
        FilterData(label: 'Kids 0-5', icon: LucideIcons.baby),
        FilterData(label: 'Kids 6-12', icon: LucideIcons.users),
      ];
      
      return SliverToBoxAdapter(
        child: Container(
          height: 80,
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AnimatedFilterChip(
                  filter: filters[index],
                  isSelected: selectedFilter == filters[index].label,
                  onTap: () {
                    setState(() {
                      selectedFilter = selectedFilter == filters[index].label 
                          ? null 
                          : filters[index].label;
                    });
                    widget.onFilterSelected(filters[index].label);
                  },
                ).animate().slideInLeft(
                  delay: Duration(milliseconds: index * 100),
                ),
              );
            },
          ),
        ),
      );
    }
  }
  
  class FilterData {
    final String label;
    final IconData icon;
    
    const FilterData({required this.label, required this.icon});
  }
  
  class AnimatedFilterChip extends StatefulWidget {
    final FilterData filter;
    final bool isSelected;
    final VoidCallback onTap;
    
    const AnimatedFilterChip({
      Key? key,
      required this.filter,
      required this.isSelected,
      required this.onTap,
    }) : super(key: key);
    
    @override
    State<AnimatedFilterChip> createState() => _AnimatedFilterChipState();
  }
  
  class _AnimatedFilterChipState extends State<AnimatedFilterChip> {
    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: widget.isSelected 
                ? AppColors.oceanGradient
                : LinearGradient(
                    colors: [
                      AppColors.dubaiTeal.withOpacity(0.1),
                      AppColors.dubaiPurple.withOpacity(0.1),
                    ],
                  ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: widget.isSelected 
                  ? Colors.transparent
                  : AppColors.dubaiTeal.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: widget.isSelected ? [
              BoxShadow(
                color: AppColors.dubaiTeal.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.filter.icon,
                size: 16,
                color: widget.isSelected ? Colors.white : AppColors.dubaiTeal,
              ),
              const SizedBox(width: 8),
              Text(
                widget.filter.label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.isSelected ? Colors.white : AppColors.dubaiTeal,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
  ```

### 4.3 Event Cards with Animations
- [ ] Create stunning event cards:
  ```dart
  // features/events/widgets/event_card.dart
  class EventCard extends ConsumerStatefulWidget {
    final Event event;
    final VoidCallback? onTap;
    final VoidCallback? onSave;
    
    const EventCard({
      Key? key,
      required this.event,
      this.onTap,
      this.onSave,
    }) : super(key: key);
    
    @override
    ConsumerState<EventCard> createState() => _EventCardState();
  }
  
  class _EventCardState extends ConsumerState<EventCard> 
      with SingleTickerProviderStateMixin {
    late AnimationController _animationController;
    late Animation<double> _scaleAnimation;
    
    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 0.95,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
    }
    
    @override
    void dispose() {
      _animationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      final savedEvents = ref.watch(savedEventsProvider);
      final isSaved = savedEvents.contains(widget.event.id);
      
      return GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: BubbleDecoration(
              borderRadius: 24,
              shadows: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
              child: Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event image with gradient overlay
                    Stack(
                      children: [
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            image: widget.event.imageUrls.isNotEmpty
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      widget.event.imageUrls.first,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            gradient: widget.event.imageUrls.isEmpty
                                ? AppColors.sunsetGradient
                                : null,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Save button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {
                              ref.read(savedEventsProvider.notifier)
                                  .toggleSaveEvent(widget.event.id);
                              widget.onSave?.call();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isSaved ? LucideIcons.heart : LucideIcons.heart,
                                size: 16,
                                color: isSaved ? AppColors.dubaiCoral : AppColors.textSecondary,
                              ),
                            ),
                          ).animate().scale(
                            duration: const Duration(milliseconds: 200),
                          ),
                        ),
                        
                        // Family score badge
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getScoreColor(widget.event.familyScore),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.star,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.event.familyScore}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Event details
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Event title
                          Text(
                            widget.event.title,
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // AI Summary
                          Text(
                            widget.event.aiSummary,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Event metadata
                          Row(
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 14,
                                color: AppColors.dubaiTeal,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM dd').format(widget.event.startDate),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.dubaiTeal,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                LucideIcons.mapPin,
                                size: 14,
                                color: AppColors.dubaiCoral,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.event.venue.area,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.dubaiCoral,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Price and age range
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.dubaiGold.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.event.pricing.minPrice == 0
                                      ? 'FREE'
                                      : 'AED ${widget.event.pricing.minPrice}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.dubaiGold,
                                  ),
                                ),
                              ),
                              
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.dubaiPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${widget.event.familySuitability.ageMin}-${widget.event.familySuitability.ageMax} yrs',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.dubaiPurple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    Color _getScoreColor(int score) {
      if (score >= 80) return AppColors.dubaiTeal;
      if (score >= 60) return AppColors.dubaiGold;
      return AppColors.dubaiCoral;
    }
  }
  ```

### 4.4 Featured Events Section
- [ ] Create featured events carousel:
  ```dart
  // features/home/widgets/featured_events.dart
  class FeaturedEventsSection extends ConsumerWidget {
    const FeaturedEventsSection({Key? key}) : super(key: key);
    
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final eventsAsyncValue = ref.watch(eventsProvider(
        EventsFilter(featured: true, limit: 5),
      ));
      
      return SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '✨ Featured Events',
                    style: GoogleFonts.comfortaa(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeInLeft(),
                  
                  TextButton(
                    onPressed: () => context.pushNamed('events'),
                    child: Text(
                      'See All',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dubaiTeal,
                      ),
                    ),
                  ).animate().fadeInRight(),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              height: 360,
              child: eventsAsyncValue.when(
                data: (eventsResponse) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: eventsResponse.events.length,
                  itemBuilder: (context, index) {
                    final event = eventsResponse.events[index];
                    return EventCard(
                      event: event,
                      onTap: () => context.pushNamed(
                        'event-details',
                        pathParameters: {'eventId': event.id},
                      ),
                    ).animate().slideInLeft(
                      delay: Duration(milliseconds: index * 150),
                    );
                  },
                ),
                loading: () => _buildShimmerLoading(),
                error: (error, stack) => _buildErrorWidget(error),
              ),
            ),
          ],
        ),
      );
    }
    
    Widget _buildShimmerLoading() {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        itemBuilder: (context, index) => Container(
          width: 280,
          margin: const EdgeInsets.only(right: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      );
    }
    
    Widget _buildErrorWidget(Object error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: AppColors.dubaiCoral,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
  }
  ```

---

## PHASE 5: Event Details & Search (Week 5)

### 5.1 Event Details Screen
- [ ] Create immersive event details:
  ```dart
  // features/events/event_details_screen.dart
  class EventDetailsScreen extends ConsumerStatefulWidget {
    final String eventId;
    
    const EventDetailsScreen({Key? key, required this.eventId}) : super(key: key);
    
    @override
    ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
  }
  
  class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen>
      with TickerProviderStateMixin {
    late AnimationController _animationController;
    late Animation<double> _fadeAnimation;
    late Animation<Offset> _slideAnimation;
    
    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );
      
      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ));
      
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ));
      
      _animationController.forward();
    }
    
    @override
    void dispose() {
      _animationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      final eventAsyncValue = ref.watch(eventDetailsProvider(widget.eventId));
      
      return Scaffold(
        body: eventAsyncValue.when(
          data: (event) => _buildEventDetails(event),
          loading: () => _buildLoadingScreen(),
          error: (error, stack) => _buildErrorScreen(),
        ),
      );
    }
    
    Widget _buildEventDetails(Event event) {
      return CustomScrollView(
        slivers: [
          // Hero image section
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () => context.pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(LucideIcons.share),
                  onPressed: () => _shareEvent(event),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Event image
                  Container(
                    decoration: BoxDecoration(
                      image: event.imageUrls.isNotEmpty
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(
                                event.imageUrls.first,
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                      gradient: event.imageUrls.isEmpty
                          ? AppColors.sunsetGradient
                          : null,
                    ),
                  ),
                  
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  
                  // Floating event info
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: BubbleDecoration(
                          bubbleColor: Colors.white.withOpacity(0.9),
                          borderRadius: 20,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: GoogleFonts.comfortaa(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      LucideIcons.star,
                                      size: 16,
                                      color: _getScoreColor(event.familyScore),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${event.familyScore} Family Score',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _getScoreColor(event.familyScore),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Event content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick info cards
                    _buildQuickInfoSection(event),
                    
                    const SizedBox(height: 24),
                    
                    // AI Summary
                    _buildAISummarySection(event),
                    
                    const SizedBox(height: 24),
                    
                    // Full description
                    _buildDescriptionSection(event),
                    
                    const SizedBox(height: 24),
                    
                    // Venue information
                    _buildVenueSection(event),
                    
                    const SizedBox(height: 24),
                    
                    // Family suitability
                    _buildFamilySuitabilitySection(event),
                    
                    const SizedBox(height: 100), // Space for floating button
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    Widget _buildQuickInfoSection(Event event) {
      return Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              icon: LucideIcons.calendar,
              title: 'Date',
              value: DateFormat('MMM dd, yyyy').format(event.startDate),
              color: AppColors.dubaiTeal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              icon: LucideIcons.clock,
              title: 'Time',
              value: DateFormat('HH:mm').format(event.startDate),
              color: AppColors.dubaiCoral,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              icon: LucideIcons.dollarSign,
              title: 'Price',
              value: event.pricing.minPrice == 0 
                  ? 'FREE' 
                  : 'AED ${event.pricing.minPrice}',
              color: AppColors.dubaiGold,
            ),
          ),
        ],
      );
    }
    
    Widget _buildInfoCard({
      required IconData icon,
      required String title,
      required String value,
      required Color color,
    }) {
      return BubbleDecoration(
        borderRadius: 16,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    // Additional methods for other sections...
    Color _getScoreColor(int score) {
      if (score >= 80) return AppColors.dubaiTeal;
      if (score >= 60) return AppColors.dubaiGold;
      return AppColors.dubaiCoral;
    }
    
    void _shareEvent(Event event) {
      // Implement sharing functionality
    }
  }
  ```

### 5.2 Search Screen with Smart Filters
- [ ] Create advanced search interface:
  ```dart
  // features/search/search_screen.dart
  class SearchScreen extends ConsumerStatefulWidget {
    const SearchScreen({Key? key}) : super(key: key);
    
    @override
    ConsumerState<SearchScreen> createState() => _SearchScreenState();
  }
  
  class _SearchScreenState extends ConsumerState<SearchScreen>
      with TickerProviderStateMixin {
    final TextEditingController _searchController = TextEditingController();
    late AnimationController _filterAnimationController;
    bool _showFilters = false;
    
    @override
    void initState() {
      super.initState();
    _filterAnimationController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
    }
    
    @override
    void dispose() {
      _searchController.dispose();
      _filterAnimationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return).hasMatch(value!)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Password field
                _buildCustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: LucideIcons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your password';
                    }
                    if (value!.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 8),
                
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Implement forgot password
                    },
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.dubaiTeal,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dubaiTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.dubaiTeal.withOpacity(0.3),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                
                if (authState.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dubaiCoral.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.dubaiCoral.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.alertCircle,
                          size: 16,
                          color: AppColors.dubaiCoral,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.dubaiCoral,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    
    Widget _buildCustomTextField({
      required TextEditingController controller,
      required String label,
      required IconData icon,
      bool isPassword = false,
      String? Function(String?)? validator,
    }) {
      return TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.dubaiTeal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.dubaiTeal, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
        ),
      );
    }
    
    void _handleLogin() async {
      if (_formKey.currentState?.validate() ?? false) {
        await ref.read(authProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );
        
        if (mounted && ref.read(authProvider).isAuthenticated) {
          context.goNamed('home');
        }
      }
    }
  }
  ```

### 6.2 Family Profile Management
- [ ] Create comprehensive profile screen:
  ```dart
  // features/profile/profile_screen.dart
  class ProfileScreen extends ConsumerStatefulWidget {
    const ProfileScreen({Key? key}) : super(key: key);
    
    @override
    ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
  }
  
  class _ProfileScreenState extends ConsumerState<ProfileScreen>
      with TickerProviderStateMixin {
    late TabController _tabController;
    
    @override
    void initState() {
      super.initState();
      _tabController = TabController(length: 3, vsync: this);
    }
    
    @override
    void dispose() {
      _tabController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      final authState = ref.watch(authProvider);
      
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            // Profile header
            _buildProfileHeader(authState.user),
            
            // Tab bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.dubaiTeal,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.dubaiTeal,
                  tabs: const [
                    Tab(text: 'Family'),
                    Tab(text: 'Preferences'),
                    Tab(text: 'Saved'),
                  ],
                ),
              ),
            ),
            
            // Tab content
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFamilyTab(),
                  _buildPreferencesTab(),
                  _buildSavedEventsTab(),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    Widget _buildProfileHeader(UserProfile? user) {
      return SliverToBoxAdapter(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.oceanGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile picture and info
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                            style: GoogleFonts.comfortaa(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.dubaiTeal,
                            ),
                          ),
                        ),
                      ).animate().scale(),
                      
                      const SizedBox(width: 20),
                      
                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Dubai Family',
                              style: GoogleFonts.comfortaa(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ).animate().fadeInLeft(),
                            
                            const SizedBox(height: 4),
                            
                            Text(
                              user?.email ?? 'user@example.com',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ).animate().fadeInLeft(delay: 200.ms),
                            
                            const SizedBox(height: 8),
                            
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.dubaiGold,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Premium Member',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ).animate().fadeInLeft(delay: 400.ms),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('Events Attended', '42', LucideIcons.calendar),
                      _buildStatCard('Events Saved', '18', LucideIcons.heart),
                      _buildStatCard('Family Score', '95', LucideIcons.star),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    Widget _buildStatCard(String title, String value, IconData icon) {
      return BubbleDecoration(
        bubbleColor: Colors.white.withOpacity(0.9),
        borderRadius: 16,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: AppColors.dubaiTeal, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.comfortaa(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ).animate().scale(delay: 600.ms);
    }
  }
  
  // Sticky tab bar delegate
  class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
    final TabBar tabBar;
    
    _StickyTabBarDelegate(this.tabBar);
    
    @override
    double get minExtent => tabBar.preferredSize.height;
    
    @override
    double get maxExtent => tabBar.preferredSize.height;
    
    @override
    Widget build(context, double shrinkOffset, bool overlapsContent) {
      return Container(
        color: Colors.white,
        child: tabBar,
      );
    }
    
    @override
    bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
  }
  
  class _SocialLoginSection extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Or continue with',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                icon: 'assets/icons/google.svg',
                label: 'Google',
                onTap: () => _handleGoogleLogin(),
              ),
              _buildSocialButton(
                icon: 'assets/icons/apple.svg',
                label: 'Apple',
                onTap: () => _handleAppleLogin(),
              ),
              _buildSocialButton(
                icon: 'assets/icons/facebook.svg',
                label: 'Facebook',
                onTap: () => _handleFacebookLogin(),
              ),
            ],
          ),
        ],
      );
    }
    
    Widget _buildSocialButton({
      required String icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: BubbleDecoration(
          borderRadius: 16,
          child: Container(
            width: 80,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SvgPicture.asset(icon, width: 24, height: 24),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().scale(delay: 200.ms);
    }
    
    void _handleGoogleLogin() {
      // Implement Google login
    }
    
    void _handleAppleLogin() {
      // Implement Apple login
    }
    
    void _handleFacebookLogin() {
      // Implement Facebook login
    }
  }
  ```

### 6.3 Welcome/Onboarding Screens
- [ ] Create engaging welcome flow:
  ```dart
  // features/auth/welcome_screen.dart
  class WelcomeScreen extends StatefulWidget {
    const WelcomeScreen({Key? key}) : super(key: key);
    
    @override
    State<WelcomeScreen> createState() => _WelcomeScreenState();
  }
  
  class _WelcomeScreenState extends State<WelcomeScreen>
      with TickerProviderStateMixin {
    late PageController _pageController;
    late AnimationController _animationController;
    int _currentPage = 0;
    
    final List<OnboardingData> _pages = [
      OnboardingData(
        title: 'Discover Amazing\nFamily Events! 🎉',
        description: 'Find the perfect activities for your family in Dubai with our AI-powered recommendations',
        imagePath: 'assets/illustrations/family_fun.svg',
        primaryColor: AppColors.dubaiTeal,
        secondaryColor: AppColors.dubaiCoral,
      ),
      OnboardingData(
        title: 'Smart Family\nRecommendations 🤖',
        description: 'Our AI learns your family\'s preferences to suggest events that everyone will love',
        imagePath: 'assets/illustrations/ai_recommendations.svg',
        primaryColor: AppColors.dubaiPurple,
        secondaryColor: AppColors.dubaiGold,
      ),
      OnboardingData(
        title: 'Never Miss\nThe Fun! ⏰',
        description: 'Get personalized notifications for events that match your schedule and interests',
        imagePath: 'assets/illustrations/notifications.svg',
        primaryColor: AppColors.dubaiGold,
        secondaryColor: AppColors.dubaiTeal,
      ),
    ];
    
    @override
    void initState() {
      super.initState();
      _pageController = PageController();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      _animationController.forward();
    }
    
    @override
    void dispose() {
      _pageController.dispose();
      _animationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Stack(
          children: [
            // Background with floating bubbles
            _buildAnimatedBackground(),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Skip button
                  _buildSkipButton(),
                  
                  // Page view
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _pages.length,
                      itemBuilder: (context, index) => _buildOnboardingPage(_pages[index]),
                    ),
                  ),
                  
                  // Bottom section
                  _buildBottomSection(),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    Widget _buildAnimatedBackground() {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _pages[_currentPage].primaryColor.withOpacity(0.1),
              _pages[_currentPage].secondaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Stack(
          children: List.generate(10, (index) => 
            Positioned(
              top: Random().nextDouble() * MediaQuery.of(context).size.height,
              left: Random().nextDouble() * MediaQuery.of(context).size.width,
              child: FloatingBubble(
                size: 20 + Random().nextDouble() * 60,
                color: _pages[_currentPage].primaryColor.withOpacity(0.1),
              ).animate().scale(
                delay: Duration(milliseconds: index * 200),
                duration: const Duration(seconds: 2),
              ).then().moveY(
                begin: 0,
                end: -100,
                duration: const Duration(seconds: 8),
                curve: Curves.easeInOut,
              ),
            ),
          ),
        ),
      );
    }
    
    Widget _buildSkipButton() {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.topRight,
          child: TextButton(
            onPressed: () => _skipToLogin(),
            child: Text(
              'Skip',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ).animate().fadeInRight();
    }
    
    Widget _buildOnboardingPage(OnboardingData data) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              height: 300,
              child: SvgPicture.asset(
                data.imagePath,
                height: 300,
                fit: BoxFit.contain,
              ),
            ).animate().scale(
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
            ),
            
            const SizedBox(height: 60),
            
            // Title
            Text(
              data.title,
              style: GoogleFonts.comfortaa(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeInUp(delay: 300.ms),
            
            const SizedBox(height: 20),
            
            // Description
            Text(
              data.description,
              style: GoogleFonts.inter(
                fontSize: 18,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeInUp(delay: 500.ms),
          ],
        ),
      );
    }
    
    Widget _buildBottomSection() {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index 
                        ? _pages[_currentPage].primaryColor
                        : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Action buttons
            Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _previousPage(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        side: BorderSide(
                          color: _pages[_currentPage].primaryColor,
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _pages[_currentPage].primaryColor,
                        ),
                      ),
                    ),
                  ),
                
                if (_currentPage > 0) const SizedBox(width: 16),
                
                Expanded(
                  flex: _currentPage == 0 ? 1 : 2,
                  child: PulsingButton(
                    pulseColor: _pages[_currentPage].primaryColor,
                    onPressed: () => _nextPage(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _pages[_currentPage].primaryColor,
                            _pages[_currentPage].secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: Text(
                          _currentPage == _pages.length - 1 ? 'Get Started! 🚀' : 'Next',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    void _nextPage() {
      if (_currentPage < _pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _goToLogin();
      }
    }
    
    void _previousPage() {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    
    void _skipToLogin() {
      context.pushReplacementNamed('login');
    }
    
    void _goToLogin() {
      context.pushReplacementNamed('login');
    }
  }
  
  class OnboardingData {
    final String title;
    final String description;
    final String imagePath;
    final Color primaryColor;
    final Color secondaryColor;
    
    const OnboardingData({
      required this.title,
      required this.description,
      required this.imagePath,
      required this.primaryColor,
      required this.secondaryColor,
    });
  }
  ```

### 6.4 Registration Screen
- [ ] Create family-focused registration:
  ```dart
  // features/auth/register_screen.dart
  class RegisterScreen extends ConsumerStatefulWidget {
    const RegisterScreen({Key? key}) : super(key: key);
    
    @override
    ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
  }
  
  class _RegisterScreenState extends ConsumerState<RegisterScreen>
      with TickerProviderStateMixin {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    
    late AnimationController _animationController;
    int _currentStep = 0;
    
    final List<String> _steps = [
      'Personal Info',
      'Family Details',
      'Preferences',
    ];
    
    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      _animationController.forward();
    }
    
    @override
    void dispose() {
      _nameController.dispose();
      _emailController.dispose();
      _passwordController.dispose();
      _confirmPasswordController.dispose();
      _animationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF8FAFC),
                    Color(0xFFE2E8F0),
                  ],
                ),
              ),
            ),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Header with back button
                  _buildHeader(),
                  
                  // Progress indicator
                  _buildProgressIndicator(),
                  
                  // Step content
                  Expanded(
                    child: _buildStepContent(),
                  ),
                  
                  // Navigation buttons
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    Widget _buildHeader() {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.arrowLeft,
                  size: 20,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Account',
                    style: GoogleFonts.comfortaa(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Step ${_currentStep + 1} of ${_steps.length}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeInDown();
    }
    
    Widget _buildProgressIndicator() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          children: List.generate(_steps.length, (index) {
            final isActive = index <= _currentStep;
            final isCompleted = index < _currentStep;
            
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < _steps.length - 1 ? 8 : 0),
                decoration: BoxDecoration(
                  color: isActive 
                      ? AppColors.dubaiTeal 
                      : Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: isCompleted
                    ? Container(
                        decoration: BoxDecoration(
                          color: AppColors.dubaiTeal,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    : null,
              ),
            );
          }),
        ),
      ).animate().slideInLeft(delay: 200.ms);
    }
    
    Widget _buildStepContent() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _getStepWidget(_currentStep),
        ),
      );
    }
    
    Widget _getStepWidget(int step) {
      switch (step) {
        case 0:
          return _buildPersonalInfoStep();
        case 1:
          return _buildFamilyDetailsStep();
        case 2:
          return _buildPreferencesStep();
        default:
          return _buildPersonalInfoStep();
      }
    }
    
    Widget _buildPersonalInfoStep() {
      return BubbleDecoration(
        key: const ValueKey('personal_info'),
        borderRadius: 24,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tell us about yourself 👋',
                  style: GoogleFonts.comfortaa(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'We\'ll use this to personalize your experience',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Name field
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: LucideIcons.user,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Email field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}

### 7.1 Advanced Animation Components
- [ ] Create reusable animation widgets:
  ```dart
  // core/widgets/animated_widgets.dart
  class FadeInSlideUp extends StatefulWidget {
    final Widget child;
    final Duration delay;
    final Duration duration;
    
    const FadeInSlideUp({
      Key? key,
      required this.child,
      this.delay = Duration.zero,
      this.duration = const Duration(milliseconds: 600),
    }) : super(key: key);
    
    @override
    State<FadeInSlideUp> createState() => _FadeInSlideUpState();
  }
  
  class _FadeInSlideUpState extends State<FadeInSlideUp>
      with SingleTickerProviderStateMixin {
    late AnimationController _controller;
    late Animation<double> _opacity;
    late Animation<Offset> _position;
    
    @override
    void initState() {
      super.initState();
      _controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      );
      
      _opacity = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));
      
      _position = Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ));
      
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
    
    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => FadeTransition(
          opacity: _opacity,
          child: SlideTransition(
            position: _position,
            child: widget.child,
          ),
        ),
      );
    }
  }
  
  class PulsingButton extends StatefulWidget {
    final Widget child;
    final VoidCallback? onPressed;
    final Color? pulseColor;
    
    const PulsingButton({
      Key? key,
      required this.child,
      this.onPressed,
      this.pulseColor,
    }) : super(key: key);
    
    @override
    State<PulsingButton> createState() => _PulsingButtonState();
  }
  
  class _PulsingButtonState extends State<PulsingButton>
      with SingleTickerProviderStateMixin {
    late AnimationController _controller;
    late Animation<double> _scaleAnimation;
    
    @override
    void initState() {
      super.initState();
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
      
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 1.1,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      
      _controller.repeat(reverse: true);
    }
    
    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: (widget.pulseColor ?? AppColors.dubaiTeal).withOpacity(0.3),
                    blurRadius: 20 * _scaleAnimation.value,
                    spreadRadius: 5 * (_scaleAnimation.value - 1),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      );
    }
  }
  
  class ShimmerLoading extends StatefulWidget {
    final Widget child;
    final bool isLoading;
    
    const ShimmerLoading({
      Key? key,
      required this.child,
      required this.isLoading,
    }) : super(key: key);
    
    @override
    State<ShimmerLoading> createState() => _ShimmerLoadingState();
  }
  
  class _ShimmerLoadingState extends State<ShimmerLoading>
      with SingleTickerProviderStateMixin {
    late AnimationController _controller;
    
    @override
    void initState() {
      super.initState();
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
      
      if (widget.isLoading) {
        _controller.repeat();
      }
    }
    
    @override
    void didUpdateWidget(ShimmerLoading oldWidget) {
      super.didUpdateWidget(oldWidget);
      if (widget.isLoading != oldWidget.isLoading) {
        if (widget.isLoading) {
          _controller.repeat();
        } else {
          _controller.stop();
        }
      }
    }
    
    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      if (!widget.isLoading) {
        return widget.child;
      }
      
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: widget.child,
      );
    }
  }
  ```

### 7.2 Performance Optimizations
- [ ] Implement efficient list rendering:
  ```dart
  // core/widgets/optimized_list_view.dart
  class OptimizedEventsList extends StatefulWidget {
    final List<Event> events;
    final VoidCallback? onLoadMore;
    final bool hasMore;
    final bool isLoading;
    
    const OptimizedEventsList({
      Key? key,
      required this.events,
      this.onLoadMore,
      this.hasMore = false,
      this.isLoading = false,
    }) : super(key: key);
    
    @override
    State<OptimizedEventsList> createState() => _OptimizedEventsListState();
  }
  
  class _OptimizedEventsListState extends State<OptimizedEventsList> {
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
          _scrollController.position.maxScrollExtent * 0.8) {
        if (widget.hasMore && !widget.isLoading) {
          widget.onLoadMore?.call();
        }
      }
    }
    
    @override
    Widget build(BuildContext context) {
      return ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: widget.events.length + (widget.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= widget.events.length) {
            return _buildLoadingItem();
          }
          
          final event = widget.events[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EventCard(
              event: event,
              onTap: () => context.pushNamed(
                'event-details',
                pathParameters: {'eventId': event.id},
              ),
            ).animate().fadeIn(
              delay: Duration(milliseconds: index * 50),
            ),
          );
        },
      );
    }
    
    Widget _buildLoadingItem() {
      return Container(
        height: 200,
        margin: const EdgeInsets.only(bottom: 16),
        child: const ShimmerLoading(
          isLoading: true,
          child: BubbleDecoration(
            child: SizedBox.expand(),
          ),
        ),
      );
    }
  }
  ```

### 7.3 Image Optimization
- [ ] Create optimized image widgets:
  ```dart
  // core/widgets/optimized_image.dart
  class OptimizedNetworkImage extends StatelessWidget {
    final String imageUrl;
    final double? width;
    final double? height;
    final BoxFit fit;
    final BorderRadius? borderRadius;
    
    const OptimizedNetworkImage({
      Key? key,
      required this.imageUrl,
      this.width,
      this.height,
      this.fit = BoxFit.cover,
      this.borderRadius,
    }) : super(key: key);
    
    @override
    Widget build(BuildContext context) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: AppColors.sunsetGradient.scale(0.3),
              borderRadius: borderRadius,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: borderRadius,
            ),
            child: const Icon(
              LucideIcons.image,
              color: Colors.grey,
              size: 40,
            ),
          ),
          memCacheWidth: width?.toInt(),
          memCacheHeight: height?.toInt(),
        ),
      );
    }
  }
  ```

---

## PHASE 8: Testing & Deployment (Week 8)

### 8.1 Widget Testing
- [ ] Create comprehensive tests:
  ```dart
  // test/widgets/event_card_test.dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:dxb_events_web/features/events/widgets/event_card.dart';
  
  void main() {
    group('EventCard Widget Tests', () {
      late Event testEvent;
      
      setUp(() {
        testEvent = Event(
          id: 'test-1',
          title: 'Test Family Event',
          description: 'A great test event for families',
          aiSummary: 'Fun family activity',
          startDate: DateTime.now(),
          venue: const Venue(
            name: 'Test Venue',
            address: 'Test Address',
            area: 'Dubai Marina',
            amenities: [],
          ),
          pricing: const Pricing(minPrice: 0, maxPrice: 100, currency: 'AED'),
          familySuitability: const FamilySuitability(
            ageMin: 0,
            ageMax: 12,
            familyFriendly: true,
          ),
          categories: ['outdoor', 'family'],
          imageUrls: [],
          familyScore: 85,
        );
      });
      
      testWidgets('should display event title', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: EventCard(event: testEvent),
              ),
            ),
          ),
        );
        
        expect(find.text('Test Family Event'), findsOneWidget);
      });
      
      testWidgets('should display family score', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: EventCard(event: testEvent),
              ),
            ),
          ),
        );
        
        expect(find.text('85'), findsOneWidget);
      });
      
      testWidgets('should trigger onTap callback', (WidgetTester tester) async {
        bool tapped = false;
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: EventCard(
                  event: testEvent,
                  onTap: () => tapped = true,
                ),
              ),
            ),
          ),
        );
        
        await tester.tap(find.byType(EventCard));
        expect(tapped, isTrue);
      });
    });
  }
  ```

### 8.2 Integration Testing
- [ ] Create end-to-end tests:
  ```dart
  // integration_test/app_test.dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:integration_test/integration_test.dart';
  import 'package:dxb_events_web/main.dart' as app;
  
  void main() {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    
    group('DXB Events App Integration Tests', () {
      testWidgets('complete user flow test', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        
        // Test home screen loads
        expect(find.text('Hello Dubai Families! 👋'), findsOneWidget);
        
        // Test search functionality
        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();
        
        await tester.enterText(
          find.byType(TextField),
          'family events',
        );
        await tester.pumpAndSettle();
        
        // Test navigation to event details
        if (find.byType(EventCard).evaluate().isNotEmpty) {
          await tester.tap(find.byType(EventCard).first);
          await tester.pumpAndSettle();
          
          // Verify event details screen
          expect(find.byType(EventDetailsScreen), findsOneWidget);
        }
      });
      
      testWidgets('login flow test', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        
        // Navigate to profile (should redirect to login)
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();
        
        // Should be on login screen
        expect(find.text('Welcome to DXB Events! 🎉'), findsOneWidget);
        
        // Test form validation
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();
        
        expect(find.text('Please enter your email'), findsOneWidget);
      });
    });
  }
  ```

### 8.3 Performance Testing
- [ ] Create performance monitoring:
  ```dart
  // test/performance/performance_test.dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  
  void main() {
    group('Performance Tests', () {
      testWidgets('event list scrolling performance', (WidgetTester tester) async {
        // Create mock events list
        final events = List.generate(100, (index) => createMockEvent(index));
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: OptimizedEventsList(events: events),
              ),
            ),
          ),
        );
        
        // Measure frame rendering time
        await tester.binding.watchPerformance(() async {
          // Scroll through the list
          await tester.fling(
            find.byType(ListView),
            const Offset(0, -500),
            1000,
          );
          await tester.pumpAndSettle();
        }, reportKey: 'event_list_scroll');
      });
      
      testWidgets('animation performance test', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: HomeScreen(),
          ),
        );
        
        await tester.binding.watchPerformance(() async {
          // Trigger animations
          await tester.pumpAndSettle();
        }, reportKey: 'home_screen_animations');
      });
    });
  }
  ```

### 8.4 Build Configuration
- [ ] Set up build scripts:
  ```yaml
  # build_runner.yaml
  targets:
    $default:
      builders:
        json_serializable:
          options:
            explicit_to_json: true
            field_rename: snake_case
  ```

- [ ] Create deployment script:
  ```bash
  #!/bin/bash
  # scripts/deploy.sh
  
  echo "🚀 Building DXB Events Web App..."
  
  # Clean previous builds
  flutter clean
  flutter pub get
  
  # Generate code
  flutter packages pub run build_runner build --delete-conflicting-outputs
  
  # Build for web
  flutter build web --release --web-renderer html
  
  # Optimize assets
  echo "📦 Optimizing assets..."
  # Add asset optimization commands here
  
  echo "✅ Build completed successfully!"
  echo "📁 Build files are in: build/web/"
  ```

### 8.5 Environment Configuration
- [ ] Set up environment configs:
  ```dart
  // lib/core/config/environment.dart
  class Environment {
    static const String apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.dxbevents.com',
    );
    
    static const String googleMapsApiKey = String.fromEnvironment(
      'GOOGLE_MAPS_API_KEY',
      defaultValue: '',
    );
    
    static const bool isProduction = bool.fromEnvironment(
      'PRODUCTION',
      defaultValue: false,
    );
    
    static const bool enableAnalytics = bool.fromEnvironment(
      'ENABLE_ANALYTICS',
      defaultValue: false,
    );
  }
  ```

---

## Success Criteria Checklist

### Design & UX Goals
- [ ] Implement vibrant Dubai-inspired color scheme with gradients
- [ ] Create smooth animations throughout the app (60fps)
- [ ] Achieve playful, family-friendly design with curves and bubbles
- [ ] Implement comprehensive dark/light theme support
- [ ] Ensure responsive design works on all screen sizes
- [ ] Use fun typography (Comfortaa, Nunito, Inter, Poppins)

### Performance Goals
- [ ] Achieve <3 second initial load time
- [ ] Maintain 60fps during animations and scrolling
- [ ] Implement efficient image caching and lazy loading
- [ ] Keep bundle size under 2MB (gzipped)
- [ ] Achieve 90+ Lighthouse performance score

### Functionality Goals
- [ ] Complete event discovery and search functionality
- [ ] Working authentication and profile management
- [ ] Functional family preference system
- [ ] Save/unsave events functionality
- [ ] Advanced filtering and search capabilities
- [ ] Integration with backend API (FastAPI/MongoDB)

### Mobile Preparation Goals
- [ ] Responsive design that works on mobile browsers
- [ ] Touch-optimized interactions
- [ ] Progressive Web App (PWA) capabilities
- [ ] Offline-first architecture preparation
- [ ] Mobile-specific animations and gestures

---

## Cost Estimation

### Development Dependencies (One-time)
- [ ] **Design Assets**: $200-500 (icons, illustrations, stock photos)
- [ ] **Font Licenses**: $0 (Google Fonts)
- [ ] **Development Tools**: $50-100/month (IDE extensions, testing tools)

### Hosting & Infrastructure (Monthly)
- [ ] **Web Hosting**: $20-50 (Netlify/Vercel Pro)
- [ ] **CDN**: $10-30 (image and asset delivery)
- [ ] **Analytics**: $0-50 (Google Analytics + Mixpanel)
- [ ] **Error Tracking**: $0-25 (Sentry free tier)

**Total Estimated Monthly Cost: $30-155 USD**

---

## Future Mobile App Considerations

### Architecture Decisions for Mobile
- [ ] Shared state management system (Riverpod works across platforms)
- [ ] Reusable UI components with platform adaptations
- [ ] Shared API client and data models
- [ ] Consistent navigation patterns

### Mobile-Specific Features to Prepare
- [ ] Push notifications infrastructure
- [ ] Offline data synchronization
- [ ] Device-specific permissions (location, camera)
- [ ] Platform-specific UI adaptations (iOS/Android)

### Code Reusability Strategy
- [ ] 80%+ shared business logic
- [ ] Shared core widgets with platform variants
- [ ] Unified theming system
- [ ] Common animation framework

## Next Steps After Completion

### Immediate Next Phase
- [ ] Deploy web app to staging environment
- [ ] Connect to live FastAPI backend
- [ ] User acceptance testing with Dubai families
- [ ] Performance optimization based on real usage

### Mobile App Development
- [ ] Create iOS/Android projects sharing core codebase
- [ ] Implement mobile-specific features
- [ ] App Store and Google Play Store preparation
- [ ] Mobile app beta testing

### Analytics & Optimization
- [ ] Implement comprehensive event tracking
- [ ] A/B testing framework for UI improvements
- [ ] User behavior analysis and optimization
- [ ] Performance monitoring and optimization

This comprehensive Flutter web development checklist ensures a beautiful, performant, and family-friendly application that serves as the perfect foundation for Dubai's premier family events platform. The modern design techniques, smooth animations, and Dubai-inspired aesthetic will create an engaging experience that busy Dubai families will love to use for discovering their next family adventure! Container(
        decoration: BoxDecoration(
          color: bubbleColor ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: shadows ?? [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: child,
      );
    }
  }
  ```

- [ ] Create animated curved containers:
  ```dart
  // core/widgets/curved_container.dart
  class CurvedContainer extends StatelessWidget {
    final Widget child;
    final Gradient? gradient;
    final Color? backgroundColor;
    final double curveHeight;
    final CurvePosition curvePosition;
    
    @override
    Widget build(BuildContext context) {
      return CustomPaint(
        painter: CurvePainter(
          gradient: gradient,
          backgroundColor: backgroundColor,
          curveHeight: curveHeight,
          curvePosition: curvePosition,
        ),
        child: child,
      );
    }
  }
  
  class CurvePainter extends CustomPainter {
    final Gradient? gradient;
    final Color? backgroundColor;
    final double curveHeight;
    final CurvePosition curvePosition;
    
    CurvePainter({
      this.gradient,
      this.backgroundColor,
      required this.curveHeight,
      required this.curvePosition,
    });
    
    @override
    void paint(Canvas canvas, Size size) {
      final paint = Paint();
      
      if (gradient != null) {
        paint.shader = gradient!.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        );
      } else {
        paint.color = backgroundColor ?? Colors.blue;
      }
      
      final path = Path();
      
      switch (curvePosition) {
        case CurvePosition.top:
          path.moveTo(0, curveHeight);
          path.quadraticBezierTo(
            size.width / 2, 0, 
            size.width, curveHeight
          );
          path.lineTo(size.width, size.height);
          path.lineTo(0, size.height);
          break;
          
        case CurvePosition.bottom:
          path.moveTo(0, 0);
          path.lineTo(size.width, 0);
          path.lineTo(size.width, size.height - curveHeight);
          path.quadraticBezierTo(
            size.width / 2, size.height,
            0, size.height - curveHeight
          );
          break;
      }
      
      path.close();
      canvas.drawPath(path, paint);
    }
    
    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
  }
  
  enum CurvePosition { top, bottom }
  ```

---

## PHASE 2: Navigation & Routing (Week 2)

### 2.1 Go Router Configuration
- [ ] Set up app routing:
  ```dart
  // services/navigation/app_router.dart
  final GoRouter appRouter = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/events',
        name: 'events',
        builder: (context, state) => const EventsScreen(),
        routes: [
          GoRoute(
            path: '/details/:eventId',
            name: 'event-details',
            builder: (context, state) => EventDetailsScreen(
              eventId: state.pathParameters['eventId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
        redirect: (context, state) {
          // Redirect to login if not authenticated
          final container = ProviderContainer();
          final isLoggedIn = container.read(authProvider).isAuthenticated;
          return isLoggedIn ? null : '/login';
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
  ```

### 2.2 Responsive Navigation Bar
- [ ] Create animated bottom navigation:
  ```dart
  // core/widgets/animated_bottom_nav.dart
  class AnimatedBottomNav extends StatefulWidget {
    final int currentIndex;
    final Function(int) onTap;
    
    const AnimatedBottomNav({
      Key? key,
      required this.currentIndex,
      required this.onTap,
    }) : super(key: key);
    
    @override
    State<AnimatedBottomNav> createState() => _AnimatedBottomNavState();
  }
  
  class _AnimatedBottomNavState extends State<AnimatedBottomNav> {
    @override
    Widget build(BuildContext context) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, LucideIcons.home, 'Home'),
            _buildNavItem(1, LucideIcons.calendar, 'Events'),
            _buildNavItem(2, LucideIcons.search, 'Search'),
            _buildNavItem(3, LucideIcons.user, 'Profile'),
          ],
        ),
      );
    }
    
    Widget _buildNavItem(int index, IconData icon, String label) {
      final isSelected = widget.currentIndex == index;
      return GestureDetector(
        onTap: () => widget.onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.dubaiTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(
        duration: const Duration(milliseconds: 150),
        curve: Curves.elasticOut,
      );
    }
  }
  ```

### 2.3 App Bar with Animations
- [ ] Create dynamic app bar:
  ```dart
  // core/widgets/dubai_app_bar.dart
  class DubaiAppBar extends StatelessWidget implements PreferredSizeWidget {
    final String title;
    final List<Widget>? actions;
    final bool showBackButton;
    final VoidCallback? onBackPressed;
    
    const DubaiAppBar({
      Key? key,
      required this.title,
      this.actions,
      this.showBackButton = false,
      this.onBackPressed,
    }) : super(key: key);
    
    @override
    Widget build(BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          gradient: AppColors.oceanGradient,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.dubaiTeal.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                if (showBackButton)
                  GestureDetector(
                    onTap: onBackPressed ?? () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.arrowLeft,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ).animate().fadeInLeft(),
                
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.comfortaa(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: showBackButton ? TextAlign.center : TextAlign.left,
                  ).animate().fadeInUp(),
                ),
                
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      );
    }
    
    @override
    Size get preferredSize => const Size.fromHeight(100);
  }
  ```

---

## PHASE 3: API Integration & State Management (Week 3)

### 3.1 Riverpod State Management Setup
- [ ] Create API client with Dio:
  ```dart
  // services/api/api_client.dart
  @RestApi(baseUrl: "https://api.dxbevents.com")
  abstract class ApiClient {
    factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;
    
    // Auth endpoints
    @POST("/api/auth/login")
    Future<AuthResponse> login(@Body() LoginRequest request);
    
    @POST("/api/auth/register")
    Future<AuthResponse> register(@Body() RegisterRequest request);
    
    @GET("/api/auth/me")
    Future<UserProfile> getCurrentUser();
    
    // Events endpoints
    @GET("/api/events")
    Future<EventsResponse> getEvents({
      @Query("category") String? category,
      @Query("location") String? location,
      @Query("date") String? date,
      @Query("price_max") int? priceMax,
      @Query("age_group") String? ageGroup,
      @Query("page") int page = 1,
    });
    
    @GET("/api/events/{id}")
    Future<EventDetail> getEventById(@Path("id") String eventId);
    
    @POST("/api/events/{id}/save")
    Future<void> saveEvent(@Path("id") String eventId);
    
    // Search endpoints
    @GET("/api/search")
    Future<SearchResponse> searchEvents({
      @Query("q") required String query,
      @Query("filters") Map<String, dynamic>? filters,
    });
  }
  ```

- [ ] Create data models:
  ```dart
  // models/event.dart
  @JsonSerializable()
  class Event {
    final String id;
    final String title;
    final String description;
    final String aiSummary;
    final DateTime startDate;
    final DateTime? endDate;
    final Venue venue;
    final Pricing pricing;
    final FamilySuitability familySuitability;
    final List<String> categories;
    final List<String> imageUrls;
    final bool isSaved;
    final int familyScore;
    
    const Event({
      required this.id,
      required this.title,
      required this.description,
      required this.aiSummary,
      required this.startDate,
      this.endDate,
      required this.venue,
      required this.pricing,
      required this.familySuitability,
      required this.categories,
      required this.imageUrls,
      this.isSaved = false,
      required this.familyScore,
    });
    
    factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
    Map<String, dynamic> toJson() => _$EventToJson(this);
  }
  
  @JsonSerializable()
  class Venue {
    final String name;
    final String address;
    final String area;
    final double? latitude;
    final double? longitude;
    final List<String> amenities;
    
    const Venue({
      required this.name,
      required this.address,
      required this.area,
      this.latitude,
      this.longitude,
      required this.amenities,
    });
    
    factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);
    Map<String, dynamic> toJson() => _$VenueToJson(this);
  }
  ```

- [ ] Set up providers:
  ```dart
  // services/providers/events_provider.dart
  final apiClientProvider = Provider<ApiClient>((ref) {
    final dio = Dio();
    // Add interceptors for auth, logging, etc.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors globally
          handler.next(error);
        },
      ),
    );
    return ApiClient(dio);
  });
  
  final eventsProvider = FutureProvider.family<EventsResponse, EventsFilter>(
    (ref, filter) async {
      final apiClient = ref.read(apiClientProvider);
      return await apiClient.getEvents(
        category: filter.category,
        location: filter.location,
        date: filter.date,
        priceMax: filter.priceMax,
        ageGroup: filter.ageGroup,
        page: filter.page,
      );
    },
  );
  
  final savedEventsProvider = StateNotifierProvider<SavedEventsNotifier, Set<String>>(
    (ref) => SavedEventsNotifier(),
  );
  
  class SavedEventsNotifier extends StateNotifier<Set<String>> {
    SavedEventsNotifier() : super(<String>{});
    
    void toggleSaveEvent(String eventId) {
      if (state.contains(eventId)) {
        state = {...state}..remove(eventId);
      } else {
        state = {...state, eventId};
      }
    }
  }
  ```

### 3.2 Authentication State
- [ ] Create auth provider:
  ```dart
  // services/providers/auth_provider.dart
  class AuthState {
    final bool isAuthenticated;
    final bool isLoading;
    final UserProfile? user;
    final String? error;
    
    const AuthState({
      this.isAuthenticated = false,
      this.isLoading = false,
      this.user,
      this.error,
    });
    
    AuthState copyWith({
      bool? isAuthenticated,
      bool? isLoading,
      UserProfile? user,
      String? error,
    }) {
      return AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading: isLoading ?? this.isLoading,
        user: user ?? this.user,
        error: error ?? this.error,
      );
    }
  }
  
  class AuthNotifier extends StateNotifier<AuthState> {
    final ApiClient _apiClient;
    final FlutterSecureStorage _storage;
    
    AuthNotifier(this._apiClient, this._storage) : super(const AuthState());
    
    Future<void> login(String email, String password) async {
      state = state.copyWith(isLoading: true, error: null);
      try {
        final response = await _apiClient.login(
          LoginRequest(email: email, password: password),
        );
        await _storage.write(key: 'access_token', value: response.accessToken);
        await _storage.write(key: 'refresh_token', value: response.refreshToken);
        
        final user = await _apiClient.getCurrentUser();
        state = AuthState(isAuthenticated: true, user: user);
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
    
    Future<void> logout() async {
      await _storage.deleteAll();
      state = const AuthState();
    }
  }
  
  final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
    final apiClient = ref.read(apiClientProvider);
    const storage = FlutterSecureStorage();
    return AuthNotifier(apiClient, storage);
  });
  ```

---

## PHASE 4: Home Screen & Event Discovery (Week 4)

### 4.1 Animated Home Screen
- [ ] Create engaging home screen:
  ```dart
  // features/home/home_screen.dart
  class HomeScreen extends ConsumerStatefulWidget {
    const HomeScreen({Key? key}) : super(key: key);
    
    @override
    ConsumerState<HomeScreen> createState() => _HomeScreenState();
  }
  
  class _HomeScreenState extends ConsumerState<HomeScreen>
      with TickerProviderStateMixin {
    late AnimationController _headerAnimationController;
    late AnimationController _cardsAnimationController;
    
    @override
    void initState() {
      super.initState();
      _headerAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );
      _cardsAnimationController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      
      // Start animations
      _headerAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _cardsAnimationController.forward();
      });
    }
    
    @override
    void dispose() {
      _headerAnimationController.dispose();
      _cardsAnimationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildAnimatedHeader(),
            _buildQuickFilters(),
            _buildFeaturedEvents(),
            _buildTrendingEvents(),
            _buildCategoriesGrid(),
          ],
        ),
      );
    }
    
    Widget _buildAnimatedHeader() {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          decoration: const BoxDecoration(
            gradient: AppColors.sunsetGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Stack(
            children: [
              // Floating bubbles background
              ...List.generate(6, (index) => 
                Positioned(
                  top: Random().nextDouble() * 200,
                  left: Random().nextDouble() * 300,
                  child: FloatingBubble(
                    size: 20 + Random().nextDouble() * 40,
                    color: Colors.white.withOpacity(0.1),
                  ).animate().scale(
                    delay: Duration(milliseconds: index * 200),
                    duration: const Duration(seconds: 2),
                  ).then().moveY(
                    begin: 0,
                    end: -50,
                    duration: const Duration(seconds: 4),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
              
              // Main header content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello Dubai Families! 👋',
                                style: GoogleFonts.comfortaa(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ).animate().fadeInLeft(),
                              const SizedBox(height: 8),
                              Text(
                                'Discover amazing family events',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ).animate().fadeInLeft(delay: 200.ms),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              LucideIcons.bell,
                              color: Colors.white,
                              size: 24,
                            ),
                          ).animate().scale(delay: 400.ms),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Search bar
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search family events...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppColors.oceanGradient,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: const Icon(
                                LucideIcons.search,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ).animate().slideInUp(delay: 600.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
  
  // Floating bubble widget
  class FloatingBubble extends StatelessWidget {
    final double size;
    final Color color;
    
    const FloatingBubble({
      Key? key,
      required this.size,
      required this.color,
    }) : super(key: key);
    
    @override
    Widget build(BuildContext context) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
    }
  }
  ```

### 4.2 Quick Filters Component
- [ ] Create animated filter chips:
  ```dart
  // features/home/widgets/quick_filters.dart
  class QuickFilters extends StatefulWidget {
    final Function(String) onFilterSelected;
    
    const QuickFilters({Key? key, required this.onFilterSelected}) : super(key: key);
    
    @override
    State<QuickFilters> createState() => _QuickFiltersState();
  }
  
  class _QuickFiltersState extends State<QuickFilters> {
    String? selectedFilter;
    
    @override
    Widget build(BuildContext context) {
      final filters = [
        FilterData(label: 'Today', icon: LucideIcons.calendar),
        FilterData(label: 'Free Events', icon: LucideIcons.gift),
        FilterData(label: 'Indoor', icon: LucideIcons.home),
        FilterData(label: 'Outdoor', icon: LucideIcons.sun),
        FilterData(label: 'Kids 0-5', icon: LucideIcons.baby),
        FilterData(label: 'Kids 6-12', icon: LucideIcons.users),
      ];
      
      return SliverToBoxAdapter(
        child: Container(
          height: 80,
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AnimatedFilterChip(
                  filter: filters[index],
                  isSelected: selectedFilter == filters[index].label,
                  onTap: () {
                    setState(() {
                      selectedFilter = selectedFilter == filters[index].label 
                          ? null 
                          : filters[index].label;
                    });
                    widget.onFilterSelected(filters[index].label);
                  },
                ).animate().slideInLeft(
                  delay: Duration(milliseconds: index * 100),
                ),
              );
            },
          ),
        ),
      );
    }
  }
  
  class FilterData {
    final String label;
    final IconData icon;
    
    const FilterData({required this.label, required this.icon});
  }
  
  class AnimatedFilterChip extends StatefulWidget {
    final FilterData filter;
    final bool isSelected;
    final VoidCallback onTap;
    
    const AnimatedFilterChip({
      Key? key,
      required this.filter,
      required this.isSelected,
      required this.onTap,
    }) : super(key: key);
    
    @override
    State<AnimatedFilterChip> createState() => _AnimatedFilterChipState();
  }
  
  class _AnimatedFilterChipState extends State<AnimatedFilterChip> {
    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: widget.isSelected 
                ? AppColors.oceanGradient
                : LinearGradient(
                    colors: [
                      AppColors.dubaiTeal.withOpacity(0.1),
                      AppColors.dubaiPurple.withOpacity(0.1),
                    ],
                  ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: widget.isSelected 
                  ? Colors.transparent
                  : AppColors.dubaiTeal.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: widget.isSelected ? [
              BoxShadow(
                color: AppColors.dubaiTeal.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.filter.icon,
                size: 16,
                color: widget.isSelected ? Colors.white : AppColors.dubaiTeal,
              ),
              const SizedBox(width: 8),
              Text(
                widget.filter.label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.isSelected ? Colors.white : AppColors.dubaiTeal,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
  ```

### 4.3 Event Cards with Animations
- [ ] Create stunning event cards:
  ```dart
  // features/events/widgets/event_card.dart
  class EventCard extends ConsumerStatefulWidget {
    final Event event;
    final VoidCallback? onTap;
    final VoidCallback? onSave;
    
    const EventCard({
      Key? key,
      required this.event,
      this.onTap,
      this.onSave,
    }) : super(key: key);
    
    @override
    ConsumerState<EventCard> createState() => _EventCardState();
  }
  
  class _EventCardState extends ConsumerState<EventCard> 
      with SingleTickerProviderStateMixin {
    late AnimationController _animationController;
    late Animation<double> _scaleAnimation;
    
    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 0.95,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
    }
    
    @override
    void dispose() {
      _animationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      final savedEvents = ref.watch(savedEventsProvider);
      final isSaved = savedEvents.contains(widget.event.id);
      
      return GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: BubbleDecoration(
              borderRadius: 24,
              shadows: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
              child: Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event image with gradient overlay
                    Stack(
                      children: [
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            image: widget.event.imageUrls.isNotEmpty
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      widget.event.imageUrls.first,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            gradient: widget.event.imageUrls.isEmpty
                                ? AppColors.sunsetGradient
                                : null,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Save button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {
                              ref.read(savedEventsProvider.notifier)
                                  .toggleSaveEvent(widget.event.id);
                              widget.onSave?.call();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isSaved ? LucideIcons.heart : LucideIcons.heart,
                                size: 16,
                                color: isSaved ? AppColors.dubaiCoral : AppColors.textSecondary,
                              ),
                            ),
                          ).animate().scale(
                            duration: const Duration(milliseconds: 200),
                          ),
                        ),
                        
                        // Family score badge
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getScoreColor(widget.event.familyScore),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.star,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.event.familyScore}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Event details
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Event title
                          Text(
                            widget.event.title,
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // AI Summary
                          Text(
                            widget.event.aiSummary,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Event metadata
                          Row(
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 14,
                                color: AppColors.dubaiTeal,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM dd').format(widget.event.startDate),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.dubaiTeal,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                LucideIcons.mapPin,
                                size: 14,
                                color: AppColors.dubaiCoral,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.event.venue.area,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.dubaiCoral,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Price and age range
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.dubaiGold.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.event.pricing.minPrice == 0
                                      ? 'FREE'
                                      : 'AED ${widget.event.pricing.minPrice}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.dubaiGold,
                                  ),
                                ),
                              ),
                              
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.dubaiPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${widget.event.familySuitability.ageMin}-${widget.event.familySuitability.ageMax} yrs',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.dubaiPurple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    Color _getScoreColor(int score) {
      if (score >= 80) return AppColors.dubaiTeal;
      if (score >= 60) return AppColors.dubaiGold;
      return AppColors.dubaiCoral;
    }
  }
  ```

### 4.4 Featured Events Section
- [ ] Create featured events carousel:
  ```dart
  // features/home/widgets/featured_events.dart
  class FeaturedEventsSection extends ConsumerWidget {
    const FeaturedEventsSection({Key? key}) : super(key: key);
    
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final eventsAsyncValue = ref.watch(eventsProvider(
        EventsFilter(featured: true, limit: 5),
      ));
      
      return SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '✨ Featured Events',
                    style: GoogleFonts.comfortaa(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeInLeft(),
                  
                  TextButton(
                    onPressed: () => context.pushNamed('events'),
                    child: Text(
                      'See All',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dubaiTeal,
                      ),
                    ),
                  ).animate().fadeInRight(),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              height: 360,
              child: eventsAsyncValue.when(
                data: (eventsResponse) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: eventsResponse.events.length,
                  itemBuilder: (context, index) {
                    final event = eventsResponse.events[index];
                    return EventCard(
                      event: event,
                      onTap: () => context.pushNamed(
                        'event-details',
                        pathParameters: {'eventId': event.id},
                      ),
                    ).animate().slideInLeft(
                      delay: Duration(milliseconds: index * 150),
                    );
                  },
                ),
                loading: () => _buildShimmerLoading(),
                error: (error, stack) => _buildErrorWidget(error),
              ),
            ),
          ],
        ),
      );
    }
    
    Widget _buildShimmerLoading() {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        itemBuilder: (context, index) => Container(
          width: 280,
          margin: const EdgeInsets.only(right: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      );
    }
    
    Widget _buildErrorWidget(Object error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: AppColors.dubaiCoral,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
  }
  ```

---

## PHASE 5: Event Details & Search (Week 5)

### 5.1 Event Details Screen
- [ ] Create immersive event details:
  ```dart
  // features/events/event_details_screen.dart
  class EventDetailsScreen extends ConsumerStatefulWidget {
    final String eventId;
    
    const EventDetailsScreen({Key? key, required this.eventId}) : super(key: key);
    
    @override
    ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
  }
  
  class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen>
      with TickerProviderStateMixin {
    late AnimationController _animationController;
    late Animation<double> _fadeAnimation;
    late Animation<Offset> _slideAnimation;
    
    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );
      
      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ));
      
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ));
      
      _animationController.forward();
    }
    
    @override
    void dispose() {
      _animationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      final eventAsyncValue = ref.watch(eventDetailsProvider(widget.eventId));
      
      return Scaffold(
        body: eventAsyncValue.when(
          data: (event) => _buildEventDetails(event),
          loading: () => _buildLoadingScreen(),
          error: (error, stack) => _buildErrorScreen(),
        ),
      );
    }
    
    Widget _buildEventDetails(Event event) {
      return CustomScrollView(
        slivers: [
          // Hero image section
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () => context.pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(LucideIcons.share),
                  onPressed: () => _shareEvent(event),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Event image
                  Container(
                    decoration: BoxDecoration(
                      image: event.imageUrls.isNotEmpty
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(
                                event.imageUrls.first,
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                      gradient: event.imageUrls.isEmpty
                          ? AppColors.sunsetGradient
                          : null,
                    ),
                  ),
                  
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  
                  // Floating event info
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: BubbleDecoration(
                          bubbleColor: Colors.white.withOpacity(0.9),
                          borderRadius: 20,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: GoogleFonts.comfortaa(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      LucideIcons.star,
                                      size: 16,
                                      color: _getScoreColor(event.familyScore),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${event.familyScore} Family Score',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _getScoreColor(event.familyScore),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Event content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick info cards
                    _buildQuickInfoSection(event),
                    
                    const SizedBox(height: 24),
                    
                    // AI Summary
                    _buildAISummarySection(event),
                    
                    const SizedBox(height: 24),
                    
                    // Full description
                    _buildDescriptionSection(event),
                    
                    const SizedBox(height: 24),
                    
                    // Venue information
                    _buildVenueSection(event),
                    
                    const SizedBox(height: 24),
                    
                    // Family suitability
                    _buildFamilySuitabilitySection(event),
                    
                    const SizedBox(height: 100), // Space for floating button
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    Widget _buildQuickInfoSection(Event event) {
      return Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              icon: LucideIcons.calendar,
              title: 'Date',
              value: DateFormat('MMM dd, yyyy').format(event.startDate),
              color: AppColors.dubaiTeal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              icon: LucideIcons.clock,
              title: 'Time',
              value: DateFormat('HH:mm').format(event.startDate),
              color: AppColors.dubaiCoral,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              icon: LucideIcons.dollarSign,
              title: 'Price',
              value: event.pricing.minPrice == 0 
                  ? 'FREE' 
                  : 'AED ${event.pricing.minPrice}',
              color: AppColors.dubaiGold,
            ),
          ),
        ],
      );
    }
    
    Widget _buildInfoCard({
      required IconData icon,
      required String title,
      required String value,
      required Color color,
    }) {
      return BubbleDecoration(
        borderRadius: 16,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    // Additional methods for other sections...
    Color _getScoreColor(int score) {
      if (score >= 80) return AppColors.dubaiTeal;
      if (score >= 60) return AppColors.dubaiGold;
      return AppColors.dubaiCoral;
    }
    
    void _shareEvent(Event event) {
      // Implement sharing functionality
    }
  }
  ```

### 5.2 Search Screen with Smart Filters
- [ ] Create advanced search interface:
  ```dart
  // features/search/search_screen.dart
  class SearchScreen extends ConsumerStatefulWidget {
    const SearchScreen({Key? key}) : super(key: key);
    
    @override
    ConsumerState<SearchScreen> createState() => _SearchScreenState();
  }
  
  class _SearchScreenState extends ConsumerState<SearchScreen>
      with TickerProviderStateMixin {
    final TextEditingController _searchController = TextEditingController();
    late AnimationController _filterAnimationController;
    bool _showFilters = false;
    
    @override
    void initState() {
      super.initState();
    _filterAnimationController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
    }
    
    @override
    void dispose() {
      _searchController.dispose();
      _filterAnimationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return).hasMatch(value!)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Password field
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: LucideIcons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a password';
                    }
                    if (value!.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Confirm password field
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  icon: LucideIcons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    Widget _buildTextField({
      required TextEditingController controller,
      required String label,
      required IconData icon,
      bool isPassword = false,
      TextInputType? keyboardType,
      String? Function(String?)? validator,
    }) {
      return TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.dubaiTeal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.dubaiTeal, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
        ),
      ).animate().slideInUp(delay: 100.ms);
    }
    
    Widget _buildNavigationButtons() {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _previousStep(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    side: const BorderSide(color: AppColors.dubaiTeal),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dubaiTeal,
                    ),
                  ),
                ),
              ),
            
            if (_currentStep > 0) const SizedBox(width: 16),
            
            Expanded(
              flex: _currentStep == 0 ? 1 : 2,
              child: ElevatedButton(
                onPressed: () => _nextStep(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dubaiTeal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  _currentStep == _steps.length - 1 ? 'Create Account 🎉' : 'Continue',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    void _nextStep() {
      if (_currentStep < _steps.length - 1) {
        if (_validateCurrentStep()) {
          setState(() {
            _currentStep++;
          });
        }
      } else {
        _handleRegistration();
      }
    }
    
    void _previousStep() {
      if (_currentStep > 0) {
        setState(() {
          _currentStep--;
        });
      }
    }
    
    bool _validateCurrentStep() {
      switch (_currentStep) {
        case 0:
          return _formKey.currentState?.validate() ?? false;
        case 1:
          // Validate family details
          return true;
        case 2:
          // Validate preferences
          return true;
        default:
          return true;
      }
    }
    
    void _handleRegistration() {
      // Implement registration logic
      ref.read(authProvider.notifier).register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }
  ```

---

## PHASE 7: Performance & Animations (Week 7)

### 7.1 Advanced Animation Components
- [ ] Create reusable animation widgets:
  ```dart
  // core/widgets/animated_widgets.dart
  class FadeInSlideUp extends StatefulWidget {
    final Widget child;
    final Duration delay;
    final Duration duration;
    
    const FadeInSlideUp({
      Key? key,
      required this.child,
      this.delay = Duration.zero,
      this.duration = const Duration(milliseconds: 600),
    }) : super(key: key);
    
    @override
    State<FadeInSlideUp> createState() => _FadeInSlideUpState();
  }
  
  class _FadeInSlideUpState extends State<FadeInSlideUp>
      with SingleTickerProviderStateMixin {
    late AnimationController _controller;
    late Animation<double> _opacity;
    late Animation<Offset> _position;
    
    @override
    void initState() {
      super.initState();
      _controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      );
      
      _opacity = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));
      
      _position = Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ));
      
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
    
    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => FadeTransition(
          opacity: _opacity,
          child: SlideTransition(
            position: _position,
            child: widget.child,
          ),
        ),
      );
    }
  }
  
  class PulsingButton extends StatefulWidget {
    final Widget child;
    final VoidCallback? onPressed;
    final Color? pulseColor;
    
    const PulsingButton({
      Key? key,
      required this.child,
      this.onPressed,
      this.pulseColor,
    }) : super(key: key);
    
    @override
    State<PulsingButton> createState() => _PulsingButtonState();
  }
  
  class _PulsingButtonState extends State<PulsingButton>
      with SingleTickerProviderStateMixin {
    late AnimationController _controller;
    late Animation<double> _scaleAnimation;
    
    @override
    void initState() {
      super.initState();
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
      
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 1.1,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      
      _controller.repeat(reverse: true);
    }
    
    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: (widget.pulseColor ?? AppColors.dubaiTeal).withOpacity(0.3),
                    blurRadius: 20 * _scaleAnimation.value,
                    spreadRadius: 5 * (_scaleAnimation.value - 1),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      );
    }
  }
  
  class ShimmerLoading extends StatefulWidget {
    final Widget child;
    final bool isLoading;
    
    const ShimmerLoading({
      Key? key,
      required this.child,
      required this.isLoading,
    }) : super(key: key);
    
    @override
    State<ShimmerLoading> createState() => _ShimmerLoadingState();
  }
  
  class _ShimmerLoadingState extends State<ShimmerLoading>
      with SingleTickerProviderStateMixin {
    late AnimationController _controller;
    
    @override
    void initState() {
      super.initState();
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
      
      if (widget.isLoading) {
        _controller.repeat();
      }
    }
    
    @override
    void didUpdateWidget(ShimmerLoading oldWidget) {
      super.didUpdateWidget(oldWidget);
      if (widget.isLoading != oldWidget.isLoading) {
        if (widget.isLoading) {
          _controller.repeat();
        } else {
          _controller.stop();
        }
      }
    }
    
    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      if (!widget.isLoading) {
        return widget.child;
      }
      
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: widget.child,
      );
    }
  }
  ```

### 7.2 Performance Optimizations
- [ ] Implement efficient list rendering:
  ```dart
  // core/widgets/optimized_list_view.dart
  class OptimizedEventsList extends StatefulWidget {
    final List<Event> events;
    final VoidCallback? onLoadMore;
    final bool hasMore;
    final bool isLoading;
    
    const OptimizedEventsList({
      Key? key,
      required this.events,
      this.onLoadMore,
      this.hasMore = false,
      this.isLoading = false,
    }) : super(key: key);
    
    @override
    State<OptimizedEventsList> createState() => _OptimizedEventsListState();
  }
  
  class _OptimizedEventsListState extends State<OptimizedEventsList> {
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
          _scrollController.position.maxScrollExtent * 0.8) {
        if (widget.hasMore && !widget.isLoading) {
          widget.onLoadMore?.call();
        }
      }
    }
    
    @override
    Widget build(BuildContext context) {
      return ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: widget.events.length + (widget.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= widget.events.length) {
            return _buildLoadingItem();
          }
          
          final event = widget.events[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EventCard(
              event: event,
              onTap: () => context.pushNamed(
                'event-details',
                pathParameters: {'eventId': event.id},
              ),
            ).animate().fadeIn(
              delay: Duration(milliseconds: index * 50),
            ),
          );
        },
      );
    }
    
    Widget _buildLoadingItem() {
      return Container(
        height: 200,
        margin: const EdgeInsets.only(bottom: 16),
        child: const ShimmerLoading(
          isLoading: true,
          child: BubbleDecoration(
            child: SizedBox.expand(),
          ),
        ),
      );
    }
  }
  ```

### 7.3 Image Optimization
- [ ] Create optimized image widgets:
  ```dart
  // core/widgets/optimized_image.dart
  class OptimizedNetworkImage extends StatelessWidget {
    final String imageUrl;
    final double? width;
    final double? height;
    final BoxFit fit;
    final BorderRadius? borderRadius;
    
    const OptimizedNetworkImage({
      Key? key,
      required this.imageUrl,
      this.width,
      this.height,
      this.fit = BoxFit.cover,
      this.borderRadius,
    }) : super(key: key);
    
    @override
    Widget build(BuildContext context) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: AppColors.sunsetGradient.scale(0.3),
              borderRadius: borderRadius,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: borderRadius,
            ),
            child: const Icon(
              LucideIcons.image,
              color: Colors.grey,
              size: 40,
            ),
          ),
          memCacheWidth: width?.toInt(),
          memCacheHeight: height?.toInt(),
        ),
      );
    }
  }
  ```

---

## PHASE 8: Testing & Deployment (Week 8)

### 8.1 Widget Testing
- [ ] Create comprehensive tests:
  ```dart
  // test/widgets/event_card_test.dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:dxb_events_web/features/events/widgets/event_card.dart';
  
  void main() {
    group('EventCard Widget Tests', () {
      late Event testEvent;
      
      setUp(() {
        testEvent = Event(
          id: 'test-1',
          title: 'Test Family Event',
          description: 'A great test event for families',
          aiSummary: 'Fun family activity',
          startDate: DateTime.now(),
          venue: const Venue(
            name: 'Test Venue',
            address: 'Test Address',
            area: 'Dubai Marina',
            amenities: [],
          ),
          pricing: const Pricing(minPrice: 0, maxPrice: 100, currency: 'AED'),
          familySuitability: const FamilySuitability(
            ageMin: 0,
            ageMax: 12,
            familyFriendly: true,
          ),
          categories: ['outdoor', 'family'],
          imageUrls: [],
          familyScore: 85,
        );
      });
      
      testWidgets('should display event title', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: EventCard(event: testEvent),
              ),
            ),
          ),
        );
        
        expect(find.text('Test Family Event'), findsOneWidget);
      });
      
      testWidgets('should display family score', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: EventCard(event: testEvent),
              ),
            ),
          ),
        );
        
        expect(find.text('85'), findsOneWidget);
      });
      
      testWidgets('should trigger onTap callback', (WidgetTester tester) async {
        bool tapped = false;
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: EventCard(
                  event: testEvent,
                  onTap: () => tapped = true,
                ),
              ),
            ),
          ),
        );
        
        await tester.tap(find.byType(EventCard));
        expect(tapped, isTrue);
      });
    });
  }
  ```

### 8.2 Integration Testing
- [ ] Create end-to-end tests:
  ```dart
  // integration_test/app_test.dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:integration_test/integration_test.dart';
  import 'package:dxb_events_web/main.dart' as app;
  
  void main() {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    
    group('DXB Events App Integration Tests', () {
      testWidgets('complete user flow test', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        
        // Test home screen loads
        expect(find.text('Hello Dubai Families! 👋'), findsOneWidget);
        
        // Test search functionality
        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();
        
        await tester.enterText(
          find.byType(TextField),
          'family events',
        );
        await tester.pumpAndSettle();
        
        // Test navigation to event details
        if (find.byType(EventCard).evaluate().isNotEmpty) {
          await tester.tap(find.byType(EventCard).first);
          await tester.pumpAndSettle();
          
          // Verify event details screen
          expect(find.byType(EventDetailsScreen), findsOneWidget);
        }
      });
      
      testWidgets('login flow test', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        
        // Navigate to profile (should redirect to login)
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();
        
        // Should be on login screen
        expect(find.text('Welcome to DXB Events! 🎉'), findsOneWidget);
        
        // Test form validation
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();
        
        expect(find.text('Please enter your email'), findsOneWidget);
      });
    });
  }
  ```

### 8.3 Performance Testing
- [ ] Create performance monitoring:
  ```dart
  // test/performance/performance_test.dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  
  void main() {
    group('Performance Tests', () {
      testWidgets('event list scrolling performance', (WidgetTester tester) async {
        // Create mock events list
        final events = List.generate(100, (index) => createMockEvent(index));
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: OptimizedEventsList(events: events),
              ),
            ),
          ),
        );
        
        // Measure frame rendering time
        await tester.binding.watchPerformance(() async {
          // Scroll through the list
          await tester.fling(
            find.byType(ListView),
            const Offset(0, -500),
            1000,
          );
          await tester.pumpAndSettle();
        }, reportKey: 'event_list_scroll');
      });
      
      testWidgets('animation performance test', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: HomeScreen(),
          ),
        );
        
        await tester.binding.watchPerformance(() async {
          // Trigger animations
          await tester.pumpAndSettle();
        }, reportKey: 'home_screen_animations');
      });
    });
  }
  ```

### 8.4 Build Configuration
- [ ] Set up build scripts:
  ```yaml
  # build_runner.yaml
  targets:
    $default:
      builders:
        json_serializable:
          options:
            explicit_to_json: true
            field_rename: snake_case
  ```

- [ ] Create deployment script:
  ```bash
  #!/bin/bash
  # scripts/deploy.sh
  
  echo "🚀 Building DXB Events Web App..."
  
  # Clean previous builds
  flutter clean
  flutter pub get
  
  # Generate code
  flutter packages pub run build_runner build --delete-conflicting-outputs
  
  # Build for web
  flutter build web --release --web-renderer html
  
  # Optimize assets
  echo "📦 Optimizing assets..."
  # Add asset optimization commands here
  
  echo "✅ Build completed successfully!"
  echo "📁 Build files are in: build/web/"
  ```

### 8.5 Environment Configuration
- [ ] Set up environment configs:
  ```dart
  // lib/core/config/environment.dart
  class Environment {
    static const String apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.dxbevents.com',
    );
    
    static const String googleMapsApiKey = String.fromEnvironment(
      'GOOGLE_MAPS_API_KEY',
      defaultValue: '',
    );
    
    static const bool isProduction = bool.fromEnvironment(
      'PRODUCTION',
      defaultValue: false,
    );
    
    static const bool enableAnalytics = bool.fromEnvironment(
      'ENABLE_ANALYTICS',
      defaultValue: false,
    );
  }
  ```

---

## Success Criteria Checklist

### Design & UX Goals
- [ ] Implement vibrant Dubai-inspired color scheme with gradients
- [ ] Create smooth animations throughout the app (60fps)
- [ ] Achieve playful, family-friendly design with curves and bubbles
- [ ] Implement comprehensive dark/light theme support
- [ ] Ensure responsive design works on all screen sizes
- [ ] Use fun typography (Comfortaa, Nunito, Inter, Poppins)

### Performance Goals
- [ ] Achieve <3 second initial load time
- [ ] Maintain 60fps during animations and scrolling
- [ ] Implement efficient image caching and lazy loading
- [ ] Keep bundle size under 2MB (gzipped)
- [ ] Achieve 90+ Lighthouse performance score

### Functionality Goals
- [ ] Complete event discovery and search functionality
- [ ] Working authentication and profile management
- [ ] Functional family preference system
- [ ] Save/unsave events functionality
- [ ] Advanced filtering and search capabilities
- [ ] Integration with backend API (FastAPI/MongoDB)

### Mobile Preparation Goals
- [ ] Responsive design that works on mobile browsers
- [ ] Touch-optimized interactions
- [ ] Progressive Web App (PWA) capabilities
- [ ] Offline-first architecture preparation
- [ ] Mobile-specific animations and gestures

---

## Cost Estimation

### Development Dependencies (One-time)
- [ ] **Design Assets**: $200-500 (icons, illustrations, stock photos)
- [ ] **Font Licenses**: $0 (Google Fonts)
- [ ] **Development Tools**: $50-100/month (IDE extensions, testing tools)

### Hosting & Infrastructure (Monthly)
- [ ] **Web Hosting**: $20-50 (Netlify/Vercel Pro)
- [ ] **CDN**: $10-30 (image and asset delivery)
- [ ] **Analytics**: $0-50 (Google Analytics + Mixpanel)
- [ ] **Error Tracking**: $0-25 (Sentry free tier)

**Total Estimated Monthly Cost: $30-155 USD**

---

## Future Mobile App Considerations

### Architecture Decisions for Mobile
- [ ] Shared state management system (Riverpod works across platforms)
- [ ] Reusable UI components with platform adaptations
- [ ] Shared API client and data models
- [ ] Consistent navigation patterns

### Mobile-Specific Features to Prepare
- [ ] Push notifications infrastructure
- [ ] Offline data synchronization
- [ ] Device-specific permissions (location, camera)
- [ ] Platform-specific UI adaptations (iOS/Android)

### Code Reusability Strategy
- [ ] 80%+ shared business logic
- [ ] Shared core widgets with platform variants
- [ ] Unified theming system
- [ ] Common animation framework

## Next Steps After Completion

### Immediate Next Phase
- [ ] Deploy web app to staging environment
- [ ] Connect to live FastAPI backend
- [ ] User acceptance testing with Dubai families
- [ ] Performance optimization based on real usage

### Mobile App Development
- [ ] Create iOS/Android projects sharing core codebase
- [ ] Implement mobile-specific features
- [ ] App Store and Google Play Store preparation
- [ ] Mobile app beta testing

### Analytics & Optimization
- [ ] Implement comprehensive event tracking
- [ ] A/B testing framework for UI improvements
- [ ] User behavior analysis and optimization
- [ ] Performance monitoring and optimization

This comprehensive Flutter web development checklist ensures a beautiful, performant, and family-friendly application that serves as the perfect foundation for Dubai's premier family events platform. The modern design techniques, smooth animations, and Dubai-inspired aesthetic will create an engaging experience that busy Dubai families will love to use for discovering their next family adventure! Container(
        decoration: BoxDecoration(
          color: bubbleColor ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: shadows ?? [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: child,
      );
    }
  }
  ```

- [ ] Create animated curved containers:
  ```dart
  // core/widgets/curved_container.dart
  class CurvedContainer extends StatelessWidget {
    final Widget child;
    final Gradient? gradient;
    final Color? backgroundColor;
    final double curveHeight;
    final CurvePosition curvePosition;
    
    @override
    Widget build(BuildContext context) {
      return CustomPaint(
        painter: CurvePainter(
          gradient: gradient,
          backgroundColor: backgroundColor,
          curveHeight: curveHeight,
          curvePosition: curvePosition,
        ),
        child: child,
      );
    }
  }
  
  class CurvePainter extends CustomPainter {
    final Gradient? gradient;
    final Color? backgroundColor;
    final double curveHeight;
    final CurvePosition curvePosition;
    
    CurvePainter({
      this.gradient,
      this.backgroundColor,
      required this.curveHeight,
      required this.curvePosition,
    });
    
    @override
    void paint(Canvas canvas, Size size) {
      final paint = Paint();
      
      if (gradient != null) {
        paint.shader = gradient!.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        );
      } else {
        paint.color = backgroundColor ?? Colors.blue;
      }
      
      final path = Path();
      
      switch (curvePosition) {
        case CurvePosition.top:
          path.moveTo(0, curveHeight);
          path.quadraticBezierTo(
            size.width / 2, 0, 
            size.width, curveHeight
          );
          path.lineTo(size.width, size.height);
          path.lineTo(0, size.height);
          break;
          
        case CurvePosition.bottom:
          path.moveTo(0, 0);
          path.lineTo(size.width, 0);
          path.lineTo(size.width, size.height - curveHeight);
          path.quadraticBezierTo(
            size.width / 2, size.height,
            0, size.height - curveHeight
          );
          break;
      }
      
      path.close();
      canvas.drawPath(path, paint);
    }
    
    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
  }
  
  enum CurvePosition { top, bottom }
  ```

---

## PHASE 2: Navigation & Routing (Week 2)

### 2.1 Go Router Configuration
- [ ] Set up app routing:
  ```dart
  // services/navigation/app_router.dart
  final GoRouter appRouter = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/events',
        name: 'events',
        builder: (context, state) => const EventsScreen(),
        routes: [
          GoRoute(
            path: '/details/:eventId',
            name: 'event-details',
            builder: (context, state) => EventDetailsScreen(
              eventId: state.pathParameters['eventId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
        redirect: (context, state) {
          // Redirect to login if not authenticated
          final container = ProviderContainer();
          final isLoggedIn = container.read(authProvider).isAuthenticated;
          return isLoggedIn ? null : '/login';
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
  ```

### 2.2 Responsive Navigation Bar
- [ ] Create animated bottom navigation:
  ```dart
  // core/widgets/animated_bottom_nav.dart
  class AnimatedBottomNav extends StatefulWidget {
    final int currentIndex;
    final Function(int) onTap;
    
    const AnimatedBottomNav({
      Key? key,
      required this.currentIndex,
      required this.onTap,
    }) : super(key: key);
    
    @override
    State<AnimatedBottomNav> createState() => _AnimatedBottomNavState();
  }
  
  class _AnimatedBottomNavState extends State<AnimatedBottomNav> {
    @override
    Widget build(BuildContext context) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, LucideIcons.home, 'Home'),
            _buildNavItem(1, LucideIcons.calendar, 'Events'),
            _buildNavItem(2, LucideIcons.search, 'Search'),
            _buildNavItem(3, LucideIcons.user, 'Profile'),
          ],
        ),
      );
    }
    
    Widget _buildNavItem(int index, IconData icon, String label) {
      final isSelected = widget.currentIndex == index;
      return GestureDetector(
        onTap: () => widget.onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.dubaiTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(
        duration: const Duration(milliseconds: 150),
        curve: Curves.elasticOut,
      );
    }
  }
  ```

### 2.3 App Bar with Animations
- [ ] Create dynamic app bar:
  ```dart
  // core/widgets/dubai_app_bar.dart
  class DubaiAppBar extends StatelessWidget implements PreferredSizeWidget {
    final String title;
    final List<Widget>? actions;
    final bool showBackButton;
    final VoidCallback? onBackPressed;
    
    const DubaiAppBar({
      Key? key,
      required this.title,
      this.actions,
      this.showBackButton = false,
      this.onBackPressed,
    }) : super(key: key);
    
    @override
    Widget build(BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          gradient: AppColors.oceanGradient,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.dubaiTeal.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                if (showBackButton)
                  GestureDetector(
                    onTap: onBackPressed ?? () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.arrowLeft,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ).animate().fadeInLeft(),
                
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.comfortaa(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: showBackButton ? TextAlign.center : TextAlign.left,
                  ).animate().fadeInUp(),
                ),
                
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      );
    }
    
    @override
    Size get preferredSize => const Size.fromHeight(100);
  }
  ```

---

## PHASE 3: API Integration & State Management (Week 3)

### 3.1 Riverpod State Management Setup
- [ ] Create API client with Dio:
  ```dart
  // services/api/api_client.dart
  @RestApi(baseUrl: "https://api.dxbevents.com")
  abstract class ApiClient {
    factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;
    
    // Auth endpoints
    @POST("/api/auth/login")
    Future<AuthResponse> login(@Body() LoginRequest request);
    
    @POST("/api/auth/register")
    Future<AuthResponse> register(@Body() RegisterRequest request);
    
    @GET("/api/auth/me")
    Future<UserProfile> getCurrentUser();
    
    // Events endpoints
    @GET("/api/events")
    Future<EventsResponse> getEvents({
      @Query("category") String? category,
      @Query("location") String? location,
      @Query("date") String? date,
      @Query("price_max") int? priceMax,
      @Query("age_group") String? ageGroup,
      @Query("page") int page = 1,
    });
    
    @GET("/api/events/{id}")
    Future<EventDetail> getEventById(@Path("id") String eventId);
    
    @POST("/api/events/{id}/save")
    Future<void> saveEvent(@Path("id") String eventId);
    
    // Search endpoints
    @GET("/api/search")
    Future<SearchResponse> searchEvents({
      @Query("q") required String query,
      @Query("filters") Map<String, dynamic>? filters,
    });
  }
  ```

- [ ] Create data models:
  ```dart
  // models/event.dart
  @JsonSerializable()
  class Event {
    final String id;
    final String title;
    final String description;
    final String aiSummary;
    final DateTime startDate;
    final DateTime? endDate;
    final Venue venue;
    final Pricing pricing;
    final FamilySuitability familySuitability;
    final List<String> categories;
    final List<String> imageUrls;
    final bool isSaved;
    final int familyScore;
    
    const Event({
      required this.id,
      required this.title,
      required this.description,
      required this.aiSummary,
      required this.startDate,
      this.endDate,
      required this.venue,
      required this.pricing,
      required this.familySuitability,
      required this.categories,
      required this.imageUrls,
      this.isSaved = false,
      required this.familyScore,
    });
    
    factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
    Map<String, dynamic> toJson() => _$EventToJson(this);
  }
  
  @JsonSerializable()
  class Venue {
    final String name;
    final String address;
    final String area;
    final double? latitude;
    final double? longitude;
    final List<String> amenities;
    
    const Venue({
      required this.name,
      required this.address,
      required this.area,
      this.latitude,
      this.longitude,
      required this.amenities,
    });
    
    factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);
    Map<String, dynamic> toJson() => _$VenueToJson(this);
  }
  ```

- [ ] Set up providers:
  ```dart
  // services/providers/events_provider.dart
  final apiClientProvider = Provider<ApiClient>((ref) {
    final dio = Dio();
    // Add interceptors for auth, logging, etc.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors globally
          handler.next(error);
        },
      ),
    );
    return ApiClient(dio);
  });
  
  final eventsProvider = FutureProvider.family<EventsResponse, EventsFilter>(
    (ref, filter) async {
      final apiClient = ref.read(apiClientProvider);
      return await apiClient.getEvents(
        category: filter.category,
        location: filter.location,
        date: filter.date,
        priceMax: filter.priceMax,
        ageGroup: filter.ageGroup,
        page: filter.page,
      );
    },
  );
  
  final savedEventsProvider = StateNotifierProvider<SavedEventsNotifier, Set<String>>(
    (ref) => SavedEventsNotifier(),
  );
  
  class SavedEventsNotifier extends StateNotifier<Set<String>> {
    SavedEventsNotifier() : super(<String>{});
    
    void toggleSaveEvent(String eventId) {
      if (state.contains(eventId)) {
        state = {...state}..remove(eventId);
      } else {
        state = {...state, eventId};
      }
    }
  }
  ```

### 3.2 Authentication State
- [ ] Create auth provider:
  ```dart
  // services/providers/auth_provider.dart
  class AuthState {
    final bool isAuthenticated;
    final bool isLoading;
    final UserProfile? user;
    final String? error;
    
    const AuthState({
      this.isAuthenticated = false,
      this.isLoading = false,
      this.user,
      this.error,
    });
    
    AuthState copyWith({
      bool? isAuthenticated,
      bool? isLoading,
      UserProfile? user,
      String? error,
    }) {
      return AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading: isLoading ?? this.isLoading,
        user: user ?? this.user,
        error: error ?? this.error,
      );
    }
  }
  
  class AuthNotifier extends StateNotifier<AuthState> {
    final ApiClient _apiClient;
    final FlutterSecureStorage _storage;
    
    AuthNotifier(this._apiClient, this._storage) : super(const AuthState());
    
    Future<void> login(String email, String password) async {
      state = state.copyWith(isLoading: true, error: null);
      try {
        final response = await _apiClient.login(
          LoginRequest(email: email, password: password),
        );
        await _storage.write(key: 'access_token', value: response.accessToken);
        await _storage.write(key: 'refresh_token', value: response.refreshToken);
        
        final user = await _apiClient.getCurrentUser();
        state = AuthState(isAuthenticated: true, user: user);
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
    
    Future<void> logout() async {
      await _storage.deleteAll();
      state = const AuthState();
    }
  }
  
  final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
    final apiClient = ref.read(apiClientProvider);
    const storage = FlutterSecureStorage();
    return AuthNotifier(apiClient, storage);
  });
  ```

---

## PHASE 4: Home Screen & Event Discovery (Week 4)

### 4.1 Animated Home Screen
- [ ] Create engaging home screen:
  ```dart
  // features/home/home_screen.dart
  class HomeScreen extends ConsumerStatefulWidget {
    const HomeScreen({Key? key}) : super(key: key);
    
    @override
    ConsumerState<HomeScreen> createState() => _HomeScreenState();
  }
  
  class _HomeScreenState extends ConsumerState<HomeScreen>
      with TickerProviderStateMixin {
    late AnimationController _headerAnimationController;
    late AnimationController _cardsAnimationController;
    
    @override
    void initState() {
      super.initState();
      _headerAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );
      _cardsAnimationController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      
      // Start animations
      _headerAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _cardsAnimationController.forward();
      });
    }
    
    @override
    void dispose() {
      _headerAnimationController.dispose();
      _cardsAnimationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildAnimatedHeader(),
            _buildQuickFilters(),
            _buildFeaturedEvents(),
            _buildTrendingEvents(),
            _buildCategoriesGrid(),
          ],
        ),
      );
    }
    
    Widget _buildAnimatedHeader() {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          decoration: const BoxDecoration(
            gradient: AppColors.sunsetGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Stack(
            children: [
              // Floating bubbles background
              ...List.generate(6, (index) => 
                Positioned(
                  top: Random().nextDouble() * 200,
                  left: Random().nextDouble() * 300,
                  child: FloatingBubble(
                    size: 20 + Random().nextDouble() * 40,
                    color: Colors.white.withOpacity(0.1),
                  ).animate().scale(
                    delay: Duration(milliseconds: index * 200),
                    duration: const Duration(seconds: 2),
                  ).then().moveY(
                    begin: 0,
                    end: -50,
                    duration: const Duration(seconds: 4),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
              
              // Main header content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello Dubai Families! 👋',
                                style: GoogleFonts.comfortaa(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ).animate().fadeInLeft(),
                              const SizedBox(height: 8),
                              Text(
                                'Discover amazing family events',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ).animate().fadeInLeft(delay: 200.ms),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              LucideIcons.bell,
                              color: Colors.white,
                              size: 24,
                            ),
                          ).animate().scale(delay: 400.ms),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Search bar
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search family events...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppColors.oceanGradient,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: const Icon(
                                LucideIcons.search,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ).animate().slideInUp(delay: 600.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
  
  // Floating bubble widget
  class FloatingBubble extends StatelessWidget {
    final double size;
    final Color color;
    
    const FloatingBubble({
      Key? key,
      required this.size,
      required this.color,
    }) : super(key: key);
    
    @override
    Widget build(BuildContext context) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
    }
  }
  ```

### 4.2 Quick Filters Component
- [ ] Create animated filter chips:
  ```dart
  // features/home/widgets/quick_filters.dart
  class QuickFilters extends StatefulWidget {
    final Function(String) onFilterSelected;
    
    const QuickFilters({Key? key, required this.onFilterSelected}) : super(key: key);
    
    @override
    State<QuickFilters> createState() => _QuickFiltersState();
  }
  
  class _QuickFiltersState extends State<QuickFilters> {
    String? selectedFilter;
    
    @override
    Widget build(BuildContext context) {
      final filters = [
        FilterData(label: 'Today', icon: LucideIcons.calendar),
        FilterData(label: 'Free Events', icon: LucideIcons.gift),
        FilterData(label: 'Indoor', icon: LucideIcons.home),
        FilterData(label: 'Outdoor', icon: LucideIcons.sun),
        FilterData(label: 'Kids 0-5', icon: LucideIcons.baby),
        FilterData(label: 'Kids 6-12', icon: LucideIcons.users),
      ];
      
      return SliverToBoxAdapter(
        child: Container(
          height: 80,
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AnimatedFilterChip(
                  filter: filters[index],
                  isSelected: selectedFilter == filters[index].label,
                  onTap: () {
                    setState(() {
                      selectedFilter = selectedFilter == filters[index].label 
                          ? null 
                          : filters[index].label;
                    });
                    widget.onFilterSelected(filters[index].label);
                  },
                ).animate().slideInLeft(
                  delay: Duration(milliseconds: index * 100),
                ),
              );
            },
          ),
        ),
      );
    }
  }
  
  class FilterData {
    final String label;
    final IconData icon;
    
    const FilterData({required this.label, required this.icon});
  }
  
  class AnimatedFilterChip extends StatefulWidget {
    final FilterData filter;
    final bool isSelected;
    final VoidCallback onTap;
    
    const AnimatedFilterChip({
      Key? key,
      required this.filter,
      required this.isSelected,
      required this.onTap,
    }) : super(key: key);
    
    @override
    State<AnimatedFilterChip> createState() => _AnimatedFilterChipState();
  }
  
  class _AnimatedFilterChipState extends State<AnimatedFilterChip> {
    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: widget.isSelected 
                ? AppColors.oceanGradient
                : LinearGradient(
                    colors: [
                      AppColors.dubaiTeal.withOpacity(0.1),
                      AppColors.dubaiPurple.withOpacity(0.1),
                    ],
                  ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: widget.isSelected 
                  ? Colors.transparent
                  : AppColors.dubaiTeal.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: widget.isSelected ? [
              BoxShadow(
                color: AppColors.dubaiTeal.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.filter.icon,
                size: 16,
                color: widget.isSelected ? Colors.white : AppColors.dubaiTeal,
              ),
              const SizedBox(width: 8),
              Text(
                widget.filter.label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.isSelected ? Colors.white : AppColors.dubaiTeal,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
  ```

### 4.3 Event Cards with Animations
- [ ] Create stunning event cards:
  ```dart
  // features/events/widgets/event_card.dart
  class EventCard extends ConsumerStatefulWidget {
    final Event event;
    final VoidCallback? onTap;
    final VoidCallback? onSave;
    
    const EventCard({
      Key? key,
      required this.event,
      this.onTap,
      this.onSave,
    }) : super(key: key);
    
    @override
    ConsumerState<EventCard> createState() => _EventCardState();
  }
  
  class _EventCardState extends ConsumerState<EventCard> 
      with SingleTickerProviderStateMixin {
    late AnimationController _animationController;
    late Animation<double> _scaleAnimation;
    
    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 0.95,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
    }
    
    @override
    void dispose() {
      _animationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      final savedEvents = ref.watch(savedEventsProvider);
      final isSaved = savedEvents.contains(widget.event.id);
      
      return GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: BubbleDecoration(
              borderRadius: 24,
              shadows: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
              child: Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event image with gradient overlay
                    Stack(
                      children: [
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            image: widget.event.imageUrls.isNotEmpty
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      widget.event.imageUrls.first,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            gradient: widget.event.imageUrls.isEmpty
                                ? AppColors.sunsetGradient
                                : null,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Save button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {
                              ref.read(savedEventsProvider.notifier)
                                  .toggleSaveEvent(widget.event.id);
                              widget.onSave?.call();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isSaved ? LucideIcons.heart : LucideIcons.heart,
                                size: 16,
                                color: isSaved ? AppColors.dubaiCoral : AppColors.textSecondary,
                              ),
                            ),
                          ).animate().scale(
                            duration: const Duration(milliseconds: 200),
                          ),
                        ),
                        
                        // Family score badge
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getScoreColor(widget.event.familyScore),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.star,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.event.familyScore}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Event details
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Event title
                          Text(
                            widget.event.title,
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // AI Summary
                          Text(
                            widget.event.aiSummary,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Event metadata
                          Row(
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 14,
                                color: AppColors.dubaiTeal,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM dd').format(widget.event.startDate),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.dubaiTeal,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                LucideIcons.mapPin,
                                size: 14,
                                color: AppColors.dubaiCoral,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.event.venue.area,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.dubaiCoral,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Price and age range
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.dubaiGold.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.event.pricing.minPrice == 0
                                      ? 'FREE'
                                      : 'AED ${widget.event.pricing.minPrice}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.dubaiGold,
                                  ),
                                ),
                              ),
                              
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.dubaiPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${widget.event.familySuitability.ageMin}-${widget.event.familySuitability.ageMax} yrs',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.dubaiPurple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    Color _getScoreColor(int score) {
      if (score >= 80) return AppColors.dubaiTeal;
      if (score >= 60) return AppColors.dubaiGold;
      return AppColors.dubaiCoral;
    }
  }
  ```

### 4.4 Featured Events Section
- [ ] Create featured events carousel:
  ```dart
  // features/home/widgets/featured_events.dart
  class FeaturedEventsSection extends ConsumerWidget {
    const FeaturedEventsSection({Key? key}) : super(key: key);
    
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final eventsAsyncValue = ref.watch(eventsProvider(
        EventsFilter(featured: true, limit: 5),
      ));
      
      return SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '✨ Featured Events',
                    style: GoogleFonts.comfortaa(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeInLeft(),
                  
                  TextButton(
                    onPressed: () => context.pushNamed('events'),
                    child: Text(
                      'See All',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dubaiTeal,
                      ),
                    ),
                  ).animate().fadeInRight(),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              height: 360,
              child: eventsAsyncValue.when(
                data: (eventsResponse) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: eventsResponse.events.length,
                  itemBuilder: (context, index) {
                    final event = eventsResponse.events[index];
                    return EventCard(
                      event: event,
                      onTap: () => context.pushNamed(
                        'event-details',
                        pathParameters: {'eventId': event.id},
                      ),
                    ).animate().slideInLeft(
                      delay: Duration(milliseconds: index * 150),
                    );
                  },
                ),
                loading: () => _buildShimmerLoading(),
                error: (error, stack) => _buildErrorWidget(error),
              ),
            ),
          ],
        ),
      );
    }
    
    Widget _buildShimmerLoading() {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        itemBuilder: (context, index) => Container(
          width: 280,
          margin: const EdgeInsets.only(right: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      );
    }
    
    Widget _buildErrorWidget(Object error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: AppColors.dubaiCoral,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
  }
  ```

---

## PHASE 5: Event Details & Search (Week 5)

### 5.1 Event Details Screen
- [ ] Create immersive event details:
  ```dart
  // features/events/event_details_screen.dart
  class EventDetailsScreen extends ConsumerStatefulWidget {
    final String eventId;
    
    const EventDetailsScreen({Key? key, required this.eventId}) : super(key: key);
    
    @override
    ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
  }
  
  class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen>
      with TickerProviderStateMixin {
    late AnimationController _animationController;
    late Animation<double> _fadeAnimation;
    late Animation<Offset> _slideAnimation;
    
    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );
      
      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ));
      
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ));
      
      _animationController.forward();
    }
    
    @override
    void dispose() {
      _animationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      final eventAsyncValue = ref.watch(eventDetailsProvider(widget.eventId));
      
      return Scaffold(
        body: eventAsyncValue.when(
          data: (event) => _buildEventDetails(event),
          loading: () => _buildLoadingScreen(),
          error: (error, stack) => _buildErrorScreen(),
        ),
      );
    }
    
    Widget _buildEventDetails(Event event) {
      return CustomScrollView(
        slivers: [
          // Hero image section
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () => context.pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(LucideIcons.share),
                  onPressed: () => _shareEvent(event),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Event image
                  Container(
                    decoration: BoxDecoration(
                      image: event.imageUrls.isNotEmpty
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(
                                event.imageUrls.first,
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                      gradient: event.imageUrls.isEmpty
                          ? AppColors.sunsetGradient
                          : null,
                    ),
                  ),
                  
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  
                  // Floating event info
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: BubbleDecoration(
                          bubbleColor: Colors.white.withOpacity(0.9),
                          borderRadius: 20,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: GoogleFonts.comfortaa(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      LucideIcons.star,
                                      size: 16,
                                      color: _getScoreColor(event.familyScore),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${event.familyScore} Family Score',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _getScoreColor(event.familyScore),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Event content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick info cards
                    _buildQuickInfoSection(event),
                    
                    const SizedBox(height: 24),
                    
                    // AI Summary
                    _buildAISummarySection(event),
                    
                    const SizedBox(height: 24),
                    
                    // Full description
                    _buildDescriptionSection(event),
                    
                    const SizedBox(height: 24),
                    
                    // Venue information
                    _buildVenueSection(event),
                    
                    const SizedBox(height: 24),
                    
                    // Family suitability
                    _buildFamilySuitabilitySection(event),
                    
                    const SizedBox(height: 100), // Space for floating button
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    Widget _buildQuickInfoSection(Event event) {
      return Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              icon: LucideIcons.calendar,
              title: 'Date',
              value: DateFormat('MMM dd, yyyy').format(event.startDate),
              color: AppColors.dubaiTeal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              icon: LucideIcons.clock,
              title: 'Time',
              value: DateFormat('HH:mm').format(event.startDate),
              color: AppColors.dubaiCoral,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              icon: LucideIcons.dollarSign,
              title: 'Price',
              value: event.pricing.minPrice == 0 
                  ? 'FREE' 
                  : 'AED ${event.pricing.minPrice}',
              color: AppColors.dubaiGold,
            ),
          ),
        ],
      );
    }
    
    Widget _buildInfoCard({
      required IconData icon,
      required String title,
      required String value,
      required Color color,
    }) {
      return BubbleDecoration(
        borderRadius: 16,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    // Additional methods for other sections...
    Color _getScoreColor(int score) {
      if (score >= 80) return AppColors.dubaiTeal;
      if (score >= 60) return AppColors.dubaiGold;
      return AppColors.dubaiCoral;
    }
    
    void _shareEvent(Event event) {
      // Implement sharing functionality
    }
  }
  ```

### 5.2 Search Screen with Smart Filters
- [ ] Create advanced search interface:
  ```dart
  // features/search/search_screen.dart
  class SearchScreen extends ConsumerStatefulWidget {
    const SearchScreen({Key? key}) : super(key: key);
    
    @override
    ConsumerState<SearchScreen> createState() => _SearchScreenState();
  }
  
  class _SearchScreenState extends ConsumerState<SearchScreen>
      with TickerProviderStateMixin {
    final TextEditingController _searchController = TextEditingController();
    late AnimationController _filterAnimationController;
    bool _showFilters = false;
    
    @override
    void initState() {
      super.initState();
    _filterAnimationController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
    }
    
    @override
    void dispose() {
      _searchController.dispose();
      _filterAnimationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return
style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    void _nextStep() {
      if (_currentStep < _steps.length - 1) {
        if (_validateCurrentStep()) {
          setState(() {
            _currentStep++;
          });
        }
      } else {
        _handleRegistration();
      }
    }
    
    void _previousStep() {
      if (_currentStep > 0) {
        setState(() {
          _currentStep--;
        });
      }
    }
    
    bool _validateCurrentStep() {
      switch (_currentStep) {
        case 0:
          return _formKey.currentState?.validate() ?? false;
        case 1:
          return true; // Family setup is optional
        case 2:
          return true; // Preferences are optional
        default:
          return true;
      }
    }
    
    void _handleRegistration() {
      // Implement registration logic
      ref.read(authProvider.notifier).register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        familyMembers: _familyMembers,
        interests: _selectedInterests,
        preferredAreas: _selectedAreas,
      );
    }
    
    void _showAddFamilyMemberDialog() {
      showDialog(
        context: context,
        builder: (context) => AddFamilyMemberDialog(
          onAdd: (member) {
            setState(() {
              _familyMembers.add(member);
            });
          },
        ),
      );
    }
    
    void _removeFamilyMember(int index) {
      setState(() {
        _familyMembers.removeAt(index);
      });
    }
    
    void _toggleInterest(String interest) {
      setState(() {
        if (_selectedInterests.contains(interest)) {
          _selectedInterests.remove(interest);
        } else {
          _selectedInterests.add(interest);
        }
      });
    }
    
    void _toggleArea(String area) {
      setState(() {
        if (_selectedAreas.contains(area)) {
          _selectedAreas.remove(area);
        } else {
          _selectedAreas.add(area);
        }
      });
    }
  }
  
  // Supporting classes
  class FamilyMember {
    final String name;
    final int age;
    final String relationship;
    
    const FamilyMember({
      required this.name,
      required this.age,
      required this.relationship,
    });
  }
  
  class InterestCategory {
    final String emoji;
    final String name;
    final Color color;
    
    const InterestCategory(this.emoji, this.name, this.color);
  }
  
  class AddFamilyMemberDialog extends StatefulWidget {
    final Function(FamilyMember) onAdd;
    
    const AddFamilyMemberDialog({Key? key, required this.onAdd}) : super(key: key);
    
    @override
    State<AddFamilyMemberDialog> createState() => _AddFamilyMemberDialogState();
  }
  
  class _AddFamilyMemberDialogState extends State<AddFamilyMemberDialog> {
    final _nameController = TextEditingController();
    final _ageController = TextEditingController();
    String _selectedRelationship = 'child';
    
    @override
    Widget build(BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Family Member',
                style: GoogleFonts.comfortaa(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRelationship,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  border: OutlineInputBorder(),
                ),
                items: ['child', 'spouse', 'parent', 'other']
                    .map((rel) => DropdownMenuItem(
                          value: rel,
                          child: Text(rel.capitalize()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRelationship = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addMember,
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    
    void _addMember() {
      if (_nameController.text.isNotEmpty && _ageController.text.isNotEmpty) {
        widget.onAdd(FamilyMember(
          name: _nameController.text,
          age: int.parse(_ageController.text),
          relationship: _selectedRelationship,
        ));
        Navigator.pop(context);
      }
    }
  }
  
  extension StringExtension on String {
    String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
  }
  ```

### 6.4 Enhanced Profile Management
- [ ] Create comprehensive profile screen:
  ```dart
  // features/profile/profile_screen.dart
  class ProfileScreen extends ConsumerStatefulWidget {
    const ProfileScreen({Key? key}) : super(key: key);
    
    @override
    ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
  }
  
  class _ProfileScreenState extends ConsumerState<ProfileScreen>
      with TickerProviderStateMixin {
    late TabController _tabController;
    
    @override
    void initState() {
      super.initState();
      _tabController = TabController(length: 4, vsync: this);
    }
    
    @override
    void dispose() {
      _tabController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      final authState = ref.watch(authProvider);
      
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            // Profile header
            _buildProfileHeader(authState.user),
            
            // Tab bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.dubaiTeal,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.dubaiTeal,
                  tabs: const [
                    Tab(text: 'Family'),
                    Tab(text: 'Saved'),
                    Tab(text: 'Settings'),
                    Tab(text: 'Help'),
                  ],
                ),
              ),
            ),
            
            // Tab content
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFamilyTab(),
                  _buildSavedEventsTab(),
                  _buildSettingsTab(),
                  _buildHelpTab(),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    Widget _buildProfileHeader(UserProfile? user) {
      return SliverToBoxAdapter(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.oceanGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile picture and info
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                            style: GoogleFonts.comfortaa(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.dubaiTeal,
                            ),
                          ),
                        ),
                      ).animate().scale(),
                      
                      const SizedBox(width: 20),
                      
                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Dubai Family',
                              style: GoogleFonts.comfortaa(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ).animate().fadeInLeft(),
                            
                            const SizedBox(height: 4),
                            
                            Text(
                              user?.email ?? 'user@example.com',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ).animate().fadeInLeft(delay: 200.ms),
                            
                            const SizedBox(height: 8),
                            
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.dubaiGold,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Premium Member',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ).animate().fadeInLeft(delay: 400.ms),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('Events\nAttended', '42', LucideIcons.calendar),
                      _buildStatCard('Events\nSaved', '18', LucideIcons.heart),
                      _buildStatCard('Family\nScore', '95', LucideIcons.star),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    Widget _buildStatCard(String title, String value, IconData icon) {
      return BubbleDecoration(
        bubbleColor: Colors.white.withOpacity(0.9),
        borderRadius: 16,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: AppColors.dubaiTeal, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.comfortaa(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ).animate().scale(delay: 600.ms);
    }
    
    Widget _buildFamilyTab() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Family members section
            _buildSectionHeader('Family Members', LucideIcons.users),
            const SizedBox(height: 16),
            _buildFamilyMembersList(),
            
            const SizedBox(height: 32),
            
            // Preferences section
            _buildSectionHeader('Interests & Preferences', LucideIcons.heart),
            const SizedBox(height: 16),
            _buildInterestsList(),
            
            const SizedBox(height: 32),
            
            // Preferred areas
            _buildSectionHeader('Preferred Areas', LucideIcons.mapPin),
            const SizedBox(height: 16),
            _buildPreferredAreasList(),
          ],
        ),
      );
    }
    
    Widget _buildSectionHeader(String title, IconData icon) {
      return Row(
        children: [
          Icon(icon, color: AppColors.dubaiTeal, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.comfortaa(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      );
    }
    
    Widget _buildSavedEventsTab() {
      final savedEvents = ref.watch(savedEventsProvider);
      
      if (savedEvents.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppColors.dubaiCoral.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.heart,
                  size: 60,
                  color: AppColors.dubaiCoral,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Saved Events Yet',
                style: GoogleFonts.comfortaa(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start exploring and save events\nyou\'d like to attend',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.pushNamed('events'),
                child: const Text('Explore Events'),
              ),
            ],
          ),
        );
      }
      
      // Show saved events list
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: savedEvents.length,
        itemBuilder: (context, index) {
          // Implementation for saved events list
          return Container(); // Placeholder
        },
      );
    }
  }
  
  // Sticky tab bar delegate
  class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
    final TabBar tabBar;
    
    _StickyTabBarDelegate(this.tabBar);
    
    @override
    double get minExtent => tabBar.preferredSize.height;
    
    @override
    double get maxExtent => tabBar.preferredSize.height;
    
    @override
    Widget build(context, double shrinkOffset, bool overlapsContent) {
      return Container(
        color: Colors.white,
        child: tabBar,
      );
    }
    
    @override
    bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
  }
  ```
PHASE 5: Event Details & Search (Week 5) - Continued
5.3 Event Details Content Sections

 Create rich event details sections:
dart// features/events/widgets/event_details_sections.dart
class EventDetailsSections extends StatelessWidget {
  final Event event;
  
  const EventDetailsSections({Key? key, required this.event}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAISummarySection(),
        const SizedBox(height: 24),
        _buildDescriptionSection(),
        const SizedBox(height: 24),
        _buildVenueSection(),
        const SizedBox(height: 24),
        _buildFamilySuitabilitySection(),
        const SizedBox(height: 24),
        _buildLogisticsSection(),
        const SizedBox(height: 24),
        _buildSimilarEventsSection(),
      ],
    );
  }
  
  Widget _buildAISummarySection() {
    return BubbleDecoration(
      borderRadius: 20,
      bubbleColor: AppColors.dubaiTeal.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.oceanGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.brain,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'AI Summary',
                  style: GoogleFonts.comfortaa(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              event.aiSummary,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    ).animate().slideInLeft();
  }
  
  Widget _buildDescriptionSection() {
    return BubbleDecoration(
      borderRadius: 20,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.fileText,
                  color: AppColors.dubaiCoral,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Event Details',
                  style: GoogleFonts.comfortaa(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              event.description,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    ).animate().slideInRight(delay: 200.ms);
  }
  
  Widget _buildVenueSection() {
    return BubbleDecoration(
      borderRadius: 20,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.mapPin,
                  color: AppColors.dubaiGold,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Venue Information',
                  style: GoogleFonts.comfortaa(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Venue name and address
            Text(
              event.venue.name,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              event.venue.address,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Amenities
            if (event.venue.amenities.isNotEmpty) ...[
              Text(
                'Amenities',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: event.venue.amenities.map((amenity) =>
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dubaiGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.dubaiGold.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      amenity,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.dubaiGold,
                      ),
                    ),
                  ),
                ).toList(),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Map button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openMap(event.venue),
                icon: const Icon(LucideIcons.navigation),
                label: const Text('View on Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dubaiGold,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideInLeft(delay: 400.ms);
  }
  
  Widget _buildFamilySuitabilitySection() {
    return BubbleDecoration(
      borderRadius: 20,
      bubbleColor: AppColors.dubaiPurple.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.dubaiPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.users,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Family Suitability',
                  style: GoogleFonts.comfortaa(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Age range
            _buildSuitabilityItem(
              icon: LucideIcons.baby,
              label: 'Age Range',
              value: '${event.familySuitability.ageMin}-${event.familySuitability.ageMax} years',
              color: AppColors.dubaiPurple,
            ),
            
            const SizedBox(height: 12),
            
            // Family friendly indicator
            _buildSuitabilityItem(
              icon: event.familySuitability.familyFriendly 
                  ? LucideIcons.check 
                  : LucideIcons.x,
              label: 'Family Friendly',
              value: event.familySuitability.familyFriendly 
                  ? 'Yes' 
                  : 'Not Recommended',
              color: event.familySuitability.familyFriendly 
                  ? AppColors.dubaiTeal 
                  : AppColors.dubaiCoral,
            ),
            
            const SizedBox(height: 12),
            
            // Stroller friendly
            if (event.familySuitability.strollerFriendly != null)
              _buildSuitabilityItem(
                icon: event.familySuitability.strollerFriendly! 
                    ? LucideIcons.check 
                    : LucideIcons.x,
                label: 'Stroller Friendly',
                value: event.familySuitability.strollerFriendly! 
                    ? 'Yes' 
                    : 'No',
                color: event.familySuitability.strollerFriendly! 
                    ? AppColors.dubaiTeal 
                    : AppColors.dubaiCoral,
              ),
          ],
        ),
      ),
    ).animate().slideInRight(delay: 600.ms);
  }
  
  Widget _buildSuitabilityItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
  
  void _openMap(Venue venue) {
    // Implement map opening logic
  }
}


5.4 Floating Action Button

 Create booking/save floating button:
dart// features/events/widgets/floating_action_section.dart
class EventFloatingActions extends ConsumerWidget {
  final Event event;
  
  const EventFloatingActions({Key? key, required this.event}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedEvents = ref.watch(savedEventsProvider);
    final isSaved = savedEvents.contains(event.id);
    
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: BubbleDecoration(
        borderRadius: 25,
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Save button
              GestureDetector(
                onTap: () => _toggleSave(ref),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSaved 
                        ? AppColors.dubaiCoral.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSaved 
                          ? AppColors.dubaiCoral
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    isSaved ? LucideIcons.heart : LucideIcons.heart,
                    color: isSaved ? AppColors.dubaiCoral : Colors.grey,
                    size: 24,
                  ),
                ),
              ).animate().scale(
                duration: const Duration(milliseconds: 200),
              ),
              
              const SizedBox(width: 16),
              
              // Book/Get Tickets button
              Expanded(
                child: PulsingButton(
                  pulseColor: AppColors.dubaiTeal,
                  onPressed: () => _handleBooking(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.oceanGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.ticket,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            event.pricing.minPrice == 0 
                                ? 'Get Free Tickets' 
                                : 'Book Now - AED ${event.pricing.minPrice}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
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
        ),
      ),
    ).animate().slideInUp(delay: 800.ms);
  }
  
  void _toggleSave(WidgetRef ref) {
    ref.read(savedEventsProvider.notifier).toggleSaveEvent(event.id);
  }
  
  void _handleBooking() {
    // Implement booking logic
  }
}



PHASE 6: Authentication & Profile (Week 6)
6.1 Welcome/Onboarding Screens

 Create engaging welcome flow:
dart// features/auth/welcome_screen.dart
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);
  
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;
  
  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Discover Amazing\nFamily Events! 🎉',
      description: 'Find the perfect activities for your family in Dubai with our AI-powered recommendations',
      imagePath: 'assets/illustrations/family_fun.svg',
      primaryColor: AppColors.dubaiTeal,
      secondaryColor: AppColors.dubaiCoral,
    ),
    OnboardingData(
      title: 'Smart Family\nRecommendations 🤖',
      description: 'Our AI learns your family\'s preferences to suggest events that everyone will love',
      imagePath: 'assets/illustrations/ai_recommendations.svg',
      primaryColor: AppColors.dubaiPurple,
      secondaryColor: AppColors.dubaiGold,
    ),
    OnboardingData(
      title: 'Never Miss\nThe Fun! ⏰',
      description: 'Get personalized notifications for events that match your schedule and interests',
      imagePath: 'assets/illustrations/notifications.svg',
      primaryColor: AppColors.dubaiGold,
      secondaryColor: AppColors.dubaiTeal,
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with floating bubbles
          _buildAnimatedBackground(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                _buildSkipButton(),
                
                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) => _buildOnboardingPage(_pages[index]),
                  ),
                ),
                
                // Bottom section
                _buildBottomSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedBackground() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _pages[_currentPage].primaryColor.withOpacity(0.1),
            _pages[_currentPage].secondaryColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Stack(
        children: List.generate(10, (index) => 
          Positioned(
            top: Random().nextDouble() * MediaQuery.of(context).size.height,
            left: Random().nextDouble() * MediaQuery.of(context).size.width,
            child: FloatingBubble(
              size: 20 + Random().nextDouble() * 60,
              color: _pages[_currentPage].primaryColor.withOpacity(0.1),
            ).animate().scale(
              delay: Duration(milliseconds: index * 200),
              duration: const Duration(seconds: 2),
            ).then().moveY(
              begin: 0,
              end: -100,
              duration: const Duration(seconds: 8),
              curve: Curves.easeInOut,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSkipButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.topRight,
        child: TextButton(
          onPressed: () => _skipToLogin(),
          child: Text(
            'Skip',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    ).animate().fadeInRight();
  }
  
  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            height: 300,
            child: SvgPicture.asset(
              data.imagePath,
              height: 300,
              fit: BoxFit.contain,
            ),
          ).animate().scale(
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
          ),
          
          const SizedBox(height: 60),
          
          // Title
          Text(
            data.title,
            style: GoogleFonts.comfortaa(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeInUp(delay: 300.ms),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            data.description,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeInUp(delay: 500.ms),
        ],
      ),
    );
  }
  
  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index 
                      ? _pages[_currentPage].primaryColor
                      : Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Action buttons
          Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _previousPage(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      side: BorderSide(
                        color: _pages[_currentPage].primaryColor,
                      ),
                    ),
                    child: Text(
                      'Back',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _pages[_currentPage].primaryColor,
                      ),
                    ),
                  ),
                ),
              
              if (_currentPage > 0) const SizedBox(width: 16),
              
              Expanded(
                flex: _currentPage == 0 ? 1 : 2,
                child: PulsingButton(
                  pulseColor: _pages[_currentPage].primaryColor,
                  onPressed: () => _nextPage(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _pages[_currentPage].primaryColor,
                          _pages[_currentPage].secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started! 🚀' : 'Next',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }
  
  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  void _skipToLogin() {
    context.pushReplacementNamed('login');
  }
  
  void _goToLogin() {
    context.pushReplacementNamed('login');
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String imagePath;
  final Color primaryColor;
  final Color secondaryColor;
  
  const OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.primaryColor,
    required this.secondaryColor,
  });
}


6.2 Enhanced Login Screen

 Create welcoming login experience:
dart// features/auth/login_screen.dart
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      body: Stack(
        children: [
          // Background with floating bubbles
          _buildAnimatedBackground(),
          
          // Login form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo and welcome text
                          _buildWelcomeSection(),
                          
                          const SizedBox(height: 40),
                          
                          // Login form
                          _buildLoginForm(authState),
                          
                          const SizedBox(height: 24),
                          
                          // Social login options
                          _buildSocialLoginSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Sign up link
                          _buildSignUpLink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFE2E8F0),
          ],
        ),
      ),
      child: Stack(
        children: List.generate(8, (index) => 
          Positioned(
            top: Random().nextDouble() * MediaQuery.of(context).size.height,
            left: Random().nextDouble() * MediaQuery.of(context).size.width,
            child: FloatingBubble(
              size: 30 + Random().nextDouble() * 60,
              color: AppColors.dubaiTeal.withOpacity(0.1),
            ).animate().scale(
              delay: Duration(milliseconds: index * 300),
              duration: const Duration(seconds: 3),
            ).then().moveY(
              begin: 0,
              end: -100,
              duration: const Duration(seconds: 6),
              curve: Curves.easeInOut,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildWelcomeSection() {
    return Column(
      children: [
        // App logo with animation
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.oceanGradient,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.dubaiTeal.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            LucideIcons.calendar,
            size: 40,
            color: Colors.white,
          ),
        ).animate().scale(delay: 300.ms),
        
        const SizedBox(height: 24),
        
        Text(
          'Welcome to DXB Events! 🎉',
          style: GoogleFonts.comfortaa(
            fontSize:


---

## PHASE 7: Performance & Animations (Week 7)

### 7.1 Advanced Animation Components
- [ ] Create reusable animation widgets:
  ```dart
  // core/widgets/advanced_animations.dart
  class MorphingCard extends StatefulWidget {
    final Widget child;
    final Widget expandedChild;
    final bool isExpanded;
    final Duration duration;
    
    const MorphingCard({
      Key? key,
      required this.child,
      required this.expandedChild,
      required this.isExpanded,
      this.duration = const Duration(milliseconds: 600),
    }) : super(key: key);
    
    @override
    State<MorphingCard> createState() => _MorphingCardState();
  }
  
  class _MorphingCardState extends State<MorphingCard>
      with SingleTickerProviderStateMixin {
    late AnimationController _controller;
    late Animation<double> _expandAnimation;
    late Animation<double> _fadeAnimation;
    
    @override
    void initState() {
      super.initState();
      _controller = AnimationController(duration: widget.duration, vsync: this);
      
      _expandAnimation = CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      );
      
      _fadeAnimation = Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5),
      ));
    }
    
    @override
    void didUpdateWidget(MorphingCard oldWidget) {
      super.didUpdateWidget(oldWidget);
      if (widget.isExpanded != oldWidget.isExpanded) {
        if (widget.isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      }
    }
    
    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizeTransition(
            sizeFactor: _expandAnimation,
            child: FadeTransition(
              opacity: widget.isExpanded 
                  ? Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.5, 1.0),
                      ),
                    )
                  : _fadeAnimation,
              child: widget.isExpanded ? widget.expandedChild : widget.child,
            ),
          );
        },
      );
    }
  }
  
  class StaggeredList extends StatefulWidget {
    final List<Widget> children;
    final Duration delay;
    final Duration interval;
    
    const StaggeredList({
      Key? key,
      required this.children,
      this.delay = const Duration(milliseconds: 100),
      this.interval = const Duration(milliseconds: 100),
    }) : super(key: key);
    
    @override
    State<StaggeredList> createState() => _StaggeredListState();
  }
  
  class _StaggeredListState extends State<StaggeredList>
      with TickerProviderStateMixin {
    late List<AnimationController> _controllers;
    late List<Animation<Offset>> _animations;
    
    @override
    void initState() {
      super.initState();
      _controllers = List.generate(
        widget.children.length,
        (index) => AnimationController(
          duration: const Duration(milliseconds: 600),
          vsync: this,
        ),
      );
      
      _animations = _controllers.map((controller) =>
        Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        )),
      ).toList();
      
      _startAnimations();
    }
    
    void _startAnimations() async {
      await Future.delayed(widget.delay);
      for (int i = 0; i < _controllers.length; i++) {
        _controllers[i].forward();
        if (i < _controllers.length - 1) {
          await Future.delayed(widget.interval);
        }
      }
    }
    
    @override
    void dispose() {
      for (var controller in _controllers) {
        controller.dispose();
      }
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return Column(
        children: List.generate(
          widget.children.length,
          (index) => SlideTransition(
            position: _animations[index],
            child: FadeTransition(
              opacity: _controllers[index],
              child: widget.children[index],
            ),
          ),
        ),
      );
    }
  }
  
  class ParallaxBackground extends StatefulWidget {
    final Widget child;
    final String backgroundImage;
    final double parallaxFactor;
    
    const ParallaxBackground({
      Key? key,
      required this.child,
      required this.backgroundImage,
      this.parallaxFactor = 0.5,
    }) : super(key: key);
    
    @override
    State<ParallaxBackground> createState() => _ParallaxBackgroundState();
  }
  
  class _ParallaxBackgroundState extends State<ParallaxBackground> {
    late ScrollController _scrollController;
    double _scrollOffset = 0.0;
    
    @override
    void initState() {
      super.initState();
      _scrollController = ScrollController();
      _scrollController.addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });
    }
    
    @override
    void dispose() {
      _scrollController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return Stack(
        children: [
          // Parallax background
          Transform.translate(
            offset: Offset(0, -_scrollOffset * widget.parallaxFactor),
            child: Container(
              height: MediaQuery.of(context).size.height * 1.2,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.backgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // Content
          SingleChildScrollView(
            controller: _scrollController,
            child: widget.child,
          ),
        ],
      );
    }
  }
  ```

### 7.2 Performance Optimizations
- [ ] Implement efficient loading states:
  ```dart
  // core/widgets/performance_optimized.dart
  class LazyLoadingGrid extends StatefulWidget {
    final List<dynamic> items;
    final Widget Function(BuildContext, dynamic, int) itemBuilder;
    final int crossAxisCount;
    final VoidCallback? onLoadMore;
    final bool hasMore;
    
    const LazyLoadingGrid({
      Key? key,
      required this.items,
      required this.itemBuilder,
      this.crossAxisCount = 2,
      this.onLoadMore,
      this.hasMore = false,
    }) : super(key: key);
    
    @override
    State<LazyLoadingGrid> createState() => _LazyLoadingGridState();
  }
  
  class _LazyLoadingGridState extends State<LazyLoadingGrid> {
    final ScrollController _scrollController = ScrollController();
    final Set<int> _loadedItems = {};
    
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
          _scrollController.position.maxScrollExtent * 0.8) {
        if (widget.hasMore) {
          widget.onLoadMore?.call();
        }
      }
    }
    
    @override
    Widget build(BuildContext context) {
      return GridView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: widget.items.length + (widget.hasMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= widget.items.length) {
            return _buildLoadingCard();
          }
          
          // Lazy load items as they come into view
          if (!_loadedItems.contains(index)) {
            _loadedItems.add(index);
            return FadeInSlideUp(
              delay: Duration(milliseconds: index * 50),
              child: widget.itemBuilder(context, widget.items[index], index),
            );
          }
          
          return widget.itemBuilder(context, widget.items[index], index);
        },
      );
    }
    
    Widget _buildLoadingCard() {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }
  
  class CachedImageWidget extends StatefulWidget {
    final String imageUrl;
    final double? width;
    final double? height;
    final BoxFit fit;
    final Widget? placeholder;
    final Widget? errorWidget;
    
    const CachedImageWidget({
      Key? key,
      required this.imageUrl,
      this.width,
      this.height,
      this.fit = BoxFit.cover,
      this.placeholder,
      this.errorWidget,
    }) : super(key: key);
    
    @override
    State<CachedImageWidget> createState() => _CachedImageWidgetState();
  }
  
  class _CachedImageWidgetState extends State<CachedImageWidget> {
    late ImageProvider _imageProvider;
    ImageStream? _imageStream;
    ImageInfo? _imageInfo;
    bool _isLoading = true;
    bool _hasError = false;
    
    @override
    void initState() {
      super.initState();
      _loadImage();
    }
    
    @override
    void didUpdateWidget(CachedImageWidget oldWidget) {
      super.didUpdateWidget(oldWidget);
      if (widget.imageUrl != oldWidget.imageUrl) {
        _loadImage();
      }
    }
    
    void _loadImage() {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      
      _imageProvider = CachedNetworkImageProvider(widget.imageUrl);
      _imageStream = _imageProvider.resolve(ImageConfiguration.empty);
      _imageStream!.addListener(
        ImageStreamListener(
          (ImageInfo info, bool _) {
            if (mounted) {
              setState(() {
                _imageInfo = info;
                _isLoading = false;
              });
            }
          },
          onError: (exception, stackTrace) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
            }
          },
        ),
      );
    }
    
    @override
    Widget build(BuildContext context) {
      if (_hasError) {
        return widget.errorWidget ?? _buildDefaultErrorWidget();
      }
      
      if (_isLoading) {
        return widget.placeholder ?? _buildDefaultPlaceholder();
      }
      
      return Image(
        image: _imageProvider,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    }
    
    Widget _buildDefaultPlaceholder() {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: AppColors.sunsetGradient.scale(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }
    
    Widget _buildDefaultErrorWidget() {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            LucideIcons.image,
            color: Colors.grey,
            size: 40,
          ),
        ),
      );
    }
    
    @override
    void dispose() {
      _imageStream?.removeListener(ImageStreamListener((_, __) {}));
      super.dispose();
    }
  }
  ```

---

## PHASE 8: Testing & Deployment (Week 8)

### 8.1 Comprehensive Testing Suite
- [ ] Create widget and integration tests:
  ```dart
  // test/widget_tests/event_card_test.dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  
  void main() {
    group('EventCard Widget Tests', () {
      late Event testEvent;
      
      setUp(() {
        testEvent = Event(
          id: 'test-event-1',
          title: 'Family Fun Day at Dubai Marina',
          description: 'A wonderful day out for the whole family',
          aiSummary: 'Perfect for families with children aged 3-12',
          startDate: DateTime.now().add(const Duration(days: 1)),
          venue: const Venue(
            name: 'Dubai Marina',
            address: 'Dubai Marina Walk, Dubai',
            area: 'Dubai Marina',
            amenities: ['parking', 'stroller_friendly', 'restrooms'],
          ),
          pricing: const Pricing(
            minPrice: 0,
            maxPrice: 50,
            currency: 'AED',
          ),
          familySuitability: const FamilySuitability(
            ageMin: 3,
            ageMax: 12,
            familyFriendly: true,
            strollerFriendly: true,
          ),
          categories: ['outdoor', 'family', 'free'],
          imageUrls: ['https://example.com/image.jpg'],
          familyScore: 92,
        );
      });
      
      testWidgets('should display event title and basic info', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: EventCard(event: testEvent),
              ),
            ),
          ),
        );
        
        expect(find.text('Family Fun Day at Dubai Marina'), findsOneWidget);
        expect(find.text('Dubai Marina'), findsOneWidget);
        expect(find.text('92'), findsOneWidget);
      });
      
      testWidgets('should handle save/unsave functionality', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: EventCard(event: testEvent),
              ),
            ),
          ),
        );
        
        // Find and tap the save button
        final saveButton = find.byIcon(LucideIcons.heart);
        expect(saveButton, findsOneWidget);
        
        await tester.tap(saveButton);
        await tester.pump();
        
        // Verify the event is saved (implementation depends on state management)
      });
      
      testWidgets('should trigger onTap callback when card is tapped', (WidgetTester tester) async {
        bool wasTapped = false;
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: EventCard(
                  event: testEvent,
                  onTap: () => wasTapped = true,
                ),
              ),
            ),
          ),
        );
        
        await tester.tap(find.byType(EventCard));
        expect(wasTapped, isTrue);
      });
      
      testWidgets('should display correct price information', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: EventCard(event: testEvent),
              ),
            ),
          ),
        );
        
        expect(find.text('FREE'), findsOneWidget);
        
        // Test with paid event
        final paidEvent = testEvent.copyWith(
          pricing: const Pricing(minPrice: 25, maxPrice: 50, currency: 'AED'),
        );
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: EventCard(event: paidEvent),
              ),
            ),
          ),
        );
        
        expect(find.text('AED 25'), findsOneWidget);
      });
    });
  }
  ```

### 8.2 Integration Testing
- [ ] Create end-to-end user flow tests:
  ```dart
  // integration_test/user_flow_test.dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:integration_test/integration_test.dart';
  import 'package:dxb_events_web/main.dart' as app;
  
  void main() {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    
    group('DXB Events User Flow Tests', () {
      testWidgets('complete onboarding and registration flow', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        
        // Test onboarding flow
        expect(find.text('Discover Amazing'), findsOneWidget);
        
        // Navigate through onboarding pages
        for (int i = 0; i < 3; i++) {
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
        }
        
        // Should navigate to login/register
        expect(find.text('Welcome to DXB Events!'), findsOneWidget);
        
        // Go to registration
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();
        
        // Fill registration form
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Full Name'),
          'Test Family Dubai',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email Address'),
          'test@example.com',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'),
          'password123',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm Password'),
          'password123',
        );
        
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        
        // Skip family setup for now
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        
        // Skip preferences for now
        await tester.tap(find.text('Create Account 🎉'));
        await tester.pumpAndSettle();
        
        // Should be on home screen after successful registration
        expect(find.text('Hello Dubai Families!'), findsOneWidget);
      });
      
      testWidgets('search and filter events flow', (WidgetTester tester) async {
        // Assuming user is already logged in
        app.main();
        await tester.pumpAndSettle();
        
        // Navigate to search
        await tester.tap(find.text('Search'));
        await tester.pumpAndSettle();
        
        // Enter search query
        await tester.enterText(
          find.byType(TextField),
          'family activities',
        );
        await tester.pumpAndSettle();
        
        // Apply filters
        await tester.tap(find.byIcon(LucideIcons.sliders));
        await tester.pumpAndSettle();
        
        // Select age group filter
        await tester.tap(find.text('3-5 years'));
        await tester.pumpAndSettle();
        
        // Select location filter
        await tester.tap(find.text('Dubai Marina'));
        await tester.pumpAndSettle();
        
        // Verify search results are displayed
        expect(find.byType(EventCard), findsWidgets);
      });
      
      testWidgets('event details and booking flow', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        
        // Tap on first event card
        await tester.tap(find.byType(EventCard).first);
        await tester.pumpAndSettle();
        
        // Should be on event details screen
        expect(find.byType(EventDetailsScreen), findsOneWidget);
        
        // Scroll to see more details
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -300),
        );
        await tester.pumpAndSettle();
        
        // Test save functionality
        await tester.tap(find.byIcon(LucideIcons.heart));
        await tester.pumpAndSettle();
        
        // Test booking button
        final bookingButton = find.textContaining('Book Now');
        if (tester.any(bookingButton)) {
          await tester.tap(bookingButton);
          await tester.pumpAndSettle();
        }
      });
      
      testWidgets('profile management flow', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        
        // Navigate to profile
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();
        
        // Should be on profile screen
        expect(find.text('Dubai Family'), findsOneWidget);
        
        // Test tab navigation
        await tester.tap(find.text('Family'));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Saved'));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
      });
    });
  }
  ```

### 8.3 Performance Testing
- [ ] Create performance benchmarks:
  ```dart
  // test/performance/performance_benchmarks.dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  
  void main() {
    group('Performance Benchmarks', () {
      testWidgets('event list scrolling performance', (WidgetTester tester) async {
        // Create large list of mock events
        final events = List.generate(1000, (index) => createMockEvent(index));
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: OptimizedEventsList(
                  events: events,
                  hasMore: false,
                ),
              ),
            ),
          ),
        );
        
        // Measure scrolling performance
        await tester.binding.watchPerformance(() async {
          // Perform fast scrolling
          await tester.fling(
            find.byType(ListView),
            const Offset(0, -5000),
            3000,
          );
          await tester.pumpAndSettle();
        }, reportKey: 'event_list_fast_scroll');
      });
      
      testWidgets('animation performance test', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: HomeScreen(),
          ),
        );
        
        await tester.binding.watchPerformance(() async {
          // Trigger all home screen animations
          await tester.pumpAndSettle();
          
          // Navigate between screens
          await tester.tap(find.text('Events'));
          await tester.pumpAndSettle();
          
          await tester.tap(find.text('Search'));
          await tester.pumpAndSettle();
          
          await tester.tap(find.text('Home'));
          await tester.pumpAndSettle();
        }, reportKey: 'navigation_animations');
      });
      
      testWidgets('image loading performance', (WidgetTester tester) async {
        // Test with multiple cached network images
        final imageUrls = List.generate(50, (index) => 
          'https://picsum.photos/300/200?random=$index');
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LazyLoadingGrid(
                items: imageUrls,
                itemBuilder: (context, url, index) => CachedImageWidget(
                  imageUrl: url,
                  width: 150,
                  height: 100,
                ),
              ),
            ),
          ),
        );
        
        await tester.binding.watchPerformance(() async {
          // Scroll through images
          await tester.drag(
            find.byType(GridView),
            const Offset(0, -2000),
          );
          await tester.pumpAndSettle();
        }, reportKey: 'image_loading_performance');
      });
      
      testWidgets('memory usage test', (WidgetTester tester) async {
        // Test memory usage with large datasets
        final largeDataset = List.generate(10000, (index) => {
          'id': index,
          'title': 'Event $index',
          'description': 'Description for event $index' * 10,
        });
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ListView.builder(
                  itemCount: largeDataset.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(largeDataset[index]['title']!),
                    subtitle: Text(largeDataset[index]['description']!),
                  ),
                ),
              ),
            ),
          ),
        );
        
        // Simulate heavy usage
        for (int i = 0; i < 10; i++) {
          await tester.drag(
            find.byType(ListView),
            const Offset(0, -1000),
          );
          await tester.pump();
        }
      });
    });
  }
  
  Event createMockEvent(int index) {
    return Event(
      id: 'event-$index',
      title: 'Mock Event $index',
      description: 'Description for mock event $index',
      aiSummary: 'AI summary for event $index',
      startDate: DateTime.now().add(Duration(days: index)),
      venue: Venue(
        name: 'Venue $index',
        address: 'Address $index',
        area: 'Area ${index % 5}',
        amenities: ['parking', 'wifi'],
      ),
      pricing: Pricing(
        minPrice: index % 2 == 0 ? 0 : 25,
        maxPrice: (index % 2 == 0 ? 0 : 25) + 50,
        currency: 'AED',
      ),
      familySuitability: FamilySuitability(
        ageMin: 0,
        ageMax: 12,
        familyFriendly: true,
      ),
      categories: ['category${index % 3}'],
      imageUrls: ['https://picsum.photos/300/200?random=$index'],
      familyScore: 80 + (index % 20),
    );
  }
  ```

### 8.4 Build Configuration & Deployment
- [ ] Set up build pipeline:
  ```yaml
  # .github/workflows/deploy.yml
  name: Deploy DXB Events Web
  
  on:
    push:
      branches: [ main ]
    pull_request:
      branches: [ main ]
  
  jobs:
    test:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v3
        
        - name: Setup Flutter
          uses: subosito/flutter-action@v2
          with:
            flutter-version: '3.24.0'
            
        - name: Install dependencies
          run: flutter pub get
          
        - name: Generate code
          run: flutter packages pub run build_runner build --delete-conflicting-outputs
          
        - name: Run tests
          run: flutter test
          
        - name: Run integration tests
          run: flutter test integration_test/
  
    build-and-deploy:
      needs: test
      runs-on: ubuntu-latest
      if: github.ref == 'refs/heads/main'
      
      steps:
        - uses: actions/checkout@v3
        
        - name: Setup Flutter
          uses: subosito/flutter-action@v2
          with:
            flutter-version: '3.24.0'
            
        - name: Install dependencies
          run: flutter pub get
          
        - name: Generate code
          run: flutter packages pub run build_runner build --delete-conflicting-outputs
          
        - name: Build web
          run: flutter build web --release --web-renderer html
          
        - name: Deploy to Netlify
          uses: nwtgck/actions-netlify@v2.0
          with:
            publish-dir: './build/web'
            production-branch: main
            github-token: ${{ secrets.GITHUB_TOKEN }}
            deploy-message: "Deploy from GitHub Actions"
          env:
            NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
            NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
  ```

- [ ] Create environment-specific configurations:
  ```dart
  // lib/core/config/app_config.dart
  abstract class AppConfig {
    static const String appName = 'DXB Events';
    static const String version = '1.0.0';
    
    // Environment-specific configurations
    static String get apiBaseUrl {
      const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
      switch (environment) {
        case 'production':
          return 'https://api.dxbevents.com';
        case 'staging':
          return 'https://staging-api.dxbevents.com';
        default:
          return 'http://localhost:8000';
      }
    }
    
    static String get googleMapsApiKey {
      return const String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');
    }
    
    static bool get enableAnalytics {
      return const bool.fromEnvironment('ENABLE_ANALYTICS', defaultValue: false);
    }
    
    static bool get isProduction {
      return const String.fromEnvironment('ENVIRONMENT') == 'production';
    }
    
    // Feature flags
    static bool get enablePushNotifications {
      return const bool.fromEnvironment('ENABLE_PUSH_NOTIFICATIONS', defaultValue: true);
    }
    
    static bool get enableSocialLogin {
      return const bool.fromEnvironment('ENABLE_SOCIAL_LOGIN', defaultValue: true);
    }
  }
  ```

### 8.5 Production Optimization
- [ ] Implement production optimizations:
  ```dart
  // lib/core/utils/performance_utils.dart
  class PerformanceUtils {
    static void optimizeForProduction() {
      // Disable debug prints in production
      if (AppConfig.isProduction) {
        debugPrint = (String? message, {int? wrapWidth}) {};
      }
      
      // Enable performance overlay in debug mode
      if (!AppConfig.isProduction) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Add performance monitoring
        });
      }
    }
    
    static Widget optimizedBuilder({
      required Widget child,
      bool enablePerformanceOverlay = false,
    }) {
      return RepaintBoundary(
        child: enablePerformanceOverlay && !AppConfig.isProduction
            ? Stack(
                children: [
                  child,
                  Positioned(
                    top: 50,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Performance Monitor',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              )
            : child,
      );
    }
  }
  
  // lib/core/utils/error_handler.dart
  class GlobalErrorHandler {
    static void initialize() {
      FlutterError.onError = (FlutterErrorDetails details) {
        if (AppConfig.isProduction) {
          // Send to crash reporting service
          _sendToCrashlytics(details);
        } else {
          // Print detailed error in development
          FlutterError.presentError(details);
        }
      };
      
      PlatformDispatcher.instance.onError = (error, stack) {
        if (AppConfig.isProduction) {
          _sendToCrashlytics(FlutterErrorDetails(
            exception: error,
            stack: stack,
          ));
        }
        return true;
      };
    }
    
    static void _sendToCrashlytics(FlutterErrorDetails details) {
      // Implement crash reporting
      print('Error sent to crash reporting: ${details.exception}');
    }
  }
  ```

---

## Final Success Criteria & Deployment Checklist

### ✅ Design & UX Completion
- [ ] All animations running at 60fps consistently
- [ ] Bubble design language implemented throughout
- [ ] Dubai-inspired color scheme with gradients
- [ ] Fun typography (Comfortaa, Nunito, Inter, Poppins) working
- [ ] Responsive design tested on various screen sizes
- [ ] Dark mode support (optional enhancement)

### ✅ Performance Benchmarks
- [ ] Initial load time under 3 seconds
- [ ] Smooth scrolling in event lists (60fps)
- [ ] Image loading optimized with caching
- [ ] Bundle size optimized (under 2MB gzipped)
- [ ] Memory usage stable during extended use
- [ ] Lighthouse score 90+ for performance

### ✅ Functionality Verification
- [ ] Complete authentication flow (onboarding → registration → login)
- [ ] Event discovery and search working
- [ ] Family profile management functional
- [ ] Save/unsave events working
- [ ] Advanced filtering operational
- [ ] Event details view complete
- [ ] Profile management with family setup

### ✅ API Integration
- [ ] All FastAPI endpoints integrated
- [ ] Error handling for network failures
- [ ] Offline state management
- [ ] Data synchronization working
- [ ] JWT token refresh implemented

### ✅ Testing Coverage
- [ ] Unit tests coverage >80%
- [ ] Widget tests for key components
- [ ] Integration tests for user flows
- [ ] Performance benchmarks established
- [ ] Cross-browser compatibility verified

### ✅ Production Deployment
- [ ] Environment configurations set up
- [ ] Build pipeline automated
- [ ] Error tracking implemented
- [ ] Analytics integration (optional)
- [ ] SEO optimization for web
- [ ] PWA capabilities enabled

### ✅ Mobile Preparation
- [ ] Responsive design works on mobile browsers
- [ ] Touch interactions optimized
- [ ] Progressive Web App features
- [ ] Offline-first architecture ready
- [ ] Code structured for easy mobile app extraction

---

## Final Cost Summary

### Monthly Operational Costs
- **Hosting (Netlify/Vercel Pro)**: $20-50
- **CDN & Image Optimization**: $10-30  
- **Analytics & Monitoring**: $0-50
- **Error Tracking**: $0-25
- **Domain & SSL**: $10-20

**Total Monthly: $40-175 USD (AED 150-650)**

### Development Assets (One-time)
- **Custom Illustrations**: $200-500
- **Icon Sets & Design Assets**: $50-150
- **Stock Photos**: $100-300

**Total One-time: $350-950 USD (AED 1,300-3,500)**

---

## Post-Launch Roadmap

### Phase 1: Optimization (Month 1-2)
- [ ] Performance monitoring and optimization
- [ ] User feedback integration
- [ ] Bug fixes and improvements
- [ ] A/B testing implementation

### Phase 2: Mobile App (Month 3-4)
- [ ] Extract shared code for mobile
- [ ] iOS and Android app development
- [ ] App store submission
- [ ] Push notifications implementation

### Phase 3: Advanced Features (Month 5-6)
- [ ] AI recommendation enhancement
- [ ] Social features and sharing
- [ ] Event booking integration
- [ ] Premium subscription features

This comprehensive Flutter frontend development checklist provides everything needed to create a world-class family events platform for Dubai's market, with beautiful animations, efficient performance, and a delightful user experience that families will love to use!            style: GoogleFonts.comfortaa(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeInUp(delay: 500.ms),
          
          const SizedBox(height: 8),
          
          Text(
            'Discover amazing family events\nin Dubai just for you',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeInUp(delay: 700.ms),
        ],
      );
    }
    
    Widget _buildLoginForm(AuthState authState) {
      return BubbleDecoration(
        borderRadius: 24,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Email field
                _buildCustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: LucideIcons.mail,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}# DXB Events Flutter Frontend - Development Checklist Part 2

## Continuation from Phase 5.2 - Advanced Features & Completion

---

## PHASE 5: Event Details & Search (Week 5) - Continued

### 5.3 Event Details Content Sections
- [ ] Create rich event details sections:
  ```dart
  // features/events/widgets/event_details_sections.dart
  class EventDetailsSections extends StatelessWidget {
    final Event event;
    
    const EventDetailsSections({Key? key, required this.event}) : super(key: key);
    
    @override
    Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAISummarySection(),
          const SizedBox(height: 24),
          _buildDescriptionSection(),
          const SizedBox(height: 24),
          _buildVenueSection(),
          const SizedBox(height: 24),
          _buildFamilySuitabilitySection(),
          const SizedBox(height: 24),
          _buildLogisticsSection(),
          const SizedBox(height: 24),
          _buildSimilarEventsSection(),
        ],
      );
    }
    
    Widget _buildAISummarySection() {
      return BubbleDecoration(
        borderRadius: 20,
        bubbleColor: AppColors.dubaiTeal.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.oceanGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.brain,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI Summary',
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                event.aiSummary,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ).animate().slideInLeft();
    }
    
    Widget _buildDescriptionSection() {
      return BubbleDecoration(
        borderRadius: 20,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.fileText,
                    color: AppColors.dubaiCoral,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Event Details',
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                event.description,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ).animate().slideInRight(delay: 200.ms);
    }
    
    Widget _buildVenueSection() {
      return BubbleDecoration(
        borderRadius: 20,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.mapPin,
                    color: AppColors.dubaiGold,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Venue Information',
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Venue name and address
              Text(
                event.venue.name,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                event.venue.address,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Amenities
              if (event.venue.amenities.isNotEmpty) ...[
                Text(
                  'Amenities',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: event.venue.amenities.map((amenity) =>
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.dubaiGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.dubaiGold.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        amenity,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.dubaiGold,
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Map button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openMap(event.venue),
                  icon: const Icon(LucideIcons.navigation),
                  label: const Text('View on Map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dubaiGold,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().slideInLeft(delay: 400.ms);
    }
    
    Widget _buildFamilySuitabilitySection() {
      return BubbleDecoration(
        borderRadius: 20,
        bubbleColor: AppColors.dubaiPurple.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.dubaiPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.users,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Family Suitability',
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Age range
              _buildSuitabilityItem(
                icon: LucideIcons.baby,
                label: 'Age Range',
                value: '${event.familySuitability.ageMin}-${event.familySuitability.ageMax} years',
                color: AppColors.dubaiPurple,
              ),
              
              const SizedBox(height: 12),
              
              // Family friendly indicator
              _buildSuitabilityItem(
                icon: event.familySuitability.familyFriendly 
                    ? LucideIcons.check 
                    : LucideIcons.x,
                label: 'Family Friendly',
                value: event.familySuitability.familyFriendly 
                    ? 'Yes' 
                    : 'Not Recommended',
                color: event.familySuitability.familyFriendly 
                    ? AppColors.dubaiTeal 
                    : AppColors.dubaiCoral,
              ),
              
              const SizedBox(height: 12),
              
              // Stroller friendly
              if (event.familySuitability.strollerFriendly != null)
                _buildSuitabilityItem(
                  icon: event.familySuitability.strollerFriendly! 
                      ? LucideIcons.check 
                      : LucideIcons.x,
                  label: 'Stroller Friendly',
                  value: event.familySuitability.strollerFriendly! 
                      ? 'Yes' 
                      : 'No',
                  color: event.familySuitability.strollerFriendly! 
                      ? AppColors.dubaiTeal 
                      : AppColors.dubaiCoral,
                ),
            ],
          ),
        ),
      ).animate().slideInRight(delay: 600.ms);
    }
    
    Widget _buildSuitabilityItem({
      required IconData icon,
      required String label,
      required String value,
      required Color color,
    }) {
      return Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      );
    }
    
    void _openMap(Venue venue) {
      // Implement map opening logic
    }
  }
  ```

### 5.4 Floating Action Button
- [ ] Create booking/save floating button:
  ```dart
  // features/events/widgets/floating_action_section.dart
  class EventFloatingActions extends ConsumerWidget {
    final Event event;
    
    const EventFloatingActions({Key? key, required this.event}) : super(key: key);
    
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final savedEvents = ref.watch(savedEventsProvider);
      final isSaved = savedEvents.contains(event.id);
      
      return Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: BubbleDecoration(
          borderRadius: 25,
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Save button
                GestureDetector(
                  onTap: () => _toggleSave(ref),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSaved 
                          ? AppColors.dubaiCoral.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSaved 
                            ? AppColors.dubaiCoral
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      isSaved ? LucideIcons.heart : LucideIcons.heart,
                      color: isSaved ? AppColors.dubaiCoral : Colors.grey,
                      size: 24,
                    ),
                  ),
                ).animate().scale(
                  duration: const Duration(milliseconds: 200),
                ),
                
                const SizedBox(width: 16),
                
                // Book/Get Tickets button
                Expanded(
                  child: PulsingButton(
                    pulseColor: AppColors.dubaiTeal,
                    onPressed: () => _handleBooking(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppColors.oceanGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              LucideIcons.ticket,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              event.pricing.minPrice == 0 
                                  ? 'Get Free Tickets' 
                                  : 'Book Now - AED ${event.pricing.minPrice}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
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
          ),
        ),
      ).animate().slideInUp(delay: 800.ms);
    }
    
    void _toggleSave(WidgetRef ref) {
      ref.read(savedEventsProvider.notifier).toggleSaveEvent(event.id);
    }
    
    void _handleBooking() {
      // Implement booking logic
    }
  }
  ```

---

## PHASE 6: Authentication & Profile (Week 6)

### 6.1 Welcome/Onboarding Screens
- [ ] Create engaging welcome flow:
  ```dart
  // features/auth/welcome_screen.dart
  class WelcomeScreen extends StatefulWidget {
    const WelcomeScreen({Key? key}) : super(key: key);
    
    @override
    State<WelcomeScreen> createState() => _WelcomeScreenState();
  }
  
  class _WelcomeScreenState extends State<WelcomeScreen>
      with TickerProviderStateMixin {
    late PageController _pageController;
    late AnimationController _animationController;
    int _currentPage = 0;
    
    final List<OnboardingData> _pages = [
      OnboardingData(
        title: 'Discover Amazing\nFamily Events! 🎉',
        description: 'Find the perfect activities for your family in Dubai with our AI-powered recommendations',
        imagePath: 'assets/illustrations/family_fun.svg',
        primaryColor: AppColors.dubaiTeal,
        secondaryColor: AppColors.dubaiCoral,
      ),
      OnboardingData(
        title: 'Smart Family\nRecommendations 🤖',
        description: 'Our AI learns your family\'s preferences to suggest events that everyone will love',
        imagePath: 'assets/illustrations/ai_recommendations.svg',
        primaryColor: AppColors.dubaiPurple,
        secondaryColor: AppColors.dubaiGold,
      ),
      OnboardingData(
        title: 'Never Miss\nThe Fun! ⏰',
        description: 'Get personalized notifications for events that match your schedule and interests',
        imagePath: 'assets/illustrations/notifications.svg',
        primaryColor: AppColors.dubaiGold,
        secondaryColor: AppColors.dubaiTeal,
      ),
    ];
    
    @override
    void initState() {
      super.initState();
      _pageController = PageController();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      _animationController.forward();
    }
    
    @override
    void dispose() {
      _pageController.dispose();
      _animationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Stack(
          children: [
            // Background with floating bubbles
            _buildAnimatedBackground(),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Skip button
                  _buildSkipButton(),
                  
                  // Page view
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _pages.length,
                      itemBuilder: (context, index) => _buildOnboardingPage(_pages[index]),
                    ),
                  ),
                  
                  // Bottom section
                  _buildBottomSection(),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    Widget _buildAnimatedBackground() {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _pages[_currentPage].primaryColor.withOpacity(0.1),
              _pages[_currentPage].secondaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Stack(
          children: List.generate(10, (index) => 
            Positioned(
              top: Random().nextDouble() * MediaQuery.of(context).size.height,
              left: Random().nextDouble() * MediaQuery.of(context).size.width,
              child: FloatingBubble(
                size: 20 + Random().nextDouble() * 60,
                color: _pages[_currentPage].primaryColor.withOpacity(0.1),
              ).animate().scale(
                delay: Duration(milliseconds: index * 200),
                duration: const Duration(seconds: 2),
              ).then().moveY(
                begin: 0,
                end: -100,
                duration: const Duration(seconds: 8),
                curve: Curves.easeInOut,
              ),
            ),
          ),
        ),
      );
    }
    
    Widget _buildSkipButton() {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.topRight,
          child: TextButton(
            onPressed: () => _skipToLogin(),
            child: Text(
              'Skip',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ).animate().fadeInRight();
    }
    
    Widget _buildOnboardingPage(OnboardingData data) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              height: 300,
              child: SvgPicture.asset(
                data.imagePath,
                height: 300,
                fit: BoxFit.contain,
              ),
            ).animate().scale(
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
            ),
            
            const SizedBox(height: 60),
            
            // Title
            Text(
              data.title,
              style: GoogleFonts.comfortaa(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeInUp(delay: 300.ms),
            
            const SizedBox(height: 20),
            
            // Description
            Text(
              data.description,
              style: GoogleFonts.inter(
                fontSize: 18,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeInUp(delay: 500.ms),
          ],
        ),
      );
    }
    
    Widget _buildBottomSection() {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index 
                        ? _pages[_currentPage].primaryColor
                        : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Action buttons
            Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _previousPage(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        side: BorderSide(
                          color: _pages[_currentPage].primaryColor,
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _pages[_currentPage].primaryColor,
                        ),
                      ),
                    ),
                  ),
                
                if (_currentPage > 0) const SizedBox(width: 16),
                
                Expanded(
                  flex: _currentPage == 0 ? 1 : 2,
                  child: PulsingButton(
                    pulseColor: _pages[_currentPage].primaryColor,
                    onPressed: () => _nextPage(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _pages[_currentPage].primaryColor,
                            _pages[_currentPage].secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: Text(
                          _currentPage == _pages.length - 1 ? 'Get Started! 🚀' : 'Next',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    void _nextPage() {
      if (_currentPage < _pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _goToLogin();
      }
    }
    
    void _previousPage() {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    
    void _skipToLogin() {
      context.pushReplacementNamed('login');
    }
    
    void _goToLogin() {
      context.pushReplacementNamed('login');
    }
  }
  
  class OnboardingData {
    final String title;
    final String description;
    final String imagePath;
    final Color primaryColor;
    final Color secondaryColor;
    
    const OnboardingData({
      required this.title,
      required this.description,
      required this.imagePath,
      required this.primaryColor,
      required this.secondaryColor,
    });
  }
  ```

### 6.2 Enhanced Login Screen
- [ ] Create welcoming login experience:
  ```dart
  // features/auth/login_screen.dart
  class LoginScreen extends ConsumerStatefulWidget {
    const LoginScreen({Key? key}) : super(key: key);
    
    @override
    ConsumerState<LoginScreen> createState() => _LoginScreenState();
  }
  
  class _LoginScreenState extends ConsumerState<LoginScreen>
      with TickerProviderStateMixin {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    
    late AnimationController _animationController;
    late Animation<double> _fadeAnimation;
    late Animation<Offset> _slideAnimation;
    
    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
      
      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ));
      
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ));
      
      _animationController.forward();
    }
    
    @override
    void dispose() {
      _emailController.dispose();
      _passwordController.dispose();
      _animationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      final authState = ref.watch(authProvider);
      
      return Scaffold(
        body: Stack(
          children: [
            // Background with floating bubbles
            _buildAnimatedBackground(),
            
            // Login form
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo and welcome text
                            _buildWelcomeSection(),
                            
                            const SizedBox(height: 40),
                            
                            // Login form
                            _buildLoginForm(authState),
                            
                            const SizedBox(height: 24),
                            
                            // Social login options
                            _buildSocialLoginSection(),
                            
                            const SizedBox(height: 24),
                            
                            // Sign up link
                            _buildSignUpLink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    Widget _buildAnimatedBackground() {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: Stack(
          children: List.generate(8, (index) => 
            Positioned(
              top: Random().nextDouble() * MediaQuery.of(context).size.height,
              left: Random().nextDouble() * MediaQuery.of(context).size.width,
              child: FloatingBubble(
                size: 30 + Random().nextDouble() * 60,
                color: AppColors.dubaiTeal.withOpacity(0.1),
              ).animate().scale(
                delay: Duration(milliseconds: index * 300),
                duration: const Duration(seconds: 3),
              ).then().moveY(
                begin: 0,
                end: -100,
                duration: const Duration(seconds: 6),
                curve: Curves.easeInOut,
              ),
            ),
          ),
        ),
      );
    }
    
    Widget _buildWelcomeSection() {
      return Column(
        children: [
          // App logo with animation
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.oceanGradient,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dubaiTeal.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.calendar,
              size: 40,
              color: Colors.white,
            ),
          ).animate().scale(delay: 300.ms),
          
          const SizedBox(height: 24),
          
          Text(
            'Welcome to DXB Events! 🎉',
            style: GoogleFonts.comfortaa(
              fontSize: ).hasMatch(value!)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Password field
                _buildCustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: LucideIcons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your password';
                    }
                    if (value!.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 8),
                
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Implement forgot password
                    },
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.dubaiTeal,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dubaiTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.dubaiTeal.withOpacity(0.3),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                
                if (authState.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dubaiCoral.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.dubaiCoral.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.alertCircle,
                          size: 16,
                          color: AppColors.dubaiCoral,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.dubaiCoral,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    
    Widget _buildCustomTextField({
      required TextEditingController controller,
      required String label,
      required IconData icon,
      bool isPassword = false,
      String? Function(String?)? validator,
    }) {
      return TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.dubaiTeal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.dubaiTeal, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
        ),
      );
    }
    
    Widget _buildSocialLoginSection() {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Or continue with',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                icon: 'assets/icons/google.svg',
                label: 'Google',
                onTap: () => _handleGoogleLogin(),
              ),
              _buildSocialButton(
                icon: 'assets/icons/apple.svg',
                label: 'Apple',
                onTap: () => _handleAppleLogin(),
              ),
              _buildSocialButton(
                icon: 'assets/icons/facebook.svg',
                label: 'Facebook',
                onTap: () => _handleFacebookLogin(),
              ),
            ],
          ),
        ],
      );
    }
    
    Widget _buildSocialButton({
      required String icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: BubbleDecoration(
          borderRadius: 16,
          child: Container(
            width: 80,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SvgPicture.asset(icon, width: 24, height: 24),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().scale(delay: 200.ms);
    }
    
    Widget _buildSignUpLink() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Don\'t have an account? ',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () => context.pushNamed('register'),
            child: Text(
              'Sign Up',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.dubaiTeal,
              ),
            ),
          ),
        ],
      );
    }
    
    void _handleLogin() async {
      if (_formKey.currentState?.validate() ?? false) {
        await ref.read(authProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );
        
        if (mounted && ref.read(authProvider).isAuthenticated) {
          context.goNamed('home');
        }
      }
    }
    
    void _handleGoogleLogin() {
      // Implement Google login
    }
    
    void _handleAppleLogin() {
      // Implement Apple login
    }
    
    void _handleFacebookLogin() {
      // Implement Facebook login
    }
  }
  ```

### 6.3 Registration Screen with Family Setup
- [ ] Create comprehensive registration flow:
  ```dart
  // features/auth/register_screen.dart
  class RegisterScreen extends ConsumerStatefulWidget {
    const RegisterScreen({Key? key}) : super(key: key);
    
    @override
    ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
  }
  
  class _RegisterScreenState extends ConsumerState<RegisterScreen>
      with TickerProviderStateMixin {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    
    late AnimationController _animationController;
    int _currentStep = 0;
    
    // Family setup data
    final List<FamilyMember> _familyMembers = [];
    final List<String> _selectedInterests = [];
    final List<String> _selectedAreas = [];
    
    final List<String> _steps = [
      'Personal Info',
      'Family Setup',
      'Preferences',
    ];
    
    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      _animationController.forward();
    }
    
    @override
    void dispose() {
      _nameController.dispose();
      _emailController.dispose();
      _passwordController.dispose();
      _confirmPasswordController.dispose();
      _animationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF8FAFC),
                    Color(0xFFE2E8F0),
                  ],
                ),
              ),
            ),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Header with back button
                  _buildHeader(),
                  
                  // Progress indicator
                  _buildProgressIndicator(),
                  
                  // Step content
                  Expanded(
                    child: _buildStepContent(),
                  ),
                  
                  // Navigation buttons
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    Widget _buildHeader() {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.arrowLeft,
                  size: 20,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Account',
                    style: GoogleFonts.comfortaa(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Step ${_currentStep + 1} of ${_steps.length}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeInDown();
    }
    
    Widget _buildProgressIndicator() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          children: List.generate(_steps.length, (index) {
            final isActive = index <= _currentStep;
            final isCompleted = index < _currentStep;
            
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < _steps.length - 1 ? 8 : 0),
                decoration: BoxDecoration(
                  color: isActive 
                      ? AppColors.dubaiTeal 
                      : Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: isCompleted
                    ? Container(
                        decoration: BoxDecoration(
                          color: AppColors.dubaiTeal,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    : null,
              ),
            );
          }),
        ),
      ).animate().slideInLeft(delay: 200.ms);
    }
    
    Widget _buildStepContent() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _getStepWidget(_currentStep),
        ),
      );
    }
    
    Widget _getStepWidget(int step) {
      switch (step) {
        case 0:
          return _buildPersonalInfoStep();
        case 1:
          return _buildFamilySetupStep();
        case 2:
          return _buildPreferencesStep();
        default:
          return _buildPersonalInfoStep();
      }
    }
    
    Widget _buildPersonalInfoStep() {
      return BubbleDecoration(
        key: const ValueKey('personal_info'),
        borderRadius: 24,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tell us about yourself 👋',
                  style: GoogleFonts.comfortaa(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'We\'ll use this to personalize your experience',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Name field
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: LucideIcons.user,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Email field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}# DXB Events Flutter Frontend - Development Checklist Part 2

## Continuation from Phase 5.2 - Advanced Features & Completion

---

## PHASE 5: Event Details & Search (Week 5) - Continued

### 5.3 Event Details Content Sections
- [ ] Create rich event details sections:
  ```dart
  // features/events/widgets/event_details_sections.dart
  class EventDetailsSections extends StatelessWidget {
    final Event event;
    
    const EventDetailsSections({Key? key, required this.event}) : super(key: key);
    
    @override
    Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAISummarySection(),
          const SizedBox(height: 24),
          _buildDescriptionSection(),
          const SizedBox(height: 24),
          _buildVenueSection(),
          const SizedBox(height: 24),
          _buildFamilySuitabilitySection(),
          const SizedBox(height: 24),
          _buildLogisticsSection(),
          const SizedBox(height: 24),
          _buildSimilarEventsSection(),
        ],
      );
    }
    
    Widget _buildAISummarySection() {
      return BubbleDecoration(
        borderRadius: 20,
        bubbleColor: AppColors.dubaiTeal.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.oceanGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.brain,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI Summary',
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                event.aiSummary,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ).animate().slideInLeft();
    }
    
    Widget _buildDescriptionSection() {
      return BubbleDecoration(
        borderRadius: 20,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.fileText,
                    color: AppColors.dubaiCoral,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Event Details',
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                event.description,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ).animate().slideInRight(delay: 200.ms);
    }
    
    Widget _buildVenueSection() {
      return BubbleDecoration(
        borderRadius: 20,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.mapPin,
                    color: AppColors.dubaiGold,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Venue Information',
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Venue name and address
              Text(
                event.venue.name,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                event.venue.address,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Amenities
              if (event.venue.amenities.isNotEmpty) ...[
                Text(
                  'Amenities',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: event.venue.amenities.map((amenity) =>
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.dubaiGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.dubaiGold.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        amenity,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.dubaiGold,
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Map button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openMap(event.venue),
                  icon: const Icon(LucideIcons.navigation),
                  label: const Text('View on Map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dubaiGold,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().slideInLeft(delay: 400.ms);
    }
    
    Widget _buildFamilySuitabilitySection() {
      return BubbleDecoration(
        borderRadius: 20,
        bubbleColor: AppColors.dubaiPurple.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.dubaiPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.users,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Family Suitability',
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Age range
              _buildSuitabilityItem(
                icon: LucideIcons.baby,
                label: 'Age Range',
                value: '${event.familySuitability.ageMin}-${event.familySuitability.ageMax} years',
                color: AppColors.dubaiPurple,
              ),
              
              const SizedBox(height: 12),
              
              // Family friendly indicator
              _buildSuitabilityItem(
                icon: event.familySuitability.familyFriendly 
                    ? LucideIcons.check 
                    : LucideIcons.x,
                label: 'Family Friendly',
                value: event.familySuitability.familyFriendly 
                    ? 'Yes' 
                    : 'Not Recommended',
                color: event.familySuitability.familyFriendly 
                    ? AppColors.dubaiTeal 
                    : AppColors.dubaiCoral,
              ),
              
              const SizedBox(height: 12),
              
              // Stroller friendly
              if (event.familySuitability.strollerFriendly != null)
                _buildSuitabilityItem(
                  icon: event.familySuitability.strollerFriendly! 
                      ? LucideIcons.check 
                      : LucideIcons.x,
                  label: 'Stroller Friendly',
                  value: event.familySuitability.strollerFriendly! 
                      ? 'Yes' 
                      : 'No',
                  color: event.familySuitability.strollerFriendly! 
                      ? AppColors.dubaiTeal 
                      : AppColors.dubaiCoral,
                ),
            ],
          ),
        ),
      ).animate().slideInRight(delay: 600.ms);
    }
    
    Widget _buildSuitabilityItem({
      required IconData icon,
      required String label,
      required String value,
      required Color color,
    }) {
      return Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      );
    }
    
    void _openMap(Venue venue) {
      // Implement map opening logic
    }
  }
  ```

### 5.4 Floating Action Button
- [ ] Create booking/save floating button:
  ```dart
  // features/events/widgets/floating_action_section.dart
  class EventFloatingActions extends ConsumerWidget {
    final Event event;
    
    const EventFloatingActions({Key? key, required this.event}) : super(key: key);
    
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final savedEvents = ref.watch(savedEventsProvider);
      final isSaved = savedEvents.contains(event.id);
      
      return Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: BubbleDecoration(
          borderRadius: 25,
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Save button
                GestureDetector(
                  onTap: () => _toggleSave(ref),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSaved 
                          ? AppColors.dubaiCoral.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSaved 
                            ? AppColors.dubaiCoral
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      isSaved ? LucideIcons.heart : LucideIcons.heart,
                      color: isSaved ? AppColors.dubaiCoral : Colors.grey,
                      size: 24,
                    ),
                  ),
                ).animate().scale(
                  duration: const Duration(milliseconds: 200),
                ),
                
                const SizedBox(width: 16),
                
                // Book/Get Tickets button
                Expanded(
                  child: PulsingButton(
                    pulseColor: AppColors.dubaiTeal,
                    onPressed: () => _handleBooking(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppColors.oceanGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              LucideIcons.ticket,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              event.pricing.minPrice == 0 
                                  ? 'Get Free Tickets' 
                                  : 'Book Now - AED ${event.pricing.minPrice}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
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
          ),
        ),
      ).animate().slideInUp(delay: 800.ms);
    }
    
    void _toggleSave(WidgetRef ref) {
      ref.read(savedEventsProvider.notifier).toggleSaveEvent(event.id);
    }
    
    void _handleBooking() {
      // Implement booking logic
    }
  }
  ```

---

## PHASE 6: Authentication & Profile (Week 6)

### 6.1 Welcome/Onboarding Screens
- [ ] Create engaging welcome flow:
  ```dart
  // features/auth/welcome_screen.dart
  class WelcomeScreen extends StatefulWidget {
    const WelcomeScreen({Key? key}) : super(key: key);
    
    @override
    State<WelcomeScreen> createState() => _WelcomeScreenState();
  }
  
  class _WelcomeScreenState extends State<WelcomeScreen>
      with TickerProviderStateMixin {
    late PageController _pageController;
    late AnimationController _animationController;
    int _currentPage = 0;
    
    final List<OnboardingData> _pages = [
      OnboardingData(
        title: 'Discover Amazing\nFamily Events! 🎉',
        description: 'Find the perfect activities for your family in Dubai with our AI-powered recommendations',
        imagePath: 'assets/illustrations/family_fun.svg',
        primaryColor: AppColors.dubaiTeal,
        secondaryColor: AppColors.dubaiCoral,
      ),
      OnboardingData(
        title: 'Smart Family\nRecommendations 🤖',
        description: 'Our AI learns your family\'s preferences to suggest events that everyone will love',
        imagePath: 'assets/illustrations/ai_recommendations.svg',
        primaryColor: AppColors.dubaiPurple,
        secondaryColor: AppColors.dubaiGold,
      ),
      OnboardingData(
        title: 'Never Miss\nThe Fun! ⏰',
        description: 'Get personalized notifications for events that match your schedule and interests',
        imagePath: 'assets/illustrations/notifications.svg',
        primaryColor: AppColors.dubaiGold,
        secondaryColor: AppColors.dubaiTeal,
      ),
    ];
    
    @override
    void initState() {
      super.initState();
      _pageController = PageController();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      _animationController.forward();
    }
    
    @override
    void dispose() {
      _pageController.dispose();
      _animationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Stack(
          children: [
            // Background with floating bubbles
            _buildAnimatedBackground(),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Skip button
                  _buildSkipButton(),
                  
                  // Page view
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _pages.length,
                      itemBuilder: (context, index) => _buildOnboardingPage(_pages[index]),
                    ),
                  ),
                  
                  // Bottom section
                  _buildBottomSection(),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    Widget _buildAnimatedBackground() {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _pages[_currentPage].primaryColor.withOpacity(0.1),
              _pages[_currentPage].secondaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Stack(
          children: List.generate(10, (index) => 
            Positioned(
              top: Random().nextDouble() * MediaQuery.of(context).size.height,
              left: Random().nextDouble() * MediaQuery.of(context).size.width,
              child: FloatingBubble(
                size: 20 + Random().nextDouble() * 60,
                color: _pages[_currentPage].primaryColor.withOpacity(0.1),
              ).animate().scale(
                delay: Duration(milliseconds: index * 200),
                duration: const Duration(seconds: 2),
              ).then().moveY(
                begin: 0,
                end: -100,
                duration: const Duration(seconds: 8),
                curve: Curves.easeInOut,
              ),
            ),
          ),
        ),
      );
    }
    
    Widget _buildSkipButton() {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.topRight,
          child: TextButton(
            onPressed: () => _skipToLogin(),
            child: Text(
              'Skip',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ).animate().fadeInRight();
    }
    
    Widget _buildOnboardingPage(OnboardingData data) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              height: 300,
              child: SvgPicture.asset(
                data.imagePath,
                height: 300,
                fit: BoxFit.contain,
              ),
            ).animate().scale(
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
            ),
            
            const SizedBox(height: 60),
            
            // Title
            Text(
              data.title,
              style: GoogleFonts.comfortaa(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeInUp(delay: 300.ms),
            
            const SizedBox(height: 20),
            
            // Description
            Text(
              data.description,
              style: GoogleFonts.inter(
                fontSize: 18,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeInUp(delay: 500.ms),
          ],
        ),
      );
    }
    
    Widget _buildBottomSection() {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index 
                        ? _pages[_currentPage].primaryColor
                        : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Action buttons
            Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _previousPage(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        side: BorderSide(
                          color: _pages[_currentPage].primaryColor,
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _pages[_currentPage].primaryColor,
                        ),
                      ),
                    ),
                  ),
                
                if (_currentPage > 0) const SizedBox(width: 16),
                
                Expanded(
                  flex: _currentPage == 0 ? 1 : 2,
                  child: PulsingButton(
                    pulseColor: _pages[_currentPage].primaryColor,
                    onPressed: () => _nextPage(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _pages[_currentPage].primaryColor,
                            _pages[_currentPage].secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: Text(
                          _currentPage == _pages.length - 1 ? 'Get Started! 🚀' : 'Next',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    void _nextPage() {
      if (_currentPage < _pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _goToLogin();
      }
    }
    
    void _previousPage() {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    
    void _skipToLogin() {
      context.pushReplacementNamed('login');
    }
    
    void _goToLogin() {
      context.pushReplacementNamed('login');
    }
  }
  
  class OnboardingData {
    final String title;
    final String description;
    final String imagePath;
    final Color primaryColor;
    final Color secondaryColor;
    
    const OnboardingData({
      required this.title,
      required this.description,
      required this.imagePath,
      required this.primaryColor,
      required this.secondaryColor,
    });
  }
  ```

### 6.2 Enhanced Login Screen
- [ ] Create welcoming login experience:
  ```dart
  // features/auth/login_screen.dart
  class LoginScreen extends ConsumerStatefulWidget {
    const LoginScreen({Key? key}) : super(key: key);
    
    @override
    ConsumerState<LoginScreen> createState() => _LoginScreenState();
  }
  
  class _LoginScreenState extends ConsumerState<LoginScreen>
      with TickerProviderStateMixin {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    
    late AnimationController _animationController;
    late Animation<double> _fadeAnimation;
    late Animation<Offset> _slideAnimation;
    
    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
      
      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ));
      
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ));
      
      _animationController.forward();
    }
    
    @override
    void dispose() {
      _emailController.dispose();
      _passwordController.dispose();
      _animationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      final authState = ref.watch(authProvider);
      
      return Scaffold(
        body: Stack(
          children: [
            // Background with floating bubbles
            _buildAnimatedBackground(),
            
            // Login form
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo and welcome text
                            _buildWelcomeSection(),
                            
                            const SizedBox(height: 40),
                            
                            // Login form
                            _buildLoginForm(authState),
                            
                            const SizedBox(height: 24),
                            
                            // Social login options
                            _buildSocialLoginSection(),
                            
                            const SizedBox(height: 24),
                            
                            // Sign up link
                            _buildSignUpLink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    Widget _buildAnimatedBackground() {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: Stack(
          children: List.generate(8, (index) => 
            Positioned(
              top: Random().nextDouble() * MediaQuery.of(context).size.height,
              left: Random().nextDouble() * MediaQuery.of(context).size.width,
              child: FloatingBubble(
                size: 30 + Random().nextDouble() * 60,
                color: AppColors.dubaiTeal.withOpacity(0.1),
              ).animate().scale(
                delay: Duration(milliseconds: index * 300),
                duration: const Duration(seconds: 3),
              ).then().moveY(
                begin: 0,
                end: -100,
                duration: const Duration(seconds: 6),
                curve: Curves.easeInOut,
              ),
            ),
          ),
        ),
      );
    }
    
    Widget _buildWelcomeSection() {
      return Column(
        children: [
          // App logo with animation
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.oceanGradient,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dubaiTeal.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.calendar,
              size: 40,
              color: Colors.white,
            ),
          ).animate().scale(delay: 300.ms),
          
          const SizedBox(height: 24),
          
          Text(
            'Welcome to DXB Events! 🎉',
            style: GoogleFonts.comfortaa(
              fontSize: ).hasMatch(value!)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Password field
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: LucideIcons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a password';
                    }
                    if (value!.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Confirm password field
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  icon: LucideIcons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    Widget _buildFamilySetupStep() {
      return BubbleDecoration(
        key: const ValueKey('family_setup'),
        borderRadius: 24,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell us about your family 👨‍👩‍👧‍👦',
                style: GoogleFonts.comfortaa(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Add family members to get personalized recommendations',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Family members list
              if (_familyMembers.isNotEmpty) ...[
                ...List.generate(_familyMembers.length, (index) =>
                  _buildFamilyMemberCard(_familyMembers[index], index),
                ),
                const SizedBox(height: 16),
              ],
              
              // Add family member button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showAddFamilyMemberDialog(),
                  icon: const Icon(LucideIcons.plus),
                  label: const Text('Add Family Member'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(color: AppColors.dubaiTeal),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    Widget _buildFamilyMemberCard(FamilyMember member, int index) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.dubaiTeal.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.dubaiTeal.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.dubaiTeal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                member.relationship == 'child' 
                    ? LucideIcons.baby 
                    : LucideIcons.user,
                color: Colors.white,
                size: 16,
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${member.age} years old • ${member.relationship}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            GestureDetector(
              onTap: () => _removeFamilyMember(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.dubaiCoral.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.x,
                  color: AppColors.dubaiCoral,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ).animate().slideInLeft(delay: Duration(milliseconds: index * 100));
    }
    
    Widget _buildPreferencesStep() {
      return BubbleDecoration(
        key: const ValueKey('preferences'),
        borderRadius: 24,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What interests your family? 🎨',
                style: GoogleFonts.comfortaa(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Select interests to get better recommendations',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Interest categories
              _buildInterestSection(),
              
              const SizedBox(height: 32),
              
              // Preferred areas
              _buildAreaSection(),
            ],
          ),
        ),
      );
    }
    
    Widget _buildInterestSection() {
      final interests = [
        InterestCategory('🎨', 'Arts & Crafts', AppColors.dubaiCoral),
        InterestCategory('⚽', 'Sports', AppColors.dubaiTeal),
        InterestCategory('🎭', 'Entertainment', AppColors.dubaiPurple),
        InterestCategory('🧪', 'Science', AppColors.dubaiGold),
        InterestCategory('🏖️', 'Outdoor', AppColors.dubaiTeal),
        InterestCategory('🏠', 'Indoor', AppColors.dubaiCoral),
        InterestCategory('📚', 'Educational', AppColors.dubaiPurple),
        InterestCategory('🍳', 'Cooking', AppColors.dubaiGold),
      ];
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interests',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: interests.map((interest) =>
              GestureDetector(
                onTap: () => _toggleInterest(interest.name),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedInterests.contains(interest.name)
                        ? interest.color.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedInterests.contains(interest.name)
                          ? interest.color
                          : Colors.grey.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(interest.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        interest.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _selectedInterests.contains(interest.name)
                              ? interest.color
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).toList(),
          ),
        ],
      );
    }
    
    Widget _buildAreaSection() {
      final areas = [
        'Dubai Marina',
        'JBR',
        'Downtown Dubai',
        'DIFC',
        'Business Bay',
        'Jumeirah',
        'Dubai Hills',
        'Arabian Ranches',
      ];
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferred Areas',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: areas.map((area) =>
              FilterChip(
                label: Text(area),
                selected: _selectedAreas.contains(area),
                onSelected: (selected) => _toggleArea(area),
                backgroundColor: Colors.grey.withOpacity(0.1),
                selectedColor: AppColors.dubaiTeal.withOpacity(0.2),
                checkmarkColor: AppColors.dubaiTeal,
                side: BorderSide(
                  color: _selectedAreas.contains(area)
                      ? AppColors.dubaiTeal
                      : Colors.grey.withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ).toList(),
          ),
        ],
      );
    }
    
    Widget _buildTextField({
      required TextEditingController controller,
      required String label,
      required IconData icon,
      bool isPassword = false,
      TextInputType? keyboardType,
      String? Function(String?)? validator,
    }) {
      return TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.dubaiTeal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.dubaiTeal, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
        ),
      ).animate().slideInUp(delay: 100.ms);
    }
    
    Widget _buildNavigationButtons() {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _previousStep(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    side: const BorderSide(color: AppColors.dubaiTeal),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dubaiTeal,
                    ),
                  ),
                ),
              ),
            
            if (_currentStep > 0) const SizedBox(width: 16),
            
            Expanded(
              flex: _currentStep == 0 ? 1 : 2,
              child: ElevatedButton(
                onPressed: () => _nextStep(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dubaiTeal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  _currentStep == _steps.length - 1 ? 'Create Account 🎉' : 'Continue',
                  style: GoogleFonts.poppins(
                    fontSize: # DXB Events Flutter Frontend - Development Checklist Part 2

## Continuation from Phase 5.2 - Advanced Features & Completion

---

## PHASE 5: Event Details & Search (Week 5) - Continued

### 5.3 Event Details Content Sections
- [ ] Create rich event details sections:
  ```dart
  // features/events/widgets/event_details_sections.dart
  class EventDetailsSections extends StatelessWidget {
    final Event event;
    
    const EventDetailsSections({Key? key, required this.event}) : super(key: key);
    
    @override
    Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAISummarySection(),
          const SizedBox(height: 24),
          _buildDescriptionSection(),
          const SizedBox(height: 24),
          _buildVenueSection(),
          const SizedBox(height: 24),
          _buildFamilySuitabilitySection(),
          const SizedBox(height: 24),
          _buildLogisticsSection(),
          const SizedBox(height: 24),
          _buildSimilarEventsSection(),
        ],
      );
    }
    
    Widget _buildAISummarySection() {
      return BubbleDecoration(
        borderRadius: 20,
        bubbleColor: AppColors.dubaiTeal.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.oceanGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.brain,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI Summary',
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                event.aiSummary,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ).animate().slideInLeft();
    }
    
    Widget _buildDescriptionSection() {
      return BubbleDecoration(
        borderRadius: 20,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.fileText,
                    color: AppColors.dubaiCoral,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Event Details',
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                event.description,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ).animate().slideInRight(delay: 200.ms);
    }
    
    Widget _buildVenueSection() {
      return BubbleDecoration(
        borderRadius: 20,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.mapPin,
                    color: AppColors.dubaiGold,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Venue Information',
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Venue name and address
              Text(
                event.venue.name,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                event.venue.address,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Amenities
              if (event.venue.amenities.isNotEmpty) ...[
                Text(
                  'Amenities',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: event.venue.amenities.map((amenity) =>
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.dubaiGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.dubaiGold.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        amenity,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.dubaiGold,
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Map button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openMap(event.venue),
                  icon: const Icon(LucideIcons.navigation),
                  label: const Text('View on Map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dubaiGold,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().slideInLeft(delay: 400.ms);
    }
    
    Widget _buildFamilySuitabilitySection() {
      return BubbleDecoration(
        borderRadius: 20,
        bubbleColor: AppColors.dubaiPurple.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.dubaiPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.users,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Family Suitability',
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Age range
              _buildSuitabilityItem(
                icon: LucideIcons.baby,
                label: 'Age Range',
                value: '${event.familySuitability.ageMin}-${event.familySuitability.ageMax} years',
                color: AppColors.dubaiPurple,
              ),
              
              const SizedBox(height: 12),
              
              // Family friendly indicator
              _buildSuitabilityItem(
                icon: event.familySuitability.familyFriendly 
                    ? LucideIcons.check 
                    : LucideIcons.x,
                label: 'Family Friendly',
                value: event.familySuitability.familyFriendly 
                    ? 'Yes' 
                    : 'Not Recommended',
                color: event.familySuitability.familyFriendly 
                    ? AppColors.dubaiTeal 
                    : AppColors.dubaiCoral,
              ),
              
              const SizedBox(height: 12),
              
              // Stroller friendly
              if (event.familySuitability.strollerFriendly != null)
                _buildSuitabilityItem(
                  icon: event.familySuitability.strollerFriendly! 
                      ? LucideIcons.check 
                      : LucideIcons.x,
                  label: 'Stroller Friendly',
                  value: event.familySuitability.strollerFriendly! 
                      ? 'Yes' 
                      : 'No',
                  color: event.familySuitability.strollerFriendly! 
                      ? AppColors.dubaiTeal 
                      : AppColors.dubaiCoral,
                ),
            ],
          ),
        ),
      ).animate().slideInRight(delay: 600.ms);
    }
    
    Widget _buildSuitabilityItem({
      required IconData icon,
      required String label,
      required String value,
      required Color color,
    }) {
      return Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      );
    }
    
    void _openMap(Venue venue) {
      // Implement map opening logic
    }
  }
  ```

### 5.4 Floating Action Button
- [ ] Create booking/save floating button:
  ```dart
  // features/events/widgets/floating_action_section.dart
  class EventFloatingActions extends ConsumerWidget {
    final Event event;
    
    const EventFloatingActions({Key? key, required this.event}) : super(key: key);
    
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final savedEvents = ref.watch(savedEventsProvider);
      final isSaved = savedEvents.contains(event.id);
      
      return Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: BubbleDecoration(
          borderRadius: 25,
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Save button
                GestureDetector(
                  onTap: () => _toggleSave(ref),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSaved 
                          ? AppColors.dubaiCoral.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSaved 
                            ? AppColors.dubaiCoral
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      isSaved ? LucideIcons.heart : LucideIcons.heart,
                      color: isSaved ? AppColors.dubaiCoral : Colors.grey,
                      size: 24,
                    ),
                  ),
                ).animate().scale(
                  duration: const Duration(milliseconds: 200),
                ),
                
                const SizedBox(width: 16),
                
                // Book/Get Tickets button
                Expanded(
                  child: PulsingButton(
                    pulseColor: AppColors.dubaiTeal,
                    onPressed: () => _handleBooking(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppColors.oceanGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              LucideIcons.ticket,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              event.pricing.minPrice == 0 
                                  ? 'Get Free Tickets' 
                                  : 'Book Now - AED ${event.pricing.minPrice}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
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
          ),
        ),
      ).animate().slideInUp(delay: 800.ms);
    }
    
    void _toggleSave(WidgetRef ref) {
      ref.read(savedEventsProvider.notifier).toggleSaveEvent(event.id);
    }
    
    void _handleBooking() {
      // Implement booking logic
    }
  }
  ```

---

## PHASE 6: Authentication & Profile (Week 6)

### 6.1 Welcome/Onboarding Screens
- [ ] Create engaging welcome flow:
  ```dart
  // features/auth/welcome_screen.dart
  class WelcomeScreen extends StatefulWidget {
    const WelcomeScreen({Key? key}) : super(key: key);
    
    @override
    State<WelcomeScreen> createState() => _WelcomeScreenState();
  }
  
  class _WelcomeScreenState extends State<WelcomeScreen>
      with TickerProviderStateMixin {
    late PageController _pageController;
    late AnimationController _animationController;
    int _currentPage = 0;
    
    final List<OnboardingData> _pages = [
      OnboardingData(
        title: 'Discover Amazing\nFamily Events! 🎉',
        description: 'Find the perfect activities for your family in Dubai with our AI-powered recommendations',
        imagePath: 'assets/illustrations/family_fun.svg',
        primaryColor: AppColors.dubaiTeal,
        secondaryColor: AppColors.dubaiCoral,
      ),
      OnboardingData(
        title: 'Smart Family\nRecommendations 🤖',
        description: 'Our AI learns your family\'s preferences to suggest events that everyone will love',
        imagePath: 'assets/illustrations/ai_recommendations.svg',
        primaryColor: AppColors.dubaiPurple,
        secondaryColor: AppColors.dubaiGold,
      ),
      OnboardingData(
        title: 'Never Miss\nThe Fun! ⏰',
        description: 'Get personalized notifications for events that match your schedule and interests',
        imagePath: 'assets/illustrations/notifications.svg',
        primaryColor: AppColors.dubaiGold,
        secondaryColor: AppColors.dubaiTeal,
      ),
    ];
    
    @override
    void initState() {
      super.initState();
      _pageController = PageController();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      _animationController.forward();
    }
    
    @override
    void dispose() {
      _pageController.dispose();
      _animationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Stack(
          children: [
            // Background with floating bubbles
            _buildAnimatedBackground(),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Skip button
                  _buildSkipButton(),
                  
                  // Page view
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _pages.length,
                      itemBuilder: (context, index) => _buildOnboardingPage(_pages[index]),
                    ),
                  ),
                  
                  // Bottom section
                  _buildBottomSection(),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    Widget _buildAnimatedBackground() {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _pages[_currentPage].primaryColor.withOpacity(0.1),
              _pages[_currentPage].secondaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Stack(
          children: List.generate(10, (index) => 
            Positioned(
              top: Random().nextDouble() * MediaQuery.of(context).size.height,
              left: Random().nextDouble() * MediaQuery.of(context).size.width,
              child: FloatingBubble(
                size: 20 + Random().nextDouble() * 60,
                color: _pages[_currentPage].primaryColor.withOpacity(0.1),
              ).animate().scale(
                delay: Duration(milliseconds: index * 200),
                duration: const Duration(seconds: 2),
              ).then().moveY(
                begin: 0,
                end: -100,
                duration: const Duration(seconds: 8),
                curve: Curves.easeInOut,
              ),
            ),
          ),
        ),
      );
    }
    
    Widget _buildSkipButton() {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.topRight,
          child: TextButton(
            onPressed: () => _skipToLogin(),
            child: Text(
              'Skip',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ).animate().fadeInRight();
    }
    
    Widget _buildOnboardingPage(OnboardingData data) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              height: 300,
              child: SvgPicture.asset(
                data.imagePath,
                height: 300,
                fit: BoxFit.contain,
              ),
            ).animate().scale(
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
            ),
            
            const SizedBox(height: 60),
            
            // Title
            Text(
              data.title,
              style: GoogleFonts.comfortaa(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeInUp(delay: 300.ms),
            
            const SizedBox(height: 20),
            
            // Description
            Text(
              data.description,
              style: GoogleFonts.inter(
                fontSize: 18,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeInUp(delay: 500.ms),
          ],
        ),
      );
    }
    
    Widget _buildBottomSection() {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index 
                        ? _pages[_currentPage].primaryColor
                        : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Action buttons
            Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _previousPage(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        side: BorderSide(
                          color: _pages[_currentPage].primaryColor,
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _pages[_currentPage].primaryColor,
                        ),
                      ),
                    ),
                  ),
                
                if (_currentPage > 0) const SizedBox(width: 16),
                
                Expanded(
                  flex: _currentPage == 0 ? 1 : 2,
                  child: PulsingButton(
                    pulseColor: _pages[_currentPage].primaryColor,
                    onPressed: () => _nextPage(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _pages[_currentPage].primaryColor,
                            _pages[_currentPage].secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: Text(
                          _currentPage == _pages.length - 1 ? 'Get Started! 🚀' : 'Next',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    void _nextPage() {
      if (_currentPage < _pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _goToLogin();
      }
    }
    
    void _previousPage() {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    
    void _skipToLogin() {
      context.pushReplacementNamed('login');
    }
    
    void _goToLogin() {
      context.pushReplacementNamed('login');
    }
  }
  
  class OnboardingData {
    final String title;
    final String description;
    final String imagePath;
    final Color primaryColor;
    final Color secondaryColor;
    
    const OnboardingData({
      required this.title,
      required this.description,
      required this.imagePath,
      required this.primaryColor,
      required this.secondaryColor,
    });
  }
  ```

### 6.2 Enhanced Login Screen
- [ ] Create welcoming login experience:
  ```dart
  // features/auth/login_screen.dart
  class LoginScreen extends ConsumerStatefulWidget {
    const LoginScreen({Key? key}) : super(key: key);
    
    @override
    ConsumerState<LoginScreen> createState() => _LoginScreenState();
  }
  
  class _LoginScreenState extends ConsumerState<LoginScreen>
      with TickerProviderStateMixin {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    
    late AnimationController _animationController;
    late Animation<double> _fadeAnimation;
    late Animation<Offset> _slideAnimation;
    
    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
      
      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ));
      
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ));
      
      _animationController.forward();
    }
    
    @override
    void dispose() {
      _emailController.dispose();
      _passwordController.dispose();
      _animationController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      final authState = ref.watch(authProvider);
      
      return Scaffold(
        body: Stack(
          children: [
            // Background with floating bubbles
            _buildAnimatedBackground(),
            
            // Login form
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo and welcome text
                            _buildWelcomeSection(),
                            
                            const SizedBox(height: 40),
                            
                            // Login form
                            _buildLoginForm(authState),
                            
                            const SizedBox(height: 24),
                            
                            // Social login options
                            _buildSocialLoginSection(),
                            
                            const SizedBox(height: 24),
                            
                            // Sign up link
                            _buildSignUpLink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    Widget _buildAnimatedBackground() {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: Stack(
          children: List.generate(8, (index) => 
            Positioned(
              top: Random().nextDouble() * MediaQuery.of(context).size.height,
              left: Random().nextDouble() * MediaQuery.of(context).size.width,
              child: FloatingBubble(
                size: 30 + Random().nextDouble() * 60,
                color: AppColors.dubaiTeal.withOpacity(0.1),
              ).animate().scale(
                delay: Duration(milliseconds: index * 300),
                duration: const Duration(seconds: 3),
              ).then().moveY(
                begin: 0,
                end: -100,
                duration: const Duration(seconds: 6),
                curve: Curves.easeInOut,
              ),
            ),
          ),
        ),
      );
    }
    
    Widget _buildWelcomeSection() {
      return Column(
        children: [
          // App logo with animation
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.oceanGradient,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dubaiTeal.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.calendar,
              size: 40,
              color: Colors.white,
            ),
          ).animate().scale(delay: 300.ms),
          
          const SizedBox(height: 24),
          
          Text(
            'Welcome to DXB Events! 🎉',
            style: GoogleFonts.comfortaa(
              fontSize: