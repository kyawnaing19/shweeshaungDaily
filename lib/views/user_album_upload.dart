import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shweeshaungdaily/services/api_service.dart'; // Assuming this service is correctly implemented

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final TextEditingController _captionController = TextEditingController();
  XFile? _selectedMedia;
  bool _isUploading = false;
  String? _errorMessage;

  Future<void> _pickMedia(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    XFile? media;

    try {
      media = await picker.pickImage(source: source);
      if (media != null) {
        setState(() {
          _selectedMedia = media;
          _errorMessage = null;
        });
      }
    } catch (e) {
      debugPrint('Error picking media: $e');
      setState(() {
        _errorMessage = 'Failed to pick media. Please try again.';
      });
    }
  }

  Future<void> _uploadStory() async {
    debugPrint('Upload button pressed');

    if (_selectedMedia == null) {
      setState(() {
        _errorMessage = 'Please select an image or video to upload.';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      // Ensure ApiService.uploadStory can handle XFile or File
      // You might need to convert XFile to File if ApiService expects `File`:
      // photo: File(_selectedMedia!.path),
      await ApiService.uploadStory(
        caption: _captionController.text,
        photo: XFile(
          _selectedMedia!.path,
        ), // Pass the XFile object directly or convert to File
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story uploaded successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // A clean background
      appBar: AppBar(
        title: const Text('New Album', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0, // No shadow for a flat, modern look
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.black87,
        ), // Darker icon for contrast
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Media Selection Area
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Photo Library'),
                            onTap: () {
                              _pickMedia(ImageSource.gallery);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Camera'),
                            onTap: () {
                              _pickMedia(ImageSource.camera);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                height: 250, // Slightly taller for better visual impact
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // subtle shadow
                    ),
                  ],
                ),
                child:
                    _selectedMedia == null
                        ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 60,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Tap to select image or video',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            File(_selectedMedia!.path),
                            fit: BoxFit.cover, // Cover the container
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 30), // Increased spacing
            // Caption Input
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                labelText: 'Add a caption...',
                labelStyle: TextStyle(color: Colors.grey[700]),
                hintText: 'Share your thoughts with this story!',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none, // No border for a cleaner look
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              maxLines: 4, // Allow more lines for longer captions
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 25),

            // Error Message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Upload Button
            Container(
              height: 50, // Fixed height for the button
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00897B),
                    Color(0xFF00695C),
                  ], // Subtle gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00897B).withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent, // Make Material button transparent
                child: InkWell(
                  onTap: _isUploading ? null : _uploadStory,
                  borderRadius: BorderRadius.circular(10),
                  child: Center(
                    child:
                        _isUploading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Upload Story',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
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
