import 'package:open_contacts/auxiliary.dart';

class Entitlement {
  Entitlement();

  factory Entitlement.fromMap(Map map) {
    final type = map["\$type"];

    return switch (type) {
      "storageSpace" => StorageSpace.fromMap(map),
      _ => Entitlement(),
    };
  }
}

class StorageSpace extends Entitlement {
  final int bytes;
  final int maximumShareLevel;
  final String storageId;
  final String group;
  final DateTime startsOn;
  final DateTime expiresOn;
  final String name;
  final String description;

  StorageSpace({
    required this.bytes,
    required this.maximumShareLevel,
    required this.storageId,
    required this.group,
    required this.startsOn,
    required this.expiresOn,
    required this.name,
    required this.description,
  });

  factory StorageSpace.fromMap(Map map) {
    return StorageSpace(
      bytes: map["bytes"] is int ? map["bytes"] : int.tryParse(map["bytes"]?.toString() ?? "0") ?? 0,
      maximumShareLevel: map["maximumShareLevel"] is int ? map["maximumShareLevel"] : int.tryParse(map["maximumShareLevel"]?.toString() ?? "0") ?? 0,
      storageId: map["storageId"]?.toString() ?? "",
      group: map["group"]?.toString() ?? "",
      startsOn: DateTime.tryParse(map["startsOn"] ?? "") ?? DateTimeX.epoch,
      expiresOn: DateTime.tryParse(map["expiresOn"] ?? "") ?? DateTimeX.epoch,
      name: map["name"]?.toString() ?? "",
      description: map["description"]?.toString() ?? "",
    );
  }
}
