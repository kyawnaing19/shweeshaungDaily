import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shweeshaungdaily/views/view_router.dart';
import 'package:shweeshaungdaily/widget/copyable_text.dart';

import '../services/api_service.dart';

class CommentSection extends StatefulWidget {
  final String? profileUrl;
  final List<dynamic> comments;
  final int? feedId;
  final VoidCallback? onCommentSuccess;
  const CommentSection({
    super.key,
    required this.comments,
    required this.feedId,
    this.onCommentSuccess,
    this.profileUrl = '',
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  List<dynamic>? _comments;
  bool _loading = true;
  bool _hasText = false;
  bool _showUserSuggestions = false;
  List<String> _userSuggestions = [];
  int _selectedSuggestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _fetchComments();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _onTextChanged() {
    final text = _controller.text;
    setState(() {
      _hasText = text.trim().isNotEmpty;
      // Show suggestions if text starts with '@'
      if (text.startsWith('@')) {
        _userSuggestions = _getUniqueUserNames();
        _showUserSuggestions = _userSuggestions.isNotEmpty;
        _selectedSuggestionIndex = 0;
      } else {
        _showUserSuggestions = false;
      }
    });
  }

  List<String> _getUniqueUserNames() {
    if (_comments == null) return [];
    final names =
        _comments!
            .map((c) => c['userName']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList();
    return names;
  }

  Future<void> _fetchComments() async {
    try {
      if (widget.feedId != null) {
        final apiComments = await ApiService.getComments(widget.feedId!);
        setState(() {
          _comments = apiComments ?? widget.comments;
          _loading = false;
        });
      } else {
        setState(() {
          _comments = widget.comments;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _comments = widget.comments;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return DraggableScrollableSheet(
      initialChildSize: 1.0,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.comment, color: Colors.black54),
                    const SizedBox(width: 8),
                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      (_comments?.length ?? 0).toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child:
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : (_comments == null || _comments!.isEmpty)
                        ? const Center(child: Text('No comments yet.'))
                        : ListView.builder(
                          controller: scrollController,
                          itemCount: _comments!.length,
                          itemBuilder: (context, index) {
                        
                            final comment = _comments![index];
                            final email = comment['email'];
                            final userName = comment['userName'] ?? 'User';
                            final text = comment['text'] ?? '';
                            final createdAt = comment['createdAt'] ?? '';
                            final profileUrl =
                                comment['authorProfileUrl'] ?? '';
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    (profileUrl != null &&
                                            profileUrl.isNotEmpty)
                                        ? NetworkImage(profileUrl)
                                        : null,
                                child:
                                    (profileUrl == null || profileUrl.isEmpty)
                                        ? const Icon(Icons.person)
                                        : null,
                              ),
                              title: GestureDetector(
                                onTap: () {
      // Your onTap logic
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ViewRouter(email: email,)),
      );
    },
                                
                                child: Text(userName)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CopyableText(text: text),
                                  if (createdAt.isNotEmpty)
                                    Text(
                                      _formatDate(createdAt),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
              const Divider(height: 1),
              SafeArea(
                top: false,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(
                    bottom: bottomInset,
                    left: 16,
                    right: 8,
                    top: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_showUserSuggestions)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 150),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _userSuggestions.length,
                            itemBuilder: (context, index) {
                              final user = _userSuggestions[index];
                              return ListTile(
                                dense: true,
                                tileColor:
                                    index == _selectedSuggestionIndex
                                        ? Colors.blue.shade50
                                        : null,
                                title: Text(user),
                                onTap: () {
                                  setState(() {
                                    _controller.text = '$user ';
                                    _controller
                                        .selection = TextSelection.fromPosition(
                                      TextPosition(
                                        offset: _controller.text.length,
                                      ),
                                    );
                                    _showUserSuggestions = false;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      Row(
                        children: [
                          // Leading CircleAvatar
                          Padding(
                            padding: EdgeInsets.only(
                              left: 8.0,
                              right: 8.0,
                              bottom: 10,
                            ),
                            child: CircleAvatar(
                              backgroundImage:
                                  widget.profileUrl?.isNotEmpty ?? false
                                      ? NetworkImage(widget.profileUrl!)
                                      : null,
                              child:
                                  widget.profileUrl?.isEmpty ?? true
                                      ? const Icon(Icons.person)
                                      : null,
                            ),
                          ),
                          // Expanded TextField
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 4.0, bottom: 10),
                              child: TextField(
                                focusNode: _focusNode,
                                controller: _controller,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                minLines: 1,
                                decoration: InputDecoration(
                                  hintText: 'Write a comment...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Send IconButton
                          Padding(
                            padding: EdgeInsets.only(
                              left: 4.0,
                              right: 8.0,
                              bottom: 10,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.send_rounded,
                                color:
                                    _hasText
                                        ? Colors.blue
                                        : const Color.fromARGB(
                                          255,
                                          230,
                                          159,
                                          159,
                                        ),
                              ),
                              onPressed:
                                  _hasText
                                      ? () async {
                                        if (widget.feedId != null) {
                                          final text = _controller.text.trim();
                                          if (text.isNotEmpty) {
                                            final success =
                                                await ApiService.comment(
                                                  widget.feedId!,
                                                  text,
                                                );
                                            if (success) {
                                              _controller.clear();
                                              FocusScope.of(context).unfocus();
                                              await _fetchComments();
                                              if (widget.onCommentSuccess !=
                                                  null) {
                                                widget.onCommentSuccess!();
                                              }
                                            }
                                          }
                                        }
                                      }
                                      : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
