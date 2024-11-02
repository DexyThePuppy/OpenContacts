import 'package:flutter/material.dart';

enum ViewMode {
  list,
  details,
  tiles,
  icons;

  IconData get icon {
    return switch (this) {
      ViewMode.list => Icons.list,
      ViewMode.details => Icons.view_agenda,
      ViewMode.tiles => Icons.grid_view,
      ViewMode.icons => Icons.apps,
    };
  }

  String get label {
    return switch (this) {
      ViewMode.list => "List",
      ViewMode.details => "Details",
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
      case ViewMode.details:
        return Icons.view_agenda;
      case ViewMode.tiles:
        return Icons.grid_view;
      case ViewMode.icons:
        return Icons.apps;
    }
  }
}