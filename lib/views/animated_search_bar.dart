import 'package:flutter/material.dart';

class AnimatedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  const AnimatedSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search...',
  });

  @override
  _AnimatedSearchBarState createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _expand();
      } else if (widget.controller.text.isEmpty) {
        _collapse();
      }
    });
  }

  void _expand() {
    setState(() {
      _isExpanded = true;
    });
    _animationController.forward();
  }

  void _collapse() {
    setState(() {
      _isExpanded = false;
    });
    _animationController.reverse();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: _isExpanded ? MediaQuery.of(context).size.width - 40 : 200,
      height: 50,
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
      child: Row(
        children: [
          if (_isExpanded)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              color: const Color(0xFF4DB6AC),
              onPressed: () {
                widget.controller.clear();
                widget.onChanged('');
                _focusNode.unfocus();
              },
            ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                border: InputBorder.none,
                icon:
                    _isExpanded
                        ? null
                        : const Icon(Icons.search, color: Color(0xFF4DB6AC)),
              ),
              onChanged: (value) {
                widget.onChanged(value);
                if (value.isNotEmpty && !_focusNode.hasFocus) {
                  FocusScope.of(context).requestFocus(_focusNode);
                }
              },
              onTap: () {
                if (!_isExpanded) {
                  _expand();
                }
              },
            ),
          ),
          if (_isExpanded && widget.controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              color: const Color(0xFF4DB6AC),
              onPressed: () {
                widget.controller.clear();
                widget.onChanged('');
              },
            ),
        ],
      ),
    );
  }
}
