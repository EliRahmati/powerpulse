import 'dart:convert'; // For JSON encoding/decoding
import 'dart:io'; // For WebSocket
import 'package:flutter/material.dart';
import 'package:powerpulse/src/network/websocket_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebSocketScreen(),
    );
  }
}

class WebSocketScreen extends StatefulWidget {
  @override
  _WebSocketScreenState createState() => _WebSocketScreenState();
}

const int pingDurationFromAPI = 10;

class _WebSocketScreenState extends State<WebSocketScreen>
    with TickerProviderStateMixin {
  dynamic _receivedData = '';
  final _textController = TextEditingController();
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  WebSocketClient client =
      WebSocketClient('ws://localhost:8765', pingDurationFromAPI);

  // Function to reset light to green when a ping is received
  void _blink() {
    _controller.duration = const Duration(seconds: 0);
    _controller.forward();
    _controller.duration = const Duration(seconds: 2 * pingDurationFromAPI);
    _controller.reverse();
  }

  void handleStatus(status) {
    _blink();
  }

  void handleDataReceived(data) {
    setState(() {
      _receivedData = data;
    });
  }

  @override
  void initState() {
    super.initState();
    client.connect();
    client.onPing = handleStatus;
    client.onDataReceived = handleDataReceived;

    // Animation controller for 5 seconds duration
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2 * pingDurationFromAPI),
    );

    // Color animation from bright green to darker green
    _colorAnimation = ColorTween(
      begin: const Color.fromARGB(255, 130, 0, 0),
      end: const Color.fromARGB(255, 30, 255, 0), // Dark green
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WebSocket Client')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _colorAnimation.value,
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
            Text('Received Message from test_channel:'),
            SizedBox(height: 10),
            Text(_receivedData.toString(), style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            TextField(
              controller: _textController,
              decoration:
                  InputDecoration(labelText: 'Send Message to test_channel'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => client.sendMessage(_textController.text),
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
