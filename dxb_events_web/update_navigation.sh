#!/bin/bash

echo "=== Navigation Update Script ==="
echo "Converting traditional Flutter navigation to Go Router..."

# Files that need updates
files=(
    "lib/features/home/home_screen.dart"
    "lib/features/auth/register_screen.dart"
    "lib/features/events/events_list_screen.dart"
    "lib/features/events/events_list_screen_simple.dart"
    "lib/widgets/home/smart_trending_section.dart"
    "lib/widgets/home/weekend_highlights.dart"
    "lib/widgets/events/event_image_carousel.dart"
)

echo "Files to update:"
for file in "${files[@]}"; do
    echo "  - $file"
done

echo ""
echo "Checking current navigation patterns..."

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        count=$(grep -c "Navigator\.push\|MaterialPageRoute\|Navigator\.pushNamed" "$file")
        if [ $count -gt 0 ]; then
            echo "📁 $file: $count navigation instances found"
            grep -n "Navigator\.push\|MaterialPageRoute\|Navigator\.pushNamed" "$file"
            echo ""
        fi
    fi
done

echo "=== Manual update required for each file ==="
echo "Use the following pattern for updates:"
echo ""
echo "Before: Navigator.of(context).push(MaterialPageRoute(builder: (context) => SomeScreen()))"
echo "After:  context.go('/some-route')"
echo ""
echo "Before: Navigator.pushNamed(context, '/some-route')"  
echo "After:  context.go('/some-route')"
echo ""
echo "Make sure to add: import 'package:go_router/go_router.dart';"