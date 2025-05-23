import 'package:intl/intl.dart';
import 'package:open_contacts/config.dart';
import 'package:open_contacts/crypto_helper.dart';
import 'package:open_contacts/models/session.dart';
import 'package:open_contacts/models/session_metadata.dart';
import 'package:open_contacts/models/users/online_status.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:open_contacts/badges_db.dart' as badges_db;

enum UserSessionType {
  unknown,
  graphicalClient,
  chatClient,
  headless,
  bot;

  factory UserSessionType.fromString(String? text) {
    return UserSessionType.values.firstWhere(
      (element) => element.name.toLowerCase() == text?.toLowerCase(),
      orElse: () => UserSessionType.unknown,
    );
  }
}

class UserStatus {
  final String userId;
  final OnlineStatus onlineStatus;
  final DateTime lastStatusChange;
  final DateTime lastPresenceTimestamp;
  final String userSessionId;
  final int currentSessionIndex;
  final List<SessionMetadata> sessions;
  final String appVersion;
  final String outputDevice;
  final bool isMobile;
  final bool isPresent;
  final String compatibilityHash;
  final String hashSalt;
  final UserSessionType sessionType;
  final List<Session> decodedSessions;
  final Color? appVersionColor;
  final String worldName;
  final String location;
  final bool? isHost;
  final List<badges_db.Badge> badges;

  const UserStatus({
    required this.userId,
    required this.onlineStatus,
    required this.lastStatusChange,
    required this.lastPresenceTimestamp,
    required this.userSessionId,
    required this.currentSessionIndex,
    required this.sessions,
    required this.appVersion,
    required this.outputDevice,
    required this.isMobile,
    required this.isPresent,
    required this.compatibilityHash,
    required this.hashSalt,
    required this.sessionType,
    this.decodedSessions = const [],
    this.appVersionColor,
    this.worldName = '',
    this.location = '',
    this.isHost,
    this.badges = const [],
  });

  factory UserStatus.initial() => UserStatus.empty().copyWith(
        compatibilityHash: Config.latestCompatHash,
        onlineStatus: OnlineStatus.Online,
        hashSalt: CryptoHelper.cryptoToken(),
        outputDevice: "Unknown",
        userSessionId: const Uuid().v4().toString(),
        sessionType: UserSessionType.chatClient,
        isPresent: true,
        appVersionColor: Colors.green,
        badges: const [],
      );

  factory UserStatus.empty() => UserStatus(
        userId: "",
        onlineStatus: OnlineStatus.Offline,
        lastStatusChange: DateTime.now(),
        lastPresenceTimestamp: DateTime.now(),
        userSessionId: "",
        currentSessionIndex: -1,
        sessions: [],
        appVersion: "",
        outputDevice: "Unknown",
        isMobile: false,
        isPresent: false,
        compatibilityHash: "",
        hashSalt: "",
        sessionType: UserSessionType.unknown,
        decodedSessions: const [],
        appVersionColor: null,
        worldName: '',
        location: '',
        isHost: false,
        badges: const [],
      );

  factory UserStatus.fromMap(Map map) {
    final statusString = map["onlineStatus"].toString();
    final status = OnlineStatus.fromString(statusString);

    // Get badges from status and profile if available
    final List<String> badgeTags =
        (map["badges"] as List? ?? []).cast<String>();
    
    // Get additional badges from profile if available
    final userProfile = map["profile"] as Map?;
    final List<String> profileBadgeTags = userProfile != null
        ? (userProfile["displayBadges"] as List? ?? []).cast<String>()
        : [];
    
    // Combine badges from status and profile
    final Set<String> allBadgeTags = {...badgeTags, ...profileBadgeTags};
    
    final List<badges_db.Badge> badges =
        badges_db.BadgesDB.getBadgesForUser(allBadgeTags.toList());

    return UserStatus(
      userId: map["userId"] ?? "",
      onlineStatus: status,
      lastStatusChange:
          DateTime.tryParse(map["lastStatusChange"] ?? "") ?? DateTime.now(),
      lastPresenceTimestamp:
          DateTime.tryParse(map["lastPresenceTimestamp"] ?? "") ??
              DateTime.now(),
      userSessionId: map["userSessionId"] ?? "",
      isPresent: map["isPresent"] ?? false,
      currentSessionIndex: map["currentSessionIndex"] ?? -1,
      sessions: (map["sessions"] as List? ?? [])
          .map((e) => SessionMetadata.fromMap(e))
          .toList(),
      appVersion: map["appVersion"] ?? "",
      outputDevice: map["outputDevice"] ?? "Unknown",
      isMobile: map["isMobile"] ?? false,
      compatibilityHash: map["compatibilityHash"] ?? "",
      hashSalt: map["hashSalt"] ?? "",
      sessionType: UserSessionType.fromString(map["sessionType"]),
      decodedSessions: const [],
      appVersionColor: _tryParseColor(map["appVersionColor"]),
      worldName: map["worldName"] ?? '',
      location: map["location"] ?? '',
      isHost: map["isHost"] ?? false,
      badges: badges,
    );
  }

