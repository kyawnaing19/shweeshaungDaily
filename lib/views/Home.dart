import 'dart:async';
import 'dart:convert'; // Add this for JSON encoding/decoding
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shweeshaungdaily/NoteListPage.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/views/bottomNavBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shweeshaungdaily/views/note_list_view.dart';
import 'package:shweeshaungdaily/views/profile_router.dart';
import 'package:shweeshaungdaily/views/timetablepage.dart'; // Add this for SharedPreferences
import 'package:shweeshaungdaily/utils/route_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // State for the selected tab in the bottom navigation

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    if (index == 1) {
      Navigator.of(context).pushReplacement(fadeRoute(const TimeTablePage()));
    }
    if (index == 2) {
      Navigator.of(context).pushReplacement(fadeRoute(const HomePage()));
    }
    if (index == 3) {
      Navigator.of(
        context,
      ).pushReplacement(fadeRoute(const ProfileRouterPage()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  late List<Map<String, String?>> feedItems;
  Map<String, Map<int, dynamic>>? timetableData;
  bool isLoading = true;
  String? errorMessage;

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
    feedItems = [
      {
        "user": "Daw Aye Mya ",
        "timeAgo": "6 min ago",
        "message": "Min ga lar bar ka lay toh",
        "imageUrl":
            "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Bagan_sunset.jpg/640px-Bagan_sunset.jpg",
      },
      {
        "user": "Daw Aye Mya Kyi",
        "timeAgo": "8 min ago",
        "message": "This is a post with only text and no image.",
        "imageUrl": null,
      },
      {
        "user": "Daw Aye Mya Kyi",
        "timeAgo": "15 min ago",
        "message": "This post has an image.",
        "imageUrl":
            "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Bagan_sunset.jpg/640px-Bagan_sunset.jpg",
      },
      {
        "user": "Daw Aye Mya Kyi",
        "timeAgo": "20 min ago",
        "message": "This is another post with only text.",
        "imageUrl": "",
      },
    ];
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

  Timer? _lunchTimer;

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
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchTimetable();
    final currentPeriod = _getCurrentPeriodIndex();
    if (currentPeriod >= 0 && currentPeriod < periodTimes.length) {
      _pageController.jumpToPage(currentPeriod);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && timetableData == null) {
      // Only show loading on first load
      // return Scaffold(
      //   backgroundColor: const Color(0xFFE0F7FA),
      //   body: const Center(child: CircularProgressIndicator()),
      // );
      return Scaffold(
        body: Container(
          color: kAccentColor, // The greenish-blue color from your image
          child: const Center(
            child: Column(
              // Use Column to arrange widgets vertically
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Shwee Shaung Daily',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontFamily:
                        'Pacifico', // Ensure this font is added to your pubspec.yaml
                  ),
                ),
                SizedBox(
                  height: 100,
                ), // Space between "Shwee Shaung Daily" and "Loading..."
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    // You can also apply a fontFamily here if desired, e.g., fontFamily: 'Pacifico',
                  ),
                ),
                SizedBox(
                  height: 20,
                ), // Space between "Loading..." and the indicator
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ), // White loading indicator
                ),
              ],
            ),
          ),
        ),
      );
    }
    // if (errorMessage != null) {
    //   return Scaffold(
    //     backgroundColor: const Color(0xFFE0F7FA),
    //     body: Center(child: Text('Error: $errorMessage')),
    //   );
    // }

    final today = getCurrentDayName();
    final classes = timetableData?[today] ?? {};

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: const Text(
          "Shwee Shaung Daily",
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, size: 26),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_rounded, size: 26),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
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
                    // ...existing code...
                    child: Builder(
                      builder: (context) {
                        if (isOutsideClassTime()) {
                          return _buildCustomMessageCards();
                        }
                        final currentPeriod = _getCurrentPeriodIndex();
                        final periodType = periodTimes[currentPeriod]["type"];
                        if (periodType == "lunch") {
                          // ...existing lunch card code...
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
                          // ...existing class PageView code...
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
                    // ...existing code...,
                  ),
                  const SizedBox(height: 10),
                  _buildQuickActionsRow(),
                  const SizedBox(height: 32),
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
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = feedItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildFeedCard(
                      user: item['user']!,
                      timeAgo: item['timeAgo']!,
                      message: item['message']!,
                      imageUrl: item['imageUrl'],
                    ),
                  );
                }, childCount: feedItems.length),
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
            child: _buildQuickActionButton(
              context,
              Icons.event_rounded,
              "Events",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const TimeTablePage();
                    },
                  ),
                );
              },
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
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    height: 180,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: const Color(0xFF00897B),
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder:
                        (context, error, stackTrace) => Image.asset(
                          'assets/images/tpo.jpg',
                          fit: BoxFit.cover,
                          height: 180,
                          width: double.infinity,
                        ),
                  ),
                ),
              ),

            if (!hasImage) const SizedBox(height: 12),

            // Action Bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.favorite_border_rounded,
                      color: Colors.white70,
                      size: 22,
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '24',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Colors.white70,
                      size: 22,
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '5',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
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
