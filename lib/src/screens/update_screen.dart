import 'package:flutter/material.dart';

import 'package:powerpulse/src/models/user.dart';
import 'package:powerpulse/src/utils/update_person_form.dart';

class UpdateScreen extends StatefulWidget {
  final int index;
  final User user;

  const UpdateScreen({
    required this.index,
    required this.user,
  });

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update User Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: UpdatePersonForm(
          index: widget.index,
          user: widget.user,
        ),
      ),
    );
  }
}
