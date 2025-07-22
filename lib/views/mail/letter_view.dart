import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shweeshaungdaily/colors.dart';

class LoveLetterScreen extends StatelessWidget {
  // 1. Define fields to hold the data
  final Map<String, dynamic> message;
  final bool
  isSent; // To differentiate between inbox and sent messages if needed for display logic

  // 2. Update the constructor to require these fields
  const LoveLetterScreen({
    super.key,
    required this.message,
    required this.isSent,
  });

  @override
  Widget build(BuildContext context) {
    // Extract data from the message map, providing fallback values
    final String recipientName =
        isSent
            ? message['recipientName'] ?? 'Recipient'
            : message['sender'] ?? 'Sender';
    final String letterContent =
        message['text'] ??
        'No content available.'; // Assuming 'text' holds the full letter content
    final String privacy =
        message['senderName'] ??
        'Unknown'; // Assuming 'time' is available for date display

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.favorite_border, size: 24),
          //   onPressed: () {
          //     // Implement favorite logic
          //   },
          // ),
          // IconButton(
          //   icon: const Icon(Icons.share, size: 24),
          //   onPressed: () {
          //     // Implement share logic
          //   },
          // ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSent
                    ? 'To My Dearest,'
                    : 'My Dearest,', // Adjust greeting based on sent/received
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                recipientName, // Use the extracted recipient/sender name
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.pink[600],
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.05),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.pink.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      letterContent, // Use the extracted letter content
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 20,
                        height: 1.8,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 36),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        isSent
                            ? 'Sent by $privacy'
                            : 'Forever yours,', // Adjust closing based on sent/received
                        style: GoogleFonts.dancingScript(
                          fontSize: 28,
                          color: Colors.pink[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  // decoration: BoxDecoration(
                  //   color: Colors.pink[600],
                  //   borderRadius: BorderRadius.circular(24),
                  // ),
                  // child: Text(
                  //   privacy, // Use the extracted date
                  //   style: GoogleFonts.roboto(
                  //     fontSize: 14,
                  //     color: Colors.white,
                  //     fontWeight: FontWeight.w500,
                  //     letterSpacing: 0.5,
                  //   ),
                  // ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
