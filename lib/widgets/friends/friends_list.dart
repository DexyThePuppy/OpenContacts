import 'package:open_contacts/clients/messaging_client.dart';
import 'package:open_contacts/widgets/friends/friend_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_contacts/models/users/friend.dart';
import 'package:open_contacts/auxiliary.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:open_contacts/models/contact_tabs_config.dart';

class FriendsList extends StatefulWidget {
  const FriendsList({super.key});

  @override
  State<FriendsList> createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late List<ContactTab> _tabs;
  final String _searchFilter = "";

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
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Stack(
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
        );
      },
    );
  }

  Widget _buildFriendsList(ContactTab tab) {
    final mClient = Provider.of<MessagingClient>(context);
    List<Friend> friends = mClient.cachedFriends;
    
    // Filter friends if tab has userIds
    if (tab.userIds != null && tab.userIds!.isNotEmpty) {
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
      if (mounted) {
        final newTabs = config.tabs;
        final newController = TabController(length: newTabs.length, vsync: this);
        setState(() {
          _tabController.dispose();
          _tabs = newTabs;
          _tabController = newController;
        });
      }
    } catch (e) {
      if (mounted) {
        final newTabs = [ContactTab(id: 'all', label: 'All')];
        final newController = TabController(length: newTabs.length, vsync: this);
        setState(() {
          _tabController.dispose();
          _tabs = newTabs;
          _tabController = newController;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((tab) => Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tab.icon != null) ...[
                  Icon(
                    IconData(int.parse(tab.icon!), fontFamily: 'MaterialIcons'),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(tab.label),
              ],
            ),
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
}
