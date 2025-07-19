import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/services/authorized_http_service.dart';
import 'package:shweeshaungdaily/views/bulletin_image_loading_view.dart';

class AuthorizedNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;

  const AuthorizedNetworkImage({
    super.key,
    required this.imageUrl,
    required this.height,
    required this.width,
    this.fit = BoxFit.cover,
  });

  @override
  State<AuthorizedNetworkImage> createState() => _AuthorizedNetworkImageState();
}

class _AuthorizedNetworkImageState extends State<AuthorizedNetworkImage> {
  Uint8List? _imageBytes;
  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchImage();
  }

  Future<void> _fetchImage() async {
    try {
      final uri = Uri.parse(widget.imageUrl);
      final response = await AuthorizedHttpService.sendAuthorizedRequest(
        uri,
        method: 'GET',
      );

      if (response != null && response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _imageBytes = response.bodyBytes;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Image.asset(
        'assets/images/download.jpeg',
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
      );
    }

    if (_isLoading || _imageBytes == null) {
      return ShimmerLoadingPlaceholder(
        height: widget.height,
        width: widget.width,
      );
    }

    return Image.memory(
      _imageBytes!,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
    );
  }
}
