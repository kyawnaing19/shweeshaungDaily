import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' as io;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb; // Import Uint8List and kIsWeb

// Assuming these are defined in your project
import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/services/authorize_image.dart'; // Ensure this is correctly implemented
// For fetching authorized network images

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
  bool _isLoading = true;

  // Stores newly picked local image file (for mobile) or bytes (for web)
  dynamic _newlyPickedImage;

  // Stores the initial profile image URL fetched from the API
  String? _initialProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final profileData = await ApiService.getProfile();
      if (profileData != null && profileData.isNotEmpty) {
        _nameController.text = profileData['userName'] ?? '';
        _nicknameController.text = profileData['nickName'] ?? '';
        _emailController.text = profileData['email'] ?? '';
        _semesterController.text = profileData['semester'] ?? '';
        _classController.text = profileData['userClass'] ?? '';
        _majorController.text = profileData['major'] ?? '';
        _bioController.text = profileData['bio'] ?? '';

        // Store the full URL for AuthorizedImage
        _initialProfileImageUrl =
            profileData['profilePictureUrl'] != null
                ? '$baseUrl/${profileData['profilePictureUrl']}'
                : null;

        // Clear any previously picked images when loading new profile data
        _newlyPickedImage = null;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfilePicture() async {
    setState(() {
      _isSaving = true;
    });
    try {
      if (_newlyPickedImage == null) {
        if (mounted) {
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
        }
        return;
      }

      final bool success = await ApiService.updateProfilePicture(
        photo: _newlyPickedImage,
      );

      String message;
      Color snackBarColor;

      if (success) {
        message = 'Profile picture updated successfully! 🎉';
        snackBarColor = Colors.green;
        await _loadProfileData(); // Reload to get the new image URL from API
        if (mounted) {
          // Pop with true after successful picture update
          Navigator.pop(context, true);
        }
      } else {
        message = 'Failed to update profile picture. Please try again. 😔';
        snackBarColor = kErrorColor;
        // Revert local state if upload failed
        setState(() {
          _newlyPickedImage = null;
        });
        await _loadProfileData(); // Revert to previous image or default
      }

      if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
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
      }
      setState(() {
        _newlyPickedImage = null;
      });
      await _loadProfileData();
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
        dynamic imageForViewer;
        if (!kIsWeb) { // Check if not web
          // Mobile: Use File
          imageForViewer = io.File(pickedFile.path);
        } else {
          // Web/Desktop: Use Uint8List
          imageForViewer = await pickedFile.readAsBytes();
        }

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullscreenImageViewer(
                image: imageForViewer,
                imageSourceType: imageForViewer is io.File
                    ? ImageSourceType.file
                    : ImageSourceType.bytes,
                onDelete: () {
                   setState(() {
                     _loadProfileData();
                   });
                  // User chose to delete from viewer, don't update profile
                  // The viewer handles popping itself.
                },
                onConfirm: (confirmedImage) {
                  setState(() {
                    _newlyPickedImage = confirmedImage;
                  });
                  _updateProfilePicture();
                },
              ),
            ),
          );
        }
      } else {
        if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context, true), // Pop with true on back
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
              )
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
                // If there's an initial network image URL, view it using FullscreenImageViewer
                if (_initialProfileImageUrl != null &&
                    _newlyPickedImage == null) {
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullscreenImageViewer(
                          image: _initialProfileImageUrl!,
                          imageSourceType: ImageSourceType.network,
                          imageWidth: MediaQuery.of(context).size.width,
                          imageHeight: MediaQuery.of(context).size.height,
                          onDelete: () {
                            setState(() {
                              _initialProfileImageUrl = null;
                              _newlyPickedImage = null;
                            });
                            // Optionally, call an API to delete the remote image here
                            // ApiService.deleteProfilePicture();
                          },
                          onConfirm: (confirmedImage) {
                            // For an existing network image, "confirm" means just close.
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  }
                }
                // If there's a newly picked local image, view that
                else if (_newlyPickedImage != null) {
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullscreenImageViewer(
                          image: _newlyPickedImage,
                          imageSourceType: _newlyPickedImage is io.File
                              ? ImageSourceType.file
                              : ImageSourceType.bytes,
                          onDelete: () {
                            setState(() {
                              _newlyPickedImage = null;
                            });
                            // No need to call update API here, it's a local discard
                          },
                          onConfirm: (confirmedImage) {
                            // For a newly picked image, "confirm" means just close,
                            // as it's already handled by _pickImage calling _updateProfilePicture
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  }
                }
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: (_newlyPickedImage != null ||
                          _initialProfileImageUrl != null)
                      ? Border.all(color: Colors.white, width: 4)
                      : null,
                  gradient: (_newlyPickedImage == null &&
                          _initialProfileImageUrl == null)
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [kPrimaryColor, kPrimaryDarkColor],
                        )
                      : null,
                ),
                child: ClipOval(
                  child: _newlyPickedImage != null
                      ? (_newlyPickedImage is Uint8List
                          ? Image.memory(
                              _newlyPickedImage as Uint8List,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              _newlyPickedImage as io.File,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ))
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
              : 'Loading Name...',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kPrimaryDarkColor,
          ),
        ),
        Text(
          _emailController.text.isNotEmpty
              ? _emailController.text
              : 'Loading Email...',
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
      enabled: enabled,
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
                      final bool success = await ApiService.updateProfile(
                        _nicknameController.text,
                        _bioController.text,
                      );

                      if (mounted) {
                        setState(() => _isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Profile updated successfully! 🎉'
                                  : 'Failed to update profile 😔',
                            ),
                            backgroundColor:
                                success ? Colors.green : kErrorColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        if (success) {
                          Navigator.pop(context, true); // Pop with true on success
                        }
                      }
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
          onPressed: () => Navigator.pop(context, true), // Pop with true on cancel
          child: const Text(
            'Cancel',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

enum ImageSourceType { network, file, bytes }

/// A widget for displaying an image in fullscreen, supporting network URLs (AuthorizedImage),
/// file paths, or Uint8List data. It also provides delete and confirm actions.
class FullscreenImageViewer extends StatelessWidget {
  final dynamic image; // Can be String (URL), io.File, or Uint8List
  final ImageSourceType imageSourceType; // To differentiate image type
  final double? imageWidth; // Optional width for the image
  final double? imageHeight; // Optional height for the image
  final VoidCallback onDelete;
  final Function(dynamic confirmedImage) onConfirm;

  const FullscreenImageViewer({
    super.key,
    required this.image,
    required this.imageSourceType,
    this.imageWidth,
    this.imageHeight,
    required this.onDelete,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    switch (imageSourceType) {
      case ImageSourceType.network:
        imageWidget = AuthorizedImage(
          imageUrl: image as String,
          width: imageWidth ?? MediaQuery.of(context).size.width,
          height: imageHeight ?? MediaQuery.of(context).size.height,
          fit: BoxFit.contain,
        );
        break;
      case ImageSourceType.file:
        imageWidget = Image.file(
          image as io.File,
          width: imageWidth,
          height: imageHeight,
          fit: BoxFit.contain,
        );
        break;
      case ImageSourceType.bytes:
        imageWidget = Image.memory(
          image as Uint8List,
          width: imageWidth,
          height: imageHeight,
          fit: BoxFit.contain,
        );
        break;
    }

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
          // Confirm Icon - only show if there's an image to confirm (i.e., newly picked local image)
          // For network images, confirmation usually means just closing the viewer.
          if (imageSourceType != ImageSourceType.network)
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              onPressed: () {
                onConfirm(image); // Pass the local image back for confirmation
                Navigator.pop(context); // Close the viewer
              },
            ),
          // Delete Icon
          IconButton(
  icon: const Icon(Icons.delete, color: Colors.white),
  onPressed: () async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile Picture?'),
        content: const Text('Are you sure you want to delete your profile picture? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final check = await ApiService.deleteProfile();
      if (check) {
        onDelete();
        Navigator.pop(context);        // Close delete confirmation/viewer
        Navigator.pop(context, true); // Return to previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete profile picture.'),
            backgroundColor: kErrorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  },
)

        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child: Center(
          child: imageWidget,
        ),
      ),
    );
  }
}