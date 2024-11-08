class UserProfile {
  final String iconUrl;
  final bool? isPinned;

  UserProfile({required this.iconUrl, this.isPinned});

  factory UserProfile.empty() => UserProfile(iconUrl: "");

  factory UserProfile.fromMap(Map? map) {
    return UserProfile(
      iconUrl: map?["iconUrl"] ?? "",
      isPinned: map?["isPinned"],
    );
  }

  Map toMap() {
    return {
      "iconUrl": iconUrl,
      "isPinned": isPinned,
    };
  }

  UserProfile copyWith({
    bool? isPinned,
  }) {
    return UserProfile(
      isPinned: isPinned ?? this.isPinned,
      iconUrl: this.iconUrl,
    );
  }
}