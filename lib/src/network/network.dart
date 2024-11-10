import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';

Future<void> connectToServer(BuildContext context, String ip) async {
  final int port = 8080; // Replace with the actual port number.

  try {
    // Create a socket connection.
    Socket socket = await Socket.connect(ip, port);
    _showSnackBar(context,
        'Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');

    // Listen for data from the server.
    socket.listen(
      (data) {
        _showSnackBar(context, 'Received: ${String.fromCharCodes(data)}');
      },
      onError: (error) {
        _showSnackBar(context, 'Error: $error');
      },
      onDone: () {
        _showSnackBar(context, 'Server disconnected');
        socket.destroy();
      },
    );

    // Send a message to the server.
    // socket.write('Hello from Flutter client!');
  } catch (e) {
    _showSnackBar(context, 'Unable to connect: $e');
  }
}

void _showSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Container(
      padding: const EdgeInsets.all(16.0),
      child: Text(message),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // Rounded corners
    ),
    duration: const Duration(seconds: 4),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
