library powerpulse.globals;

import 'package:powerpulse/src/models/user.dart';

String? token;
User? user;
const Map<String, double> prefixMultipliers = {
  'M': 1e6, // mega
  'k': 1e3, // kilo
  '': 1, //
  'c': 1e-2, // centi
  'm': 1e-3, // milli
  'µ': 1e-6, // micro
  'n': 1e-9, // nano
  'p': 1e-12, // pico
};
