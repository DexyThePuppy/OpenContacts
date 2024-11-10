import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_contacts/models/users/friend.dart';
import 'package:open_contacts/models/contact_tabs_config.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

class CategoryManagementDialog extends StatefulWidget {
  final Friend friend;

  const CategoryManagementDialog({
    super.key,
    required this.friend,
  });

  @override
  State<CategoryManagementDialog> createState() =>
      _CategoryManagementDialogState();
}

class _CategoryManagementDialogState extends State<CategoryManagementDialog> {
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final tabsConfig = Provider.of<ContactTabsConfig>(context, listen: false);
    _controllers = {
      for (var tab in tabsConfig.tabs)
        tab.id: TextEditingController(text: tab.label)
    };
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabsConfig = Provider.of<ContactTabsConfig>(context);

    return AlertDialog(
      title: Text('Manage Categories for ${widget.friend.username}'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: tabsConfig.tabs.length,
          itemBuilder: (context, index) {
            final tab = tabsConfig.tabs[index];
            return ListTile(
              title: TextField(
                controller: _controllers[tab.id],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: Theme.of(context).textTheme.titleMedium,
                onChanged: (newLabel) {
                  if (newLabel.isNotEmpty) {
                    tabsConfig.updateTabLabel(tab.id, newLabel);
                  }
                },
              ),
              leading: InkWell(
                onTap: () async {
                  IconPickerIcon? icon = await showIconPicker(context);
                  if (icon != null) {
                    tabsConfig.updateTabIcon(
                        tab.id, icon.data.codePoint.toString());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: tab.icon != null
                      ? Icon(
                          IconData(int.tryParse(tab.icon!) ?? 0xe3af,
                              fontFamily: 'MaterialIcons'),
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : Icon(
                          Icons.label,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                ),
              ),
              trailing: Checkbox(
                value: tabsConfig.isUserInTab(widget.friend.id, tab.id),
                onChanged: (bool? value) {
                  if (value == true) {
                    tabsConfig.addUserToTab(widget.friend.id, tab.id);
                  } else {
                    tabsConfig.removeUserFromTab(widget.friend.id, tab.id);
                  }
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
