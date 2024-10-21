import 'package:flutter/material.dart';
import 'package:powerpulse/src/models/user.dart';
import 'package:powerpulse/src/screens/update_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:powerpulse/src/screens/register.dart';

class InfoScreen extends StatefulWidget {
  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  late final Box contactBox;

  // Delete info from people box
  _deleteInfo(int index) {
    contactBox.deleteAt(index);

    print('Item deleted from box at index: $index');
  }

  @override
  void initState() {
    super.initState();
    // Get reference to an already opened box
    contactBox = Hive.box('users');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddScreen(),
          ),
        ),
        child: Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: contactBox.listenable(),
        builder: (context, Box box, widget) {
          if (box.isEmpty) {
            return Center(
              child: Text('No user is registered ...'),
            );
          } else {
            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                var currentBox = box;
                User userData = currentBox.getAt(index)!;

                return InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UpdateScreen(
                        index: index,
                        user: userData,
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text(userData.username),
                    // subtitle: Text('${userData.key}'),
                    // trailing: IconButton(
                    //   onPressed: () => _deleteInfo(index),
                    //   icon: Icon(
                    //     Icons.delete,
                    //     color: Colors.red,
                    //   ),
                    // ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
