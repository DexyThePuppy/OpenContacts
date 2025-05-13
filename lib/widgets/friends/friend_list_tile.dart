import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_contacts/auxiliary.dart';
import 'package:open_contacts/clients/messaging_client.dart';
import 'package:open_contacts/models/message.dart';
import 'package:open_contacts/models/users/friend.dart';
import 'package:open_contacts/widgets/formatted_text.dart';
import 'package:open_contacts/widgets/generic_avatar.dart';
import 'package:open_contacts/widgets/messages/messages_list.dart';
import 'package:open_contacts/widgets/user_profile_dialog.dart';
import 'package:open_contacts/string_formatter.dart';
import 'package:open_contacts/widgets/friends/friend_context_menu.dart';
import 'package:open_contacts/client_holder.dart';
import 'package:open_contacts/widgets/my_profile_dialog.dart';
import 'package:open_contacts/models/contact_tabs_config.dart';
import 'package:open_contacts/badges_db.dart';

class FriendListTile extends StatefulWidget {
  const FriendListTile(
      {required this.friend,
      required this.unreads,
      this.onTap,
      super.key,
      this.onLongPress});

  final Friend friend;
  final int unreads;
  final Function? onTap;
  final Function? onLongPress;

  @override
  State<FriendListTile> createState() => _FriendListTileState();
}

