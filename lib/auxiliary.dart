import 'package:open_contacts/config.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:html/parser.dart' as htmlparser;

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
      
      final filename = p.basenameWithoutExtension(resdb).trim();
      if (filename.isEmpty) {
        return "https://i2.wp.com/vdostavka.ru/wp-content/uploads/2019/05/no-avatar.png";
      }
      
      // Check file extension
      final extension = p.extension(resdb).toLowerCase();
      if (extension == '.exr') {
        // For EXR files, we'll need to convert them using image_v3
        // The URL will still point to the EXR file, but our image loading widget
        // will need to handle the conversion
        return "${Config.skyfrostAssetsUrl}/$filename$extension";
      }
      
      // For other formats (including .webp), use the standard URL
      return "${Config.skyfrostAssetsUrl}/$filename";
    } catch (e) {
      return "https://i2.wp.com/vdostavka.ru/wp-content/uploads/2019/05/no-avatar.png";
    }
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

extension ColorX on Color {
  Color invert() {
    final r = 255 - red;
    final g = 255 - green;
    final b = 255 - blue;

    return Color.fromARGB((opacity * 255).round(), r, g, b);
  }
}