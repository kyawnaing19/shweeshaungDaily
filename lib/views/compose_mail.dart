import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComposeLoveLetterScreen extends StatefulWidget {
  const ComposeLoveLetterScreen({super.key});

  @override
  State<ComposeLoveLetterScreen> createState() =>
      _ComposeLoveLetterScreenState();
}

class _ComposeLoveLetterScreenState extends State<ComposeLoveLetterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartbeatController;
  bool _isAnonymous = true;

  @override
  void initState() {
    super.initState();
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 187, 170),
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.teal,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'New Love Letter',
        style: GoogleFonts.parisienne(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(
            right: 15.0,
          ), // Adjust this value as needed
          child: ScaleTransition(
            scale: Tween(begin: 0.9, end: 1.1).animate(
              CurvedAnimation(
                parent: _heartbeatController,
                curve: Curves.easeInOut,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.pink),
              onPressed: () {
                // Send the love letter
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecipientField(),
          const SizedBox(height: 20),
          _buildSubjectField(),
          const SizedBox(height: 20),
          _buildLetterContent(),
          const SizedBox(height: 16),
          _buildAuthorSelection(),
        ],
      ),
    );
  }

  Widget _buildAuthorSelection() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: SizedBox(
          height: 58,

          // Adjust this value to your preferred height
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.center, // This centers vertically
            children: [
              Text(
                'Choose mode to send: ',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: GoogleFonts.dancingScript().fontFamily,

                  color: Colors.teal[400],
                ),
              ),
              _buildAuthorOption('Anonymous', true),
              SizedBox(width: 12),
              _buildAuthorOption('Myself', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorOption(String text, bool isAnonymousMode) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isAnonymous = isAnonymousMode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              _isAnonymous == isAnonymousMode
                  ? Colors.teal.withOpacity(0.2)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: _isAnonymous == isAnonymousMode ? Colors.teal : Colors.grey,
            fontFamily: GoogleFonts.dancingScript().fontFamily,
          ),
        ),
      ),
    );
  }

  Widget _buildRecipientField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'To: My Beloved',
          hintStyle: TextStyle(
            color: Colors.pinkAccent,
            fontFamily: GoogleFonts.dancingScript().fontFamily,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(Icons.favorite_border, color: Colors.pink[300]),
          suffixIcon: IconButton(
            icon: Icon(Icons.contacts_outlined, color: Colors.teal[300]),
            onPressed: () {},
          ),
        ),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildSubjectField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Subject: My Heart Speaks...',
          hintStyle: TextStyle(
            color: Colors.teal[400],
            fontFamily: GoogleFonts.dancingScript().fontFamily,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(Icons.subject_outlined, color: Colors.teal[300]),
        ),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildLetterContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        maxLines: 15,
        decoration: InputDecoration(
          hintText:
              'My Dearest...\n\nEvery moment without you feels like an eternity...',
          hintStyle: TextStyle(
            color: Colors.teal[400],
            fontFamily: GoogleFonts.dancingScript().fontFamily,
            fontSize: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8),
      ),
    );
  }
}
