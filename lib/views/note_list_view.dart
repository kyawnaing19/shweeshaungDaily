
import 'package:flutter/material.dart'; 
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/utils/note_database/note_database.dart';
import 'note_editor_page.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  List<Map<String, dynamic>> _notes = [];
  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    await fetchAndCacheNotes();
    final db = NoteDatabase();
    final notes = await db.getAllNotes();

    setState(() {
      _notes = notes;
    });
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF4DB6AC),
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Note: If this is your main home page, Navigator.pop(context) might not be what you want here.
            // It would try to pop the current route, which might be the last route in the stack or the app itself.
            // Consider if you need a back button on your main Notes page.
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Note',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
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
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Color(0xFF4DB6AC)),
                  suffixIcon: Icon(Icons.tune, color: Color(0xFF4DB6AC)),
                ),
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
                  itemCount: _notes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final note = _notes[index];

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
                              'Last modified: ${DateTime.now().toString().substring(0, 10)}',
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
          // Add new note functionality
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) =>
                      const NoteEditorPage(title: 'New Note', initialText: ''),
            ),
          );
          if (newNote != null) {
            print('New Note created: $newNote');
            // You'd typically add this new note to a list or database here
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF4DB6AC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(icon: Icons.home, label: 'Home', isActive: false),
            _BottomNavItem(icon: Icons.notes, label: 'Notes', isActive: true),
            _BottomNavItem(
              icon: Icons.check_box,
              label: 'Tasks',
              isActive: false,
            ),
            _BottomNavItem(
              icon: Icons.person,
              label: 'Profile',
              isActive: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
          size: 26,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
