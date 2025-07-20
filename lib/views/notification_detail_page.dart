import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shweeshaungdaily/colors.dart'; // Ensure this path is correct
import 'package:shweeshaungdaily/views/notification_list_view.dart'; // Import NotificationItem model

// -----------------------------------------------------------------------------
// General Notification Detail Page (Handles various sub-types)
// -----------------------------------------------------------------------------
class GeneralNotificationDetailPage extends StatelessWidget {
  final NotificationItem notification;

  const GeneralNotificationDetailPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    Widget contentSection;
    switch (notification.subType) {
      case 'app_maintenance':
        contentSection = _AppMaintenanceSection(notification: notification);
        break;
      case 'general_knowledge':
        contentSection = _GeneralKnowledgeSection(notification: notification);
        break;
      case 'quote':
        contentSection = _QuoteSection(notification: notification);
        break;
      case 'sweet_message':
        contentSection = _SweetMessageSection(notification: notification);
        break;
      default:
        // Default content for 'general' type without a specific subType
        contentSection = _DefaultGeneralSection(notification: notification);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          notification.title,
        ), // AppBar title can be dynamic based on notification title
        backgroundColor: kAccentColor, // Using kAccentColor
        foregroundColor: kWhite, // Text color for AppBar title
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: contentSection,
      ),
    );
  }
}

// Helper widget for common info rows
Widget _buildInfoRow(
  BuildContext context,
  IconData icon,
  String label,
  String value, {
  Color? valueColor,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: kGrey), // Using kGrey
      const SizedBox(width: 10),
      Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: kTextColor, // Using kTextColor
        ),
      ),
      const SizedBox(width: 5),
      Expanded(
        child: Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: valueColor ?? kLightTextColor, // Using kLightTextColor
          ),
        ),
      ),
    ],
  );
}

// -----------------------------------------------------------------------------
// Specific Sections for General Notifications
// -----------------------------------------------------------------------------

class _DefaultGeneralSection extends StatelessWidget {
  final NotificationItem notification;

