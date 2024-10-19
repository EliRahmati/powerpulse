import 'package:flutter/material.dart';

/// Displays detailed information about a SampleItem.
class MethodPage extends StatelessWidget {
  const MethodPage(
      {super.key, required this.type, required this.id, required this.title});

  final String type;
  final String id;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('This is a $type method and the Id is $id'),
      ),
    );
  }
}
