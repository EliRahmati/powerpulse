import 'package:flutter/material.dart';
import 'package:network_tools/network_tools.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:powerpulse/src/models/device.dart';
import 'package:powerpulse/src/devices/device_view.dart';

class DeviceScanner extends StatefulWidget {
  static const routeName = '/devices';

  const DeviceScanner({super.key});
  @override
  _DeviceScannerState createState() => _DeviceScannerState();
}

class _DeviceScannerState extends State<DeviceScanner> {
  Map<String, Device> devices = {};
  bool isScanning = false;
  double scanningProgress = 0;

  updateDevices(ActiveHost host) async {
    host.deviceName.then((deviceName) {
      host.getMacAddress().then((mac) {
        setState(() {
          devices[host.address] = Device(
            iPAddress: host.address,
            macAddress: mac,
            deviceName: deviceName,
          );
          isScanning = true;
        });
      });
    });
  }

  Future<void> scanNetwork() async {
    setState(() {
      isScanning = true;
      scanningProgress = 0;
      devices = {};
    });

    final String? address = await (NetworkInfo().getWifiIP());
    if (address == null) {
      return;
    }
    final String subnet = address.substring(0, address.lastIndexOf('.'));
    final stream = HostScannerService.instance.getAllPingableDevices(
      subnet,
      progressCallback: (progress) {
        scanningProgress = progress;
      },
    );

    stream.listen(
      (host) {
        updateDevices(host);
      },
      onDone: () {
        setState(() {
          isScanning = false;
        });
      },
      onError: (err) {
        // ignore errors to finish the scan
      },
    ); // Don't forget to cancel the stream when not in use.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network Scanner')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: isScanning ? null : scanNetwork,
            child: Text(isScanning ? 'Scanning...' : 'Scan Network'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.entries.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devices.values.toList()[index].deviceName),
                  subtitle: Text(devices.values.toList()[index].iPAddress),
                  leading: const CircleAvatar(
                    // Display the Flutter Logo image asset.
                    foregroundImage: AssetImage(
                      'assets/images/flutter_logo.png',
                    ),
                  ),
                  onTap: () {
                    // Navigate to the details page. If the user leaves and returns to
                    // the app after it has been killed while running in the
                    // background, the navigation stack is restored.
                    Navigator.restorablePushNamed(
                      context,
                      DeviceInfoView.routeName,
                      arguments: {
                        'ip': devices.values.toList()[index].iPAddress,
                        'deviceName': devices.values.toList()[index].deviceName,
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
