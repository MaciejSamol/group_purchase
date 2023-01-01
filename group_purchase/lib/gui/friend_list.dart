import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_purchase/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendListPage extends StatefulWidget {
  const FriendListPage({super.key});

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  String? name = '';
  String? email = '';

  Future _getDataFromDatabase() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        setState(() {
          email = '${documentSnapshot.get('email')}';
          name = '${documentSnapshot.get('name')}';
        });
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista Znajomych"),
        backgroundColor: Colors.green,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // Funkcja odpowiadająca za dodanie znajomego poprzez wprowadzenie jego e-maila i wysłanie zaproszenia
              }),
        ],
      ),
      body: Column(),
    );
  }
}
