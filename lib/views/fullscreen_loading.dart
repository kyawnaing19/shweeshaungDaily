import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shweeshaungdaily/colors.dart';
// Assuming colors.dart defines kBackgroundColor
// import 'package:shweeshaungdaily/colors.dart';

// Define kBackgroundColor here for completeness
const Color kBackgroundColor = Color(0xFFE0F7FA);

class FullScreenShimmerSkeleton extends StatelessWidget {
  const FullScreenShimmerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Set the full background color of the widget
      color: kBackgroundColor,
      child: Shimmer.fromColors(
        baseColor: kAccentColor,
        // ignore: deprecated_member_use
        highlightColor: kAccentColor.withOpacity(
          0.8,
        ), // A slightly different shade for the shimmer effect
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60),
              // Profile image placeholder
              // Container(
              //   width: double.infinity, // Makes the container full-width
              //   padding: const EdgeInsets.all(16), // 🔹 Inner spacing
              //   decoration: BoxDecoration(
              //     color: const Color.fromARGB(
              //       255,
              //       193,
              //       242,
              //       249,
              //     ), // 🔹 Background color
              //     borderRadius: BorderRadius.circular(12), // 🔹 Rounded corners
              //   ),
              //   child: 
              Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: const BoxDecoration(
                          color: kBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      // You can add more children here if needed
                    ],
                  ),
                ),
              // ),
              SizedBox(height: 10),
              // User details placeholders
              Container(
                width: 150,
                height: 16,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
              ),
              Container(
                width: 100,
                height: 14,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 20),
              ),
              // Info card placeholder
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 20),
              ),
              // Album title placeholder
              Container(
                width: 100,
                height: 20,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 15),
              ),
              // Grid of album items placeholders
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 4, // Show a few placeholder cards
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
