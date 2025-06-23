import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../models/event.dart';
import '../../services/providers/auth_provider_mongodb.dart';

/// Heart/Save action buttons for events
class EventActionButtons extends ConsumerWidget {
  final Event event;
  final bool isCompact;
  final Color? iconColor;
  final double? iconSize;

  const EventActionButtons({
    Key? key,
    required this.event,
    this.isCompact = false,
    this.iconColor,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    final isHearted = ref.watch(isEventHeartedProvider(event.id));
    final isSaved = ref.watch(isEventSavedProvider(event.id));
    
    if (!isAuthenticated) {
      return const SizedBox.shrink(); // Don't show actions for unauthenticated users
    }

    if (isCompact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HeartButton(
            eventId: event.id,
            isHearted: isHearted,
            iconColor: iconColor,
            iconSize: iconSize ?? 20,
            showLabel: false,
          ),
          const SizedBox(width: 8),
          _SaveButton(
            eventId: event.id,
            isSaved: isSaved,
            iconColor: iconColor,
            iconSize: iconSize ?? 20,
            showLabel: false,
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeartButton(
          eventId: event.id,
          isHearted: isHearted,
          iconColor: iconColor,
          iconSize: iconSize ?? 24,
          showLabel: true,
        ),
        const SizedBox(height: 8),
        _SaveButton(
          eventId: event.id,
          isSaved: isSaved,
          iconColor: iconColor,
          iconSize: iconSize ?? 24,
          showLabel: true,
        ),
      ],
    );
  }
}

/// Individual heart button widget
class _HeartButton extends ConsumerWidget {
  final String eventId;
  final bool isHearted;
  final Color? iconColor;
  final double iconSize;
  final bool showLabel;

  const _HeartButton({
    required this.eventId,
    required this.isHearted,
    this.iconColor,
    required this.iconSize,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final authNotifier = ref.read(authProvider.notifier);
        
        try {
          bool success;
          if (isHearted) {
            success = await authNotifier.unheartEvent(eventId);
          } else {
            success = await authNotifier.heartEvent(eventId);
          }
          
          if (success) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        isHearted ? LucideIcons.heartOff : LucideIcons.heart,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isHearted 
                            ? 'Event removed from favorites' 
                            : 'Event added to favorites',
                        ),
                      ),
                      if (!isHearted) ...[
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            context.push('/favorites');
                          },
                          child: Text(
                            'View',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  backgroundColor: isHearted ? AppColors.textSecondary : AppColors.dubaiCoral,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isHearted ? 'Failed to unheart event' : 'Failed to heart event',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Something went wrong. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(showLabel ? 8 : 4),
        decoration: BoxDecoration(
          color: isHearted
              ? AppColors.dubaiCoral.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isHearted
              ? Border.all(color: AppColors.dubaiCoral.withOpacity(0.3))
              : null,
        ),
        child: showLabel
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isHearted ? LucideIcons.heart : LucideIcons.heart,
                    color: isHearted
                        ? AppColors.dubaiCoral
                        : (iconColor ?? AppColors.textSecondary),
                    size: iconSize,
                    fill: isHearted ? 1.0 : null,
                  ),
                  if (showLabel) ...[
                    const SizedBox(height: 2),
                    Text(
                      isHearted ? 'Hearted' : 'Heart',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isHearted
                            ? AppColors.dubaiCoral
                            : (iconColor ?? AppColors.textSecondary),
                      ),
                    ),
                  ],
                ],
              )
            : Icon(
                isHearted ? LucideIcons.heart : LucideIcons.heart,
                color: isHearted
                    ? AppColors.dubaiCoral
                    : (iconColor ?? AppColors.textSecondary),
                size: iconSize,
                fill: isHearted ? 1.0 : null,
              ),
      ),
    );
  }
}

/// Individual save button widget
class _SaveButton extends ConsumerWidget {
  final String eventId;
  final bool isSaved;
  final Color? iconColor;
  final double iconSize;
  final bool showLabel;

