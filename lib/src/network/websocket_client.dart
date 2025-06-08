import 'dart:convert'; // For JSON encoding/decoding
import 'dart:io'; // For WebSocket
import 'dart:async';

const int pingDurationFromAPI = 10;

class WebSocketClient {
  late WebSocket _ws;
  String _receivedMessage = '';
  String _pingMessage = ''; // For storing ping responses
  bool _isConnected = false; // Track WebSocket connection status
  final String _url;
  void Function(String)? onPing;
  void Function(dynamic)? onDataReceived;
  void Function()? onConnected;
  void Function()? onDisconnected;
  bool _statusValidity = false;
  final EventListener _eventListener = EventListener();
  Timer? _statusTimer;

  // Constructor
  WebSocketClient(this._url, this.onConnected, this.onDisconnected) {}

  // Establish WebSocket connection
  Future<void> connect() async {
    try {
      _ws.close();
    } catch (e) {}
    try {
      _ws = await WebSocket.connect(_url);
      _isConnected = true;
      startStatusTimer();

      // Listen for incoming messages from the WebSocket
      _ws.listen(
        (data) {
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
        },
        onDone: () {
          // Handle WebSocket closure
          _handleDisconnection('Connection closed');
        },
        onError: (error) {
          // Handle WebSocket errors
          _handleDisconnection('Error: $error');
        },
      );

      // Subscribe to both 'test_channel' and 'ping_channel'
      // _ws.add('connect'); // Subscribe to 'test_channel'
      // _ws.add('register ping_channel'); // Subscribe to 'ping_channel'
      print("Subscribed to websocket");
      onConnected!();
    } catch (e) {
      // _handleDisconnection('Error connecting to WebSocket: $e');
    }
  }

  // Properly disconnect the WebSocket client
  void disconnect() {
    _statusTimer?.cancel();
    _isConnected = false;
    _statusValidity = false;
    try {
      _ws.close(WebSocketStatus.normalClosure, "Client disconnected");
    } catch (e) {}
    onDisconnected!();
  }

  // Handle WebSocket disconnection error and attempt reconnection
  void _handleDisconnection(String message) {
    print(message); // Log the disconnection message
    _isConnected = false; // Mark as disconnected
    _statusValidity = false;
    // Optionally call any error handling listener if defined
    onDataReceived?.call({'status': 'error', 'message': message});

    // // Retry reconnection after a delay (e.g., 3 seconds)
    // Future.delayed(Duration(seconds: 5), () {
    //   reconnect();
    // });
  }

  // Notify the status listener when a ping response is received
  void _notifyStatus(String message) {
    _isConnected = true;
    _statusValidity = true;
    if (onPing != null) {
      onPing!(message); // Call the listener if it's set
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
    fetch(messageJson)
        .then((data) {
          print(data);
          _handleDataReceived(data);
        })
        .catchError((error) {
          print(error);
          _handleDataReceived(error);
        });
  }

  Future<dynamic> fetch(
    dynamic body, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    Completer<dynamic> completer = Completer<dynamic>();

    if (_isConnected) {
      // Create a Completer to return a Future
      var messageJson = {'id': completer.hashCode, 'body': body};

      try {
        // Send the message to the server
        _ws.add(jsonEncode(messageJson));

        // Set up a timer to handle the timeout
        var fetchTimer = Timer(timeout, () {
          if (!completer.isCompleted) {
            completer.completeError(
              'Message sending failed: Timeout occurred.',
            );
            _eventListener.removeListener(completer.hashCode);
          }
        });

        listener(response) {
          if (!completer.isCompleted) {
            if (response['id'] == completer.hashCode) {
              // If the server responds, cancel the timeout
              fetchTimer.cancel();
              if (response['status'] == 'success') {
                if (response.containsKey('body') && response['body'] != null) {
                  completer.complete(response['body']);
                } else {
                  completer.complete(response['status']);
                }
              } else if (response['status'] == 'error') {
                completer.completeError(response['message']);
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
      print("Attempting to reconnect...");
      connect();
    }
  }

  bool isConnect() {
    return _isConnected;
  }

  void startStatusTimer() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(Duration(seconds: pingDurationFromAPI + 1), (
      timer,
    ) {
      if (!_statusValidity) {
        _isConnected = false;
        onDisconnected!();
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
