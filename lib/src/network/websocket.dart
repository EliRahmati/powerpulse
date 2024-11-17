import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:msgpack_dart/msgpack_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketDemo extends StatefulWidget {
  @override
  _WebSocketDemoState createState() => _WebSocketDemoState();
}

class _WebSocketDemoState extends State<WebSocketDemo> {
  late WebSocketChannel _channel;
  final TextEditingController _controller = TextEditingController();
  final List<String> _response = [];
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _channel.sink.close(status.goingAway);
    _controller.dispose();
    super.dispose();
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8765'));
    _isConnected = true;
    _channel.stream.listen(
      (message) => _handleResponse(message),
      onError: (error) {
        setState(() {
          _isConnected = false;
          _response.add("WebSocket error: $error");
        });
      },
      onDone: () {
        setState(() {
          _isConnected = false;
          _response.add("WebSocket connection closed.");
        });
      },
    );
  }

  void _handleResponse(dynamic message) {
    try {
      // Decode MessagePack data
      final Uint8List rawData = message is String
          ? Uint8List.fromList(message.codeUnits)
          : Uint8List.fromList(message as List<int>);
      final decoded = deserialize(rawData);

      if (mounted) {
        setState(() {
          _response.add(jsonEncode(decoded));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _response.add("Error decoding response: $e");
        });
      }
    }
  }

  void _sendRequest(Map<String, dynamic> request) {
    if (_isConnected) {
      // Encode request as MessagePack
      final Uint8List requestData = serialize(request);
      _channel.sink.add(requestData);
    } else {
      setState(() {
        _response.add("Error: WebSocket is not connected.");
      });
    }
  }

  Widget _buildResponseList() {
    return ListView.builder(
      itemCount: _response.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(_response[index]),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(labelText: "Item to Add/Remove/Edit"),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () => _sendRequest({"action": "get_items"}),
              child: Text("Get Items"),
            ),
            ElevatedButton(
              onPressed: () {
                final item = _controller.text.trim();
                if (item.isNotEmpty) {
                  _sendRequest({"action": "add_item", "data": {"item": item}});
                }
              },
              child: Text("Add Item"),
            ),
            ElevatedButton(
              onPressed: () {
                final item = _controller.text.trim();
                if (item.isNotEmpty) {
                  _sendRequest({"action": "remove_item", "data": {"item": item}});
                }
              },
              child: Text("Remove Item"),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            final oldItem = _controller.text.trim();
            final newItem = "${_controller.text.trim()}_edited";
            if (oldItem.isNotEmpty) {
              _sendRequest({
                "action": "edit_item",
                "data": {"old_item": oldItem, "new_item": newItem}
              });
            }
          },
          child: Text("Edit Item"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("WebSocket Client with MessagePack")),
      body: Column(
        children: [
          Expanded(
            child: _isConnected
                ? _buildResponseList()
                : Center(child: Text("Disconnected from WebSocket.")),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildControlButtons(),
          ),
        ],
      ),
    );
  }
}
