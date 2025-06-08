import 'package:flutter/material.dart';
import 'package:powerpulse/src/dynamicForm/measurment.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:powerpulse/src/devices/recent_devices.dart';
import 'package:powerpulse/src/settings/settings_view.dart';
import 'package:powerpulse/src/network/ping_indicator.dart';
import 'package:powerpulse/src/network/terminal.dart';
import 'package:powerpulse/src/methods/methods.dart';
import 'package:powerpulse/src/globals.dart' as globals;
import 'package:provider/provider.dart';
import 'package:powerpulse/src/app_provider.dart';

class StartPage extends StatelessWidget {
  StartPage({super.key});
  static const routeName = '/';
  static const title = 'PowerPulse';
  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: canvasColor,
        title: const Text(title),
        leading:
            isSmallScreen
                ? Row(
                  children: <Widget>[
                    const BackButton(),
                    IconButton(
                      onPressed: () {
                        // if (!Platform.isAndroid && !Platform.isIOS) {
                        //   _controller.setExtended(true);
                        // }
                        _key.currentState?.openDrawer();
                      },
                      icon: const Icon(Icons.menu),
                    ),
                  ],
                )
                : const BackButton(),
        leadingWidth: isSmallScreen ? 90 : null,
        actions: const [
          PingIndicator(),
          // IconButton(
          //   icon: const Icon(Icons.settings),
          //   onPressed: () {
          //     // Navigate to the settings page. If the user leaves and returns
          //     // to the app after it has been killed while running in the
          //     // background, the navigation stack is restored.
          //     Navigator.restorablePushNamed(context, SettingsView.routeName);
          //   },
          // ),
        ],
      ),
      drawer: MainSidebar(controller: _controller),
      body: Row(
        children: [
          if (!isSmallScreen) MainSidebar(controller: _controller),
          Expanded(
            child: Center(
              child: _DeviceMethodsListView(controller: _controller),
            ),
          ),
        ],
      ),
    );
  }
}

class MainSidebar extends StatelessWidget {
  MainSidebar({Key? key, required SidebarXController controller})
    : _controller = controller,
      super(key: key);

  final SidebarXController _controller;
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: scaffoldBackgroundColor,
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        hoverTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: canvasColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: actionColor.withOpacity(0.37)),
          gradient: const LinearGradient(
            colors: [accentCanvasColor, canvasColor],
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.28), blurRadius: 30),
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 20),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(color: canvasColor),
      ),
      footerDivider: divider,
      headerBuilder: (context, extended) {
        return SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset('assets/images/avatar.png'),
          ),
        );
      },
      items: [
        const SidebarXItem(
          icon: Icons.settings,
          label: 'New Measurment',
          selectable: false,
        ),
        SidebarXItem(
          icon: Icons.settings,
          label: 'My Measurments',
          selectable: false,
          onTap:
              () => Navigator.restorablePushNamed(context, Methods.routeName),
        ),
        SidebarXItem(
          icon: Icons.settings,
          label: 'Settings',
          selectable: false,
          onTap:
              () => Navigator.restorablePushNamed(
                context,
                SettingsView.routeName,
              ),
        ),
        SidebarXItem(
          icon: Icons.device_hub,
          label: 'Terminal',
          selectable: false,
          onTap:
              () => Navigator.restorablePushNamed(context, Terminal.routeName),
        ),
        SidebarXItem(
          icon: Icons.device_unknown,
          label: 'Devices',
          selectable: false,
          onTap:
              () => Navigator.restorablePushNamed(
                context,
                RecentDevices.routeName,
              ),
        ),
        // SidebarXItem(
        //   icon: Icons.exit_to_app,
        //   label: 'Exit',
        //   selectable: false,
        //   onTap: () => Navigator.of(context).pop(),
        // ),
      ],
    );
  }
}

class _DeviceMethodsListView extends StatefulWidget {
  _DeviceMethodsListView({Key? key, required this.controller})
    : super(key: key);

  final SidebarXController controller;

  @override
  State<_DeviceMethodsListView> createState() => _DeviceMethodsListViewState();
}

class _DeviceMethodsListViewState extends State<_DeviceMethodsListView> {
  Map<dynamic, dynamic> data = {"inputs": {}, "outputs": {}, "figures": {}};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        switch (widget.controller.selectedIndex) {
          case 0:
            if (appProvider.connectedDeviceMethods.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Not connected to the device'),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: appProvider.connectedDeviceMethods.length,
              itemBuilder: (context, index) {
                List<String> keys =
                    appProvider.connectedDeviceMethods.keys.toList();
                return ListTile(
                  title: Text(
                    appProvider
                        .connectedDeviceMethods[keys[index]]['inputs']['title'],
                  ),
                  selected: widget.controller.selectedIndex == index,
                  onTap: () {
                    // Optionally update controller.selectedIndex when tapping
                    // widget.controller.selectIndex(index);
                    Navigator.restorablePushNamed(
                      context,
                      Measurment.routeName,
                      arguments: {
                        'type': keys[index],
                        'schema':
                            appProvider.connectedDeviceMethods[keys[index]],
                        'data': data,
                      },
                    );
                  },
                );
              },
            );
          default:
            return Text('Not implemented yet.');
        }
      },
    );
  }
}

const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);
