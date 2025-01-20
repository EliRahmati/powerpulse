import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:powerpulse/src/devices/devices_view.dart';
import 'package:powerpulse/src/settings/settings_view.dart';
import 'package:powerpulse/src/dynamicForm/dynamicForm.dart';
import 'package:powerpulse/src/network/websocket.dart';

class MethodApp extends StatelessWidget {
  MethodApp(
      {Key? key, required this.type, required this.id, required this.title})
      : super(key: key);
  static const routeName = '/method';
  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  final String type;
  final String id;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: canvasColor,
        title: Text(type + ' ' + title),
        leading: isSmallScreen
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
          IconButton(
            icon: const Icon(Icons.circle),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, DeviceScanner.routeName);
            },
          ),
        ],
      ),
      drawer: MethodSidebar(controller: _controller),
      body: Row(
        children: [
          if (!isSmallScreen) MethodSidebar(controller: _controller),
          Expanded(
            child: Center(
              child: _ScreensExampleWidget(
                controller: _controller,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MethodSidebar extends StatelessWidget {
  const MethodSidebar({
    Key? key,
    required SidebarXController controller,
  })  : _controller = controller,
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
          border: Border.all(
            color: actionColor.withOpacity(0.37),
          ),
          gradient: const LinearGradient(
            colors: [accentCanvasColor, canvasColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: canvasColor,
        ),
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
          icon: Icons.input,
          label: 'Inputs',
        ),
        const SidebarXItem(
          icon: Icons.analytics,
          label: 'Figure',
        ),
        SidebarXItem(
          icon: Icons.settings,
          label: 'Settings',
          selectable: false,
          onTap: () =>
              Navigator.restorablePushNamed(context, SettingsView.routeName),
        ),
        SidebarXItem(
          icon: Icons.device_unknown,
          label: 'Devices',
          selectable: false,
          onTap: () =>
              Navigator.restorablePushNamed(context, DeviceScanner.routeName),
        ),
        SidebarXItem(
          icon: Icons.exit_to_app,
          label: 'Exit',
          selectable: false,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _ScreensExampleWidget extends StatefulWidget {
  final SidebarXController controller;

  const _ScreensExampleWidget({
    super.key,
    required this.controller,
  });

  @override
  _ScreensExampleWidgetState createState() => _ScreensExampleWidgetState();
}

class _ScreensExampleWidgetState extends State<_ScreensExampleWidget> {
  late Map<String, dynamic> data;

  @override
  void initState() {
    super.initState();
    data = {
      "name": "my name",
      "time": 5.5,
      "time_shown_unitprefix": "m",
      "int": 8,
      "bool": true,
      "birthdate": "2000-01-01",
      "run_time": 10000,
      "meeting_datetime": "2024-11-17T14:30:00",
      "gender": "Male",
      "description": "",
      "x": 4,
      "x_shown_unitprefix": "",
      "v": 2,
      "v_shown_unitprefix": "",
      "t": 2,
      "t_shown_unitprefix": "",
      "times": [2.0, 4.0, 5.0],
      "times_shown_unitprefix": "",
      "numbers": [2, 6, 9, 0, 8],
      "xarr": [1.0, 4.0, 12.0],
      "xarr_shown_unitprefix": "",
      "varr": [1.0, 2.0, 4.0],
      "varr_shown_unitprefix": "",
      "tarr": [1.0, 2.0, 3.0],
      "tarr_shown_unitprefix": "",
      "normx": 4,
      "normx_shown_unitprefix": "",
      "intxarr": [1, 5],
    };
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
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),
                child: DynamicForm(
                    schema: const {
                      "title": "Sample Form",
                      "properties": {
                        "description": {
                          "type": "richtext",
                          "title": "my description",
                        },
                        "name": {
                          "type": "string",
                          "title": "My Name",
                          "description": "Enter your full name.",
                          "maxLength": 50
                        },
                        "time": {
                          "type": "float",
                          "title": "My Time",
                          "description": "Enter time.",
                          "minimum": 0,
                          "maximum": 100,
                          "unit": "s"
                        },
                        "x": {
                          "type": "float",
                          "title": "x",
                          "description": "Enter time.",
                          "minimum": 0,
                          "maximum": 100,
                          "unit": "m",
                          "exp": ["v = x / t"]
                        },
                        "v": {
                          "type": "float",
                          "title": "v",
                          "description": "Enter time.",
                          "minimum": 0,
                          "maximum": 100,
                          "unit": "m/s",
                          "exp": ["x = v * t"]
                        },
                        "t": {
                          "type": "float",
                          "title": "t",
                          "description": "Enter time.",
                          "minimum": 0,
                          "maximum": 100,
                          "unit": "s",
                          "exp": ["x = sqrt(t)", "int = t"]
                        },
                        "int": {
                          "type": "integer",
                          "title": "My Int",
                          "description": "Enter an integer value.",
                          "minimum": 1,
                          "maximum": 10
                        },
                        "bool": {
                          "type": "boolean",
                          "title": "My Bool",
                          "description": "Toggle the switch."
                        },
                        "birthdate": {"type": "date", "title": "Birth Date"},
                        "run_time": {"type": "duration", "title": "Run Time"},
                        "meeting_datetime": {
                          "type": "datetime",
                          "title": "Meeting Date & Time"
                        },
                        "gender": {
                          "type": "enum",
                          "title": "Gender",
                          "enum": ["Male", "Female", "Other"]
                        },
                        "times": {
                          "type": "float[]",
                          "title": "My Times",
                          "description": "Enter time.",
                          "minimum": 0,
                          "maximum": 100,
                          "unit": "s"
                        },
                        "numbers": {
                          "type": "integer[]",
                          "title": "My numbers",
                          "description": "Enter number.",
                          "minimum": 0,
                          "maximum": 100,
                        },
                        "xarr": {
                          "type": "float[]",
                          "title": "x",
                          "description": "Enter x array.",
                          "minimum": 0,
                          "maximum": 100,
                          "unit": "m",
                          "exp": ["normx = norm(xarr)"]
                        },
                        "normx": {
                          "type": "float",
                          "title": "normx",
                          "description": "Enter time.",
                          "minimum": 0,
                          "maximum": 20,
                          "unit": "m"
                        },
                        "varr": {
                          "type": "float[]",
                          "title": "v",
                          "description": "Enter v array.",
                          "minimum": 0,
                          "maximum": 100,
                          "unit": "m/s",
                          "exp": ["xarr = sqrt(varr) * 4"]
                        },
                        "tarr": {
                          "type": "float[]",
                          "title": "t",
                          "description": "Enter time array.",
                          "minimum": 0,
                          "maximum": 100,
                          "unit": "s",
                          "exp": ["xarr = floor(tarr)", "intxarr = floor(tarr)"]
                        },
                        "intxarr": {
                          "type": "integer[]",
                          "title": "t",
                          "description": "Enter time array.",
                          "minimum": 0,
                          "maximum": 50
                        }
                      }
                    },
                    data: data,
                    onValueChange: (value) {
                      setState(() {
                        data = value;
                      });
                    }));
          case 1:
            // return WebSocketDemo();
            return ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: 20,
              itemBuilder: (context, index) => Container(
                height: 100,
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 200),
                margin: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
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
