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

class ExampleSidebarX extends StatelessWidget {
  const ExampleSidebarX({
    Key? key,
    required SidebarXController controller,
  })  : _controller = controller,
        super(key: key);

  final SidebarXController _controller;

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: scaffoldBackgroundColor,
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        hoverTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: canvasColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: actionColor.withOpacity(0.37),
          ),
          gradient: const LinearGradient(
            colors: [accentCanvasColor, canvasColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: canvasColor,
        ),
      ),
      footerDivider: divider,
      items: [
        SidebarXItem(
          icon: Icons.home,
          label: 'Home',
          onTap: () {
            debugPrint('Home');
          },
        ),
        const SidebarXItem(
          icon: Icons.search,
          label: 'Search',
        ),
        const SidebarXItem(
          icon: Icons.people,
          label: 'People',
        ),
        SidebarXItem(
          icon: Icons.favorite,
          label: 'Favorites',
          selectable: false,
          onTap: () => _showDisabledAlert(context),
        ),
        const SidebarXItem(
          iconWidget: FlutterLogo(size: 20),
          label: 'Flutter',
        ),
      ],
    );
  }

  void _showDisabledAlert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Item disabled for selecting',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}

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
      appBar: AppBar(title: Text('Dynamic Form')),
      drawer: ExampleSidebarX(controller: _controller),
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
