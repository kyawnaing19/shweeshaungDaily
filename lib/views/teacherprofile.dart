import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/views/Home.dart';
import 'package:shweeshaungdaily/utils/route_transition.dart';

final Map<String, String> audienceValueMap = {
  'Public': 'Public',
  'Sem 1': '1',
  'Sem 2': '2',
  'Sem 3': '3',
  'Sem 4': '4',
  'Sem 5': '5',
  'Sem 6': '6',
  'Sem 7': '7',
  'Sem 8': '8',
};

class TeacherProfilePage extends StatefulWidget {
  final VoidCallback? onBack;

  const TeacherProfilePage({super.key, this.onBack});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  int _currentPage = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kAccentColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!(); // ✅ Access via `widget`
            }
          },
        ),
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    final RenderBox overlay =
                        Overlay.of(context).context.findRenderObject()
                            as RenderBox;
                    final Offset topRight = overlay.localToGlobal(
                      Offset(overlay.size.width, 0),
                    );
                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        topRight.dx - 200, // 200 = width of SettingsCard
                        topRight.dy + kToolbarHeight + 8, // below appbar
                        10, // right margin
                        0,
                      ),
                      items: [
                        PopupMenuItem(
                          enabled: false,
                          padding: EdgeInsets.zero,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 250),
                            child: SettingsCard(),
                          ),
                        ),
                      ],
                      elevation: 8,
                      color: Colors.transparent,
                    );
                  },
                ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10),
            // Profile Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPrimaryDarkColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
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
                      size: 30,
                      color: kPrimaryDarkColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Daw Aye Myat Kyi',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text('( FCT )', style: TextStyle(color: Colors.white)),
                      Text('Professor', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Tabs: Shares & Stories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                    child: Text(
                      'Shares',
                      style: TextStyle(
                        fontSize: 18,
                        color: kPrimaryDarkColor.withOpacity(
                          _currentPage == 0 ? 1.0 : 0.5,
                        ),
                        fontWeight: FontWeight.w800,
                        decoration:
                            _currentPage == 0
                                ? TextDecoration.underline
                                : TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                    child: Text(
                      'Stories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kPrimaryDarkColor.withOpacity(
                          _currentPage == 1 ? 1.0 : 0.5,
                        ),
                        decoration:
                            _currentPage == 1
                                ? TextDecoration.underline
                                : TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Swipeable Shares & Stories
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // Shares Widget
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: kPrimaryDarkColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: kAccentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "What's on your mind?",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => const UploadSharesDialog(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        // Additional content like shared posts could go here
                      ],
                    ),
                  ),
                  // Stories Widget
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      itemCount: 9,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                builder: (context) => const UploadStoryDialog(),
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
                          return SizedBox(
                            width: 100,
                            height: 120,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF48C4BC),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Stack(
                                children: const [
                                  Positioned(
                                    bottom: 4,
                                    left: 4,
                                    child: Icon(
                                      Icons.play_arrow,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    left: 20,
                                    child: Text(
                                      '1:30',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // bottomNavigationBar: CustomBottomNavBar(
      //   selectedIndex: _selectedIndex,
      //   onItemTapped: _onItemTapped,
      // ),
    );
  }
}

//upload share widget

class UploadSharesDialog extends StatefulWidget {
  const UploadSharesDialog({super.key});

  @override
  State<UploadSharesDialog> createState() => _UploadSharesDialogState();
}

class _UploadSharesDialogState extends State<UploadSharesDialog> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedAudience = 'Public';
  XFile? _selectedImage;
  bool _isUploading = false;

  Color get _textColor =>
      _controller.text.isNotEmpty ? Colors.white : Colors.white;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _uploadPost() async {
    setState(() {
      _isUploading = true;
    });
    final backendAudience = audienceValueMap[_selectedAudience] ?? 'Public';
    try {
      await ApiService.uploadFeed(
        text: _controller.text,
        audience: backendAudience,
        photo: _selectedImage != null ? File(_selectedImage!.path) : null,
        // Add token or other params if needed
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your story has been uploaded!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxDialogHeight = MediaQuery.of(context).size.height * 0.8;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: BoxConstraints(maxHeight: maxDialogHeight),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tell Us a Tale!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF317575),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Even if it’s about a potato who saved the world :)',
                          style: TextStyle(color: Color(0xFF317575)),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final selected = await showDialog<String>(
                        context: context,
                        builder: (context) => const ShowSharesDialog(),
                      );
                      if (selected != null) {
                        setState(() {
                          _selectedAudience = selected;
                        });
                      }
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder:
                          (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                      child:
                          _selectedAudience == 'Public'
                              ? const CircleAvatar(
                                key: ValueKey('icon'),
                                radius: 23,
                                backgroundColor: Color(0xFF48C4BC),
                                child: Icon(
                                  Icons.public,
                                  size: 25,
                                  color: Colors.white,
                                ),
                              )
                              : Container(
                                key: ValueKey(_selectedAudience),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF48C4BC),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _selectedAudience,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // TextArea with dynamic height and scrollbar
              ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(Color(0xFF317575)),
                  trackColor: WidgetStateProperty.all(Color(0xFFD4F7F5)),
                  thickness: WidgetStateProperty.all(6),
                  radius: Radius.circular(15),
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 50,
                      maxHeight: 180,
                    ),
                    child: TextField(
                      controller: _controller,
                      scrollController: _scrollController,
                      minLines: 1,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        color: _textColor,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "Add a caption ....",
                        hintStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF48C4BC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Image preview with remove button
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_selectedImage!.path),
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
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

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Select photo
                  GestureDetector(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        setState(() {
                          _selectedImage = image;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Selected image: ${image.name}'),
                          ),
                        );
                      }
                    },
                    child: const CircleAvatar(
                      radius: 23,
                      backgroundColor: Color(0xFF48C4BC),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Cancel button
                  // OutlinedButton(
                  //   onPressed: () => Navigator.pop(context),
                  //   style: OutlinedButton.styleFrom(
                  //     backgroundColor: Color(0xFFD4F7F5),
                  //     side: const BorderSide(color: Colors.teal),
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 20,
                  //       vertical: 10,
                  //     ),
                  //   ),
                  //   child: const Text(
                  //     "Cancel",
                  //     style: TextStyle(color: Color(0xFF317575)),
                  //   ),
                  // ),

                  // Upload button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF317575),
                    ),
                    onPressed:
                        _isUploading
                            ? null
                            : () async {
                              await _uploadPost();
                            },
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
                              "Share",
                              style: TextStyle(color: Colors.white),
                            ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShowSharesDialog extends StatelessWidget {
  const ShowSharesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        width: MediaQuery.of(context).size.width * 0.3,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Audience',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF317575),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 230, // Customize this height as needed
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(
                    Color(0xFF317575),
                  ), // Your custom color
                  trackColor: WidgetStateProperty.all(Color(0xFFD4F7F5)),
                  thickness: WidgetStateProperty.all(6),
                  radius: Radius.circular(10),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  interactive: true,
                  child: ListView(
                    shrinkWrap: true,
                    children:
                        audienceValueMap.keys
                            .map(
                              (status) => ListTile(
                                title: Text(
                                  status,
                                  style: const TextStyle(
                                    color: Color(0xFF317575),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context, status);
                                },
                              ),
                            )
                            .toList(),
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

//upload story widget

class UploadStoryDialog extends StatefulWidget {
  const UploadStoryDialog({super.key});

  @override
  State<UploadStoryDialog> createState() => _UploadStoryDialogState();
}

class _UploadStoryDialogState extends State<UploadStoryDialog> {
  final TextEditingController _captionController = TextEditingController();
  XFile? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _uploadStory() async {
    setState(() {
      _isUploading = true;
    });

    // TODO: Replace this with your backend upload logic
    // Example: await ApiService.uploadStory(photo: File(_selectedImage!.path), caption: _captionController.text);

    await Future.delayed(const Duration(seconds: 1)); // Simulate upload

    if (mounted) {
      Navigator.pop(context); // Temporary: just close the modal
      // Optionally show a snackbar or other feedback here
    }
    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder:
          (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const Text(
                    "Upload Story",
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
                                  child: Image.file(
                                    File(_selectedImage!.path),
                                    width: mediaQuery.size.width * 0.7,
                                    height: 180,
                                    fit: BoxFit.cover,
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              _isUploading
                                  ? null
                                  : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: kBackgroundColor,
                            foregroundColor: kPrimaryDarkColor,
                            side: const BorderSide(color: Color(0xFF317575)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              (_selectedImage != null && !_isUploading)
                                  ? _uploadStory
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryDarkColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                                    style: TextStyle(color: Colors.white),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _SettingsItem(
            icon: Icons.headset_mic_outlined,
            text: 'Customer Support',
          ),
          SizedBox(height: 12),
          _SettingsItem(
            icon: Icons.power_settings_new_rounded,
            text: 'Log out',
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SettingsItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFF317575),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF317575),
              fontWeight: FontWeight.w600,
            ),
            // overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
