import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:open_contacts/apis/user_api.dart';
import 'package:open_contacts/clients/api_client.dart';
import 'package:open_contacts/auxiliary.dart';
import 'package:collection/collection.dart';
import 'package:open_contacts/models/users/user.dart';
import 'package:image/image.dart' as img; // Added for EXR to PNG conversion

class UserCacheManager {
  // Keeps track of ongoing cache operations to avoid duplicate network traffic.
  static final Map<String, Future<void>> _ongoing = {};

  static Future<void> ensureCached(ApiClient apiClient, String userId, String? iconUrl) {
    if (_ongoing.containsKey(userId)) {
      return _ongoing[userId]!;
    }
    final future = _cache(apiClient, userId, iconUrl);
    _ongoing[userId] = future;
    return future;
  }

  static Future<void> _cache(ApiClient apiClient, String userId, String? iconUrl) async {
    try {
      final userDir = await _resolveUserDir(userId);

      // We need user info to determine filename
      late User user;
      try {
        user = await UserApi.getUser(apiClient, userId: userId);
      } catch (e) {
        // If user fetch fails we fallback to generic filenames
        user = User(id: userId, username: userId, registrationDate: DateTime.now());
      }

      final sanitized = _sanitizeFilename(user.username);

      // Cache the user JSON --------------------------------------------------
      final jsonFile = File(p.join(userDir.path, '$sanitized.json'));
      if (!await jsonFile.exists()) {
        try {
          await jsonFile.writeAsString(jsonEncode(user.toMap()));
        } catch (_) {}
      }

      // Cache the user icon --------------------------------------------------
      if (iconUrl != null && iconUrl.isNotEmpty) {
        String originalExtension = '';
        try {
          // Try to get extension from the original iconUrl (e.g., resdb:///hash.exr)
          final originalUri = Uri.parse(iconUrl);
          originalExtension = p.extension(originalUri.path).toLowerCase();
        } catch (e) {
          // If parsing original iconUrl fails, this is a fallback.
          // For resdb URLs, this path might not have an extension.
        }

        final resolvedUrl = Aux.resdbToHttp(iconUrl); // Convert resdb to http/https
        final downloadUri = Uri.tryParse(resolvedUrl);

        if (downloadUri != null) {
          if (originalExtension == '.exr') {
            final originalExrFile = File(p.join(userDir.path, '${sanitized}_original.exr'));
            if (!await originalExrFile.exists()) {
              try {
                final response = await http.get(downloadUri);
                if (response.statusCode == 200) {
                  await originalExrFile.writeAsBytes(response.bodyBytes);
                }
              } catch (_) {
                // Failed to download/save original EXR
              }
            }

            final pngIconFile = File(p.join(userDir.path, '$sanitized.png'));
            if (await originalExrFile.exists() && !await pngIconFile.exists()) {
              try {
                final exrBytes = await originalExrFile.readAsBytes();
                final image = img.decodeExr(exrBytes);
                if (image != null) {
                  final pngBytes = img.encodePng(image);
                  await pngIconFile.writeAsBytes(pngBytes);
                } else {
                  // Failed to decode EXR
                }
              } catch (e) {
                // Failed to convert EXR to PNG
              }
            }
          } else {
            // For non-EXR files, or if original extension couldn't be determined reliably as .exr
            // Use extension from resolved download URI path, or default to .png
            final ext = p.extension(downloadUri.path).isEmpty ? '.png' : p.extension(downloadUri.path);
            final iconFile = File(p.join(userDir.path, '$sanitized$ext'));
            if (!await iconFile.exists()) {
              try {
                final response = await http.get(downloadUri);
                if (response.statusCode == 200) {
                  await iconFile.writeAsBytes(response.bodyBytes);
                }
              } catch (_) {
                // Failed to download/save other icon type
              }
            }
          }
        }
      }
    } finally {
      _ongoing.remove(userId);
    }
  }

  static Future<Directory> _resolveUserDir(String userId) async {
    Directory base;
    try {
      final exeDir = File(Platform.resolvedExecutable).parent;
      base = Directory(p.join(exeDir.path, '.cache', 'users'));
    } catch (_) {
      final support = await getApplicationSupportDirectory();
      base = Directory(p.join(support.path, '.cache', 'users'));
    }
    final userDir = Directory(p.join(base.path, userId));
    if (!await userDir.exists()) {
      await userDir.create(recursive: true);
    }
    return userDir;
  }

  /// Returns the local cached icon [File] if available, otherwise null.
  /// Prioritizes a '.png' version (especially if an '.exr' was converted)
  /// and avoids returning '_original.exr' files directly.
  static Future<File?> cachedIconFile(String userId) async {
    final dir = await _resolveUserDir(userId);
    final filesInDir = dir.listSync().whereType<File>().toList();

    // Try to determine the sanitized username base name from a cached JSON file.
    // The JSON file is named '$sanitized.json'.
    String? sanitizedBaseName;
    final jsonFile = filesInDir.firstWhereOrNull((f) => f.path.endsWith('.json'));
    if (jsonFile != null) {
        sanitizedBaseName = p.basenameWithoutExtension(jsonFile.path);
    }

    if (sanitizedBaseName != null) {
        // 1. Prioritize <sanitized_username>.png (expected output for EXR conversion or standard PNG)
        final preferredPngFile = File(p.join(dir.path, '$sanitizedBaseName.png'));
        if (await preferredPngFile.exists()) {
            return preferredPngFile;
        }
    }

    // 2. Fallback: look for any other standard image file (png, jpg, webp)
    //    that is NOT an '_original.exr' file.
    //    This handles cases where the icon was not EXR, or if the specific <sanitized_username>.png wasn't found.
    final fallbackFile = filesInDir.firstWhereOrNull((f) {
        final filePath = f.path;
        if (filePath.endsWith('_original.exr')) {
            return false; // Explicitly exclude original EXR files
        }
        return RegExp(r'\.(png|jpe?g|webp)$', caseSensitive: false).hasMatch(filePath);
    });

    return fallbackFile != null && await fallbackFile.exists() ? fallbackFile : null;
  }

  /// Reads the cached user JSON and returns the `iconUrl` if present.
  static Future<String?> cachedIconUrl(String userId) async {
    try {
      final dir = await _resolveUserDir(userId);
      // pick first json file
      final jsonFile = dir
          .listSync()
          .whereType<File>()
          .firstWhereOrNull((f) => f.path.endsWith('.json'));
      if (jsonFile == null) return null;
      final data = jsonDecode(await jsonFile.readAsString());
      final profile = data['profile'];
      if (profile is Map && profile.containsKey('iconUrl')) {
        return profile['iconUrl'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Returns icon source information, either as a file or URL
  static Future<Map<String, dynamic>?> getCachedIconSource(String userId) async {
    try {
      // First try local file
      final iconFile = await cachedIconFile(userId);
      if (iconFile != null && await iconFile.exists()) {
        return {'file': iconFile};
      }

      // Then try URL in JSON
      final iconUrl = await cachedIconUrl(userId);
      if (iconUrl != null && iconUrl.isNotEmpty) {
        return {'url': iconUrl};
      }
    } catch (_) {}
    return null;
  }

  static String _sanitizeFilename(String input) {
    return input.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }
}