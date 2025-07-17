import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math'; // For simulating random success/failure
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/services/api_service.dart'; // Assuming api_service.dart is here

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final String baseUrl = ApiService.base;

  bool _isSaving = false;
  bool _isLoading = true; // Added for initial data loading

  Uint8List? _webImage;
  io.File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Call this to fetch profile data
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final profileData = await ApiService.getProfile(); // Fetching data from your API service

      if (profileData != null && profileData.isNotEmpty) {
        // Populate controllers with fetched data
        _nameController.text = profileData['userName'] ?? '';
        _nicknameController.text = profileData['nickName'] ?? '';
        _emailController.text = profileData['email'] ?? '';
        _semesterController.text = profileData['semester'] ?? '';
        _classController.text = profileData['userClass'] ?? '';
        _majorController.text = profileData['major'] ?? '';
        _bioController.text = profileData['bio'] ?? '';

         final String profileImageUrl = profileData['profilePictureUrl'] != null
        ? '$baseUrl/${profileData['profilePictureUrl']}'
        : 'assets/images/tpo.jpg';

        // Handle profile image if your API returns a URL or base64 string
        // For simplicity, this example doesn't fetch the image,
        // you'd typically load it from a URL here.
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: kAccentColor,
        foregroundColor: kAccentColor,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                color: kPrimaryColor,
              )) // Show loading indicator
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                        ? Border.all(color: Colors.white, width: 4)
                        : null,
                    gradient: (_profileImage == null && _webImage == null)
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              kPrimaryColor,
                              kPrimaryDarkColor,
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
                    color: kAccentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 20,
                    color: kWhite,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _nameController.text.isNotEmpty
              ? _nameController.text
              : 'Loading Name...', // Display placeholder while loading
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kPrimaryDarkColor,
          ),
        ),
        Text(
          _emailController.text.isNotEmpty
              ? _emailController.text
              : 'Loading Email...', // Display placeholder while loading
          style: const TextStyle(
            fontSize: 14,
            color: kGrey,
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
          _buildTextField('Nickname', _nicknameController,
              Icons.face_retouching_natural_outlined),
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
        prefixIcon: Icon(icon, color: kPrimaryColor),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
        ),
        labelStyle: const TextStyle(
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

                      // Here you would call your API to save the profile data
                      // For example:
                      // final success = await ApiService.updateProfile(
                      //   name: _nameController.text,
                      //   nickname: _nicknameController.text,
                      //   email: _emailController.text,
                      //   // ... other fields
                      // );

                      // Simulating API call for update
                      await Future.delayed(const Duration(seconds: 2));
                      final bool success = Random().nextBool(); // Replace with actual API response

                      setState(() => _isSaving = false);

                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Profile updated successfully!'
                              : 'Failed to update profile'),
                          backgroundColor: success ? Colors.green : kErrorColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: kWhite,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
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
  final VoidCallback onDelete;

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
              onDelete();
              Navigator.pop(context);
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