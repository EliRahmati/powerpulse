import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownEditor extends StatefulWidget {
  final String? value;
  final String title;
  final Function(String) onValueChanged;

  const MarkdownEditor({
    Key? key,
    required this.value,
    required this.title,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  _MarkdownEditorState createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late TextEditingController _controller;
  bool _isTextFieldVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
      children: [
        // Title with Icon Button to switch views
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
            ),
            IconButton(
              icon: Icon(
                _isTextFieldVisible ? Icons.visibility : Icons.edit,
              ),
              onPressed: () {
                setState(() {
                  _isTextFieldVisible = !_isTextFieldVisible;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 5), // Add space between the title and the editor
        Container(
          height: 150,
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: _isTextFieldVisible
                ? TextField(
                    controller: _controller,
                    onChanged: (text) {
                      widget.onValueChanged(text);
                    },
                    keyboardType: TextInputType.multiline,
                    minLines: 10,
                    maxLines: null, // Allow multi-line input
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).highlightColor),
                  )
                : ConstrainedBox(
                    constraints:
                        BoxConstraints(maxHeight: 150), // Set max height to 250
                    child: SingleChildScrollView(
                      child: MarkdownBody(
                        selectable: true,
                        shrinkWrap: true,
                        data: _controller.text,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
