import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powerpulse/src/globals.dart' as globals;
import 'dart:async'; // Import for Timer

num convertValue(num value, String prefix) {
  return value * globals.prefixMultipliers[prefix]!;
}

enum NumberFieldType { integer, float }

class NumberField extends StatefulWidget {
  final num value;
  final String title;
  final String? unit;
  final String? unitPrefix;
  final Function(num) onValueChange;
  final Function(String)? onUnitPrefixChange;
  final num? min;
  final num? max;
  final NumberFieldType type;

  const NumberField({
    super.key,
    required this.value,
    required this.title,
    this.unit,
    this.unitPrefix,
    required this.onValueChange,
    this.onUnitPrefixChange,
    required this.min,
    required this.max,
    required this.type,
  });

  @override
  _NumberFieldState createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  late TextEditingController _controller;
  String? _errorMessage;
  final List<String> _unitPrefixes = globals.prefixMultipliers.keys.toList();
  Timer? _debounceTimer;
  bool _isDropdownOpen = false; // To track dropdown visibility

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: widget.unit == null
            ? widget.value.toString()
            : convertValue(widget.value, widget.unitPrefix!).toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  String? _validator(String? value) {
    num inputValue = 0;
    if (value == null || value.isEmpty) {
      return 'Invalid number';
    }
    try {
      inputValue = num.parse(value);
    } catch (e) {
      return 'Invalid number';
    }
    if (widget.max == null && widget.min != null) {
      if (inputValue < (widget.min as num)) {
        return 'Value must be greater than ${widget.min}';
      }
    } else if (widget.max != null && widget.min == null) {
      if (inputValue > (widget.max as num)) {
        return 'Value must be less than ${widget.max}';
      }
    } else if (widget.min != null && widget.max != null) {
      if (inputValue < (widget.min as num) ||
          inputValue > (widget.max as num)) {
        return 'Value must be between ${widget.min} and ${widget.max}';
      }
    }
    return null;
  }

  void _onUnitPrefixChange(String? newPrefix) {
    if (widget.onUnitPrefixChange != null && newPrefix != null) {
      widget.onUnitPrefixChange!(newPrefix);
      setState(() {
        _controller.text = widget.unit == null
            ? widget.value.toString()
            : convertValue(widget.value, newPrefix).toString();
        _controller.selection = TextSelection.collapsed(
            offset: _controller.text.length); // To move the cursor to the end
      });
    }
  }

  TextInputFormatter _inputFormatter() {
    if (widget.type == NumberFieldType.integer) {
      return FilteringTextInputFormatter.allow(RegExp(r'[\d+\-]+'));
    } else if (widget.type == NumberFieldType.float) {
      return FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\.eE]+'));
    }
    return FilteringTextInputFormatter.digitsOnly;
  }

  void _debouncedOnChanged(String value) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(Duration(milliseconds: 700), () {
      var error = _validator(value);
      if (error == null) {
        widget.onValueChange(num.parse(value));
      }
      setState(() {
        _errorMessage = error;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: _controller,
            keyboardType: widget.type == NumberFieldType.integer
                ? TextInputType.number
                : const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: widget.title,
              errorText: _errorMessage,
              suffixIcon: widget.unit != null
                  ? GestureDetector(
                      onTap: () async {
                        final RenderBox renderBox =
                            context.findRenderObject() as RenderBox;
                        final offset = renderBox.localToGlobal(Offset.zero);
                        final selectedPrefix = await showMenu<String>(
                          context: context,
                          position: RelativeRect.fromLTRB(
                              offset.dx, offset.dy, 0.0, 0.0),
                          items: _unitPrefixes.map((String prefix) {
                            return PopupMenuItem<String>(
                              value: prefix,
                              child: Text('$prefix${widget.unit}'),
                            );
                          }).toList(),
                        );
                        if (selectedPrefix != null) {
                          _onUnitPrefixChange(selectedPrefix);
                        }
                      },
                      child: Chip(
                        label: Text('${widget.unitPrefix}${widget.unit}'),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20), // Rounded border
                        ),
                      ),
                    )
                  : null,
            ),
            inputFormatters: [_inputFormatter()],
            onChanged: (value) {
              _debouncedOnChanged(value);
            },
          ),
        ),
      ],
    );
  }
}
