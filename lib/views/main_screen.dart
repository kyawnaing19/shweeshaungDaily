import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/views/bottomNavBar.dart';
import 'Home.dart';
import 'note_list_view.dart';
import 'profile_router.dart';
import 'timetablepage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex > 0) {
      setState(() {
        _selectedIndex -= 1;
        _pageController.jumpToPage(_selectedIndex);
      });
      return false; // Don't exit the app
    }
    return true; // Exit app if on index 0
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // 👈 Intercepts back press
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const HomeScreenPage(),
            NotePage(
              onBack: () {
                _onItemTapped(
                  0,
                ); // ⬅️ Go to Home tab when back arrow is pressed
              },
            ),

            TimeTablePage(
              onBack: () {
                _onItemTapped(
                  1,
                ); // ⬅️ Go to Home tab when back arrow is pressed
              },
            ),
            ProfileRouterPage(
              onBack: () {
                _onItemTapped(
                  2,
                ); // ⬅️ Go to Home tab when back arrow is pressed
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
