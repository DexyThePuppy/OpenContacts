import 'package:flutter/material.dart';
import 'package:open_contacts/models/users/friend.dart';
import 'package:open_contacts/models/users/online_status.dart';
import 'package:open_contacts/models/users/user_status.dart';

class FriendOnlineStatusIndicator extends StatelessWidget {
  const FriendOnlineStatusIndicator({required this.friend, super.key});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    final UserStatus userStatus = friend.userStatus;
    final OnlineStatus onlineStatus = userStatus.onlineStatus;
    return userStatus.appVersion.contains("OpenContacts") && friend.isOnline
        ? SizedBox.square(
            dimension: 10,
            child: Image.asset(
              "assets/images/logo-white.png",
              color: onlineStatus.color(context),
              filterQuality: FilterQuality.medium,
              isAntiAlias: true,
            ),
          )
        : Icon(
            friend.isOffline ? Icons.circle_outlined : Icons.circle,
            color: friend.isHeadless
                ? const Color.fromARGB(255, 41, 77, 92)
                : onlineStatus.color(context),
            size: 10,
          );
  }
}
// TODO: Re-invent the fucking wheel aparently 