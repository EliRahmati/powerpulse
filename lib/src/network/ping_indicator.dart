import 'dart:async';
import 'package:flutter/material.dart';
import 'package:powerpulse/src/devices/recent_devices.dart';
import 'package:powerpulse/src/globals.dart' as globals;

class PingIndicator extends StatefulWidget {
  const PingIndicator({Key? key}) : super(key: key);

  @override
  _PingIndicatorState createState() => _PingIndicatorState();
}

class _PingIndicatorState extends State<PingIndicator> {
  late Timer _timer;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnection(); // Check immediately on start
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkConnection();
    });
  }

  void _checkConnection() {
    final connected =
        globals.client != null && globals.client?.isConnect() == true;
    if (connected != _isConnected) {
      setState(() {
        _isConnected = connected;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.circle, color: _isConnected ? Colors.green : Colors.red),
      onPressed: () {
        Navigator.restorablePushNamed(context, RecentDevices.routeName);
      },
    );
  }
}
