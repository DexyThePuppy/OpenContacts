import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:background_downloader/background_downloader.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:open_contacts/apis/github_api.dart';
import 'package:open_contacts/client_holder.dart';
import 'package:open_contacts/clients/api_client.dart';
import 'package:open_contacts/clients/inventory_client.dart';
import 'package:open_contacts/clients/messaging_client.dart';
import 'package:open_contacts/clients/session_client.dart';
import 'package:open_contacts/clients/settings_client.dart';
import 'package:open_contacts/models/sem_ver.dart';
import 'package:open_contacts/widgets/homepage.dart';
import 'package:open_contacts/widgets/login_screen.dart';
import 'package:open_contacts/widgets/update_notifier.dart';
import 'package:open_contacts/models/contact_tabs_config.dart';

import 'models/authentication_data.dart';

final _logger = Logger('main');
late final ContactTabsConfig tabsConfig;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the initial config
  final jsonString =
      await rootBundle.loadString('assets/config/contact_tabs.json');
  tabsConfig = ContactTabsConfig.fromJson(jsonString);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: true,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top]);

  await Hive.initFlutter();

  final dateFormat = DateFormat.Hms();
  Logger.root.onRecord.listen((event) => log(
      "${dateFormat.format(event.time)}: ${event.message}",
      name: event.loggerName,
      time: event.time));

  final settingsClient = SettingsClient();
  await settingsClient.loadSettings();
  final newSettings = settingsClient.currentSettings.copyWith(
      machineId: settingsClient.currentSettings.machineId.valueOrDefault);
  await settingsClient
      .changeSettings(newSettings); // Save generated machineId to disk

  AuthenticationData cachedAuth = AuthenticationData.unauthenticated();
  try {
    cachedAuth = await ApiClient.tryCachedLogin();
    _logger.info('Successfully retrieved cached login');
  } catch (e) {
    _logger.warning('Failed to retrieve cached login: $e');
    // Still ignore but at least log the error
  }

  runApp(
      Recon(settingsClient: settingsClient, cachedAuthentication: cachedAuth));
}

class Recon extends StatefulWidget {
  const Recon(
      {required this.settingsClient,
      required this.cachedAuthentication,
      super.key});

  final SettingsClient settingsClient;
  final AuthenticationData cachedAuthentication;

  @override
  State<Recon> createState() => _ReconState();
}

class _ReconState extends State<Recon> {
  final Typography _typography =
      Typography.material2021(platform: defaultTargetPlatform);
  final ReceivePort _port = ReceivePort();
  late AuthenticationData _authData = widget.cachedAuthentication;
  bool _checkedForUpdate = false;

