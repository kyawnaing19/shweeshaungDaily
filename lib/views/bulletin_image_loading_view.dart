// shimmer_loading_placeholder.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shweeshaungdaily/colors.dart';

class ShimmerLoadingPlaceholder extends StatelessWidget {
  final double height;
  final double width;
  final Color baseColor;
  final Color highlightColor;
  final Color backgroundColor; // Color of the underlying container

  const ShimmerLoadingPlaceholder({
    super.key,
    required this.height,
    required this.width,
    this.baseColor = const Color(0xFFE0E0E0), // Default light grey
    this.highlightColor = kPrimaryColor, // Default even lighter grey
    this.backgroundColor =
        Colors.white, // Default white background for the block
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(seconds: 5),
      child: Container(
        height: height,
        width: width,
        color: backgroundColor, // This is the shimmering block itself
      ),
    );
  }
}
