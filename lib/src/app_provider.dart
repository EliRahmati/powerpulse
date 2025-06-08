import 'package:flutter/foundation.dart';
import 'package:powerpulse/src/globals.dart' as globals;
import 'package:powerpulse/src/devices/device_status.dart';
import 'package:hive/hive.dart';
import 'package:powerpulse/src/network/websocket_client.dart';

class AppProvider extends ChangeNotifier {
  Map<String, dynamic> connectedDeviceMethods = {};

  Future<void> fetchMethods() async {
    if (globals.client != null) {
      try {
        // Await the fetch call
        List<String> methodNames = List<String>.from(
          await globals.client!.fetch({'text': 'methods'}),
        );

        // Create a list of futures for fetching schemas
        List<Future<void>> futures = [];
        for (var methodName in methodNames) {
          futures.add(fetchMethodSchema(methodName));
        }

        // Wait for all schemas to be fetched
        await Future.wait(futures);
      } catch (error) {
        // Handle error if needed
      }
    }
  }

  Future<void> fetchMethodSchema(String methodName) async {
    try {
      var data = await globals.client!.fetch({'text': 'schema $methodName'});
      connectedDeviceMethods[methodName] = data;
    } catch (error) {
      // Handle error if needed
    }
  }

  Future<void> updateMethods() async {
    await fetchMethods();
    notifyListeners();
  }

  Future<void> clearMethods() async {
    connectedDeviceMethods.clear();
    notifyListeners();
  }

  void createWebsocket(String ip, int port) {
    globals.client = WebSocketClient(
      'ws://$ip:$port/websocket',
      () {
        updateMethods();
      },
      () {
        clearMethods();
      },
    );
  }
}
