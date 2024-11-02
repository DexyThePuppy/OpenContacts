import 'dart:convert';

class ContactTab {
  final String id;
  final String label;
  final String? icon;
  final List<String>? userIds;

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
}

class ContactTabsConfig {
  final List<ContactTab> tabs;

  ContactTabsConfig({required this.tabs});

  factory ContactTabsConfig.fromJson(String jsonString) {
    final json = jsonDecode(jsonString);
    return ContactTabsConfig(
      tabs: (json['tabs'] as List)
          .map((tab) => ContactTab.fromJson(tab))
          .toList(),
    );
  }
} 