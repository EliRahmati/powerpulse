import 'package:flutter/material.dart';
import 'package:powerpulse/src/plot/plot.dart';

class ArrayShape {
  final String baseType;
  final int depth;
  final List<int> arrayDepths;

  ArrayShape({
    required this.baseType,
    required this.depth,
    required this.arrayDepths,
  });

  @override
  String toString() {
    return 'Base Type: $baseType, Depth: $depth, Array Depths: $arrayDepths';
  }
}

ArrayShape getShape(String type) {
  // Trim any leading/trailing spaces
  type = type.trim();

  // If the type is empty, return undetermined length
  if (type.isEmpty) {
    return ArrayShape(baseType: 'Unknown', depth: -1, arrayDepths: []);
  }

  // Regex pattern to match type and count array dimensions (any number of [])
  RegExp arrayRegex = RegExp(r'(\w+)(\[(\d*)\])*');

  // Match the type string against the regex
  var match = arrayRegex.firstMatch(type);

  // If the match is null, the input is invalid (i.e., it doesn't match a valid type)
  if (match == null) {
    return ArrayShape(baseType: 'Invalid', depth: -1, arrayDepths: []);
  }

  // The first part of the match will be the base type (e.g., "float")
  String baseType = match.group(1) ?? "";

  // The second part will represent the array brackets and we count them
  String arrayPart = match.group(2) ?? "";
  int depth = 0;
  if (arrayPart != "") {
    depth = 1;
  }

  String arrayLength = match.group(3) ?? "";
  List<int> arrayDepths = [];
  arrayDepths.add(arrayLength.isEmpty ? -1 : int.tryParse(arrayLength) ?? -1);

  if (arrayDepths.isEmpty) {
    return ArrayShape(baseType: baseType, depth: 0, arrayDepths: []);
  }

  // Return the structure containing the baseType, depth, and array sizes at each depth
  return ArrayShape(baseType: baseType, depth: depth, arrayDepths: arrayDepths);
}

class OutputFigures extends StatefulWidget {
  final Map<dynamic, dynamic> schema;
  final Map<dynamic, dynamic> data;

  const OutputFigures({super.key, required this.schema, required this.data});

  @override
  _OutputFiguresState createState() => _OutputFiguresState();
}

class _OutputFiguresState extends State<OutputFigures> {
  @override
  void initState() {
    super.initState();
  }

  T? get<T>(List<T>? list, int index) {
    if (list != null && index >= 0 && index < list.length) {
      return list[index];
    }
    return null;
  }

  Widget _buildField(String key, Map<String, dynamic> schema) {
    ArrayShape arrayShape = getShape(schema['type']);

    switch (arrayShape.baseType) {
      case 'plot':
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5, // Shadow of the card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Plot(
                title: schema['title'],
                x: schema['x'],
                y: schema['y'],
                schema: widget.schema,
                data: widget.data,
                minX: schema['minX'],
                maxX: schema['maxX'],
                minY: schema['minY'],
                maxY: schema['maxY'],
                zoomX: schema['zoomX'],
                zoomY: schema['zoomY'],
                defaultX: schema['defaultX'],
                defaultY: schema['defaultY'],
                xShownUnitprefix: schema['x_shown_unitprefix'],
                yShownUnitprefix: schema['y_shown_unitprefix'],
              ),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Add this line to make the form scrollable
      child: Column(
        children: [
          ...widget.schema['outputs']['properties'].entries.map((entry) {
            return _buildField(entry.key, entry.value);
          }).toList(),
        ],
      ),
    );
  }
}
