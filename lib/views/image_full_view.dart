import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/services/authorize_image.dart';

class ImageFullView extends StatefulWidget {
  final String imageUrl;

  const ImageFullView({super.key, required this.imageUrl});

  @override
  State<ImageFullView> createState() => _ImageFullViewState();
}

class _ImageFullViewState extends State<ImageFullView>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ), // Duration for the reset animation
    )..addListener(() {
      if (_animation != null) {
        _transformationController.value = _animation!.value;
      }
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _resetImage() {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(), // Reset to identity matrix (initial state)
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward(from: 0); // Start the animation
  }

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
          tag: widget.imageUrl, // A unique tag for the animation
          child: InteractiveViewer(
            transformationController: _transformationController,
            // Only enable panning if the image is currently zoomed in
            panEnabled:
                _transformationController.value.getMaxScaleOnAxis() > 1.0,
            boundaryMargin: const EdgeInsets.all(
              double.infinity,
            ), // Allow image to be dragged anywhere
            minScale: 1.0, // Minimum scale (initial size)
            maxScale: 4.0, // Maximum zoom level
            onInteractionEnd: (details) {
              // If there are less than 2 pointers (i.e., 0 or 1 finger on the screen)
              if (details.pointerCount < 2) {
                // Always reset to initial state when two-finger action is no longer active
                _resetImage();
              }
              // Update panEnabled state after interaction to reflect current zoom level
              // This `setState` will trigger a rebuild and update `panEnabled` based on the new scale
              setState(() {});
            },
            child: AuthorizedImage(
              imageUrl: widget.imageUrl,
              width: double.infinity,
              height: MediaQuery.of(context).size.height, // Take full height
              fit: BoxFit.contain, // Ensure the entire image is visible
            ),
          ),
        ),
      ),
    );
  }
}
