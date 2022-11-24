import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> loginAno() async {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();
    widget.onSignIn(userCredential.user);
  }

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
        title: Text("Login Page"),
      ), // Pasek górny
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              loginAno();
            },
            child: Text("Sign In Ano"),
          ), // Przycisk logowania anonimowego
          TextFormField(
            controller: _controllerEmail,
            decoration: InputDecoration(labelText: "Email"),
          ), // Pole wprowadzania emaila
          TextFormField(
            controller: _controllerPassword,
            decoration: InputDecoration(labelText: "Password"),
          ), // Pole wprowadzania hasła
          Text(error),
          ElevatedButton(
            onPressed: () {
              login ? loginUser() : createUser();
            },
            child: Text(login ? "Login into account" : "Create User"),
          ),
          OutlinedButton(
            onPressed: () {
              setState(() {
                login = !login;
              });
            },
            child: Text("Switch Login/Create account"),
          )
        ],
      ),
    );
  }
}
