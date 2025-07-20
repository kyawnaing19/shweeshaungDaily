// import 'dart:io'; // Removed for web compatibility
import 'dart:typed_data';
import 'dart:convert'; // Added for JSON encoding/decoding
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Added for date formatting

import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/views/audio_post/audio_upload_page.dart';
import 'package:shweeshaungdaily/services/authorize_image.dart'; // Added for AuthorizedImage
import 'package:shweeshaungdaily/services/token_service.dart'; // Added for TokenService
import 'package:shweeshaungdaily/utils/audio_timeformat.dart'; // Added for formatFacebookStyleTime
import 'package:shweeshaungdaily/utils/image_cache.dart'; // Added for ImageCacheManager
import 'package:shweeshaungdaily/views/comment_section.dart'; // Added for CommentSection
import 'package:shweeshaungdaily/views/image_full_view.dart'; // Added for ImageFullView
import 'package:shweeshaungdaily/widget/copyable_text.dart'; // Added for CopyableText
import 'package:shared_preferences/shared_preferences.dart'; // Added for SharedPreferences

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

class TeacherProfilePage extends StatefulWidget {
  final VoidCallback? onBack;

  const TeacherProfilePage({super.key, this.onBack});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  int _currentPage = 0;
  late final PageController _pageController;

  // New state variables for feed management, copied from Home.dart
  final String baseUrl = ApiService.base;
  List<Map<String, dynamic>>? feedItems = [];
  bool isFeedLoading = true;
  String? feedErrorMessage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _fetchFeed(); // Fetch feed when the page initializes
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // New method: loadCachedFeed, copied from Home.dart
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

  // New method: _fetchFeed, copied from Home.dart
  Future<void> _fetchFeed() async {
    setState(() {
      isFeedLoading = true;
      feedErrorMessage = null;
    });

    try {
      final result = await ApiService.getFeed();

      // Save feed to local cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_feed', jsonEncode(result));

      setState(() {
        feedItems = result ?? [];
        isFeedLoading = false;
      });

      // 🧹 Clean up cached images not in feed
      final imageUrls =
          feedItems!
              .map((item) => item['photoUrl'])
              .where((url) => url != null && url != '')
              .map((url) => '$baseUrl/$url')
              .toSet();

      await ImageCacheManager.clearUnusedFeedImages(imageUrls);
    } catch (e) {
      // API failed – try to reload cached feed
      final cached = await loadCachedFeed();
      setState(() {
        feedItems = cached;
        feedErrorMessage = 'Failed to load feed: ${e.toString()}'; // Display error message
        isFeedLoading = false;
      });
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

            const SizedBox(height: 7),

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
            Expanded( // Use Expanded to allow the PageView to take available height
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
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder:
                                  (context) => const UploadSharesDialog(),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
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
                        const SizedBox(height: 16), // Spacing below the "What's on your mind?"

                        // Bulletin Section (Copied from Home.dart)
                        Expanded( // Wrap the bulletin content in Expanded to fill remaining space
                          child: RefreshIndicator( // Added RefreshIndicator
                            onRefresh: _fetchFeed, // Refresh feed on pull
                            child: CustomScrollView( // Use CustomScrollView for SliverPadding
                              slivers: [
                                // SliverPersistentHeader(
                                //   pinned: true,
                                //   delegate: _SliverAppBarDelegate(
                                //     minHeight: 60.0,
                                //     maxHeight: 60.0,
                                //     // child: Container(
                                //     //   color: const Color(0xFFE0F7FA),
                                //     //   padding: const EdgeInsets.symmetric(
                                //     //     horizontal: 20,
                                //     //     vertical: 16,
                                //     //   ),
                                //     //   child: const Text(
                                //     //     "Bulletin",
                                //     //     style: TextStyle(
                                //     //       fontSize: 20,
                                //     //       fontWeight: FontWeight.w700,
                                //     //       color: Color(0xFF00897B),
                                //     //       letterSpacing: 0.5,
                                //     //     ),
                                //     //   ),
                                //     // ),
                                //   ),
                                // ),
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        if (isFeedLoading) {
                                          return ShimmerLoadingPlaceholder(
                                            height: MediaQuery.of(context).size.height * 0.3,
                                            width: MediaQuery.of(context).size.width - 32,
                                          );
                                        }

                                        if (feedErrorMessage != null) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                                            child: Center(child: Text(feedErrorMessage!)),
                                          );
                                        }

                                        if (feedItems!.isEmpty) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 32.0),
                                            child: Center(child: Text('No feed items available.')),
                                          );
                                        }

                                        final item = feedItems![index];
                                        final String user =
                                            item['teacherName']; // Replace with actual user
                                        final String timeAgo = item['createdAt'] ?? '';
                                        final String message = item['text'] ?? '';
                                        final String? imageUrl =
                                            (item['photoUrl'] != null && item['photoUrl'] != '')
                                                ? '$baseUrl/${item['photoUrl']}'
                                                : null;
                                        // Count likes and comments from the response arrays
                                        final int likeCount = (item['likes'] as List?)?.length ?? 0;
                                        final int commentCount =
                                            (item['comments'] as List?)?.length ?? 0;

                                        return FutureBuilder<String?>(
                                          future: TokenService.getUserName(),
                                          builder: (context, snapshot) {
                                            final List<String> likes = List<String>.from(
                                              item['likes'] ?? [],
                                            );
                                            final userName = snapshot.data ?? '';
                                            final bool isLikedByMe = likes.contains(userName);
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 16.0),
                                              child: _buildFeedCard(
                                                user: user,
                                                timeAgo: formatFacebookStyleTime(timeAgo),
                                                message: message,
                                                imageUrl: imageUrl,
                                                likeCount: likeCount,
                                                commentCount: commentCount,
                                                comments: item['comments'] ?? [],
                                                feedId: item['id'] ?? '',
                                                isLiked: isLikedByMe,
                                                userName: userName, // Pass userName here
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
                                builder:
                                    (context) => const UploadStoryDialog(),
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
    );
  }

  // New widget: _buildFeedCard, copied from Home.dart
  Widget _buildFeedCard({
    required String user,
    required String timeAgo,
    required String message,
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
                      child: Image.asset(
                        'assets/images/tpo.jpg',
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
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
                  IconButton(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white70,
                    ),
                    onPressed: () {},
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
                              if (feedId == null) return; // Add null check for feedId
                              if (isLiked) {
                                print("is liked");
                                final success = await ApiService.unlike(
                                  feedId,
                                );
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
                                      )..add(userName); // Use userName parameter here
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


// _SliverAppBarDelegate copied from Home.dart
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
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
        Navigator.pop(context);
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
    );
  }
}
