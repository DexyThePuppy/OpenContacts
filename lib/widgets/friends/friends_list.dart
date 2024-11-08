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

class _FriendsListState extends State<FriendsList> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late List<ContactTab> _tabs;
  bool _isInitialized = false;
  final String _searchFilter = "";
  final Map<int, bool> _hoverStates = {};

  Widget _buildListView(List<Friend> friends, MessagingClient mClient) {
    final filteredFriends = friends
        .where((friend) => friend.username.toLowerCase()
            .contains(_searchFilter.toLowerCase()))
        .toList();
        
    return ListView.builder(
      physics: const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast),
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
      physics: const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast),
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
            GestureDetector(
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
                      builder: (context) => ChangeNotifierProvider<MessagingClient>.value(
                        value: mClient,
                        child: const MessagesList(),
                      ),
                    ),
                  );
                }
                mClient.selectedFriend = null;
              },
              onSecondaryTapUp: (details) {
                FriendContextMenu.show(
                  context: context,
                  friend: friend,
                  tabs: _tabs,
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
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: CachedNetworkImage(
                              imageUrl: Aux.resdbToHttp(friend.userProfile.iconUrl),
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => const Icon(
                                Icons.broken_image,
                                size: 64,
                              ),
                              placeholder: (context, uri) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                          if (friend.userProfile.isPinned ?? false)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(
                                Icons.push_pin,
                                color: Theme.of(context).colorScheme.primary,
                                size: 16,
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.7),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    friend.username,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (unreads.isNotEmpty)
                                    Chip(
                                      label: Text(
                                        '${unreads.length}',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Theme.of(context).colorScheme.primary,
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
          ],
        );
      },
    );
  }

  Widget _buildFriendsList(ContactTab tab) {
    final mClient = Provider.of<MessagingClient>(context);
    List<Friend> friends = mClient.cachedFriends;
    
    // Filter friends based on tab
    if (tab.id != 'all' && tab.userIds != null) {
      friends = friends.where((friend) => 
        tab.userIds!.contains(friend.id)
      ).toList();
    }
    
    return mClient.viewMode == ViewMode.list 
        ? _buildListView(friends, mClient)
        : _buildGridView(friends, mClient);
  }

  @override
  void initState() {
    super.initState();
    _tabs = [ContactTab(id: 'all', label: 'All')];
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadTabsConfig();
  }

  Future<void> _loadTabsConfig() async {
    try {
      final jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/config/contact_tabs.json');
      final config = ContactTabsConfig.fromJson(jsonString);
      
      if (!mounted) return;
      
      setState(() {
        _tabs = config.tabs;
        // Properly handle tab controller recreation
        _tabController.dispose();
        _tabController = TabController(length: _tabs.length, vsync: this);
        _isInitialized = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _tabs = [ContactTab(id: 'all', label: 'All')];
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((tab) => Tab(
            text: tab.label,
            icon: tab.icon != null ? Icon(IconData(int.parse(tab.icon!), fontFamily: 'MaterialIcons')) : null,
          )).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) => _buildFriendsList(tab)).toList(),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
