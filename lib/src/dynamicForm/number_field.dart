import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powerpulse/src/globals.dart' as globals;
import 'dart:async'; // Import for Timer

num convertValue(num basevalue, String prefix) {
  return basevalue / globals.prefixMultipliers[prefix]!;
}

num baseValue(num value, String prefix) {
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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text:
          widget.unit == null
              ? widget.value.toString()
              : convertValue(widget.value, widget.unitPrefix!).toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  String? _textValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Invalid number';
    }
    try {
      num.parse(value);
    } catch (e) {
      return 'Invalid number';
    }
    return null;
  }

  String? _numValidator(num value) {
    var minInUnit =
        widget.unit != null && widget.min != null
            ? '${convertValue(widget.min!, widget.unitPrefix!)} (${widget.unitPrefix}${widget.unit})'
            : widget.min;
    var maxInUnit =
        widget.unit != null && widget.max != null
            ? '${convertValue(widget.max!, widget.unitPrefix!)} (${widget.unitPrefix}${widget.unit})'
            : widget.max;
    if (widget.max == null && widget.min != null) {
      if (value < (widget.min as num)) {
        return 'Value must be greater than $minInUnit';
      }
    } else if (widget.max != null && widget.min == null) {
      if (value > (widget.max as num)) {
        return 'Value must be less than $maxInUnit';
      }
    } else if (widget.min != null && widget.max != null) {
      if (value < (widget.min as num) || value > (widget.max as num)) {
        return 'Value must be between $minInUnit and $maxInUnit';
      }
    }
    return null;
  }

  void _onUnitPrefixChange(String? newPrefix) {
    if (widget.onUnitPrefixChange != null && newPrefix != null) {
      widget.onUnitPrefixChange!(newPrefix);
      setState(() {
        _controller.text =
            widget.unit == null
                ? widget.value.toString()
                : convertValue(widget.value, newPrefix).toString();
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        ); // To move the cursor to the end
        _errorMessage = null;
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

    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      var error = _textValidator(value);
      if (error != null) {
        setState(() {
          _errorMessage = error;
        });
      } else {
        num base = num.parse(value);
        if (widget.unit != null) {
          base = baseValue(num.parse(value), widget.unitPrefix!);
        }
        var numError = _numValidator(base);
        widget.onValueChange(base);
        setState(() {
          _errorMessage = numError;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var numError = _numValidator(widget.value);
    _errorMessage = numError;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: TextEditingController(
              text:
                  widget.unit == null
                      ? widget.value.toString()
                      : convertValue(
                        widget.value,
                        widget.unitPrefix!,
                      ).toString(),
            ),
            keyboardType:
                widget.type == NumberFieldType.integer
                    ? TextInputType.number
                    : const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: widget.title,
              errorText: _errorMessage,
              suffixIcon:
                  widget.unit != null
                      ? GestureDetector(
                        onTapDown: (details) async {
                          final offset = details.globalPosition;
                          final selectedPrefix = await showMenu<String>(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              offset.dx,
                              offset.dy - 40,
                              MediaQuery.of(context).size.width -
                                  offset.dx -
                                  40,
                              MediaQuery.of(context).size.height - offset.dy,
                            ),
                            items:
                                _unitPrefixes.map((String prefix) {
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
                            borderRadius: BorderRadius.circular(
                              20,
                            ), // Rounded border
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
