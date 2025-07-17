import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shweeshaungdaily/colors.dart';
import 'dart:async'; // For debounce
import 'dart:convert'; // Import for jsonEncode/jsonDecode (needed for API service)

// Assuming ApiService is structured to have static methods like sendMail and searchUserNames
import 'package:shweeshaungdaily/services/api_service.dart';

// Define the custom color scheme (as previously defined)
const Color primaryDarkColor = Color(0xFF00897B);
const Color backgroundColor = Color(0xFFE0F7FA);
const Color accentColor = Color(0xFF48C4BC);
const Color textColor = Color(0xFF263238); // A dark grey for general text
const Color hintColor = Color(0xFF78909C); // A softer grey for hints

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

  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _contentController =
      TextEditingController(); // Added content controller
  int? _selectedRecipientId; // To store the recipient's ID

  List<String> _suggestedRecipients = [];
  Timer? _debounce;
  bool _ignoreTextChanges = false; // Flag to temporarily ignore changes

  @override
  void initState() {
    super.initState();
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _recipientController.addListener(_onRecipientChanged);
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _recipientController.removeListener(_onRecipientChanged);
    _recipientController.dispose();
    _contentController.dispose(); // Dispose content controller
    _debounce?.cancel();
    super.dispose();
  }

  void _onRecipientChanged() {
    if (_ignoreTextChanges) {
      return;
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _fetchSuggestedRecipients(_recipientController.text);
    });
  }

  void _fetchSuggestedRecipients(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestedRecipients = [];
        _selectedRecipientId = null; // Clear selected ID if text is empty
      });
      return;
    }
    try {
      final List<Map<String, dynamic>> results =
          await ApiService.searchUserNames(query);

      // Extract names. If your API returns IDs, store them too.
      // Assuming your API response for searchUserNames includes 'name' and 'id'
      // Example: [{'id': 1, 'name': 'Alice'}, {'id': 2, 'name': 'Bob'}]
      final List<String> names =
          results
              .map((item) => item['name']?.toString() ?? '')
              .where((name) => name.isNotEmpty)
              .toList();

      setState(() {
        _suggestedRecipients = names;
        // For demonstration, we'll assume the first result's ID is selected
        // In a real app, you'd associate the ID with the selected name more accurately.
        // For now, we are NOT storing the ID when fetching suggestions.
        // The ID will be stored when a suggestion is *tapped*.
      });
    } catch (e) {
      print('Error fetching names: $e');
      setState(() {
        _suggestedRecipients = [];
        _selectedRecipientId = null;
      });
    }
  }

  // New function to handle sending the mail
  void _sendMailAction() async {
    final String letterContent = _contentController.text;
    final String recipientName =
        _recipientController.text; // The text in the recipient field
    final bool anonymous = _isAnonymous;

    // --- IMPORTANT ---

    // You need a way to get the `recipientId` when a user types a name
    // or selects from suggestions. Currently, `_selectedRecipientId`
    // is set only when a suggestion is tapped. If the user types a full name
    // without selecting a suggestion, _selectedRecipientId might be null.
    //
    // For this example, we'll only send if _selectedRecipientId is not null.
    // In a real app, you might need to:
    // 1. Fetch recipient ID based on the typed name before sending.
    // 2. Only allow sending if a valid recipient (with an ID) is selected/typed.
    if (_selectedRecipientId == null || recipientName.isEmpty) {
      _showSnackBar(
        'Please select a recipient from the suggestions or ensure a valid recipient is entered.',
        Colors.red,
      );
      return;
    }

    if (letterContent.trim().isEmpty) {
      _showSnackBar('Message content cannot be empty.', Colors.red);
      return;
    }

    // Show a loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text('Sending mail...', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: primaryDarkColor,
        duration: Duration(days: 1), // Indefinite duration
      ),
    );

    final String? errorMessage = await ApiService.sendMail(
      text: letterContent,
      anonymous: anonymous,
      recipientId: _selectedRecipientId!, // Use the stored ID
    );

    // Hide the loading indicator
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (errorMessage == null) {
      _showSnackBar('Mail sent successfully! ❤️', primaryDarkColor);
      // Optionally clear fields after success
      _recipientController.clear();
      _contentController.clear();
      setState(() {
        _suggestedRecipients = [];
        _selectedRecipientId = null;
        _isAnonymous = true; // Reset to default
      });
    } else {
      _showSnackBar('Failed to send mail: $errorMessage', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: primaryDarkColor,
        scaffoldBackgroundColor: kBackgroundColor,
        appBarTheme: const AppBarTheme(
          color: kAccentColor,
          elevation: 4,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 14.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: primaryDarkColor, width: 2.0),
          ),
          hintStyle: GoogleFonts.lato(
            color: hintColor,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.lato(color: textColor, fontSize: 16),
          bodyMedium: GoogleFonts.lato(color: textColor, fontSize: 14),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: accentColor),
      ),
      child: Scaffold(appBar: _buildAppBar(context), body: _buildBody()),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'New Message',
        style: GoogleFonts.lato(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: ScaleTransition(
            scale: Tween(begin: 0.9, end: 1.1).animate(
              CurvedAnimation(
                parent: _heartbeatController,
                curve: Curves.easeInOut,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendMailAction, // CALL THE NEW ACTION FUNCTION HERE
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
          if (_suggestedRecipients.isNotEmpty) _buildRecipientSuggestions(),
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
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Send as: ',
              style: GoogleFonts.lato(
                fontSize: 15,
                color: primaryDarkColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAuthorOption('Anonymous', true),
            const SizedBox(width: 12),
            _buildAuthorOption('Myself', false),
          ],
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color:
              _isAnonymous == isAnonymousMode
                  ? accentColor.withOpacity(0.2)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color:
                _isAnonymous == isAnonymousMode
                    ? accentColor
                    : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.lato(
            color:
                _isAnonymous == isAnonymousMode ? primaryDarkColor : textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _recipientController,
        decoration: InputDecoration(
          hintText: 'To:',
          prefixIcon: Icon(
            Icons.person_outline,
            color: primaryDarkColor.withOpacity(0.7),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.contacts_outlined,
              color: primaryDarkColor.withOpacity(0.7),
            ),
            onPressed: () {
              // Potentially open contacts picker
            },
          ),
        ),
        style: GoogleFonts.lato(color: textColor, fontSize: 16),
      ),
    );
  }

  Widget _buildRecipientSuggestions() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: _suggestedRecipients.length,
          itemBuilder: (context, index) {
            final name = _suggestedRecipients[index];
            // You'll need to retrieve the actual ID from your API results here
            // This example assumes searchUserNames returns results like [{'name': 'Alice', 'id': 1}]
            // For now, we'll just use a placeholder ID or assume it's part of `name` if not separate.
            // THIS IS A CRITICAL PART TO VERIFY WITH YOUR ACTUAL API RESPONSE.
            // Example:
            // final int recipientId = (ApiService.lastSearchResults[index]['id'] as int);
            // Assuming ApiService.searchUserNames caches results or you pass it here.
            // For a robust solution, you'd want to store both name and ID in _suggestedRecipients.

            return Column(
              children: [
                ListTile(
                  title: Text(
                    name,
                    style: GoogleFonts.lato(color: textColor, fontSize: 16),
                  ),
                  onTap: () async {
                    // Find the corresponding ID from the original API results
                    final List<Map<String, dynamic>> allResults =
                        await ApiService.searchUserNames(
                          _recipientController.text,
                        ); // Re-fetch or cache results
                    final Map<String, dynamic>? selectedUser = allResults
                        .firstWhere(
                          (item) => item['name'] == name,
                          orElse: () => {}, // Provide an empty map if not found
                        );

                    _ignoreTextChanges = true;
                    _recipientController.text = name;
                    setState(() {
                      _suggestedRecipients = []; // Clear suggestions
                      // Set the recipient ID here
                      _selectedRecipientId =
                          selectedUser?['id'] as int?; // Cast to int?
                    });
                    Future.delayed(const Duration(milliseconds: 50), () {
                      _ignoreTextChanges = false;
                    });
                  },
                ),
                if (index < _suggestedRecipients.length - 1)
                  Divider(
                    height: 1,
                    color: Colors.grey[200],
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          },
        ),
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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _contentController, // Assign controller
        maxLines: 15,
        decoration: InputDecoration(
          hintText: 'Compose your message...',
          contentPadding: const EdgeInsets.all(16),
        ),
        style: GoogleFonts.lato(color: textColor, fontSize: 16, height: 1.5),
      ),
    );
  }
}
