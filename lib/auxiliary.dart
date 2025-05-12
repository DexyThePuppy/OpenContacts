import 'dart:io';

import 'package:open_contacts/config.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:html/parser.dart' as htmlparser;
import 'package:flutter/material.dart';
import 'package:open_contacts/cache/user_cache_manager.dart';

class Aux {
  static String resdbToHttp(String? resdb) {
    if (resdb == null || resdb.isEmpty) {
      return "https://i2.wp.com/vdostavka.ru/wp-content/uploads/2019/05/no-avatar.png";
    }

    // Handle invalid URLs or malformed strings
    try {
      if (resdb.startsWith("http")) {
        Uri.parse(resdb); // Validate URL format
        return resdb;
      }

      // Remove resdb:/// prefix and any file extension
      final cleanPath = resdb
          .replaceFirst('resdb:///', '')
          .replaceAll(RegExp(r'\..*$'), '') // Remove any file extension
          .trim();

      if (cleanPath.isEmpty) {
        return "https://i2.wp.com/vdostavka.ru/wp-content/uploads/2019/05/no-avatar.png";
      }

      // For other formats, use the standard URL
      return "${Config.skyfrostAssetsUrl}/$cleanPath";
    } catch (e) {
      return "https://i2.wp.com/vdostavka.ru/wp-content/uploads/2019/05/no-avatar.png";
    }
  }

  /// Get a URL for a user's profile image - synchronous version.
  /// Note: This doesn't check cache - use getProfileImageUrlAsync when possible.
  static String getProfileImageUrl(dynamic userProfile) {
    return resdbToHttp(userProfile?.iconUrl);
  }

  /// Get a URL for a user's profile image - async version that checks cache first.
  /// If [userId] is provided, attempts to load from local cache first.
  static Future<String> getProfileImageUrlAsync(dynamic userProfile, {String? userId}) async {
    // Try cache first if userId is provided
    if (userId != null) {
      // 1. Try local icon file
      final iconFile = await UserCacheManager.cachedIconFile(userId);
      if (iconFile != null) {
        // Return as file:// URL
        return iconFile.uri.toString();
      }
      
      // 2. Try cached URL from JSON
      final cached = await UserCacheManager.cachedIconUrl(userId);
      if (cached != null && cached.isNotEmpty) {
        return resdbToHttp(cached);
      }
    }
    
    // Fall back to regular URL
    return resdbToHttp(userProfile?.iconUrl);
  }

  /// Asynchronous version that checks cache first if [userId] is provided.
  /// Returns a FileImage or NetworkImage source for the avatar.
  static Future<ImageProvider> getProfileImageProvider(dynamic userProfile, {String? userId}) async {
    if (userId != null) {
      final source = await UserCacheManager.getCachedIconSource(userId);
      if (source != null) {
        if (source.containsKey('file')) {
          return FileImage(source['file'] as File);
        } else if (source.containsKey('url')) {
          return NetworkImage(resdbToHttp(source['url'] as String));
        }
      }
    }
    
    // Fall back to regular URL
    return NetworkImage(resdbToHttp(userProfile?.iconUrl));
  }

  static Widget imageWidget(String? resdb) {
    final imageUrl = resdbToHttp(resdb);
    return flutter.Image.network(
      imageUrl,
    );
  }
  
  /// Creates an image widget that attempts to use cached version first
  /// if userId is provided.
  static Widget cachedImageWidget(String? resdb, {String? userId}) {
    if (userId == null) {
      return imageWidget(resdb);
    }
    
    return FutureBuilder<ImageProvider>(
      future: getProfileImageProvider(null, userId: userId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image(image: snapshot.data!);
        } else {
          // Fall back to network image while loading
          return imageWidget(resdb);
        }
      },
    );
  }

  static int colorToInterger(Color color) {
    return (255 & 0xff) << 24 |
        (color.r.toInt() & 0xff) << 16 |
        (color.g.toInt() & 0xff) << 8 |
        (color.b.toInt() & 0xff) << 0;
  }

  static Color apllyOpacity(Color color, int opacity) {
    return color.withAlpha(opacity);
  }
}

extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = <Id>{};
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}

extension StringX on String {
  String stripHtml() {
    final document = htmlparser.parse(this);
    return htmlparser.parse(document.body?.text).documentElement?.text ?? "";
  }

  // This won't be accurate since userIds can't contain certain characters that usernames can
  // but it's fine for just having a name to display
  String stripUid() => startsWith("U-") ? substring(2) : this;

  String? get asNullable => isEmpty ? null : this;
}

extension Format on Duration {
  String format() {
    final hh = (inHours).toString().padLeft(2, '0');
    final mm = (inMinutes % 60).toString().padLeft(2, '0');
    final ss = (inSeconds % 60).toString().padLeft(2, '0');
    if (inHours == 0) {
      return "$mm:$ss";
    } else {
      return "$hh:$mm:$ss";
    }
  }
}

extension DateTimeX on DateTime {
  static DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0);
  static DateTime one = DateTime(1);
}

extension ColorX on flutter.Color {
  flutter.Color invert() {
    final r = 255 - red;
    final g = 255 - green;
    final b = 255 - blue;

    return flutter.Color.fromARGB((opacity * 255).round(), r, g, b);
  }
}
