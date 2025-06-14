import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:powerpulse/src/devices/recent_devices.dart';
import 'package:powerpulse/src/settings/settings_view.dart';
import 'method.dart';
import 'method_list_view.dart';
import 'package:powerpulse/src/network/ping_indicator.dart';
import 'package:powerpulse/src/network/terminal.dart';

class Methods extends StatelessWidget {
  Methods({
    super.key,
    this.methods = const [
      MethodType('IV'),
      MethodType('EIS'),
      MethodType('Pulse'),
      MethodType('Battery'),
    ],
  });
  static const routeName = '/methods';
  static const title = 'PowerPulse';
  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();
  final List<MethodType> methods;

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
      drawer: MethodsSidebar(controller: _controller, methods: methods),
      body: Row(
        children: [
          if (!isSmallScreen)
            MethodsSidebar(controller: _controller, methods: methods),
          Expanded(
            child: Center(
              child: _MethodsListView(
                controller: _controller,
                methods: methods,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MethodsSidebar extends StatelessWidget {
  MethodsSidebar({
    Key? key,
    required SidebarXController controller,
    required this.methods,
  }) : _controller = controller,
       super(key: key);

  final SidebarXController _controller;
  final List<MethodType> methods;
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
      items:
          methods.map((method) {
            return SidebarXItem(
              icon: Icons.analytics,
              label: method.methodName,
              onTap: () {
                // if (!Platform.isAndroid && !Platform.isIOS) {
                //   _controller.setExtended(true);
                // }
                _key.currentState?.openDrawer();
              },
            );
          }).toList() +
          [
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
                  () => Navigator.restorablePushNamed(
                    context,
                    Terminal.routeName,
                  ),
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

class _MethodsListView extends StatelessWidget {
  const _MethodsListView({
    Key? key,
    required this.controller,
    required this.methods,
  }) : super(key: key);

  final SidebarXController controller;
  final List<MethodType> methods;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return MethodListView(
          type: methods[controller.selectedIndex].methodName,
        );
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