  static Color? _tryParseColor(dynamic value) {
    if (value == null) return null;
    try {
      if (value is String && value.startsWith('#')) {
        return Color(int.parse('FF${value.substring(1)}', radix: 16));
      } else if (value is int) {
        return Color(value);
      }
    } catch (e) {
      print('*Confused puppy noises* Failed to parse color: $value');
    }
    return null;
  }

  Map toMap({bool shallow = false}) {
    return {
      "userId": userId,
      "onlineStatus": onlineStatus.index,
      "lastStatusChange": lastStatusChange.toIso8601String(),
      "isPresent": isPresent,
      "lastPresenceTimestamp": lastPresenceTimestamp.toIso8601String(),
      "userSessionId": userSessionId,
      "currentSessionIndex": currentSessionIndex,
      "sessions": shallow
          ? []
          : sessions
              .map(
                (e) => e.toMap(),
              )
              .toList(),
      "appVersion": appVersion,
      "outputDevice": outputDevice,
      "isMobile": isMobile,
      "compatibilityHash": compatibilityHash,
      "sessionType": toBeginningOfSentenceCase(sessionType.name),
      "appVersionColor": appVersionColor?.value,
      "worldName": worldName,
      "location": location,
      "isHost": isHost,
      "badges": badges.map((b) => b.name.toLowerCase()).toList(),
    };
  }

  UserStatus copyWith({
    String? userId,
    OnlineStatus? onlineStatus,
    DateTime? lastStatusChange,
    DateTime? lastPresenceTimestamp,
    bool? isPresent,
    String? userSessionId,
    int? currentSessionIndex,
    List<SessionMetadata>? sessions,
    String? appVersion,
    String? outputDevice,
    bool? isMobile,
    String? compatibilityHash,
    String? hashSalt,
    UserSessionType? sessionType,
    List<Session>? decodedSessions,
    Color? appVersionColor,
    String? worldName,
    String? location,
    bool? isHost,
    List<badges_db.Badge>? badges,
  }) =>
      UserStatus(
        userId: userId ?? this.userId,
        onlineStatus: onlineStatus ?? this.onlineStatus,
        lastStatusChange: lastStatusChange ?? this.lastStatusChange,
        lastPresenceTimestamp:
            lastPresenceTimestamp ?? this.lastPresenceTimestamp,
        isPresent: isPresent ?? this.isPresent,
        userSessionId: userSessionId ?? this.userSessionId,
        currentSessionIndex: currentSessionIndex ?? this.currentSessionIndex,
        sessions: sessions ?? this.sessions,
        appVersion: appVersion ?? this.appVersion,
        outputDevice: outputDevice ?? this.outputDevice,
        isMobile: isMobile ?? this.isMobile,
        compatibilityHash: compatibilityHash ?? this.compatibilityHash,
        hashSalt: hashSalt ?? this.hashSalt,
        sessionType: sessionType ?? this.sessionType,
        decodedSessions: decodedSessions ?? this.decodedSessions,
        appVersionColor: appVersionColor ?? this.appVersionColor,
        worldName: worldName ?? this.worldName,
        location: location ?? this.location,
        isHost: isHost ?? this.isHost,
        badges: badges ?? this.badges,
      );
}
