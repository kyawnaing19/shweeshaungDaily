import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ImageCacheManager {
  static Future<String> _getCacheDirPath() async {
    final dir = await getTemporaryDirectory();
    final cacheDir = Directory('${dir.path}/image_cache');
    if (!(await cacheDir.exists())) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

 static String _generateFileName(String url) {
  final hash = md5.convert(utf8.encode(url)).toString();
  if (url.startsWith('https://shweeshaung.mooo.com/tfeedphoto/story')) {
    return 'story_$hash';
  }
  return 'feed_$hash';
}


  static Future<File> _getFile(String url) async {
    final path = await _getCacheDirPath();
    final fileName = _generateFileName(url);
    return File('$path/$fileName.jpg');
  }

  static Future<Uint8List?> getCachedImage(String url) async {
    final file = await _getFile(url);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  }

  static Future<void> cacheImage(String url, Uint8List bytes) async {
    final file = await _getFile(url);
    await file.writeAsBytes(bytes, flush: true);
  }

  static Future<void> deleteImage(String url) async {
    final file = await _getFile(url);
    if (await file.exists()) {
      await file.delete();
    }
  }


  static Future<void> clearUnusedStoryImages(Set<String> activeStoryUrls) async {
  final dirPath = await _getCacheDirPath();
  final dir = Directory(dirPath);
  final files = dir.listSync();

  final activeStoryHashes = activeStoryUrls
      .map((url) => _generateFileName(url))
      .where((name) => name.startsWith('story_')) // keep only feed hashes
      .toSet();

  for (final file in files) {
    if (file is File) {
      final fileName = file.path.split('/').last.split('.jpg').first;

      // Only delete if it's a feed image and not active
      if (fileName.startsWith('story_') && !activeStoryHashes.contains(fileName)) {
        await file.delete();
      }
    }
  }
}

static Future<void> clearUnusedFeedImages(Set<String> activeStoryUrls) async {
  final dirPath = await _getCacheDirPath();
  final dir = Directory(dirPath);
  final files = dir.listSync();

  final activeStoryHashes = activeStoryUrls
      .map((url) => _generateFileName(url))
      .where((name) => name.startsWith('feed_')) // keep only feed hashes
      .toSet();

  for (final file in files) {
    if (file is File) {
      final fileName = file.path.split('/').last.split('.jpg').first;

      // Only delete if it's a feed image and not active
      if (fileName.startsWith('feed_') && !activeStoryHashes.contains(fileName)) {
        await file.delete();
      }
    }
  }
}

}
