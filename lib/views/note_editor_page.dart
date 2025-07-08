import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class NoteEditorPage extends StatefulWidget {
  final String title;
  final String initialText;

  const NoteEditorPage({
    super.key,
    required this.title,
    required this.initialText,
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _showToolbar = false;

  @override
  void initState() {
    super.initState();

    final doc =
        widget.initialText.trim().isEmpty ? Document() : Document()
          ..insert(0, widget.initialText);

    _controller = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  void _saveNote() {
    final plainText = _controller.document.toPlainText();
    Navigator.pop(context, plainText);
  }

  void _toggleToolbar() {
    setState(() {
      _showToolbar = !_showToolbar;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ), // Close the shape
        actions: [
          Tooltip(
            message: 'Save note',
            child: IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: _saveNote,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Toolbar that appears below app bar
          AnimatedContainer(
            margin: const EdgeInsets.all(8),
            duration: const Duration(milliseconds: 450),
            height: _showToolbar ? 56 : 0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.9),
                width: 1,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: AnimatedSwitcher(
              switchInCurve: Curves.fastLinearToSlowEaseIn,
              switchOutCurve: Curves.fastEaseInToSlowEaseOut,
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) {
                final slideAnim = Tween<Offset>(
                  begin:
                      _showToolbar ? const Offset(-1, 0) : const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOutBack,
                    reverseCurve: Curves.easeInCirc,
                  ),
                );

                final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: anim,
                    curve: const Interval(0.2, 1.0),
                  ),
                );

                return SlideTransition(
                  position: slideAnim,
                  child: FadeTransition(
                    opacity: fadeAnim,
                    child: Transform.scale(
                      scale:
                          Tween<double>(begin: 0.95, end: 1.0)
                              .animate(
                                CurvedAnimation(
                                  parent: anim,
                                  curve: const Interval(
                                    0.1,
                                    0.8,
                                    curve: Curves.elasticOut,
                                  ),
                                ),
                              )
                              .value,
                      child: child,
                    ),
                  ),
                );
              },
              child:
                  _showToolbar
                      ? Material(
                        color: Colors.transparent,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: QuillSimpleToolbar(
                              controller: _controller,
                              config: QuillSimpleToolbarConfig(
                                buttonOptions: QuillSimpleToolbarButtonOptions(
                                  base: QuillToolbarBaseButtonOptions(
                                    iconTheme: QuillIconTheme(
                                      iconButtonSelectedData: IconButtonData(
                                        style: IconButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF4DB6AC,
                                          ).withOpacity(0.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                      iconButtonUnselectedData: IconButtonData(
                                        style: IconButton.styleFrom(
                                          foregroundColor: Colors.grey.shade700,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                showBoldButton: true,
                                showItalicButton: true,
                                showListNumbers: true,
                                showListBullets: true,
                                showQuote: false,
                                showCodeBlock: true,
                                showStrikeThrough: false,
                                showInlineCode: false,
                                showUndo: true,
                                showRedo: true,
                                showLink: true,
                                showAlignmentButtons: false,
                              ),
                            ),
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ),
          // Editor content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),

                padding: const EdgeInsets.all(20),
                child: QuillEditor.basic(
                  controller: _controller,
                  focusNode: _focusNode,
                  config: const QuillEditorConfig(),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4DB6AC),
        onPressed: _toggleToolbar,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) {
            return RotationTransition(
              turns:
                  child.key == const ValueKey('icon1')
                      ? Tween<double>(begin: 0.5, end: 1).animate(anim)
                      : Tween<double>(begin: 1, end: 0.5).animate(anim),
              child: child,
            );
          },
          child:
              _showToolbar
                  ? const Icon(Icons.close, key: ValueKey('icon1'))
                  : const Icon(Icons.edit, key: ValueKey('icon2')),
        ),
      ),
    );
  }
}
