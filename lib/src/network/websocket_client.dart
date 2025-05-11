import 'dart:convert'; // For JSON encoding/decoding
import 'dart:io'; // For WebSocket
import 'dart:async';

class WebSocketClient {
  late WebSocket _ws;
  String _receivedMessage = '';
  String _pingMessage = ''; // For storing ping responses
  bool _isConnected = false; // Track WebSocket connection status
  final String _url;
  final int _pingDuration;
  void Function(String)? onPing;
  void Function(dynamic)? onDataReceived;
  bool _statusValidity = false;
  final EventListener _eventListener = EventListener();

  // Constructor
  WebSocketClient(this._url, this._pingDuration) {
    startStatusTimer();
  }

  // Establish WebSocket connection
  Future<void> connect() async {
    try {
      _ws = await WebSocket.connect(_url);
      _isConnected = true;

      // Listen for incoming messages from the WebSocket
      _ws.listen((data) {
        var message = jsonDecode(data);
        if (message['type'] == 'ping') {
          _pingMessage = message['message']; // Handle ping message
          _notifyStatus(_pingMessage); // Notify the status listener
        } else if (message['type'] == 'status') {
          _receivedMessage = message['status'] ?? ''; // Handle normal message
          _handleDataReceived(message);
        } else if (message['status'] == 'success' ||
            message['status'] == 'error') {
          _eventListener.notifyListeners(message);
        }
      });

      // Subscribe to both 'test_channel' and 'ping_channel'
      _ws.add('register test_channel'); // Subscribe to 'test_channel'
      _ws.add('register ping_channel'); // Subscribe to 'ping_channel'
      print("Subscribed to test_channel and ping_channel");
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      _isConnected = false;
    }
  }

  // Notify the status listener when a ping response is received
  void _notifyStatus(String message) {
    if (onPing != null) {
      onPing!(message); // Call the listener if it's set
      _isConnected = true;
      _statusValidity = true;
    }
  }

  // Notify the status listener when a ping response is received
  void _handleDataReceived(dynamic data) {
    if (onDataReceived != null) {
      onDataReceived!(data); // Call the listener if it's set
    }
  }

  // Send message to the WebSocket server (to 'test_channel')
  void sendMessage(String message) {
    var messageJson = {'text': message};
    fetch(messageJson).then((data) {
      print(data);
    }).catchError((error) {
      print(error);
    });
  }

  Future<dynamic> fetch(dynamic body,
      {Duration timeout = const Duration(seconds: 5)}) async {
    Completer<String> completer = Completer<String>();

    if (_isConnected) {
      // Create a Completer to return a Future
      var messageJson = {'id': completer.hashCode, 'body': body};

      try {
        // Send the message to the server
        _ws.add(jsonEncode(messageJson));

        // Set up a timer to handle the timeout
        var fetchTimer = Timer(timeout, () {
          if (!completer.isCompleted) {
            completer
                .completeError('Message sending failed: Timeout occurred.');
            _eventListener.removeListener(completer.hashCode);
          }
        });

        listener(response) {
          if (!completer.isCompleted) {
            if (response['id'] == completer.hashCode) {
              // If the server responds, cancel the timeout
              fetchTimer.cancel();
              if (response['status'] == 'success') {
                // If the server responds with success
                completer.complete('server responds with success');
              } else if (response['status'] == 'error') {
                // Handle error message from the server
                completer.completeError(response['error']);
              }
              _eventListener.removeListener(completer.hashCode);
            }
          }
        }

        // Listen for server response
        _eventListener.addListener(completer.hashCode, listener);
      } catch (e) {
        completer.completeError(e);
      }
    } else {
      completer.completeError('Not connected to WebSocket.');
    }

    return completer.future;
  }

  // Close the WebSocket connection
  void closeConnection() {
    if (_isConnected) {
      _ws.close();
      _isConnected = false;
    }
  }

  // Reconnect to the WebSocket server
  void reconnect() {
    if (!_isConnected) {
      connect();
    }
  }

  bool isConnect() {
    return _isConnected;
  }

  void startStatusTimer() {
    Timer.periodic(Duration(seconds: _pingDuration + 1), (timer) {
      if (!_statusValidity) {
        _isConnected = false;
        reconnect();
      } else {
        _statusValidity = false;
      }
    });
  }

  // Getter for the received message
  String get receivedMessage => _receivedMessage;

  // Getter for the ping message
  String get pingMessage => _pingMessage;

  // Getter for connection status
  bool get isConnected => _isConnected;
}

class EventListener {
  // A list to store the callbacks (listeners)
  // final List<void Function(dynamic message)> _listeners = [];
  Map<int, void Function(dynamic message)> _listeners = {};

  // Method to add a listener (callback)
  void addListener(int id, void Function(dynamic message) listener) {
    _listeners[id] = listener;
  }

  // Method to remove a listener (callback)
  void removeListener(int id) {
    _listeners.remove(id);
  }

  // Method to notify all listeners
  void notifyListeners(dynamic message) {
    var listeners = _listeners.values.toList();
    var count = listeners.length;
    for (var i = 0; i < count; i++) {
      var listener = listeners[i];
      listener(message);
    }
  }
}
