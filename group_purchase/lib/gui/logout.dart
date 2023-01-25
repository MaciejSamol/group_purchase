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
  String? surname = '';
  String? email = '';
  String? id = '';
  String? userNameInput = '';
  String userSurnameInput = '';

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
          surname = '${documentSnapshot.get('surname')}';
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

  Future _updateUserSurname() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .update({
      'surname': userSurnameInput,
    });
  }

  _displayTextInpuitDialogSurname(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Uaktualnij swoje imię i nazwisko'),
            content: Wrap(
              children: [
                Column(
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          userNameInput = value;
                        });
                      },
                      decoration: const InputDecoration(hintText: 'Imię'),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          userSurnameInput = value;
                        });
                      },
                      decoration: const InputDecoration(hintText: 'Nazwisko'),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                // ignore: sort_child_properties_last
                child: const Text(
                  'Zatwierdź',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  _updateUserName();
                  _updateUserSurname();
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
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 231, 229, 229),
      appBar: AppBar(
        title: Text("Profil"),
        backgroundColor: Colors.green,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _displayTextInpuitDialogSurname(context);
            },
            icon: const Icon(Icons.edit),
          ),
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              CircleAvatar(
                radius: 95,
                backgroundColor: Colors.green[800],
                child: CircleAvatar(
                  radius: 92,
                  backgroundImage: AssetImage(
                    'assets/images/profile.png',
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Imię: ' + name!,
                style: const TextStyle(
                  fontSize: 20.0,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Nazwisko: ' + surname!,
                style: const TextStyle(
                  fontSize: 20.0,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: Text(
                  'Email: ' + email!,
                  style: const TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
