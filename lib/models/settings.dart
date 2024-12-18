import 'dart:convert';

import 'package:open_contacts/models/sem_ver.dart';
import 'package:open_contacts/models/users/online_status.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SettingsEntry<T> {
  final T? value;
  final T deflt;

  const SettingsEntry({this.value, required this.deflt});

  factory SettingsEntry.fromMap(Map map) {
    return SettingsEntry<T>(
      value: jsonDecode(map["value"]) as T?,
      deflt: map["default"],
    );
  }

  Map toMap() {
    return {
      "value": jsonEncode(value),
      "default": deflt,
    };
  }

  T get valueOrDefault => value ?? deflt;

  SettingsEntry<T> withValue({required T newValue}) =>
      SettingsEntry(value: newValue, deflt: deflt);

  SettingsEntry<T> passThrough(T? newValue) {
    return newValue == null ? this : this.withValue(newValue: newValue);
  }
}

class Settings {
  final SettingsEntry<bool> notificationsDenied;
  final SettingsEntry<int> lastOnlineStatus;
  final SettingsEntry<String> lastDismissedVersion;
  final SettingsEntry<String> machineId;
  final SettingsEntry<int> themeMode;
  final SettingsEntry<int> sessionViewLastMinimumUsers;
  final SettingsEntry<bool> sessionViewLastIncludeEnded;
  final SettingsEntry<bool> sessionViewLastIncludeEmpty;
  final SettingsEntry<bool> sessionViewLastIncludeIncompatible;
  final SettingsEntry<int> seedColor;
  final SettingsEntry<int?> customColor;
  final SettingsEntry<bool> useSystemColor;
  final SettingsEntry<int> lastSelectedPage;

  Settings({
    SettingsEntry<bool>? notificationsDenied,
    SettingsEntry<int>? lastOnlineStatus,
    SettingsEntry<int>? themeMode,
    SettingsEntry<String>? lastDismissedVersion,
    SettingsEntry<String>? machineId,
    SettingsEntry<int>? sessionViewLastMinimumUsers,
    SettingsEntry<bool>? sessionViewLastIncludeEnded,
    SettingsEntry<bool>? sessionViewLastIncludeEmpty,
    SettingsEntry<bool>? sessionViewLastIncludeIncompatible,
    SettingsEntry<int>? seedColor,
    SettingsEntry<int?>? customColor,
    SettingsEntry<bool>? useSystemColor,
    SettingsEntry<int>? lastSelectedPage,
  })  : notificationsDenied =
            notificationsDenied ?? const SettingsEntry<bool>(deflt: false),
        lastOnlineStatus = lastOnlineStatus ??
            SettingsEntry<int>(deflt: OnlineStatus.Online.index),
        themeMode =
            themeMode ?? SettingsEntry<int>(deflt: ThemeMode.dark.index),
        lastDismissedVersion = lastDismissedVersion ??
            SettingsEntry<String>(deflt: SemVer.zero().toString()),
        machineId =
            machineId ?? SettingsEntry<String>(deflt: const Uuid().v4()),
        sessionViewLastMinimumUsers =
            sessionViewLastMinimumUsers ?? const SettingsEntry<int>(deflt: 0),
        sessionViewLastIncludeEnded = sessionViewLastIncludeEnded ??
            const SettingsEntry<bool>(deflt: false),
        sessionViewLastIncludeEmpty = sessionViewLastIncludeEmpty ??
            const SettingsEntry<bool>(deflt: true),
        sessionViewLastIncludeIncompatible =
            sessionViewLastIncludeIncompatible ??
                const SettingsEntry<bool>(deflt: false),
        seedColor = seedColor ?? const SettingsEntry<int>(deflt: 0),
        customColor = customColor ?? const SettingsEntry<int?>(deflt: null),
        useSystemColor =
            useSystemColor ?? const SettingsEntry<bool>(deflt: true),
        lastSelectedPage =
            lastSelectedPage ?? const SettingsEntry<int>(deflt: 0);

