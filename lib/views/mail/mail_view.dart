import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shweeshaungdaily/views/mail/compose_mail.dart';
import 'package:shweeshaungdaily/views/mail/letter_view.dart';
import 'package:shweeshaungdaily/services/api_service.dart'; // Make sure this path is correct

class MailBoxHome extends StatefulWidget {
  const MailBoxHome({super.key});

  @override
  State<MailBoxHome> createState() => _MailBoxHomeState();
}

class _MailBoxHomeState extends State<MailBoxHome> {
  int _currentTabIndex = 1; // 0 for Sent, 1 for Inbox

  // Declare a Future to hold the result of the API call for sent mails.
  // This will be initialized in initState and potentially re-fetched.
  late Future<List<Map<String, dynamic>>?> _sentMailsFuture;
  late Future<List<Map<String, dynamic>>?> _getInboxMessages;

  // Keep mock data for inbox for now, as you only provided getSentMails
  

  @override
void initState() {
  super.initState();
  _fetchSentMails();
  _fetchAllMails();
   // This will now fetch real data in production
  // For testing, you can override it like this:
  _sentMailsFuture = Future.value([
    {
      'text': 'This is the body of the test email.',
      'recipientId': 123,
      'recipientName': 'Test Recipient',
      'semester': '2025 Fall',
      'major': 'Computer Science',
      'senderId': 456,
      'senderName': 'Test Sender',
      // No 'isDelivered' or 'time' in this sample
    },
    {
      'text': 'Another test email about a project.',
      'recipientId': 789,
      'recipientName': 'Project Collaborator',
      'semester': '2026 Spring',
      'major': 'Electrical Engineering',
      'senderId': null, // Anonymous
      'senderName': null, // Anonymous
    },
  ]);

  _getInboxMessages = Future.value([
    {
      'text': 'Inbox.',
      'recipientId': 123,
      'recipientName': 'Recipient',
      'semester': '2025 Fall',
      'major': 'Computer Science',
      'senderId': 456,
      'senderName': 'Test Sender',
      // No 'isDelivered' or 'time' in this sample
    },
    {
      'text': 'Another test email about a project.',
      'recipientId': 789,
      'recipientName': 'Project Collaborator',
      'semester': '2026 Spring',
      'major': 'Electrical Engineering',
      'senderId': null, // Anonymous
      'senderName': null, // Anonymous
    },
  ]);

}

  // A method to fetch sent mails
  void _fetchSentMails() {
    setState(() {
     // _sentMailsFuture = ApiService.getSentMails();
    });
  }

  void _fetchAllMails() {
    setState(() {
     // _sentMailsFuture = ApiService.getSentMails();
    });
  }

  void _switchTab(int index) {
    setState(() {
      _currentTabIndex = index;
    });
    // If you switch to the Sent tab, you might want to re-fetch to get the latest.
    if (index == 0) {
      _fetchSentMails();
    }
  }

  // ... (Your _buildInboxCard and _buildSentCard methods remain the same for now)
  //     (Consider updating LoveLetterScreen to accept message data later)