class _FriendListTileState extends State<FriendListTile>
    with AutomaticKeepAliveClientMixin {
  bool isHovered = false;
  Offset? mousePosition;
  Alignment imageAlignment = Alignment.center;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final imageUri = Aux.getProfileImageUrl(widget.friend.userProfile);
    final theme = Theme.of(context);
    final mClient = Provider.of<MessagingClient>(context, listen: false);
    final tabsConfig = Provider.of<ContactTabsConfig>(context, listen: true);
    final currentSession = widget.friend.userStatus.currentSessionIndex == -1
        ? null
        : widget.friend.userStatus.decodedSessions
            .elementAtOrNull(widget.friend.userStatus.currentSessionIndex);

    return LayoutBuilder(
      builder: (context, constraints) => MouseRegion(
        onEnter: (event) {
          setState(() {
            mousePosition = event.localPosition;
            isHovered = true;
          });
        },
        onHover: (event) {
          setState(() {
            mousePosition = event.localPosition;
          });
        },
        onExit: (_) {
          setState(() {
            isHovered = false;
          });
        },
        child: SizedBox(
          height: 56,
          child: Stack(
            children: [
              if (mousePosition != null)
                Positioned.fromRect(
                  rect: Rect.fromLTWH(
                    8,
                    1,
                    constraints.maxWidth - 16,
                    54,
                  ),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.fastEaseInToSlowEaseOut,
                    opacity: isHovered ? 0.1 : 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: TweenAnimationBuilder<Alignment>(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        tween: Tween<Alignment>(
                          begin: mousePosition != null
                              ? Alignment(
                                  ((mousePosition!.dx / constraints.maxWidth) -
                                          0.5) *
                                      0.3,
                                  ((mousePosition!.dy / 54) - 0.5) * 0.3,
                                )
                              : Alignment.center,
                          end: Alignment.center,
                        ),
                        builder: (context, alignment, child) => FutureBuilder<ImageProvider>(
                          future: Aux.getProfileImageProvider(null, userId: widget.friend.id),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image(
                                image: snapshot.data!,
                          fit: BoxFit.cover,
                          alignment: alignment,
                              );
                            } else {
                              // Fallback while loading
                              return Container(color: Theme.of(context).colorScheme.surfaceContainerHighest);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              LongPressDraggable<Friend>(
                data: widget.friend,
                dragAnchorStrategy: pointerDragAnchorStrategy,
                feedback: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(28),
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: FutureBuilder<ImageProvider>(
                      future: Aux.getProfileImageProvider(null, userId: widget.friend.id),
                      builder: (context, snapshot) {
                        return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                            image: snapshot.hasData
                                ? DecorationImage(
                                    image: snapshot.data!,
                                    fit: BoxFit.cover,
                                  )
                                : DecorationImage(
                          image: NetworkImage(imageUri),
                          fit: BoxFit.cover,
                        ),
                      ),
                        );
                      },
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: Card(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: ListTile(
                      leading: GenericAvatar(userId: widget.friend.id, imageUri: imageUri),
                      title: Text(widget.friend.username),
                    ),
                  ),
                ),
                child: GestureDetector(
                  onSecondaryTapUp: (details) {
                    FriendContextMenu.show(
                      context: context,
                      friend: widget.friend,
                      position: RelativeRect.fromLTRB(
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                      ),
                      tabs: tabsConfig.tabs,
                    );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                    child: Material(
                      color: Colors.transparent,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        visualDensity: VisualDensity.compact,
                        dense: true,
                        leading: SizedBox(
                          width: 30,
                          height: 30,
                          child: GenericAvatar(
                            userId: widget.friend.id,
                            imageUri: imageUri,
                            radius: 18,
                          ),
                        ),
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -3),
                              child: Text(
                                widget.friend.username,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.5,
                                  height: 1.2,
                                  leadingDistribution:
                                      TextLeadingDistribution.even,
                                ),
                              ),
                            ),
                            if (widget.friend.isHeadless)
                              Transform.translate(
                                offset: const Offset(0, -1),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3, vertical: 0),
                                  child: Icon(
                                    Icons.dns,
                                    size: 12,
                                    color: theme
                                        .colorScheme.onSecondaryContainer
                                        .withOpacity(1.0),
                                  ),
                                ),
                              ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...widget.friend.userStatus.badges
                                      .map((badge) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: FutureBuilder<ImageProvider>(
                                        future: Aux.getProfileImageProvider(null, userId: null),
                                        builder: (context, snapshot) {
                                          return Image(
                                            image: snapshot.hasData 
                                              ? snapshot.data! 
                                              : NetworkImage(badge.assetUrl),
                                          width: 16,
                                          height: 16,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          );
                                        },
                                      ),
                                    );
                                  }),
                                  if (widget.friend.userStatus.isHost ?? false)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: FutureBuilder<ImageProvider>(
                                        future: Aux.getProfileImageProvider(null, userId: null),
                                        builder: (context, snapshot) {
                                          return Image(
                                            image: snapshot.hasData 
                                              ? snapshot.data! 
                                              : NetworkImage(BadgesDB.commonBadges['host']?.assetUrl ?? ''),
                                        width: 16,
                                        height: 16,
                                        color: const Color(0xFFE69E50),
                                          );
                                        },
                                      ),
                                    ),
                                  if (widget
                                          .friend.userProfile.supporterMetadata
                                          ?.any((m) =>
                                              m.type == 'patreon' &&
                                              m.isActiveSupporter) ??
                                      false)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: FutureBuilder<ImageProvider>(
                                        future: Aux.getProfileImageProvider(null, userId: null),
                                        builder: (context, snapshot) {
                                          return Image(
                                            image: snapshot.hasData 
                                              ? snapshot.data! 
                                              : NetworkImage(BadgesDB.commonBadges['supporter']?.assetUrl ?? ''),
                                        width: 16,
                                        height: 16,
                                        color: const Color(0xFFFF424D),
                                          );
                                        },
                                      ),
                                    ),
                                  if (widget.friend.userProfile.isTeamMember)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: FutureBuilder<ImageProvider>(
                                        future: Aux.getProfileImageProvider(null, userId: null),
                                        builder: (context, snapshot) {
                                          return Image(
                                            image: snapshot.hasData 
                                              ? snapshot.data! 
                                              : NetworkImage(BadgesDB.teamBadges['team']?.assetUrl ?? ''),
                                        width: 16,
                                        height: 16,
                                        color: const Color(0xFF00B0F4),
                                          );
                                        },
                                      ),
                                    ),
                                  if (widget.friend.userProfile.isModerator)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: FutureBuilder<ImageProvider>(
                                        future: Aux.getProfileImageProvider(null, userId: null),
                                        builder: (context, snapshot) {
                                          return Image(
                                            image: snapshot.hasData 
                                              ? snapshot.data! 
                                              : NetworkImage(BadgesDB.teamBadges['moderator']?.assetUrl ?? ''),
                                        width: 16,
                                        height: 16,
                                        color: const Color(0xFF1ABC9C),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (!widget.friend.isOffline &&
                                !widget.friend.isHeadless) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: widget.friend.userStatus.onlineStatus
                                      .color(context)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 1),
                                      child: Icon(
                                        Icons.circle,
                                        size: 6,
                                        color: widget
                                            .friend.userStatus.onlineStatus
                                            .color(context),
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    FormattedText(
                                      FormatNode.fromText(widget
                                          .friend.userStatus.onlineStatus.name),
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: widget
                                            .friend.userStatus.onlineStatus
                                            .color(context),
                                        fontSize: 12,
                                        height: 1.0,
                                        leadingDistribution:
                                            TextLeadingDistribution.even,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (currentSession != null) ...[
                                const SizedBox(width: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (currentSession.name.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme.tertiaryContainer
                                              .withOpacity(0.6),
                                          borderRadius: BorderRadius.horizontal(
                                            left: Radius.circular(12),
                                            right: Radius.zero,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.public,
                                              size: 12,
                                              color: theme.colorScheme
                                                  .onTertiaryContainer,
                                            ),
                                            const SizedBox(width: 3),
                                            Flexible(
                                              child: FormattedText(
                                                currentSession.formattedName,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  color: theme.colorScheme
                                                      .onTertiaryContainer,
                                                  fontSize: 12,
                                                  height: 1.0,
                                                  leadingDistribution:
                                                      TextLeadingDistribution
                                                          .even,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme.surfaceContainerHighest
                                            .withOpacity(0.6),
                                        borderRadius: BorderRadius.horizontal(
                                          left: currentSession.name.isEmpty
                                              ? Radius.circular(12)
                                              : Radius.zero,
                                          right: Radius.circular(12),
                                        ),
                                      ),
                                      child: FormattedText(
                                        FormatNode.fromText(currentSession
                                            .accessLevel
                                            .toReadableString()),
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                          height: 1.0,
                                          leadingDistribution:
                                              TextLeadingDistribution.even,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else if (widget
                                  .friend.userStatus.appVersion.isNotEmpty) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme.surfaceContainerHighest
                                        .withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.info,
                                        size: 12,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: FormattedText(
                                          FormatNode.fromText(widget
                                              .friend.userStatus.appVersion),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                            ] else if (widget.friend.isOffline)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      "Offline",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme
                                      .colorScheme.surfaceContainerHighest
                                      .withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.dns,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      "Headless Host",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        height: 1.0,
                                        leadingDistribution:
                                            TextLeadingDistribution.even,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          ],
                        ),
                        onTap: () async {
                          widget.onTap?.call();
                          mClient.loadUserMessageCache(widget.friend.id);
                          final unreads =
                              mClient.getUnreadsForFriend(widget.friend);
                          if (unreads.isNotEmpty) {
                            final readBatch = MarkReadBatch(
                              senderId: widget.friend.id,
                              ids: unreads.map((e) => e.id).toList(),
                              readTime: DateTime.now(),
                            );
                            mClient.markMessagesRead(readBatch);
                          }
                          mClient.selectedFriend = widget.friend;
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChangeNotifierProvider<MessagingClient>.value(
                                value: mClient,
                                child: const MessagesList(),
                              ),
                            ),
                          );
                          mClient.selectedFriend = null;
                        },
                        onLongPress: () async {
                          final myId =
                              ClientHolder.of(context).apiClient.userId;
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return widget.friend.id == myId
                                  ? const MyProfileDialog()
                                  : UserProfileDialog(friend: widget.friend);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
