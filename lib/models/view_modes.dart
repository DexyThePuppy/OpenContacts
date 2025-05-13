import 'package:flutter/material.dart';

enum ViewMode {
  list,
  tiles,
  icons;

  IconData get icon {
    return switch (this) {
      ViewMode.list => Icons.list,
      ViewMode.tiles => Icons.grid_view,
      ViewMode.icons => Icons.apps,
    };
  }

  String get label {
    return switch (this) {
      ViewMode.list => "List",
      ViewMode.tiles => "Tiles",
      ViewMode.icons => "Icons",
    };
  }
}
extension ViewModeProperties on ViewMode {
  IconData get icon {
    switch (this) {
      case ViewMode.list:
        return Icons.list;
      case ViewMode.tiles:
        return Icons.grid_view;
      case ViewMode.icons:
        return Icons.apps;
    }
  }
}