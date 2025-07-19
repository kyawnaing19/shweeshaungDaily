import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? highlightStyle; // New parameter for highlight style

  const CopyableText({
    super.key,
    required this.text,
    this.style,
    this.highlightStyle, // Added highlightStyle to the constructor
  });

  @override
  Widget build(BuildContext context) {
    // Define the default base style if none is provided
    final TextStyle defaultStyle =
        style ?? const TextStyle(color: Colors.black, fontSize: 15);
    // Define the default highlight style if none is provided
    final TextStyle defaultHighlightStyle =
        highlightStyle ??
        defaultStyle.copyWith(
          color: Colors.blueAccent, // A distinct color for highlighted text
          fontWeight: FontWeight.bold, // Make highlighted text bold
        );

    // List to hold the TextSpans
    List<TextSpan> textSpans = [];
    // Regular expression to find hashtags (e.g., #word or #multi_word)
    final RegExp hashtagRegExp = RegExp(r'#\w+');
    int lastMatchEnd = 0;

    // Iterate through all matches found by the regex
    hashtagRegExp.allMatches(text).forEach((match) {
      // Add the text before the current hashtag
      if (match.start > lastMatchEnd) {
        textSpans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: defaultStyle,
          ),
        );
      }
      // Add the highlighted hashtag itself
      textSpans.add(
        TextSpan(text: match.group(0), style: defaultHighlightStyle),
      );
      lastMatchEnd = match.end;
    });

    // Add any remaining text after the last hashtag
    if (lastMatchEnd < text.length) {
      textSpans.add(
        TextSpan(text: text.substring(lastMatchEnd), style: defaultStyle),
      );
    }

    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('"$text" copied to clipboard')));
      },
      child: RichText(text: TextSpan(children: textSpans)),
    );
  }
}
