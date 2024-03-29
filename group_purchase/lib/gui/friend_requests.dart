/* Strona zawierająca wszystkie otrzymane zaproszenia do grona znajomych. Znajdujący się na niej użytkownik może zaakceptować bądź odrzucić otrzymane zaproszenie. */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_purchase/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  DatabaseService databaseService = new DatabaseService();

  String name = '';
  String surname = '';

  Future _getDataFromDatabase() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        if (!mounted) return;
        setState(() {
          name = '${documentSnapshot.get('name')}';
          surname = '${documentSnapshot.get('surname')}';
        });
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  dynamic requestSnapshot;

  Future initiateRequestLoad() async {
    await databaseService
        .getFriendRequests(FirebaseAuth.instance.currentUser!.email)
        .then((val) {
      if (!mounted) return;
      setState(() {
        requestSnapshot = val;
      });
    });
  }

  Widget requestList() {
    initiateRequestLoad();
    _getDataFromDatabase();
    return requestSnapshot != null
        ? ListView.builder(
            itemCount: requestSnapshot.docs.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return RequestTile(
                friendName:
                    requestSnapshot.docs[index].data()['requestFromName']!,
                friendSurname:
                    requestSnapshot.docs[index].data()['requestFromSurname']!,
                friendEmail:
                    requestSnapshot.docs[index].data()['requestFromEmail']!,
                userName: name,
                userSurname: surname,
              );
            })
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 231, 229, 229),
      appBar: AppBar(
        title: Text("Otrzymane zaproszenia"),
        backgroundColor: Colors.green,
      ), // Pasek górny
      body: Container(
        child: SingleChildScrollView(
          child: requestList(),
        ),
      ),
    );
  }
}

class RequestTile extends StatefulWidget {
  final String friendName;
  final String friendEmail;
  final String friendSurname;
  final String userName;
  final String userSurname;
  const RequestTile(
      {super.key,
      required this.friendName,
      required this.friendEmail,
      required this.userName,
      required this.friendSurname,
      required this.userSurname});

  @override
  State<RequestTile> createState() => _RequestTileState();
}

class _RequestTileState extends State<RequestTile> {
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
                  style: const TextStyle(
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
                acceptRequest(
                    widget.friendEmail,
                    widget.friendName,
                    widget.userName,
                    widget.friendSurname,
                    widget
                        .userSurname); // funkcja odpowiedzialna za akceptację friend requesta
                deleteRequest(widget.friendEmail);
                setState(() {});
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildPopupDialogAccepted(context),
                );

                Navigator.of(context).pop();
              },
              child: const Text('Akceptuj'),
            ),
            SizedBox(
              width: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                deleteRequest(widget
                    .friendEmail); // funkcja odpowiedzialna za odrzucenie friend requesta
                setState(() {});
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildPopupDialogDeleted(context),
                );

                Navigator.of(context).pop();
              },
              child: const Text('Odrzuć'),
            ),
          ]),
        ),
      ),
    );
  }

  acceptRequest(String friendEmail, String friendName, String name,
      String friendSurname, String surname) {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .acceptFriendRequestUser(FirebaseAuth.instance.currentUser!.email,
            friendEmail, friendName, friendSurname);
    DatabaseService(uid: friendEmail).acceptFriendRequestFriend(
        FirebaseAuth.instance.currentUser!.email, name, friendEmail, surname);
  }

  deleteRequest(String friendEmail) {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .deleteFriendRequest(
            FirebaseAuth.instance.currentUser!.email, friendEmail);
  }

  // Dialog wyskakujący po anulowaniu zaproszenia
  Widget _buildPopupDialogDeleted(BuildContext context) {
    return new AlertDialog(
      title: const Text('Usunięto zaproszenie'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Zamknij'),
        ),
      ],
    );
  }

  // Dialog pojawiający się po akceptacji zaproszenia
  Widget _buildPopupDialogAccepted(BuildContext context) {
    return new AlertDialog(
      title: const Text('Zaakceptowano zaproszenie'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Zamknij'),
        ),
      ],
    );
  }
}
