import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:powerpulse/src/globals.dart' as globals;
import 'package:powerpulse/src/network/ping_indicator.dart';

class Terminal extends StatefulWidget {
  static const routeName = '/terminal';
  @override
  _TerminalState createState() => _TerminalState();
}

class _TerminalState extends State<Terminal> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  late Box<String> _historyBox;
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _initHistory();
    scrollToEnd();
  }

  Future<void> _initHistory() async {
    _historyBox = Hive.box<String>('historyCommands');
    _history = _historyBox.values.toList();
  }

  void sendMessage(String message) {
    if (globals.client != null) {
      var messageJson = {'text': message};
      globals.client
          ?.fetch(messageJson)
          .then((data) {
            handleDataReceived(data);
          })
          .catchError((error) {
            handleDataReceived(error);
          });
    } else {
      handleDataReceived('not connected');
    }

    _saveCommandToHistory(message);
  }

  void _saveCommandToHistory(String command) {
    if (command.isEmpty) return;
    if (_history.isEmpty || _history.last != command) {
      _historyBox.add(command);
      setState(() {
        _history.add(command);
      });
    }
  }

  void handleDataReceived(data) {
    setState(() {
      if (globals.terminalData.isEmpty) {
        globals.terminalData = data.toString();
      } else {
        globals.terminalData += '\n${data.toString()}';
      }
    });
    scrollToEnd();
  }

  void scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showHistoryModal() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        if (_history.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text('No command history')),
          );
        }
        return ListView.separated(
          itemCount: _history.length,
          separatorBuilder: (_, __) => Divider(),
          itemBuilder: (ctx, index) {
            final command =
                _history[_history.length - 1 - index]; // show latest first
            return ListTile(
              title: Text(command),
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _textController.text = command;
                  _textController.selection = TextSelection.fromPosition(
                    TextPosition(offset: command.length),
                  );
                  _focusNode.requestFocus();
                });
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal'),
        actions: const [PingIndicator()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Text(
                    globals.terminalData,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      color: Colors.greenAccent,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _textController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                labelText: 'Command',
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.history),
                      tooltip: 'Show command history',
                      onPressed: _showHistoryModal,
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        final text = _textController.text.trim();
                        if (text.isNotEmpty) {
                          sendMessage(text);
                          _textController.clear();
                          _focusNode.requestFocus();
                        }
                      },
                    ),
                  ],
                ),
              ),
              onSubmitted: (value) {
                final text = value.trim();
                if (text.isNotEmpty) {
                  sendMessage(text);
                  _textController.clear();
                  _focusNode.requestFocus();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
