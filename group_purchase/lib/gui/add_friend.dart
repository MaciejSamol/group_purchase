/* Strona na której można wyszukać użytkownika poprzez jego adres email. Po wyszukaniu wybranej osoby, użytkownik może wysłać zaproszenie do grona znajomych naciskając przycisk "dodaj" . */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_purchase/services/database.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  DatabaseService databaseService = new DatabaseService();
  TextEditingController searchTextEditingController =
      new TextEditingController();

  String name = '';
  String surname = '';

  Future _getDataFromDatabase() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        setState(() {
          name = '${documentSnapshot.get('name')}';
          surname = '${documentSnapshot.get('surname')}';
        });
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  bool friendExistance = false;
  Future _checkIfFriendExists() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('friends')
        .doc(searchTextEditingController.text)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      friendExistance = documentSnapshot.exists;
    });
  }

  dynamic searchSnapshot;

  initiateSearch() {
    _getDataFromDatabase();
    if (searchTextEditingController.text !=
        FirebaseAuth.instance.currentUser!.email) {
      databaseService
          .getUserByEmail(searchTextEditingController.text)
          .then((val) {
        setState(() {
          searchSnapshot = val;
        });
      });
    } else {
      searchSnapshot = null;
    }
  }

  Widget searchList() {
    return searchSnapshot != null && friendExistance != true
        ? ListView.builder(
            itemCount: searchSnapshot.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return SearchTile(
                friendName: searchSnapshot.docs[index].data()['name']!,
                friendSurname: searchSnapshot.docs[index].data()['surname']!,
                friendEmail: searchSnapshot.docs[index].data()['email']!,
                currentUserName: name,
                currentUserSurname: surname,
              );
            })
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 231, 229, 229),
      appBar: AppBar(
        title: Text("Dodaj znajomego"),
        backgroundColor: Colors.green,
      ), // Pasek górny
      body: Container(
        child: Column(
          children: [
            Container(
              color: Colors.green[300], //kolor paska wyszukiwania
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchTextEditingController,
                      decoration: InputDecoration(
                        hintText: 'wprowadź email',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _checkIfFriendExists();
                      initiateSearch();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          const Color(0xFF66BB6A),
                          const Color(0xFF2E7D32)
                        ]),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Image.asset('assets/images/search_white.png'),
                    ),
                  ),
                ],
              ),
            ),
            searchList()
          ],
        ),
      ),
    );
  }
}

class SearchTile extends StatefulWidget {
  final String friendName;
  final String friendSurname;
  final String friendEmail;
  final String currentUserName;
  final String currentUserSurname;
  const SearchTile(
      {super.key,
      required this.friendName,
      required this.friendEmail,
      required this.currentUserName,
      required this.friendSurname,
      required this.currentUserSurname});

  @override
  State<SearchTile> createState() => _SearchTileState();
}

bool existance = false;

class _SearchTileState extends State<SearchTile> {
  Future _checkIfExists() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.friendEmail)
        .collection('requests')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      existance = documentSnapshot.exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
      child: Card(
        elevation: 5,
        shadowColor: Colors.black,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(children: [
            IconButton(onPressed: () {}, icon: Icon(Icons.people)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friendName + ' ' + widget.friendSurname,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(widget.friendEmail),
              ],
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                _checkIfExists();
                if (existance == false) {
                  sendRequest(widget
                      .friendEmail); // funkcja odpowiedzialna za wysłanie friend requesta
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        _buildPopupDialog(context),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        _buildPopupDialogRepeat(context),
                  );
                }
              },
              child: const Text('Dodaj'),
            ),
          ]),
        ),
      ),
    );
  }

  sendRequest(String friendEmail) {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .sendFriendRequest(FirebaseAuth.instance.currentUser!.email,
            widget.currentUserName, widget.currentUserSurname, friendEmail);
  }

  Widget _buildPopupDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('Wysłano zaproszenie'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Zamknij'),
        ),
      ],
    );
  }

  Widget _buildPopupDialogRepeat(BuildContext context) {
    return new AlertDialog(
      title: const Text('Już wysłano zaproszenie'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Zamknij'),
        ),
      ],
    );
  }
}
