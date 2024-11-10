import 'package:open_contacts/config.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:html/parser.dart' as htmlparser;
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';

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

  static Widget imageWidget(String? resdb) {
    final imageUrl = resdbToHttp(resdb);
    return flutter.Image.network(
      imageUrl,
    );
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
