import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; // Import the CurvedNavigationBar

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final PageController pageController;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: selectedIndex,
      height: 70.0, // Adjust height as needed
      items: const <Widget>[
        Icon(Icons.home, size: 30),
        Icon(Icons.description, size: 30),
        Icon(Icons.calendar_today, size: 30),
        Icon(Icons.person, size: 30),
      ],
      color: const Color.fromARGB(
        255,
        38,
        207,
        219,
      ), // Color of the navigation bar itself
      buttonBackgroundColor:
          Colors.teal, // Color of the selected item's background circle
      backgroundColor:
          Colors
              .transparent, // Background color behind the bar (usually the scaffold's background)
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 600),
      onTap: (index) {
        pageController.jumpToPage(index); // Control the PageView
        onItemTapped(index); // Update state in parent
      },
      letIndexChange: (index) => true, // Allows changing index
    );
  }
}