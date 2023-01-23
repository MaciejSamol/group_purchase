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
                friendEmail:
                    requestSnapshot.docs[index].data()['requestFromEmail']!,
                userName: name,
              );
            })
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  final String userName;
  const RequestTile(
      {super.key,
      required this.friendName,
      required this.friendEmail,
      required this.userName});

  @override
  State<RequestTile> createState() => _RequestTileState();
}

class _RequestTileState extends State<RequestTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.friendName,
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
                widget
                    .userName); // funkcja odpowiedzialna za akceptację friend requesta
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
    );
  }

  acceptRequest(String friendEmail, String friendName, String name) {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .acceptFriendRequestUser(
            FirebaseAuth.instance.currentUser!.email, friendEmail, friendName);
    DatabaseService(uid: friendEmail).acceptFriendRequestFriend(
        FirebaseAuth.instance.currentUser!.email, name, friendEmail);
  }

  deleteRequest(String friendEmail) {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .deleteFriendRequest(
            FirebaseAuth.instance.currentUser!.email, friendEmail);
  }

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
