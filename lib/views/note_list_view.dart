import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/utils/note_database/note_database.dart';
import 'package:shweeshaungdaily/views/animated_search_bar.dart';
import 'note_editor_page.dart';

class NotePage extends StatefulWidget {
  final VoidCallback? onBack;

  const NotePage({super.key, this.onBack});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

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

  List<Map<String, dynamic>> _notes = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus && _searchQuery.isEmpty) {
        _searchFocusNode.unfocus();
      }
    });
    _loadNotes();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
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
            AnimatedSearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              hintText: 'Search notes...',
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
                  itemCount:
                      _notes
                          .where(
                            (note) => note['subject']
                                .toString()
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()),
                          )
                          .length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final filteredNotes =
                        _notes
                            .where(
                              (note) => note['subject']
                                  .toString()
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()),
                            )
                            .toList();
                    final note = filteredNotes[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final updatedNote = await Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    NoteEditorPage(
                                      title: note['subject'],
                                      initialText: note['content'],
                                    ),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return Stack(
                                children: [
                                  FadeTransition(
                                    opacity: Tween<double>(
                                      begin: 1.0,
                                      end: 0.7,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                      ),
                                    ),
                                  ),
                                  FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: Tween<double>(
                                        begin: 0.8,
                                        end: 1.0,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.fastOutSlowIn,
                                        ),
                                      ),
                                      child: child,
                                    ),
                                  ),
                                ],
                              );
                            },
                            transitionDuration: const Duration(
                              milliseconds: 500,
                            ),
                          ),
                        );

                        if (updatedNote != null) {
                          await NoteDatabase().updateNote(
                            note['subject'],
                            updatedNote,
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
        backgroundColor: kPrimaryDarkColor,
        elevation: 8,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        onPressed: () async {
          String newTitle = '';
          await showGeneralDialog(
            context: context,
            pageBuilder: (context, animation, secondaryAnimation) {
              final focusNode = FocusNode();
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                elevation: 0,
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Note',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: kPrimaryDarkColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          focusNode: focusNode,
                          autofocus: false,
                          decoration: InputDecoration(
                            hintText: 'Enter note title...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                          onChanged: (value) => newTitle = value,
                          onTap: () => focusNode.requestFocus(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  kPrimaryDarkColor,
                                  kPrimaryDarkColor.withOpacity(0.8),
                                ],
                              ),
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                if (newTitle.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      content: const Text(
                                        'Please enter a title',
                                      ),
                                    ),
                                  );
                                } else {
                                  addNewNote(newTitle);
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                              child: const Text('Create'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 450),
          );
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4DB6AC).withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      //  bottomNavigationBar: CustomBottomNavBar(
      //     selectedIndex: _selectedIndex,
      //     onItemTapped: _onItemTapped,
      //   ),
    );
  }
}
