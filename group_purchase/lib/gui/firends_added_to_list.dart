/* Strona prezentująca listę osób dodanych do listy zakupowej. Osoby z tej listy mogą dodawać, kasować oraz oznaczać produkty jako zakupione.*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/database.dart';

class FriendsAddedToListPage extends StatefulWidget {
  final String id;
  const FriendsAddedToListPage({super.key, required this.id});

  @override
  State<FriendsAddedToListPage> createState() => _FriendsAddedToListPageState();
}

class _FriendsAddedToListPageState extends State<FriendsAddedToListPage> {
  DatabaseService databaseService = new DatabaseService();

  dynamic friendsAddedListSnapshot;

  Future initiateFriendsAddedListLoad() async {
    await databaseService.getUsersList(widget.id).then((val) {
      if (!mounted) return;
      setState(() {
        friendsAddedListSnapshot = val;
      });
    });
  }

  Widget friendsAddedList() {
    initiateFriendsAddedListLoad();
    return friendsAddedListSnapshot != null
        ? ListView.builder(
            itemCount: friendsAddedListSnapshot.data()['users'].length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              if (FirebaseAuth.instance.currentUser!.email !=
                  friendsAddedListSnapshot.data()['users']![index]) {
                return FriendsAddedListTile(
                  friendEmail: friendsAddedListSnapshot.data()['users']![index],
                  id: widget.id,
                );
              } else {
                return Container();
              }
            })
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 231, 229, 229),
      appBar: AppBar(
        title: Text("Lista dodanych osób"),
        backgroundColor: Colors.green,
      ),
      body: Container(
        child: SingleChildScrollView(child: friendsAddedList()),
      ),
    );
  }
}

class FriendsAddedListTile extends StatefulWidget {
  final String friendEmail;
  final String id;
  const FriendsAddedListTile({
    super.key,
    required this.friendEmail,
    required this.id,
  });

  @override
  State<FriendsAddedListTile> createState() => _FriendListTileState();
}

class _FriendListTileState extends State<FriendsAddedListTile> {
  String friendName = '';
  String friendSurname = '';

  Future _getDataFromDatabase() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.friendEmail)
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot.exists) {
          if (!mounted) return;
          setState(() {
            friendName = '${documentSnapshot.get('name')}';
            friendSurname = '${documentSnapshot.get('surname')}';
          });
        } else {
          print('Document does not exist on the database');
        }
      });
    } else {
      print('User not logged');
    }
  }

  createWidget() {
    _getDataFromDatabase();
    return [
      Text(
        friendName + ' ' + friendSurname,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(widget.friendEmail),
    ];
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
                children: createWidget()),
            Spacer(),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.red)),
              onPressed: () {
                removeFriendFromList();
                setState(() {});
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildPopupDialogDeleted(context),
                ); // Funkcja odpowiedzialna za usunięcie znajomego z listy zakupowej
              },
              child: Text("Usuń"),
            ),
          ]),
        ),
      ),
    );
  }

  removeFriendFromList() {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .deleteFriendFromList(widget.id, [widget.friendEmail]);
  }

  Widget _buildPopupDialogDeleted(BuildContext context) {
    return new AlertDialog(
      title: const Text('Usunięto znajomego z listy zakupowej'),
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
