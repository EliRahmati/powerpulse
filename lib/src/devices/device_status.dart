import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model class with port
class Device {
  final String name;
  final String ip;
  final int port;
  final bool isActive;

  Device({
    required this.name,
    required this.ip,
    required this.port,
    this.isActive = false,
  });

  Device copyWith({String? name, String? ip, int? port, bool? isActive}) {
    return Device(
      name: name ?? this.name,
      ip: ip ?? this.ip,
      port: port ?? this.port,
      isActive: isActive ?? this.isActive,
    );
  }
}

// DeviceCard widget for displaying each device with IP and Port and status circle
class DeviceCard extends StatefulWidget {
  final Device device;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect; // Added disconnect callback
  final VoidCallback onRemove;
  final ValueChanged<String> onSetName;

  const DeviceCard({
    Key? key,
    required this.device,
    required this.onConnect,
    required this.onDisconnect, // Added required disconnect callback
    required this.onRemove,
    required this.onSetName,
  }) : super(key: key);

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  late Timer _timer;
  bool statusOk = false;

  @override
  void initState() {
    super.initState();
    _startStatusUpdates();
  }

  void _startStatusUpdates() {
    _fetchStatus();

    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchStatus();
    });
  }

  void _fetchStatus() async {
    final url = Uri.parse(
      'http://${widget.device.ip}:${widget.device.port}/info',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 1));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> &&
            data['company'] == 'e.ai.techtronic') {
          if (!mounted) return;
          setState(() => statusOk = true);
          // Extract device_name and call onSetName
          if (data.containsKey('device_name') &&
              data['device_name'] is String) {
            widget.onSetName(data['device_name']);
          }
        } else {
          if (!mounted) return;
          setState(() => statusOk = false);
        }
      } else {
        if (!mounted) return;
        setState(() => statusOk = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => statusOk = false);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circleColor = statusOk ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor,
                  border: Border.all(color: Colors.black12),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.device.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text('IP: ${widget.device.ip}:${widget.device.port}'),
                const SizedBox(height: 40),
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed:
                        widget.device.isActive
                            ? widget.onDisconnect
                            : widget.onConnect,
                    child: Text(
                      widget.device.isActive ? 'Disconnect' : 'Connect',
                    ),
                  ),
                  if (!widget.device.isActive) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: widget.onRemove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Remove'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