  factory Settings.fromMap(Map map) {
    return Settings(
      notificationsDenied: getEntryOrNull<bool>(map["notificationsDenied"]),
      lastOnlineStatus: getEntryOrNull<int>(map["lastOnlineStatus"]),
      themeMode: getEntryOrNull<int>(map["themeMode"]),
      lastDismissedVersion: getEntryOrNull<String>(map["lastDismissedVersion"]),
      machineId: getEntryOrNull<String>(map["machineId"]),
      sessionViewLastMinimumUsers:
          getEntryOrNull<int>(map["sessionViewLastMinimumUsers"]),
      sessionViewLastIncludeEnded:
          getEntryOrNull<bool>(map["sessionViewLastIncludeEnded"]),
      sessionViewLastIncludeEmpty:
          getEntryOrNull<bool>(map["sessionViewLastIncludeEmpty"]),
      sessionViewLastIncludeIncompatible:
          getEntryOrNull<bool>(map["sessionViewLastIncludeIncompatible"]),
      seedColor: getEntryOrNull<int>(map["seedColor"]),
      customColor: getEntryOrNull<int?>(map["customColor"]),
      useSystemColor: getEntryOrNull<bool>(map["useSystemColor"]),
      lastSelectedPage: getEntryOrNull<int>(map["lastSelectedPage"]),
    );
  }

  static SettingsEntry<T>? getEntryOrNull<T>(Map? map) {
    if (map == null) return null;
    try {
      return SettingsEntry<T>.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Map toMap() {
    return {
      "notificationsDenied": notificationsDenied.toMap(),
      "lastOnlineStatus": lastOnlineStatus.toMap(),
      "themeMode": themeMode.toMap(),
      "lastDismissedVersion": lastDismissedVersion.toMap(),
      "machineId": machineId.toMap(),
      "sessionViewLastMinimumUsers": sessionViewLastMinimumUsers.toMap(),
      "sessionViewLastIncludeEnded": sessionViewLastIncludeEnded.toMap(),
      "sessionViewLastIncludeEmpty": sessionViewLastIncludeEmpty.toMap(),
      "sessionViewLastIncludeIncompatible":
          sessionViewLastIncludeIncompatible.toMap(),
      "seedColor": seedColor.toMap(),
      "customColor": customColor.toMap(),
      "useSystemColor": useSystemColor.toMap(),
      "lastSelectedPage": lastSelectedPage.toMap(),
    };
  }

  Settings copy() => copyWith();

  Settings copyWith({
    bool? notificationsDenied,
    int? lastOnlineStatus,
    int? themeMode,
    String? lastDismissedVersion,
    String? machineId,
    int? sessionViewLastMinimumUsers,
    bool? sessionViewLastIncludeEnded,
    bool? sessionViewLastIncludeEmpty,
    bool? sessionViewLastIncludeIncompatible,
    int? seedColor,
    int? customColor,
    bool? useSystemColor,
    int? lastSelectedPage,
  }) {
    return Settings(
      notificationsDenied:
          this.notificationsDenied.passThrough(notificationsDenied),
      lastOnlineStatus: this.lastOnlineStatus.passThrough(lastOnlineStatus),
      themeMode: this.themeMode.passThrough(themeMode),
      lastDismissedVersion:
          this.lastDismissedVersion.passThrough(lastDismissedVersion),
      machineId: this.machineId.passThrough(machineId),
      sessionViewLastMinimumUsers: this
          .sessionViewLastMinimumUsers
          .passThrough(sessionViewLastMinimumUsers),
      sessionViewLastIncludeEnded: this
          .sessionViewLastIncludeEnded
          .passThrough(sessionViewLastIncludeEnded),
      sessionViewLastIncludeEmpty: this
          .sessionViewLastIncludeEmpty
          .passThrough(sessionViewLastIncludeEmpty),
      sessionViewLastIncludeIncompatible: this
          .sessionViewLastIncludeIncompatible
          .passThrough(sessionViewLastIncludeIncompatible),
      seedColor: this.seedColor.passThrough(seedColor),
      customColor: this.customColor.passThrough(customColor),
      useSystemColor: this.useSystemColor.passThrough(useSystemColor),
      lastSelectedPage: this.lastSelectedPage.passThrough(lastSelectedPage),
    );
  }
}
