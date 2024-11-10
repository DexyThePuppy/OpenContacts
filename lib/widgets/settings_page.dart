import 'package:open_contacts/client_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:open_contacts/clients/settings_client.dart';
import 'package:open_contacts/auxiliary.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sClient = ClientHolder.of(context).settingsClient;
    return ListView(
      children: [
        const ListSectionHeader(leadingText: "Notifications"),
        BooleanSettingsTile(
          title: "Enable Notifications",
          initialState:
              !sClient.currentSettings.notificationsDenied.valueOrDefault,
          onChanged: (value) async => await sClient.changeSettings(
              sClient.currentSettings.copyWith(notificationsDenied: !value)),
        ),
        ListTile(
          enabled: !sClient.currentSettings.notificationsDenied.valueOrDefault,
          trailing: const Icon(Icons.notification_add),
          title: const Text("Send Test Notification"),
          onTap: () async {
            await ClientHolder.of(context).notificationClient.showNotification(
                  title: "Test Notification",
                  body: "This is a test notification! Woof! 🐾",
                );
          },
        ),
        const ListSectionHeader(leadingText: "Appearance"),
        BooleanSettingsTile(
          title: "Use System Accent Color",
          initialState: sClient.currentSettings.useSystemColor.valueOrDefault,
          onChanged: (value) async {
            await sClient.changeSettings(sClient.currentSettings.copyWith(
                useSystemColor: value,
                customColor: !value
                    ? sClient.currentSettings.customColor.valueOrDefault ??
                        Colors.blue.value
                    : null));
            if (context.mounted) {
              Phoenix.rebirth(context);
            }
          },
        ),
        ListTile(
          trailing: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Color(sClient.currentSettings.customColor.valueOrDefault ??
                  Colors.blue.value),
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
          ),
          title: const Text("Accent Color"),
          onTap: () => _showColorPicker(context, sClient),
        ),
        ListTile(
          trailing: StatefulBuilder(builder: (context, setState) {
            return DropdownButton<ThemeMode>(
              items: ThemeMode.values
                  .map((mode) => DropdownMenuItem<ThemeMode>(
                        value: mode,
                        child: Text(
                          toBeginningOfSentenceCase(mode.name),
                        ),
                      ))
                  .toList(),
              value: ThemeMode
                  .values[sClient.currentSettings.themeMode.valueOrDefault],
              onChanged: (ThemeMode? value) async {
                final currentSetting = sClient.currentSettings.themeMode.value;
                if (currentSetting != value?.index) {
                  await sClient.changeSettings(sClient.currentSettings
                      .copyWith(themeMode: value?.index));
                  if (context.mounted) {
                    Phoenix.rebirth(context);
                  }
                }
                setState(() {});
              },
            );
          }),
          title: const Text("Theme Mode"),
        ),
        const ListSectionHeader(leadingText: "Other"),
        ListTile(
          trailing: const Icon(Icons.logout),
          title: const Text("Sign out"),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  "Are you sure you want to sign out?",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("No")),
                  TextButton(
                    onPressed: () async {
                      await ClientHolder.of(context).apiClient.logout();
                    },
                    child: const Text("Yes"),
                  ),
                ],
              ),
            );
          },
        ),
        ListTile(
          trailing: const Icon(Icons.info_outline),
          title: const Text("About OpenContacts"),
          onTap: () async {
            final version = await PackageInfo.fromPlatform();
            if (!context.mounted) return;

            showAboutDialog(
              context: context,
              applicationVersion: version.version,
              applicationIcon: InkWell(
                onTap: () async {
                  if (!await launchUrl(
                      Uri.parse(
                          "https://git.mrdab.vore.media/ThatOneJackalGuy/Opencontacts"),
                      mode: LaunchMode.externalApplication)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Failed to open link.")));
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(16),
                  constraints: const BoxConstraints(maxWidth: 64),
                  child: Image.asset("assets/images/testingIcon512.png"),
                ),
              ),
              applicationLegalese:
                  "ReCon by Nutcake, OpenContacts by ThatOneJackalGuy. Both apps made with <3",
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.link),
          title: const Text('ResDB Link Converter'),
          subtitle: const Text('Convert ResDB links to HTTP URLs'),
          onTap: () => _showResDBConverter(context),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context, SettingsClient sClient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color currentColor = Color(
            sClient.currentSettings.customColor.valueOrDefault ??
                Colors.blue.value);
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                currentColor = color;
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                await sClient.changeSettings(
                  sClient.currentSettings
                      .copyWith(customColor: currentColor.value),
                );
                if (context.mounted) {
                  Phoenix.rebirth(context);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showResDBConverter(BuildContext context) {
    final textController = TextEditingController();
    final resultController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ResDB Link Converter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  labelText: 'Enter ResDB Link',
                  hintText: 'resdb:///example...',
                ),
                onChanged: (value) {
                  resultController.text = Aux.resdbToHttp(value);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resultController,
                decoration: const InputDecoration(
                  labelText: 'HTTP Link',
                ),
                readOnly: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class ListSectionHeader extends StatelessWidget {
  const ListSectionHeader(
      {required this.leadingText,
      this.trailingText,
      this.showLine = true,
      super.key});

  final String leadingText;
  final String? trailingText;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(leadingText, style: textTheme),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: Colors.white12,
              height: showLine ? 1 : 0,
            ),
          ),
          if (trailingText != null)
            Text(
              trailingText!,
              style: textTheme,
            ),
        ],
      ),
    );
  }
}

class BooleanSettingsTile extends StatefulWidget {
  const BooleanSettingsTile(
      {required this.title,
      required this.initialState,
      required this.onChanged,
      super.key});

  final String title;
  final bool initialState;
  final Function(bool) onChanged;

  @override
  State<StatefulWidget> createState() => _BooleanSettingsTileState();
}

class _BooleanSettingsTileState extends State<BooleanSettingsTile> {
  late bool state = widget.initialState;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: Switch(
        onChanged: (value) async {
          await widget.onChanged(value);
          setState(() {
            state = value;
          });
        },
        value: state,
      ),
      title: Text(widget.title),
      onTap: () async {
        await widget.onChanged(!state);
        setState(() {
          state = !state;
        });
      },
    );
  }
}
