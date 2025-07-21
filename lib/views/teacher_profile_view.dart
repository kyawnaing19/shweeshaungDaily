import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Assuming these imports are available in your project
import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/services/authorize_image.dart';
import 'package:shweeshaungdaily/services/authorized_network_image.dart';
import 'package:shweeshaungdaily/services/token_service.dart';
import 'package:shweeshaungdaily/utils/audio_timeformat.dart';
import 'package:shweeshaungdaily/utils/image_cache.dart';
import 'package:shweeshaungdaily/views/audio_post/audio_upload_page.dart';
import 'package:shweeshaungdaily/views/comment_section.dart';
import 'package:shweeshaungdaily/views/image_full_view.dart';
import 'package:shweeshaungdaily/widget/copyable_text.dart';
import 'package:shweeshaungdaily/views/user_album_upload.dart';
// import 'package:shweeshaungdaily/views/user_profile_update.dart'; // No longer needed for teacher profile
import 'package:shweeshaungdaily/views/teacher_profile_update.dart'; // <--- NEW IMPORT

const double kHorizontalPadding = 20.0;
const double kVerticalSpacing = 15.0;
const double kCardElevation = 2.0;
const double kCardBorderRadius = 12.0;

class TeacherProfileViewPage extends StatefulWidget {
  final VoidCallback? onBack;
  final String email;

  const TeacherProfileViewPage({super.key, this.onBack, required this.email});

  @override
  State<TeacherProfileViewPage> createState() => _TeacherProfileViewPageState();
}

class _TeacherProfileViewPageState extends State<TeacherProfileViewPage> {
  int _currentPage = 0;
  late final PageController _pageController;

  // State variables for feed management (from Home.dart)
  final String baseUrl = ApiService.base;
  List<Map<String, dynamic>>? feedItems = [];
  bool isFeedLoading = true;
  String? feedErrorMessage;

  // New state variables for album/stories management (from UserProfile.dart)
  List<dynamic> _stories = [];
  bool _loadingStories = true; // Renamed to avoid conflict with `isFeedLoading`

