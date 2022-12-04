import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';

class LogoutPage extends StatelessWidget {
  final Function(User?) onSignOut;
  LogoutPage({required this.onSignOut});

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    onSignOut(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil"),
        backgroundColor: Colors.green,
      ), // Pasek górny
      body: ElevatedButton(
        onPressed: () {
          logout();
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
        ),
        child: Text("Wyloguj się"),
      ),
    );
  }
}
