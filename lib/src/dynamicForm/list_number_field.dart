import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powerpulse/src/globals.dart' as globals;
import 'package:powerpulse/src/dynamicForm/number_field.dart';
import 'dart:async'; // Import for Timer

class ListNumbers extends StatefulWidget {
  final List<num> values; // Changed to accept a list of numbers
  final String title;
  final String? unit;
  final String? unitPrefix;
  final Function(List<num>) onValueChange;
  final Function(String)? onUnitPrefixChange;
  final num? min;
  final num? max;
  final NumberFieldType type;
  final bool? withDeleteAction;

  const ListNumbers({
    super.key,
    required this.values,
    required this.title,
    this.unit,
    this.unitPrefix,
    required this.onValueChange,
    this.onUnitPrefixChange,
    required this.min,
    required this.max,
    required this.type,
    this.withDeleteAction,
  });

  @override
  _ListNumbersState createState() => _ListNumbersState();
}

class _ListNumbersState extends State<ListNumbers> {
  late List<TextEditingController> _controllers;
  late Map<int, String?> _errorMessage;
  final List<String> _unitPrefixes = globals.prefixMultipliers.keys.toList();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controllers = widget.values
        .map((value) => TextEditingController(
            text: widget.unit == null
                ? value.toString()
                : convertValue(value, widget.unitPrefix!).toString()))
        .toList();
    _errorMessage = {};
    widget.values.asMap().forEach((index, value) {
      var numError = _numValidator(value);
      _errorMessage[index] = numError;
    });
  }

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    _debounceTimer?.cancel();
    super.dispose();
  }

  void setController() {}

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
    var minInUnit = widget.unit != null
        ? '${convertValue(widget.min!, widget.unitPrefix!)} (${widget.unitPrefix}${widget.unit})'
        : widget.min;
    var maxInUnit = widget.unit != null
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
        _controllers = widget.values
            .map((value) => TextEditingController(
                text: widget.unit == null
                    ? value.toString()
                    : convertValue(value, newPrefix).toString()))
            .toList();
        _errorMessage = {};
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

  void _debouncedOnChanged(String value, int index) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      var error = _textValidator(value);
      if (error != null) {
        setState(() {
          _errorMessage[index] = error;
        });
      } else {
        num base = num.parse(value);
        if (widget.unit != null) {
          base = baseValue(num.parse(value), widget.unitPrefix!);
        }
        var numError = _numValidator(base);
        widget.values[index] = base;
        widget.onValueChange(widget.values);
        setState(() {
          _errorMessage[index] = numError;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _errorMessage = {};
    widget.values.asMap().forEach((index, value) {
      var numError = _numValidator(value);
      _errorMessage[index] = numError;
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.unit != null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(widget.title),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTapDown: (details) async {
                      final offset = details.globalPosition;
                      final selectedPrefix = await showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          offset.dx,
                          offset.dy - 40,
                          MediaQuery.of(context).size.width - offset.dx - 40,
                          MediaQuery.of(context).size.height - offset.dy,
                        ),
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
                    child: Container(
                      alignment: Alignment.center,
                      child: Chip(
                        visualDensity:
                            const VisualDensity(horizontal: 0.0, vertical: -4),
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                        label: Text('${widget.unitPrefix}${widget.unit}'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Text(widget.title),
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Column(
            children: List.generate(
              widget.values.length,
              (index) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: (widget.values
                          .map((value) => TextEditingController(
                              text: widget.unit == null
                                  ? value.toString()
                                  : convertValue(value, widget.unitPrefix!)
                                      .toString()))
                          .toList())[index],
                      keyboardType: widget.type == NumberFieldType.integer
                          ? TextInputType.number
                          : const TextInputType.numberWithOptions(
                              decimal: true),
                      decoration: InputDecoration(
                        errorText: _errorMessage[index],
                        suffixIcon: widget.withDeleteAction == true
                            ? IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  widget.values.removeAt(index);
                                  widget.onValueChange(widget.values);
                                },
                              )
                            : null,
                      ),
                      inputFormatters: [_inputFormatter()],
                      onChanged: (value) {
                        _debouncedOnChanged(value, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
