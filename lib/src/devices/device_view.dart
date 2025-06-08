import 'package:flutter/material.dart';
import 'package:powerpulse/src/network/network.dart';

class DeviceInfoView extends StatefulWidget {
  const DeviceInfoView({super.key, required this.deviceName, required this.ip});

  static const routeName = '/device';
  final String? deviceName;
  final String? ip;

  @override
  _DeviceInfoViewState createState() => _DeviceInfoViewState();
}

class _DeviceInfoViewState extends State<DeviceInfoView> {
  String macAddress = '00:1A:2B:3C:4D:5E'; // Example MAC address
  String hostName = 'my-device.local'; // Example Host Name

  List<String> supportedMethods = ['IV', 'EIS', 'Pulse', 'Battery'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceName ?? 'no name'),
        actions: [IconButton(icon: const Icon(Icons.circle), onPressed: () {})],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device Name: ${widget.deviceName}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'IP Address: ${widget.ip}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'MAC Address: $macAddress',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Host Name: $hostName',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Supported Methods:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: supportedMethods.length,
                    itemBuilder: (context, index) {
                      return ListTile(title: Text(supportedMethods[index]));
                    },
                  ),
                ),
                const Spacer(),
                Container(
                  alignment: Alignment.centerRight,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => connectToServer(context, widget.ip ?? ''),
                    child: const Text('Connect'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
