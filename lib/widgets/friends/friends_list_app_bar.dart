import 'package:collection/collection.dart';
import 'package:open_contacts/client_holder.dart';
import 'package:open_contacts/clients/messaging_client.dart'
    show MessagingClient;
import 'package:open_contacts/models/users/online_status.dart';
import 'package:open_contacts/widgets/friends/user_search.dart';
import 'package:open_contacts/widgets/my_profile_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:open_contacts/models/contact_tabs_config.dart';
import 'package:open_contacts/models/view_modes.dart';

class FriendsListAppBar extends StatefulWidget {
  final void Function(int)? onTabChanged;
  const FriendsListAppBar({super.key, this.onTabChanged});

  @override
  State<StatefulWidget> createState() => _FriendsListAppBarState();
}

class _FriendsListAppBarState extends State<FriendsListAppBar>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ContactTab> _tabs = [];

  @override
  void initState() {
    super.initState();
    final tabsConfig = Provider.of<ContactTabsConfig>(context, listen: false);
    _tabs = List.from(tabsConfig.tabs);
    _tabController = TabController(
      length: _tabs.isEmpty ? 1 : _tabs.length,
      vsync: this,
      initialIndex: tabsConfig.selectedTabIndex,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        tabsConfig.updateSelectedTab(_tabController.index);
        widget.onTabChanged?.call(_tabController.index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        AppBar(
          title: Row(
            children: [
              const Text("Contacts"),
              Expanded(
                child: Center(
                  child: Container(
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: colorScheme.secondaryContainer,
                      ),
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      labelColor: colorScheme.onSecondaryContainer,
                      unselectedLabelColor: colorScheme.onSurfaceVariant,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tabs: Provider.of<ContactTabsConfig>(context)
                          .tabs
                          .map((tab) => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Tab(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(tab.label),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Consumer<MessagingClient>(
              builder: (context, client, _) => PopupMenuButton<ViewMode>(
                icon: Icon(client.viewMode.icon),
                tooltip: "Change view",
                onSelected: (ViewMode mode) {
                  client.viewMode = mode;
                },
                itemBuilder: (context) => ViewMode.values
                  .map(
                    (mode) => PopupMenuItem(
                      value: mode,
                      child: Row(
                        children: [
                          Icon(
                            mode.icon,
                            color: client.viewMode == mode
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            mode.label,
                            style: TextStyle(
                              color: client.viewMode == mode
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              ),
            ),
            Consumer<MessagingClient>(builder: (context, client, _) {
              return PopupMenuButton<OnlineStatus>(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.circle,
                        size: 16,
                        color: client.userStatus.onlineStatus.color(context),
                      ),
                    ),
                    Text(toBeginningOfSentenceCase(
                            client.userStatus.onlineStatus.name) ??
                        "Unknown"),
                  ],
                ),
                onSelected: (OnlineStatus onlineStatus) async {
                  final settingsClient =
                      ClientHolder.of(context).settingsClient;
                  try {
                    await client.setOnlineStatus(onlineStatus);
                    await settingsClient.changeSettings(settingsClient
                        .currentSettings
                        .copyWith(lastOnlineStatus: onlineStatus.index));
                  } catch (e, s) {
                    FlutterError.reportError(
                        FlutterErrorDetails(exception: e, stack: s));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Failed to set online-status.")));
                    }
                  }
                },
                itemBuilder: (BuildContext context) => OnlineStatus.values
                    .where((element) =>
                        element == OnlineStatus.Sociable ||
                        element == OnlineStatus.Online ||
                        element == OnlineStatus.Busy ||
                        element == OnlineStatus.Offline)
                    .sorted(
                      (a, b) => b.index.compareTo(a.index),
                    )
                    .map(
                      (item) => PopupMenuItem<OnlineStatus>(
                        value: item,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 16,
                              color: item.color(context),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(toBeginningOfSentenceCase(item.name)!),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            }),
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: PopupMenuButton<MenuItemDefinition>(
                icon: const Icon(Icons.more_vert),
                onSelected: (MenuItemDefinition itemDef) async {
                  await itemDef.onTap();
                },
                itemBuilder: (BuildContext context) => [
                  MenuItemDefinition(
                    name: "Add Users",
                    icon: Icons.person_add,
                    onTap: () async {
                      final mClient =
                          Provider.of<MessagingClient>(context, listen: false);
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ChangeNotifierProvider<MessagingClient>.value(
                            value: mClient,
                            child: const UserSearch(),
                          ),
                        ),
                      );
                    },
                  ),
                  MenuItemDefinition(
                    name: "My Profile",
                    icon: Icons.person,
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return const MyProfileDialog();
                        },
                      );
                    },
                  ),
                ]
                    .map(
                      (item) => PopupMenuItem<MenuItemDefinition>(
                        value: item,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.name),
                            Icon(item.icon),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: Provider.of<ContactTabsConfig>(context)
                .tabs
                .map((tab) => Center(child: Text('Content for ${tab.label}')))
                .toList(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    final tabsConfig = Provider.of<ContactTabsConfig>(context, listen: false);
    _tabController.removeListener(() {
      if (_tabController.indexIsChanging) {
        tabsConfig.updateSelectedTab(_tabController.index);
        widget.onTabChanged?.call(_tabController.index);
      }
    });
    _tabController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

class MenuItemDefinition {
  final String name;
  final IconData icon;
  final Function() onTap;

  const MenuItemDefinition(
      {required this.name, required this.icon, required this.onTap});
}
