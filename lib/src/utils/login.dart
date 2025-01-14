import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:powerpulse/src/models/user.dart';
import 'package:powerpulse/src/screens/register.dart';
import 'package:collection/collection.dart';
import 'package:powerpulse/src/globals.dart' as globals;

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passController = TextEditingController();
  final _personFormKey = GlobalKey<FormState>();

  late final Box box;

  String? _usernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username can\'t be empty';
    }
    return null;
  }

  String? _passValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password can\'t be empty';
    }
    return null;
  }

  User? _findUser(String username, String pass) {
    User? foundUser = box.values
        .toList()
        .firstWhereOrNull((user) => user.username == username);
    if (foundUser == null) {
      return null;
    }
    if (foundUser.pass != pass) {
      return null;
    }
    return foundUser;
  }

  // Add info to people box
  _login() async {
    String username = _usernameController.text;
    String pass = _passController.text;

    var user = _findUser(username, pass);
    if (user != null) {
      globals.user = user;
    } else {
      globals.user = null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Get reference to the users box
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
                            onFieldSubmitted: (String value) {
                              if (_personFormKey.currentState!.validate()) {
                                _login();
                                // Navigator.of(context).pop();
                                Navigator.restorablePushNamed(
                                  context,
                                  '/',
                                );
                              }
                            },
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
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 10, 0),
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
                              onFieldSubmitted: (String value) {
                                if (_personFormKey.currentState!.validate()) {
                                  _login();
                                  // Navigator.of(context).pop();
                                  Navigator.restorablePushNamed(
                                    context,
                                    '/',
                                  );
                                }
                              }),
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
                                    _login();
                                    // Navigator.of(context).pop();
                                    Navigator.restorablePushNamed(
                                      context,
                                      '/',
                                    );
                                  }
                                },
                                child: Text('Login'),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                            child: Container(
                              width: double.maxFinite,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AddScreen(),
                                  ),
                                ),
                                child: Text('Register'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )))));
  }
}
