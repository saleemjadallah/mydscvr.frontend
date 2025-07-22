# Mobile and Responsive Code Backup
## Before Nuclear Removal - Created on 2025-07-22

This document contains all the mobile and responsive patterns that were removed from the codebase.

## Common Breakpoint Values Used
```dart
// Mobile: <= 600px or <= 768px
// Tablet: > 768px && <= 1200px  
// Desktop: > 1200px
```

## Common Mobile Detection Patterns

### 1. Basic Screen Size Detection
```dart
final screenWidth = MediaQuery.of(context).size.width;
final isMobile = screenWidth <= 600;
final isTablet = screenWidth > 600 && screenWidth <= 1200;
final isDesktop = screenWidth > 1200;
```

### 2. Mobile Browser Detection (from image_utils.dart)
```dart
static bool _isMobileBrowser() {
  if (!kIsWeb) return false;
  
  final userAgent = _getUserAgent().toLowerCase();
  return userAgent.contains('mobile') || 
         userAgent.contains('android') || 
         userAgent.contains('iphone') ||
         userAgent.contains('ipad');
}
```

### 3. Platform Detection
```dart
if (kIsWeb && _isMobileBrowser()) {
  // Mobile web specific code
}
```

## Responsive UI Patterns

### 1. Responsive Padding
```dart
padding: EdgeInsets.all(isMobile ? 8.0 : 16.0)
```

### 2. Responsive Font Sizes
```dart
fontSize: isMobile ? 24 : 32
```

### 3. Responsive Grid Columns
```dart
crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3)
```

### 4. Conditional Widget Display
```dart
if (!isMobile) // Show only on desktop/tablet
  AdvancedFilters()
```

### 5. Layout Changes
```dart
isMobile 
  ? Column(children: widgets)
  : Row(children: widgets)
```

### 6. Responsive Container Constraints
```dart
constraints: BoxConstraints(
  maxWidth: isMobile ? double.infinity : 1200,
)
```

## Mobile-Specific Features Removed

1. **Mobile Search FAB**: Floating action button for search on mobile
2. **Horizontal Filter Chips**: Scrollable filter chips on mobile
3. **Carousel Views**: PageView widgets for mobile featured events
4. **Touch-Friendly Tap Targets**: Larger buttons and clickable areas
5. **Mobile Navigation**: Bottom navigation and hamburger menus
6. **Progressive Disclosure**: Hidden information panels on mobile
7. **Mobile Image Optimization**: Lower quality images for mobile devices

## Files with Heavy Mobile Logic

1. `events_list_screen.dart` - Mobile FAB, responsive grid
2. `home_screen_beautiful.dart` - Responsive app bar, layouts
3. `featured_events_section.dart` - Mobile carousel vs desktop grid
4. `events_filter_sidebar_glassmorphic.dart` - Collapsible mobile filters
5. `footer.dart` - Stacked mobile vs multi-column desktop layout
6. `image_utils.dart` - Mobile browser detection and optimization

## Responsive Component Examples

### Event Card Responsive Sizing
```dart
height: isMobile ? 280 : 350,
width: isMobile ? double.infinity : 300,
```

### Filter Sidebar Behavior
```dart
// Mobile: Horizontal scrollable chips
// Desktop: Vertical expandable sidebar
```

### Search Bar Constraints
```dart
Container(
  constraints: BoxConstraints(
    maxWidth: isMobile ? double.infinity : 600,
  ),
  child: SearchBar(),
)
```

## Notes for Rebuilding

When rebuilding the mobile experience:
1. Consider using a responsive package like `responsive_framework` for consistency
2. Define breakpoints in a central location
3. Create responsive utility widgets
4. Test on actual devices, not just browser dev tools
5. Consider touch targets (minimum 48x48 dp)
6. Think mobile-first, then enhance for larger screens