  Widget _buildInboxCard(Map<String, dynamic> message) {
  // Extract the relevant fields from the message map
  final String recipientName = message['recipientName'] ?? 'Unknown Recipient';
  final String semester = message['semester'] ?? 'N/A';
  final String major = message['major'] ?? 'N/A';
  // Removed 'time' as it's not in PublicMailDTO and you only want specified fields
  // If you still want to show a time, you'd need to add it to your DTO or determine how it's sent from the API.

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoveLetterScreen(message: message, isSent: true),
          // You might want to pass the full message to LoveLetterScreen if it needs all details
          // builder: (context) => LoveLetterScreen(message: message, isSent: true),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('assets/images/noinfomail.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.pink.withOpacity(0.2),
            // Removed isDelivered logic. Using a static send icon now.
            child: const Icon(
              Icons.send, // Static send icon
              color: Colors.pink,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To: $recipientName', // Display recipientName
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Semester: $semester', // Display semester
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Major: $major', // Display major
                    style: const TextStyle(color: Colors.black),
                  ),
                  // Removed the Text for 'time' as it's not in your DTO
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSentCard(Map<String, dynamic> message) {
  // Extract the relevant fields from the message map
  final String recipientName = message['recipientName'] ?? 'Unknown Recipient';
  final String semester = message['semester'] ?? 'N/A';
  final String major = message['major'] ?? 'N/A';
  // Removed 'time' as it's not in PublicMailDTO and you only want specified fields
  // If you still want to show a time, you'd need to add it to your DTO or determine how it's sent from the API.

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoveLetterScreen(message: message, isSent: true),
          // You might want to pass the full message to LoveLetterScreen if it needs all details
          // builder: (context) => LoveLetterScreen(message: message, isSent: true),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('assets/images/noinfomail.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.pink.withOpacity(0.2),
            // Removed isDelivered logic. Using a static send icon now.
            child: const Icon(
              Icons.send, // Static send icon
              color: Colors.pink,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To: $recipientName', // Display recipientName
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Semester: $semester', // Display semester
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Major: $major', // Display major
                    style: const TextStyle(color: Colors.black),
                  ),
                  // Removed the Text for 'time' as it's not in your DTO
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              0,
              'Sent',
              Icons.send_rounded,
              Colors.pinkAccent.withOpacity(0.9),
            ),
          ),
          Container(width: 1, height: 24, color: Colors.grey.withOpacity(0.2)),
          Expanded(
            child: _buildTabButton(
              1,
              'Inbox',
              Icons.mark_email_read_rounded,
              const Color.fromARGB(211, 21, 196, 2).withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    int index,
    String label,
    IconData icon,
    Color activeColor,
  ) {
    bool isActive = _currentTabIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        gradient:
            isActive
                ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    activeColor.withOpacity(0.1),
                    activeColor.withOpacity(0.05),
                  ],
                )
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _switchTab(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? activeColor : Colors.grey.withOpacity(0.8),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        isActive ? activeColor : Colors.grey.withOpacity(0.8),
                  ),
                ),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    height: 2,
                    width: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: [activeColor, activeColor.withOpacity(0.5)],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Love Letters',
          style: GoogleFonts.parisienne(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _currentTabIndex == 1 ? _buildInboxList() : _buildSentList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.edit, color: Colors.white),
        onPressed: () async {
          // Navigate to compose mail screen and await its result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ComposeLoveLetterScreen(),
            ),
          );
          // If a mail was successfully sent (you can pass 'true' back from ComposeLoveLetterScreen)
          if (result == true && _currentTabIndex == 0) {
            _fetchSentMails(); // Refresh only if on sent tab
          } else if (result == true && _currentTabIndex == 1) {
            // If you implement getInboxMails, you'd fetch inbox here too
          }
        },
      ),
    );
  }

  Widget _buildInboxList() {
    return FutureBuilder<List<Map<String, dynamic>>?>(
      future: _getInboxMessages, // Use the Future here
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while data is being fetched
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Show an error message if something went wrong
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 10),
                Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _fetchAllMails, // Retry button
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          // Data successfully fetched
          final List<Map<String, dynamic>> sentMessages = snapshot.data!;
          if (sentMessages.isEmpty) {
            return const Center(child: Text('No sent messages yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sentMessages.length,
            itemBuilder: (context, index) => _buildInboxCard(sentMessages[index]),
          );
        } else {
          // No data available (e.g., API returned null, or empty list if no error)
          return const Center(child: Text('No sent messages found.'));
        }
      },
    );
  }

  Widget _buildSentList() {
    return FutureBuilder<List<Map<String, dynamic>>?>(
      future: _sentMailsFuture, // Use the Future here
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while data is being fetched
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Show an error message if something went wrong
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 10),
                Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _fetchSentMails, // Retry button
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          // Data successfully fetched
          final List<Map<String, dynamic>> sentMessages = snapshot.data!;
          if (sentMessages.isEmpty) {
            return const Center(child: Text('No sent messages yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sentMessages.length,
            itemBuilder: (context, index) => _buildSentCard(sentMessages[index]),
          );
        } else {
          // No data available (e.g., API returned null, or empty list if no error)
          return const Center(child: Text('No sent messages found.'));
        }
      },
    );
  }
}