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

class FriendsList extends StatefulWidget {
  const FriendsList({super.key});

  @override
  State<FriendsList> createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList>
    with AutomaticKeepAliveClientMixin {
  final String _searchFilter = "";
  final Map<int, bool> _hoverStates = {};

  Widget _buildListView(List<Friend> friends, MessagingClient mClient) {
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

  Widget _buildGridView(List<Friend> friends, MessagingClient mClient) {
    return GridView.builder(
      clipBehavior: Clip.none,
      physics: const BouncingScrollPhysics(
          decelerationRate: ScrollDecelerationRate.fast),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: friends.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final friend = friends[index];
        final unreads = mClient.getUnreadsForFriend(friend);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            LongPressDraggable<Friend>(
              data: friend,
              dragAnchorStrategy: pointerDragAnchorStrategy,
              feedback: Material(
                elevation: 8,
                shape: const CircleBorder(),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        Aux.resdbToHttp(friend.userProfile.iconUrl),
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
                child: MouseRegion(
                  onEnter: (_) => setState(() {
                    _hoverStates[index] = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {});
                    });
                  }),
                  onExit: (_) => setState(() => _hoverStates[index] = false),
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    clipBehavior: Clip.none,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      transform: Matrix4.identity()
                        ..scale(_hoverStates[index] == true ? 1.1 : 1.0),
                      transformAlignment: Alignment.center,
                      child: Card(
                        color: const Color(0xFF2C2F33),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Profile Image
                            Positioned.fill(
                              child: CachedNetworkImage(
                                imageUrl:
                                    Aux.resdbToHttp(friend.userProfile.iconUrl),
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  Icons.broken_image,
                                  size: 64,
                                ),
                                placeholder: (context, uri) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                            // Status Bar
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFF2C2F33).withOpacity(0.95),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      friend.username,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Online Status Pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF43B581),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'Online',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Game Status Pill (if in a game)
                                    if (friend.userStatus.currentSessionIndex >=
                                        0)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF7289DA),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.games,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  'in: ${friend.userStatus.decodedSessions[friend.userStatus.currentSessionIndex].name}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (unreads.isNotEmpty)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreads.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFriendsList() {
    final mClient = Provider.of<MessagingClient>(context);
    final tabsConfig = Provider.of<ContactTabsConfig>(context);
    final currentTab = tabsConfig.tabs[tabsConfig.selectedTabIndex];
    List<Friend> friends = mClient.cachedFriends;

    if (currentTab.id != 'all' && currentTab.userIds != null) {
      friends = friends
          .where((friend) => currentTab.userIds!.contains(friend.id))
          .toList();
    }

    return AnimatedSwitcher(
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
      child: mClient.viewMode == ViewMode.list
          ? _buildListView(friends, mClient)
          : _buildGridView(friends, mClient),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildFriendsList();
  }

  @override
  bool get wantKeepAlive => true;
}
