import 'package:open_contacts/auxiliary.dart';
import 'package:open_contacts/models/users/entitlement.dart';
import 'package:open_contacts/models/users/user_profile.dart';

class PersonalProfile {
  final String id;
  final String username;
  final String email;
  final DateTime? publicBanExpiration;
  final String? publicBanType;
  final bool twoFactor;
  final UserProfile userProfile;
  final List<Entitlement> entitlements;
  final List<SupporterMetadata> supporterMetadata;
  final DateTime registrationDate;

  PersonalProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.publicBanExpiration,
    required this.publicBanType,
    required this.twoFactor,
    required this.userProfile,
    required this.entitlements,
    required this.supporterMetadata,
    required this.registrationDate,
  });

  factory PersonalProfile.fromMap(Map<String, dynamic> map) {
    return PersonalProfile(
      id: map["id"]?.toString() ?? "",
      username: map["username"] ?? "",
      email: map["email"] ?? "",
      publicBanExpiration: DateTime.tryParse(map["publicBanExpiration"] ?? ""),
      publicBanType: map["publicBanType"],
      twoFactor: map["2fa_login"] ?? false,
      userProfile: UserProfile.fromMap(map["profile"]),
      entitlements: ((map["entitlements"] ?? []) as List).map((e) => Entitlement.fromMap(e)).toList(),
      supporterMetadata: ((map["supporterMetadata"] ?? []) as List).map((e) => SupporterMetadata.fromMap(e)).toList(),
      registrationDate: DateTime.tryParse(map['registrationDate'] ?? '') ?? DateTimeX.epoch,
    );
  }

  bool get isPatreonSupporter =>
      supporterMetadata.whereType<PatreonSupporter>().any((element) => element.isActiveSupporter);
}

class StorageQuota {
  final String id;
  final int usedBytes;
  final int quotaBytes;
  final int fullQuotaBytes;

  StorageQuota({
    required this.id,
    required this.usedBytes,
    required this.quotaBytes,
    required this.fullQuotaBytes,
  });

  factory StorageQuota.fromMap(Map map) {
    return StorageQuota(
      id: map["id"]?.toString() ?? "",
      usedBytes: map["usedBytes"] ?? 0,
      quotaBytes: map["quotaBytes"] ?? 0,
      fullQuotaBytes: map["fullQuotaBytes"] ?? 0,
    );
  }
}

class SupporterMetadata {
  SupporterMetadata();

  factory SupporterMetadata.fromMap(Map map) {
    final type = map["\$type"];
    return switch (type) {
      "patreon" => PatreonSupporter.fromMap(map),
      _ => SupporterMetadata(),
    };
  }
}

class PatreonSupporter extends SupporterMetadata {
  final bool isActiveSupporter;
  final int totalSupportMonths;
  final int totalSupportCents;
  final int lastTierCents;
  final int highestTierCents;
  final int lowestTierCents;
  final DateTime firstSupportTimestamp;
  final DateTime lastSupportTimestamp;

  PatreonSupporter({
    required this.isActiveSupporter,
    required this.totalSupportMonths,
    required this.totalSupportCents,
    required this.lastTierCents,
    required this.highestTierCents,
    required this.lowestTierCents,
    required this.firstSupportTimestamp,
    required this.lastSupportTimestamp,
  });

  factory PatreonSupporter.fromMap(Map map) {
    return PatreonSupporter(
      isActiveSupporter: map["isActiveSupporter"] ?? false,
      totalSupportMonths: map["totalSupportMonths"] is int ? map["totalSupportMonths"] : int.tryParse(map["totalSupportMonths"]?.toString() ?? "0") ?? 0,
      totalSupportCents: map["totalSupportCents"] is int ? map["totalSupportCents"] : int.tryParse(map["totalSupportCents"]?.toString() ?? "0") ?? 0,
      lastTierCents: map["lastTierCents"] is int ? map["lastTierCents"] : int.tryParse(map["lastTierCents"]?.toString() ?? "0") ?? 0,
      highestTierCents: map["highestTierCents"] is int ? map["highestTierCents"] : int.tryParse(map["highestTierCents"]?.toString() ?? "0") ?? 0,
      lowestTierCents: map["lowestTierCents"] is int ? map["lowestTierCents"] : int.tryParse(map["lowestTierCents"]?.toString() ?? "0") ?? 0,
      firstSupportTimestamp: DateTime.tryParse(map["firstSupportTimestamp"] ?? "") ?? DateTimeX.epoch,
      lastSupportTimestamp: DateTime.tryParse(map["lastSupportTimestamp"] ?? "") ?? DateTimeX.epoch,
    );
  }
}
