import 'package:flutter/material.dart';

import '../settings/settings_view.dart';
import 'method.dart';

/// Displays a list of Methods.
class Methods extends StatelessWidget {
  const Methods({
    super.key,
    this.methods = const [
      MethodType('IV'),
      MethodType('EIS'),
      MethodType('Pulse'),
      MethodType('Battery')
    ],
  });

  static const routeName = '/';

  final List<MethodType> methods;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Methods'),
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
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'methods',
        itemCount: methods.length,
        itemBuilder: (BuildContext context, int index) {
          final method = methods[index];

          return ListTile(
              title: Text(method.methodName),
              leading: const CircleAvatar(
                // Display the Flutter Logo image asset.
                foregroundImage: AssetImage('assets/images/flutter_logo.png'),
              ),
              onTap: () {
                // Navigate to the details page. If the user leaves and returns to
                // the app after it has been killed while running in the
                // background, the navigation stack is restored.
                Navigator.restorablePushNamed(
                  context,
                  method.methodName,
                );
              });
        },
      ),
    );
  }
}
