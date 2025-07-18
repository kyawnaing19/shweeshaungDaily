import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
// Import for network image fetching
import 'package:path_provider/path_provider.dart'; // Import for temporary file on mobile

// Assuming these are defined in your project
import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/services/authorize_image.dart';
import 'package:shweeshaungdaily/services/authorized_http_service.dart';

// Dummy AuthorizedImage for demonstration. Replace with your actual one.
// This widget is assumed to handle its own network loading and token.


class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final userbaseUrl = ApiService.userbaseUrl;
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

  Uint8List? _webImage; // Holds image data for web (newly picked)
  io.File? _profileImage; // Holds image file for mobile (newly picked)

  // Stores the initial profile image URL fetched from the API
  String? _initialProfileImageUrl;

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
      final profileData =
          await ApiService.getProfile(); // Fetching data from your API service

      if (profileData != null && profileData.isNotEmpty) {
        // Populate controllers with fetched data
        _nameController.text = profileData['userName'] ?? '';
        _nicknameController.text = profileData['nickName'] ?? '';
        _emailController.text = profileData['email'] ?? '';
        _semesterController.text = profileData['semester'] ?? '';
        _classController.text = profileData['userClass'] ?? '';
        _majorController.text = profileData['major'] ?? '';
        _bioController.text = profileData['bio'] ?? '';
        _initialProfileImageUrl = profileData['profilePictureUrl'];

        // Only store the URL, do not fetch bytes here
        _initialProfileImageUrl = profileData['profilePictureUrl'] != null
            ? '$baseUrl/${profileData['profilePictureUrl']}'
            : null;

        // Clear any previously picked images when loading new profile data
        _webImage = null;
        _profileImage = null;
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

  Future<void> _updateProfilePicture() async {
    setState(() {
      _isSaving = true; // Show loading indicator
    });

    try {
      // Determine which image type to send based on platform
      dynamic imageToSend;
      if (kIsWeb) {
        imageToSend = _webImage;
      } else {
        imageToSend = _profileImage;
      }

      // Ensure there's an image to send
      if (imageToSend == null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No image selected to update.'),
            backgroundColor: kErrorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return; // Exit if no image
      }

      // Call your API function with the appropriate image data
      final bool success = await ApiService.updateProfilePicture(photo: imageToSend);

      String message;
      Color snackBarColor;

      if (success) {
        message = 'Profile picture updated successfully! 🎉';
        snackBarColor = Colors.green;
        // If successful, the image is already in _webImage or _profileImage
        // and will be displayed.
        // Also, update the _initialProfileImageUrl to reflect the new image
        // (you might need to get the new URL from the API response here)
        // For simplicity, we'll just reload the profile data to get the new URL.
        await _loadProfileData();
      } else {
        message = 'Failed to update profile picture. Please try again. 😔';
        snackBarColor = kErrorColor;

        // IMPORTANT: If update failed, revert the local image state
        // to prevent showing a broken image or an un-uploaded image.
        setState(() {
          _webImage = null;
          _profileImage = null;
        });
        // Reload original profile data to revert to the old image or default
        await _loadProfileData();
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: snackBarColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      // Handle any exceptions during the API call
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()} ⚠️'),
          backgroundColor: kErrorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      // Also revert image on error
      setState(() {
        _webImage = null;
        _profileImage = null;
      });
      await _loadProfileData(); // Reload original profile data
    } finally {
      setState(() {
        _isSaving = false; // Hide loading indicator regardless of success/failure
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
        // Determine the image type (web or mobile) and pass it to the viewer
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullscreenImageViewer(
                tag: 'temp-profile-image', // Use a temporary tag for the new image
                image: bytes,
                onDelete: () {
                  // If user deletes from viewer, do nothing here as image wasn't set yet
                  // The viewer handles popping itself.
                },
                onConfirm: (confirmedImage) {
                  // This callback is triggered when "Confirm" is pressed in the viewer
                  setState(() {
                    _webImage = confirmedImage as Uint8List;
                    _profileImage = null; // Clear mobile file if switching
                  });
                  _updateProfilePicture(); // Call the update function
                },
              ),
            ),
          );
        } else {
          final file = io.File(pickedFile.path);
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullscreenImageViewer(
                tag: 'temp-profile-image', // Use a temporary tag for the new image
                image: file,
                onDelete: () {
                  // If user deletes from viewer, do nothing here as image wasn't set yet
                  // The viewer handles popping itself.
                },
                onConfirm: (confirmedImage) {
                  // This callback is triggered when "Confirm" is pressed in the viewer
                  setState(() {
                    _profileImage = confirmedImage as io.File;
                    _webImage = null; // Clear web file if switching
                  });
                  _updateProfilePicture(); // Call the update function
                },
              ),
            ),
          );
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
                child: CircularProgressIndicator(color: kPrimaryColor),
              ) // Show loading indicator
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
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
              onTap: () async {
                // Show loading indicator while fetching network image for full view
                if (_initialProfileImageUrl != null && _webImage == null && _profileImage == null) {
                  // If AuthorizedImage is currently displayed, fetch its bytes on tap
                  // ignore: use_build_context_synchronously
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    ),
                  );
                  try {
                    final response = await AuthorizedHttpService.sendAuthorizedRequest(Uri.parse('https://shweeshaung.mooo.com/$_initialProfileImageUrl'), method: 'GET');
                    // http.get(Uri.parse(_initialProfileImageUrl!), headers: {
                    //   // Add any necessary authorization headers here, if your API requires them
                    //   // 'Authorization': 'Bearer YOUR_AUTH_TOKEN', // Example
                    // });

                    // ignore: use_build_context_synchronously
                    Navigator.pop(context); // Dismiss loading dialog

                    if (response?.statusCode == 200) {
                      dynamic imageForViewer;
                      if (kIsWeb) {
                        imageForViewer = response?.bodyBytes;
                      } else {
                        final directory = await getTemporaryDirectory();
                        final filePath = '${directory.path}/profile_full_view_temp_image.png';
                        final file = io.File(filePath);
                        await file.writeAsBytes(response!.bodyBytes);
                        imageForViewer = file;
                      }

                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullscreenImageViewer(
                            tag: 'profile-image',
                            image: imageForViewer,
                            onDelete: () {
                              setState(() {
                                _webImage = null;
                                _profileImage = null;
                                _initialProfileImageUrl = null; // Clear network URL too
                              });
                              // You might call an API to delete the remote image here
                              // ApiService.deleteProfilePicture();
                            },
                            onConfirm: (confirmedImage) {
                              // For an already set image, confirm just closes the viewer
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    } else {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to load full image: ${response?.statusCode}'),
                          backgroundColor: kErrorColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context); // Dismiss loading dialog
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error loading full image: $e'),
                        backgroundColor: kErrorColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                } else if (_profileImage != null || _webImage != null) {
                  // If a newly picked image is present, view that directly
                  // ignore: use_build_context_synchronously
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
                            // If you want to remove the image from the backend when deleted from viewer
                            // You might call a specific API function here, e.g., ApiService.deleteProfilePicture();
                          });
                          // No need to call _updateProfilePicture here, as it's a delete action.
                        },
                        onConfirm: (confirmedImage) {
                          // For an already set image, "Confirm" might just close the viewer
                          // or do nothing if the image is already considered confirmed.
                          Navigator.pop(context);
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
                    border:
                        (_profileImage != null || _webImage != null)
                            ? Border.all(color: Colors.white, width: 4)
                            : null,
                    gradient:
                        (_profileImage == null && _webImage == null)
                            ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [kPrimaryColor, kPrimaryDarkColor],
                            )
                            : null,
                  ),
                  child: ClipOval(
                    child:
                        _webImage != null
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
                            : (_initialProfileImageUrl != null && !_isLoading)
                                ? AuthorizedImage(
                                    imageUrl: _initialProfileImageUrl!,
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
          style: const TextStyle(fontSize: 14, color: kGrey),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            'Nickname',
            _nicknameController,
            Icons.face_retouching_natural_outlined,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Semester',
            _semesterController,
            Icons.school_outlined,
            enabled: false,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Class',
            _classController,
            Icons.class_outlined,
            enabled: false,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Major',
            _majorController,
            Icons.work_outline,
            enabled: false,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Bio',
            _bioController,
            Icons.info_outline,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
  }) {
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
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
        labelStyle: const TextStyle(color: kGrey, fontSize: 14),
      ),
      // validator: (value) {
      //   if (value == null || value.isEmpty) {
      //     return 'Please enter $label';
      //   }
      //   if (label == 'Email' &&
      //       !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.edu\.mm$')
      //           .hasMatch(value)) {
      //     return 'Please enter a valid .edu.mm email';
      //   }
      //   return null;
      // },
      enabled: enabled,
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _isSaving
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

                      final bool success = await ApiService.updateProfile(
                        _nicknameController.text,
                        _bioController.text,
                      ); // Replace with actual API response
                        // Simulating API call for update

                        final bool success = await ApiService.updateProfile(
                          _nicknameController.text,
                          _bioController.text,
                        ); // Replace with actual API response

                        setState(() => _isSaving = false);

                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Profile updated successfully!'
                                  : 'Failed to update profile',
                            ),
                            backgroundColor:
                                success ? Colors.green : kErrorColor,
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
            child:
                _isSaving
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
  final Function(dynamic image) onConfirm; // New callback for confirmation

  const FullscreenImageViewer({
    super.key,
    required this.tag,
    required this.image,
    required this.onDelete,
    required this.onConfirm, // Mark as required
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
          // Confirm Icon
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            onPressed: () {
              onConfirm(image); // Call confirm callback with the image
              Navigator.pop(context); // Close the viewer
            },
          ),
          // Delete Icon
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              onDelete();
              Navigator.pop(context); // Close the viewer after delete
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
            child:
                image is Uint8List
                    ? Image.memory(image as Uint8List)
                    : Image.file(image as io.File),
          ),
        ),
      ),
    );
  }
}