  const _DefaultGeneralSection({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(notification.icon, color: notification.color, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                notification.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: kTextColor, // Using kTextColor
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 30, thickness: 1),
        Text(
          'Details:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: kPrimaryColor, // Using kPrimaryColor
          ),
        ),
        const SizedBox(height: 8),
        Text(
          notification.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: kLightTextColor,
          ), // Using kLightTextColor
        ),
        const SizedBox(height: 20),
        _buildInfoRow(
          context,
          Icons.access_time,
          'Time Received:',
          DateFormat('MMM d, y - hh:mm a').format(notification.time),
        ),
        const SizedBox(height: 10),
        _buildInfoRow(
          context,
          notification.isRead ? Icons.check_circle_outline : Icons.info_outline,
          'Status:',
          notification.isRead ? 'Read' : 'Unread',
          valueColor:
              notification.isRead
                  ? Colors.green
                  : kErrorColor, // Using kErrorColor
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Action for ${notification.title}')),
              );
            },
            icon: const Icon(Icons.info_outline),
            label: const Text('More Info'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor, // Using kPrimaryColor
              foregroundColor: kWhite, // Using kWhite
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppMaintenanceSection extends StatelessWidget {
  final NotificationItem notification;

  const _AppMaintenanceSection({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(notification.icon, size: 80, color: notification.color),
        const SizedBox(height: 20),
        Text(
          notification.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: kTextColor, // Using kTextColor
          ),
        ),
        const SizedBox(height: 15),
        Text(
          notification.description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: kLightTextColor,
          ), // Using kLightTextColor
        ),
        const SizedBox(height: 30),
        const LinearProgressIndicator(
          value: 0.0, // No progress for maintenance, just a visual element
          backgroundColor: kGrey, // Using kGrey
          valueColor: AlwaysStoppedAnimation<Color>(
            kPrimaryDarkColor,
          ), // Using kPrimaryDarkColor
          minHeight: 10,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        const SizedBox(height: 10),
        Text(
          'Scheduled for: ${DateFormat('MMM d, y - hh:mm a').format(notification.time)}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: kGrey), // Using kGrey
        ),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Maintenance details requested.')),
            );
          },
          icon: const Icon(Icons.calendar_today),
          label: const Text('View Schedule'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                notification.color, // Notification's specific color
            foregroundColor: kWhite, // Using kWhite
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class _GeneralKnowledgeSection extends StatelessWidget {
  final NotificationItem notification;

  const _GeneralKnowledgeSection({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Icon(notification.icon, size: 60, color: notification.color),
        ),
        const SizedBox(height: 20),
        Text(
          notification.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: kTextColor, // Using kTextColor
          ),
        ),
        const Divider(height: 30, thickness: 1),
        Text(
          'Fact:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: kPrimaryColor, // Using kPrimaryColor
          ),
        ),
        const SizedBox(height: 8),
        Text(
          notification.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: kLightTextColor,
          ), // Using kLightTextColor
        ),
        const SizedBox(height: 20),
        _buildInfoRow(
          context,
          Icons.access_time,
          'Published:',
          DateFormat('MMM d, y').format(notification.time),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exploring more facts!')),
              );
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explore More'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  notification.color, // Notification's specific color
              foregroundColor: kWhite, // Using kWhite
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuoteSection extends StatelessWidget {
  final NotificationItem notification;

  const _QuoteSection({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(notification.icon, size: 60, color: notification.color),
        const SizedBox(height: 20),
        Text(
          notification.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: kTextColor, // Using kTextColor
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardGradientStart.withOpacity(
              0.1,
            ), // Using kCardGradientStart
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: notification.color, width: 2),
          ),
          child: Column(
            children: [
              Text(
                notification.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: kTextColor, // Using kTextColor
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '- Author Name', // Assuming author is part of description or separate field
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: kLightTextColor, // Using kLightTextColor
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sharing inspiration!')),
            );
          },
          icon: const Icon(Icons.share),
          label: const Text('Share Quote'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                notification.color, // Notification's specific color
            foregroundColor: kWhite, // Using kWhite
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class _SweetMessageSection extends StatelessWidget {
  final NotificationItem notification;

  const _SweetMessageSection({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(notification.icon, size: 80, color: notification.color),
        const SizedBox(height: 20),
        Text(
          notification.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: kTextColor, // Using kTextColor
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                notification.color.withOpacity(0.2),
                kWhite,
              ], // Using kWhite
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: notification.color.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            notification.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: kTextColor, // Using kTextColor
            ),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sending good vibes back!')),
            );
          },
          icon: const Icon(Icons.favorite),
          label: const Text('Send Good Vibes'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                notification.color, // Notification's specific color
            foregroundColor: kWhite, // Using kWhite
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Type-Specific Detail Pages: Voicemail & Bulletin (Remain largely unchanged, colors updated)
// -----------------------------------------------------------------------------

class VoicemailDetailPage extends StatelessWidget {
  final NotificationItem notification;

  const VoicemailDetailPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voicemail'),
        backgroundColor: notification.color, // Notification's specific color
        foregroundColor: kWhite, // Text color for AppBar title
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: kWhite, // Using kWhite
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: notification.color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              notification.icon,
              size: 60,
              color: notification.color, // Notification's specific color
            ),
            const SizedBox(height: 20),
            Text(
              notification.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: notification.color, // Notification's specific color
              ),
            ),
            const SizedBox(height: 10),
            Text(
              notification.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: kLightTextColor,
              ), // Using kLightTextColor
            ),
            const Divider(height: 30, thickness: 1),
            _buildInfoRow(
              context,
              Icons.phone,
              'From:',
              'Unknown Caller (555-1234)', // Example caller
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              context,
              Icons.access_time,
              'Duration:',
              '00:45', // Example duration
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Playing voicemail...')),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play Voicemail'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    notification.color, // Notification's specific color
                foregroundColor: kWhite, // Using kWhite
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: kGrey), // Using kGrey
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: kTextColor, // Using kTextColor
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: kLightTextColor, // Using kLightTextColor
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BulletinDetailPage extends StatelessWidget {
  final NotificationItem notification;

  const BulletinDetailPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulletin'),
        backgroundColor: notification.color, // Notification's specific color
        foregroundColor: kWhite, // Text color for AppBar title
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kWhite,
              notification.color.withOpacity(0.1),
            ], // Using kWhite
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                notification.icon,
                size: 60,
                color: notification.color, // Notification's specific color
              ),
            ),
            const SizedBox(height: 20),
            Text(
              notification.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: kTextColor, // Using kTextColor
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 30, thickness: 1),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  notification.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: kLightTextColor,
                  ), // Using kLightTextColor
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Viewing full announcement...'),
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('View Full Announcement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      notification.color, // Notification's specific color
                  foregroundColor: kWhite, // Using kWhite
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
