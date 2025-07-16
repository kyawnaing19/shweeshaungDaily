import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/services/authorize_image.dart';
import 'package:shweeshaungdaily/utils/image_cache.dart';
import 'package:shweeshaungdaily/views/user_album_upload.dart';
import 'package:shweeshaungdaily/views/user_profile_update.dart';

// Consider defining constants for common sizes/paddings
const double kHorizontalPadding = 20.0;
const double kVerticalSpacing = 15.0;
const double kCardElevation = 2.0;
const double kCardBorderRadius = 12.0;
const Color kPrimaryColor = Color(0xFF00897B);
const Color kBackgroundColor = Color(0xFFE0F7FA);
const Color kAccentColor = Color(0xFF48C4BC);

class UserProfile extends StatefulWidget {
  final VoidCallback? onBack;

  const UserProfile({super.key, this.onBack});

  @override
  State<UserProfile> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfile> {
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

  Future<void> _fetchProfile() async {
    try {
      final profile = await ApiService.getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _profile = {};
          debugPrint('Error fetching profile: $e'); // Use debugPrint for logs
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> loadStoryItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cached_story');

    if (jsonString == null) return [];

    try {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error decoding feed items: $e');
      return [];
    }
  }

  Future<void> _fetchStories() async {
    try {
      final result = await ApiService.getStory();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_story', jsonEncode(result));

      final imageUrls =
          result
              .map((item) => item['url'] as String?)
              .where((url) => url != null && url.isNotEmpty)
              .map((url) => '$baseUrl/$url')
              .toSet();

      // Ensure ImageCacheManager.clearUnusedStoryImages is implemented to handle network images
      await ImageCacheManager.clearUnusedStoryImages(imageUrls);

      if (mounted) {
        setState(() {
          debugPrint('Stories before update: ${_stories.length}');
          _stories = result; // Or _stories = cached;
          debugPrint(
            'Stories after update: ${_stories.length}, first item: ${_stories.isNotEmpty ? _stories.first : 'N/A'}',
          );
        });
      }
    } catch (e) {
      final cached = await loadStoryItems();
      if (mounted) {
        setState(() {
          _stories = cached;
        });
      }
      debugPrint('Error fetching stories/album items: $e');
    }
  }

  // Callback to handle item deletion from GalleryViewerPage
  void _onDeleteItem(int indexToDelete) {
    if (indexToDelete >= 0 && indexToDelete < _stories.length) {
      setState(() {
        _stories.removeAt(indexToDelete);
      });
      // Optionally, you would also call an API to delete the item from the server
      // and update the cached_story in SharedPreferences.
      // ApiService.deleteStoryItem(_stories[indexToDelete]['id']);
      // _saveStoriesToCache(_stories); // A helper function to re-save
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userName = _profile?['userName'] ?? 'Loading Name...';
    final String userNickname = _profile?['nickName'] ?? 'Loading Nickname...';
    final String userBio =
        (_profile?['bio']?.toString().trim().isNotEmpty ?? false)
            ? _profile!['bio'].toString()
            : 'Add a few words about yourself...';

    final String profileImageUrl =
        _profile?['profile_image'] != null
            ? '$baseUrl/${_profile!['profile_image']}'
            : 'assets/images/tpo.jpg';

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              )
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kHorizontalPadding,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: kHorizontalPadding),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start, // This aligns children to the start horizontally
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => FullscreenImageView(
                                          imageUrl: profileImageUrl,
                                          isAsset: profileImageUrl.startsWith(
                                            'assets/',
                                          ),
                                        ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: 'profileImageHero',
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: kWhite,
                                  child: CircleAvatar(
                                    radius: 56,
                                    backgroundImage:
                                        profileImageUrl.startsWith('assets/')
                                            ? AssetImage(profileImageUrl)
                                                as ImageProvider
                                            : NetworkImage(profileImageUrl),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: kVerticalSpacing),
                            Text(
                              userNickname,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: kPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
  children: [
    Text(
      '@$userName',
      style: const TextStyle(
        fontSize: 16,
        color: kPrimaryColor,
      ),
    ),
    const SizedBox(width: 8),
    GestureDetector(
      onTap: () {
        Navigator.push(  // Fixed: Use Navigator.push directly
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileUpdateScreen(),
          ),
        );
      },
      child: const Icon(
        Icons.edit,
        color: kPrimaryColor,
        size: 30,
      ),
    ),
  ],
),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildInfoCard(userBio),
                      const SizedBox(height: 18),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Album',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: kVerticalSpacing),
                      // Show a message if album is empty and not loading
                      if (_stories.isEmpty && !_loading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Text(
                            'Your album is empty. Add your first photo!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _stories.length + 1,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12.0,
                              mainAxisSpacing: 12.0,
                              childAspectRatio: 0.8,
                            ),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildAddNewCard();
                          } else {
                            return _buildPhotoCard(index - 1, context);
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildInfoCard(String bio) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        elevation: kCardElevation,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardBorderRadius),
        ),
        color: kAccentColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bio',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                bio,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modify the signature of _buildPhotoCard to accept a Key
  Widget _buildPhotoCard(int index, BuildContext context) {
    // Ensure the index is within bounds and the 'url' exists
    if (index >= _stories.length || _stories[index]['url'] == null) {
      return Container(
        key: ValueKey('placeholder_$index'),
      ); // Provide a key for placeholder too
    }

    final Map<String, dynamic> storyItem = _stories[index];
    final String imageUrl = '$baseUrl/${storyItem['url']}';
    final String itemType = storyItem['type'] ?? 'image';

    // Use the unique ID from your story data as the key
    return GestureDetector(
      key: ValueKey(storyItem['id']), // <--- Add this line! Use a unique ID
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => GalleryViewerPage(
                  images:
                      _stories
                          .map(
                            (item) =>
                                item['url'] != null
                                    ? '$baseUrl/${item['url']}'
                                    : '',
                          )
                          .where((url) => url.isNotEmpty)
                          .toList(),
                  initialIndex: index,
                  onDeleteItem: _onDeleteItem,
                ),
            transitionDuration: Duration.zero,
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return child;
            },
          ),
        );
      },
      child: Hero(
        tag:
            'galleryImage_${storyItem['id']}', // <--- Update Hero tag to use ID
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Stack(
            children: [
              AuthorizedImage(
                imageUrl: imageUrl,
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              // ... rest of your stack content
              if (itemType == 'video')
                const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // In _UserProfileViewState class

  Widget _buildAddNewCard() {
    return GestureDetector(
      onTap: () async {
        debugPrint('Add new item tapped!');
        // Navigate to UploadScreen and wait for result
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UploadScreen()),
        );

        // If result is true, it means upload was successful, so refresh stories
        if (result == true) {
          debugPrint('Upload successful, re-fetching stories...');
          await _fetchStories(); // Re-fetch all stories to include the new one
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          color: Colors.grey[300], // Grey background color
          child: const Center(
            child: Icon(
              Icons.add_a_photo, // Add photo icon
              size: 50,
              color: Colors.grey, // Icon color
            ),
          ),
        ),
      ),
    );
  }
}

class FullscreenImageView extends StatefulWidget {
  final String imageUrl;
  final bool isAsset;

  const FullscreenImageView({
    super.key,
    required this.imageUrl,
    this.isAsset = true,
  });

  @override
  State<FullscreenImageView> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageView>
    with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += Offset(0, details.delta.dy);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_offset.dy.abs() > 100) {
      // Check absolute value for both up and down swipe
      Navigator.of(context).pop();
    } else {
      setState(() {
        _offset = Offset.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(
        1 - (_offset.dy.abs() / 300).clamp(0, 1), // Use abs for transparency
      ),
      body: Stack(
        children: [
          GestureDetector(
            onVerticalDragUpdate: _onVerticalDragUpdate,
            onVerticalDragEnd: _onVerticalDragEnd,
            child: Center(
              child: Transform.translate(
                offset: _offset,
                child: Hero(
                  tag: 'profileImageHero',
                  child:
                      widget.isAsset
                          ? Image.asset(
                            widget.imageUrl,
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.7,
                            fit: BoxFit.contain,
                          )
                          : Image.network(
                            widget.imageUrl,
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.7,
                            fit: BoxFit.contain,
                            loadingBuilder: (
                              BuildContext context,
                              Widget child,
                              ImageChunkEvent? loadingProgress,
                            ) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 50,
                              );
                            },
                          ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class GalleryViewerPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final Function(int)? onDeleteItem; // New callback for deletion

  const GalleryViewerPage({
    super.key,
    required this.images,
    required this.initialIndex,
    this.onDeleteItem,
  });

  @override
  State<GalleryViewerPage> createState() => _GalleryViewerPageState();
}

class _GalleryViewerPageState extends State<GalleryViewerPage> {
  late PageController _pageController;
  int currentIndex = 0;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += Offset(0, details.delta.dy);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_offset.dy.abs() > 100) {
      Navigator.pop(context);
    } else {
      setState(() {
        _offset = Offset.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(
        1 - (_offset.dy.abs() / 300).clamp(0, 1),
      ),
      body: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => currentIndex = index),
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Transform.translate(
                    offset: index == currentIndex ? _offset : Offset.zero,
                    child: AuthorizedImage(
                      imageUrl: widget.images[index],
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () {
                      if (widget.onDeleteItem != null) {
                        widget.onDeleteItem!(currentIndex);
                        // After deleting, decide whether to pop or navigate to the next/previous image
                        if (widget.images.length <= 1) {
                          Navigator.pop(context); // Pop if no more images
                        } else {
                          // Handle navigation after deletion if there are still images
                          // For simplicity, we'll pop for now. A more complex
                          // solution would involve animating to next/prev image.
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
