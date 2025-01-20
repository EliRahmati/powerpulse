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

  // Split the array part based on "[]" and check the lengths at each depth
  List<int> arrayDepths = [];
  int depth = 0;
  while (arrayPart.contains('[]')) {
    depth++;
    int startIndex = arrayPart.indexOf('[]');
    arrayPart = arrayPart.substring(startIndex + 2); // Move to the next part
    arrayDepths.add(arrayPart.isEmpty
        ? -1
        : int.tryParse(arrayPart) ?? -1); // If empty, use -1
  }

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

  Widget _buildField(String key, dynamic value) {
    ArrayShape arrayShape = getShape(value['type']);

    switch (arrayShape.baseType) {
      case 'string':
        if (arrayShape.depth == 0) {
          return TextFormField(
            decoration: InputDecoration(labelText: value['title']),
            onChanged: (text) => widget.data[key] = text,
            initialValue: widget.data[key],
            validator: (text) {
              if (value['maxLength'] != null &&
                  text!.length > value['maxLength']) {
                return 'Max length is ${value['maxLength']} characters';
              }
              return null;
            },
          );
        } else {
          return SizedBox.shrink();
        }
      case 'richtext': // Handle rich text case here
        return MarkdownEditor(
          value: widget.data[key],
          title: value['title'],
          onValueChanged: (newValue) {
            setState(() {
              widget.data[key] = newValue;
              widget.onValueChange(widget.data);
            });
          },
        );
      case 'integer':
        final exp = value['exp'];
        if (arrayShape.depth == 0) {
          return NumberField(
            value: widget.data[key],
            title: value['title'],
            type: NumberFieldType.integer,
            onValueChange: (newValue) {
              setState(() {
                widget.data[key] = newValue;
                if (exp != null && exp is List && exp.isNotEmpty) {
                  evaluateAndUpdate(exp, [key]);
                }
                widget.onValueChange(widget.data);
              });
            },
            min: value['minimum']?.toInt(),
            max: value['maximum']?.toInt(),
          );
        } else if (arrayShape.depth == 1) {
          return ListNumbers(
            values: widget.data[key],
            title: value['title'],
            type: NumberFieldType.integer,
            onValueChange: (newValue) {
              setState(() {
                widget.data[key] = newValue;
                if (exp != null && exp is List && exp.isNotEmpty) {
                  evaluateAndUpdate(exp, [key]);
                }
                widget.onValueChange(widget.data);
              });
            },
            min: value['minimum']?.toInt(),
            max: value['maximum']?.toInt(),
          );
        } else {
          return SizedBox.shrink();
        }
      case 'float':
        final unit = value['unit'] ?? '';
        final exp = value['exp'];
        if (arrayShape.depth == 0) {
          return NumberField(
            value: widget.data[key],
            title: value['title'],
            unit: unit,
            type: NumberFieldType.float,
            unitPrefix:
                unit != null ? widget.data['${key}_shown_unitprefix'] : null,
            onValueChange: (newValue) {
              setState(() {
                widget.data[key] = newValue;
                if (exp != null && exp is List && exp.isNotEmpty) {
                  evaluateAndUpdate(exp, [key]);
                }
                widget.onValueChange(widget.data);
              });
            },
            onUnitPrefixChange: (newPrefix) {
              setState(() {
                widget.data['${key}_shown_unitprefix'] = newPrefix;
              });
            },
            min: value['minimum']?.toDouble(),
            max: value['maximum']?.toDouble(),
          );
        } else if (arrayShape.depth == 1) {
          return ListNumbers(
            values: widget.data[key],
            title: value['title'],
            unit: unit,
            type: NumberFieldType.float,
            unitPrefix:
                unit != null ? widget.data['${key}_shown_unitprefix'] : null,
            onValueChange: (newValue) {
              setState(() {
                widget.data[key] = newValue;
                if (exp != null && exp is List && exp.isNotEmpty) {
                  evaluateAndUpdate(exp, [key]);
                }
                widget.onValueChange(widget.data);
              });
            },
            onUnitPrefixChange: (newPrefix) {
              setState(() {
                widget.data['${key}_shown_unitprefix'] = newPrefix;
              });
            },
            min: value['minimum']?.toDouble(),
            max: value['maximum']?.toDouble(),
          );
        } else {
          return SizedBox.shrink();
        }
      case 'boolean':
        return Row(
          children: [
            Text(value['title']),
            Checkbox(
              value: widget.data[key] ?? false,
              onChanged: (bool? newValue) {
                setState(() {
                  widget.data[key] = newValue;
                  widget.onValueChange(widget.data);
                });
              },
            ),
          ],
        );
      case 'date':
        return DateTimeField(
          value: widget.data[key], // Initial value
          title: value['title'], // Desired format
          type: DateTimeFieldType.date,
          onValueChange: (newDateTime) {
            setState(() {
              widget.data[key] = newDateTime;
              widget.onValueChange(widget.data);
            });
          },
        );
      case 'duration':
        return DurationField(
          value: widget.data[key], // 1 day, 1 hour, 0 minutes, 0 seconds
          title: value['title'],
          onValueChange: (value) {
            // Handle value change (value will be in seconds)
            setState(() {
              widget.data[key] = value;
              widget.onValueChange(widget.data);
            });
          },
        );
      case 'datetime':
        return DateTimeField(
          value: widget.data[key], // Initial value
          title: value['title'], // Desired format
          type: DateTimeFieldType.datetime,
          onValueChange: (newDateTime) {
            setState(() {
              widget.data[key] = newDateTime;
              widget.onValueChange(widget.data);
            });
          },
        );
      case 'enum':
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: value['title']),
          value: widget.data[key],
          items: (value['enum'] as List<dynamic>)
              .map((item) => DropdownMenuItem<String>(
                    value: item as String,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: (newValue) {
            setState(() {
              widget.data[key] = newValue;
              widget.onValueChange(widget.data);
            });
          },
        );
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      child: _buildField(entry.key, entry.value));
                }).toList(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process the data
                      print(widget.data);
                    }
                  },
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
