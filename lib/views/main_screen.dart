import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/views/bottomNavBar.dart';
import 'Home.dart';
import 'package:shweeshaungdaily/views/note_list_view.dart';
import 'package:shweeshaungdaily/views/profile_router.dart';
import 'package:shweeshaungdaily/views/timetablepage.dart';

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
    _pageController.jumpToPage(index); // 👈 this line is missing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Optional: prevent swipe
        children: const [
          HomeScreenPage(), // Your pages (aa.dart, bb.dart, etc.)
          NotePage(),
          TimeTablePage(),
          ProfileRouterPage(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        pageController: _pageController,
      ),
    );
  }
}
