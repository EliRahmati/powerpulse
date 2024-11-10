import 'package:flutter/material.dart';
import 'package:powerpulse/src/dynamicForm/method_app.dart';
import '../settings/settings_view.dart';
import 'method.dart';

/// Displays a list of Methods.
class MethodListView extends StatelessWidget {
  const MethodListView({
    super.key,
    required this.type,
  });

  static const routeName = '/';
  final String? type;
  static List<Method>? methods;

  @override
  Widget build(BuildContext context) {
    if (type == 'IV') {
      methods = [
        IV('iv-id1', '-3V to 3V'),
        IV('iv-id2', '-5V to 5V'),
      ];
    } else if (type == 'EIS') {
      methods = [
        EIS('eis-id1', 'test'),
        EIS('eis-id2', 'test2'),
      ];
    } else if (type == 'Pulse') {
      methods = [
        Pulse('pulse-id1', 'pulse 1'),
        Pulse('pulse-id2', 'pulse 2'),
      ];
    } else if (type == 'Battery') {
      methods = [
        Battery('battery-id1', 'battery test 1'),
        Battery('battery-id2', 'battery test 2'),
      ];
    }

    return Scaffold(
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'sampleItemListView',
        itemCount: methods?.length,
        itemBuilder: (BuildContext context, int index) {
          final method = methods?[index];

          return ListTile(
              title: Text(method != null ? method.title : ''),
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
                  MethodApp.routeName,
                  arguments: {
                    'type': method?.type,
                    'id': method?.id,
                    'title': method?.title
                  },
                );
              });
        },
      ),
    );
  }
}
