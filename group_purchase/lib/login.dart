import 'package:flutter/material.dart';
import 'package:group_purchase/main.dart';

import 'home_page.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      backgroundColor: Colors.green,
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainPage()),
            );
          }),
      title: Text('Zarejestruj się'),
    ));
  }
}
