import 'package:flutter/material.dart';

class MailBoxHome extends StatefulWidget {
  const MailBoxHome({super.key});

  @override
  State<MailBoxHome> createState() => _MailBoxHomeState();
}

class _MailBoxHomeState extends State<MailBoxHome> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildMailCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage(
            'assets/images/noinfomail.png',
          ), // Replace with your asset path
          fit: BoxFit.cover,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Container(
        // Overlay color to make text more readable (optional)
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0), // Adjust opacity as needed
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Anonymous",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // Text(
                    //   "Miss You",
                    //   style: TextStyle(fontWeight: FontWeight.w500),
                    // ),
                    SizedBox(height: 4),
                    Text(
                      "I just want to know, you ....",
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "1:30 AM",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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

  @override
  Widget build(BuildContext context) {
    final tabs = ['Compose Mail', 'Inbox'];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'MailBox',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(tabs.length, (index) {
                final isActive = index == 1; // default: Inbox
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Colors.teal : Colors.black54,
                      decoration:
                          isActive
                              ? TextDecoration.underline
                              : TextDecoration.none,
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildMailCard();
              },
            ),
          ),
        ],
      ),
    );
  }
}
