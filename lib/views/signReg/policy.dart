import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  // Helper function to build list items
  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16.0, height: 1.7),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build a section
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32.0),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF004D7A),
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 16.0),
          ...children,
        ],
      ),
    );
  }

  // Helper function to build a sub-heading
  Widget _buildSubHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF006699),
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          height: 1.7,
        ),
      ),
    );
  }

  // Helper function to build a paragraph
  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16.0,
          color: Color(0xFF333333),
          height: 1.7,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // body background-color
      appBar: AppBar(
        backgroundColor: kAccentColor,
        actions: [
          // Replaced NotificationIcon with Text 'Note'
          const Padding(
            // Use Padding to give the text some space if needed
            padding: EdgeInsets.only(right: 40.0), // A
            // Use Padding to give the text some space if needed
            child: Text(
              'Privacy Policies & Terms of Services',
              style: TextStyle(
                fontSize: 18, // Adjust font size as needed
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 900,
            ), // max-width for main content
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Privacy Policy Section
                  _buildSection(
                    title: 'Privacy Policy',
                    children: [
                      _buildParagraph('Effective Date: 23 July 2025'),
                      _buildSubHeading('1. Information We Collect'),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildListItem(
                            'Email address (limited to @ucstt.edu.mm)',
                          ),
                          _buildListItem('User role (Student or Teacher)'),
                          _buildListItem(
                            'Student academic details (Semester and Major)',
                          ),
                          _buildListItem(
                            'Feed posts, comments, and mailbox messages',
                          ),
                          _buildListItem(
                            'Voice messages sent by teachers or administrators',
                          ),
                        ],
                      ),
                      _buildSubHeading('2. Use of Information'),
                      _buildParagraph(
                        'Your information is used to manage account access, deliver relevant content based on role and semester, and ensure appropriate moderation of the platform.',
                      ),
                      _buildSubHeading('3. Public Content'),
                      _buildParagraph(
                        'Mailbox messages are public. Students may send messages in either anonymous or named mode from Friday to Sunday. These messages are displayed from Monday to Wednesday and are visible to all students. Feed posts, voice messages, and albums are also visible to appropriate users. Albums are always public and can be viewed by all users if uploaded.',
                      ),
                      _buildSubHeading('4. Data Retention'),
                      _buildParagraph(
                        'We retain user data for as long as your account remains active. You may request deletion at any time by contacting our team.',
                      ),
                      _buildSubHeading('5. Data Sharing'),
                      _buildParagraph(
                        'We do not sell or share your personal information with third parties.',
                      ),
                      _buildParagraph(
                        'Mailbox content is not shared with teachers.',
                      ),
                      _buildParagraph(
                        'Notes are stored only locally and are not collected or shared by the platform.',
                      ),
                      _buildSubHeading('6. Security'),
                      _buildParagraph(
                        'We implement encryption and secure authentication protocols to protect your data.',
                      ),
                      _buildParagraph(
                        'Passwords and mailbox message contents are encrypted for your privacy.',
                      ),
                      _buildParagraph(
                        'While administrators can view sender and receiver information, mailbox message content is encrypted in the database. For your safety, we advise against including sensitive or personal information in messages.',
                      ),
                      _buildSubHeading('7. Your Rights'),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildListItem(
                            'View and review your personal information',
                          ),
                          _buildListItem('Request data deletion'),
                          _buildListItem(
                            'Report harmful or inappropriate content via email',
                          ),
                        ],
                      ),
                      _buildSubHeading('8. Policy Updates'),
                      _buildParagraph(
                        'This policy may be updated occasionally. All changes will be posted here and announced via the app or email.',
                      ),
                      _buildSubHeading('9. Contact'),
                      Text.rich(
                        TextSpan(
                          text: 'For questions or support, please contact: ',
                          style: const TextStyle(fontSize: 16.0, height: 1.7),
                          children: [
                            TextSpan(
                              text: 'shweeshaung2024@gmail.com',
                              style: const TextStyle(
                                color: Color(0xFF004D7A),
                                decoration: TextDecoration.underline,
                                fontSize: 16.0,
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Terms of Service Section
                  _buildSection(
                    title: 'Terms of Service',
                    children: [
                      _buildParagraph('Effective Date: 23 July 2025'),
                      _buildSubHeading('1. Eligibility'),
                      _buildParagraph(
                        'Only registered students, teachers, and administrators of UCSTT with a valid @ucstt.edu.mm email address may access this service.',
                      ),
                      _buildSubHeading('2. User Roles'),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildListItem(
                            'Students: May comment on Bulletins, send mailbox messages (Friday–Sunday), view mailbox content (Monday–Wednesday), take notes offline, and upload up to five photos to their public Album.',
                          ),
                          _buildListItem(
                            'Teachers: May post Bulletins, send voice messages (to students), and upload photos to their public Album.',
                          ),
                          _buildListItem(
                            'Admins (Rector and Pro Rector): Have full permissions, including the ability to send voice messages and platform-wide content to any user.',
                          ),
                        ],
                      ),
                      _buildSubHeading('3. Mailbox, Album & Feed Rules'),
                      _buildParagraph(
                        'Mailbox messages are publicly visible, even when sent anonymously. They are shown to all students from Monday to Wednesday. Albums are always public and viewable by all users; each user may upload a maximum of five photos. All content must follow university and community guidelines—hate speech, harassment, and the sharing of personal data are strictly prohibited.',
                      ),
                      _buildSubHeading('4. Intellectual Property'),
                      _buildParagraph(
                        'All platform software and services are the property of The Shwee Shaung Team. Users retain ownership of their content but grant us permission to display and moderate it within the platform.',
                      ),
                      _buildSubHeading('5. Termination'),
                      _buildParagraph(
                        'We reserve the right to suspend or ban users who violate our terms or university conduct policies.',
                      ),
                      _buildSubHeading('6. Disclaimers'),
                      _buildParagraph(
                        'The service is provided as-is. We are not responsible for any user-generated content or loss of data.',
                      ),
                      _buildSubHeading('7. Changes to Terms'),
                      _buildParagraph(
                        'Terms may be updated periodically. Users will be informed via in-app notices or email.',
                      ),
                    ],
                  ),

                  // User Agreement Section
                  _buildSection(
                    title: 'User Agreement',
                    children: [
                      _buildParagraph('Effective Date: 23 July 2025'),
                      _buildSubHeading('1. Agreement to Terms'),
                      _buildParagraph(
                        'By accessing or using this app, you agree to abide by this User Agreement and the Privacy Policy. If you do not agree, please do not use the service.',
                      ),
                      _buildSubHeading('2. Account Eligibility'),
                      _buildParagraph(
                        'Only students, teachers, and administrators from the University of Computer Studies, Thaton (UCSTT) with a valid @ucstt.edu.mm email address may register and use the app.',
                      ),
                      _buildSubHeading('3. User Responsibilities'),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildListItem(
                            'Maintain respectful behavior in all public interactions.',
                          ),
                          _buildListItem(
                            'Do not use the platform to harass, threaten, or bully others.',
                          ),
                          _buildListItem(
                            'Refrain from posting confidential university or personal data in public features.',
                          ),
                          _buildListItem(
                            'Use the Mailbox feature only during the designated period (Friday–Sunday).',
                          ),
                          _buildListItem(
                            'Understand that Mailbox, Album, and Feed content may be visible to others.',
                          ),
                        ],
                      ),
                      _buildSubHeading('4. Prohibited Conduct'),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildListItem(
                            'No hate speech, discrimination, or harassment',
                          ),
                          _buildListItem(
                            'No impersonation or use of false identities',
                          ),
                          _buildListItem(
                            'No use of offensive language or inappropriate content',
                          ),
                          _buildListItem(
                            'No spamming or sending repetitive unwanted messages',
                          ),
                        ],
                      ),
                      _buildSubHeading('5. Suspension or Termination'),
                      _buildParagraph(
                        'Violations of these rules may lead to content removal, account suspension, or permanent banning without prior notice.',
                      ),
                      _buildSubHeading('6. User Content and Ownership'),
                      _buildParagraph(
                        'You retain ownership of all content you create. However, by using this service, you grant us the right to display, store, and moderate your content as needed to ensure safe and responsible platform use.',
                      ),
                      _buildSubHeading('7. Changes to this Agreement'),
                      _buildParagraph(
                        'We may revise this User Agreement as needed. Continued use of the app signifies acceptance of the updated terms.',
                      ),
                      _buildSubHeading('8. Contact'),
                      Text.rich(
                        TextSpan(
                          text:
                              'If you have any questions or concerns, please reach out to us at ',
                          style: const TextStyle(fontSize: 16.0, height: 1.7),
                          children: [
                            TextSpan(
                              text: 'shweeshaung2024@gmail.com',
                              style: const TextStyle(
                                color: Color(0xFF004D7A),
                                decoration: TextDecoration.underline,
                                fontSize: 16.0,
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFFF9FAFB), // Footer background to match body
        padding: const EdgeInsets.all(32.0),
        child: const Text(
          '© 2025 The Shwee Shaung Team. All rights reserved.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.0,
            color: Color(0xFF888888), // footer text color
          ),
        ),
      ),
    );
  }
}
