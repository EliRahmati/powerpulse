import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:powerpulse/src/methods/methods.dart';
import 'package:powerpulse/src/methods/start_page.dart';

import 'sample_feature/sample_item_details_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'screens/login_screen.dart';
import 'package:powerpulse/src/devices/device_view.dart';
import 'package:powerpulse/src/devices/devices_view.dart';
import 'package:powerpulse/src/devices/recent_devices.dart';
import 'package:powerpulse/src/dynamicForm/method_app.dart';
import 'package:powerpulse/src/dynamicForm/measurment.dart';
import 'package:powerpulse/src/network/terminal.dart';
import 'package:powerpulse/src/network/websocket_client.dart';
import 'package:powerpulse/src/devices/device_status.dart';
import 'package:hive/hive.dart';
import 'globals.dart' as globals;
import 'package:provider/provider.dart';
import 'package:powerpulse/src/app_provider.dart';

const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF2E2E48);

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  final SettingsController settingsController;

  const MyApp({super.key, required this.settingsController});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    globals.terminalData = '';
    Device? lastDevice = getFirstActiveDevice();
    if (lastDevice != null) {
      AppProvider appProvider = Provider.of<AppProvider>(
        context,
        listen: false,
      );
      appProvider.createWebsocket(lastDevice.ip, lastDevice.port);
      globals.client?.connect();
    }
  }

  Device? getFirstActiveDevice() {
    Box box = Hive.box('devices');
    final storedDevices = box.values.toList();

    for (var deviceMap in storedDevices) {
      if (deviceMap['isActive'] == true) {
        return Device(
          name: deviceMap['name'],
          ip: deviceMap['ip'],
          port: deviceMap['port'] ?? 0,
          isActive: deviceMap['isActive'] ?? false,
        );
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          onGenerateTitle:
              (BuildContext context) => AppLocalizations.of(context)!.appTitle,

          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: widget.settingsController.themeMode,

          onGenerateRoute: (RouteSettings routeSettings) {
            final arguments =
                (routeSettings.arguments ?? <String, dynamic>{}) as Map;

            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: widget.settingsController);
                  case SampleItemDetailsView.routeName:
                    return const SampleItemDetailsView();
                  case DeviceScanner.routeName:
                    return DeviceScanner();
                  case RecentDevices.routeName:
                    return RecentDevices();
                  case Terminal.routeName:
                    return Terminal();
                  case DeviceInfoView.routeName:
                    if (arguments.isEmpty) {
                      return const DeviceInfoView(ip: null, deviceName: null);
                    } else {
                      return DeviceInfoView(
                        ip: arguments['ip'],
                        deviceName: arguments['deviceName'],
                      );
                    }
                  case Methods.routeName:
                    return Methods();
                  case MethodApp.routeName:
                    return MethodApp(
                      type: arguments['type'],
                      id: arguments['id'],
                      title: arguments['title'],
                    );
                  case Measurment.routeName:
                    return Measurment(
                      type: arguments['type'],
                      schema: arguments['schema'],
                      data: arguments['data'],
                    );
                  default:
                    if (globals.user != null) {
                      return StartPage();
                    } else {
                      return LoginScreen();
                    }
                }
              },
            );
          },
        );
      },
    );
  }
}
