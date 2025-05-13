import 'package:hive/hive.dart';

part 'secure_account.g.dart';

@HiveType(typeId: 1)
class SecureAccount {
  @HiveField(0)
  final String username;
  
  @HiveField(1)
  final String? password;
  
  @HiveField(2)
  final DateTime? lastUsed;
  
  @HiveField(3)
  final bool favorite;
  
  @HiveField(4)
  final Map<String, String>? additionalInfo;
  
  @HiveField(5)
  final String? profilePictureUrl;

  SecureAccount({
    required this.username,
    this.password,
    this.lastUsed,
    this.favorite = false,
    this.additionalInfo,
    this.profilePictureUrl,
  });
} 