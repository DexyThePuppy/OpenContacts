// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_account.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SecureAccountAdapter extends TypeAdapter<SecureAccount> {
  @override
  final int typeId = 1;

  @override
  SecureAccount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SecureAccount(
      username: fields[0] as String,
      password: fields[1] as String?,
      lastUsed: fields[2] as DateTime?,
      favorite: fields[3] as bool,
      additionalInfo: (fields[4] as Map?)?.cast<String, String>(),
      profilePictureUrl: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SecureAccount obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.password)
      ..writeByte(2)
      ..write(obj.lastUsed)
      ..writeByte(3)
      ..write(obj.favorite)
      ..writeByte(4)
      ..write(obj.additionalInfo)
      ..writeByte(5)
      ..write(obj.profilePictureUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecureAccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
