import 'package:intl/intl.dart';

String formatFacebookStyleTime(String isoString) {
  try {
    final now = DateTime.now().toUtc().add(const Duration(hours: 6, minutes: 30)); // Myanmar Time
    final createdUtc = DateTime.parse(isoString).toUtc();
    final created = createdUtc.add(const Duration(hours: 6, minutes: 30)); // Convert to MM time

    final difference = now.difference(created);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (_isYesterday(now, created)) {
      return 'Yesterday at ${DateFormat('h:mm a').format(created)}';
    } else if (_isSameWeek(now, created)) {
      return '${DateFormat('EEEE').format(created)} at ${DateFormat('h:mm a').format(created)}';
    } else if (now.year == created.year) {
      return '${DateFormat('MMM d').format(created)} at ${DateFormat('h:mm a').format(created)}';
    } else {
      return '${DateFormat('MMM d, y').format(created)} at ${DateFormat('h:mm a').format(created)}';
    }
  } catch (e) {
    return 'Invalid time';
  }
}

bool _isYesterday(DateTime now, DateTime date) {
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  return date.year == yesterday.year &&
         date.month == yesterday.month &&
         date.day == yesterday.day;
}

bool _isSameWeek(DateTime now, DateTime date) {
  final nowMonday = now.subtract(Duration(days: now.weekday - 1));
  final dateMonday = date.subtract(Duration(days: date.weekday - 1));
  return nowMonday.year == dateMonday.year &&
         nowMonday.month == dateMonday.month &&
         nowMonday.day == dateMonday.day;
}
