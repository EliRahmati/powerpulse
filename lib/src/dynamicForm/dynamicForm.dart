import 'package:flutter/material.dart';
import 'package:powerpulse/src/dynamicForm/number_field.dart';
import 'package:powerpulse/src/dynamicForm/list_number_field.dart';
import 'package:powerpulse/src/dynamicForm/datetime_field.dart';
import 'package:powerpulse/src/dynamicForm/duration_field.dart';
import 'package:powerpulse/src/dynamicForm/richtext_field.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:intl/intl.dart';
import 'package:expressions/expressions.dart';
import 'dart:math';
import 'package:ml_linalg/linalg.dart';

num abs(num val) {
  return val.abs();
}

num norm(val) {
  if (val is List) {
    final vector = Vector.fromList(val as List<num>);
    return vector.norm();
  } else {
    return val.abs();
  }
}

num floor(num val) {
  return val.floor();
}

num ceil(num val) {
  return val.ceil();
}

num round(num val) {
  return val.round();
}

num toInt(num val) {
  return val.toInt();
}

num toDouble(num val) {
  return val.toDouble();
}

dynamic withList(func) {
  return (val) {
    if (val is List) {
      return val.map((e) => func(e) as num).toList();
    } else {
      return func(val);
    }
  };
}

var functions = {
  "acos": withList(acos), // Arc cosine in radians
  "asin": withList(asin), // Arc sine in radians
  "atan": withList(atan), // Arc tangent in radians
  "atan2": withList(atan2), // Arc tangent (variant of atan)
  "cos": withList(cos), // Cosine of the value (in radians)
  "exp": withList(exp), // Natural exponent (e^x)
  "log": withList(log), // Natural logarithm (ln(x))
  "max": withList(max), // Maximum of two numbers
  "min": withList(min), // Minimum of two numbers
  "pow": withList(pow), // x raised to the power of exponent
  "sin": withList(sin), // Sine of the value (in radians)
  "sqrt": withList(sqrt), // Square root of the value
  "tan": withList(tan), // Tangent of the value (in radians)
  "pi": withList(pi), // The PI constant
  "e": withList(e), // The base of the natural logarithm (e)
  "ln10": withList(ln10), // Natural logarithm of 10
  "ln2": withList(ln2), // Natural logarithm of 2
  "log10e": withList(log10e), // Base-10 logarithm of e
  "log2e": withList(log2e), // Base-2 logarithm of e
  "sqrt1_2": withList(sqrt1_2), // Square root of 1/2
  "sqrt2": withList(sqrt2), // Square root of 2
  "abs": norm, // abs
  "norm": norm, // abs
  "floor": withList(floor),
  "ceil": withList(ceil),
  "round": withList(round),
  "int": withList(toInt),
  "double": withList(toDouble),
};

class ArrayShape {
  final String baseType;
  final int depth;
  final List<int> arrayDepths;

  ArrayShape(
      {required this.baseType, required this.depth, required this.arrayDepths});

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

const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);

class DynamicForm extends StatefulWidget {
  final Map<String, dynamic> schema;
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onValueChange;

  const DynamicForm({
    super.key,
    required this.schema,
    required this.data,
    required this.onValueChange,
  });

  @override
  _DynamicFormState createState() => _DynamicFormState();
}

