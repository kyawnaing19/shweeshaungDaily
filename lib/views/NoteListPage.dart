import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/views/bottomNavBar.dart';

void main() {
  runApp(const NoteApp());
}

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // The NoteListPage is directly set as the home, acting as the initial page.
      home: const NoteListPage(),
    );
  }
}

class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  int _selectedIndex = 1; // Notes tab is selected by default

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Optionally, handle navigation here
    // CustomBottomNavBar.handleNavigation(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.teal[50], // Light teal background for the whole page
      appBar: AppBar(
        backgroundColor: Colors.teal, // Darker teal for the app bar
        elevation: 0, // No shadow for a flat design
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // In a multi-page app, this would typically pop the current route.
            // For a single page, it might just do nothing or close the app.
            Navigator.of(context).maybePop();
          },
        ),
        title: const Text(
          'Note',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: 6, // Number of note cards
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: NoteCard(
                        title: 'Parallel and Distributed Computing',
                        // You can add more note details here if needed
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final String title;

  const NoteCard({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3, // Slight shadow for the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          15.0,
        ), // Rounded corners for the card
      ),
      margin:
          EdgeInsets.zero, // No external margin, controlled by parent padding
      child: Container(
        width: double.infinity, // Card takes full available width
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
            color: Colors.teal[800], // Darker teal for text
          ),
        ),
      ),
    );
  }
}
