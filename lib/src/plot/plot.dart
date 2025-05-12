import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Plot extends StatefulWidget {
  final String title;
  final List<String> x;
  final List<String> y;
  final Map<String, dynamic> schema;
  final Map<String, dynamic> data;

  const Plot({
    super.key,
    required this.title,
    required this.x,
    required this.y,
    required this.schema,
    required this.data,
  });

  @override
  _PlotState createState() => _PlotState();
}

class _PlotState extends State<Plot> {
  String? _selectedX; // Store the selected X value
  String? _selectedY; // Store the selected Y value
  final List<FlSpot> _spots = List.from([]);

  @override
  void initState() {
    super.initState();

    // Set default values if available
    if (widget.x.isNotEmpty) {
      _selectedX = widget.x.first;
    }
    if (widget.y.isNotEmpty) {
      _selectedY = widget.y.first;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getTitleFromSchema(key) {
    return widget.schema['properties'][key]['title'];
  }

  void setData() {
    var x = widget.data[_selectedX] ?? [];
    var y = widget.data[_selectedY] ?? [];
    int n = x.length < y.length ? x.length : y.length;
    _spots.clear();
    for (int i = 0; i < n; i++) {
      _spots.add(FlSpot(x[i].toDouble(), y[i].toDouble()));
    }
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
            DropdownButton<String>(
              value: _selectedX,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedX = newValue;
                });
              },
              items:
                  widget.x.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(getTitleFromSchema(value)),
                    );
                  }).toList(),
            ),
            const SizedBox(width: 20),
            const Text("y:"),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: _selectedY,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedY = newValue;
                });
              },
              items:
                  widget.y.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(getTitleFromSchema(value)),
                    );
                  }).toList(),
            ),
          ],
        ),
        Container(
          width:
              double
                  .infinity, // Ensure it takes up the full width of the parent
          height: 300, // Give it a fixed height (adjust as needed)
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: const FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: _spots,
                  isCurved: false,
                  barWidth: 3,
                  belowBarData: BarAreaData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
