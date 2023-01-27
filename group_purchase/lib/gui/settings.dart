/* Strona odpowiedzialna za prezentację menu ustawień aplikacji.
W aktualnej wersji znajduje się tam wyłacznie przycisk odpowiedzialny za wylogowanie użytkownika.
W przyszłości pojawi się w tym widoku między innymi możliwość zmiany motywu aplikacji na ciemny
 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                elevation: 5,
                shadowColor: Colors.black,
                child: checkForUser(),
              ),
            ),
          ),
        ));
  }

  /* Funkcja sprawdzająca czy użytkownik jest zalogowany do aplikacji.
  Jeśli tak, wyświetli przycisk wyloguj, w innym wypadku widok ten będzie pusty. */
  checkForUser() {
    if (FirebaseAuth.instance.currentUser != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: Text('Wyloguj'),
          ),
        ],
      );
    } else {
      return Column();
    }
  }
}
