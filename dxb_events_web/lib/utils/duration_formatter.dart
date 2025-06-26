/// Utility for formatting event durations in a user-friendly way
class DurationFormatter {
  /// Formats a duration into a human-readable string
  /// Converts large hour values into days, weeks, or months as appropriate
  static String formatDuration(Duration duration, {bool isShort = true}) {
    final totalMinutes = duration.inMinutes;
    final totalHours = duration.inHours;
    final totalDays = duration.inDays;
    
    // For very short events (under 1 hour)
    if (totalHours < 1) {
      return isShort ? '${totalMinutes}min' : '$totalMinutes minutes';
    }
    
    // For events under 6 hours - show in hours
    if (totalHours < 6) {
      final hours = totalHours;
      final minutes = totalMinutes % 60;
      if (minutes > 0 && !isShort) {
        return '$hours hours $minutes minutes';
      }
      return isShort ? '${hours}h' : '$hours hours';
    }
    
    // For events 6+ hours but less than 24 hours
    if (totalHours < 24) {
      return isShort ? 'Full Day' : 'Full day event';
    }
    
    // For events 24+ hours - convert to days
    if (totalDays < 7) {
      return isShort ? '${totalDays}d' : '$totalDays days';
    }
    
    // For events 7+ days - convert to weeks
    if (totalDays < 30) {
      final weeks = (totalDays / 7).floor();
      final remainingDays = totalDays % 7;
      
      if (weeks == 1 && remainingDays == 0) {
        return isShort ? '1w' : '1 week';
      } else if (remainingDays == 0) {
        return isShort ? '${weeks}w' : '$weeks weeks';
      } else if (weeks == 1) {
        return isShort ? '1w ${remainingDays}d' : '1 week $remainingDays days';
      } else {
        return isShort ? '${weeks}w ${remainingDays}d' : '$weeks weeks $remainingDays days';
      }
    }
    
    // For events 30+ days - convert to months
    final months = (totalDays / 30).floor();
    final remainingDays = totalDays % 30;
    
    if (months == 1 && remainingDays == 0) {
      return isShort ? '1mo' : '1 month';
    } else if (remainingDays == 0) {
      return isShort ? '${months}mo' : '$months months';
    } else if (months == 1) {
      return isShort ? '1mo ${remainingDays}d' : '1 month $remainingDays days';
    } else {
      return isShort ? '${months}mo ${remainingDays}d' : '$months months $remainingDays days';
    }
  }
  
  /// Formats a duration from start and end DateTime objects
  static String formatEventDuration(DateTime startDate, DateTime? endDate, {bool isShort = true}) {
    final effectiveEndDate = endDate ?? startDate.add(const Duration(hours: 2));
    final duration = effectiveEndDate.difference(startDate);
    return formatDuration(duration, isShort: isShort);
  }
  
  /// Formats duration for display in event cards (always short format)
  static String formatForCard(DateTime startDate, DateTime? endDate) {
    return formatEventDuration(startDate, endDate, isShort: true);
  }
  
  /// Formats duration for display in detailed views (long format)
  static String formatForDetails(DateTime startDate, DateTime? endDate) {
    return formatEventDuration(startDate, endDate, isShort: false);
  }
}