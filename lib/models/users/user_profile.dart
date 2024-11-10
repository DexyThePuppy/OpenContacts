class UserProfile {
  final String iconUrl;
  final List<String> displayBadges;
  final List<SupporterMetadata>? supporterMetadata;
  final bool? isPinned;

  const UserProfile({
    required this.iconUrl,
    required this.displayBadges,
    this.supporterMetadata,
    this.isPinned,
  });

  factory UserProfile.empty() => UserProfile(iconUrl: "", displayBadges: []);

  factory UserProfile.fromMap(Map? map) {
    return UserProfile(
      iconUrl: map?["iconUrl"] ?? "",
      displayBadges: List.from(map?["displayBadges"] ?? []),
      supporterMetadata: map?["supporterMetadata"] != null
          ? List.from(map?["supporterMetadata"]).map((metadata) {
              return SupporterMetadata(
                type: metadata["type"] ?? "",
                isActiveSupporter: metadata["isActiveSupporter"] ?? false,
              );
            }).toList()
          : null,
      isPinned: map?["isPinned"] ?? false,
    );
  }

  Map toMap() {
    return {
      "iconUrl": iconUrl,
      "displayBadges": displayBadges,
      "supporterMetadata": supporterMetadata?.map((metadata) {
        return {
          "type": metadata.type,
          "isActiveSupporter": metadata.isActiveSupporter,
        };
      }).toList(),
      "isPinned": isPinned,
    };
  }

  UserProfile copyWith({
    String? iconUrl,
    List<String>? displayBadges,
    List<SupporterMetadata>? supporterMetadata,
    bool? isPinned,
  }) {
    return UserProfile(
      iconUrl: iconUrl ?? this.iconUrl,
      displayBadges: displayBadges ?? this.displayBadges,
      supporterMetadata: supporterMetadata ?? this.supporterMetadata,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  bool get isTeamMember => displayBadges.contains('team');
  bool get isModerator => displayBadges.contains('moderator');
  bool get isPatreonSupporter =>
      supporterMetadata
          ?.any((m) => m.type == 'patreon' && m.isActiveSupporter) ??
      false;
}

class SupporterMetadata {
  final String type;
  final bool isActiveSupporter;

  const SupporterMetadata({
    required this.type,
    required this.isActiveSupporter,
  });
}
