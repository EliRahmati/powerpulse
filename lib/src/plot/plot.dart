import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:powerpulse/src/dynamicForm/dynamicForm.dart';
import 'package:powerpulse/src/utils/popup_checkbox.dart';
import 'package:powerpulse/src/utils/popup_radio.dart';
import 'package:powerpulse/src/globals.dart' as globals;

num convertValue(num basevalue, String prefix) {
  return basevalue / globals.prefixMultipliers[prefix]!;
}

List<Color> linePlotColors = [
  Colors.indigo,
  const Color(0xFF800000),
  const Color(0xFF000080),
  Colors.pink,
  Colors.deepPurple,
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.yellow,
  Colors.red,
  Colors.cyan,
  Colors.brown,
  Colors.pink,
  Colors.teal,
  Colors.lime,
  Colors.amber,
  Colors.deepOrange,
  Colors.blueGrey,
  Colors.lightBlue,
  Colors.lightGreen,
  Colors.limeAccent,
  Colors.grey,
  Colors.blueAccent,
  Colors.redAccent,
  Colors.greenAccent,
  Colors.purpleAccent,
  Colors.orangeAccent,
  Colors.yellowAccent,
  Colors.cyanAccent,
  Colors.pinkAccent,
];

class Plot extends StatefulWidget {
  final String title;
  final List<dynamic> x;
  final List<dynamic> y;
  final Map<dynamic, dynamic> schema;
  final Map<dynamic, dynamic> data;
  final dynamic minX;
  final dynamic maxX;
  final dynamic minY;
  final dynamic maxY;
  final bool? zoomX;
  final bool? zoomY;
  final String? defaultX;
  final List<dynamic>? defaultY;
  final List<dynamic>? xShownUnitprefix;
  final String? yShownUnitprefix;

  const Plot({
    super.key,
    required this.title,
    required this.x,
    required this.y,
    required this.schema,
    required this.data,
    this.minX,
    this.maxX,
    this.minY,
    this.maxY,
    this.zoomX,
    this.zoomY,
    this.defaultX,
    this.defaultY,
    this.xShownUnitprefix,
    this.yShownUnitprefix,
  });

  @override
  _PlotState createState() => _PlotState();
}

class _PlotState extends State<Plot> {
  String _selectedX = ""; // Store the selected X value
  List<String> _selectedY = []; // Store the selected Y value
  final List<LineChartBarData> _lineBarsData = List.from([]);
  final List<Widget> _legends = List.from([]);
  late TransformationController _transformationController;
  double? _minX;
  double? _maxX;
  double? _minY;
  double? _maxY;
  FlScaleAxis _scaleAxis = FlScaleAxis.none;
  Widget _resetZoom = const SizedBox(width: 1);
  final Map<String, Color> _dataColors = {};
  final List<String> _unitPrefixes = globals.prefixMultipliers.keys.toList();
  String? _xUnitPrefix;
  String? _xUnit;
  String? _yUnitPrefix;
  String? _yUnit;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();

    _dataColors.clear();
    int i = -1;
    for (var item in widget.y) {
      i++;
      _dataColors[item] = linePlotColors[i];
    }

    // Set default values if available
    if (widget.defaultX != null) {
      if (widget.defaultX?.contains(widget.defaultX!) == true) {
        _selectedX = widget.defaultX as String;
      } else {
        _selectedX = widget.x.first;
      }
    } else {
      if (widget.x.isNotEmpty) {
        _selectedX = widget.x.first;
      }
    }

    if (widget.defaultY != null) {
      List<String> defaults = [];
      for (var item in widget.y) {
        if (widget.defaultY?.contains(item) == true) {
          defaults.add(item);
        }
      }
      if (defaults.isNotEmpty) {
        _selectedY = defaults;
      } else {
        _selectedY = [widget.y.first];
      }
    } else {
      if (widget.y.isNotEmpty) {
        _selectedY = [widget.y.first];
      }
    }

    if (widget.zoomX == true && widget.zoomY == true) {
      _scaleAxis = FlScaleAxis.free;
    } else {
      if (widget.zoomX == true) {
        _scaleAxis = FlScaleAxis.horizontal;
      } else if (widget.zoomY == true) {
        _scaleAxis = FlScaleAxis.vertical;
      }
    }

    if (widget.zoomX == true || widget.zoomY == true) {
      _resetZoom = Tooltip(
        message: 'Reset zoom',
        child: IconButton(
          icon: const Icon(Icons.refresh, size: 16),
          onPressed: _transformationReset,
        ),
      );
    }

