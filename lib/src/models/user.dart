import 'package:hive/hive.dart';
import 'package:powerpulse/hive_helper/hive_types.dart';
import 'package:powerpulse/hive_helper/hive_adapters.dart';
import 'package:powerpulse/hive_helper/fields/user_fields.dart';


part 'user.g.dart';


@HiveType(typeId: HiveTypes.user, adapterName: HiveAdapters.user)
class User extends HiveObject{
	@HiveField(UserFields.username)
  final String username;
	@HiveField(UserFields.pass)
  final String pass;

  User({
    required this.username,
    required this.pass,
  });
}