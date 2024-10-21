import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:powerpulse/src/models/user.dart';
import 'package:collection/collection.dart';

class AddPersonForm extends StatefulWidget {
  const AddPersonForm({Key? key}) : super(key: key);

  @override
  _AddPersonFormState createState() => _AddPersonFormState();
}

class _AddPersonFormState extends State<AddPersonForm> {
  final _usernameController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _personFormKey = GlobalKey<FormState>();

  late final Box box;

  String? _usernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username can\'t be empty';
    }
    if (value.length < 6) {
      return 'Username should be at least 6 characters';
    }
    var foundUser =
        box.values.toList().firstWhereOrNull((user) => user.username == value);
    if (foundUser != null) {
      return 'This username is registered before';
    }
    return null;
  }

  String? _passValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password can\'t be empty';
    }
    if (value.length < 6) {
      return 'Password should be at least 6 characters';
    }
    return null;
  }

  String? _confirmPassValidator(String? value) {
    if (_passController.text != _confirmPassController.text) {
      return 'The password and confirmation password do not match';
    }
    return null;
  }

  // Add info to people box
  _addInfo() async {
    User newUser = User(
      username: _usernameController.text,
      pass: _passController.text,
    );

    box.add(newUser);
    print('New user was added.');
  }

  @override
  void initState() {
    super.initState();
    // Get reference to an already opened box
    box = Hive.box('users');
  }

  bool _obscured = true;

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            width: double.infinity,
            height: double.infinity,
            constraints: BoxConstraints(maxWidth: 400, maxHeight: 500),
            child: Card(
                child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Form(
                      key: _personFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            validator: _usernameValidator,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              filled: true,
                              prefixIcon: const Icon(Icons.account_circle),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(50)),
                            ),
                          ),
                          SizedBox(height: 24.0),
                          TextFormField(
                            controller: _passController,
                            validator: _passValidator,
                            obscureText: _obscured,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              filled: true,
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: GestureDetector(
                                  onTap: _toggleObscured,
                                  child: Icon(
                                    _obscured
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    size: 24,
                                  ),
                                ),
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(50)),
                            ),
                          ),
                          SizedBox(height: 24.0),
                          TextFormField(
                            controller: _confirmPassController,
                            validator: _confirmPassValidator,
                            obscureText: _obscured,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              filled: true,
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: GestureDetector(
                                  onTap: _toggleObscured,
                                  child: Icon(
                                    _obscured
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    size: 24,
                                  ),
                                ),
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(50)),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                            child: Container(
                              width: double.maxFinite,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_personFormKey.currentState!.validate()) {
                                    _addInfo();
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Text('Register'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )))));
  }
}
