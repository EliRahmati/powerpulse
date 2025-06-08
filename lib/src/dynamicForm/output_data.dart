import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

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

class OutputData extends StatefulWidget {
  final Map<dynamic, dynamic> schema;
  final Map<dynamic, dynamic> data;

  const OutputData({super.key, required this.schema, required this.data});

  @override
  _OutputDataState createState() => _OutputDataState();
}

class _OutputDataState extends State<OutputData> {
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

  List<DataColumn> getColumns() {
    List<DataColumn> columns = [];
    columns.add(const DataColumn(label: Text('index')));
    widget.schema['outputs']['properties'].entries
        .where((entry) => entry.value['type'] != 'plot')
        .forEach((entry) {
          columns.add(DataColumn(label: Text(entry.value['title'])));
        });
    return columns;
  }

  List<DataRow> getRows() {
    List<DataRow> rows = [];
    var allEntries =
        widget.schema['outputs']['properties'].entries
            .where((entry) => entry.value['type'] != 'plot')
            .toList();

    var firstKey = allEntries[0].key;
    var firstData = widget.data['outputs'][firstKey];
    int n = firstData == null ? 0 : firstData.length;

    for (int index = 0; index < n; index++) {
      List<DataCell> cells = [];
      cells.add(DataCell(Text('$index')));
      allEntries.forEach((entry) {
        cells.add(
          DataCell(Text(widget.data['outputs'][entry.key][index].toString())),
        );
      });
      rows.add(DataRow(cells: cells));
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 600,
        columns: getColumns(),
        rows: getRows(),
      ),
    );
  }
}
