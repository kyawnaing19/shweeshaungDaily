import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  'Majors': 'Majors',
};

const List<String> majorsList = ['CST', 'CS', 'CT'];

const double kHorizontalPadding = 20.0;
const double kVerticalSpacing = 15.0;
const double kCardElevation = 2.0;
const double kCardBorderRadius = 12.0;
const Color kPrimaryColor = Color(0xFF00897B);
const Color kBackgroundColor = Color(0xFFE0F7FA);
const Color kAccentColor = Color(0xFF48C4BC);

class TeacherProfilePage extends StatefulWidget {
  final VoidCallback? onBack;

  const TeacherProfilePage({super.key, this.onBack});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
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
  String? _userPhotoUrl;
  bool _isLoadingUser = true;
  String? _userBio;

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
      final Map<String, dynamic>? profile = await ApiService.getProfile();
      if (mounted) {
        setState(() {
          _nickName = profile!['nickName'] ?? 'N/A';
          _department = profile['department'] ?? 'N/A';
          _role = profile['role'] ?? 'N/A';
          _userPhotoUrl =
              profile['profileUrl']; // Assuming 'photoUrl' is the key\
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
        });
      }
    }
  }

  // Method: loadCachedFeed, copied from Home.dart
  Future<List<Map<String, dynamic>>> loadCachedFeed() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedFeed = prefs.getString('cached_feed');
    if (cachedFeed != null) {
      try {
        final decoded = jsonDecode(cachedFeed);
        if (decoded is List) {
          return decoded
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        }
      } catch (e) {
        debugPrint('Error decoding cached feed: $e');
      }
    }
    return [];
  }

  // Method: _fetchFeed, copied from Home.dart
  Future<void> _fetchFeed() async {
    setState(() {
      isFeedLoading = true;
      feedErrorMessage = null;
    });

    try {
      final result = await ApiService.getTeacherProfileFeed();

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

  // New method: _fetchStories, copied from UserProfile.dart
  Future<void> _fetchStories() async {
    setState(() {
      _loadingStories = true;
    });
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
            Align(
              alignment: Alignment.topCenter,
              child: Container(
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
                child:
                    _isLoadingUser
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _userPhotoUrl != null
                                    ? ClipOval(
                                      child: AuthorizedImage(
                                        imageUrl: '$baseUrl/$_userPhotoUrl',
                                        height:
                                            60, // 2 * radius (CircleAvatar radius = 30)
                                        width: 60,
                                        fit: BoxFit.cover,
                                      ),
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
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _nickName,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _department,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _role,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const TeacherProfileUpdateScreen(),
                                      ),
                                    ).then((value) {
                                      if (value == true) {
                                        _fetchUserProfile();
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            _buildInfoCard(_userBio!),
                          ],
                        ),
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
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 400),
                          pageBuilder:
                              (_, animation, __) => AudioRecorderScreen(),
                          transitionsBuilder: (_, animation, __, child) {
                            return ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                        ),
                      );
                    },
                    child: Text(
                      'Speech',
                      style: TextStyle(
                        fontSize: 18,
                        color: kPrimaryDarkColor.withOpacity(0.7),
                        fontWeight: FontWeight.w800,
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
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const UploadSharesDialog(),
                          ).then((value) {
                            // <--- Add .then() here
                            if (value == true) {
                              // Check if the result is true (indicating success)
                              _fetchFeed(); // Call _fetchFeed() to refresh the feed
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: kAccentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: const [
                              Expanded(
                                child: Text(
                                  "What's on your mind?",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Icon(Icons.add, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
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
                                            child: Text(
                                              'No feed items available.',
                                            ),
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
                                  'Your album is empty. Add your first photo!',
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
                                  itemCount: _stories.length + 1,
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
                                    if (index == 0) {
                                      return _buildAddNewCard();
                                    } else {
                                      return _buildPhotoCard(
                                        index - 1,
                                        context,
                                      );
                                    }
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
    );
  }

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
                              : Icon(Icons.account_circle, size: 40),
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
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white70),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text(
                              'Are you sure you want to delete this item?',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(
                                      context,
                                    ).pop(false), // Cancel
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(
                                      context,
                                    ).pop(true), // Confirm
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        final success = await ApiService.deleteFeedbyId(
                          feedId.toString(),
                        );

                        // You can show a snackbar or refresh your UI based on 'success'
                        if (success==true) {
                          _fetchFeed();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Failed to delete story.'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      }
                    },
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
                    child: AuthorizedImage(
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

// New widget: _buildAddNewCard, copied from UserProfile.dart
class UploadSharesDialog extends StatefulWidget {
  const UploadSharesDialog({super.key});

  @override
  State<UploadSharesDialog> createState() => _UploadSharesDialogState();
}

class _UploadSharesDialogState extends State<UploadSharesDialog> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedAudience = 'Public';
  String? _selectedMajor;
  String? _selectedSemester;
  XFile? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // In _UploadSharesDialogState
  Future<void> _uploadPost() async {
    setState(() => _isUploading = true);
    try {
      await ApiService.uploadFeed(
        text: _controller.text,
        audience:
            _selectedAudience == 'Public'
                ? 'public'
                : _selectedAudience == 'Majors' &&
                    _selectedMajor != null &&
                    _selectedSemester != null
                ? '${_selectedSemester?.replaceAll('Sem ', '') ?? ''} ${_selectedMajor ?? ''}'
                : _selectedAudience.startsWith('Sem ')
                ? '${_selectedAudience.replaceAll('Sem ', '')} CST'
                : _selectedAudience,
        // On web, pass the XFile or its bytes instead of File
        photo: _selectedImage,
      );

      if (mounted) {
        Navigator.pop(context, true); // <--- Pass true here to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Post shared successfully!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color(0xFF317575),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.5, 0.7, 0.92],
      builder:
          (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CustomScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDragHandle(),
                        const SizedBox(height: 12),
                        _buildHeader(),
                        const SizedBox(height: 28),
                        _buildCaptionField(),
                        const SizedBox(height: 28),
                        _buildMediaSection(),
                        const SizedBox(height: 32),
                        _buildShareButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 48,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Post',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF317575),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Share your thoughts with the community',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF317575).withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        _buildAudienceSelector(),
      ],
    );
  }

  Widget _buildAudienceSelector() {
    return GestureDetector(
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (context) => const ShowSharesDialog(),
        );
        if (selected != null) {
          setState(() {
            if (selected.contains('::')) {
              final parts = selected.split('::');
              _selectedSemester = parts[0];
              _selectedMajor = parts[1];
              _selectedAudience = 'Majors';
            } else if (selected.startsWith('Majors-')) {
              _selectedAudience = 'Majors';
              _selectedMajor = selected.split('-')[1];
              _selectedSemester = null;
            } else {
              _selectedAudience = selected;
              _selectedMajor = null;
              _selectedSemester = null;
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F7F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF48C4BC).withOpacity(0.4),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _selectedAudience == 'Public' ? Icons.public : Icons.people_alt,
              size: 18,
              color: const Color(0xFF317575),
            ),
            const SizedBox(width: 6),
            Text(
              _selectedAudience == 'Majors' &&
                      _selectedMajor != null &&
                      _selectedSemester != null
                  ? '$_selectedSemester ($_selectedMajor)'
                  : _selectedAudience,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF317575),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptionField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5FDFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF48C4BC).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 150),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            maxLines: null,
            style: GoogleFonts.poppins(
              color: const Color(0xFF317575),
              fontSize: 15,
              height: 1.4,
            ),
            decoration: InputDecoration.collapsed(
              hintText: "What's on your mind?",
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF48C4BC).withOpacity(0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Media',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF317575),
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedImage != null)
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FutureBuilder<Uint8List?>(
                  future: _selectedImage!.readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return Image.memory(
                        snapshot.data!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      );
                    } else {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedImage = null),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          DottedBorder(
            color: const Color(0xFF48C4BC),
            strokeWidth: 1.5,
            dashPattern: const [6, 4],
            borderType: BorderType.RRect,
            radius: const Radius.circular(16),
            child: InkWell(
              onTap: () async {
                final picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  setState(() => _selectedImage = image);
                }
              },
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5FDFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F7F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate,
                        size: 28,
                        color: Color(0xFF317575),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to add photo',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF317575).withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            _controller.text.isEmpty && _selectedImage == null
                ? null
                : !_isUploading
                ? _uploadPost
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _controller.text.isEmpty && _selectedImage == null
                  ? const Color(0xFF48C4BC).withOpacity(0.4)
                  : const Color(0xFF317575),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child:
            _isUploading
                ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
                : Text(
                  "Share Now",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }
}

class ShowSharesDialog extends StatefulWidget {
  const ShowSharesDialog({super.key});

  @override
  State<ShowSharesDialog> createState() => _ShowSharesDialogState();
}

class _ShowSharesDialogState extends State<ShowSharesDialog> {
  bool _showMajors = false;
  String? _pendingSem;

  static const List<String> _audienceList = [
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_showMajors && _pendingSem != null) {
          Navigator.pop(context, 'Public');
          return false;
        }
        return true;
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5FDFC),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFF48C4BC).withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Select Audience',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF317575),
                    ),
                  ),
                ),
              ),

              // Content
              SizedBox(
                height: 280,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      // Left Column (Audiences)
                      Expanded(
                        child: ScrollbarTheme(
                          data: ScrollbarThemeData(
                            thumbVisibility: WidgetStateProperty.all(true),
                            trackVisibility: WidgetStateProperty.all(true),
                            thumbColor: WidgetStateProperty.all(
                              const Color(0xFF48C4BC),
                            ),
                            trackColor: WidgetStateProperty.all(
                              const Color(0xFFE8F7F6),
                            ),
                            thickness: WidgetStateProperty.all(6),
                            radius: const Radius.circular(10),
                            crossAxisMargin: 2,
                          ),
                          child: Scrollbar(
                            child: ListView.separated(
                              padding: const EdgeInsets.only(right: 4),
                              itemCount: _audienceList.length,
                              separatorBuilder:
                                  (_, __) => Divider(
                                    height: 1,
                                    color: const Color(
                                      0xFF48C4BC,
                                    ).withOpacity(0.1),
                                  ),
                              itemBuilder: (context, index) {
                                final item = _audienceList[index];
                                final isSemWithMajors = index >= 3;
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () {
                                      if (!isSemWithMajors) {
                                        Navigator.pop(context, item);
                                      } else {
                                        setState(() {
                                          _showMajors = true;
                                          _pendingSem = item;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                        horizontal: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            item == 'Public'
                                                ? Icons.public
                                                : Icons.school,
                                            size: 20,
                                            color: const Color(0xFF317575),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            item,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF317575),
                                            ),
                                          ),
                                          if (isSemWithMajors) ...[
                                            const Spacer(),
                                            const Icon(
                                              Icons.chevron_right,
                                              size: 20,
                                              color: Color(0xFF48C4BC),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // Vertical divider
                      Container(
                        width: 1,
                        height: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: const Color(0xFF48C4BC).withOpacity(0.2),
                      ),

                      // Right Column (Majors)
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child:
                              _showMajors
                                  ? ScrollbarTheme(
                                    data: ScrollbarThemeData(
                                      thumbVisibility: WidgetStateProperty.all(
                                        true,
                                      ),
                                      trackVisibility: WidgetStateProperty.all(
                                        true,
                                      ),
                                      thumbColor: WidgetStateProperty.all(
                                        const Color(0xFF48C4BC),
                                      ),
                                      trackColor: WidgetStateProperty.all(
                                        const Color(0xFFE8F7F6),
                                      ),
                                      thickness: WidgetStateProperty.all(6),
                                      radius: const Radius.circular(10),
                                      crossAxisMargin: 2,
                                    ),
                                    child: Scrollbar(
                                      child: ListView.separated(
                                        padding: const EdgeInsets.only(left: 4),
                                        itemCount: majorsList.length,
                                        separatorBuilder:
                                            (_, __) => Divider(
                                              height: 1,
                                              color: const Color(
                                                0xFF48C4BC,
                                              ).withOpacity(0.1),
                                            ),
                                        itemBuilder: (context, index) {
                                          final major = majorsList[index];
                                          return Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              onTap: () {
                                                if (_pendingSem != null) {
                                                  Navigator.pop(
                                                    context,
                                                    '$_pendingSem::$major',
                                                  );
                                                }
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                      horizontal: 12,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.architecture,
                                                      size: 20,
                                                      color: Color(0xFF317575),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      major,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: const Color(
                                                              0xFF317575,
                                                            ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                  : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFFE8F7F6),
                                          ),
                                          child: const Icon(
                                            Icons.people_alt,
                                            size: 30,
                                            color: Color(0xFF317575),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Select a semester\nfirst to see majors',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: const Color(
                                              0xFF317575,
                                            ).withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5FDFC),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFF48C4BC).withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
                    "Create Story",
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
                                  child: FutureBuilder<Uint8List?>(
                                    future: _selectedImage!.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                              ConnectionState.done &&
                                          snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data!,
                                          width: mediaQuery.size.width * 0.7,
                                          height: 180,
                                          fit: BoxFit.cover,
                                        );
                                      } else {
                                        return Container(
                                          width: mediaQuery.size.width * 0.7,
                                          height: 180,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                    },
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
                ],
              ),
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
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Delete Story'),
                              content: const Text(
                                'Are you sure you want to delete this story? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        final success = await ApiService.deleteStory(
                          widget.images[currentIndex].substring(
                            widget.images[currentIndex].indexOf('tfeedphoto'),
                          ),
                        );

                        if (success) {
                          if (widget.onDeleteItem != null) {
                            widget.onDeleteItem!(currentIndex);

                            // Pop depending on remaining images
                            if (widget.images.length <= 1) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pop(
                                context,
                              ); // You can also auto-navigate to next image here
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Failed to delete story.'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
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
