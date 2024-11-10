import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:open_contacts/models/users/friend.dart';
import 'package:open_contacts/models/contact_tabs_config.dart';
import 'package:open_contacts/clients/messaging_client.dart';
import 'package:open_contacts/widgets/messages/messages_list.dart';
import 'package:open_contacts/widgets/my_profile_dialog.dart';
import 'package:open_contacts/widgets/user_profile_dialog.dart';
import 'package:open_contacts/client_holder.dart';
import 'package:open_contacts/widgets/friends/category_management_dialog.dart';

class FriendContextMenu {
  static Future<void> show({
    required BuildContext context,
    required Friend friend,
    required RelativeRect position,
    required List<ContactTab> tabs,
  }) async {
    final mClient = Provider.of<MessagingClient>(context, listen: false);
    final tabsConfig = Provider.of<ContactTabsConfig>(context, listen: false);

    final entries = <ContextMenuEntry>[
      MenuItem(
        label: 'View Profile',
        icon: Icons.person,
        onSelected: () async {
          final myId = ClientHolder.of(context).apiClient.userId;
          if (context.mounted) {
            await showDialog(
              context: context,
              builder: (context) => friend.id == myId
                  ? const MyProfileDialog()
                  : UserProfileDialog(friend: friend),
            );
          }
        },
      ),
      const MenuDivider(),
      MenuItem(
        label: 'Message',
        icon: Icons.message,
        onSelected: () async {
          mClient.loadUserMessageCache(friend.id);
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
            mClient.selectedFriend = null;
          }
        },
      ),
      MenuItem(
        label: 'Boop',
        icon: Icons.notifications,
        onSelected: () {
          // TODO: Implement boop
        },
      ),
      MenuItem(
        label: friend.isPinned ? 'Unpin' : 'Pin',
        icon: friend.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
        onSelected: () async {
          await mClient.toggleFriendPin(friend);
        },
      ),
      const MenuDivider(),
      MenuItem.submenu(
        label: 'Categories',
        icon: Icons.category,
        items: [
          ...tabs.map((tab) => MenuItem(
                label: tabsConfig.isUserInTab(friend.id, tab.id)
                    ? "${tab.label} ✓"
                    : tab.label,
                icon: tab.icon != null
                    ? IconData(int.parse(tab.icon!),
                        fontFamily: 'MaterialIcons')
                    : Icons.label,
                onSelected: () async {
                  if (tabsConfig.isUserInTab(friend.id, tab.id)) {
                    tabsConfig.removeUserFromTab(friend.id, tab.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Removed from ${tab.label}')),
                      );
                    }
                  } else {
                    tabsConfig.addUserToTab(friend.id, tab.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added to ${tab.label}')),
                      );
                    }
                  }
                },
              )),
          MenuDivider(),
          MenuItem(
            label: 'Manage Categories...',
            icon: Icons.settings,
            onSelected: () async {
              // Show category management dialog
              if (context.mounted) {
                await showDialog(
                  context: context,
                  builder: (context) =>
                      CategoryManagementDialog(friend: friend),
                );
              }
            },
          ),
        ],
      ),
      const MenuDivider(),
      MenuItem(
        label: 'Block',
        icon: Icons.block,
        onSelected: () async {
          await mClient.blockFriend(friend);
        },
      ),
    ];

    final menu = ContextMenu(
      entries: entries,
      position: Offset(position.left, position.top),
      padding: const EdgeInsets.all(8.0),
    );

    await showContextMenu(context, contextMenu: menu);
  }
}
