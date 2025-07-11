import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/services/authorized_http_service.dart';
import 'package:shweeshaungdaily/utils/image_cache.dart';

class AuthorizedImage extends StatefulWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;

  const AuthorizedImage({
    super.key,
    required this.imageUrl,
    required this.height,
    required this.width,
    this.fit = BoxFit.cover,
  });

  @override
  State<AuthorizedImage> createState() => _AuthorizedImageState();
}

class _AuthorizedImageState extends State<AuthorizedImage> {
  Uint8List? _imageBytes;
  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      // Try loading from cache first
      final cached = await ImageCacheManager.getCachedImage(widget.imageUrl);
      if (cached != null) {
        if (!mounted) return;
        setState(() {
          _imageBytes = cached;
          _isLoading = false;
        });
        return;
      }

      final uri = Uri.parse(widget.imageUrl);
      final response = await AuthorizedHttpService.sendAuthorizedRequest(
        uri,
        method: 'GET',
      );

      if (response != null && response.statusCode == 200) {
        _imageBytes = response.bodyBytes;
        await ImageCacheManager.cacheImage(widget.imageUrl, _imageBytes!);
        if (!mounted) return;
        setState(() {
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
        'assets/images/tpo.jpg',
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
      );
    }

    if (_isLoading || _imageBytes == null) {
      return Container(
        height: widget.height,
        width: widget.width,
        color: Colors.grey.shade200,
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF00897B)),
        ),
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