  // User Profile Data
  String _nickName = 'Loading...';
  String _department = 'Loading...';
  String _role = 'Loading...';
  bool _isLoadingUser = true;
  String? _userBio;
  String? finalProfileImage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _fetchFeed();
    _fetchStories();
    _fetchUserProfile(); // Fetch user profile data
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Method to fetch user profile data - FIXED
  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoadingUser = true;
    });
    try {
      final Map<String, dynamic>? profile = await ApiService.getProfileForViewing(widget.email);
      if (mounted) {
        setState(() {
          _nickName = profile!['nickName'] ?? 'N/A';
          _department = profile['department'] ?? 'N/A';
          _role = profile['role'] ?? 'N/A';
          final String? rawProfileImageUrl = profile['profilePictureUrl'];
          final String? finalProfileImage =
              (rawProfileImageUrl != null && rawProfileImageUrl.isNotEmpty)
                  ? '$baseUrl/$rawProfileImageUrl'
                  : null;
          _userBio =
              (profile['bio']?.toString().trim().isNotEmpty ?? false)
                  ? profile!['bio'].toString()
                  : 'Add a few words about yourself...';

          _isLoadingUser = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
          _nickName = 'Error';
          _department = 'Error';
          _role = 'Error';
          _userBio = 'Error';
        });
      }
    }
  }

  // Method: loadCachedFeed, copied from Home.dart
  Future<List<Map<String, dynamic>>> loadCachedFeed() async {
    return [];
  }

  // Method: _fetchFeed, copied from Home.dart
  Future<void> _fetchFeed() async {
    setState(() {
      isFeedLoading = true;
      feedErrorMessage = null;
    });

    try {
      final result = await ApiService.getTeacherProfileFeedForViewing(widget.email);

      // Save feed to local cache
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('cached_feed', jsonEncode(result));

      setState(() {
        feedItems = result ?? [];
        isFeedLoading = false;
      });

      // 🧹 Clean up cached images not in feed
      // final imageUrls =
      //     feedItems!
      //         .map((item) => item['photoUrl'])
      //         .where((url) => url != null && url != '')
      //         .map((url) => '$baseUrl/$url')
      //         .toSet();

      // await ImageCacheManager.clearUnusedFeedImages(imageUrls);
    } catch (e) {
      // API failed – try to reload cached feed
      // final cached = await loadCachedFeed();
      setState(() {
        feedItems = [];
        feedErrorMessage =
            'Failed to load feed: ${e.toString()}'; // Display error message
        isFeedLoading = false;
      });
    }
  }

  // New method: loadStoryItems, copied from UserProfile.dart
  Future<List<Map<String, dynamic>>> loadStoryItems() async {
    return [];
  }

  // New method: _fetchStories, copied from UserProfile.dart
  Future<void> _fetchStories() async {
    setState(() {
      _loadingStories = true;
    });
    try {
      final result = await ApiService.getStoryForViewing(widget.email);
    

      if (mounted) {
        setState(() {
          debugPrint('Stories before update: ${_stories.length}');
          _stories = result; // Or _stories = cached;
          debugPrint(
            'Stories after update: ${_stories.length}, first item: ${_stories.isNotEmpty ? _stories.first : 'N/A'}',
          );
          _loadingStories = false;
        });
      }
    } catch (e) {
      final cached = await loadStoryItems();
      if (mounted) {
        setState(() {
          _stories = cached;
          _loadingStories = false;
        });
      }
      debugPrint('Error fetching stories/album items: $e');
    }
  }

  // New method: _onDeleteItem, copied from UserProfile.dart
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
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 5),
            // Profile Card (Updated)
            Container(
              width: double.infinity, // Makes the container full-width
              padding: const EdgeInsets.all(16), // 🔹 Inner spacing
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                  255,
                  193,
                  242,
                  249,
                ), // 🔹 Background color
                borderRadius: BorderRadius.circular(12), // 🔹 Rounded corners
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start, // This aligns children to the start horizontally
                  children: [
                    Container(
                      width: double.infinity, // Makes the container full-width
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
                                if (finalProfileImage != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => FullscreenImageView(
                                            imageUrl:
                                                finalProfileImage.toString(),
                                            isAsset:
                                                false, // It's a network image
                                          ),
                                    ),
                                  );
                                }
                              },
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: kAccentColor,
                                child: ClipOval(
                                  // Added ClipOval here
                                  child: SizedBox(
                                    // Sized box to ensure proper sizing for ClipOval
                                    width: 112, // Corresponds to radius * 2
                                    height: 112, // Corresponds to radius * 2
                                    child:
                                        finalProfileImage != null
                                            ? AuthorizedNetworkImage(
                                              // Add a Key here based on the image URL
                                              key: ValueKey(finalProfileImage),
                                              imageUrl:
                                                  finalProfileImage.toString(),
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
                                    _nickName,
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        _department,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                            _nickName,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              color: kPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                _department,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: kPrimaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
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
            _buildInfoCard(_role, _userBio!),
            const SizedBox(height: 18),

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
                      'Bulletin',
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
                      'Album',
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

            const SizedBox(height: 15),

            // Swipeable Shares & Stories
            Expanded(
              // Use Expanded to allow the PageView to take available height
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // Shares Widget
                  Column(
                    children: [
                      // In _TeacherProfilePageState, inside the build method, where UploadSharesDialog is called:
                      // GestureDetector(
                      //   onTap: () {
                      //     showModalBottomSheet(
                      //       context: context,
                      //       isScrollControlled: true,
                      //       backgroundColor: Colors.transparent,
                      //       builder: (context) => const UploadSharesDialog(),
                      //     ).then((value) {
                      //       // <--- Add .then() here
                      //       if (value == true) {
                      //         // Check if the result is true (indicating success)
                      //         _fetchFeed(); // Call _fetchFeed() to refresh the feed
                      //       }
                      //     });
                      //   },
                      // ),
                      const SizedBox(
                        height: 16,
                      ), // Spacing below the "What's on your mind?"
                      // Bulletin Section (Copied from Home.dart)
                      Expanded(
                        // Wrap the bulletin content in Expanded to fill remaining space
                        child: RefreshIndicator(
                          // Added RefreshIndicator
                          onRefresh: _fetchFeed, // Refresh feed on pull
                          child: CustomScrollView(
                            // Use CustomScrollView for SliverPadding
                            slivers: [
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      if (isFeedLoading) {
                                        return const ShimmerLoadingPlaceholder(
                                          // Added const
                                          height: 200, // Example height
                                          width:
                                              double.infinity, // Example width
                                        );
                                      }

                                      if (feedErrorMessage != null) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 32.0,
                                          ),
                                          child: Center(
                                            child: Text(feedErrorMessage!),
                                          ),
                                        );
                                      }

                                      if (feedItems!.isEmpty) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 32.0,
                                          ),
                                          child: Center(
                                            child: Text('No bulletin yet!'),
                                          ),
                                        );
                                      }

                                      final item = feedItems![index];
                                      final String user =
                                          item['teacherName']; // Replace with actual user
                                      final String timeAgo =
                                          item['createdAt'] ?? '';
                                      final String message = item['text'] ?? '';
                                      final String? imageUrl =
                                          (item['photoUrl'] != null &&
                                                  item['photoUrl'] != '')
                                              ? '$baseUrl/${item['photoUrl']}'
                                              : null;
                                      final String? uprofile =
                                          (item['profileUrl'] != null &&
                                                  item['profileUrl'] != '')
                                              ? '$baseUrl/${item['profileUrl']}'
                                              : null;
                                      // Count likes and comments from the response arrays
                                      final int likeCount =
                                          (item['likes'] as List?)?.length ?? 0;
                                      final int commentCount =
                                          (item['comments'] as List?)?.length ??
                                          0;

                                      return FutureBuilder<String?>(
                                        future: TokenService.getUserName(),
                                        builder: (context, snapshot) {
                                          final List<String> likes =
                                              List<String>.from(
                                                item['likes'] ?? [],
                                              );
                                          final userName = snapshot.data ?? '';
                                          final bool isLikedByMe = likes
                                              .contains(userName);
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 16.0,
                                            ),
                                            child: _buildFeedCard(
                                              user: user,
                                              timeAgo: formatFacebookStyleTime(
                                                timeAgo,
                                              ),
                                              message: message,
                                              imageUrl: imageUrl,
                                              likeCount: likeCount,
                                              profileUrl: uprofile,
                                              commentCount: commentCount,
                                              comments: item['comments'] ?? [],
                                              feedId: item['id'] ?? '',
                                              isLiked: isLikedByMe,
                                              userName:
                                                  userName, // Pass userName here
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    childCount: () {
                                      if (isFeedLoading ||
                                          feedErrorMessage != null ||
                                          feedItems!.isEmpty) {
                                        return 1;
                                      } else {
                                        return feedItems?.length;
                                      }
                                    }(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Stories Widget (Album section from UserProfile.dart)
                  RefreshIndicator(
                    // Added RefreshIndicator for stories
                    onRefresh: _fetchStories, // Refresh stories on pull
                    child: SingleChildScrollView(
                      // Added SingleChildScrollView
                      physics:
                          const AlwaysScrollableScrollPhysics(), // Ensure scrollable even if content is small
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Show a message if album is empty and not loading
                            if (_stories.isEmpty && !_loadingStories)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20.0,
                                ),
                                child: Text(
                                  'No photo album yet!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            _loadingStories
                                ? const Center(
                                  child: CircularProgressIndicator(
                                    color: kPrimaryDarkColor,
                                  ),
                                )
                                : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _stories.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            3, // Changed to 3 for a tighter grid
                                        crossAxisSpacing:
                                            8.0, // Adjusted spacing
                                        mainAxisSpacing:
                                            8.0, // Adjusted spacing
                                        childAspectRatio:
                                            0.7, // Adjusted aspect ratio for better fit
                                      ),
                                  itemBuilder: (context, index) {
                                    return _buildPhotoCard(index, context);
                                  },
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String role, String bio) {
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

  // Widget: _buildFeedCard, copied from Home.dart
  Widget _buildFeedCard({
    required String user,
    required String timeAgo,
    required String message,
    required String? profileUrl,
    required String? imageUrl,
    required int? likeCount,
    required int? commentCount,
    required List<dynamic> comments,
    required int? feedId,
    required bool isLiked,
    required String userName, // Added userName parameter
  }) {
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4DB6AC), Color(0xFF26A69A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child:
                          profileUrl != null && profileUrl.isNotEmpty
                              ? AuthorizedNetworkImage(
                                imageUrl: profileUrl,
                                height: 40,
                                width: 40,
                              )
                              : CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: kPrimaryDarkColor,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Message Text
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: CopyableText(
                text: message,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                highlightStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Conditionally display the image section
            if (hasImage) // Use widget.imageUrl to check for image existence
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageFullView(imageUrl: imageUrl),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AuthorizedNetworkImage(
                      imageUrl: imageUrl,
                      height: 200,
                      width: double.infinity,
                      // Add this line
                    ),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),

            //if (!hasImage) const SizedBox(height: 12),

            // Action Bar
            Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: Colors.white70,
                              size: 22,
                            ),
                            onPressed: () async {
                              if (feedId == null)
                                return; // Add null check for feedId
                              if (isLiked) {
                                print("is liked");
                                final success = await ApiService.unlike(feedId);
                                if (success) {
                                  setState(() {
                                    isLiked = false;
                                    likeCount = likeCount! - 1;
                                    final idx = feedItems?.indexWhere(
                                      (item) => item['id'] == feedId,
                                    );
                                    if (idx != null && idx >= 0) {
                                      final likes = feedItems![idx]['likes'];
                                      if (likes is List && likes.isNotEmpty) {
                                        likes.removeLast();
                                        feedItems![idx]['likes'] = List.from(
                                          likes,
                                        );
                                      }
                                    }
                                  });
                                }
                              } else {
                                final success = await ApiService.like(feedId);
                                if (success) {
                                  setState(() {
                                    final idx = feedItems?.indexWhere(
                                      (item) => item['id'] == feedId,
                                    );
                                    if (idx != null && idx >= 0) {
                                      feedItems![idx]['likes'] = List.from(
                                        feedItems![idx]['likes'] ?? [],
                                      )..add(
                                        userName,
                                      ); // Use userName parameter here
                                    }
                                    isLiked = true;
                                    likeCount = likeCount! + 1;
                                  });
                                }
                              }
                            },
                          ),
                          const SizedBox(width: 4),
                          Text(
                            likeCount.toString(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Colors.white70,
                      size: 22,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder:
                            (context) => FractionallySizedBox(
                              heightFactor: 1.0,
                              child: CommentSection(
                                feedId: feedId,
                                comments: comments,
                                onCommentSuccess: () {
                                  setState(() {
                                    // Find the feed item by feedId and add a dummy comment to increment count
                                    final idx = feedItems?.indexWhere(
                                      (item) => item['id'] == feedId,
                                    );
                                    if (idx != null && idx >= 0) {
                                      feedItems![idx]['comments'] = List.from(
                                        feedItems![idx]['comments'] ?? [],
                                      )..add({});
                                    }
                                  });
                                },
                              ),
                            ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  Text(
                    commentCount.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const Spacer(),
                ],
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

// Helper widget for shimmer loading, copied from Home.dart
class ShimmerLoadingPlaceholder extends StatelessWidget {
  final double height;
  final double width;

  const ShimmerLoadingPlaceholder({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[200]!),
          backgroundColor: Colors.grey[300],
        ),
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
