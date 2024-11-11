import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:powerpulse/src/dynamicForm/number_field.dart';
import 'package:sidebarx/sidebarx.dart';

const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);

class DynamicForm extends StatefulWidget {
  final Map<String, dynamic> schema;
  final Map<String, dynamic> data;

  const DynamicForm({super.key, required this.schema, required this.data});

  @override
  _DynamicFormState createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  double mayValue = 100;
  String unitPrefix = 'k';

  Widget _buildField(String key, dynamic value) {
    switch (value['type']) {
      case 'string':
        return TextFormField(
          decoration: InputDecoration(labelText: value['title']),
          onChanged: (text) => widget.data[key] = text,
          initialValue: widget.data[key],
          validator: (text) {
            if (value['maxLength'] != null &&
                text!.length > value['maxLength']) {
              return 'Max length is ${value['maxLength']} characters';
            }
            return null;
          },
        );
      case 'integer':
        return TextFormField(
          decoration: InputDecoration(labelText: value['title']),
          keyboardType: TextInputType.number,
          initialValue: widget.data[key].toString(),
          onChanged: (text) => widget.data[key] = int.tryParse(text),
          validator: (text) {
            if (text == null || text.isEmpty) {
              return 'Please enter your age';
            }
            if (int.tryParse(text) == null) {
              return 'Please enter a valid integer';
            }
            return null;
          },
        );
      case 'number':
        return NumberField(
          value: mayValue,
          title: 'Amount',
          unit: 'g',
          unitPrefix: unitPrefix,
          onValueChange: (newValue) {
            setState(() {
              mayValue = newValue;
            });
          },
          onUnitPrefixChange: (newPrefix) {
            setState(() {
              unitPrefix = newPrefix;
            });
          },
          min: 0.0,
          max: 1000.0,
        );
      // return TextFormField(
      //   decoration: InputDecoration(labelText: value['title']),
      //   keyboardType: TextInputType.numberWithOptions(decimal: true),
      //   initialValue: widget.data[key].toString(),
      //   onChanged: (text) => widget.data[key] = double.tryParse(text),
      // );
      case 'boolean':
        return Row(
          children: [
            Text(value['title']),
            Checkbox(
              value: widget.data[key] ?? false,
              onChanged: (bool? newValue) {
                setState(() {
                  widget.data[key] = newValue;
                });
              },
            ),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }

  final _controller = SidebarXController(selectedIndex: 0, extended: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.schema == null
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    ...widget.schema!['properties'].entries.map((entry) {
                      return _buildField(entry.key, entry.value);
                    }).toList(),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Process the data
                          print(widget.data);
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
