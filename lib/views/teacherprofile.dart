import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/views/Home.dart';
import 'package:shweeshaungdaily/views/bottomNavBar.dart';
import 'package:shweeshaungdaily/utils/route_transition.dart';
import 'package:shweeshaungdaily/views/timetablepage.dart';
import 'package:dotted_border/dotted_border.dart';

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

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({super.key});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  int _selectedIndex = 3; // State for the selected tab in the bottom navigation

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    if (index == 0) {
      Navigator.of(context).pushReplacement(fadeRoute(const HomePage()));
    }
    if (index == 1) {
      Navigator.of(context).pushReplacement(fadeRoute(const TimeTablePage()));
    }
    if (index == 2) {
      Navigator.of(context).pushReplacement(fadeRoute(const HomePage()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(fadeRoute(const HomePage()));
          },
          color: Colors.white,
          tooltip: 'Back',
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
            // ...existing code...
            const SizedBox(height: 16),

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

            const SizedBox(height: 20),

            // Tabs: Shares & Stories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Text(
                    'Shares',
                    style: TextStyle(
                      fontSize: 18,
                      color: kPrimaryDarkColor,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Stories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kPrimaryDarkColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Input Box
            Expanded(
              child: Container(
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
                          // Replace the Icon with IconButton to show dialog
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => const UploadStoryDialog(),
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
            ),
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class UploadStoryDialog extends StatefulWidget {
  const UploadStoryDialog({super.key});

  @override
  State<UploadStoryDialog> createState() => _UploadStoryDialogState();
}

class _UploadStoryDialogState extends State<UploadStoryDialog> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
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

    // TODO: Replace this with your backend API call.
    // Example:
    // await uploadPostToBackend(_controller.text, _selectedImage);

    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    setState(() {
      _isUploading = false;
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your story has been uploaded!')),
      );
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
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const ShowStoryDialog(),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 23,
                      backgroundColor: Color(0xFF48C4BC),
                      child: Icon(
                        Icons.lock_person_rounded,
                        size: 25,
                        color: Colors.white,
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
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color(0xFFD4F7F5),
                      side: const BorderSide(color: Colors.teal),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Color(0xFF317575)),
                    ),
                  ),

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
                              "Upload",
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

class ShowStoryDialog extends StatelessWidget {
  const ShowStoryDialog({super.key});

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
                        storyStatusOptions
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
