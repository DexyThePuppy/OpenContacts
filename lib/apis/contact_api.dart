import 'dart:convert';

import 'package:open_contacts/clients/api_client.dart';
import 'package:open_contacts/models/users/friend.dart';
import 'package:open_contacts/models/users/friend_status.dart';
import 'package:open_contacts/models/users/user.dart';
import 'package:open_contacts/models/users/user_profile.dart';
import 'package:open_contacts/models/users/user_status.dart';
import 'package:open_contacts/apis/user_api.dart';

class ContactApi {
  static Future<List<Friend>> getFriendsList(ApiClient client, {DateTime? lastStatusUpdate}) async {
    final response = await client.get("/users/${client.userId}/contacts${lastStatusUpdate != null ? "?lastStatusUpdate=${lastStatusUpdate.toUtc().toIso8601String()}" : ""}");
    client.checkResponse(response);
    final data = jsonDecode(response.body) as List;
    return data.map((e) => Friend.fromMap(e)).toList();
  }

  static Future<void> addUserAsFriend(ApiClient client, {required User user}) async {
    final registrationDate = await UserApi.getRegistrationDate(client, user.id);
    
    final friend = Friend(
      id: user.id,
      username: user.username,
      ownerId: client.userId,
      registrationDate: registrationDate,
      userStatus: UserStatus.empty(),
      userProfile: UserProfile.empty(),
      contactStatus: FriendStatus.accepted,
      latestMessageTime: DateTime.now(),
    );
    
    final body = jsonEncode(friend.toMap(shallow: true));
    final response = await client.put("/users/${client.userId}/contacts/${user.id}", body: body);
    client.checkResponse(response);
  }

  static Future<void> removeUserAsFriend(ApiClient client, {required User user}) async {
    final response = await client.delete("/users/${client.userId}/friends/${user.id}");
    client.checkResponse(response);
  }
}