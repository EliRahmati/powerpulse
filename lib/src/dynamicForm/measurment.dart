import 'package:flutter/material.dart';
import 'package:powerpulse/src/dynamicForm/output_figures.dart';
import 'package:powerpulse/src/dynamicForm/output_data.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:powerpulse/src/devices/recent_devices.dart';
import 'package:powerpulse/src/settings/settings_view.dart';
import 'package:powerpulse/src/dynamicForm/dynamicForm.dart';
import 'package:powerpulse/src/dynamicForm/figures.dart';
import 'package:powerpulse/src/network/terminal.dart';
import 'package:powerpulse/src/network/ping_indicator.dart';

class Measurment extends StatelessWidget {
  Measurment({
    Key? key,
    required this.type,
    required this.schema,
    required this.data,
  }) : super(key: key);
  static const routeName = '/measurment';
  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  final String type;
  final Map<dynamic, dynamic> schema;
  final Map<dynamic, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: canvasColor,
        title: const Text('Measurment'),
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
      drawer: MethodSidebar(controller: _controller),
      body: Row(
        children: [
          if (!isSmallScreen) MethodSidebar(controller: _controller),
          Expanded(
            child: Center(
              child: _NewMeasurmentWidget(
                controller: _controller,
                schema: schema,
                data: data,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MethodSidebar extends StatelessWidget {
  const MethodSidebar({Key? key, required SidebarXController controller})
    : _controller = controller,
      super(key: key);

  final SidebarXController _controller;

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
        const SidebarXItem(icon: Icons.input, label: 'Inputs'),
        const SidebarXItem(icon: Icons.analytics, label: 'Ouputs'),
        const SidebarXItem(icon: Icons.table_view, label: 'Data'),
        const SidebarXItem(icon: Icons.image, label: 'Figures'),
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
          icon: Icons.device_hub,
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

class _NewMeasurmentWidget extends StatefulWidget {
  final SidebarXController controller;
  final Map<dynamic, dynamic> schema;
  Map<dynamic, dynamic> data;

  _NewMeasurmentWidget({
    super.key,
    required this.controller,
    required this.schema,
    required this.data,
  });

  @override
  _NewMeasurmentWidgetState createState() => _NewMeasurmentWidgetState();
}

class _NewMeasurmentWidgetState extends State<_NewMeasurmentWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        switch (widget.controller.selectedIndex) {
          case 0:
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: DynamicForm(
                schema: widget.schema,
                data: widget.data,
                onValueChange: (value) {
                  print(value);
                  setState(() {
                    widget.data = value;
                  });
                },
              ),
            );
          case 1:
            return OutputFigures(schema: widget.schema, data: widget.data);
          case 2:
            return OutputData(schema: widget.schema, data: widget.data);
          case 3:
            return Figures(schema: widget.schema, data: widget.data);
          case 4:
            // return WebSocketDemo();
            return ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: 20,
              itemBuilder:
                  (context, index) => Container(
                    height: 100,
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 200),
                    margin: const EdgeInsets.only(
                      bottom: 10,
                      right: 10,
                      left: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.deepOrangeAccent,
                      boxShadow: const [BoxShadow()],
                    ),
                  ),
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
