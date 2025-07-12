import 'dart:async';
import 'dart:convert'; // Add this for JSON encoding/decoding
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:shweeshaungdaily/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shweeshaungdaily/services/authorize_image.dart';
import 'package:shweeshaungdaily/services/token_service.dart';
import 'package:shweeshaungdaily/utils/image_cache.dart';
import 'package:shweeshaungdaily/views/note_list_view.dart';
import 'package:shweeshaungdaily/views/timetablepage.dart'; // Add this for SharedPreferences
import 'package:shweeshaungdaily/views/comment_section.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({super.key});
  // Add this for base URL

  @override
  State<HomeScreenPage> createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreenPage> {
  final String baseUrl = ApiService.base;
  List<Map<String, dynamic>>? feedItems = [];
  bool isFeedLoading = true;
  String? feedErrorMessage;
  Map<String, Map<int, dynamic>>? timetableData;
  bool isLoading = true;
  String? errorMessage;

  // Audio player state
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  Future<void> _playAudio() async {
    // Placeholder audio URL (public domain short mp3)
    const url = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
    await _audioPlayer.play(UrlSource(url));
    setState(() {
      _isPlaying = true;
    });
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
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
    _loadTimetableFromPrefs();

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

      await ImageCacheManager.clearUnusedImages(imageUrls);
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
    super.dispose();
  }

  // ...existing code...
  bool isOutsideClassTime() {
    final now = TimeOfDay.now();
    final start = const TimeOfDay(hour: 8, minute: 30);
    final end = const TimeOfDay(hour: 15, minute: 30);

    final afterStart =
        now.hour > start.hour ||
        (now.hour == start.hour && now.minute >= start.minute);
    final beforeEnd =
        now.hour < end.hour ||
        (now.hour == end.hour && now.minute <= end.minute);

    return !(afterStart && beforeEnd);
  }
  // ...existing code...

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
                        if (isOutsideClassTime()) {
                          return _buildCustomMessageCards();
                        }
                        final currentPeriod = _getCurrentPeriodIndex();
                        final periodType = periodTimes[currentPeriod]["type"];
                        if (periodType == "lunch") {
                          final now = DateTime.now();
                          final periodTime =
                              periodTimes[currentPeriod]["start"] as TimeOfDay;
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
                    "Latest Feed",
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
                    if (isFeedLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(child: CircularProgressIndicator()),
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
                            timeAgo: timeAgo,
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
    );
  }

  // ...existing code...
  Widget _buildCustomMessageCards() {
    return PageView.builder(
      controller: PageController(viewportFraction: 0.96),
      itemCount: customMessageImages.length,
      itemBuilder: (context, idx) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              customMessageImages[idx],
              width: 350, // Set your desired fixed width
              height: 220, // Set your desired fixed height
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
  // ...existing code...

  Widget _buildClassCard({
    required String number,
    required String date,
    required String code,
    required String teacher,
    required String time,
    required String upcoming,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kCardGradientStart, kCardGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kShadowColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                decoration: const BoxDecoration(
                  color: kPrimaryDarkColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    topLeft: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: GoogleFonts.rowdies(
                      fontSize: 62,
                      color: Colors.white,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      code,
                      style: GoogleFonts.rowdies(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          teacher,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          time,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Upcoming: $upcoming",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
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
    );
  }

  Widget _buildQuickActionsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: _buildQuickActionButton(
              context,
              Icons.menu_book_rounded,
              "Note",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const NotePage();
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow, size: 32, color: Colors.teal),
                      onPressed: () {
                        if (_isPlaying) {
                          _stopAudio();
                        } else {
                          _playAudio();
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    Text(_isPlaying ? 'Playing...' : 'Stopped', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTapAction,
  ) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: const Color(0xFF00897B),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTapAction,
        child: Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),

            // Conditionally display the image section
            if (hasImage)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AuthorizedImage(
                    imageUrl: imageUrl,
                    height: 180,
                    width: double.infinity,
                  ),
                ),
              ),

            if (!hasImage) const SizedBox(height: 12),

            // Action Bar
            Padding(
              padding: const EdgeInsets.all(12),
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
                                  });
                                }
                              } else {
                                final success = await ApiService.like(feedId!);
                                if (success) {
                                  setState(() {
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
                  IconButton(
                    icon: const Icon(
                      Icons.share_rounded,
                      color: Colors.white70,
                      size: 22,
                    ),
                    onPressed: () {},
                  ),
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
        gradient: const LinearGradient(
          colors: [kLunchGradientStart, kLunchGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                decoration: const BoxDecoration(
                  color: kLunchIconBg,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    topLeft: Radius.circular(16),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.lunch_dining, size: 48, color: kWhite),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('MMM dd EEE').format(date),
                      style: const TextStyle(
                        color: kLunchText,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Lunch Break',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: kLunchText,
                        letterSpacing: 0.5,
                      ),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: kLunchText,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          time,
                          style: const TextStyle(
                            color: kLunchText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Enjoy your meal and take a break!',
                      style: TextStyle(fontSize: 14, color: kLunchTextAccent),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
