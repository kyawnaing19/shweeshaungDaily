import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/views/bottomNavBar.dart';
import 'package:shweeshaungdaily/views/teacherprofile.dart';
import 'Home.dart';
import 'note/note_list_view.dart';
import 'profile_router.dart';
import 'timetablepage.dart';
import 'package:shweeshaungdaily/widget/settings_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

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

  /// 👇 Dynamic AppBar based on selectedIndex
  AppBar? _buildAppBar() {
    switch (_selectedIndex) {
      case 0:
        return AppBar(
          backgroundColor: kAccentColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Home',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      case 1:
        return AppBar(
          backgroundColor: kAccentColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Note',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      case 2:
        return AppBar(
          backgroundColor: kAccentColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Timetable',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
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
            Builder(
              builder:
                  (context) => IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      final RenderBox overlay =
                          Overlay.of(context).context.findRenderObject()
                              as RenderBox;
                      final Offset topRight = overlay.localToGlobal(
                        Offset(overlay.size.width, 0),
                      );
                      showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          topRight.dx - 200, // 200 = width of SettingsCard
                          topRight.dy + kToolbarHeight + 8, // below appbar
                          10, // right margin
                          0,
                        ),
                        items: [
                          PopupMenuItem(
                            enabled: false,
                            padding: EdgeInsets.zero,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 250),
                              child: SettingsCard(),
                            ),
                          ),
                        ],
                        elevation: 8,
                        color: Colors.transparent,
                      );
                    },
                  ),
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
        appBar: _buildAppBar(), // 👈 Dynamic AppBar inserted here
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
                _pageController.jumpToPage(3); // Jump to ProfileRouterPage tab
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
