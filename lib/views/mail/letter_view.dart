import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoveLetterScreen extends StatelessWidget {
  const LoveLetterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, size: 24),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.share, size: 24), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Dearest,',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "recipientName",
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
                      "letterContent",
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
                        'Forever yours,',
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
                  decoration: BoxDecoration(
                    color: Colors.pink[600],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    "date",
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              // const SizedBox(height: 40),
              // Center(
              //   child: ElevatedButton.icon(
              //     onPressed: () {},
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.pink[600],
              //       foregroundColor: Colors.white,
              //       elevation: 0,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(24),
              //       ),
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 36,
              //         vertical: 18,
              //       ),
              //       shadowColor: Colors.pink.withOpacity(0.3),
              //     ),
              //     icon: const Icon(Icons.favorite, size: 20),
              //     label: Text(
              //       'Send Heart',
              //       style: GoogleFonts.roboto(
              //         fontSize: 16,
              //         fontWeight: FontWeight.w500,
              //         letterSpacing: 0.5,
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
