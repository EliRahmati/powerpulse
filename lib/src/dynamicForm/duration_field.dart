import 'package:flutter/material.dart';

class DurationField extends StatefulWidget {
  final num value; // The value is stored in seconds
  final String title;
  final Function(num) onValueChange;

  const DurationField({
    super.key,
    required this.value,
    required this.title,
    required this.onValueChange,
  });

  @override
  _DurationFieldState createState() => _DurationFieldState();
}

class _DurationFieldState extends State<DurationField> {
  late TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatDuration(widget.value));
  }

  String _formatDuration(num seconds) {
    int days = (seconds / (24 * 60 * 60)).floor();
    int hours = ((seconds % (24 * 60 * 60)) / (60 * 60)).floor();
    int minutes = ((seconds % (60 * 60)) / 60).floor();
    int remainingSeconds = (seconds % 60).floor();

    return '${days}d:${hours}h:${minutes}m:${remainingSeconds}s';
  }

  num _parseDuration(String value) {
    final regex = RegExp(r'(\d+)d:(\d+)h:(\d+)m:(\d+)s');
    final match = regex.firstMatch(value);

    if (match != null) {
      int days = int.parse(match.group(1)!);
      int hours = int.parse(match.group(2)!);
      int minutes = int.parse(match.group(3)!);
      int seconds = int.parse(match.group(4)!);

      // Convert everything to seconds
      return days * 24 * 60 * 60 + hours * 60 * 60 + minutes * 60 + seconds;
    } else {
      return 0; // Invalid format, return 0
    }
  }

  void _onChanged(String value) {
    // Validate the input format
    final regex = RegExp(r'^\d+d:\d+h:\d+m:\d+s$');
    if (regex.hasMatch(value)) {
      final parsedSeconds = _parseDuration(value);
      widget.onValueChange(parsedSeconds);
      setState(() {
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = 'Invalid format. Please use Xd:Xh:Xm:Xs';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.title,
        errorText: _errorMessage,
      ),
      keyboardType: TextInputType.number,
      onChanged: _onChanged,
    );
  }
}
