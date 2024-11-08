import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_contacts/clients/session_client.dart';
import 'package:open_contacts/widgets/sessions/session_filter_dialog.dart';
import 'package:open_contacts/models/view_modes.dart';

class SessionListAppBar extends StatefulWidget {
  const SessionListAppBar({super.key});

  @override
  State<SessionListAppBar> createState() => _SessionListAppBarState();
}

class _SessionListAppBarState extends State<SessionListAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Sessions"),
      actions: [
        Builder(
          builder: (context) {
            final client = Provider.of<SessionClient>(context);
            return PopupMenuButton<ViewMode>(
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
            );
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () async {
            final sessionClient = Provider.of<SessionClient>(context, listen: false);
            await showDialog(
              context: context,
              builder: (context) => ChangeNotifierProvider.value(
                value: sessionClient,
                child: SessionFilterDialog(
                  lastFilter: sessionClient.filterSettings,
                ),
              ),
            );
          },
          icon: const Icon(Icons.filter_alt_outlined),
        ),
      ],
    );
  }
}