    _xUnit = getUnitFromSchema(_selectedX);
    int selectedXIndex = widget.x.indexOf(_selectedX);
    _xUnitPrefix =
        widget.xShownUnitprefix != null
            ? widget.xShownUnitprefix![selectedXIndex]
            : '';
    _yUnit = getUnitFromSchema(widget.y.first);
    _yUnitPrefix = widget.yShownUnitprefix ?? '';
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  List<String?> extractParts(String path) {
    // Regular expression to match the three parts: inputs.object.x or inputs.object
    RegExp regExp = RegExp(r'^([^\.]+)\.([^\.]+)(?:\.(.*))?$');

    // Check if the path matches the pattern
    var match = regExp.firstMatch(path);

    if (match != null) {
      // Capture the first part, second part, and third part (if available)
      String part1 = match.group(1)!;
      String part2 = match.group(2)!;
      String? part3 = match.group(3);

      // Return the three parts, with null for the third part if it's not available
      return [part1, part2, part3];
    }

    // Return a default value if no match (shouldn't happen with valid input)
    return [null, null, null];
  }

  String getTitleFromSchema(key) {
    var parts = extractParts(key);
    String objectTitle =
        widget.schema[parts[0]]['properties'][parts[1]]['title'];
    if (parts[2] == null) {
      return objectTitle;
    } else {
      String varibleTitle =
          widget
              .schema[parts[0]]['properties'][parts[1]]['properties'][parts[2]]['title'];
      return '$objectTitle $varibleTitle';
    }
  }

  String? getUnitFromSchema(key) {
    var parts = extractParts(key);
    String? objectUnit =
        widget.schema[parts[0]]['properties'][parts[1]]['unit'];
    if (parts[2] == null) {
      return objectUnit;
    } else {
      String? varibleUnit =
          widget
              .schema[parts[0]]['properties'][parts[1]]['properties'][parts[2]]['unit'];
      return varibleUnit;
    }
  }

