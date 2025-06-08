import 'package:hive/hive.dart';
import 'package:powerpulse/src/models/user.dart';
import 'package:powerpulse/src/models/device.dart';

void registerAdapters() {
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(DeviceAdapter());
}
