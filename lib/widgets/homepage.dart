import 'package:flutter/material.dart';
import 'package:open_contacts/widgets/friends/friends_list.dart';
import 'package:open_contacts/widgets/friends/friends_list_app_bar.dart';
import 'package:open_contacts/widgets/inventory/inventory_browser.dart';
import 'package:open_contacts/widgets/inventory/inventory_browser_app_bar.dart';
import 'package:open_contacts/widgets/sessions/session_list.dart';
import 'package:open_contacts/widgets/sessions/session_list_app_bar.dart';
import 'package:open_contacts/widgets/settings_app_bar.dart';
import 'package:open_contacts/widgets/settings_page.dart';
import 'package:open_contacts/client_holder.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const List<Widget> _appBars = [
    SessionListAppBar(),
    FriendsListAppBar(),
    InventoryBrowserAppBar(),
    SettingsAppBar()
  ];
  final PageController _pageController = PageController();
  late int _selectedPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final settingsClient = ClientHolder.of(context).settingsClient;
      setState(() {
        _selectedPage =
            settingsClient.currentSettings.lastSelectedPage.valueOrDefault;
      });
      _pageController.jumpToPage(_selectedPage);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _changePage(int index) async {
    final settingsClient = ClientHolder.of(context).settingsClient;
    await settingsClient.changeSettings(
        settingsClient.currentSettings.copyWith(lastSelectedPage: index));
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
    setState(() {
      _selectedPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _appBars[_selectedPage],
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          SessionList(),
          FriendsList(),
          InventoryBrowser(),
          SettingsPage(),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          color: Theme.of(context).colorScheme.surface,
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            height: 64,
        selectedIndex: _selectedPage,
        onDestinationSelected: _changePage,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.public),
            label: "Sessions",
          ),
          NavigationDestination(
            icon: Icon(Icons.contacts),
            label: "Contacts",
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory),
            label: "Inventory",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
          ),
        ),
      ),
    );
  }
}