// Custom evaluator class for handling lists
class CustomExpressionEvaluator extends ExpressionEvaluator {
  @override
  dynamic eval(Expression expression, Map<String, dynamic> context) {
    var fulContext = {...context, ...functions};
    // Modify the eval method to support list element-wise multiplication

    if (expression.runtimeType == BinaryExpression) {
      var operator = (expression as BinaryExpression).operator;
      dynamic leftExpression = expression.left.toString();
      dynamic rightExpression = expression.right.toString();
      dynamic left;
      if (expression.left is Variable) {
        left = fulContext[leftExpression];
      } else {
        Expression ex = Expression.parse(expression.left.toString());
        var evaluator = CustomExpressionEvaluator();
        left = evaluator.eval(ex, fulContext);
      }

      dynamic right;
      if (expression.right is Variable) {
        right = fulContext[rightExpression];
      } else {
        Expression ex = Expression.parse(expression.right.toString());
        var evaluator = CustomExpressionEvaluator();
        right = evaluator.eval(ex, fulContext);
      }

      if (operator == '*') {
        if (left is num && right is num) {
          return left * right;
        } else if (left is num && right is List) {
          return right.map((e) => e * left as num).toList();
        } else if (right is num && left is List) {
          return left.map((e) => e * right as num).toList();
        } else if (left is List &&
            right is List &&
            left.length == right.length) {
          return List.generate(
              left.length, (index) => left[index] * right[index] as num);
        }
      } else if (operator == '/') {
        if (left is num && right is num) {
          return left / right as num;
        } else if (left is num && right is List) {
          return right.map((e) => e / left as num).toList();
        } else if (right is num && left is List) {
          return left.map((e) => e / right as num).toList();
        } else if (left is List &&
            right is List &&
            left.length == right.length) {
          return List.generate(
              left.length, (index) => left[index] / right[index] as num);
        }
      } else if (operator == '+') {
        if (left is num && right is num) {
          return left + right;
        } else if (left is num && right is List) {
          return right.map((e) => e + left as num).toList();
        } else if (right is num && left is List) {
          return left.map((e) => e + right as num).toList();
        } else if (left is List &&
            right is List &&
            left.length == right.length) {
          return List.generate(
              left.length, (index) => left[index] + right[index] as num);
        }
      } else if (operator == '-') {
        if (left is num && right is num) {
          return left - right;
        } else if (left is num && right is List) {
          return right.map((e) => e - left as num).toList();
        } else if (right is num && left is List) {
          return left.map((e) => e - right as num).toList();
        } else if (left is List &&
            right is List &&
            left.length == right.length) {
          return List.generate(
              left.length, (index) => left[index] - right[index] as num);
        }
      } else if (operator == '^') {
        if (left is num && right is num) {
          return pow(left, right);
        } else if (left is num && right is List) {
          return right.map((e) => pow(e, left)).toList();
        } else if (right is num && left is List) {
          return left.map((e) => pow(e, right)).toList();
        } else if (left is List &&
            right is List &&
            left.length == right.length) {
          return List.generate(
              left.length, (index) => pow(left[index], right[index]));
        }
      } else if (operator == '.') {
        if (fulContext.containsKey(operator)) {
          var left = fulContext[expression.toString().split('.')[0].trim()];
          var right = fulContext[operator];

          if (left is num && right is num) {
            return left * right;
          } else if (left is List &&
              right is List &&
              left.length == right.length) {
            final vector1 = Vector.fromList(left as List<num>);
            final vector2 = Vector.fromList(right as List<num>);
            final result = vector1.dot(vector2);
            return result as num;
          }
        }
      }
    }

    var result = super.eval(expression, fulContext);

    return result; // Return the result for other cases
  }
}

