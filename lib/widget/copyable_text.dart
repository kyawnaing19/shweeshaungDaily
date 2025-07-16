import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyableText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const CopyableText({super.key, required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('"$text" copied to clipboard')));
      },
      child: Text(text, style: style ?? const TextStyle(color: Colors.black)),
    );
  }
}
