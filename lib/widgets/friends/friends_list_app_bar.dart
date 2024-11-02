import 'package:collection/collection.dart';
import 'package:open_contacts/client_holder.dart';
import 'package:open_contacts/clients/messaging_client.dart' show MessagingClient, ViewMode;
import 'package:open_contacts/models/users/online_status.dart';
import 'package:open_contacts/widgets/friends/user_search.dart';
import 'package:open_contacts/widgets/my_profile_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FriendsListAppBar extends StatefulWidget {
  const FriendsListAppBar({super.key});

  @override
  State<StatefulWidget> createState() => _FriendsListAppBarState();
}

class _FriendsListAppBarState extends State<FriendsListAppBar> with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AppBar(
      title: const Text("Contacts"),
      actions: [
        Consumer<MessagingClient>(
          builder: (context, client, _) => IconButton(
            icon: Icon(client.viewMode.icon),
            onPressed: () {
              client.viewMode = client.viewMode == ViewMode.list 
                ? ViewMode.tiles 
                : ViewMode.list;
            },
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
                Text(toBeginningOfSentenceCase(client.userStatus.onlineStatus.name) ?? "Unknown"),
              ],
            ),
            onSelected: (OnlineStatus onlineStatus) async {
              final settingsClient = ClientHolder.of(context).settingsClient;
              try {
                await client.setOnlineStatus(onlineStatus);
                await settingsClient
                    .changeSettings(settingsClient.currentSettings.copyWith(lastOnlineStatus: onlineStatus.index));
              } catch (e, s) {
                FlutterError.reportError(FlutterErrorDetails(exception: e, stack: s));
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("Failed to set online-status.")));
                }
              }
            },
            itemBuilder: (BuildContext context) => OnlineStatus.values
                .where((element) => element == OnlineStatus.sociable || element == OnlineStatus.online ||element == OnlineStatus.busy || element == OnlineStatus.offline).sorted((a, b) => b.index.compareTo(a.index),)
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
                  final mClient = Provider.of<MessagingClient>(context, listen: false);
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider<MessagingClient>.value(
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MenuItemDefinition {
  final String name;
  final IconData icon;
  final Function() onTap;

  const MenuItemDefinition({required this.name, required this.icon, required this.onTap});
}
