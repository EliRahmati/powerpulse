library powerpulse.globals;

import 'package:powerpulse/src/models/user.dart';
import 'package:powerpulse/src/network/websocket_client.dart';

String? token;
User? user;
const Map<String, double> prefixMultipliers = {
  'M': 1e6, // mega
  'k': 1e3, // kilo
  '': 1, //
  'm': 1e-3, // milli
  'µ': 1e-6, // micro
  'n': 1e-9, // nano
  'p': 1e-12, // pico
};

WebSocketClient? client;
int connectionStatus = 0;
String terminalData = '';
