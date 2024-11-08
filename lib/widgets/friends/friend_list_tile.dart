import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_contacts/auxiliary.dart';
import 'package:open_contacts/clients/messaging_client.dart';
import 'package:open_contacts/models/message.dart';
import 'package:open_contacts/models/users/friend.dart';
import 'package:open_contacts/models/users/online_status.dart';
import 'package:open_contacts/widgets/formatted_text.dart';
import 'package:open_contacts/widgets/friends/friend_online_status_indicator.dart';
import 'package:open_contacts/widgets/generic_avatar.dart';
import 'package:open_contacts/widgets/messages/messages_list.dart';
import 'package:open_contacts/widgets/user_profile_dialog.dart';
import 'package:open_contacts/string_formatter.dart';
import 'package:open_contacts/widgets/friends/friend_context_menu.dart';
import 'package:open_contacts/client_holder.dart';
import 'package:open_contacts/widgets/my_profile_dialog.dart';
import 'package:open_contacts/models/contact_tabs_config.dart';



class FriendListTile extends StatelessWidget {
  const FriendListTile({required this.friend, required this.unreads, this.onTap, super.key, this.onLongPress});

  final Friend friend;
  final int unreads;
  final Function? onTap;
  final Function? onLongPress;

  @override
  Widget build(BuildContext context) {
    final imageUri = Aux.resdbToHttp(friend.userProfile.iconUrl);
    final theme = Theme.of(context);
    final mClient = Provider.of<MessagingClient>(context, listen: false);
    final currentSession = friend.userStatus.currentSessionIndex == -1
        ? null
        : friend.userStatus.decodedSessions.elementAtOrNull(friend.userStatus.currentSessionIndex);
    return GestureDetector(
      onSecondaryTapUp: (details) {
        FriendContextMenu.show(
          context: context,
          friend: friend,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
          tabs: [ContactTab(id: 'all', label: 'All')],
        );
      },
      child: ListTile(
        leading: GenericAvatar(
          imageUri: imageUri,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (friend.userProfile.isPinned ?? false)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.push_pin,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
            if (unreads != 0)
              Text(
                "+$unreads",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Text(friend.username),
            if (friend.isHeadless)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.dns,
                  size: 12,
                  color: theme.colorScheme.onSecondaryContainer.withAlpha(150),
                ),
              ),
          ],
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FriendOnlineStatusIndicator(friend: friend),
            const SizedBox(
              width: 4,
            ),
            if (!friend.isOffline && !friend.isHeadless) ...[
              FormattedText(FormatNode.fromText(friend.userStatus.onlineStatus.name)),
              if (currentSession != null) ...[
                const Text(" in "),
                if (currentSession.name.isNotEmpty)
                  Expanded(
                    child: FormattedText(
                      currentSession.formattedName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )
                else
                  Expanded(
                    child: Text(
                      "${currentSession.accessLevel.toReadableString()} World",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )
              ] else if (friend.userStatus.appVersion.isNotEmpty)
                Expanded(
                  child: FormattedText(
                    FormatNode.fromText(friend.userStatus.appVersion),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
            ] else if (friend.isOffline)
              Text(
                "Offline",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: OnlineStatus.offline.color(context),
                ),
              )
            else
              Text(
                "Headless Host",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color.fromARGB(255, 41, 77, 92),
                ),
              )
          ],
        ),
        onTap: () async {
          onTap?.call();
          mClient.loadUserMessageCache(friend.id);
          final unreads = mClient.getUnreadsForFriend(friend);
          if (unreads.isNotEmpty) {
            final readBatch = MarkReadBatch(
              senderId: friend.id,
              ids: unreads.map((e) => e.id).toList(),
              readTime: DateTime.now(),
            );
            mClient.markMessagesRead(readBatch);
          }
          mClient.selectedFriend = friend;
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider<MessagingClient>.value(
                value: mClient,
                child: const MessagesList(),
              ),
            ),
          );
          mClient.selectedFriend = null;
        },
        onLongPress: () async {
          final myId = ClientHolder.of(context).apiClient.userId;
          await showDialog(
            context: context,
            builder: (context) {
              return friend.id == myId 
                ? const MyProfileDialog()
                : UserProfileDialog(friend: friend);
            },
          );
        }
      ),
    );
  }
}