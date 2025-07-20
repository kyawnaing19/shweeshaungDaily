import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shweeshaungdaily/colors.dart';

// Placeholder colors - replace with your actual kCardGradientStart, kCardGradientEnd, etc.

/// A widget that displays a skeleton loading animation for a single class card.
class ShimmerClassCardSkeleton extends StatelessWidget {
  const ShimmerClassCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!, // Base color of the shimmer effect
      highlightColor:
          Colors.grey[100]!, // Highlight color of the shimmer effect
      child: Container(
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
              // Left section skeleton
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        kPrimaryDarkColor, // Placeholder color for the dark section
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
                    child: Container(
                      width: 50, // Placeholder for the large number
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white, // Shimmer will apply here
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              // Right section skeleton
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(25, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date skeleton
                      Container(
                        width: 80,
                        height: 12,
                        color: Colors.white, // Shimmer will apply here
                      ),
                      const SizedBox(height: 6),
                      // Code skeleton
                      Container(
                        width: 150,
                        height: 15,
                        color: Colors.white, // Shimmer will apply here
                      ),
                      const SizedBox(height: 12),
                      // Teacher skeleton
                      Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            color: Colors.white, // Icon placeholder
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 100,
                            height: 14,
                            color: Colors.white, // Teacher name placeholder
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Time skeleton
                      Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            color: Colors.white, // Icon placeholder
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 70,
                            height: 14,
                            color: Colors.white, // Time placeholder
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Upcoming Tag skeleton
                      Container(
                        width: 120,
                        height: 25,
                        decoration: BoxDecoration(
                          color: Colors.white, // Tag placeholder
                          borderRadius: BorderRadius.circular(15),
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
