import 'package:flutter/material.dart';

enum OnlineStatus {
  Offline,
  Invisible,
  Away,
  Busy,
  Online,
  Sociable;

  static final List<Color> _colors = [
    Colors.transparent,
    Colors.grey,
    Colors.yellow,
    Colors.red,
    Colors.green,
    Colors.blue,
  ];

  Color color(BuildContext context) =>
      this == OnlineStatus.Offline || this == OnlineStatus.Invisible
          ? Theme.of(context).colorScheme.onSecondaryContainer.withAlpha(150)
          : _colors[index];

  factory OnlineStatus.fromString(String? text) {
    return OnlineStatus.values.firstWhere(
      (element) => element.name.toLowerCase() == text?.toLowerCase(),
      orElse: () => OnlineStatus.Online,
    );
  }

  int compareTo(OnlineStatus other) {
    if (this == other) return 0;
    if (this == OnlineStatus.Sociable) return -1;
    if (other == OnlineStatus.Sociable) return 1;
    if (this == OnlineStatus.Online) return -1;
    if (other == OnlineStatus.Online) return 1;
    if (this == OnlineStatus.Away) return -1;
    if (other == OnlineStatus.Away) return 1;
    if (this == OnlineStatus.Busy) return -1;
    if (other == OnlineStatus.Busy) return 1;
    return 0;
  }
}
