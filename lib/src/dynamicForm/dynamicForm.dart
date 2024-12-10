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
        return NumberField(
          value: widget.data[key],
          title: value['title'],
          type: NumberFieldType.integer,
          onValueChange: (newValue) {
            setState(() {
              widget.data[key] = newValue;
            });
          },
          min: value['minimum']?.toInt(),
          max: value['maximum']?.toInt(),
        );
      case 'float':
        final unit = value['unit'] ?? '';
        return NumberField(
          value: widget.data[key],
          title: value['title'],
          unit: unit,
          type: NumberFieldType.float,
          unitPrefix:
              unit != null ? widget.data['${key}_shown_unitprefix'] : null,
          onValueChange: (newValue) {
            setState(() {
              widget.data[key] = newValue;
            });
          },
          onUnitPrefixChange: (newPrefix) {
            setState(() {
              widget.data['${key}_shown_unitprefix'] = newPrefix;
            });
          },
          min: value['minimum']?.toDouble(),
          max: value['maximum']?.toDouble(),
        );
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
      case 'date':
        return TextFormField(
          decoration: InputDecoration(labelText: value['title']),
          readOnly: true,
          controller: TextEditingController(
            text: widget.data[key]?.toString(),
          ),
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (selectedDate != null) {
              setState(() {
                widget.data[key] = selectedDate.toIso8601String().split('T')[0];
              });
            }
          },
        );
      case 'time':
        return TextFormField(
          decoration: InputDecoration(labelText: value['title']),
          readOnly: true,
          controller: TextEditingController(
            text: widget.data[key]?.toString(),
          ),
          onTap: () async {
            final selectedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (selectedTime != null) {
              setState(() {
                widget.data[key] = selectedTime.format(context);
              });
            }
          },
        );
      case 'datetime':
        return TextFormField(
          decoration: InputDecoration(labelText: value['title']),
          readOnly: true,
          controller: TextEditingController(
            text: widget.data[key]?.toString(),
          ),
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (selectedDate != null) {
              final selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (selectedTime != null) {
                setState(() {
                  widget.data[key] = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  ).toIso8601String();
                });
              }
            }
          },
        );
      case 'enum':
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: value['title']),
          value: widget.data[key],
          items: (value['enum'] as List<dynamic>)
              .map((item) => DropdownMenuItem<String>(
                    value: item as String,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: (newValue) {
            setState(() {
              widget.data[key] = newValue;
            });
          },
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ...widget.schema['properties'].entries.map((entry) {
                return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: _buildField(entry.key, entry.value));
              }).toList(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Process the data
                    print(widget.data);
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
