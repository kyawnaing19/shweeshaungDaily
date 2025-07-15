import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class CommentSection extends StatefulWidget {
  final List<dynamic> comments;
  final int? feedId;
  final VoidCallback? onCommentSuccess;
  const CommentSection({
    super.key,
    required this.comments,
    required this.feedId,
    this.onCommentSuccess,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  List<dynamic>? _comments;
  bool _loading = true;
  bool _hasText = false;
  bool _showUserSuggestions = false;
  List<String> _userSuggestions = [];
  int _selectedSuggestionIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _controller.addListener(_onTextChanged);
    _fetchComments();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _animationController.forward();
    });
  }

  void _onTextChanged() {
    final text = _controller.text;
    setState(() {
      _hasText = text.trim().isNotEmpty;
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
    _animationController.dispose();
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

  Widget _buildCommentItem(dynamic comment) {
    final userName = comment['userName'] ?? 'User';
    final text = comment['text'] ?? '';
    final createdAt = comment['createdAt'] ?? '';
    final profileUrl = comment['authorProfileUrl'] ?? '';

    return FadeTransition(
      opacity: _opacityAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null,
              child:
                  profileUrl.isEmpty
                      ? const Icon(Icons.person, size: 20)
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(text, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  if (createdAt.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 8),
                      child: Text(
                        _formatDate(createdAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(Icons.comment, color: theme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (_comments?.length ?? 0).toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 0.5),

              // Comments list
              Expanded(
                child:
                    _loading
                        ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              theme.primaryColor,
                            ),
                          ),
                        )
                        : (_comments == null || _comments!.isEmpty)
                        ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.mode_comment_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No comments yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Be the first to comment!',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _comments!.length,
                          itemBuilder:
                              (context, index) =>
                                  _buildCommentItem(_comments![index]),
                        ),
              ),

              // Bottom input area
              SafeArea(
                top: false,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.only(
                    bottom: bottomInset,
                    left: 16,
                    right: 16,
                    top: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_showUserSuggestions)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 150),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _userSuggestions.length,
                            itemBuilder: (context, index) {
                              final user = _userSuggestions[index];
                              return Material(
                                color:
                                    index == _selectedSuggestionIndex
                                        ? theme.primaryColor.withOpacity(0.1)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                child: ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: theme.primaryColor
                                        .withOpacity(0.2),
                                    child: Icon(
                                      Icons.person,
                                      size: 16,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  title: Text(
                                    user,
                                    style: TextStyle(
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _controller.text = '@$user ';
                                      _controller.selection =
                                          TextSelection.fromPosition(
                                            TextPosition(
                                              offset: _controller.text.length,
                                            ),
                                          );
                                      _showUserSuggestions = false;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color:
                                      _hasText
                                          ? theme.primaryColor.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.2),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                focusNode: _focusNode,
                                controller: _controller,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                minLines: 1,
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Write a comment...',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  suffixIcon:
                                      _hasText
                                          ? IconButton(
                                            icon: const Icon(Icons.close),
                                            onPressed: () {
                                              _controller.clear();
                                              _focusNode.requestFocus();
                                            },
                                          )
                                          : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _hasText
                                      ? theme.primaryColor
                                      : Colors.grey[300],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.send_rounded,
                                color:
                                    _hasText ? Colors.white : Colors.grey[600],
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
                                              widget.onCommentSuccess?.call();
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
