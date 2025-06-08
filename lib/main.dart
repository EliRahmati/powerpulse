import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:powerpulse/src/models/user.dart';
import 'package:provider/provider.dart';
import 'package:powerpulse/src/app_provider.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // init NetworkTools and NetworkToolsFlutter
  // final appDocDirectory = await getApplicationDocumentsDirectory();
  // await configureNetworkTools(appDocDirectory.path, enableDebugging: true);
  // await configureNetworkToolsFlutter(appDocDirectory.path,
  //     enableDebugging: true);

  // Initialize hive
  await Hive.initFlutter();
  // Registering the adapter
  Hive.registerAdapter(UserAdapter());
  // Opening the box
  await Hive.openBox('users');
  await Hive.openBox('devices');
  await Hive.openBox<String>('historyCommands');

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  // runApp(MyApp(settingsController: settingsController));
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MyApp(settingsController: settingsController),
    ),
  );
  // runApp(SidebarXExampleApp());
}
