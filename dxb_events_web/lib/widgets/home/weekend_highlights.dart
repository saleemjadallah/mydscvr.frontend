import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../services/events_service.dart';
import '../../models/event.dart';
import '../../widgets/common/bubble_decoration.dart';

class WeekendHighlights extends StatefulWidget {
  const WeekendHighlights({super.key});

  @override
  State<WeekendHighlights> createState() => _WeekendHighlightsState();
}

class _WeekendHighlightsState extends State<WeekendHighlights> {
  late final EventsService _eventsService;
  Event? _weekendEvent;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _eventsService = EventsService();
    _loadWeekendEvent();
  }

  Future<void> _loadWeekendEvent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔍 WeekendHighlights: Loading weekend events...');
      
      // Get all events
      final response = await _eventsService.getEvents(
        perPage: 100,
        sortBy: 'start_date',
      );

      if (response.isSuccess && response.data != null) {
        final events = response.data!;
        print('🔍 WeekendHighlights: Got ${events.length} events, filtering for weekend...');
        
        // Debug: Print first few event dates
        for (int i = 0; i < events.length && i < 5; i++) {
          final event = events[i];
          print('🔍 WeekendHighlights: Event $i: "${event.title}" - ${event.startDate.toString()} (${event.venue.area})');
        }
        
        // Find the best weekend event
        final weekendEvent = _findBestWeekendEvent(events);
        
        setState(() {
          _weekendEvent = weekendEvent;
          _isLoading = false;
        });
        
        if (weekendEvent != null) {
          print('🔍 WeekendHighlights: Found weekend event: ${weekendEvent.title}');
        } else {
          print('🔍 WeekendHighlights: No weekend events found');
        }
      } else {
        print('❌ WeekendHighlights: API Error: ${response.error}');
        setState(() {
          _errorMessage = response.error ?? 'Failed to load weekend events';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ WeekendHighlights: Error loading events: $e');
      setState(() {
        _errorMessage = 'Failed to load weekend events: $e';
        _isLoading = false;
      });
    }
  }

  Event? _findBestWeekendEvent(List<Event> events) {
    final now = DateTime.now();
    
    print('🔍 WeekendHighlights: Current time: $now (weekday: ${now.weekday})');
    
    // Calculate this weekend (Friday evening, Saturday, Sunday)
    final daysUntilFriday = (5 - now.weekday) % 7; // Friday = 5
    final thisFriday = now.add(Duration(days: daysUntilFriday));
    final thisSaturday = thisFriday.add(const Duration(days: 1));
    final thisSunday = thisSaturday.add(const Duration(days: 1));
    final nextMonday = thisSunday.add(const Duration(days: 1));
    
    print('🔍 WeekendHighlights: This weekend is ${thisFriday.day}/${thisFriday.month} - ${thisSunday.day}/${thisSunday.month}');
    print('🔍 WeekendHighlights: Weekend range: ${thisFriday.toString()} to ${nextMonday.toString()}');
    
    // Enhanced weekend event filtering
    final fridayEvening = DateTime(thisFriday.year, thisFriday.month, thisFriday.day, 18);
    print('🔍 WeekendHighlights: Friday evening cutoff: ${fridayEvening.toString()}');
    
    final weekendEvents = events.where((event) {
      // Check 1: Direct weekend events (start_date during weekend)
      final eventDate = event.startDate;
      final isDirectWeekendEvent = eventDate.isAfter(fridayEvening.subtract(const Duration(hours: 1))) && 
                                  eventDate.isBefore(nextMonday);
      
      if (isDirectWeekendEvent) {
        print('🔍 WeekendHighlights: ✅ Direct weekend event: "${event.title}" on ${eventDate.toString()}');
        return true;
      }
      
      // Check 2: Long-running events that span the weekend
      final endDate = event.endDate;
      if (endDate != null) {
        final spansWeekend = eventDate.isBefore(nextMonday) && endDate.isAfter(fridayEvening);
        if (spansWeekend) {
          print('🔍 WeekendHighlights: ✅ Long-running event spanning weekend: "${event.title}" (${eventDate.toString()} to ${endDate.toString()})');
          return true;
        }
      }
      
      // Check 3: Recurring/ongoing events (detect by keywords and patterns)
      final isRecurring = _isRecurringEvent(event);
      final isOngoingAttraction = _isOngoingAttraction(event);
      
      if (isRecurring || isOngoingAttraction) {
        // For recurring events, check if they could be active during weekend
        // (events within the last month are considered "current")
        final isRecentEnoughToBeActive = eventDate.isAfter(now.subtract(const Duration(days: 30)));
        if (isRecentEnoughToBeActive) {
          print('🔍 WeekendHighlights: ✅ Recurring/ongoing event: "${event.title}" (type: ${isRecurring ? "recurring" : "attraction"})');
          return true;
        }
      }
      
      return false;
    }).toList();
    
    print('🔍 WeekendHighlights: Found ${weekendEvents.length} this weekend events (including recurring/spanning)');
    
    if (weekendEvents.isEmpty) {
      print('🔍 WeekendHighlights: No events found for this weekend. Checking all event dates:');
      for (int i = 0; i < events.length && i < 10; i++) {
        final event = events[i];
        final eventDate = event.startDate;
        final isAfterFriday = eventDate.isAfter(fridayEvening.subtract(const Duration(hours: 1)));
        final isBeforeMonday = eventDate.isBefore(nextMonday);
        print('🔍   Event "$i: ${event.title}" - ${eventDate.toString()} (After Friday: $isAfterFriday, Before Monday: $isBeforeMonday)');
      }
      
      // If no events this weekend, look for next weekend
      final nextFriday = thisFriday.add(const Duration(days: 7));
      final nextSaturday = thisSaturday.add(const Duration(days: 7));
      final nextSunday = thisSunday.add(const Duration(days: 7));
      final nextNextMonday = nextMonday.add(const Duration(days: 7));
      
      final nextWeekendEvents = events.where((event) {
        final eventDate = event.startDate;
        final nextFridayEvening = DateTime(nextFriday.year, nextFriday.month, nextFriday.day, 18);
        return eventDate.isAfter(nextFridayEvening.subtract(const Duration(hours: 1))) && 
               eventDate.isBefore(nextNextMonday);
      }).toList();
      
      print('🔍 WeekendHighlights: Found ${nextWeekendEvents.length} next weekend events');
      
      if (nextWeekendEvents.isNotEmpty) {
        // Sort by rating and family score
        nextWeekendEvents.sort((a, b) {
          final scoreA = (a.rating * 10) + (a.isFree ? 5 : 0) + (a.isTrending ? 3 : 0);
          final scoreB = (b.rating * 10) + (b.isFree ? 5 : 0) + (b.isTrending ? 3 : 0);
          return scoreB.compareTo(scoreA);
        });
        return nextWeekendEvents.first;
      }
      
      // Last resort: find any upcoming event (even if not weekend)
      final upcomingEvents = events.where((event) => event.startDate.isAfter(now)).toList();
      print('🔍 WeekendHighlights: Found ${upcomingEvents.length} upcoming events');
      
      if (upcomingEvents.isNotEmpty) {
        upcomingEvents.sort((a, b) {
          final scoreA = (a.rating * 10) + (a.isFree ? 5 : 0) + (a.isTrending ? 3 : 0);
          final scoreB = (b.rating * 10) + (b.isFree ? 5 : 0) + (b.isTrending ? 3 : 0);
          return scoreB.compareTo(scoreA);
        });
        print('🔍 WeekendHighlights: No weekend events, showing best upcoming event: ${upcomingEvents.first.title}');
        return upcomingEvents.first;
      }
      
      print('🔍 WeekendHighlights: No upcoming events found at all!');
      return null;
    }
    
    // Sort weekend events by rating and preference
    weekendEvents.sort((a, b) {
      final scoreA = (a.rating * 10) + (a.isFree ? 5 : 0) + (a.isTrending ? 3 : 0);
      final scoreB = (b.rating * 10) + (b.isFree ? 5 : 0) + (b.isTrending ? 3 : 0);
      return scoreB.compareTo(scoreA);
    });
    
    return weekendEvents.first;
  }

  String _getWeekendDateRange(Event event) {
    final eventDate = event.startDate;
    final dayOfWeek = eventDate.weekday;
    final now = DateTime.now();
    
    // Check if it's this week
    final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfThisWeek = startOfThisWeek.add(const Duration(days: 6));
    
    final isThisWeek = eventDate.isAfter(startOfThisWeek.subtract(const Duration(hours: 1))) && 
                      eventDate.isBefore(endOfThisWeek.add(const Duration(hours: 1)));
    
    if (isThisWeek) {
      if (dayOfWeek == 5) { // Friday
        return 'This Friday';
      } else if (dayOfWeek == 6) { // Saturday
        return 'This Saturday';
      } else if (dayOfWeek == 7) { // Sunday
        return 'This Sunday';
      }
    }
    
    // Check if it's next week
    final startOfNextWeek = endOfThisWeek.add(const Duration(days: 1));
    final endOfNextWeek = startOfNextWeek.add(const Duration(days: 6));
    
    final isNextWeek = eventDate.isAfter(startOfNextWeek.subtract(const Duration(hours: 1))) && 
                      eventDate.isBefore(endOfNextWeek.add(const Duration(hours: 1)));
    
    if (isNextWeek) {
      if (dayOfWeek == 5) { // Friday
        return 'Next Friday';
      } else if (dayOfWeek == 6) { // Saturday
        return 'Next Saturday';
      } else if (dayOfWeek == 7) { // Sunday
        return 'Next Sunday';
      }
    }
    
    // Fallback to full date
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return '${dayNames[dayOfWeek - 1]}, ${months[eventDate.month - 1]} ${eventDate.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Weekend',
            style: GoogleFonts.comfortaa(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn().slideX(begin: -0.5, duration: 600.ms),
          
          const SizedBox(height: 16),
          
          _buildWeekendContent(),
        ],
      ),
    );
  }

  Widget _buildWeekendContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    if (_errorMessage != null) {
      return _buildErrorState();
    }
    
    if (_weekendEvent == null) {
      return _buildNoEventState();
    }
    
    return _buildEventCard(_weekendEvent!);
  }

  Widget _buildLoadingState() {
    return BubbleDecoration(
      gradient: AppColors.royalGradient,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loading weekend events...',
                      style: GoogleFonts.comfortaa(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Finding the best events for you',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildErrorState() {
    return BubbleDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.orange.shade400, Colors.red.shade400],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  LucideIcons.alertCircle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oops! Something went wrong',
                      style: GoogleFonts.comfortaa(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Unable to load weekend events',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _loadWeekendEvent,
                child: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildNoEventState() {
    return BubbleDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.blue.shade300, Colors.purple.shade300],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  LucideIcons.calendar,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekend Plans Coming Soon!',
                      style: GoogleFonts.comfortaa(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Check back later for exciting weekend events',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'In the meantime, explore our featured events and categories to discover amazing activities happening throughout the week!',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildEventCard(Event event) {
    return BubbleDecoration(
      gradient: AppColors.royalGradient,
      padding: const EdgeInsets.all(24),
      child: InkWell(
        onTap: () {
          context.go('/event/${event.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    LucideIcons.calendar,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: GoogleFonts.comfortaa(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${event.venue.area} • ${_getWeekendDateRange(event)}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event.isFree ? 'FREE' : event.displayPrice,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dubaiPurple,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              _getEventDescription(event),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.star,
                      size: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${event.rating.toStringAsFixed(1)} rating',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95), duration: 600.ms);
  }

  String _getEventDescription(Event event) {
    // Use the displaySummary method which already has fallback logic
    final summary = event.displaySummary;
    if (summary.isNotEmpty) {
      final truncated = summary.length > 100 
          ? '${summary.substring(0, 100)}...'
          : summary;
      return truncated;
    }

    // Additional fallback
    return 'Join us for this exciting event in ${event.venue.area}. Perfect for families looking for quality time together.';
  }
  
  /// Detects if an event is likely a recurring event (daily, weekly, etc.)
  bool _isRecurringEvent(Event event) {
    final title = event.title.toLowerCase();
    final description = event.description.toLowerCase();
    final tags = event.tags.map((tag) => tag.toLowerCase()).toList();
    
    // Recurring event indicators in title
    final recurringTitlePatterns = [
      'daily', 'weekly', 'every day', 'every week', 'brunch', 'night out',
      'live music', 'dj night', 'comedy night', 'karaoke', 'happy hour',
      'sunset', 'dinner show', 'rooftop', 'pool party', 'ladies night'
    ];
    
    for (final pattern in recurringTitlePatterns) {
      if (title.contains(pattern)) {
        return true;
      }
    }
    
    // Check description for recurring patterns
    final recurringDescPatterns = [
      'every friday', 'every saturday', 'every sunday', 'every weekend',
      'daily from', 'weekly on', 'recurring', 'happens every',
      'open daily', 'ongoing', 'throughout the', 'regular'
    ];
    
    for (final pattern in recurringDescPatterns) {
      if (description.contains(pattern)) {
        return true;
      }
    }
    
    // Check tags for recurring indicators
    for (final tag in tags) {
      if (recurringTitlePatterns.contains(tag)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Detects if an event is an ongoing attraction (theme parks, museums, etc.)
  bool _isOngoingAttraction(Event event) {
    final title = event.title.toLowerCase();
    final venueArea = event.venue.area.toLowerCase();
    final venueName = event.venue.name.toLowerCase();
    
    // Major ongoing attractions and venues
    final ongoingAttractions = [
      // Theme parks and water parks
      'img worlds', 'global village', 'motiongate', 'bollywood parks', 
      'legoland', 'aquaventure', 'wild wadi', 'laguna waterpark',
      
      // Museums and cultural sites
      'dubai museum', 'museum of the future', 'etihad museum', 
      'coffee museum', 'coin museum', 'al fahidi', 'bastakiya',
      
      // Major malls and entertainment
      'dubai mall', 'mall of the emirates', 'ibn battuta', 'city walk',
      'la mer', 'the beach', 'jumeirah beach residence', 'marina walk',
      
      // Shows and experiences
      'la perle', 'burj khalifa', 'dubai fountain', 'dhow cruise',
      'desert safari', 'hot air balloon', 'skydiving', 'helicopter tour',
      
      // Dining and nightlife venues
      'atlantis', 'burj al arab', 'armani hotel', 'address hotel',
      'four seasons', 'ritz carlton', 'jumeirah beach hotel'
    ];
    
    // Check if title or venue matches ongoing attractions
    for (final attraction in ongoingAttractions) {
      if (title.contains(attraction) || venueName.contains(attraction) || venueArea.contains(attraction)) {
        return true;
      }
    }
    
    // Check for venue/experience indicators
    final experienceIndicators = [
      'experience at', 'visit to', 'tour of', 'dining at', 'show at',
      'admission to', 'entry to', 'access to', 'day at', 'night at'
    ];
    
    for (final indicator in experienceIndicators) {
      if (title.contains(indicator)) {
        return true;
      }
    }
    
    return false;
  }
} 