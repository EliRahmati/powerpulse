import 'package:flutter/material.dart';

class PopupButtonWithRadioList extends StatelessWidget {
  final List<String> items;
  final List<String> itemsTitle;
  final String selectedItem;
  final Function(String) onValueChange;
  final String title;

  PopupButtonWithRadioList({
    required this.items,
    required this.itemsTitle,
    required this.selectedItem,
    required this.onValueChange,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:
          () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return RadioDialog(
                items: items,
                itemsTitle: itemsTitle,
                selectedItem: selectedItem,
                onValueChange: onValueChange,
              );
            },
          ),
      child: Text(title),
    );
  }
}

class RadioDialog extends StatefulWidget {
  final List<String> items;
  final List<String> itemsTitle;
  final String selectedItem;
  final Function(String) onValueChange;

  RadioDialog({
    required this.items,
    required this.itemsTitle,
    required this.selectedItem,
    required this.onValueChange,
  });

  @override
  _RadioDialogState createState() => _RadioDialogState();
}

class _RadioDialogState extends State<RadioDialog> {
  late String currentSelectedItem;

  @override
  void initState() {
    super.initState();
    currentSelectedItem = widget.selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    int index = -1;
    var items =
        widget.items.map((item) {
          index++;
          return RadioListTile<String>(
            title: Text(widget.itemsTitle[index]),
            value: item,
            groupValue: currentSelectedItem,
            onChanged: (String? value) {
              setState(() {
                currentSelectedItem = value!;
              });
              widget.onValueChange(currentSelectedItem);
            },
          );
        }).toList();
    return AlertDialog(
      title: const Text('Select data'),
      content: Container(
        constraints: const BoxConstraints(minWidth: 400),
        child: SingleChildScrollView(child: Column(children: items)),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
