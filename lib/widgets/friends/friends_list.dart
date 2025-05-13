import 'package:open_contacts/clients/messaging_client.dart';
import 'package:open_contacts/widgets/friends/friend_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_contacts/models/users/friend.dart';
import 'package:open_contacts/auxiliary.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:open_contacts/models/contact_tabs_config.dart';
import 'package:open_contacts/widgets/friends/friend_context_menu.dart';
import 'package:open_contacts/widgets/messages/messages_list.dart';
import 'package:open_contacts/models/message.dart';
import 'package:open_contacts/models/view_modes.dart';
import 'package:open_contacts/models/users/online_status.dart';
import 'package:open_contacts/badges_db.dart';
import 'package:open_contacts/widgets/generic_avatar.dart';

class FriendsList extends StatefulWidget {
  const FriendsList({super.key});

  @override
  State<FriendsList> createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList>
    with AutomaticKeepAliveClientMixin {
  final String _searchFilter = "";
  final Map<int, bool> _hoverStates = {};
  final Map<int, Offset?> _mousePositions = {};

  @override
  bool get wantKeepAlive => true;

  Widget _buildListView(List<Friend> friends, MessagingClient mClient, ThemeData theme) {
    final filteredFriends = friends
        .where((friend) =>
            friend.username.toLowerCase().contains(_searchFilter.toLowerCase()))
        .toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(
          decelerationRate: ScrollDecelerationRate.fast),
      itemCount: filteredFriends.length,
      itemBuilder: (context, index) {
        final friend = filteredFriends[index];
        final unreads = mClient.getUnreadsForFriend(friend);
        return FriendListTile(
          friend: friend,
          unreads: unreads.length,
        );
      },
    );
  }

