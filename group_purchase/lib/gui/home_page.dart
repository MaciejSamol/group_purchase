import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final Function(User?) onSignOut;
  HomePage({required this.onSignOut});

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    onSignOut(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Strona główna"),
        backgroundColor: Colors.green,
      ), // Pasek górny
      body: ElevatedButton(
        onPressed: () {
          logout();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
        ),
        child: Text("Wyloguj się"),
      ),
    );
  }
}
