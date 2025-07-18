import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPassword> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // New state variable for loading state

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Placeholder for the API call
  Future<void> _resetPasswordApiCall(String email) async {
    setState(() {
      _isLoading = true; // Set loading to true when API call starts
    });

    try {
      final bool success = await ApiService.resetPassword(email);

      if (success) {
        print('Password reset email sent successfully to $email');
        _showSnackBar(context, 'Password reset email sent to $email', isError: false);

        // Navigate to another page (e.g., SignInPage) after a short delay for SnackBar visibility
        // No need for an additional Future.delayed here if ApiService.resetPassword already handles its own delay
        if (mounted) { // Check if the widget is still in the tree before navigating
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInPage()), // Navigate to SignInPage
          );
        }
      } else {
        print('Failed to send password reset email for $email');
        _showSnackBar(context, 'Failed to send password reset email. Please try again.', isError: true);
      }
    } catch (e) {
      print('Error during password reset API call: $e');
      _showSnackBar(context, 'An error occurred. Please try again later.', isError: true);
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false when API call finishes (success or error)
      });
    }
  }

  // Custom SnackBar message
  void _showSnackBar(BuildContext context, String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating, // Makes it float above the content
        margin: const EdgeInsets.all(16.0), // Adds margin around the SnackBar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Rounded corners for the SnackBar
        ),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4F7F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 50),
                      const Text(
                        'Forget Password',
                        style: TextStyle(
                          color: Color(0xFF317575),
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Don\'t worry, we\'ll help you get back in.',
                        style: TextStyle(
                          color: Color(0xFF317575),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 60),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF57C5BE),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(color: Colors.white),
                                prefixIcon: Icon(
                                  Icons.mail_outline,
                                  color: Colors.white,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 18.0,
                                  horizontal: 10.0,
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              cursorColor: Colors.white,
                              validator: (value) {
                                return null;
                              },
                              onChanged: (value) {
                                // No action needed here for error display
                              },
                            ),
                          ),
                          const SizedBox(height: 19), // Maintain spacing
                        ],
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null // Disable button when loading
                            : () {
                                String email = _emailController.text.trim();

                                if (email.isEmpty) {
                                  _showSnackBar(context, 'Email cannot be empty.', isError: true);
                                } else if (!email.contains('@ucstt.edu.mm')) {
                                  _showSnackBar(context, 'Email must contain "@ucstt.edu.mm".', isError: true);
                                } else {
                                  print('Validation successful. Attempting to reset password for: $email');
                                  _resetPasswordApiCall(email);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF317575),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(1),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              ) // Show loading indicator
                            : const Text(
                                'Reset Password',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for a simple SignIn Page (assuming login.dart contains SignInPage)
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4F7F5),
      appBar: AppBar(
        title: const Text('Sign In Page'),
        backgroundColor: const Color(0xFF317575),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'You have been redirected to the Sign In Page!',
          style: TextStyle(
            color: Color(0xFF317575),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
