import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/utils/image_cache.dart';
import 'package:shweeshaungdaily/views/user_profile_update.dart';
import '../services/api_service.dart';
import 'package:shweeshaungdaily/services/authorize_image.dart';

// List of story privacy/status options for backend integration
final List<String> storyStatusOptions = [
  'Public',
  'Sem 1',
  'Sem 2',
  'Sem 3',
  'Sem 4',
  'Sem 5',
  'Sem 6',
  'Sem 7',
  'Sem 8',
];

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onGoToProfileTab; // 👈 Add this

  const ProfileScreen({
    super.key,
    this.onBack,
    this.onGoToProfileTab, // 👈 Add this
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String baseUrl = ApiService.base;

  Map<String, dynamic>? _profile;
  bool _loading = true;
  List<dynamic> _stories = [];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _fetchStories();
  }

  Future<List<Map<String, dynamic>>> loadStoryItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cached_story');

    if (jsonString == null) return [];

    try {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error decoding feed items: $e');
      return [];
    }
  }

  Future<void> _fetchProfile() async {
    final profile = await ApiService.getProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _loading = false;
      });
    }
  }

  Future<void> _fetchStories() async {
    try {
      final result = await ApiService.getStory();

      // Save to local cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_story', jsonEncode(result));

      // Extract valid URLs and convert to full URL
      final imageUrls =
          result
              .map((item) => item['url'] as String?)
              .where((url) => url != null && url.isNotEmpty)
              .map((url) => '$baseUrl/$url')
              .toSet();

      // Clean up unused cached images
      await ImageCacheManager.clearUnusedStoryImages(imageUrls);

      if (mounted) {
        setState(() {
          _stories = result;
        });
      }
    } catch (e) {
      // On failure, load from local cache
      final cached = await loadStoryItems();

      if (mounted) {
        setState(() {
          _stories = cached;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4F7F5),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Profile Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF317575),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF317575),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child:
                        _loading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _profile?['userName'] ?? 'No Name',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  _profile?['nickName'] != null
                                      ? '(${_profile?['nickName']})'
                                      : '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _profile?['bio'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Album',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                  color: Color(0xFF317575),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                itemCount: _stories.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 0.63,
                ),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder:
                              (context) => UploadStoryDialog(
                                onUploadSuccess: () async {
                                  await _fetchStories(); // ✅ Refresh stories

                                  if (widget.onGoToProfileTab != null) {
                                    widget
                                        .onGoToProfileTab!(); // ✅ Jump to ProfileRouterPage
                                  }
                                },
                              ),
                        );
                      },

                      child: SizedBox(
                        width: 100,
                        height: 120,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFC9D4D4),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 30,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    final story = _stories[index - 1];
                    final String imageUrl =
                        story['url'] != null
                            ? (story['url'].startsWith('http')
                                ? story['url']
                                : '$baseUrl/${story['url']}')
                            : '';
                    print(imageUrl);
                    return SizedBox(
                      width: 100,
                      height: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF48C4BC),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child:
                            imageUrl.isNotEmpty
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: AuthorizedImage(
                                    imageUrl: imageUrl,
                                    height: double.infinity,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : const Center(child: Icon(Icons.broken_image)),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: CustomBottomNavBar(
      //   selectedIndex: _selectedIndex,
      //   onItemTapped: _onItemTapped,
      // ),
    );
  }
}

class UploadStoryDialog extends StatefulWidget {
  final VoidCallback? onUploadSuccess;
  const UploadStoryDialog({super.key, this.onUploadSuccess});

  @override
  State<UploadStoryDialog> createState() => _UploadStoryDialogState();
}

class _UploadStoryDialogState extends State<UploadStoryDialog> {
  final TextEditingController _captionController = TextEditingController();
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = image;
        _selectedImageBytes = bytes;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _selectedImageBytes = null;
    });
  }

  Future<void> _uploadStory() async {
    debugPrint('Upload button pressed');

    setState(() {
      _isUploading = true;
    });

    try {
      await ApiService.uploadStory(
        caption: _captionController.text,
        photo: _selectedImage,
      );

      if (!mounted) return;

      widget.onUploadSuccess?.call(); // ✅ Call parent callback
      Navigator.pop(context); // ✅ Close dialog
    } catch (e) {
      // handle errors if needed
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;
    return DraggableScrollableSheet(
      initialChildSize: isKeyboardVisible ? 0.80 : 0.55,
      minChildSize: isKeyboardVisible ? 0.6 : 0.4,
      maxChildSize: isKeyboardVisible ? 0.85 : 0.85,
      expand: false,
      builder:
          (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Padding(
              padding:
                  isKeyboardVisible
                      ? const EdgeInsets.only(bottom: 8)
                      : MediaQuery.of(context).viewInsets,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed:
                              (_selectedImage != null && !_isUploading)
                                  ? _uploadStory
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryDarkColor,
                            padding: const EdgeInsets.symmetric(
                              vertical: 11,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                14,
                              ), // Change 16 to your desired radius
                            ),
                          ),
                          child:
                              _isUploading
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    "Upload",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ],
                    ),

                    const Text(
                      "Create Album",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: kPrimaryDarkColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickImage,
                      child:
                          _selectedImage == null
                              ? Container(
                                width: mediaQuery.size.width * 0.7,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: kBackgroundColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: kPrimaryDarkColor,
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color: kPrimaryDarkColor,
                                  ),
                                ),
                              )
                              : Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child:
                                        _selectedImageBytes != null
                                            ? Image.memory(
                                              _selectedImageBytes!,
                                              width:
                                                  mediaQuery.size.width * 0.7,
                                              height: 180,
                                              fit: BoxFit.cover,
                                            )
                                            : Container(
                                              width:
                                                  mediaQuery.size.width * 0.7,
                                              height: 180,
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: _removeImage,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _captionController,
                      minLines: 1,
                      maxLines: 5,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "Add a caption...",
                        filled: true,
                        fillColor: kAccentColor,
                        hintStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: OutlinedButton(
                    //         onPressed:
                    //             _isUploading
                    //                 ? null
                    //                 : () => Navigator.pop(context),
                    //         style: OutlinedButton.styleFrom(
                    //           backgroundColor: kBackgroundColor,
                    //           foregroundColor: kPrimaryDarkColor,
                    //           side: const BorderSide(color: Color(0xFF317575)),
                    //           padding: const EdgeInsets.symmetric(vertical: 14),
                    //         ),
                    //         child: const Text("Cancel"),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 16),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
