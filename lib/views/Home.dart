import 'dart:async';
import 'dart:convert'; // Add this for JSON encoding/decoding
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:shweeshaungdaily/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shweeshaungdaily/services/authorize_image.dart';
import 'package:shweeshaungdaily/services/token_service.dart';
import 'package:shweeshaungdaily/utils/audio_timeformat.dart';
import 'package:shweeshaungdaily/utils/image_cache.dart';
import 'package:shweeshaungdaily/views/audio_post/audio_view.dart';
import 'package:shweeshaungdaily/views/image_full_view.dart';
import 'package:shweeshaungdaily/views/mail/mail_view.dart';

import 'package:shweeshaungdaily/views/comment_section.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shweeshaungdaily/views/teacher_profile_view.dart';
import 'package:shweeshaungdaily/views/user_profile_view.dart';
import 'package:shweeshaungdaily/views/widget_loading.dart';
import 'package:shweeshaungdaily/widget/copyable_text.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({super.key});
  // Add this for base URL

  @override
  State<HomeScreenPage> createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreenPage>
    with TickerProviderStateMixin {
  final String baseUrl = ApiService.base;
  List<Map<String, dynamic>>? feedItems = [];
  bool isFeedLoading = true;
  String? feedErrorMessage;
  Map<String, Map<int, dynamic>>? timetableData;
  bool isLoading = true;
  String? userName;
  String? errorMessage;

  // Audio player state
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isFetchingAudio = false;

  late AnimationController _waveController;

  Future<void> _playAudio() async {
    setState(() {
      _isFetchingAudio = true;
    });
    // Placeholder audio URL (public domain short mp3)
    const url = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
    await _audioPlayer.play(UrlSource(url));
    setState(() {
      _isPlaying = true;
      _isFetchingAudio = false;
    });
    _waveController.repeat();
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
    _waveController.stop();
    _waveController.reset();
  }

  Widget _audioWaveAnimation() {
    return SizedBox(
      width: 60, // Fixed width (adjust based on your needs)
      height: 60, // Fixed height to avoid dynamic resizing
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          final t = _waveController.value;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final phase = t + i * 0.2;
              final barHeight =
                  14.0 +
                  14.0 * (0.5 + 0.5 * (1 + sin(1.2 * 3.14159 * (phase % 1))));
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 5,
                height: barHeight.clamp(
                  14.0,
                  42.0,
                ), // Optionally clamp the height
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  final List<String> customMessageImages = [
    'assets/images/poem1.webp',
    'assets/images/poem2.webp',
    'assets/images/poem3.webp',
    'assets/images/poem4.webp',
    'assets/images/poem5.webp',
    'assets/images/poem6.webp',
  ];

  // Period start and end times (lunch break is now a 'period' at index 3)
  final List<Map<String, dynamic>> periodTimes = [
    {
      "start": const TimeOfDay(hour: 8, minute: 30),
      "end": const TimeOfDay(hour: 9, minute: 29),
      "type": "class",
    }, // Period 1
    {
      "start": const TimeOfDay(hour: 9, minute: 30),
      "end": const TimeOfDay(hour: 10, minute: 29),
      "type": "class",
    }, // Period 2
    {
      "start": const TimeOfDay(hour: 10, minute: 30),
      "end": const TimeOfDay(hour: 11, minute: 29),
      "type": "class",
    }, // Period 3
    {
      "start": const TimeOfDay(hour: 11, minute: 30),
      "end": const TimeOfDay(hour: 12, minute: 29),
      "type": "lunch",
    }, // Lunch break
    {
      "start": const TimeOfDay(hour: 12, minute: 30),
      "end": const TimeOfDay(hour: 13, minute: 29),
      "type": "class",
    }, // Period 4
    {
      "start": const TimeOfDay(hour: 13, minute: 30),
      "end": const TimeOfDay(hour: 14, minute: 29),
      "type": "class",
    }, // Period 5
    {
      "start": const TimeOfDay(hour: 14, minute: 30),
      "end": const TimeOfDay(hour: 15, minute: 30),
      "type": "class",
    }, // Period 6
  ];
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _loadTimetableFromPrefs();
    getUserName();
    _fetchFeed();

    _pageController = PageController(
      viewportFraction: 0.92,
      initialPage: _getCurrentPeriodIndex(),
    );
    // Add timer to update UI every minute for lunch card and period cards
    _lunchTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!mounted) return;
      final currentPeriod = _getCurrentPeriodIndex();
      if (_pageController.hasClients && _pageController.page != currentPeriod) {
        _pageController.jumpToPage(currentPeriod);
      }
      setState(() {});
    });
  }

  Future<void> getUserName() async {
    userName = await TokenService.getUserName();
  }

  // Update loadCachedFeed to return the feed list
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

  Timer? _lunchTimer;
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

      final imageUrlsForProfiles =
          feedItems!
              .map((item) => item['profileUrl'])
              .where((url) => url != null && url != '')
              .map((url) => '$baseUrl/$url')
              .toSet();

      await ImageCacheManager.clearUnusedFeedImages(imageUrls);
      await ImageCacheManager.clearUnusedProfileImages(imageUrlsForProfiles);
    } catch (e) {
      // print("hhhhh");
      // API failed – try to reload cached feed
      final cached = await loadCachedFeed();
      setState(() {
        // print("hhhhh");
        feedItems = cached;
        //feedErrorMessage = 'Failed to load feed: ${e.toString()}';
        isFeedLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _lunchTimer?.cancel();
    _pageController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  // Helper function to check if it's a weekday
  bool _isWeekday() {
    final now = DateTime.now();
    return now.weekday >= DateTime.monday && now.weekday <= DateTime.friday;
  }

  // Check if current time is within any defined class period (including lunch)
  // This function now explicitly returns true if it's *during* class/lunch.
  bool isDuringClassOrLunchTime() {
    final now = TimeOfDay.now();
    for (int i = 0; i < periodTimes.length; i++) {
      final start = periodTimes[i]["start"] as TimeOfDay;
      final end = periodTimes[i]["end"] as TimeOfDay;

      // Convert TimeOfDay to comparable minutes from midnight
      final nowInMinutes = now.hour * 60 + now.minute;
      final startInMinutes = start.hour * 60 + start.minute;
      final endInMinutes = end.hour * 60 + end.minute;

      // Handle cases where the end time is on the next day (e.g., 23:00 to 01:00)
      if (startInMinutes <= endInMinutes) {
        if (nowInMinutes >= startInMinutes && nowInMinutes <= endInMinutes) {
          return true; // It's currently within a class or lunch period
        }
      } else {
        // Period crosses midnight (e.g., 22:00 to 05:59)
        if (nowInMinutes >= startInMinutes || nowInMinutes <= endInMinutes) {
          return true;
        }
      }
    }
    return false; // Not in any defined class or lunch period
  }

  int _getCurrentPeriodIndex() {
    final now = TimeOfDay.now();
    for (int i = 0; i < periodTimes.length; i++) {
      final start = periodTimes[i]["start"] as TimeOfDay;
      final end = periodTimes[i]["end"] as TimeOfDay;
      final afterStart =
          now.hour > start.hour ||
          (now.hour == start.hour && now.minute >= start.minute);
      final beforeEnd =
          now.hour < end.hour ||
          (now.hour == end.hour && now.minute <= end.minute);
      if (afterStart && beforeEnd) {
        return i;
      }
    }
    return 0; // Default to first period if not in any period
  }

  String getCurrentDayName() {
    final weekday = DateTime.now().weekday;
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  void _showCustomSnackbar(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: MediaQuery.of(context).size.height * 0.10,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: IntrinsicWidth(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 350),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      entry.remove();
    });
  }

  Future<void> _loadTimetableFromPrefs() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final prefs = await SharedPreferences.getInstance();
    final timetableJson = prefs.getString('timetableData');
    if (timetableJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(timetableJson);
        setState(() {
          timetableData = decoded.map(
            (k, v) => MapEntry(
              k,
              (v as Map<String, dynamic>).map(
                (ik, iv) => MapEntry(int.parse(ik), iv),
              ),
            ),
          );
          isLoading = false;
        });
      } catch (e) {
        // If error in decoding, fallback to API
        await _fetchTimetable();
      }
    } else {
      await _fetchTimetable();
    }
  }

  Future<void> _fetchTimetable() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final data = await ApiService.fetchTimetable();
      setState(() {
        timetableData = data;
        isLoading = false;
      });
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      // Convert int keys to string for JSON encoding
      final dataToSave = data.map(
        (k, v) => MapEntry(k, v.map((ik, iv) => MapEntry(ik.toString(), iv))),
      );
      await prefs.setString('timetableData', jsonEncode(dataToSave));
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      Future.microtask(() {
        if (mounted) {
          _showCustomSnackbar("Connection Error");
        }
      });
      print(e.toString());
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchTimetable();
    await _fetchFeed();
    final currentPeriod = _getCurrentPeriodIndex();
    if (currentPeriod >= 0 && currentPeriod < periodTimes.length) {
      _pageController.jumpToPage(currentPeriod);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = getCurrentDayName();
    final classes = timetableData?[today] ?? {};

    return Scaffold(
      backgroundColor: kBackgroundColor,

      body: RefreshIndicator(
        onRefresh: () async {
          await _handleRefresh();
          await _fetchFeed();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height:
                        MediaQuery.of(context).size.height *
                        0.3, // 30% of screen height for responsiveness
                    child: Builder(
                      builder: (context) {
                        // Check if it's a weekday AND during class/lunch time
                        if (_isWeekday() && isDuringClassOrLunchTime()) {
                          final currentPeriod = _getCurrentPeriodIndex();
                          final periodType = periodTimes[currentPeriod]["type"];
                          if (periodType == "lunch") {
                            final now = DateTime.now();
                            final periodTime =
                                periodTimes[currentPeriod]["start"]
                                    as TimeOfDay;
                            final periodDateTime = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              periodTime.hour,
                              periodTime.minute,
                            );
                            final periodTimeStr = DateFormat(
                              'hh:mm a',
                            ).format(periodDateTime);
                            return _buildLunchBreakCard(
                              periodDateTime,
                              periodTimeStr,
                            );
                          } else {
                            final classPeriodIndices =
                                List.generate(periodTimes.length, (i) => i)
                                    .where(
                                      (i) => periodTimes[i]["type"] == "class",
                                    )
                                    .toList();
                            final initialPage = classPeriodIndices.indexOf(
                              currentPeriod,
                            );
                            return PageView.builder(
                              controller: PageController(
                                viewportFraction: 0.92,
                                initialPage: initialPage < 0 ? 0 : initialPage,
                              ),
                              itemCount: classPeriodIndices.length,
                              itemBuilder: (context, idx) {
                                final index = classPeriodIndices[idx];
                                final now = DateTime.now();
                                final periodTime =
                                    periodTimes[index]["start"] as TimeOfDay;
                                final periodDateTime = DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                  periodTime.hour,
                                  periodTime.minute,
                                );
                                final periodTimeStr = DateFormat(
                                  'hh:mm a',
                                ).format(periodDateTime);
                                final period = index < 3 ? index + 1 : index;
                                final current = classes[period];
                                final next = classes[period + 1];
                                return _buildClassCard(
                                  number: "$period",
                                  date: DateFormat(
                                    'MMM dd EEE',
                                  ).format(periodDateTime),
                                  code:
                                      current != null
                                          ? current['subjectName']
                                          : "No Class",
                                  teacher:
                                      current != null
                                          ? current['teacherName']
                                          : "-",
                                  time: periodTimeStr,
                                  upcoming:
                                      next != null ? next['subjectCode'] : "-",
                                );
                              },
                            );
                          }
                        } else {
                          // If not during class/lunch time on a weekday, or if it's a weekend,
                          // show the custom "outside class" cards.
                          return _buildOutsideClassCards();
                        }
                      },
                    ),
                  ),
                  _buildQuickActionsRow(),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                minHeight: 60.0,
                maxHeight: 60.0,
                child: Container(
                  color: const Color(0xFFE0F7FA),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: const Text(
                    "Bulletin",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00897B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // 1. Show Shimmer Loading when data is being fetched
                    if (isFeedLoading) {
                      return Padding(
                        key: ValueKey(
                          'shimmer_item_$index',
                        ), // Essential for lists
                        padding: const EdgeInsets.only(
                          bottom: 16.0,
                        ), // Spacing between shimmer items
                        child:
                            const ShimmerClassCardSkeleton(), // Your shimmer skeleton widget
                      );
                    }

                    // 2. Show Error Message if there's an error and not loading
                    if (feedErrorMessage != null) {
                      // This case should ideally only return a single error message,
                      // so ensure childCount for error state is 1.
                      return Padding(
                        key: const ValueKey(
                          'feed_error_message',
                        ), // Unique key for the error message
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: Text(
                            feedErrorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    // 3. Show "No items" message if list is empty after loading
                    if (feedItems == null || feedItems!.isEmpty) {
                      // This case should also ideally return a single "no items" message.
                      return const Padding(
                        key: ValueKey(
                          'no_feed_items_message',
                        ), // Unique key for no items message
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(child: Text('No feed items available.')),
                      );
                    }

                    // 4. Display Actual Feed Item if data is loaded and available
                    final item = feedItems![index];
                    final String user =
                        item['teacherName'] as String? ?? 'Unknown Teacher';
                    final String timeAgo = item['createdAt'] as String? ?? '';
                    final String message = item['text'] as String? ?? '';
                    final String? imageUrl =
                        (item['photoUrl'] != null && item['photoUrl'] != '')
                            ? '$baseUrl/${item['photoUrl']}'
                            : null;
                    final String? profileUrl =
                        (item['profileUrl'] != null && item['profileUrl'] != '')
                            ? '$baseUrl/${item['profileUrl']}'
                            : null;
                    final int likeCount = (item['likes'] as List?)?.length ?? 0;
                    final int commentCount =
                        (item['comments'] as List?)?.length ?? 0;

                    return FutureBuilder<String?>(
                      future:
                          TokenService.getUserName(), // Assumes TokenService is accessible
                      builder: (context, snapshot) {
                        final List<String> likes = List<String>.from(
                          item['likes'] ?? [],
                        );
                        final userName = snapshot.data ?? '';
                        final bool isLikedByMe = likes.contains(userName);
                        return Padding(
                          key: ValueKey(
                            item['id'] ?? index,
                          ), // Use item ID for unique key if available
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildFeedCard(
                            profileUrl: profileUrl,
                            // Your existing _buildFeedCard function
                            user: user,
                            timeAgo: formatFacebookStyleTime(
                              timeAgo,
                            ), // Assumes formatFacebookStyleTime is accessible
                            message: message,
                            imageUrl: imageUrl,
                            likeCount: likeCount,
                            commentCount: commentCount,
                            comments: item['comments'] ?? [],
                            feedId: item['id'] ?? '',
                            isLiked: isLikedByMe,
                          ),
                        );
                      },
                    );
                  },
                  // --- Crucial: Define childCount based on state ---
                  childCount: () {
                    if (isFeedLoading) {
                      return 5; // Show 5 shimmer items while loading. Adjust this number as needed.
                    } else if (feedErrorMessage != null ||
                        feedItems == null ||
                        feedItems!.isEmpty) {
                      return 1; // Show 1 item for error message or 'no items available' message.
                    } else {
                      return feedItems!
                          .length; // Show the actual number of feed items.
                    }
                  }(), // The `()` immediately invokes the anonymous function.
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New generic custom message card widget
  Widget _buildCustomMessageCard(String title, String message, Color color) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

    // Responsive values for layout and text
    final double iconSectionWidth =
        screenWidth * 0.2 < 80
            ? screenWidth * 0.2
            : 80; // Adjust icon section width
    final double cardHorizontalMargin = screenWidth > 600 ? 30 : 8;
    final double cardVerticalMargin = screenWidth > 600 ? 20 : 12;
    final double contentPadding = screenWidth > 600 ? 24 : 16;

    final double titleFontSize = screenWidth > 600 ? 26 : 22;
    final double messageFontSize = screenWidth > 600 ? 15 : 13;
    final double dateFontSize = screenWidth > 600 ? 14 : 12;
    final double timeFontSize = screenWidth > 600 ? 16 : 14;
    final double iconSize = screenWidth > 600 ? 45 : 40;
    final double smallIconSize = screenWidth > 600 ? 18 : 16;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: cardHorizontalMargin,
        vertical: cardVerticalMargin,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          // Dark, deep gradient for the card background
          colors: [Color(0xFF212121), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(
              0.05,
            ), // Subtle light glow for neumorphic effect
            blurRadius: 15,
            offset: const Offset(-4, -4),
            spreadRadius: 0.5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(
              0.4,
            ), // Deeper dark shadow for neumorphic effect
            blurRadius: 15,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Icon Section with dynamic color
              Container(
                width: iconSectionWidth, // Responsive width
                decoration: BoxDecoration(
                  color: color, // Use the passed color for the icon section
                  border: Border(
                    right: BorderSide(
                      color: Colors.white.withOpacity(
                        0.2,
                      ), // Brighter border for separation
                      width: 1,
                    ),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant_menu, // A clear food-related icon
                    size: iconSize, // Responsive icon size
                    color:
                        Colors
                            .black87, // Darker icon for good contrast on the warm background
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(contentPadding), // Responsive padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Date (subtle white)
                      // Text(
                      //   //DateFormat('MMM dd EEE').format(date).toUpperCase(),
                      //   style: TextStyle(
                      //     color: Colors.white.withOpacity(0.6),
                      //     fontSize: dateFontSize, // Responsive date font size
                      //     fontWeight: FontWeight.w600,
                      //     letterSpacing: 1.5,
                      //   ),
                      //),
                      SizedBox(
                        height: screenWidth > 600 ? 12 : 8,
                      ), // Responsive spacing
                      // Title with a gradient, potentially incorporating a "hungry mood" color
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback:
                            (bounds) => LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(
                                  0.7,
                                ), // Blend with a slightly transparent white
                              ],
                            ).createShader(bounds),
                        child: Text(
                          title, // Use the passed title
                          style: TextStyle(
                            fontSize:
                                titleFontSize, // Responsive title font size
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenWidth > 600 ? 16 : 12,
                      ), // Responsive spacing
                      // Time & additional icon
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: smallIconSize,
                            color: Colors.white70,
                          ), // Responsive icon size
                          SizedBox(
                            width: screenWidth > 600 ? 12 : 8,
                          ), // Responsive spacing
                          // Text(
                          //   time, // Use the passed time
                          //   style: TextStyle(
                          //     color: Colors.white,
                          //     fontSize: timeFontSize, // Responsive time font size
                          //     fontWeight: FontWeight.w500,
                          //   ),
                          // ),
                          const Spacer(),
                          Container(
                            height: 20,
                            width: 1,
                            color: Colors.white.withOpacity(0.15),
                            margin: EdgeInsets.symmetric(
                              horizontal: screenWidth > 600 ? 12 : 8,
                            ), // Responsive spacing
                          ),
                          Icon(
                            Icons
                                .directions_run, // Another food-related icon for subtle theming
                            size: smallIconSize + 2, // Slightly larger
                            color: Colors.white70,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: screenWidth > 600 ? 12 : 8,
                      ), // Responsive spacing
                      // Message (italic white)
                      Text(
                        message, // Use the passed message
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize:
                              messageFontSize, // Responsive message font size
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // New function to build different cards based on outside class time and day
  Widget _buildOutsideClassCards() {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    //final currentWeekday = now.weekday; // 1 for Monday, 7 for Sunday

    // Weekday specific logic (Monday to Friday, when not in class/lunch)
    if (_isWeekday()) {
      // Type 1 (Weekday After School): 15:30 to 21:59
      if ((currentHour == 15 && currentMinute >= 30) ||
          (currentHour > 15 && currentHour < 22)) {
        return _buildCustomMessageCard(
          "After Classes! 📚",
          "School's out for the day. Time to relax or get some homework done!",
          Colors.indigo.shade600,
        );
      }
      // Type 2 (Weekday Bed Time, including Friday 22:00 onwards): 22:00 to 05:59
      // This will catch Friday night 22:00 onwards.
      else if ((currentHour >= 22) || (currentHour >= 0 && currentHour < 6)) {
        return _buildCustomMessageCard(
          "Bed Time! 😴",
          "It's late. Get some rest for a fresh start tomorrow!",
          Colors.purple.shade800,
        );
      }
      // Type 3 (Weekday Morning): 06:00 to 08:29
      else if ((currentHour >= 6 && currentHour < 8) ||
          (currentHour == 8 && currentMinute < 30)) {
        return _buildCustomMessageCard(
          "Good Morning! ☀️",
          "Time to get ready for school. Have a great day!",
          Colors.orange.shade600,
        );
      }
      // Fallback for any other weekday time not explicitly covered (e.g., very early morning before 6:00)
      return _buildCustomMessageCard(
        "Weekday Break! ☕",
        "Enjoy your time outside of class!",
        Colors.blueGrey.shade400,
      );
    }
    // Weekend specific logic (Saturday and Sunday)
    else {
      // It's Saturday or Sunday
      // Weekend Type 2 (Bed Time - Saturday 00:00 to 05:59) - only for Saturday morning after Friday night
      // The Friday 22:00-23:59 part is covered by the weekday bed time if it's Friday.
      // So here we only care about Sat/Sun early morning.
      if (currentHour >= 0 && currentHour < 6) {
        // This covers 00:00 to 05:59 on Saturday and Sunday
        return _buildCustomMessageCard(
          "Bed Time! 😴",
          "Late night or early morning on the weekend. Get some rest!",
          Colors.purple.shade800,
        );
      }
      // Weekend Type 3 (Morning - Saturday/Sunday 06:00 to 08:29)
      else if ((currentHour >= 6 && currentHour < 8) ||
          (currentHour == 8 && currentMinute < 30)) {
        return _buildCustomMessageCard(
          "Good Morning, Weekend! ☀️",
          "Enjoy your relaxing morning!",
          Colors.lightBlue.shade600,
        );
      }
      // Weekend Type 4 (Mid-morning - Saturday/Sunday 08:30 to 11:29)
      else if ((currentHour == 8 && currentMinute >= 30) ||
          (currentHour > 8 && currentHour < 12)) {
        return _buildCustomMessageCard(
          "Weekend Vibes! 🥳",
          "Plenty of time for weekend activities!",
          Colors.teal.shade500,
        );
      }
      // Weekend Lunch Time (Saturday/Sunday 11:30 to 12:29)
      else if ((currentHour == 11 && currentMinute >= 30) ||
          (currentHour == 12 && currentMinute < 30)) {
        return _buildCustomMessageCard(
          "Weekend Lunch! 🍔",
          "Time to grab a bite and recharge!",
          Colors.deepOrange.shade400,
        );
      }
      // Weekend Type 5 (Afternoon - Saturday/Sunday 12:30 to 15:30)
      else if ((currentHour == 12 && currentMinute >= 30) ||
          (currentHour > 12 && currentHour <= 15)) {
        return _buildCustomMessageCard(
          "Weekend Afternoon! 🚶‍♀️",
          "What are your plans for the rest of the day?",
          Colors.green.shade500,
        );
      }
      // NEW: Weekend Late Afternoon/Early Evening: 15:31 to 18:59
      else if ((currentHour == 15 && currentMinute > 30) ||
          (currentHour > 15 && currentHour < 19)) {
        return _buildCustomMessageCard(
          "Evening Plans! 🌆",
          "The weekend is still going strong. What's next?",
          Colors.blueGrey.shade800,
        );
      }
      // NEW: Weekend Evening/Night: 19:00 to 21:59
      else if (currentHour >= 19 && currentHour < 22) {
        return _buildCustomMessageCard(
          "Weekend Night! 🌙",
          "Enjoy your evening entertainment!",
          Colors.deepPurple.shade700,
        );
      }
      // NEW: Weekend Late Night: 22:00 to 23:59
      else if (currentHour >= 22 && currentHour <= 23) {
        // Covers 22:00 to 23:59
        return _buildCustomMessageCard(
          "Winding Down! ✨",
          "Almost time to wrap up the weekend. Prepare for the week ahead!",
          Colors.blueGrey.shade900,
        );
      }
      // Fallback for any other Saturday/Sunday time not explicitly covered (should be minimal now)
      else {
        return _buildCustomMessageCard(
          "Relaxing Weekend! ✨",
          "Enjoy your free time!",
          Colors
              .grey
              .shade700, // Changed to a more neutral grey for general fallback
        );
      }
    }
  }

  Widget _buildClassCard({
    required String number,
    required String date,
    required String code,
    required String teacher,
    required String time,
    required String upcoming,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kCardGradientStart, kCardGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 20,
            offset: const Offset(-8, -8),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: kShadowColor.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(10, 10),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: kPrimaryDarkColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(22),
                    topLeft: Radius.circular(22),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(4, 0),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    number,
                    style: GoogleFonts.poppins(
                      fontSize: 68,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              // --- FIX START ---
              // Wrap the Padding with SingleChildScrollView to allow scrolling
              // if the content exceeds the available vertical space.
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Removed mainAxisAlignment.spaceAround as SingleChildScrollView
                  // provides infinite height, so spaceAround won't have a finite space to work with.
                  // Children will take their natural height.
                  children: [
                    // Date
                    Text(
                      date.toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Code
                    Text(
                      code,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.blueGrey.shade800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Teacher
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 18,
                          color: Colors.blueGrey.shade500,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            teacher,
                            style: GoogleFonts.lato(
                              color: Colors.blueGrey.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Time
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: Colors.blueGrey.shade500,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: GoogleFonts.lato(
                            color: Colors.blueGrey.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Upcoming Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "Upcoming: $upcoming",
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          color: Colors.blueGrey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // --- FIX END ---
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Card(
              // color: const Color.fromARGB(255, 18, 194, 194),
              color: kPrimaryDarkColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReactorAudioPage(),
                      ),
                    );
                  },
                  child: SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.all(
                        17,
                      ), // 👈 creates space around image
                      child: Image.asset('assets/images/voice_inbox.png'),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Card(
              elevation: 6,
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
                side:
                    BorderSide
                        .none, // Ensures no default border line from the Card itself
              ).copyWith(
                side: BorderSide.none,
                borderRadius: BorderRadius.circular(0),
              ),
              child: Stack(
                children: [
                  // Background Image (fills the Card's rounded shape)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/noinfomail.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Foreground content (tappable)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MailBoxHome()),
                      );
                    },
                    child: SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 65, left: 20),

                        child: const Text(
                          "Mail Box",
                          style: TextStyle(
                            color: kPrimaryDarkColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedCard({
    required String? profileUrl,
    required String user,
    required String timeAgo,
    required String message,
    required String? imageUrl,
    required int? likeCount,
    required int? commentCount,
    required List<dynamic> comments,
    required int? feedId,
    required bool isLiked,
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
                          (profileUrl != null && profileUrl.isNotEmpty)
                              ? AuthorizedImage(
                                imageUrl: profileUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              )
                              : const Icon(
                                Icons.person,
                                size: 35,
                                color: Colors.white,
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
                              if (isLiked) {
                                print("is liked");
                                final success = await ApiService.unlike(
                                  feedId!,
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
                                final success = await ApiService.like(feedId!);
                                if (success) {
                                  setState(() {
                                    final idx = feedItems?.indexWhere(
                                      (item) => item['id'] == feedId,
                                    );
                                    if (idx != null && idx >= 0) {
                                      feedItems![idx]['likes'] = List.from(
                                        feedItems![idx]['likes'] ?? [],
                                      )..add(userName);
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
                  // IconButton(
                  //   icon: const Icon(
                  //     Icons.share_rounded,
                  //     color: Colors.white70,
                  //     size: 22,
                  //   ),
                  //   onPressed: () {},
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLunchBreakCard(DateTime date, String time) {
    // Only show the lunch break card if the current period is lunch
    final now = TimeOfDay.now();
    final lunchPeriod = periodTimes.indexWhere((p) => p["type"] == "lunch");
    if (lunchPeriod == -1) return const SizedBox.shrink();
    final lunchStart = periodTimes[lunchPeriod]["start"] as TimeOfDay;
    final lunchEnd = periodTimes[lunchPeriod]["end"] as TimeOfDay;
    final afterStart =
        now.hour > lunchStart.hour ||
        (now.hour == lunchStart.hour && now.minute >= lunchStart.minute);
    final beforeEnd =
        now.hour < lunchEnd.hour ||
        (now.hour == lunchEnd.hour && now.minute <= lunchEnd.minute);
    if (!(afterStart && beforeEnd)) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // Dark, deep gradient for the card background
          colors: [Color(0xFF212121), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(
              0.05,
            ), // Subtle light glow for neumorphic effect
            blurRadius: 15,
            offset: Offset(-4, -4),
            spreadRadius: 0.5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(
              0.4,
            ), // Deeper dark shadow for neumorphic effect
            blurRadius: 15,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Icon Section with "Hungry Mood" Color
              Container(
                width: 80,
                decoration: BoxDecoration(
                  // **"Hungry Mood" color for the icon section**
                  color: Color(0xFFFFC107), // A warm, appetizing amber/orange
                  border: Border(
                    right: BorderSide(
                      color: Colors.white.withOpacity(
                        0.2,
                      ), // Brighter border for separation
                      width: 1,
                    ),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant_menu, // A clear food-related icon
                    size: 40,
                    color:
                        Colors
                            .black87, // Darker icon for good contrast on the warm background
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Date (subtle white)
                      Text(
                        DateFormat('MMM dd EEE').format(date).toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Title with a gradient, potentially incorporating a "hungry mood" color
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback:
                            (bounds) => LinearGradient(
                              // **Gradient for title, blending white with a warm accent**
                              colors: [
                                Colors.white,
                                Color(0xFFFFE082),
                              ], // White to a warm, soft yellow
                            ).createShader(bounds),
                        child: Text(
                          'Lunch Feast', // Updated title
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      // Time & additional icon
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 16, color: Colors.white70),
                          SizedBox(width: 8),
                          Text(
                            time,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          Container(
                            height: 20,
                            width: 1,
                            color: Colors.white.withOpacity(0.15),
                            margin: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          Icon(
                            Icons
                                .directions_run, // Another food-related icon for subtle theming
                            size: 18,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Message (italic white)
                      Text(
                        'Time to satisfy those cravings!', // Updated message
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
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
