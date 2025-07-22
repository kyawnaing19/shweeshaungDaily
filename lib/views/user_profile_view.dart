import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/services/authorized_network_image.dart';

// Consider defining constants for common sizes/paddings
const double kHorizontalPadding = 20.0;
const double kVerticalSpacing = 15.0;
const double kCardElevation = 2.0;
const double kCardBorderRadius = 12.0;

class UserProfileView extends StatefulWidget {
  final VoidCallback? onBack;
  final String email;

  const UserProfileView({super.key, this.onBack, required this.email});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
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
      final profile = await ApiService.getProfileForViewing(widget.email);
      print(profile);
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
    return [];
  }

  Future<void> _fetchStories() async {
    try {
      final result = await ApiService.getStoryForViewing(widget.email);

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
    final String semester = _profile?['semester'] ?? 'Loading Semester...';
    final String userBio =
        (_profile?['bio']?.toString().trim().isNotEmpty ?? false)
            ? _profile!['bio'].toString()
            : 'No bio yet';

    // Directly use _profile?['profilePictureUrl'] to determine image source
    final String? rawProfileImageUrl = _profile?['profilePictureUrl'];
    final String? finalProfileImageUrl =
        (rawProfileImageUrl != null && rawProfileImageUrl.isNotEmpty)
            ? '$baseUrl/$rawProfileImageUrl'
            : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAccentColor,
        elevation: 0,
        automaticallyImplyLeading: true, // Set to true to show the back arrow
      ),
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
                      Container(
                        width:
                            double.infinity, // Makes the container full-width
                        padding: const EdgeInsets.all(16), // 🔹 Inner spacing
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            193,
                            242,
                            249,
                          ), // 🔹 Background color
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // 🔹 Rounded corners
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start, // This aligns children to the start horizontally
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (finalProfileImageUrl != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => FullscreenImageView(
                                              imageUrl: finalProfileImageUrl,
                                              isAsset:
                                                  false, // It's a network image
                                            ),
                                      ),
                                    );
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: kWhite,
                                  child: ClipOval(
                                    // Added ClipOval here
                                    child: SizedBox(
                                      // Sized box to ensure proper sizing for ClipOval
                                      width: 112, // Corresponds to radius * 2
                                      height: 112, // Corresponds to radius * 2
                                      child:
                                          finalProfileImageUrl != null
                                              ? AuthorizedNetworkImage(
                                                // Add a Key here based on the image URL
                                                key: ValueKey(
                                                  finalProfileImageUrl,
                                                ),
                                                imageUrl: finalProfileImageUrl,
                                                width: 112,
                                                height: 112,
                                                fit: BoxFit.cover,
                                              )
                                              : const Icon(
                                                Icons.person,
                                                size: 60,
                                                color: kPrimaryColor,
                                              ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: kVerticalSpacing),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userNickname,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: kPrimaryDarkColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '@$userName',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: kPrimaryDarkColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildInfoCard(semester, userBio),
                      const SizedBox(height: 18),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Album',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryDarkColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: kVerticalSpacing),
                      // Show a message if album is empty and not loading
                      if (_stories.isEmpty && !_loading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Text(
                            'No photo album yet!',
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
                        itemCount: _stories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12.0,
                              mainAxisSpacing: 12.0,
                              childAspectRatio: 0.8,
                            ),
                        itemBuilder: (context, index) {
                          return _buildPhotoCard(index, context);
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildInfoCard(String semester, String bio) {
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
              Text(
                'Sem $semester',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              Divider(color: Colors.white, height: 25),
              Text(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          children: [
            AuthorizedNetworkImage(
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
                child:
                    widget.isAsset
                        ? Image.asset(
                          widget.imageUrl,
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.7,
                          fit: BoxFit.contain,
                        )
                        : AuthorizedNetworkImage(
                          imageUrl: widget.imageUrl,
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.7,
                          fit: BoxFit.contain,
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
                    child: AuthorizedNetworkImage(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
