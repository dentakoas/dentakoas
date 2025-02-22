import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:denta_koas/src/utils/local_storage/storage_utility.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImageCacheService {
  final TLocalStorage _storage = TLocalStorage();
  static const String _urlMapKey = 'image_url_map';

  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  // Generate unique filename from URL
  String _generateFileName(String url) {
    final bytes = utf8.encode(url);
    final hash = md5.convert(bytes);
    return '$hash.jpg'; // Menambahkan ekstensi untuk clarity
  }

  // Get cache directory
  Future<Directory> get _cacheDir async {
    final dir = await getTemporaryDirectory();
    final cacheDir = Directory('${dir.path}/image_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  // Check if URL is already cached and return file if exists
  Future<File?> checkUrlCache(String url) async {
    final urlMap = _storage.readData<String>(_urlMapKey);
    if (urlMap != null) {
      final map = json.decode(urlMap) as Map<String, dynamic>;
      final filePath = map[url];
      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          return file;
        }
      }
    }
    return null;
  }

  // Download and cache single image
  Future<File?> downloadAndCacheImage(String url) async {
    try {
      // Check if already cached
      final cachedFile = await checkUrlCache(url);
      if (cachedFile != null) {
        return cachedFile;
      }

      // Download image
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Save file
        final fileName = _generateFileName(url);
        final cacheDir = await _cacheDir;
        final file = File('${cacheDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        // Update URL map
        final urlMap = _storage.readData<String>(_urlMapKey);
        Map<String, dynamic> map = {};
        if (urlMap != null) {
          map = json.decode(urlMap);
        }
        map[url] = file.path;
        await _storage.saveData(_urlMapKey, json.encode(map));

        return file;
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
    return null;
  }

  // Get or download multiple images
  Future<List<File>> getOrDownloadImages(List<String> urls) async {
    final List<File> files = [];

    for (final url in urls) {
      // Try to get from cache first
      final cachedFile = await checkUrlCache(url);
      if (cachedFile != null) {
        files.add(cachedFile);
        continue;
      }

      // Download if not cached
      final downloadedFile = await downloadAndCacheImage(url);
      if (downloadedFile != null) {
        files.add(downloadedFile);
      }
    }

    return files;
  }

  // Clear cache
  Future<void> clearCache() async {
    final cacheDir = await _cacheDir;
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
    await _storage.removeData(_urlMapKey);
  }
}
