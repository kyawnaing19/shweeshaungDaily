import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math'; // For simulating random success/failure
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:shweeshaungdaily/colors.dart';

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController =
      TextEditingController(text: 'Pyae Phyo Aung');
  final TextEditingController _nicknameController =
      TextEditingController(text: 'Kyote Gyi');
  final TextEditingController _emailController =
      TextEditingController(text: 'pyaephyoedung@ucstt.edu.mm');
  final TextEditingController _semesterController =
      TextEditingController(text: 'VIII');
  final TextEditingController _classController =
      TextEditingController(text: 'Fourth Year (Senior)');
  final TextEditingController _majorController =
      TextEditingController(text: 'Computer Science (CS)');
  final TextEditingController _bioController =
      TextEditingController(text: 'I like playing efootball mobile game');

  bool _isSaving = false;

  Uint8List? _webImage;
  io.File? _profileImage;

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _semesterController.dispose();
    _classController.dispose();
    _majorController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
            _profileImage = null; // Clear mobile file if switching
          });
        } else {
          setState(() {
            _profileImage = io.File(pickedFile.path);
            _webImage = null; // Clear web file if switching
          });
        }
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No image selected.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor, // Manual color
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),
        ],
        backgroundColor: Colors.transparent, // Manual color
        foregroundColor: kAccentColor, // Manual color
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildFormSection(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (_profileImage != null || _webImage != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullscreenImageViewer(
                        tag: 'profile-image',
                        image: _webImage ?? _profileImage,
                        onDelete: () {
                          setState(() {
                            _webImage = null;
                            _profileImage = null;
                          });
                        },
                      ),
                    ),
                  );
                }
              },
              child: Hero(
                tag: 'profile-image',
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: (_profileImage != null || _webImage != null)
                        ? Border.all(color: Colors.green, width: 4)
                        : null,
                    gradient: (_profileImage == null && _webImage == null)
                        ? const LinearGradient(
                            // Manual color
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              kPrimaryColor, // Manual color
                              kPrimaryDarkColor, // Manual color
                            ],
                          )
                        : null,
                  ),
                  child: ClipOval(
                    child: _webImage != null
                        ? Image.memory(
                            _webImage!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          )
                        : _profileImage != null
                            ? Image.file(
                                _profileImage!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kAccentColor, // Manual color
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 20,
                    color: kPrimaryColor, // Manual color
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _nameController.text,
          style: const TextStyle(
            // Manual TextStyle
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kPrimaryDarkColor, // Manual color
          ),
        ),
        Text(
          _emailController.text,
          style: const TextStyle(
            // Manual TextStyle
            fontSize: 14,
            color: kGrey, // Manual color
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField('Full Name', _nameController, Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField('Nickname', _nicknameController,
              Icons.face_retouching_natural_outlined),
          const SizedBox(height: 16),
          _buildTextField('Email', _emailController, Icons.email_outlined,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _buildTextField(
              'Semester', _semesterController, Icons.school_outlined),
          const SizedBox(height: 16),
          _buildTextField('Class', _classController, Icons.class_outlined),
          const SizedBox(height: 16),
          _buildTextField('Major', _majorController, Icons.work_outline),
          const SizedBox(height: 16),
          _buildTextField('Bio', _bioController, Icons.info_outline,
              maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(icon, color: kPrimaryColor), // Manual color
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true, // Manual
        fillColor: Colors.white, // Manual
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Manual
        border: OutlineInputBorder(
          // Manual
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          // Manual
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          // Manual
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: kPrimaryColor, width: 2),
        ),
        labelStyle: const TextStyle(
          // Manual
          color: kGrey,
          fontSize: 14,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (label == 'Email' &&
            !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.edu\.mm$')
                .hasMatch(value)) {
          return 'Please enter a valid .edu.mm email';
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isSaving = true);

                      await Future.delayed(const Duration(seconds: 2));

                      setState(() => _isSaving = false);

                      final bool success = Random().nextBool();

                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Profile updated successfully!'
                              : 'Failed to update profile'),
                          backgroundColor: success
                              ? Colors.green
                              : kErrorColor, // Manual color
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor, // Manual color
              foregroundColor:
                  kWhite, // Manual color
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0, // Manual
              shadowColor: Colors.transparent, // Manual
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: kWhite,
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class FullscreenImageViewer extends StatelessWidget {
  final String tag;
  final dynamic image; // File or Uint8List
  final VoidCallback onDelete; // 👈 Add this

  const FullscreenImageViewer({
    super.key,
    required this.tag,
    required this.image,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              onDelete(); // 👈 Call the delete callback
              Navigator.pop(context); // Go back
            },
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: tag,
            child: image is Uint8List
                ? Image.memory(image as Uint8List)
                : Image.file(image as io.File),
          ),
        ),
      ),
    );
  }
}
