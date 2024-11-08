import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_contacts/models/users/friend.dart';
import 'package:open_contacts/models/contact_tabs_config.dart';
import 'package:open_contacts/clients/messaging_client.dart';
import 'package:open_contacts/widgets/messages/messages_list.dart';
import 'package:open_contacts/widgets/my_profile_dialog.dart';
import 'package:open_contacts/widgets/user_profile_dialog.dart';
import 'package:open_contacts/client_holder.dart';



class FriendContextMenu {
  static Future<void> show({
    required BuildContext context,
    required Friend friend,
    required RelativeRect position,
    required List<ContactTab> tabs,
  }) async {
    final mClient = Provider.of<MessagingClient>(context, listen: false);
    final tabsConfig = Provider.of<ContactTabsConfig>(context, listen: false);

    final result = await showMenu<String>(
      context: context,
      position: position,
      items: [
        PopupMenuItem<String>(
          value: 'profile',
          child: const Row(
            children: [
              Icon(Icons.person),
              SizedBox(width: 8),
              Text('View Profile'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'message',
          child: const Row(
            children: [
              Icon(Icons.message),
              SizedBox(width: 8),
              Text('Message'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'boop',
          child: const Row(
            children: [
              Icon(Icons.notifications),
              SizedBox(width: 8),
              Text('Boop'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'pin',
          child: Row(
            children: [
              Icon(friend.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
              const SizedBox(width: 8),
              Text(friend.isPinned ? 'Unpin' : 'Pin'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'block',
          child: const Row(
            children: [
              Icon(Icons.block, color: Colors.red),
              SizedBox(width: 8),
              Text('Block', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'categories',
          child: MouseRegion(
            onEnter: (event) async {
              if (context.mounted && tabs.isNotEmpty) {
                final RenderBox button = context.findRenderObject() as RenderBox;
                final position = RelativeRect.fromLTRB(
                  event.position.dx + 200, // Right of main menu
                  event.position.dy,       // Same vertical position as main menu
                  event.position.dx + 200, // Keep width consistent
                  event.position.dy + 200  // Allow space for submenu items
                );

                final categoryResult = await showMenu<Map<String, String>>(
                  context: context,
                  position: position,
                  items: [
                    for (final tab in tabs)
                      CheckedPopupMenuItem<Map<String, String>>(
                        value: {'tabId': tab.id, 'action': tabsConfig.isUserInTab(friend.id, tab.id) ? 'remove' : 'add'},
                        checked: tabsConfig.isUserInTab(friend.id, tab.id),
                        child: Text(tab.label),
                      ),
                  ],
                );

                if (categoryResult != null && context.mounted) {
                  if (categoryResult['action'] == 'add') {
                    tabsConfig.addUserToTab(friend.id, categoryResult['tabId']!);
                  } else {
                    tabsConfig.removeUserFromTab(friend.id, categoryResult['tabId']!);
                  }
                }
              }
            },
            child: Row(
              children: [
                const Icon(Icons.category),
                const SizedBox(width: 8),
                const Text('Categories'),
                const Spacer(),
                const Icon(Icons.arrow_right),
              ],
            ),
          ),
        ),
      ],
    );

    if (!context.mounted) return;

    switch (result) {
      case 'profile':
        final myId = ClientHolder.of(context).apiClient.userId;
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (context) => friend.id == myId 
              ? const MyProfileDialog()
              : UserProfileDialog(friend: friend),
          );
        }
        break;
      case 'message':
        mClient.loadUserMessageCache(friend.id);
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
          mClient.selectedFriend = null;
        }
        break;
      case 'boop':
        // TODO: Implement boop
        break;
      case 'pin':
        await mClient.toggleFriendPin(friend);
        break;
      case 'block':
        await mClient.blockFriend(friend);
        break;
      case 'categories':
        if (context.mounted && tabs.isNotEmpty) {
          final tabsConfig = Provider.of<ContactTabsConfig>(context, listen: false);
          final RenderBox button = context.findRenderObject() as RenderBox;
          final position = RelativeRect.fromRect(
            Rect.fromPoints(
              button.localToGlobal(Offset.zero),
              button.localToGlobal(button.size.bottomRight(Offset.zero)),
            ),
            Offset.zero & MediaQuery.of(context).size,
          );
          
          final categoryResult = await showMenu<Map<String, String>>(
            context: context,
            position: position,
            items: [
              for (final tab in tabs)
                CheckedPopupMenuItem<Map<String, String>>(
                  value: {'tabId': tab.id, 'action': tabsConfig.isUserInTab(friend.id, tab.id) ? 'remove' : 'add'},
                  checked: tabsConfig.isUserInTab(friend.id, tab.id),
                  child: Text(tab.label),
                ),
            ],
          );

          if (categoryResult != null && context.mounted) {
            if (categoryResult['action'] == 'add') {
              tabsConfig.addUserToTab(friend.id, categoryResult['tabId']!);
            } else {
              tabsConfig.removeUserFromTab(friend.id, categoryResult['tabId']!);
            }
          }
        }
        break;
    }
  }
} 