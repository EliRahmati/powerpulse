import 'package:hive/hive.dart';
import 'package:powerpulse/src/models/user.dart';

void registerAdapters() {
	Hive.registerAdapter(UserAdapter());
}
