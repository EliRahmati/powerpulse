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

class MethodApp extends StatelessWidget {
  MethodApp({
    Key? key,
    required this.type,
    required this.id,
    required this.title,
  }) : super(key: key);
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
              child: _ScreensExampleWidget(controller: _controller),
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

class _ScreensExampleWidget extends StatefulWidget {
  final SidebarXController controller;

  const _ScreensExampleWidget({super.key, required this.controller});

  @override
  _ScreensExampleWidgetState createState() => _ScreensExampleWidgetState();
}

class _ScreensExampleWidgetState extends State<_ScreensExampleWidget> {
  late Map<dynamic, dynamic> data;
  late Map<dynamic, dynamic> schema;

  @override
  void initState() {
    super.initState();
    schema = {
      "inputs": {
        "title": "Sample Form",
        "properties": {
          "description": {
            "type": "richtext",
            "title": "my description",
            "default": "",
          },
          "name": {
            "type": "string",
            "title": "My Name",
            "description": "Enter your full name.",
            "maxLength": 50,
            "default": "",
          },
          "time": {
            "type": "float",
            "title": "My Time",
            "description": "Enter time.",
            "minimum": 0,
            "maximum": 100,
            "unit": "s",
            "shown_unitprefix": "m",
            "default": 0,
          },
          "x": {
            "type": "float",
            "title": "x",
            "description": "Enter time.",
            "minimum": 0,
            "maximum": 100,
            "unit": "m",
            "shown_unitprefix": "m",
            "default": 0,
            "exp": ["v = x / t"],
          },
          "v": {
            "type": "float",
            "title": "v",
            "description": "Enter time.",
            "minimum": 0,
            "maximum": 100,
            "unit": "m/s",
            "default": 0,
            "exp": ["x = v * t"],
          },
          "t": {
            "type": "float",
            "title": "t",
            "description": "Enter time.",
            "minimum": 0,
            "maximum": 100,
            "unit": "s",
            "shown_unitprefix": "",
            "default": 0,
            "exp": ["x = sqrt(t)", "int = t"],
          },
          "int": {
            "type": "integer",
            "title": "My Int",
            "description": "Enter an integer value.",
            "minimum": 1,
            "maximum": 10,
            "default": 1,
          },
          "bool": {
            "type": "boolean",
            "title": "My Bool",
            "description": "Toggle the switch.",
            "default": false,
          },
          "birthdate": {
            "type": "date",
            "title": "Birth Date",
            "default": "2000-01-01",
          },
          "run_time": {"type": "duration", "title": "Run Time", "default": 0},
          "meeting_datetime": {
            "type": "datetime",
            "title": "Meeting Date & Time",
            "default": "2000-01-01",
          },
          "gender": {
            "type": "enum",
            "title": "Gender",
            "enum": ["Male", "Female", "Other"],
            "default": "Male",
          },
          "times": {
            "type": "float[10]",
            "title": "My Times",
            "description": "Enter time.",
            "minimum": -10,
            "maximum": 10,
            "unit": "s",
            "shown_unitprefix": "m",
            "default": [-4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0],
            "defaultEntry": 0.0,
          },
          "numbers": {
            "type": "integer[10]",
            "title": "My numbers",
            "description": "Enter number.",
            "minimum": 0,
            "maximum": 100,
            "default": [0, 2, 6, 4, 2, 1, 1, 1, 1, 0],
            "defaultEntry": 0,
          },
          "numbers2": {
            "type": "integer[10]",
            "title": "My numbers2",
            "description": "Enter number.",
            "minimum": 0,
            "maximum": 100,
            "default": [1, 2, 3, 4, 5, 5, 4, 3, 2, 1],
            "defaultEntry": 0,
          },
          "plot1": {
            "type": "plot",
            "title": "My plot",
            "plotType": "line",
            "x": ["inputs.times"],
            "y": ["inputs.numbers", "inputs.numbers2"],
          },
          "xarr": {
            "type": "float[]",
            "title": "x",
            "description": "Enter x array.",
            "minimum": 0,
            "maximum": 100,
            "unit": "m",
            "shown_unitprefix": "",
            "exp": ["normx = norm(xarr)"],
            "default": [],
            "defaultEntry": 0.0,
          },
          "normx": {
            "type": "float",
            "title": "normx",
            "description": "Enter time.",
            "minimum": 0,
            "maximum": 20,
            "unit": "m",
            "shown_unitprefix": "m",
            "default": 0.0,
          },
          "varr": {
            "type": "float[]",
            "title": "v",
            "description": "Enter v array.",
            "minimum": 0,
            "maximum": 100,
            "unit": "m/s",
            "shown_unitprefix": "",
            "default": [],
            "defaultEntry": 0.0,
            "exp": ["xarr = sqrt(varr) * 4"],
          },
          "tarr": {
            "type": "float[]",
            "title": "t",
            "description": "Enter time array.",
            "minimum": 0,
            "maximum": 100,
            "unit": "s",
            "shown_unitprefix": "k",
            "default": [],
            "defaultEntry": 0.0,
            "exp": ["xarr = floor(tarr)", "intxarr = floor(tarr)"],
          },
          "intxarr": {
            "type": "integer[]",
            "title": "t",
            "description": "Enter time array.",
            "minimum": 0,
            "maximum": 50,
            "default": [],
            "defaultEntry": 0,
          },
          "myobject": {
            "type": 'object',
            "title": "my object",
            "description": "Enter object.",
            "default": [],
            "properties": {
              "t": {
                "type": "float",
                "title": "t",
                "description": "Enter time.",
                "minimum": 0,
                "maximum": 100,
                "unit": "s",
                "shown_unitprefix": "m",
                "default": 0,
              },
              "v": {
                "type": "float",
                "title": "v",
                "description": "Enter voltage.",
                "minimum": 0,
                "maximum": 100,
                "unit": "Volt",
                "shown_unitprefix": "",
                "default": 0,
              },
              "int": {
                "type": "integer",
                "title": "My Int",
                "description": "Enter an integer value.",
                "minimum": 1,
                "maximum": 10,
                "default": 1,
              },
            },
          },
          "myobjectlist": {
            "type": 'object[]',
            "title": "my object list",
            "description": "Enter object.",
            "default": [],
            "properties": {
              "t": {
                "type": "float",
                "title": "t",
                "description": "Enter time.",
                "minimum": 0,
                "maximum": 100,
                "unit": "s",
                "shown_unitprefix": "m",
                "default": 0,
              },
              "v": {
                "type": "float",
                "title": "v",
                "description": "Enter voltage.",
                "minimum": 0,
                "maximum": 100,
                "unit": "Volt",
                "shown_unitprefix": "",
                "default": 0,
              },
              "int": {
                "type": "integer",
                "title": "My Int",
                "description": "Enter an integer value.",
                "minimum": 1,
                "maximum": 10,
                "default": 1,
              },
            },
          },
          "plot2": {
            "type": "plot",
            "title": "My plot",
            "plotType": "line",
            "x": ["inputs.myobjectlist.t", "inputs.myobjectlist.v"],
            "y": ["inputs.myobjectlist.t", "inputs.myobjectlist.v"],
            "defaultX": "inputs.myobjectlist.v",
            "defaultY": ["inputs.myobjectlist.t", "inputs.myobjectlist.v"],
            "minX": 0,
            "maxX": 'inputs.normx',
            "minY": -1.0,
            "zoomX": true,
            "zoomY": false,
            "x_shown_unitprefix": ["", "m"],
            "y_shown_unitprefix": "m",
          },
        },
      },
      "outputs": {
        "properties": {
          "time": {
            "type": "float[]",
            "title": "t",
            "description": "The measured time.",
            "unit": "s",
            "shown_unitprefix": "m",
          },
          "voltage": {
            "type": "float[]",
            "title": "voltage",
            "description": "The measured time.",
            "unit": "V",
            "shown_unitprefix": "m",
          },
          "real_voltage": {
            "type": "float[]",
            "title": "real voltage",
            "description": "The measured time.",
            "unit": "V",
            "shown_unitprefix": "m",
          },
          "current": {
            "type": "float[]",
            "title": "current",
            "description": "The measured time.",
            "unit": "A",
            "shown_unitprefix": "m",
          },
          "real_current": {
            "type": "float[]",
            "title": "real current",
            "description": "The measured time.",
            "unit": "A",
            "shown_unitprefix": "m",
          },
          "plot1": {
            "type": "plot",
            "title": "Voltage",
            "plotType": "line",
            "x": ["outputs.time"],
            "y": ["outputs.voltage", "outputs.real_voltage"],
            "defaultY": ["outputs.voltage"],
            "minY": -5.0,
            "maxY": 5.0,
            "x_shown_unitprefix": [""],
            "y_shown_unitprefix": "",
          },
          "plot2": {
            "type": "plot",
            "title": "Current",
            "plotType": "line",
            "x": ["outputs.time"],
            "y": ["outputs.current", "outputs.real_current"],
            "defaultY": ["outputs.voltage"],
            "minY": -5.0,
            "maxY": 5.0,
            "x_shown_unitprefix": [""],
            "y_shown_unitprefix": "",
          },
        },
      },
    };
    data = {
      "inputs": {
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
        "v": 2,
        "v_shown_unitprefix": "",
        "t": 2,
        "t_shown_unitprefix": "",
        "xarr": [1.0, 4.0, 12.0],
        "xarr_shown_unitprefix": "",
        "varr": [1.0, 2.0, 4.0],
        "varr_shown_unitprefix": "",
        "tarr": [1.0, 2.0, 3.0],
        "tarr_shown_unitprefix": "",
        "normx": 4,
        "normx_shown_unitprefix": "",
        "intxarr": [1, 5],
        "myobject0": {
          "t": 1.0,
          "t_shown_unitprefix": "",
          "v": 2.0,
          "v_shown_unitprefix": "",
          "int": 3.0,
        },
        "myobjectlist": [
          {
            "t": 1.0,
            "t_shown_unitprefix": "",
            "v": 2.0,
            "v_shown_unitprefix": "",
            "int": 3.0,
          },
          {"t": 4.0, "t_shown_unitprefix": "", "v": 5.0},
          null,
        ],
      },
      "outputs": {
        "time": [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0],
        "time_shown_unitprefix": "",
        "voltage": [-5.0, -4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0],
        "voltage_shown_unitprefix": "",
        "current": [-5.0, -4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0],
        "current_shown_unitprefix": "",
        "real_voltage": [
          -5.1,
          -4.2,
          -3.1,
          -2.01,
          -1.1,
          0.2,
          1.1,
          2.2,
          3.1,
          4.2,
          5.1,
        ],
        "real_voltage_shown_unitprefix": "",
        "real_current": [
          -5.01,
          -4.1,
          -3.2,
          -2.3,
          -1.01,
          0.1,
          1.3,
          2.01,
          3.01,
          4.2,
          5.1,
        ],
        "real_current_shown_unitprefix": "",
      },
      "figures": {
        "plot1": {
          "type": "plot",
          "title": "Current",
          "plotType": "line",
          "x": ["outputs.time"],
          "y": ["outputs.voltage", "outputs.real_voltage"],
          "defaultY": ["outputs.voltage"],
          "x_shown_unitprefix": [""],
          "y_shown_unitprefix": "",
        },
        "plot2": {
          "type": "plot",
          "title": "Current",
          "plotType": "line",
          "x": ["outputs.time"],
          "y": ["outputs.current", "outputs.real_current"],
          "defaultY": ["outputs.current"],
          "x_shown_unitprefix": [""],
          "y_shown_unitprefix": "",
        },
        "plot3": {
          "type": "plot",
          "title": "Current",
          "plotType": "line",
          "x": ["outputs.time"],
          "y": ["outputs.current", "outputs.real_current"],
          "defaultY": ["outputs.real_current"],
          "x_shown_unitprefix": [""],
          "y_shown_unitprefix": "",
        },
      },
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
              constraints: const BoxConstraints(maxWidth: 800),
              child: DynamicForm(
                schema: schema,
                data: data,
                onValueChange: (value) {
                  print(value);
                  setState(() {
                    data = value;
                  });
                },
              ),
            );
          case 1:
            return OutputFigures(schema: schema, data: data);
          case 2:
            return OutputData(schema: schema, data: data);
          case 3:
            return Figures(schema: schema, data: data);
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
