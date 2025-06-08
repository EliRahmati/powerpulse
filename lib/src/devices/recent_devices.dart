import 'dart:math';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:powerpulse/src/devices/device_status.dart';
import 'package:powerpulse/src/network/websocket_client.dart';
import 'package:powerpulse/src/network/ping_indicator.dart';
import '../globals.dart' as globals;
import 'package:provider/provider.dart';
import 'package:powerpulse/src/app_provider.dart';

class RecentDevices extends StatefulWidget {
  static const routeName = '/recentdevices';

  const RecentDevices({super.key});

  @override
  _RecentDevicesState createState() => _RecentDevicesState();
}

class _RecentDevicesState extends State<RecentDevices> {
  final Random _random = Random();
  late final Box box;

  List<Device> devices = [];

  final _ipPortController = TextEditingController();
  bool _isAdding = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    box = Hive.box('devices');

    final storedDevices = box.values.toList();
    devices =
        storedDevices.map((deviceMap) {
          return Device(
            name: deviceMap['name'],
            ip: deviceMap['ip'],
            port: deviceMap['port'] ?? 0,
            isActive: deviceMap['isActive'] ?? false,
          );
        }).toList();

    setState(() {});
  }

  void _onAddPressed() async {
    final input = _ipPortController.text.trim();
    // Expect input format: "192.168.1.5:8080" or "localhost:8080"
    final parts = input.split(':');
    if (parts.length != 2) {
      setState(() {
        _errorText = 'Enter IP and port as IP:Port';
      });
      return;
    }

    final ip = parts[0];
    final portStr = parts[1];

    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    final isValidIp = ip == 'localhost' || ipRegex.hasMatch(ip);
    final port = int.tryParse(portStr);

    if (!isValidIp) {
      setState(() {
        _errorText = 'Invalid IP address (must be IPv4 or localhost)';
      });
      return;
    }

    if (port == null || port <= 0 || port > 65535) {
      setState(() {
        _errorText = 'Invalid port number';
      });
      return;
    }

    setState(() {
      _errorText = null;
      _isAdding = true;
    });

    try {
      const name = 'Unknown Device';
      final newDevice = Device(name: name, ip: ip, port: port, isActive: false);

      // Add to Hive (store port and isActive too)
      await box.add({
        'name': newDevice.name,
        'ip': newDevice.ip,
        'port': newDevice.port,
        'isActive': newDevice.isActive,
      });

      setState(() {
        devices.add(newDevice);
        _ipPortController.clear();
        _isAdding = false;
      });
    } catch (e) {
      setState(() {
        _errorText = 'Failed to add device';
        _isAdding = false;
      });
    }
  }

  MapEntry<int, Device>? getFirstActiveDeviceWithIndex() {
    final storedDevices = box.values.toList();

    for (int i = 0; i < storedDevices.length; i++) {
      final deviceMap = storedDevices[i];
      if (deviceMap['isActive'] == true) {
        final device = Device(
          name: deviceMap['name'],
          ip: deviceMap['ip'],
          port: deviceMap['port'] ?? 0,
          isActive: deviceMap['isActive'] ?? false,
        );
        return MapEntry(i, device);
      }
    }

    return null;
  }

  void _connectDevice(int index, Device device) {
    MapEntry<int, Device>? activeDevice = getFirstActiveDeviceWithIndex();
    if (activeDevice != null) {
      final connectedIndex = activeDevice.key;
      final connectedDevice = activeDevice.value;
      _disconnectDevice(connectedIndex, connectedDevice);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Connecting to ${device.name} (${device.ip}:${device.port})...',
        ),
      ),
    );
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.createWebsocket(device.ip, device.port);
    globals.client?.connect();
    _updateDeviceIsActive(index, true);
  }

  void _disconnectDevice(int index, Device device) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Disconnecting from ${device.name} (${device.ip}:${device.port})...',
        ),
      ),
    );
    if (globals.client != null) {
      globals.client?.disconnect();
      globals.client;
    }
    _updateDeviceIsActive(index, false);
  }

  void _removeDevice(int index) {
    setState(() {
      devices.removeAt(index);
      box.deleteAt(index);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Device removed')));
  }

  void _updateDeviceName(int index, String newName) async {
    final device = devices[index];
    if (device.name != newName) {
      final updatedDevice = device.copyWith(name: newName);

      setState(() {
        devices[index] = updatedDevice;
      });

      await box.putAt(index, {
        'name': updatedDevice.name,
        'ip': updatedDevice.ip,
        'port': updatedDevice.port,
        'isActive': updatedDevice.isActive,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Device name updated to "$newName"')),
      );
    }
  }

  void _updateDeviceIsActive(int index, bool newIsActive) async {
    final device = devices[index];
    if (device.isActive != newIsActive) {
      final updatedDevice = device.copyWith(isActive: newIsActive);

      setState(() {
        devices[index] = updatedDevice;
      });

      await box.putAt(index, {
        'name': updatedDevice.name,
        'ip': updatedDevice.ip,
        'port': updatedDevice.port,
        'isActive': updatedDevice.isActive,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Connected Devices'),
        actions: const [PingIndicator()],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return DeviceCard(
            device: device,
            onConnect: () => _connectDevice(index, device),
            onDisconnect: () => _disconnectDevice(index, device),
            onRemove: () => _removeDevice(index),
            onSetName: (newName) => _updateDeviceName(index, newName),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ipPortController,
                enabled: !_isAdding,
                decoration: InputDecoration(
                  labelText: 'IP Address and Port',
                  errorText: _errorText,
                  hintText: 'e.g. 192.168.1.5:8080 or localhost:8080',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                keyboardType: TextInputType.text,
                onSubmitted: (_) => _onAddPressed(),
              ),
            ),
            const SizedBox(width: 12),
            _isAdding
                ? const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(child: CircularProgressIndicator()),
                )
                : ElevatedButton(
                  onPressed: _onAddPressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(70, 48),
                  ),
                  child: Text('Add'),
                ),
          ],
        ),
      ),
    );
  }
}
