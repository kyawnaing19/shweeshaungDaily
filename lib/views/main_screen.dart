import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/miniApp/mini_app_widget.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/views/bottomNavBar.dart';
import 'package:shweeshaungdaily/views/person_search.dart';
import 'package:shweeshaungdaily/views/signReg/landing.dart';
import 'Home.dart';
import 'note/note_list_view.dart';
import 'profile_router.dart';
import 'timetablepage.dart';
import 'package:shweeshaungdaily/widget/notification_icon.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  int _unreadCount = 0; // 👈 store notification count

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int? currentPage = _pageController.page?.round();
      if (currentPage != null && currentPage != _selectedIndex) {
        setState(() {
          _selectedIndex = currentPage;
        });
      }
    });

    _fetchUnreadCount(); // 👈 fetch unread notifications
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final count = await ApiService.getUnreadNotificationCount();
      setState(() {
        _unreadCount = count;
      });
    } catch (e) {
      print('Error fetching unread notification count: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      _fetchUnreadCount(); // 👈 refresh when returning to Home tab
    }

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex > 0) {
      setState(() {
        _selectedIndex -= 1;
        _pageController.jumpToPage(_selectedIndex);
      });
      return false;
    }
    return true;
  }

  AppBar? _buildAppBar() {
    switch (_selectedIndex) {
      case 0:
        return AppBar(
          backgroundColor: kAccentColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Image.asset('assets/icons/45.png', height: 180),
          titleSpacing: -15.0,
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FacebookSearchPage()),
                );
              },
            ),
            NotificationIcon(
              context: context,
              unreadCount: _unreadCount, // 👈 dynamic count
            ),
          ],
        );
      case 1:
        return AppBar(
          backgroundColor: kAccentColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Image.asset('assets/icons/45.png', height: 180),
          titleSpacing: -15.0,
          centerTitle: false,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 25.0),
              child: Text(
                'Note',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      case 2:
        return AppBar(
          backgroundColor: kAccentColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Image.asset('assets/icons/45.png', height: 180),
          titleSpacing: -15.0,
          centerTitle: false,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 25.0),
              child: Text(
                'Timetable',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      case 3:
        return AppBar(
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
          actions: [
            IconButton(
              padding: const EdgeInsets.only(right: 20),
              icon: const Icon(Icons.logout_outlined, color: Colors.white),
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text(
                        'Are you sure you want to log out?\nPlease backup your notes!'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  final success = await ApiService.logout();
                  if (success == true) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LandingPage()),
                      (Route<dynamic> route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logout Failed')),
                    );
                  }
                }
              },
            ),
          ],
        );
      default:
        return AppBar(title: const Text('ShweeShaung Daily'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: PageView(
          controller: _pageController,
          children: [
            const HomeScreenPage(),
            NotePage(
              onBack: () {
                _onItemTapped(0);
              },
            ),
            TimeTablePage(
              onBack: () {
                _onItemTapped(1);
              },
            ),
            ProfileRouterPage(
              onBack: () => _onItemTapped(2),
              onGoToProfileTab: () {
                _pageController.jumpToPage(3);
              },
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
          pageController: _pageController,
        ),
      ),
    );
  }
}