  Widget _buildGridView(List<Friend> friends, MessagingClient mClient, ThemeData theme) {
    return GridView.builder(
      clipBehavior: Clip.none,
      physics: const BouncingScrollPhysics(
          decelerationRate: ScrollDecelerationRate.fast),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: friends.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final friend = friends[index];
        final unreads = mClient.getUnreadsForFriend(friend);
        
        // Status color for border
        final statusColor = friend.userStatus.onlineStatus.color(context);
        final isOffline = friend.userStatus.onlineStatus == OnlineStatus.Offline || 
                          friend.userStatus.onlineStatus == OnlineStatus.Invisible;
              
        return LayoutBuilder(
          builder: (context, constraints) {
            return MouseRegion(
              onEnter: (event) {
                setState(() {
                  _mousePositions[index] = event.localPosition;
                  _hoverStates[index] = true;
                });
              },
              onHover: (event) {
                setState(() {
                  _mousePositions[index] = event.localPosition;
                });
              },
              onExit: (_) {
                setState(() {
                  _hoverStates[index] = false;
                });
              },
              cursor: SystemMouseCursors.click,
              child: LongPressDraggable<Friend>(
                data: friend,
                dragAnchorStrategy: pointerDragAnchorStrategy,
                feedback: Material(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.transparent,
                        width: 0,
                      ),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          Aux.getProfileImageUrl(friend.userProfile),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                child: GestureDetector(
                  onTap: () async {
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
                    if (context.mounted) {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ChangeNotifierProvider<MessagingClient>.value(
                            value: mClient,
                            child: const MessagesList(),
                          ),
                        ),
                      );
                    }
                    mClient.selectedFriend = null;
                  },
                  onSecondaryTapUp: (details) {
                    final tabsConfig =
                        Provider.of<ContactTabsConfig>(context, listen: false);
                    FriendContextMenu.show(
                      context: context,
                      friend: friend,
                      tabs: tabsConfig.tabs,
                      position: RelativeRect.fromLTRB(
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    transform: Matrix4.identity()
                      ..scale(_hoverStates[index] == true ? 0.95 : 1.0),
                    transformAlignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      border: Border.all(
                        color: Colors.transparent,
                        width: 0,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background with rounded corners
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: GenericAvatar(
                              userId: friend.id,
                              imageUri: Aux.getProfileImageUrl(friend.userProfile),
                              radius: 12,
                              foregroundColor: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        
                        // Username speech bubble - bottom left
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isOffline ? theme.colorScheme.surface : statusColor.withAlpha(255),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomLeft: Radius.circular(10),
                                topLeft: Radius.circular(0),
                                bottomRight: Radius.circular(0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(20),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  friend.username,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: friend.userStatus.onlineStatus == OnlineStatus.Offline ? 
                                        Colors.white : Colors.black,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Session indicator (top right)
                        if (friend.userStatus.currentSessionIndex >= 0)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiaryContainer.withAlpha(128),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.videogame_asset_outlined,
                                    size: 12,
                                    color: theme.colorScheme.onTertiaryContainer,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    friend.userStatus.decodedSessions
                                        .elementAtOrNull(friend.userStatus.currentSessionIndex)?.name.isNotEmpty == true ? 
                                        ((friend.userStatus.decodedSessions
                                            .elementAtOrNull(friend.userStatus.currentSessionIndex)?.name.length ?? 0) > 10 ? 
                                            '${friend.userStatus.decodedSessions
                                                .elementAtOrNull(friend.userStatus.currentSessionIndex)?.name.substring(0, 10)}...' : 
                                            friend.userStatus.decodedSessions
                                                .elementAtOrNull(friend.userStatus.currentSessionIndex)?.name ?? '') : 
                                        'In Game',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onTertiaryContainer,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        
                        // Badges container (top left)
                        if (friend.userStatus.badges.isNotEmpty || friend.userStatus.isHost == true)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...friend.userStatus.badges.map((badge) {
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
                                  if (friend.userStatus.isHost ?? false)
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
                                ],
                              ),
                            ),
                          ),
                        
                        // Unread indicator (top left, below badges)
                        if (unreads.isNotEmpty)
                          Positioned(
                            top: friend.userStatus.badges.isNotEmpty || friend.userStatus.isHost == true ? 30 : 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                unreads.length > 99 ? '99+' : '${unreads.length}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onError,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildIconsView(List<Friend> friends, MessagingClient mClient, ThemeData theme) {
    return GridView.builder(
      clipBehavior: Clip.none,
      physics: const BouncingScrollPhysics(
          decelerationRate: ScrollDecelerationRate.fast),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 130,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.0,
      ),
      itemCount: friends.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final friend = friends[index];
        final unreads = mClient.getUnreadsForFriend(friend);
        final currentSession = friend.userStatus.currentSessionIndex == -1
          ? null
          : friend.userStatus.decodedSessions
              .elementAtOrNull(friend.userStatus.currentSessionIndex);
              
        // Status color for border
        final statusColor = friend.userStatus.onlineStatus.color(context);
        final isOffline = friend.userStatus.onlineStatus == OnlineStatus.Offline || 
                          friend.userStatus.onlineStatus == OnlineStatus.Invisible;
        final speechBubbleColor = isOffline ? 
            theme.colorScheme.surface : 
            statusColor.withAlpha(255);
        
        // Set text color based on online status
        final textColor = friend.userStatus.onlineStatus == OnlineStatus.Offline ? 
            Colors.white : 
            Colors.black;
              
        return LayoutBuilder(
          builder: (context, constraints) {
            final squareSize = constraints.maxWidth;
            
            return MouseRegion(
              onEnter: (event) {
                setState(() {
                  _mousePositions[index] = event.localPosition;
                  _hoverStates[index] = true;
                });
              },
              onHover: (event) {
                setState(() {
                  _mousePositions[index] = event.localPosition;
                });
              },
              onExit: (_) {
                setState(() {
                  _hoverStates[index] = false;
                });
              },
              cursor: SystemMouseCursors.click,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Main Content
                  LongPressDraggable<Friend>(
                    data: friend,
                    dragAnchorStrategy: pointerDragAnchorStrategy,
                    feedback: Material(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: GenericAvatar(
                            userId: friend.id,
                            imageUri: Aux.getProfileImageUrl(friend.userProfile),
                            radius: 30,
                          ),
                        ),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () async {
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
                        if (context.mounted) {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChangeNotifierProvider<MessagingClient>.value(
                                value: mClient,
                                child: const MessagesList(),
                              ),
                            ),
                          );
                        }
                        mClient.selectedFriend = null;
                      },
                      onSecondaryTapUp: (details) {
                        final tabsConfig =
                            Provider.of<ContactTabsConfig>(context, listen: false);
                        FriendContextMenu.show(
                          context: context,
                          friend: friend,
                          tabs: tabsConfig.tabs,
                          position: RelativeRect.fromLTRB(
                            details.globalPosition.dx,
                            details.globalPosition.dy,
                            details.globalPosition.dx,
                            details.globalPosition.dy,
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        transform: Matrix4.identity()
                          ..scale(_hoverStates[index] == true ? 0.9 : 1.0),
                        transformAlignment: Alignment.center,
                        child: Column(
                          children: [
                            // Square Avatar with Material 3 styling
                            SizedBox(
                              height: squareSize * 0.72,
                              width: squareSize * 0.72,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Avatar container with dynamic elevation
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: squareSize * 0.72,
                                    height: squareSize * 0.72,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: theme.colorScheme.surface,
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorScheme.shadow.withAlpha(20),
                                          blurRadius: 2,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child: GenericAvatar(
                                          userId: friend.id,
                                          imageUri: Aux.getProfileImageUrl(friend.userProfile),
                                          radius: 25,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Online indicator dot with Material 3 styling - hide when offline
                                  if (!friend.isOffline)
                                    Positioned(
                                      bottom: -5,
                                      right: -5,
                                      child: Tooltip(
                                        message: friend.userStatus.onlineStatus.name,
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: friend.userStatus.onlineStatus.color(context),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: theme.colorScheme.surface,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: theme.colorScheme.shadow.withAlpha(31),
                                                blurRadius: 2,
                                                spreadRadius: 0,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Unread messages badge with Material 3 styling
                                  if (unreads.isNotEmpty)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Material(
                                        color: theme.colorScheme.error,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        elevation: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          constraints: const BoxConstraints(
                                            minWidth: 22,
                                            minHeight: 22,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: theme.colorScheme.surface,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              unreads.length > 99 ? '99+' : '${unreads.length}',
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: theme.colorScheme.onError,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Badges container (top left)
                                  if (friend.userStatus.badges.isNotEmpty || friend.userStatus.isHost == true)
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: Material(
                                        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        elevation: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: theme.colorScheme.surface,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ...friend.userStatus.badges.map((badge) {
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
                                              if (friend.userStatus.isHost ?? false)
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
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Username without background - more compact
                            SizedBox(
                              width: double.infinity,
                              height: squareSize * 0.18, // Reduced from 0.24
                              child: Center(
                                child: Text(
                                  friend.username,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.2,
                                    fontSize: 10,
                                    height: 1.0,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final mClient = Provider.of<MessagingClient>(context);
    final tabsConfig = Provider.of<ContactTabsConfig>(context);
    
    // Filter friends by selected tab
    final currentTab = tabsConfig.tabs[tabsConfig.selectedTabIndex];
    List<Friend> friends = mClient.cachedFriends;
    
    if (currentTab.id != 'all' && currentTab.userIds != null) {
      friends = friends
          .where((friend) => currentTab.userIds!.contains(friend.id))
          .toList();
    }
    
    final ViewMode viewMode = mClient.viewMode;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          );
        },
        child: switch (viewMode) {
          ViewMode.list => _buildListView(friends, mClient, theme),
          ViewMode.tiles => _buildGridView(friends, mClient, theme),
          ViewMode.icons => _buildIconsView(friends, mClient, theme),
        },
      ),
    );
  }
}
