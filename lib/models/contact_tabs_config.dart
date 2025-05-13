import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_contacts/models/users/friend.dart';
import 'package:provider/provider.dart';

class ContactTab {
  final String id;
  String label;
  String? icon;
  List<String>? userIds;

  ContactTab({
    required this.id,
    required this.label,
    this.icon,
    this.userIds,
  });

  factory ContactTab.fromJson(Map<String, dynamic> json) {
    return ContactTab(
      id: json['id'],
      label: json['label'],
      icon: json['icon'],
      userIds: (json['userIds'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Widget buildTabWidget(BuildContext context) {
    return DragTarget<Friend>(
      onWillAcceptWithDetails: (details) {
        return !(userIds?.contains(details.data.id) ?? false);
      },
      onAcceptWithDetails: (details) {
        userIds ??= [];
        userIds!.add(details.data.id);
        Provider.of<ContactTabsConfig>(context, listen: false)
            .addUserToTab(details.data.id, id);
      },
      builder: (context, candidateData, rejectedData) {
        final isDraggingOver = candidateData.isNotEmpty;
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isDraggingOver
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
            color:
                isDraggingOver ? colorScheme.primary.withAlpha(38) : null,
          ),
          child: Tab(
            icon: icon != null
                ? Icon(
                    IconData(int.tryParse(icon!) ?? 0xe3af,
                        fontFamily: 'MaterialIcons'),
                    color: isDraggingOver ? colorScheme.primary : null,
                  )
                : null,
            text: label,
          ),
        );
      },
    );
  }

  ContactTab copyWith({
    String? id,
    String? label,
    String? icon,
    List<String>? userIds,
  }) {
    return ContactTab(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      userIds: userIds ?? this.userIds,
    );
  }
}

class ContactTabsConfig extends ChangeNotifier {
  final List<ContactTab> tabs;
  final String configPath = 'assets/config/contact_tabs.json';
  int _selectedTabIndex = 0; // Track the selected tab index

  ContactTabsConfig({required this.tabs});

  factory ContactTabsConfig.fromJson(String jsonString) {
    final json = jsonDecode(jsonString);
    return ContactTabsConfig(
      tabs: (json['tabs'] as List)
          .map((tab) => ContactTab.fromJson(tab))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tabs': tabs
          .map((tab) => {
                'id': tab.id,
                'label': tab.label,
                'icon': tab.icon,
                'userIds': tab.userIds ?? [],
              })
          .toList(),
    };
  }

  Future<void> saveConfig() async {
    try {
      final jsonString = jsonEncode(toJson());
      await File(configPath).writeAsString(jsonString);
    } catch (e) {
      debugPrint('Error saving contact tabs config: $e');
    }
  }

  void addUserToTab(String userId, String tabId) {
    final tab = tabs.firstWhere((tab) => tab.id == tabId);
    tab.userIds ??= [];
    if (!tab.userIds!.contains(userId)) {
      tab.userIds!.add(userId);
      saveConfig();
      notifyListeners();
    }
  }

  void removeUserFromTab(String userId, String tabId) {
    final tab = tabs.firstWhere((tab) => tab.id == tabId);
    if (tab.userIds?.remove(userId) ?? false) {
      saveConfig();
      notifyListeners();
    }
  }

  bool isUserInTab(String userId, String tabId) {
    final tab = tabs.firstWhere((tab) => tab.id == tabId);
    return tab.userIds?.contains(userId) ?? false;
  }

  void addTab({required String label, String? icon}) {
    final newId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    tabs.add(ContactTab(
      id: newId,
      label: label,
      icon: icon,
      userIds: [],
    ));
    saveConfig();
    notifyListeners();
  }

  void removeTab(String tabId) {
    if (tabId == 'all' || tabId == 'blocked') return;

    tabs.removeWhere((tab) => tab.id == tabId);
    saveConfig();
    notifyListeners();
  }

  void updateTabLabel(String tabId, String newLabel) {
    final tabIndex = tabs.indexWhere((tab) => tab.id == tabId);
    if (tabIndex != -1) {
      tabs[tabIndex] = tabs[tabIndex].copyWith(label: newLabel);
      notifyListeners();
      // Save in the background
      Future(() => saveConfig());
    }
  }

  void addNewTab(String label) {
    final newId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    // Direct update to ensure immediate UI refresh
    tabs.add(ContactTab(
      id: newId,
      label: label,
      icon: null,
      userIds: [],
    ));
    // Notify listeners immediately
    notifyListeners();
    // Save in the background
    Future(() => saveConfig());
  }

  void updateCategoryLabel(String tabId, String newLabel) {
    updateTabLabel(tabId, newLabel);
  }

  void updateTabIcon(String tabId, String iconCode) {
    final tabIndex = tabs.indexWhere((tab) => tab.id == tabId);
    if (tabIndex != -1) {
      // Direct update to ensure immediate UI refresh
      tabs[tabIndex].icon = iconCode;
      // Notify listeners immediately
      notifyListeners();
      // Save in the background
      Future(() => saveConfig());
    }
  }

  void updateSelectedTab(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  int get selectedTabIndex => _selectedTabIndex;
}