  double? resolveValue(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      var parts = extractParts(value);
      var x =
          parts[2] == null
              ? widget.data[parts[0]][parts[1]]
              : widget.data[parts[0]][parts[1]][parts[2]];
      if (x is double) {
        return x;
      }
      if (x is int) {
        return x.toDouble();
      }
    }
    return null;
  }

  Color getLineColor(String key) {
    return _dataColors[key] ?? Colors.pink;
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  void setData() {
    _lineBarsData.clear();
    _legends.clear();
    var partsX = extractParts(_selectedX);
    for (var yPath in _selectedY) {
      var partsY = extractParts(yPath);
      var x =
          partsX[2] == null
              ? widget.data[partsX[0]][partsX[1]] ?? []
              : widget.data[partsX[0]][partsX[1]]
                      .map((object) => object[partsX[2]])
                      .toList() ??
                  [];
      var y =
          partsY[2] == null
              ? widget.data[partsY[0]][partsY[1]] ?? []
              : widget.data[partsY[0]][partsY[1]]
                      .map((object) => object[partsY[2]])
                      .toList() ??
                  [];
      int n = x.length < y.length ? x.length : y.length;

      List<FlSpot> spots = List.from([]);
      for (int j = 0; j < n; j++) {
        double xVal =
            _xUnit != null && _xUnitPrefix != null
                ? convertValue(x[j].toDouble(), _xUnitPrefix!).toDouble()
                : x[j].toDouble();
        double yVal =
            _yUnit != null && _yUnitPrefix != null
                ? convertValue(y[j].toDouble(), _yUnitPrefix!).toDouble()
                : y[j].toDouble();
        spots.add(FlSpot(xVal, yVal));
      }
      if (spots.isNotEmpty) {
        _lineBarsData.add(
          LineChartBarData(
            spots: spots,
            isCurved: false,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            color: getLineColor(yPath),
          ),
        );
      }
      _legends.add(
        _buildLegendItem(getLineColor(yPath), getTitleFromSchema(yPath)),
      );
    }

    if (_xUnit != null && _xUnitPrefix != null) {
      double? minXVal = resolveValue(widget.minX);
      if (minXVal != null) {
        _minX = convertValue(minXVal.toDouble(), _xUnitPrefix!).toDouble();
      } else {
        _minX = null;
      }
      double? maxXVal = resolveValue(widget.maxX);
      if (maxXVal != null) {
        _maxX = convertValue(maxXVal.toDouble(), _xUnitPrefix!).toDouble();
      } else {
        _maxX = null;
      }
    } else {
      _minX = resolveValue(widget.minX);
      _maxX = resolveValue(widget.maxX);
    }
    if (_yUnit != null && _yUnitPrefix != null) {
      double? minYVal = resolveValue(widget.minY);
      if (minYVal != null) {
        _minY = convertValue(minYVal.toDouble(), _yUnitPrefix!).toDouble();
      } else {
        _minY = null;
      }
      double? maxYVal = resolveValue(widget.maxY);
      if (maxYVal != null) {
        _maxY = convertValue(maxYVal.toDouble(), _yUnitPrefix!).toDouble();
      } else {
        _maxY = null;
      }
    } else {
      _minY = resolveValue(widget.minY);
      _maxY = resolveValue(widget.maxY);
    }

    if (_lineBarsData.isEmpty) {
      _minX ??= -1.0;
      _maxX ??= 1.0;
      _minY ??= -1.0;
      _maxY ??= 1.0;
    }
  }

  FlLine getHorizontalVerticalLine(double value) {
    if (abs(value) < 0.00000000000001) {
      return const FlLine(
        color: Colors.white70,
        strokeWidth: 1,
        dashArray: [8, 4],
      );
    } else {
      return const FlLine(
        color: Colors.blueGrey,
        strokeWidth: 0.4,
        dashArray: [8, 4],
      );
    }
  }

  FlLine getVerticalVerticalLine(double value) {
    if (abs(value) < 0.00000000000001) {
      return const FlLine(
        color: Colors.white70,
        strokeWidth: 1,
        dashArray: [8, 4],
      );
    } else {
      return const FlLine(
        color: Colors.blueGrey,
        strokeWidth: 0.4,
        dashArray: [8, 4],
      );
    }
  }

  void _transformationReset() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    setData();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title), // Display the current title
        Row(
          children: [
            const SizedBox(width: 20),
            const Text("x:"),
            const SizedBox(width: 10),
            PopupButtonWithRadioList(
              items: List<String>.from(widget.x),
              itemsTitle:
                  widget.y.map((path) => getTitleFromSchema(path)).toList(),
              selectedItem: _selectedX,
              title: getTitleFromSchema(_selectedX),
              onValueChange: (String newSelectedItems) {
                setState(() {
                  _selectedX = newSelectedItems;
                  _xUnit = getUnitFromSchema(_selectedX);
                  int selectedXIndex = widget.x.indexOf(_selectedX);
                  _xUnitPrefix =
                      widget.xShownUnitprefix != null
                          ? widget.xShownUnitprefix![selectedXIndex]
                          : '';
                });
              },
            ),
            _xUnit != null
                ? GestureDetector(
                  onTapDown: (details) async {
                    final offset = details.globalPosition;
                    final selectedPrefix = await showMenu<String>(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        offset.dx,
                        offset.dy - 40,
                        MediaQuery.of(context).size.width - offset.dx - 40,
                        MediaQuery.of(context).size.height - offset.dy,
                      ),
                      items:
                          _unitPrefixes.map((String prefix) {
                            return PopupMenuItem<String>(
                              value: prefix,
                              child: Text('$prefix${_xUnit}'),
                            );
                          }).toList(),
                    );
                    if (selectedPrefix != null) {
                      setState(() {
                        _xUnitPrefix = selectedPrefix;
                      });
                    }
                  },
                  child: Chip(
                    label: Text('$_xUnitPrefix$_xUnit'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Rounded border
                    ),
                  ),
                )
                : const SizedBox(width: 0),
          ],
        ),
        Row(
          children: [
            const SizedBox(width: 20),
            const Text("y:"),
            const SizedBox(width: 10),
            PopupButtonWithCheckboxList(
              items: List<String>.from(widget.y),
              itemsTitle:
                  widget.y.map((path) => getTitleFromSchema(path)).toList(),
              selectedItems: _selectedY,
              title:
                  _selectedY.length == 1
                      ? getTitleFromSchema(_selectedY[0])
                      : '${_selectedY.length} data',
              onValueChange: (List<String> newSelectedItems) {
                setState(() {
                  _selectedY = newSelectedItems;
                  _yUnitPrefix = widget.yShownUnitprefix ?? "";
                });
              },
            ),
            _yUnit != null
                ? GestureDetector(
                  onTapDown: (details) async {
                    final offset = details.globalPosition;
                    final selectedPrefix = await showMenu<String>(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        offset.dx,
                        offset.dy - 40,
                        MediaQuery.of(context).size.width - offset.dx - 40,
                        MediaQuery.of(context).size.height - offset.dy,
                      ),
                      items:
                          _unitPrefixes.map((String prefix) {
                            return PopupMenuItem<String>(
                              value: prefix,
                              child: Text('$prefix${_yUnit}'),
                            );
                          }).toList(),
                    );
                    if (selectedPrefix != null) {
                      setState(() {
                        _yUnitPrefix = selectedPrefix;
                      });
                    }
                  },
                  child: Chip(
                    label: Text('${_yUnitPrefix}${_yUnit}'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Rounded border
                    ),
                  ),
                )
                : const SizedBox(width: 0),
          ],
        ),
        _resetZoom,
        Column(children: _legends),
        Container(
          width:
              double
                  .infinity, // Ensure it takes up the full width of the parent
          height: 300, // Give it a fixed height (adjust as needed)
          child: LineChart(
            transformationConfig: FlTransformationConfig(
              scaleAxis: _scaleAxis,
              minScale: 1.0,
              maxScale: 25.0,
              panEnabled: true,
              scaleEnabled: true,
              transformationController: _transformationController,
            ),
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: getHorizontalVerticalLine,
                getDrawingVerticalLine: getVerticalVerticalLine,
              ),
              titlesData: const FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: _lineBarsData,
              minX: _minX,
              maxX: _maxX,
              minY: _minY,
              maxY: _maxY,
            ),
          ),
        ),
      ],
    );
  }
}
