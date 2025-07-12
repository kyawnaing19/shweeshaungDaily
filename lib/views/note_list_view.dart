import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/utils/note_database/note_database.dart';
import 'note_editor_page.dart';

class NotePage extends StatefulWidget {
  final VoidCallback? onBack;

  const NotePage({super.key, this.onBack});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {

String formatToMMT(String? utcString) {
  if (utcString == null) return 'Unknown';

  try {
    // Parse assuming the input is in UTC
    final utcTime = DateFormat('yyyy-MM-dd HH:mm:ss').parseUtc(utcString);

    // Convert to Myanmar Time (UTC+6:30)
    final mmtTime = utcTime.add(const Duration(hours: 6, minutes: 30));

    // Format back to the same format
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(mmtTime);
  } catch (e) {
    print('❌ Error: $e');
    return 'Invalid time';
  }
}
  //int _selectedIndex = 2; // State for the selected tab in the bottom navigation

  // void _onItemTapped(int index) {
  //   if (_selectedIndex == index) return;
  //   if (index == 1) {
  //     Navigator.of(context).pushReplacement(fadeRoute(const TimeTablePage()));
  //   }
  //   if (index == 0) {
  //     Navigator.of(context).pushReplacement(fadeRoute(const HomeScreenPage()));
  //   }
  //   if (index == 3) {
  //     Navigator.of(
  //       context,
  //     ).pushReplacement(fadeRoute(const ProfileRouterPage()));
  //   } else {
  //     setState(() {
  //       _selectedIndex = index;
  //     });
  //   }
  // }

  List<Map<String, dynamic>> _notes = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    await fetchAndCacheNotes();
    final db = NoteDatabase();
    final notes = await db.getAllNotes();

    if (!mounted) return;
    setState(() {
      _notes = notes;
    });
  }

  Future<void> addNewNote(String subject) async {
    final db = NoteDatabase();
    await db.insertNote(subject, []);
    _loadNotes();
  }

  Future<void> fetchAndCacheNotes() async {
    final db = NoteDatabase();
    final existing = await db.getAllNotes();

    if (existing.isEmpty) {
      final response = await ApiService.getSubjectsForNote();

      final List<dynamic> subjects = response;

      for (final subject in subjects) {
        await db.insertNote(
          subject.toString(),
          [],
        ); // Insert empty delta for now
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      // appBar: AppBar(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar added for better functionality
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Color(0xFF4DB6AC)),
                  // suffixIcon: Icon(Icons.tune, color: Color(0xFF4DB6AC)),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4DB6AC),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: ListView.separated(
                  itemCount: _notes
                      .where((note) => note['subject']
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final filteredNotes = _notes
                        .where((note) => note['subject']
                            .toString()
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();
                    final note = filteredNotes[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final updatedNote = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => NoteEditorPage(
                                  title: note['subject'],
                                  initialText: note['content'],
                                ), // Added dynamic initial text
                          ),
                        );

                        if (updatedNote != null) {
                          await NoteDatabase().updateNote(
                            note['subject'],
                            updatedNote, // store as delta again
                          );
                          _loadNotes();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note['subject'] ?? 'Untitled Note',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Last modified: ${formatToMMT(note['updatedAt'])}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.label_outline,
                                  color: Colors.grey[600],
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Lecture Notes',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4DB6AC),
        onPressed: () async {
          String newTitle = '';
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('New Note Title'),
                content: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Enter note title'),
                  onChanged: (value) {
                    newTitle = value;
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if(newTitle.isNotEmpty) {
                        addNewNote(newTitle);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Title cannot be empty')),
                        );
                      }
                      // You can handle the newTitle here if needed
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      //  bottomNavigationBar: CustomBottomNavBar(
      //     selectedIndex: _selectedIndex,
      //     onItemTapped: _onItemTapped,
      //   ),
    );
  }
}
