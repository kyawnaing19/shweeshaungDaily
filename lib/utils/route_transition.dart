import 'package:flutter/material.dart';

PageRouteBuilder fadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );
      return FadeTransition(opacity: curvedAnimation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 500),
  );
}