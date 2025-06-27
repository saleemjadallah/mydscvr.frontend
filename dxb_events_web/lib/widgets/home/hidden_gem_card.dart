// Hidden Gem Discovery Card Widget
// Clean, elegant card with reveal animations and gamification features

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/app_colors.dart';
import '../../models/event.dart';
import '../../services/api/dio_config.dart';

class HiddenGemCard extends StatefulWidget {
  final String? userId;
  final VoidCallback? onGemRevealed;
  
  const HiddenGemCard({
    super.key,
    this.userId,
    this.onGemRevealed,
  });

  @override
  State<HiddenGemCard> createState() => _HiddenGemCardState();
}

class _HiddenGemCardState extends State<HiddenGemCard>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _revealController;
  late AnimationController _sparkleController;
  late AnimationController _pulseController;
  
  // Animations
  late Animation<double> _blurAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _sparkleOpacity;
  late Animation<double> _pulseScale;
  
  // State management
  bool _isRevealed = false;
  bool _isLoading = true;
  bool _hasError = false;
  HiddenGem? _currentGem;
  UserStreak? _userStreak;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCurrentGem();
  }
  
  void _initializeAnimations() {
    // Reveal animation (blur to clear transition)
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _blurAnimation = Tween<double>(
      begin: 10.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutExpo,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _revealController,
      curve: Curves.elasticOut,
    ));
    
    // Sparkle animation for mystery state
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _sparkleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));
    
    // Pulse animation for call-to-action
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseScale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start mystery animations
    _sparkleController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _revealController.dispose();
    _sparkleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCurrentGem() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      
      final baseUrl = DioConfig.getApiBaseUrl();
      final apiUrl = '$baseUrl/hidden-gems/current';
      
      final fullUrl = '$apiUrl${widget.userId != null ? '?user_id=${widget.userId}' : ''}';
      print('🔮 Fetching Hidden Gem from: $fullUrl');
      
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🔮 Hidden Gem API Response: ${data.toString().substring(0, min(200, data.toString().length))}...');
        
        // Check if the response indicates no gem available
        if (data['success'] == false && data['message'] == 'No gem available for today') {
          print('🔮 No gem available for today');
          setState(() {
            _currentGem = null;
            _isLoading = false;
          });
          return;
        }
        
        try {
          // Try to parse the gem data
          final gemData = data['gem'];
          if (gemData == null) {
            print('🔮 No gem data in response');
            setState(() {
              _currentGem = null;
              _isLoading = false;
            });
            return;
          }
          
          print('🔮 Parsing gem data...');
          
          final parsedGem = HiddenGem.fromJson(gemData);
          print('🔮 Gem parsed successfully: ${parsedGem.gemTitle}');
          
          setState(() {
            _currentGem = parsedGem;
            _isRevealed = data['user_revealed'] ?? false;
            _userStreak = data['user_streak'] != null 
                ? UserStreak(currentStreak: data['user_streak'])
                : null;
            _isLoading = false;
          });
          
          // If already revealed, show the gem immediately
          if (_isRevealed) {
            _revealController.value = 1.0;
          }
        } catch (parseError) {
          print('🔮 Error parsing gem data: $parseError');
          setState(() {
            _hasError = true;
            _errorMessage = 'Failed to parse gem data: $parseError';
            _isLoading = false;
          });
        }
      } else if (response.statusCode == 404) {
        setState(() {
          _currentGem = null;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load hidden gem');
      }
    } catch (e) {
      print('🔮 Hidden Gem Error: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _revealGem() async {
    print('🔮 _revealGem called - isRevealed: $_isRevealed, hasGem: ${_currentGem != null}, userId: ${widget.userId}');
    if (_isRevealed || _currentGem == null) return;
    
    // If user is not logged in, just show the reveal animation without backend call
    if (widget.userId == null) {
      print('🔮 Revealing gem without user tracking (not logged in)');
      setState(() {
        _isRevealed = true;
      });
      
      // Trigger reveal animation
      await _revealController.forward();
      
      // Stop mystery animations
      _sparkleController.stop();
      _pulseController.stop();
      
      // Callback for parent widget
      widget.onGemRevealed?.call();
      return;
    }
    
    try {
      final baseUrl = DioConfig.getApiBaseUrl();
      final apiUrl = '$baseUrl/hidden-gems/reveal/${_currentGem!.gemId}';
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': widget.userId,
          'feedback_score': null,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _isRevealed = true;
          if (data['streak_info'] != null) {
            _userStreak = UserStreak.fromJson(data['streak_info']);
          }
        });
        
        // Trigger reveal animation
        await _revealController.forward();
        
        // Stop mystery animations
        _sparkleController.stop();
        _pulseController.stop();
        
        // Callback for parent widget
        widget.onGemRevealed?.call();
        
        // Show achievement if unlocked
        if (data['achievement_unlocked'] != null) {
          _showAchievementDialog(data['achievement_unlocked']);
        }
      }
    } catch (e) {
      // Handle error silently or show toast
      debugPrint('Error revealing gem: $e');
    }
  }
  
  void _showAchievementDialog(String achievement) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Achievement Unlocked!',
                style: GoogleFonts.comfortaa(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                achievement,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF667eea),
                ),
                child: const Text('Awesome!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showEventDetailsPopup() {
    if (_currentGem?.eventDetails != null) {
      showDialog(
        context: context,
        builder: (context) => _buildEventDetailsDialog(_currentGem!.eventDetails!),
      );
    } else if (_currentGem?.event != null) {
      // Fallback to full navigation if no popup details available
      context.go('/event/${_currentGem!.event!.id}');
    } else {
      // Show a message that event details are not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event details are not available for this hidden gem'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildEventDetailsDialog(Map<String, dynamic> eventDetails) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        decoration: BoxDecoration(
          gradient: AppColors.sunsetGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '🔮 Hidden Gem Revealed',
                      style: GoogleFonts.comfortaa(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        eventDetails['title'] ?? 'Hidden Gem Event',
                        style: GoogleFonts.comfortaa(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Description
                      Text(
                        eventDetails['description'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Event Details Grid
                      _buildEventDetailItem('📅 Date', eventDetails['date'] ?? 'TBA'),
                      _buildEventDetailItem('⏰ Time', eventDetails['time'] ?? 'TBA'),
                      _buildEventDetailItem('📍 Location', eventDetails['location'] ?? 'TBA'),
                      _buildEventDetailItem('💰 Price', eventDetails['price'] ?? 'Contact for pricing'),
                      _buildEventDetailItem('👥 Capacity', eventDetails['capacity'] ?? 'Limited'),
                      
                      const SizedBox(height: 16),
                      
                      // Highlights
                      if (eventDetails['highlights'] != null) ...[
                        Text(
                          '✨ Highlights',
                          style: GoogleFonts.comfortaa(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...((eventDetails['highlights'] as List<dynamic>?) ?? []).map(
                          (highlight) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(color: AppColors.dubaiTeal)),
                                Expanded(
                                  child: Text(
                                    highlight.toString(),
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // What to Bring
                      if (eventDetails['what_to_bring'] != null) ...[
                        Text(
                          '🎒 What to Bring',
                          style: GoogleFonts.comfortaa(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...((eventDetails['what_to_bring'] as List<dynamic>?) ?? []).map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(color: AppColors.dubaiGold)),
                                Expanded(
                                  child: Text(
                                    item.toString(),
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Booking Info
                      if (eventDetails['booking_info'] != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.dubaiTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.dubaiTeal.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '📞 How to Book',
                                style: GoogleFonts.comfortaa(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.dubaiTeal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                eventDetails['booking_info'],
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard();
    }
    
    if (_hasError) {
      return _buildErrorCard();
    }
    
    if (_currentGem == null) {
      return _buildNoGemCard();
    }
    
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * (_isRevealed ? 1.0 : _pulseScale.value),
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                stops: [0.0, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Background pattern
                  _buildBackgroundPattern(),
                  
                  // Main content
                  AnimatedBuilder(
                    animation: _blurAnimation,
                    child: _buildRevealedContent(),
                    builder: (context, child) {
                      return _isRevealed
                          ? child!
                          : _buildMysteryContent();
                    },
                  ),
                  
                  // Sparkle overlay for mystery state
                  if (!_isRevealed) _buildSparkleOverlay(),
                  
                  // Streak indicator
                  if (_userStreak != null) _buildStreakIndicator(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[300]!, Colors.grey[400]!],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
  
  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[700], size: 48),
            const SizedBox(height: 8),
            Text(
              'Unable to load today\'s gem',
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadCurrentGem,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoGemCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[400]!, Colors.grey[500]!],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, color: Colors.white, size: 48),
            const SizedBox(height: 8),
            Text(
              'No hidden gem available today',
              style: GoogleFonts.comfortaa(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Check back tomorrow for a new discovery!',
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: MysteryPatternPainter(),
        ),
      ),
    );
  }
  
  Widget _buildMysteryContent() {
    return InkWell(
      onTap: () {
        print('🔮 InkWell tapped!');
        _revealGem();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mystery icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 48,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Mystery title
            Text(
              '🔮 Today\'s Hidden Gem',
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Mystery teaser (blurred)
            AnimatedBuilder(
              animation: _blurAnimation,
              child: Text(
                _currentGem!.mysteryTeaser,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              builder: (context, child) {
                return ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: _isRevealed ? 0 : 5,
                    sigmaY: _isRevealed ? 0 : 5,
                  ),
                  child: child,
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Reveal button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.visibility,
                    color: Color(0xFF667eea),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reveal Hidden Gem',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF667eea),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
  
  Widget _buildRevealedContent() {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      child: InkWell(
        onTap: _showEventDetailsPopup,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gem category
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _currentGem!.gemCategory,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${_currentGem!.gemScore}/100',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Gem title
              Text(
                _currentGem!.gemTitle,
                style: GoogleFonts.comfortaa(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Tagline
              Text(
                _currentGem!.gemTagline,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.9),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                _currentGem!.revealedDescription,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 16),
              
              // Discovery hints
              if (_currentGem!.discoveryHints.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _currentGem!.discoveryHints.take(3).map((hint) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hint,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              
              const SizedBox(height: 16),
              
              // View details button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_forward,
                      color: const Color(0xFF667eea),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'View Event Details',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF667eea),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: child,
        );
      },
    );
  }
  
  Widget _buildSparkleOverlay() {
    return AnimatedBuilder(
      animation: _sparkleOpacity,
      builder: (context, child) {
        return Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: SparkleOverlayPainter(_sparkleOpacity.value),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStreakIndicator() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${_userStreak!.currentStreak}',
              style: GoogleFonts.inter(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painters for visual effects
class MysteryPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    
    // Draw subtle geometric pattern
    for (int i = 0; i < 20; i++) {
      final x = (i * 30.0) % size.width;
      final y = (i * 20.0) % size.height;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SparkleOverlayPainter extends CustomPainter {
  final double opacity;
  
  SparkleOverlayPainter(this.opacity);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.6)
      ..style = PaintingStyle.fill;
    
    final random = Random(42); // Fixed seed for consistent sparkles
    
    // Draw sparkles
    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 1;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(SparkleOverlayPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}

// Data models for Hidden Gems
class HiddenGem {
  final String gemId;
  final String eventId;
  final String gemTitle;
  final String gemTagline;
  final String mysteryTeaser;
  final String revealedDescription;
  final String whyHiddenGem;
  final String exclusivityLevel;
  final String gemCategory;
  final String experienceLevel;
  final List<String> bestFor;
  final int gemScore;
  final List<String> discoveryHints;
  final List<String> insiderTips;
  final DateTime gemDate;
  final String revealTime;
  final Event? event;
  final Map<String, dynamic>? eventDetails;
  
  HiddenGem({
    required this.gemId,
    required this.eventId,
    required this.gemTitle,
    required this.gemTagline,
    required this.mysteryTeaser,
    required this.revealedDescription,
    required this.whyHiddenGem,
    required this.exclusivityLevel,
    required this.gemCategory,
    required this.experienceLevel,
    required this.bestFor,
    required this.gemScore,
    required this.discoveryHints,
    required this.insiderTips,
    required this.gemDate,
    required this.revealTime,
    this.event,
    this.eventDetails,
  });
  
  factory HiddenGem.fromJson(Map<String, dynamic> json) {
    // Parse event data safely
    Event? eventData;
    if (json['event'] != null) {
      try {
        print('🔮 Attempting to parse event data...');
        eventData = Event.fromBackendApi(json['event']);
        print('🔮 Event data parsed successfully: ${eventData.title}');
      } catch (e, stackTrace) {
        print('🔮 ERROR: Failed to parse event data with fromBackendApi: $e');
        // Try creating a minimal event object for navigation
        try {
          final eventJson = json['event'] as Map<String, dynamic>;
          eventData = _createMinimalEvent(eventJson);
          print('🔮 Created minimal event: ${eventData.title}');
        } catch (e2) {
          print('🔮 ERROR: Failed to create minimal event: $e2');
          eventData = null;
        }
      }
    }
    
    return HiddenGem(
      gemId: json['gem_id'] ?? '',
      eventId: json['event_id'] ?? '',
      gemTitle: json['gem_title'] ?? '',
      gemTagline: json['gem_tagline'] ?? '',
      mysteryTeaser: json['mystery_teaser'] ?? '',
      revealedDescription: json['revealed_description'] ?? '',
      whyHiddenGem: json['why_hidden_gem'] ?? '',
      exclusivityLevel: json['exclusivity_level'] ?? '',
      gemCategory: json['gem_category'] ?? '',
      experienceLevel: json['experience_level'] ?? '',
      bestFor: List<String>.from(json['best_for'] ?? []),
      gemScore: json['gem_score'] ?? 0,
      discoveryHints: List<String>.from(json['discovery_hints'] ?? []),
      insiderTips: List<String>.from(json['insider_tips'] ?? []),
      gemDate: DateTime.parse(json['gem_date'] ?? DateTime.now().toIso8601String()),
      revealTime: json['reveal_time'] ?? '12:00 PM UAE',
      event: eventData,
      eventDetails: json['event_details'],
    );
  }

  /// Create a minimal Event object with just the essential fields for navigation
  static Event _createMinimalEvent(Map<String, dynamic> json) {
    // Parse basic venue info
    final venueData = json['venue'] as Map<String, dynamic>?;
    final venue = Venue(
      id: json['id'] ?? json['_id'] ?? '',
      name: venueData?['name'] ?? 'TBA',
      address: venueData?['address'] ?? '',
      area: venueData?['area'] ?? 'Dubai',
      city: 'Dubai',
      parkingAvailable: venueData?['parking_available'] ?? true,
      publicTransportAccess: venueData?['public_transport_access'] ?? true,
    );

    // Parse basic pricing
    final pricingData = json['pricing'] as Map<String, dynamic>?;
    final pricing = Pricing(
      basePrice: (pricingData?['base_price'] ?? 0).toDouble(),
      maxPrice: pricingData?['max_price']?.toDouble(),
      currency: pricingData?['currency'] ?? 'AED',
      isRefundable: pricingData?['is_refundable'] ?? true,
    );

    // Parse basic family suitability
    final familySuitabilityData = json['family_suitability'] as Map<String, dynamic>?;
    final familySuitability = FamilySuitability(
      minAge: familySuitabilityData?['min_age'],
      maxAge: familySuitabilityData?['max_age'],
      recommendedAgeRange: familySuitabilityData?['recommended_age_range'] ?? 'All ages',
      strollerFriendly: familySuitabilityData?['stroller_friendly'] ?? true,
      babyChanging: familySuitabilityData?['baby_changing'] ?? true,
      nursingFriendly: familySuitabilityData?['nursing_friendly'] ?? true,
      kidMenuAvailable: familySuitabilityData?['kid_menu_available'] ?? false,
      educationalContent: familySuitabilityData?['educational_content'] ?? false,
      notes: familySuitabilityData?['notes'],
    );

    // Parse organizer info
    final organizerData = json['organizer_info'] as Map<String, dynamic>?;
    final organizerInfo = OrganizerInfo(
      name: organizerData?['name'] ?? 'Dubai Events',
      description: organizerData?['description'] ?? 'Verified event organizer',
      verificationStatus: organizerData?['verification_status'] ?? 'verified',
    );

    // Parse dates
    DateTime startDate;
    DateTime? endDate;
    try {
      startDate = DateTime.parse(json['start_date']);
      endDate = json['end_date'] != null ? DateTime.parse(json['end_date']) : null;
    } catch (e) {
      startDate = DateTime.now().add(const Duration(days: 1));
      endDate = startDate.add(const Duration(hours: 2));
    }

    return Event(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? 'Hidden Gem Event',
      description: json['description'] ?? json['short_description'] ?? '',
      shortDescription: json['short_description'] ?? json['description'] ?? '',
      startDate: startDate,
      endDate: endDate,
      venue: venue,
      pricing: pricing,
      familySuitability: familySuitability,
      organizerInfo: organizerInfo,
      imageUrl: json['image_url'] ?? 'assets/images/mydscvr-logo.png',
      category: json['category'] ?? 'general',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      rating: (json['rating'] ?? 1.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      bookingRequired: json['booking_required'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      // Required fields with defaults
      highlights: (json['highlights'] as List<dynamic>?)?.cast<String>() ?? [],
      included: (json['included'] as List<dynamic>?)?.cast<String>() ?? [],
      accessibility: (json['accessibility'] as List<dynamic>?)?.cast<String>() ?? [],
      whatToBring: (json['what_to_bring'] as List<dynamic>?)?.cast<String>() ?? [],
      importantInfo: (json['important_info'] as List<dynamic>?)?.cast<String>() ?? [],
      cancellationPolicy: json['cancellation_policy'] ?? 'Please check with organizer',
      isFeatured: json['is_featured'] ?? false,
      isTrending: json['is_trending'] ?? false,
    );
  }
}

class UserStreak {
  final int currentStreak;
  final int longestStreak;
  final int totalDiscoveries;
  final List<String> achievements;
  
  UserStreak({
    required this.currentStreak,
    this.longestStreak = 0,
    this.totalDiscoveries = 0,
    this.achievements = const [],
  });
  
  factory UserStreak.fromJson(Map<String, dynamic> json) {
    return UserStreak(
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      totalDiscoveries: json['total_discoveries'] ?? 0,
      achievements: List<String>.from(json['achievements'] ?? []),
    );
  }
}