import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

/// Small helper to resolve storage paths/gs:// URIs to download URLs.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final Map<String, String> _cache = {};
  // Keep logs debug-only
  final bool enableDebugLogs = false;

  Future<String?> resolveUrl(String ref) async {
    final key = ref.trim();
  if (key.isEmpty) return null;

  if (_cache.containsKey(key)) return _cache[key];

    try {
  if (kDebugMode && enableDebugLogs) print('StorageService.resolveUrl: resolving [$key]');
      if (key.startsWith('http')) {
  if (kDebugMode && enableDebugLogs) print('StorageService.resolveUrl: already http url');
        _cache[key] = key;
        return key;
      }

      String path = key;
      if (key.startsWith('gs://')) {
        final parts = key.replaceFirst('gs://', '').split('/');
        if (parts.length > 1) path = parts.sublist(1).join('/');
        else path = parts.join('/');
  if (kDebugMode && enableDebugLogs) print('StorageService.resolveUrl: converted gs:// to path [$path]');
      }

      if (path.startsWith('/')) path = path.substring(1);

  if (kDebugMode && enableDebugLogs) print('StorageService.resolveUrl: using storage path [$path]');
  final url = await FirebaseStorage.instance.ref().child(path).getDownloadURL();
  if (kDebugMode && enableDebugLogs) print('StorageService.resolveUrl: got download url [$url]');
      _cache[key] = url;
      return url;
    } catch (e) {
  // Do not throw, return null so UI can fallback
  if (kDebugMode && enableDebugLogs) print('StorageService.resolveUrl failed for [$ref]: $e');
      return null;
    }
  }
}
