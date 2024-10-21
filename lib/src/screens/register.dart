import 'package:flutter/material.dart';
import 'package:powerpulse/src/utils/register_user.dart';

class AddScreen extends StatefulWidget {
  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New User'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: AddPersonForm(),
      ),
    );
  }
}
