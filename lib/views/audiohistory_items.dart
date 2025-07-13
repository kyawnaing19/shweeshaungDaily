// import 'package:flutter/material.dart';

// class AudioHistoryItem extends StatefulWidget {
//   final String title;
//   final String author;
//   final DateTime time;
//   final String audioUrl;

//   const AudioHistoryItem({
//     Key? key,
//     required this.title,
//     required this.author,
//     required this.time,
//     required this.audioUrl,
//   }) : super(key: key);

//   @override
//   _AudioHistoryItemState createState() => _AudioHistoryItemState();
// }

// class _AudioHistoryItemState extends State<AudioHistoryItem> {
//   bool isExpanded = false;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               isExpanded = !isExpanded;
//             });
//           },
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.title,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF3A7A72),
//                     ),
//                   ),
//                   Text(
//                     "By ${widget.author}",
//                     style: const TextStyle(
//                       fontSize: 10,
//                       color: Color(0xFF3A7A72),
//                     ),
//                   ),
//                 ],
//               ),
//               AnimatedRotation(
//                 turns: isExpanded ? 0.5 : 0,
//                 duration: const Duration(milliseconds: 300),
//                 child: const Icon(
//                   Icons.keyboard_arrow_down,
//                   color: Color(0xFF3A7A72),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         if (isExpanded)
//           Column(
//             children: [
//               const SizedBox(height: 12),
//               AudioPlayerWidget(audioUrl: widget.audioUrl),
//             ],
//           )
//         else
//           Align(
//             alignment: Alignment.centerRight,
//             child: Text(
//               _formatTime(widget.time),
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.bold,
//                 fontSize: 11,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   String _formatTime(DateTime time) {
//     final difference = DateTime.now().difference(time);
//     if (difference.inDays > 0) return "${difference.inDays}d ago";
//     if (difference.inHours > 0) return "${difference.inHours}h ago";
//     return "${difference.inMinutes}m ago";
//   }
// }
