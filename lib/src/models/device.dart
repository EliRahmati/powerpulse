import 'package:hive/hive.dart';
import 'package:powerpulse/hive_helper/hive_types.dart';
import 'package:powerpulse/hive_helper/hive_adapters.dart';
import 'package:powerpulse/hive_helper/fields/device_fields.dart';

part 'device.g.dart';

@HiveType(typeId: HiveTypes.device, adapterName: HiveAdapters.device)
class Device extends HiveObject {
  @HiveField(DeviceFields.iPAddress)
  final String iPAddress;
  @HiveField(DeviceFields.macAddress)
  final String? macAddress;
  @HiveField(DeviceFields.deviceName)
  final String deviceName;

  Device({
    required this.iPAddress,
    required this.macAddress,
    required this.deviceName,
  });
}
