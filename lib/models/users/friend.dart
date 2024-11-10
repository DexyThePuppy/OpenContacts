import 'package:open_contacts/auxiliary.dart';
import 'package:open_contacts/models/users/friend_status.dart';
import 'package:open_contacts/models/users/online_status.dart';
import 'package:open_contacts/models/users/user_profile.dart';
import 'package:open_contacts/models/users/user_status.dart';
import 'package:open_contacts/clients/api_client.dart';
import 'package:open_contacts/apis/user_api.dart';

class Friend implements Comparable {
  static const _emptyId = "-1";
  static const _resoniteBotId = "U-Resonite";
  final String id;
  final String username;
  final String ownerId;
  final UserStatus userStatus;
  final UserProfile userProfile;
  final FriendStatus contactStatus;
  final DateTime latestMessageTime;
  final List<String> categories;
  final DateTime registrationDate;
  final List<SupporterMetadata>? supporterMetadata;

  const Friend({
    required this.id,
    required this.username,
    required this.ownerId,
    required this.userStatus,
    required this.userProfile,
    required this.contactStatus,
    required this.latestMessageTime,
    required this.registrationDate,
    this.categories = const [],
    this.supporterMetadata,
  });

  bool get isHeadless => userStatus.sessionType == UserSessionType.headless;

  bool get isBot =>
      userStatus.sessionType == UserSessionType.bot || id == _resoniteBotId;

  bool get isOffline =>
      (userStatus.onlineStatus == OnlineStatus.Offline ||
          userStatus.onlineStatus == OnlineStatus.Invisible) &&
      !isBot &&
      !isHeadless;

  bool get isOnline => !isOffline;

  bool get isPinned => userProfile.isPinned ?? false;

  factory Friend.fromMap(Map map) {
    var userStatus = map["userStatus"] == null
        ? UserStatus.empty()
        : UserStatus.fromMap(map["userStatus"]);

    // Get registration date from the user data
    DateTime registrationDate;
    try {
      registrationDate =
          DateTime.tryParse(map["registrationDate"] ?? "") ?? DateTimeX.epoch;
    } catch (e) {
      print('Error parsing registration date: $e');
      registrationDate = DateTimeX.epoch;
    }

    return Friend(
      id: map["id"] ?? "",
      username: map["contactUsername"] ?? map["username"] ?? "",
      ownerId: map["ownerId"] ?? map["id"] ?? "",
      userStatus: map["id"] == _resoniteBotId
          ? userStatus.copyWith(onlineStatus: OnlineStatus.Online)
          : userStatus,
      userProfile: UserProfile.fromMap(map["profile"]),
      contactStatus: FriendStatus.fromString(map["contactStatus"] ?? ""),
      latestMessageTime: map["latestMessageTime"] == null
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.parse(map["latestMessageTime"]),
      registrationDate: registrationDate,
      categories: List<String>.from(map["categories"] ?? []),
      supporterMetadata:
          List<SupporterMetadata>.from(map["supporterMetadata"] ?? []),
    );
  }

  static Friend? fromMapOrNull(Map? map) {
    if (map == null) return null;
    return Friend.fromMap(map);
  }

  factory Friend.empty() {
    return Friend(
      id: _emptyId,
      username: "",
      ownerId: "",
      userStatus: UserStatus.empty(),
      userProfile: UserProfile.empty(),
      contactStatus: FriendStatus.none,
      latestMessageTime: DateTimeX.epoch,
      registrationDate: DateTimeX.epoch,
      categories: const [],
      supporterMetadata: const [],
    );
  }

  bool get isEmpty => id == _emptyId;

  static Future<Friend> fromMapWithRegistrationDate(
      Map map, ApiClient client) async {
    Friend friend = Friend.fromMap(map);
    if (friend.registrationDate == DateTimeX.epoch) {
      try {
        final registrationDate =
            await UserApi.getRegistrationDate(client, friend.id);
        return friend.copyWith(registrationDate: registrationDate);
      } catch (e) {
        print('Error fetching registration date: $e');
        return friend;
      }
    }
    return friend;
  }

  Friend copyWith({
    String? id,
    String? username,
    String? ownerId,
    UserStatus? userStatus,
    UserProfile? userProfile,
    FriendStatus? contactStatus,
    DateTime? latestMessageTime,
    DateTime? registrationDate,
  }) {
    return Friend(
      id: id ?? this.id,
      username: username ?? this.username,
      ownerId: ownerId ?? this.ownerId,
      userStatus: userStatus ?? this.userStatus,
      userProfile: userProfile ?? this.userProfile,
      contactStatus: contactStatus ?? this.contactStatus,
      latestMessageTime: latestMessageTime ?? this.latestMessageTime,
      registrationDate: registrationDate ?? this.registrationDate,
      categories: this.categories,
      supporterMetadata: this.supporterMetadata,
    );
  }

  Map toMap({bool shallow = false}) {
    return {
      "id": id,
      "contactUsername": username,
      "ownerId": ownerId,
      "userStatus": userStatus.toMap(shallow: shallow),
      "profile": userProfile.toMap(),
      "contactStatus": contactStatus.name,
      "latestMessageTime": latestMessageTime.toIso8601String(),
      "registrationDate": registrationDate.toIso8601String(),
      "categories": categories,
      "supporterMetadata": supporterMetadata,
    };
  }

  @override
  int compareTo(covariant Friend other) {
    return username.compareTo(other.username);
  }
}
