import 'package:flutter/material.dart';

class PopupButtonWithCheckboxList extends StatelessWidget {
  final List<String> items;
  final List<String> itemsTitle;
  final List<String> selectedItems;
  final Function(List<String>) onValueChange;
  final String title;

  PopupButtonWithCheckboxList({
    required this.items,
    required this.itemsTitle,
    required this.selectedItems,
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
              return CheckboxDialog(
                items: items,
                itemsTitle: itemsTitle,
                selectedItems: selectedItems,
                onValueChange: onValueChange,
              );
            },
          ),
      child: Text(title),
    );
  }
}

class CheckboxDialog extends StatefulWidget {
  final List<String> items;
  final List<String> itemsTitle;
  final List<String> selectedItems;
  final Function(List<String>) onValueChange;

  CheckboxDialog({
    required this.items,
    required this.itemsTitle,
    required this.selectedItems,
    required this.onValueChange,
  });

  @override
  _CheckboxDialogState createState() => _CheckboxDialogState();
}

class _CheckboxDialogState extends State<CheckboxDialog> {
  late List<String> currentSelectedItems;

  @override
  void initState() {
    super.initState();
    currentSelectedItems = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    int index = -1;
    var items =
        widget.items.map((item) {
          index++;
          return CheckboxListTile(
            title: Text(widget.itemsTitle[index]),
            value: currentSelectedItems.contains(item),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  currentSelectedItems.add(item);
                } else {
                  currentSelectedItems.remove(item);
                }
              });
              widget.onValueChange(currentSelectedItems);
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
