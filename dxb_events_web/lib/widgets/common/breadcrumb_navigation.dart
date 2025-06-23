import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';

class BreadcrumbItem {
  final String label;
  final String? route;
  final bool isActive;

  const BreadcrumbItem({
    required this.label,
    this.route,
    this.isActive = false,
  });
}

class BreadcrumbNavigation extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? activeTextColor;
  final EdgeInsets? padding;

  const BreadcrumbNavigation({
    super.key,
    required this.items,
    this.backgroundColor,
    this.textColor,
    this.activeTextColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.home,
            size: 16,
            color: textColor ?? AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildBreadcrumbItems(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBreadcrumbItems(BuildContext context) {
    List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      // Add breadcrumb item
      widgets.add(
        GestureDetector(
          onTap: item.route != null && !item.isActive
              ? () => context.go(item.route!)
              : null,
          child: Text(
            item.label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: item.isActive ? FontWeight.w600 : FontWeight.w400,
              color: item.isActive
                  ? (activeTextColor ?? AppColors.dubaiTeal)
                  : (textColor ?? AppColors.textSecondary),
              decoration: item.route != null && !item.isActive
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
        ),
      );

      // Add separator (except for the last item)
      if (!isLast) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              LucideIcons.chevronRight,
              size: 12,
              color: textColor ?? AppColors.textSecondary,
            ),
          ),
        );
      }
    }

    return widgets;
  }

  // Static helper methods for common breadcrumb patterns
  static List<BreadcrumbItem> forAllEvents() {
    return [
      const BreadcrumbItem(
        label: 'Home',
        route: '/',
      ),
      const BreadcrumbItem(
        label: 'All Events',
        isActive: true,
      ),
    ];
  }

  static List<BreadcrumbItem> forEventDetail(String eventTitle) {
    return [
      const BreadcrumbItem(
        label: 'Home',
        route: '/',
      ),
      const BreadcrumbItem(
        label: 'All Events',
        route: '/events',
      ),
      BreadcrumbItem(
        label: eventTitle,
        isActive: true,
      ),
    ];
  }

  static List<BreadcrumbItem> forCategory(String categoryName) {
    return [
      const BreadcrumbItem(
        label: 'Home',
        route: '/',
      ),
      const BreadcrumbItem(
        label: 'All Events',
        route: '/events',
      ),
      BreadcrumbItem(
        label: categoryName,
        isActive: true,
      ),
    ];
  }

  static List<BreadcrumbItem> forSearchResults(String query) {
    return [
      const BreadcrumbItem(
        label: 'Home',
        route: '/',
      ),
      const BreadcrumbItem(
        label: 'All Events',
        route: '/events',
      ),
      BreadcrumbItem(
        label: 'Search: "$query"',
        isActive: true,
      ),
    ];
  }

  static List<BreadcrumbItem> forLocation(String locationName) {
    return [
      const BreadcrumbItem(
        label: 'Home',
        route: '/',
      ),
      const BreadcrumbItem(
        label: 'All Events',
        route: '/events',
      ),
      BreadcrumbItem(
        label: 'Events in $locationName',
        isActive: true,
      ),
    ];
  }
} 