class _DynamicFormState extends State<DynamicForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (checkData()) {
      Future.delayed(Duration.zero, () async {
        initData();
      });
    }
  }

  bool checkData() {
    for (var entry in widget.schema['properties'].entries) {
      ArrayShape arrayShape = getShape(entry.value['type']);
      if (arrayShape.baseType == 'object') {
        if (arrayShape.depth == 0) {
          if (widget.data[entry.key] == null) {
            return true;
          }
          for (var objectEntry in entry.value['properties'].entries) {
            var schema = objectEntry.value;
            var key = objectEntry.key;
            ArrayShape arrayShape = getShape(schema['type']);
            if (widget.data[entry.key][key] == null) {
              return true;
            }
            if (arrayShape.baseType == 'float') {
              final unit = schema['unit'];
              if (unit != null &&
                  widget.data[entry.key]['${key}_shown_unitprefix'] == null) {
                return true;
              }
            }
          }
        } else if (arrayShape.depth == 1) {
          if (widget.data[entry.key] == null) {
            return true;
          }
          if (arrayShape.arrayDepths[0] > 0) {
            if (widget.data[entry.key].length != arrayShape.arrayDepths[0]) {
              return true;
            }
          }
          int n = arrayShape.arrayDepths[0] > 0
              ? arrayShape.arrayDepths[0]
              : widget.data[entry.key].length;
          for (int i = 0; i < n; i++) {
            if (get(widget.data[entry.key], i) == null) {
              return true;
            }
            for (var objectEntry in entry.value['properties'].entries) {
              var schema = objectEntry.value;
              var key = objectEntry.key;
              ArrayShape arrayShape = getShape(schema['type']);
              if (widget.data[entry.key][i][key] == null) {
                return true;
              }
              if (arrayShape.baseType == 'float') {
                final unit = schema['unit'];
                if (unit != null &&
                    widget.data[entry.key][i]['${key}_shown_unitprefix'] ==
                        null) {
                  return true;
                }
              }
            }
          }
        }
      } else {
        var schema = entry.value;
        var key = entry.key;
        if (widget.data[key] == null) {
          return true;
        }
        if (arrayShape.baseType == 'float') {
          final unit = schema['unit'];
          if (unit != null && widget.data['${key}_shown_unitprefix'] == null) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void setInitData(
      Map<String, dynamic> schema, Map<String, dynamic> data, String key) {
    ArrayShape arrayShape = getShape(schema['type']);
    if (data[key] == null) {
      data[key] = schema['default'];
    }
    if (arrayShape.baseType == 'float') {
      final unit = schema['unit'];
      if (unit != null && data['${key}_shown_unitprefix'] == null) {
        data['${key}_shown_unitprefix'] = "";
      }
    }
  }

  T? get<T>(List<T>? list, int index) {
    if (list != null && index >= 0 && index < list.length) {
      return list[index];
    }
    return null;
  }

  void initData() {
    widget.schema['properties'].entries.forEach((entry) {
      ArrayShape arrayShape = getShape(entry.value['type']);
      if (arrayShape.baseType == 'object') {
        if (arrayShape.depth == 0) {
          Map<String, dynamic> x = {};
          widget.data[entry.key] ??= x;
          entry.value['properties'].entries.forEach((objectEntry) {
            var schema = objectEntry.value;
            var key = objectEntry.key;
            ArrayShape arrayShape = getShape(schema['type']);
            if (widget.data[entry.key][key] == null) {
              widget.data[entry.key][key] = schema['default'];
            }
            if (arrayShape.baseType == 'float') {
              final unit = schema['unit'];
              if (unit != null &&
                  widget.data[entry.key]['${key}_shown_unitprefix'] == null) {
                widget.data[entry.key]['${key}_shown_unitprefix'] = "";
              }
            }
          });
        } else if (arrayShape.depth == 1) {
          int n = arrayShape.arrayDepths[0] > 0
              ? arrayShape.arrayDepths[0]
              : widget.data[entry.key].length;
          List<Map<String, dynamic>> emptyArray = [];
          for (int i = 0; i < arrayShape.arrayDepths[0]; i++) {
            Map<String, dynamic> x = {};
            emptyArray.add(x);
          }
          widget.data[entry.key] ??= emptyArray;

          List<Map<String, dynamic>> xArray = [];
          for (int i = 0; i < n; i++) {
            Map<String, dynamic> x = {};
            if (get(widget.data[entry.key], i) != null) {
              xArray.add(get(widget.data[entry.key], i));
            } else {
              xArray.add(x);
            }
          }
          widget.data[entry.key] = xArray;

          for (int i = 0; i < n; i++) {
            Map<String, dynamic> x = {};
            if (arrayShape.arrayDepths[0] < 0) {
              if (get(widget.data[entry.key], i) == null) {
                widget.data[entry.key].add(x);
              }
            }
            entry.value['properties'].entries.forEach((objectEntry) {
              var schema = objectEntry.value;
              var key = objectEntry.key;
              ArrayShape arrayShape = getShape(schema['type']);
              if (widget.data[entry.key][i][key] == null) {
                widget.data[entry.key][i][key] = schema['default'];
              }
              if (arrayShape.baseType == 'float') {
                final unit = schema['unit'];
                if (unit != null &&
                    widget.data[entry.key][i]['${key}_shown_unitprefix'] ==
                        null) {
                  widget.data[entry.key][i]['${key}_shown_unitprefix'] = "";
                }
              }
            });
          }
        }
      } else {
        var schema = entry.value;
        var key = entry.key;

        if (arrayShape.depth == 0) {
          if (widget.data[key] == null) {
            widget.data[key] = schema['default'];
          }
        } else if (arrayShape.depth == 1) {
          List<num> emptyArray = [];
          for (int i = 0; i < arrayShape.arrayDepths[0]; i++) {
            emptyArray.add(schema['default']);
          }
          widget.data[entry.key] ??= emptyArray;
          List<num> xArray = [];
          int n = arrayShape.arrayDepths[0] > 0
              ? arrayShape.arrayDepths[0]
              : widget.data[entry.key].length;
          for (int i = 0; i < n; i++) {
            if (get(widget.data[entry.key], i) != null) {
              xArray.add(get(widget.data[entry.key], i));
            } else {
              xArray.add(schema['default']);
            }
          }
          widget.data[entry.key] = xArray;
        }

        if (arrayShape.baseType == 'float') {
          final unit = schema['unit'];
          if (unit != null && widget.data['${key}_shown_unitprefix'] == null) {
            widget.data['${key}_shown_unitprefix'] = "";
          }
        }
      }
    });

    widget.schema['properties'].entries.forEach((entry) {
      final exp = entry.value['exp'];
      if (exp != null && exp is List && exp.isNotEmpty) {
        evaluateAndUpdate(exp, [entry.key]);
      }
    });

    widget.onValueChange(widget.data);
  }

  void evaluateAndUpdate(List<dynamic> expressions, List<String> done) {
    // Loop through the list of expressions
    for (var expression in expressions) {
      // Separate the left-hand side and right-hand side
      var parts = expression.split('=');

      // If the expression is valid (contains '=')
      if (parts.length == 2) {
        var lhs = parts[0].trim(); // Left-hand side (variable name)
        var rhs = parts[1].trim(); // Right-hand side (expression)

        // Parse the right-hand side expression
        Expression rhsExpression = Expression.parse(rhs);
        var evaluator = CustomExpressionEvaluator();
        var result = evaluator.eval(rhsExpression, widget.data);

        ArrayShape arrayShape =
            getShape(widget.schema['properties'][lhs]['type']);
        if (arrayShape.baseType == 'integer') {
          result = withList(toInt)(result);
        } else {
          result = withList(toDouble)(result);
        }

        // Use the ExpressionEvaluator to evaluate the right-hand side with the object context
        // Update the object with the result (set the variable value)
        if (!done.contains(lhs)) {
          final exp = widget.schema['properties'][lhs]['exp'];
          done.add(lhs);
          setState(() {
            widget.data[lhs] = result;
            if (exp != null && exp is List && exp.isNotEmpty) {
              evaluateAndUpdate(exp, done);
            }
          });
        }

        // if (arrayShape.depth == 0) {
        //   final result = evaluator.eval(rhsExpression, widget.data);
        //   // Update the object with the result (set the variable value)
        //   setState(() {
        //     widget.data[lhs] = result;
        //   });
        // } else if (arrayShape.depth == 1) {
        //   var result = widget.data[lhs];
        //   var count = result.length;
        //   for (var i = 0; i < count; i++) {
        //     result[i] = evaluator.eval(rhsExpression, widget.data);
        //   }
        //   // Update the object with the result (set the variable value)
        //   setState(() {
        //     widget.data[lhs] = result;
        //   });
        // }
      }
    }
  }

  String? textValidator(String? text, dynamic schema) {
    if (text == null) {
      return 'The value cannot be null.';
    }
    if (schema['minLength'] != null && text!.length < schema['minLength']) {
      return 'Min length is ${schema['minLength']} character(s)';
    }
    if (schema['maxLength'] != null && text!.length > schema['maxLength']) {
      return 'Max length is ${schema['maxLength']} character(s)';
    }
    return null;
  }

  String? numTextValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Invalid number';
    }
    try {
      num.parse(value);
    } catch (e) {
      return 'Invalid number';
    }
    return null;
  }

  String? numValidator(num value, dynamic schema) {
    if (schema['maximum'] == null && schema['minimum'] != null) {
      if (value < (schema['minimum'] as num)) {
        return 'Value out of range';
      }
    } else if (schema['maximum'] != null && schema['minimum'] == null) {
      if (value > (schema['maximum'] as num)) {
        return 'Value out of range';
      }
    } else if (schema['minimum'] != null && schema['maximum'] != null) {
      if (value < (schema['minimum'] as num) ||
          value > (schema['maximum'] as num)) {
        return 'Value out of range';
      }
    }
    return null;
  }

  String? dateTimeValidator(String value) {
    try {
      DateTime.parse(value);
      return null; // If no exception occurs, the input is valid
    } catch (e) {
      return 'Invalid date-time format.';
    }
  }

  String? durationValidator(num value) {
    if (value < 0) {
      return 'Invalid duration value. It should be a positive integer number.';
    }
    return null;
  }

  Widget _buildField(
      String key, Map<String, dynamic> schema, Map<String, dynamic> data) {
    ArrayShape arrayShape = getShape(schema['type']);

    switch (arrayShape.baseType) {
      case 'string':
        if (arrayShape.depth == 0) {
          return TextFormField(
            decoration: InputDecoration(labelText: schema['title']),
            onChanged: (newValue) {
              setState(() {
                data[key] = newValue;
                widget.onValueChange(widget.data);
              });
            },
            initialValue: data[key],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (text) {
              return textValidator(text, schema);
            },
          );
        } else {
          return SizedBox.shrink();
        }
      case 'richtext': // Handle rich text case here
        return MarkdownEditor(
          value: data[key],
          title: schema['title'],
          onValueChanged: (newValue) {
            setState(() {
              data[key] = newValue;
              widget.onValueChange(widget.data);
            });
          },
        );
      case 'integer':
        final exp = schema['exp'];
        if (arrayShape.depth == 0) {
          return NumberField(
            value: data[key],
            title: schema['title'],
            type: NumberFieldType.integer,
            onValueChange: (newValue) {
              setState(() {
                data[key] = newValue;
                if (exp != null && exp is List && exp.isNotEmpty) {
                  evaluateAndUpdate(exp, [key]);
                }
                widget.onValueChange(widget.data);
              });
            },
            min: schema['minimum']?.toInt(),
            max: schema['maximum']?.toInt(),
          );
        } else if (arrayShape.depth == 1) {
          if (arrayShape.arrayDepths[0] > 0) {
            return ListNumbers(
              values: data[key],
              title: schema['title'],
              type: NumberFieldType.integer,
              onValueChange: (newValue) {
                setState(() {
                  data[key] = newValue;
                  if (exp != null && exp is List && exp.isNotEmpty) {
                    evaluateAndUpdate(exp, [key]);
                  }
                  widget.onValueChange(widget.data);
                });
              },
              min: schema['minimum']?.toInt(),
              max: schema['maximum']?.toInt(),
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListNumbers(
                  values: data[key],
                  title: schema['title'],
                  type: NumberFieldType.integer,
                  onValueChange: (newValue) {
                    setState(() {
                      data[key] = newValue;
                      if (exp != null && exp is List && exp.isNotEmpty) {
                        evaluateAndUpdate(exp, [key]);
                      }
                      widget.onValueChange(widget.data);
                    });
                  },
                  min: schema['minimum']?.toInt(),
                  max: schema['maximum']?.toInt(),
                  withDeleteAction: true,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          data[key].add(schema['default']);
                          widget.onValueChange(widget.data);
                        });
                      },
                      child: Text('Add'),
                    ),
                  ],
                ),
              ],
            );
          }
        } else {
          return SizedBox.shrink();
        }
      case 'float':
        final unit = schema['unit'];
        final exp = schema['exp'];
        if (arrayShape.depth == 0) {
          return NumberField(
            value: data[key],
            title: schema['title'],
            unit: unit,
            type: NumberFieldType.float,
            unitPrefix: unit != null ? data['${key}_shown_unitprefix'] : null,
            onValueChange: (newValue) {
              setState(() {
                data[key] = newValue;
                if (exp != null && exp is List && exp.isNotEmpty) {
                  evaluateAndUpdate(exp, [key]);
                }
                widget.onValueChange(widget.data);
              });
            },
            onUnitPrefixChange: (newPrefix) {
              setState(() {
                data['${key}_shown_unitprefix'] = newPrefix;
                widget.onValueChange(widget.data);
              });
            },
            min: schema['minimum']?.toDouble(),
            max: schema['maximum']?.toDouble(),
          );
        } else if (arrayShape.depth == 1) {
          if (arrayShape.arrayDepths[0] > 0) {
            return ListNumbers(
              values: data[key],
              title: schema['title'],
              unit: unit,
              type: NumberFieldType.float,
              unitPrefix: unit != null ? data['${key}_shown_unitprefix'] : null,
              onValueChange: (newValue) {
                setState(() {
                  data[key] = newValue;
                  if (exp != null && exp is List && exp.isNotEmpty) {
                    evaluateAndUpdate(exp, [key]);
                  }
                  widget.onValueChange(widget.data);
                });
              },
              onUnitPrefixChange: (newPrefix) {
                setState(() {
                  data['${key}_shown_unitprefix'] = newPrefix;
                  widget.onValueChange(widget.data);
                });
              },
              min: schema['minimum']?.toDouble(),
              max: schema['maximum']?.toDouble(),
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListNumbers(
                  values: data[key],
                  title: schema['title'],
                  unit: unit,
                  type: NumberFieldType.float,
                  unitPrefix:
                      unit != null ? data['${key}_shown_unitprefix'] : null,
                  onValueChange: (newValue) {
                    setState(() {
                      data[key] = newValue;
                      if (exp != null && exp is List && exp.isNotEmpty) {
                        evaluateAndUpdate(exp, [key]);
                      }
                      widget.onValueChange(widget.data);
                    });
                  },
                  onUnitPrefixChange: (newPrefix) {
                    setState(() {
                      data['${key}_shown_unitprefix'] = newPrefix;
                      widget.onValueChange(widget.data);
                    });
                  },
                  min: schema['minimum']?.toDouble(),
                  max: schema['maximum']?.toDouble(),
                  withDeleteAction: true,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          data[key].add(schema['default']);
                          widget.onValueChange(widget.data);
                        });
                      },
                      child: Text('Add'),
                    ),
                  ],
                ),
              ],
            );
          }
        } else {
          return SizedBox.shrink();
        }
      case 'boolean':
        return Row(
          children: [
            Text(schema['title']),
            Checkbox(
              value: data[key] ?? false,
              onChanged: (bool? newValue) {
                setState(() {
                  data[key] = newValue;
                  widget.onValueChange(widget.data);
                });
              },
            ),
          ],
        );
      case 'date':
        return DateTimeField(
          value: data[key], // Initial value
          title: schema['title'], // Desired format
          type: DateTimeFieldType.date,
          onValueChange: (newDateTime) {
            setState(() {
              data[key] = newDateTime;
              widget.onValueChange(widget.data);
            });
          },
        );
      case 'duration':
        return DurationField(
          value: data[key], // 1 day, 1 hour, 0 minutes, 0 seconds
          title: schema['title'],
          onValueChange: (value) {
            // Handle value change (value will be in seconds)
            setState(() {
              data[key] = value;
              widget.onValueChange(widget.data);
            });
          },
        );
      case 'datetime':
        return DateTimeField(
          value: data[key], // Initial value
          title: schema['title'], // Desired format
          type: DateTimeFieldType.datetime,
          onValueChange: (newDateTime) {
            setState(() {
              data[key] = newDateTime;
              widget.onValueChange(widget.data);
            });
          },
        );
      case 'enum':
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: schema['title']),
          value: data[key],
          items: (schema['enum'] as List<dynamic>)
              .map((item) => DropdownMenuItem<String>(
                    value: item as String,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: (newValue) {
            setState(() {
              data[key] = newValue;
              widget.onValueChange(widget.data);
            });
          },
        );
      case 'object':
        if (arrayShape.depth == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(schema['title']),
              Row(
                children: schema['properties'].entries.map<Widget>((entry) {
                  return Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: _buildField(entry.key, entry.value, data[key])),
                  );
                }).toList(),
              ),
            ],
          );
        } else if (arrayShape.depth == 1) {
          if (arrayShape.arrayDepths[0] > 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(schema['title']),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    data[key].length,
                    (index) => Row(
                      children:
                          schema['properties'].entries.map<Widget>((entry) {
                        return Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: _buildField(
                                  entry.key, entry.value, data[key][index])),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(schema['title']),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    data[key].length,
                    (index) => Row(
                      children: [
                        ...schema['properties'].entries.map<Widget>((entry) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: _buildField(
                                  entry.key, entry.value, data[key][index]),
                            ),
                          );
                        }).toList(),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            data[key].removeAt(index);
                            widget.onValueChange(widget.data);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Map<String, dynamic> x = {};
                        schema['properties'].entries.forEach((objectEntry) {
                          var subSchema = objectEntry.value;
                          var subKey = objectEntry.key;
                          ArrayShape arrayShape = getShape(subSchema['type']);
                          x[subKey] = subSchema['default'];
                          if (arrayShape.baseType == 'float') {
                            final unit = subSchema['unit'];
                            if (unit != null) {
                              x['${subKey}_shown_unitprefix'] = "";
                            }
                          }
                        });
                        setState(() {
                          data[key].add(x);
                          widget.onValueChange(widget.data);
                        });
                      },
                      child: Text('Add'),
                    ),
                  ],
                ),
              ],
            );
          }
        } else {
          return SizedBox.shrink();
        }
      default:
        return SizedBox.shrink();
    }
  }

  Map<String, String?> doValidation() {
    final Map<String, String?> errors = {};

    for (var entry in widget.schema['properties'].entries) {
      var key = entry.key;
      var schema = entry.value;
      ArrayShape arrayShape = getShape(schema['type']);

      switch (arrayShape.baseType) {
        case 'string':
          var error = textValidator(widget.data[key], schema);
          if (error != null) {
            errors[key] = error;
          } else {
            errors.remove(key);
          }
        case 'richtext':
          if (widget.data[key] == null) {
            errors[key] = 'The value cannot be null.';
          } else {
            errors.remove(key);
          }
        case 'integer':
          if (widget.data[key] == null) {
            errors[key] = 'The value cannot be null.';
          } else {
            if (arrayShape.depth == 0) {
              var error = numValidator(widget.data[key], schema);
              if (error != null) {
                errors[key] = error;
              } else {
                errors.remove(key);
              }
            } else if (arrayShape.depth == 1) {
              if (widget.data[key] is List) {
                List<dynamic> list = widget.data[key];
                for (int index = 0; index < list.length; index++) {
                  var item = list[index];
                  var error = numValidator(item, schema);
                  if (error != null) {
                    errors[key] = error;
                    break;
                  } else {
                    errors.remove(key);
                  }
                }
              } else {
                errors[key] = 'The data should be a list of integer numbers.';
              }
            }
          }
        case 'float':
          if (widget.data[key] == null) {
            errors[key] = 'The value cannot be null.';
          } else {
            if (arrayShape.depth == 0) {
              var error = numValidator(widget.data[key], schema);
              if (error != null) {
                errors[key] = error;
              } else {
                errors.remove(key);
              }
            } else if (arrayShape.depth == 1) {
              if (widget.data[key] is List) {
                List<dynamic> list = widget.data[key];
                for (int index = 0; index < list.length; index++) {
                  var item = list[index];
                  var error = numValidator(item, schema);
                  if (error != null) {
                    errors[key] = error;
                    break;
                  } else {
                    errors.remove(key);
                  }
                }
              } else {
                errors[key] = 'The data should be a list of float numbers.';
              }
            }
          }
        case 'boolean':
          if (widget.data[key] == null) {
            errors[key] = 'The value cannot be null.';
          } else {
            errors.remove(key);
          }
        case 'date':
          if (widget.data[key] == null) {
            errors[key] = 'The value cannot be null.';
          } else {
            var error = dateTimeValidator(widget.data[key]);
            if (error != null) {
              errors[key] = error;
            } else {
              errors.remove(key);
            }
          }
        case 'duration':
          if (widget.data[key] == null) {
            errors[key] = 'The value cannot be null.';
          } else {
            var error = durationValidator(widget.data[key]);
            if (error != null) {
              errors[key] = error;
            } else {
              errors.remove(key);
            }
          }
        case 'datetime':
          if (widget.data[key] == null) {
            errors[key] = 'The value cannot be null.';
          } else {
            var error = dateTimeValidator(widget.data[key]);
            if (error != null) {
              errors[key] = error;
            } else {
              errors.remove(key);
            }
          }
        case 'enum':
          if (widget.data[key] == null) {
            errors[key] = 'The value cannot be null.';
          } else {
            errors.remove(key);
          }
        case 'object':
          if (widget.data[key] == null) {
            errors[key] = 'The value cannot be null.';
          } else {
            errors.remove(key);
          }
        default:
          throw Exception(
              'The validation for ${arrayShape.baseType} type must be implemented.');
      }
    }
    return errors;
  }

  @override
  Widget build(BuildContext context) {
    if (checkData()) {
      return Scaffold();
    }
    var errors = doValidation();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // Add this line to make the form scrollable
            child: Column(
              children: [
                Row(children: [
                  Text(
                    widget.schema['title'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ]),
                const SizedBox(height: 10),
                ...widget.schema['properties'].entries.map((entry) {
                  return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: _buildField(entry.key, entry.value, widget.data));
                }).toList(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: errors.isEmpty
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            // Process the data
                            print(widget.data);
                          }
                        }
                      : null,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
