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
        child: Column(
          children: [requestList()],
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
            Text(widget.friendName),
            Text(widget.friendEmail),
          ],
        ),
        Spacer(),
        GestureDetector(
          onTap: () {
            acceptRequest(
                widget.friendEmail,
                widget.friendName,
                widget
                    .userName); // funkcja odpowiedzialna za akceptację friend requesta
            deleteRequest(widget.friendEmail);
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text("Akceptuj"),
          ),
        ),
        Spacer(),
        GestureDetector(
          onTap: () {
            deleteRequest(widget
                .friendEmail); // funkcja odpowiedzialna za odrzucenie friend requesta
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text("Odrzuć"),
          ),
        )
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
}
