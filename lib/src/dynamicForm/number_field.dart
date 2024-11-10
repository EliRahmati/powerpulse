import 'package:flutter/material.dart';
import 'package:powerpulse/src/globals.dart' as globals;

double convertValue(double value, String prefix) {
  return value * globals.prefixMultipliers[prefix]!;
}

class NumberField extends StatefulWidget {
  final double value;
  final String title;
  final String unit;
  final String unitPrefix;
  final Function(double) onValueChange;
  final Function(String) onUnitPrefixChange;
  final double min;
  final double max;

  const NumberField({
    super.key,
    required this.value,
    required this.title,
    required this.unit,
    required this.unitPrefix,
    required this.onValueChange,
    required this.onUnitPrefixChange,
    required this.min,
    required this.max,
  });

  @override
  _NumberFieldState createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  late TextEditingController _controller;
  String? _errorMessage;
  final List<String> _unitPrefixes = globals.prefixMultipliers.keys.toList();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validator(String? value) {
    double inputValue = 0;
    if (value != null) {
      inputValue = double.parse(value);
    }
    if (inputValue < widget.min || inputValue > widget.max) {
      return 'Value must be between ${widget.min} and ${widget.max}';
    } else {
      return null;
    }
  }

  void _onUnitPrefixChange(String? newPrefix) {
    if (newPrefix != null) {
      widget.onUnitPrefixChange(newPrefix);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          validator: _validator,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '${widget.title} (${widget.unitPrefix}${widget.unit})',
            errorText: _errorMessage,
          ),
          onChanged: (value) => widget.onValueChange(double.parse(value)),
        ),
        DropdownButton<String>(
          value: widget.unitPrefix,
          onChanged: _onUnitPrefixChange,
          items: _unitPrefixes.map((String prefix) {
            return DropdownMenuItem<String>(
              value: prefix,
              child: Text('$prefix${widget.unit}'),
            );
          }).toList(),
        ),
      ],
    );
  }
}
