import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shweeshaungdaily/views/mail/compose_mail.dart';
import 'package:shweeshaungdaily/views/mail/letter_view.dart';

class MailBoxHome extends StatefulWidget {
  const MailBoxHome({super.key});

  @override
  State<MailBoxHome> createState() => _MailBoxHomeState();
}

class _MailBoxHomeState extends State<MailBoxHome> {
  int _currentTabIndex = 1; // 0 for Sent, 1 for Inbox

  final List<Map<String, dynamic>> _inboxMessages = [
    {
      'id': '1',
      'sender': 'Anonymous Admirer',
      'preview': 'I saw you at the cafe yesterday...',
      'time': '10:30 AM',
      'isRead': false,
    },
    {
      'id': '2',
      'sender': 'Secret Friend',
      'preview': 'Your smile brightens my day...',
      'time': 'Yesterday',
      'isRead': true,
    },
    {
      'id': '3',
      'sender': 'Mystery Lover',
      'preview': 'I left a flower on your desk...',
      'time': 'Jul 12',
      'isRead': true,
    },
  ];

  final List<Map<String, dynamic>> _sentMessages = [
    {
      'id': 's1',
      'recipient': 'My Crush',
      'preview': 'I wanted to tell you how I feel...',
      'time': '11:45 AM',
      'isDelivered': true,
    },
    {
      'id': 's2',
      'recipient': 'Special Someone',
      'preview': 'Remember when we first met...',
      'time': 'Jul 10',
      'isDelivered': true,
    },
  ];

  void _switchTab(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  Widget _buildInboxCard(Map<String, dynamic> message) {
    return GestureDetector(
      onTap: () {
        setState(() {
          message['isRead'] = true;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoveLetterScreen(),
            //builder: (context) => LoveLetterScreen(message: message, isSent: false),
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
              backgroundColor: Colors.teal.withOpacity(0.2),
              child: Icon(
                message['isRead'] ? Icons.mark_email_read : Icons.mail,
                color: Colors.teal,
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
                      message['sender'],
                      style: TextStyle(
                        fontWeight:
                            message['isRead']
                                ? FontWeight.normal
                                : FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message['preview'],
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight:
                            message['isRead']
                                ? FontWeight.normal
                                : FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message['time'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoveLetterScreen()),
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
              child: Icon(
                message['isDelivered'] ? Icons.send : Icons.schedule,
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
                      'To: ${message['recipient']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message['preview'],
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message['time'],
                      style: TextStyle(fontSize: 12, color: Colors.pink[300]),
                    ),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ComposeLoveLetterScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInboxList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _inboxMessages.length,
      itemBuilder: (context, index) => _buildInboxCard(_inboxMessages[index]),
    );
  }

  Widget _buildSentList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sentMessages.length,
      itemBuilder: (context, index) => _buildSentCard(_sentMessages[index]),
    );
  }
}
