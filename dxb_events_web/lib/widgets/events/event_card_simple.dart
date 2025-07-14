import 'package:flutter/material.dart';
import '../../models/event.dart';
import 'event_card.dart';

/// Simple wrapper for EventCard to maintain backward compatibility
class EventCardSimple extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final bool showSaveButton;
  
  const EventCardSimple({
    Key? key,
    required this.event,
    this.onTap,
    this.showSaveButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EventCard(
      event: event,
      onTap: onTap,
      // showSaveButton parameter doesn't exist in EventCard
      // The save functionality is handled internally by EventCard
    );
  }
}