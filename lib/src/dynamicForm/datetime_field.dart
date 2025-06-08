import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For DateFormat

enum DateTimeFieldType { datetime, date }

class DateTimeField extends StatefulWidget {
  final String? value;
  final String title;
  final Function(String) onValueChange;
  final DateTimeFieldType type;

  const DateTimeField({
    super.key,
    required this.value,
    required this.title,
    required this.onValueChange,
    required this.type,
  });

  @override
  _DateTimeFieldState createState() => _DateTimeFieldState();
}

class _DateTimeFieldState extends State<DateTimeField> {
  late TextEditingController _controller;
  String? _errorMessage;

  String _format = '';
  // widget.type = DateTimeFieldType.datetime;

  @override
  void initState() {
    super.initState();

    if (widget.type == DateTimeFieldType.datetime) {
      _format = 'dd/MM/yyyy HH:mm';
    } else if (widget.type == DateTimeFieldType.date) {
      _format = 'dd/MM/yyyy';
    }

    final error = _init_validator(widget.value ?? '');
    if (error != null) {
      setState(() {
        _errorMessage = error; // Show validation error
      });
    }
    // Initialize the controller with the formatted DateTime string
    _controller = TextEditingController(
      text:
          error != null
              ? widget.value
              : DateFormat(_format).format(DateTime.parse(widget.value!)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _init_validator(String value) {
    try {
      DateTime.parse(value);
      return null; // If no exception occurs, the input is valid
    } catch (e) {
      return 'Invalid date-time format';
    }
  }

  DateTime tryToParse(String value) {
    try {
      DateTime datetime = DateTime.parse(value);
      return datetime; // If no exception occurs, the input is valid
    } catch (e) {
      return DateTime.now();
    }
  }

  // Validator function to check if the input matches the format
  String? _validator(String value) {
    try {
      DateTime.parse(DateFormat(_format).parseStrict(value).toIso8601String());
      return null; // If no exception occurs, the input is valid
    } catch (e) {
      return 'Invalid date-time format. Please use $_format';
    }
  }

  void _onChanged(String value) {
    final error = _validator(value);

    if (error == null) {
      try {
        // Try to parse the input value using the provided format
        DateTime enteredDate = DateFormat(_format).parse(value);
        widget.onValueChange(
          enteredDate.toIso8601String(),
        ); // Pass the valid DateTime to the callback
        setState(() {
          _errorMessage = null;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Invalid date-time format. Please use $_format';
        });
      }
    } else {
      setState(() {
        _errorMessage = error; // Show validation error
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
        suffixIcon: GestureDetector(
          onTap: () async {
            // Prevent the keyboard from appearing
            FocusScope.of(context).requestFocus(FocusNode());

            // Open the date picker and pass the current selected date
            final selectedDateTime = await showDatePicker(
              context: context,
              initialDate: tryToParse(widget.value!),
              firstDate: DateTime(0),
              lastDate: DateTime(99999999),
            );

            if (selectedDateTime != null) {
              if (widget.type == DateTimeFieldType.date) {
                setState(() {
                  _controller.text = DateFormat(
                    _format,
                  ).format(selectedDateTime);
                  widget.onValueChange(
                    selectedDateTime.toIso8601String(),
                  ); // Update with the new DateTime
                  _errorMessage = null; // Clear any error messages
                });
              } else if (widget.type == DateTimeFieldType.datetime) {
                // Show the time picker with the initial time based on the current selected DateTime
                final selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(
                    tryToParse(widget.value!),
                  ),
                );

                if (selectedTime != null) {
                  final combinedDateTime = DateTime(
                    selectedDateTime.year,
                    selectedDateTime.month,
                    selectedDateTime.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );

                  setState(() {
                    _controller.text = DateFormat(
                      _format,
                    ).format(combinedDateTime);
                    widget.onValueChange(
                      combinedDateTime.toIso8601String(),
                    ); // Update with the new DateTime
                    _errorMessage = null; // Clear any error messages
                  });
                }
              }
            }
          },
          child: const Icon(Icons.calendar_today_rounded),
        ),
      ),
      keyboardType: TextInputType.datetime,
      onChanged: _onChanged,
    );
  }
}
