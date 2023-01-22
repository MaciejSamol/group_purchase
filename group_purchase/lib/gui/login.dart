import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_purchase/services/database.dart';

import 'home_page.dart';
import 'logout.dart';

class LoginPage extends StatefulWidget {
  final Function(User?) onSignIn;
  LoginPage({required this.onSignIn});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();

  String error = "";
  bool login = true;

  Future<void> loginUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _controllerEmail.text, password: _controllerPassword.text);
      print(userCredential.user);
      widget.onSignIn(userCredential.user);
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message!;
      });
    }
  }

  Future<void> createUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _controllerEmail.text, password: _controllerPassword.text);
      print(userCredential.user);

      // create a new document for the user with the uid
      await DatabaseService(uid: userCredential.user!.email).updateUserData(
          userCredential.user?.displayName,
          userCredential.user!.email,
          userCredential.user!.uid);

      widget.onSignIn(userCredential.user);
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(login ? 'Zaloguj się' : 'Zarejestruj się'),
      ), // Pasek górny
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          children: [
            TextFormField(
              controller: _controllerEmail,
              cursorColor: Colors.green,
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Colors.grey[700]),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.green,
                  ),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ), // Pole wprowadzania emaila
            TextFormField(
              controller: _controllerPassword,
              cursorColor: Colors.green,
              decoration: InputDecoration(
                labelText: "Hasło",
                labelStyle: TextStyle(color: Colors.grey[700]),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.green,
                  ),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.green,
                  ),
                ),
              ),
            ), // Pole wprowadzania hasła
            Text(error),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    login ? loginUser() : createUser();
                    if (login == true) {
                      Navigator.pop(context);
                    } else if (login == false) {
                      setState(() {
                        login = !login;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(login ? "Zaloguj się" : "Załóż konto"),
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  login = !login;
                });
              },
              child: Text(
                login ? "Stwórz konto" : " Zaloguj się",
                style: TextStyle(color: Colors.green),
              ),
            )
          ],
        ),
      ),
    );
  }
}
