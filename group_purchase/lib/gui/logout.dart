import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';
import 'friend_list.dart';

class LogoutPage extends StatefulWidget {
  final String devId;
  LogoutPage({super.key, required this.devId});

  @override
  State<LogoutPage> createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  String? name = '';
  String? email = '';
  String? id = '';
  String? userNameInput = '';

  Future _getDataFromDatabase() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        setState(() {
          email = '${documentSnapshot.get('email')}';
          id = '${documentSnapshot.get('id')}';
          name = '${documentSnapshot.get('name')}';
        });
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getDataFromDatabase();
  }

  Future _updateUserName() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .update({
      'name': userNameInput,
    });
  }

  _displayTextInpuitDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Uaktualnij swoje imię i nazwisko'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  userNameInput = value;
                });
              },
              decoration: const InputDecoration(hintText: 'Pisz tutaj'),
            ),
            actions: [
              ElevatedButton(
                // ignore: sort_child_properties_last
                child: const Text(
                  'Anuluj',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                style: ElevatedButton.styleFrom(
                  // ignore: deprecated_member_use
                  primary: Colors.red,
                ),
              ),
              ElevatedButton(
                // ignore: sort_child_properties_last
                child: const Text(
                  'Zatwierdź',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  _updateUserName();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MainPage(
                                deviceId: widget.devId,
                              )));
                },
                style: ElevatedButton.styleFrom(
                  // ignore: deprecated_member_use
                  primary: Colors.green,
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil"),
        backgroundColor: Colors.green,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.people),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FriendListPage()),
                );
              }),
        ],
      ), // Pasek górny
      body: Column(
        children: [
          const SizedBox(
            height: 10.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Imię i Nazwisko: ' + name!,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  _displayTextInpuitDialog(context);
                },
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            'Email: ' + email!,
            style: const TextStyle(
              fontSize: 15.0,
            ),
          ),
        ],
      ),
    );
  }
}
