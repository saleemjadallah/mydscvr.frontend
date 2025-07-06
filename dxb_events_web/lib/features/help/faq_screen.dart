import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/themes/app_typography.dart';
import '../../models/faq_models.dart';
import '../../widgets/common/footer.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  // Animation controllers
  late AnimationController _searchAnimationController;
  late AnimationController _categoriesAnimationController;
  
  // State management
  FAQCategory? _selectedCategory;
  List<FAQ> _displayedFAQs = [];
  String _searchQuery = '';
  Set<String> _expandedFAQs = {};
  bool _showSearch = false;

  // Category keys for smooth scrolling
  final Map<FAQCategory, GlobalKey> _categoryKeys = {};

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _searchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _categoriesAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // Initialize category keys
    for (final category in FAQCategory.values) {
      _categoryKeys[category] = GlobalKey();
    }
    
    // Load initial data
    _loadFAQs();
    
    // Start animations
    _categoriesAnimationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchAnimationController.dispose();
    _categoriesAnimationController.dispose();
    super.dispose();
  }

  void _loadFAQs() {
    setState(() {
      if (_searchQuery.isNotEmpty) {
        _displayedFAQs = FAQData.searchFAQs(_searchQuery);
      } else if (_selectedCategory != null) {
        _displayedFAQs = FAQData.getFAQsByCategory(_selectedCategory!);
      } else {
        _displayedFAQs = FAQData.getPopularFAQs();
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _selectedCategory = null;
    });
    _loadFAQs();
  }

  void _selectCategory(FAQCategory? category) {
    setState(() {
      _selectedCategory = category;
      _searchQuery = '';
      _searchController.clear();
    });
    _loadFAQs();
    
    // Scroll to category section
    if (category != null) {
      _scrollToCategory(category);
    }
  }

  void _scrollToCategory(FAQCategory category) {
    final key = _categoryKeys[category];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleFAQ(String faqId) {
    setState(() {
      if (_expandedFAQs.contains(faqId)) {
        _expandedFAQs.remove(faqId);
      } else {
        _expandedFAQs.add(faqId);
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
    });
    
    if (_showSearch) {
      _searchAnimationController.forward();
    } else {
      _searchAnimationController.reverse();
      _searchController.clear();
      _onSearchChanged('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help Center',
          style: GoogleFonts.comfortaa(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.dubaiTeal,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? LucideIcons.x : LucideIcons.search,
              color: Colors.white,
            ),
            onPressed: _toggleSearch,
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Header Section
            _buildHeader(isMobile),
            
            // Search Bar
            if (_showSearch) _buildSearchBar(isMobile),
            
            // Main Content
            Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: EdgeInsets.all(isMobile ? 20 : 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories Sidebar (Desktop only)
                  if (!isMobile) ...[
                    Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 40),
                      child: _buildCategoriesSidebar(),
                    ),
                  ],
                  
                  // FAQ Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mobile Categories
                        if (isMobile) ...[
                          _buildMobileCategories(),
                          const SizedBox(height: 24),
                        ],
                        
                        // FAQ List
                        _buildFAQList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.dubaiTeal,
            AppColors.dubaiTeal.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.helpCircle,
                size: isMobile ? 28 : 36,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                'MyDscvr Help Center',
                style: GoogleFonts.comfortaa(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Find answers to frequently asked questions',
            style: GoogleFonts.inter(
              fontSize: isMobile ? 16 : 18,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Get quick answers to common questions about MyDscvr, or browse by category to find what you\'re looking for.',
            style: GoogleFonts.inter(
              fontSize: isMobile ? 14 : 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, duration: 600.ms);
  }

  Widget _buildSearchBar(bool isMobile) {
    return AnimatedBuilder(
      animation: _searchAnimationController,
      builder: (context, child) {
        return Container(
          height: _searchAnimationController.value * 80,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 40,
            vertical: _searchAnimationController.value * 20,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderLight,
                width: 1,
              ),
            ),
          ),
          child: Opacity(
            opacity: _searchAnimationController.value,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search FAQs...',
                prefixIcon: const Icon(LucideIcons.search, color: AppColors.dubaiTeal),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.dubaiTeal),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesSidebar() {
    return AnimatedBuilder(
      animation: _categoriesAnimationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.list,
                    size: 20,
                    color: AppColors.dubaiTeal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Categories',
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Popular FAQs
              _buildCategoryItem(
                'Popular Questions',
                'Most frequently asked',
                LucideIcons.star,
                isSelected: _selectedCategory == null && _searchQuery.isEmpty,
                onTap: () => _selectCategory(null),
              ),
              
              const SizedBox(height: 16),
              Divider(color: AppColors.borderLight),
              const SizedBox(height: 16),
              
              // Category List
              ...FAQCategory.values.map((category) {
                final index = FAQCategory.values.indexOf(category);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildCategoryItem(
                    category.displayName,
                    category.description,
                    _getCategoryIcon(category),
                    isSelected: _selectedCategory == category,
                    onTap: () => _selectCategory(category),
                  ).animate(delay: Duration(milliseconds: 100 * index))
                    .slideX(begin: -0.3, duration: 400.ms)
                    .fadeIn(duration: 400.ms),
                );
              }).toList(),
            ],
          ),
        ).animate()
          .slideX(begin: -0.5, duration: 600.ms)
          .fadeIn(duration: 600.ms);
      },
    );
  }

  Widget _buildMobileCategories() {
    return ExpansionTile(
      leading: const Icon(LucideIcons.list, color: AppColors.dubaiTeal),
      title: Text(
        'Browse Categories',
        style: GoogleFonts.comfortaa(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      children: [
        // Popular FAQs
        _buildCategoryItem(
          'Popular Questions',
          'Most frequently asked',
          LucideIcons.star,
          isSelected: _selectedCategory == null && _searchQuery.isEmpty,
          onTap: () => _selectCategory(null),
        ),
        const Divider(),
        
        // Categories
        ...FAQCategory.values.map((category) =>
          _buildCategoryItem(
            category.displayName,
            category.description,
            _getCategoryIcon(category),
            isSelected: _selectedCategory == category,
            onTap: () => _selectCategory(category),
          ),
        ).toList(),
      ],
    );
  }

  Widget _buildCategoryItem(
    String title,
    String description,
    IconData icon, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.dubaiTeal.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.dubaiTeal : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.dubaiTeal 
                    : AppColors.dubaiTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.dubaiTeal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.dubaiTeal : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQList() {
    if (_displayedFAQs.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              _selectedCategory != null 
                  ? _getCategoryIcon(_selectedCategory!)
                  : _searchQuery.isNotEmpty 
                      ? LucideIcons.search 
                      : LucideIcons.star,
              size: 20,
              color: AppColors.dubaiTeal,
            ),
            const SizedBox(width: 8),
            Text(
              _selectedCategory?.displayName ?? 
              (_searchQuery.isNotEmpty ? 'Search Results' : 'Popular Questions'),
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.dubaiTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_displayedFAQs.length}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.dubaiTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // FAQ Items
        ...(_displayedFAQs.asMap().entries.map((entry) {
          final index = entry.key;
          final faq = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildFAQItem(faq, index),
          );
        }).toList()),
      ],
    );
  }

  Widget _buildFAQItem(FAQ faq, int index) {
    final isExpanded = _expandedFAQs.contains(faq.id);
    
    return Container(
      key: _categoryKeys[faq.category],
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? AppColors.dubaiTeal : AppColors.borderLight,
          width: isExpanded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Question Header
          InkWell(
            onTap: () => _toggleFAQ(faq.id),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Category Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.dubaiTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(faq.category),
                      size: 16,
                      color: AppColors.dubaiTeal,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Question Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          faq.question,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (faq.isPopular) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                LucideIcons.star,
                                size: 12,
                                color: AppColors.dubaiGold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Popular',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.dubaiGold,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Expand Icon
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      LucideIcons.chevronDown,
                      color: AppColors.dubaiTeal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Answer (Expandable)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isExpanded ? null : 0,
            child: isExpanded ? Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  faq.answer,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
            ) : const SizedBox.shrink(),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
      .slideY(begin: 0.3, duration: 400.ms)
      .fadeIn(duration: 400.ms);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              _searchQuery.isNotEmpty ? LucideIcons.search : LucideIcons.helpCircle,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'No results found for "$_searchQuery"'
                  : 'No FAQs available',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try different keywords or browse categories'
                  : 'Check back later for more content',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(FAQCategory category) {
    switch (category) {
      case FAQCategory.general:
        return LucideIcons.helpCircle;
      case FAQCategory.account:
        return LucideIcons.user;
      case FAQCategory.events:
        return LucideIcons.calendar;
      case FAQCategory.favorites:
        return LucideIcons.heart;
      case FAQCategory.notifications:
        return LucideIcons.bell;
      case FAQCategory.families:
        return LucideIcons.users;
      case FAQCategory.payments:
        return LucideIcons.creditCard;
      case FAQCategory.technical:
        return LucideIcons.settings;
      case FAQCategory.privacy:
        return LucideIcons.shield;
      case FAQCategory.safety:
        return LucideIcons.shieldCheck;
    }
  }
}