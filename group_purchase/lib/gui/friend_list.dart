import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_purchase/gui/add_friend.dart';
import 'package:group_purchase/gui/friend_requests.dart';
import 'package:group_purchase/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendListPage extends StatefulWidget {
  const FriendListPage({super.key});

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  DatabaseService databaseService = new DatabaseService();

  dynamic friendListSnapshot;

  Future initiateFriendListLoad() async {
    await databaseService
        .getFriendList(FirebaseAuth.instance.currentUser!.email)
        .then((val) {
      if (!mounted) return;
      setState(() {
        friendListSnapshot = val;
      });
    });
  }

  Widget friendList() {
    initiateFriendListLoad();
    return friendListSnapshot != null
        ? ListView.builder(
            itemCount: friendListSnapshot.docs.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return FriendListTile(
                friendName:
                    friendListSnapshot.docs[index].data()['friendName']!,
                friendSurname:
                    friendListSnapshot.docs[index].data()['friendSurname']!,
                friendEmail:
                    friendListSnapshot.docs[index].data()['friendEmail']!,
              );
            })
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 231, 229, 229),
      appBar: AppBar(
        title: Text("Lista znajomych"),
        backgroundColor: Colors.green,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AddFriendScreen())); // Funkcja odpowiadająca za dodanie znajomego poprzez wprowadzenie jego e-maila i wysłanie zaproszenia
              }),
          IconButton(
              icon: Icon(Icons.question_mark),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FriendRequestScreen())); // Funkcja odpowiadająca za akceptowanie otrzymanych zaproszeń
              }),
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: friendList(),
        ),
      ),
    );
  }
}

class FriendListTile extends StatefulWidget {
  final String friendName;
  final String friendSurname;
  final String friendEmail;
  const FriendListTile({
    super.key,
    required this.friendName,
    required this.friendEmail,
    required this.friendSurname,
  });

  @override
  State<FriendListTile> createState() => _FriendListTileState();
}

class _FriendListTileState extends State<FriendListTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
      child: Card(
        elevation: 5,
        shadowColor: Colors.black,
        child: Container(
          padding: EdgeInsets.all(10),
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
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.red)),
              onPressed: () {
                deleteFriend(widget
                    .friendEmail); //Funkcja odpowiedzialna za kasowanie znajomych
                setState(() {});
                showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        _buildPopupDialogDeleted(context));
              },
              child: Text("Usuń"),
            ),
          ]),
        ),
      ),
    );
  }

  deleteFriend(String friendEmail) {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .deleteFriendUser(
            FirebaseAuth.instance.currentUser!.email, friendEmail);
    DatabaseService(uid: friendEmail).deleteFriendFriend(
        FirebaseAuth.instance.currentUser!.email, friendEmail);
  }

  Widget _buildPopupDialogDeleted(BuildContext context) {
    return new AlertDialog(
      title: const Text('Usunięto znajomego z listy'),
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
