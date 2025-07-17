import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/services/authorize_image.dart';

class ImageFullView extends StatelessWidget {
  final String imageUrl;

  const ImageFullView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.black, // Dark background for better image display
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // White back button
      ),
      backgroundColor: Colors.black, // Ensure the background is black
      body: Center(
        child: Hero(
          // Use Hero for a smooth transition animation
          tag: imageUrl, // A unique tag for the animation
          child: AuthorizedImage(
            imageUrl: imageUrl,
            // Adjust width and height as needed for full view, or use BoxFit.contain
            width: double.infinity,
            height: MediaQuery.of(context).size.height, // Take full height
            fit: BoxFit.contain, // Ensure the entire image is visible
          ),
        ),
      ),
    );
  }
}