  const _SaveButton({
    required this.eventId,
    required this.isSaved,
    this.iconColor,
    required this.iconSize,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final authNotifier = ref.read(authProvider.notifier);
        
        try {
          bool success;
          if (isSaved) {
            success = await authNotifier.unsaveEvent(eventId);
          } else {
            success = await authNotifier.saveEvent(eventId);
          }
          
          if (success) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        isSaved ? LucideIcons.bookmarkMinus : LucideIcons.bookmark,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isSaved 
                            ? 'Event removed from saved' 
                            : 'Event saved for later',
                        ),
                      ),
                      if (!isSaved) ...[
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            context.push('/favorites');
                          },
                          child: Text(
                            'View',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  backgroundColor: isSaved ? AppColors.textSecondary : AppColors.dubaiTeal,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isSaved ? 'Failed to unsave event' : 'Failed to save event',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Something went wrong. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(showLabel ? 8 : 4),
        decoration: BoxDecoration(
          color: isSaved
              ? AppColors.dubaiTeal.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSaved
              ? Border.all(color: AppColors.dubaiTeal.withOpacity(0.3))
              : null,
        ),
        child: showLabel
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSaved ? LucideIcons.bookmark : LucideIcons.bookmark,
                    color: isSaved
                        ? AppColors.dubaiTeal
                        : (iconColor ?? AppColors.textSecondary),
                    size: iconSize,
                    fill: isSaved ? 1.0 : null,
                  ),
                  if (showLabel) ...[
                    const SizedBox(height: 2),
                    Text(
                      isSaved ? 'Saved' : 'Save',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isSaved
                            ? AppColors.dubaiTeal
                            : (iconColor ?? AppColors.textSecondary),
                      ),
                    ),
                  ],
                ],
              )
            : Icon(
                isSaved ? LucideIcons.bookmark : LucideIcons.bookmark,
                color: isSaved
                    ? AppColors.dubaiTeal
                    : (iconColor ?? AppColors.textSecondary),
                size: iconSize,
                fill: isSaved ? 1.0 : null,
              ),
      ),
    );
  }
}

/// Floating action button style heart/save buttons
class EventFloatingActions extends ConsumerWidget {
  final Event event;

  const EventFloatingActions({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    
    if (!isAuthenticated) {
      return const SizedBox.shrink();
    }

    final isHearted = ref.watch(isEventHeartedProvider(event.id));
    final isSaved = ref.watch(isEventSavedProvider(event.id));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Heart button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _HeartButton(
            eventId: event.id,
            isHearted: isHearted,
            iconSize: 20,
            showLabel: false,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Save button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _SaveButton(
            eventId: event.id,
            isSaved: isSaved,
            iconSize: 20,
            showLabel: false,
          ),
        ),
      ],
    );
  }
}

/// Rating button for events
class EventRatingButton extends ConsumerStatefulWidget {
  final Event event;
  final bool isCompact;

  const EventRatingButton({
    Key? key,
    required this.event,
    this.isCompact = false,
  }) : super(key: key);

  @override
  ConsumerState<EventRatingButton> createState() => _EventRatingButtonState();
}

class _EventRatingButtonState extends ConsumerState<EventRatingButton> {
  double? _selectedRating;
  bool _isRating = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    final currentRating = ref.watch(eventRatingProvider(widget.event.id));
    
    if (!isAuthenticated) {
      return const SizedBox.shrink();
    }

    if (_isRating) {
      return _buildRatingSelector();
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isRating = true;
          _selectedRating = currentRating ?? 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: currentRating != null
              ? AppColors.dubaiGold.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: currentRating != null
              ? Border.all(color: AppColors.dubaiGold.withOpacity(0.3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.star,
              color: currentRating != null
                  ? AppColors.dubaiGold
                  : AppColors.textSecondary,
              size: widget.isCompact ? 14 : 16,
              fill: currentRating != null ? 1.0 : null,
            ),
            if (!widget.isCompact) ...[
              const SizedBox(width: 4),
              Text(
                currentRating != null
                    ? currentRating.toStringAsFixed(1)
                    : 'Rate',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: currentRating != null
                      ? AppColors.dubaiGold
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(5, (index) {
            final rating = index + 1.0;
            return GestureDetector(
              onTap: () => _submitRating(rating),
              child: Icon(
                LucideIcons.star,
                color: rating <= (_selectedRating ?? 0)
                    ? AppColors.dubaiGold
                    : Colors.grey.withOpacity(0.3),
                size: 16,
                fill: rating <= (_selectedRating ?? 0) ? 1.0 : null,
              ),
            );
          }),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isRating = false;
                _selectedRating = null;
              });
            },
            child: Icon(
              LucideIcons.x,
              color: AppColors.textSecondary,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRating(double rating) async {
    final authNotifier = ref.read(authProvider.notifier);
    
    try {
      final success = await authNotifier.rateEvent(widget.event.id, rating);
      
      if (success) {
        setState(() {
          _isRating = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Event rated ${rating.toStringAsFixed(1)} stars'),
              backgroundColor: AppColors.dubaiTeal,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit rating'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}