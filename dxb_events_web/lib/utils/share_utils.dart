import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/event.dart';

class ShareUtils {
  /// Base URL for the web app
  static const String baseUrl = 'https://mydscvr.ai';
  
  /// Share event via native share sheet or custom dialog
  static Future<void> shareEvent(
    BuildContext context,
    Event event, {
    String? customMessage,
  }) async {
    final eventUrl = '$baseUrl/events/${event.id}';
    final shareText = customMessage ?? _generateShareMessage(event, eventUrl);
    
    if (kIsWeb) {
      // On web, show custom share dialog with platform options
      await _showWebShareDialog(context, event, shareText, eventUrl);
    } else {
      // On mobile, use native share sheet
      try {
        await Share.share(
          shareText,
          subject: event.title,
        );
      } catch (e) {
        // Fallback to custom dialog if native share fails
        await _showWebShareDialog(context, event, shareText, eventUrl);
      }
    }
  }
  
  /// Generate share message for the event
  static String _generateShareMessage(Event event, String eventUrl) {
    final dateStr = _formatEventDate(event.startDate);
    final venue = event.venue?.name ?? 'Dubai';
    final price = event.isFree ? 'FREE' : event.displayPrice;
    
    return '''Check out this amazing event in Dubai! 🎉

${event.title}

📅 $dateStr
📍 $venue
💰 $price

${event.description.length > 100 ? event.description.substring(0, 100) + '...' : event.description}

Find more details: $eventUrl

Discover the best family events in Dubai with MyDscvr! 🌟
#Dubai #DubaiEvents #MyDscvr''';
  }
  
  /// Format event date for sharing
  static String _formatEventDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${_formatTime(date)}';
  }
  
  /// Format time for display
  static String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
  
  /// Show custom share dialog for web platform
  static Future<void> _showWebShareDialog(
    BuildContext context,
    Event event,
    String shareText,
    String eventUrl,
  ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareDialog(
        event: event,
        shareText: shareText,
        eventUrl: eventUrl,
      ),
    );
  }
}

/// Custom share dialog for web and fallback
class ShareDialog extends StatelessWidget {
  final Event event;
  final String shareText;
  final String eventUrl;
  
  const ShareDialog({
    Key? key,
    required this.event,
    required this.shareText,
    required this.eventUrl,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.share, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Share Event',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Share options
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Social media options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ShareOption(
                      icon: Icons.message,
                      label: 'WhatsApp',
                      color: const Color(0xFF25D366),
                      onTap: () => _shareToWhatsApp(context),
                    ),
                    _ShareOption(
                      icon: Icons.facebook,
                      label: 'Facebook',
                      color: const Color(0xFF1877F2),
                      onTap: () => _shareToFacebook(context),
                    ),
                    _ShareOption(
                      icon: Icons.telegram,
                      label: 'Telegram',
                      color: const Color(0xFF0088CC),
                      onTap: () => _shareToTelegram(context),
                    ),
                    _ShareOption(
                      icon: Icons.email,
                      label: 'Email',
                      color: Colors.red,
                      onTap: () => _shareViaEmail(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // More options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ShareOption(
                      icon: Icons.chat,
                      label: 'Messages',
                      color: Colors.green,
                      onTap: () => _shareViaSMS(context),
                    ),
                    _ShareOption(
                      icon: Icons.camera_alt,
                      label: 'Instagram',
                      color: const Color(0xFFE4405F),
                      onTap: () => _shareToInstagram(context),
                    ),
                    _ShareOption(
                      icon: Icons.link,
                      label: 'Copy Link',
                      color: Colors.grey,
                      onTap: () => _copyLink(context),
                    ),
                    if (!kIsWeb) 
                      _ShareOption(
                        icon: Icons.more_horiz,
                        label: 'More',
                        color: Colors.blue,
                        onTap: () => _shareNative(context),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _shareToWhatsApp(BuildContext context) async {
    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(shareText)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      Navigator.pop(context);
    } else {
      _showError(context, 'Could not open WhatsApp');
    }
  }
  
  void _shareToFacebook(BuildContext context) async {
    final url = Uri.parse('https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(eventUrl)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      Navigator.pop(context);
    } else {
      _showError(context, 'Could not open Facebook');
    }
  }
  
  void _shareToTelegram(BuildContext context) async {
    final url = Uri.parse('https://t.me/share/url?url=${Uri.encodeComponent(eventUrl)}&text=${Uri.encodeComponent(shareText)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      Navigator.pop(context);
    } else {
      _showError(context, 'Could not open Telegram');
    }
  }
  
  void _shareViaEmail(BuildContext context) async {
    final subject = Uri.encodeComponent('Check out this event: ${event.title}');
    final body = Uri.encodeComponent(shareText);
    final url = Uri.parse('mailto:?subject=$subject&body=$body');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      Navigator.pop(context);
    } else {
      _showError(context, 'Could not open email app');
    }
  }
  
  void _shareViaSMS(BuildContext context) async {
    final url = Uri.parse('sms:?body=${Uri.encodeComponent(shareText)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      Navigator.pop(context);
    } else {
      _showError(context, 'Could not open messages app');
    }
  }
  
  void _shareToInstagram(BuildContext context) {
    // Instagram doesn't support direct URL sharing, so copy to clipboard
    _copyLink(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied! Share it on Instagram Stories or Posts'),
        duration: Duration(seconds: 3),
      ),
    );
  }
  
  void _copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: eventUrl));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event link copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _shareNative(BuildContext context) async {
    Navigator.pop(context);
    try {
      await Share.share(shareText, subject: event.title);
    } catch (e) {
      _showError(context, 'Could not share');
    }
  }
  
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}