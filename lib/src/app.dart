import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:powerpulse/src/methods/methods.dart';

import 'sample_feature/sample_item_details_view.dart';
import 'sample_feature/sample_item_list_view.dart';
import 'methods/method_list_view.dart';
import 'methods/method_page.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'screens/login_screen.dart';
import 'package:powerpulse/src/devices/device_view.dart';
import 'package:powerpulse/src/devices/devices_view.dart';
import 'package:powerpulse/src/dynamicForm/dynamicForm.dart';
import 'package:powerpulse/src/dynamicForm/method_app.dart';

import 'globals.dart' as globals;

const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(),
          // theme: ThemeData(
          //   primaryColor: primaryColor,
          //   canvasColor: canvasColor,
          //   scaffoldBackgroundColor: scaffoldBackgroundColor,
          //   textTheme: const TextTheme(
          //     headlineSmall: TextStyle(
          //       color: Colors.white,
          //       fontSize: 46,
          //       fontWeight: FontWeight.w800,
          //     ),
          //   ),
          // ),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            //ModalRoute.of(context)?.settings.arguments
            final arguments =
                (routeSettings.arguments ?? <String, dynamic>{}) as Map;

            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case SampleItemDetailsView.routeName:
                    return const SampleItemDetailsView();
                  case DeviceScanner.routeName:
                    return DeviceScanner();
                  case DeviceInfoView.routeName:
                    if (arguments.isEmpty) {
                      return const DeviceInfoView(ip: null, deviceName: null);
                    } else {
                      return DeviceInfoView(
                          ip: arguments['ip'],
                          deviceName: arguments['deviceName']);
                    }
                  case MethodApp.routeName:
                    return MethodApp(
                        type: arguments['type'],
                        id: arguments['id'],
                        title: arguments['title']);
                  default:
                    // return SidebarXExampleApp();
                    // return const DynamicForm(schema: {
                    //   "title": "Sample Form",
                    //   "type": "object",
                    //   "properties": {
                    //     "name": {
                    //       "type": "string",
                    //       "title": "My Name",
                    //       "description": "Enter your full name."
                    //     },
                    //     "time": {
                    //       "type": "number",
                    //       "title": "My Time",
                    //       "description": "Enter time."
                    //     },
                    //     "int": {
                    //       "type": "integer",
                    //       "title": "My int",
                    //       "description": "Enter time."
                    //     },
                    //     "bool": {
                    //       "type": "boolean",
                    //       "title": "My bool",
                    //       "description": "Enter time."
                    //     }
                    //   }
                    // }, data: {
                    //   "name": "my name",
                    //   "time": 5.5,
                    //   "int": 8,
                    //   "bool": true,
                    // });
                    if (globals.user != null) {
                      return Methods();
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