  void showUpdateDialogOnFirstBuild(BuildContext context) {
    final navigator = Navigator.of(context);
    final settings = ClientHolder.of(context).settingsClient;
    if (_checkedForUpdate) return;
    _checkedForUpdate = true;

    GithubApi.getLatestTagName().then((remoteVer) async {
      if (!mounted) return;

      final currentVer = (await PackageInfo.fromPlatform()).version;
      SemVer currentSem;
      SemVer remoteSem;
      SemVer lastDismissedSem;

      try {
        currentSem = SemVer.fromString(currentVer);
      } catch (_) {
        currentSem = SemVer.zero();
      }

      try {
        lastDismissedSem = SemVer.fromString(
            settings.currentSettings.lastDismissedVersion.valueOrDefault);
      } catch (_) {
        lastDismissedSem = SemVer.zero();
      }

      try {
        remoteSem = SemVer.fromString(remoteVer);
      } catch (_) {
        return;
      }

      if (remoteSem <= lastDismissedSem && lastDismissedSem.isNotZero) {
        return;
      }

      if (remoteSem > currentSem && mounted) {
        showDialog(
          context: navigator.overlay!.context,
          builder: (context) => UpdateNotifier(
            remoteVersion: remoteSem,
            localVersion: currentSem,
          ),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      // Not useful yet? idk...
      // String id = data[0];
      // DownloadTaskStatus status = data[1];
      // int progress = data[2];
    });

    FileDownloader().updates.listen(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(TaskUpdate event) {}

  @override
  Widget build(BuildContext context) {
    return Phoenix(
      child: Builder(builder: (context) {
        return ClientHolder(
          settingsClient: widget.settingsClient,
          authenticationData: _authData,
          onLogout: () =>
              setState(() => _authData = AuthenticationData.unauthenticated()),
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => tabsConfig),
              ChangeNotifierProvider(
                create: (context) {
                  final clientHolder =
                      context.findAncestorWidgetOfExactType<ClientHolder>();
                  if (clientHolder == null)
                    throw Exception('ClientHolder not found');
                  return MessagingClient(
                    apiClient: clientHolder.apiClient,
                    settingsClient: clientHolder.settingsClient,
                    notificationClient: clientHolder.notificationClient,
                  );
                },
              ),
              ChangeNotifierProvider(
                create: (context) {
                  final clientHolder =
                      context.findAncestorWidgetOfExactType<ClientHolder>();
                  if (clientHolder == null)
                    throw Exception('ClientHolder not found');
                  return SessionClient(
                    apiClient: clientHolder.apiClient,
                    settingsClient: clientHolder.settingsClient,
                  );
                },
                lazy: false,
              ),
              ChangeNotifierProvider(
                create: (context) {
                  final clientHolder =
                      context.findAncestorWidgetOfExactType<ClientHolder>();
                  if (clientHolder == null)
                    throw Exception('ClientHolder not found');
                  return InventoryClient(
                    apiClient: clientHolder.apiClient,
                  );
                },
              )
            ],
            child: Builder(builder: (context) {
              final useSystemColor = ClientHolder.of(context)
                  .settingsClient
                  .currentSettings
                  .useSystemColor
                  .valueOrDefault;
              final customColor = Color(ClientHolder.of(context)
                      .settingsClient
                      .currentSettings
                      .customColor
                      .valueOrDefault ??
                  Colors.blue.value);

              return DynamicColorBuilder(
                builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: true,
                    title: 'open_contacts',
                    theme: ThemeData(
                      useMaterial3: true,
                      textTheme: _typography.black,
                      colorScheme: useSystemColor
                          ? (lightDynamic ??
                              ColorScheme.fromSeed(
                                  seedColor: customColor,
                                  brightness: Brightness.light))
                          : ColorScheme.fromSeed(
                              seedColor: customColor,
                              brightness: Brightness.light),
                    ),
                    darkTheme: ThemeData(
                      useMaterial3: true,
                      textTheme: _typography.white,
                      colorScheme: useSystemColor
                          ? (darkDynamic ??
                              ColorScheme.fromSeed(
                                  seedColor: customColor,
                                  brightness: Brightness.dark))
                          : ColorScheme.fromSeed(
                              seedColor: customColor,
                              brightness: Brightness.dark),
                    ),
                    themeMode: ThemeMode.values[ClientHolder.of(context)
                        .settingsClient
                        .currentSettings
                        .themeMode
                        .valueOrDefault],
                    home: Builder(
                      // Builder is necessary here since we need a context which has access to the ClientHolder
                      builder: (context) {
                        showUpdateDialogOnFirstBuild(context);
                        return _authData.isAuthenticated
                            ? AnnotatedRegion<SystemUiOverlayStyle>(
                                value: SystemUiOverlayStyle(
                                  statusBarColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                ),
                                child: const Home(),
                              )
                            : LoginScreen(
                                onLoginSuccessful:
                                    (AuthenticationData authData) async {
                                  if (authData.isAuthenticated) {
                                    setState(() {
                                      _authData = authData;
                                    });
                                  }
                                },
                              );
                      },
                    ),
                  );
                },
              );
            }),
          ),
        );
      }),
    );
  }
}
