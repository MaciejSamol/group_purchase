import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../gui/login.dart';
import '../gui/logout.dart';

class Settings extends StatefulWidget {
  final Function(User?) onSignOut;
  const Settings({super.key, required this.onSignOut});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    widget.onSignOut(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 231, 229, 229),
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text('Ustawienia'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () {
              logout();
              Navigator.pop(context);
            },
            child: Container(
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Wyloguj'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}