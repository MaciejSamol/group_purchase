import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_purchase/gui/add_friend.dart';
import 'package:group_purchase/gui/friend_requests.dart';
import 'package:group_purchase/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFriendToListPage extends StatefulWidget {
  final String index;
  const AddFriendToListPage({super.key, required this.index});

  @override
  State<AddFriendToListPage> createState() => _AddFriendToListPageState();
}

class _AddFriendToListPageState extends State<AddFriendToListPage> {
  DatabaseService databaseService = new DatabaseService();

  dynamic addFriendToListSnapshot;

  Future initiateAddFriendToListLoad() async {
    await databaseService
        .getFriendList(FirebaseAuth.instance.currentUser!.email)
        .then((val) {
      if (!mounted) return;
      setState(() {
        addFriendToListSnapshot = val;
      });
    });
  }

  dynamic friendsAddedListSnapshot;

  Future initiateFriendsAddedListLoad() async {
    await databaseService.getUsersList(widget.index).then((val) {
      if (!mounted) return;
      setState(() {
        friendsAddedListSnapshot = val;
      });
    });
  }

  checkForUser(index) {
    for (String user in friendsAddedListSnapshot.data()['users']) {
      if (user == addFriendToListSnapshot.docs[index].reference.id.toString()) {
        return true;
      } else {
        continue;
      }
    }
  }

  Widget addFriendToList() {
    initiateAddFriendToListLoad();
    initiateFriendsAddedListLoad();
    return addFriendToListSnapshot != null
        ? ListView.builder(
            itemCount: addFriendToListSnapshot.docs.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              if (checkForUser(index) != true) {
                return AddFriendToListTile(
                  friendName:
                      addFriendToListSnapshot.docs[index].data()['friendName']!,
                  friendEmail: addFriendToListSnapshot.docs[index]
                      .data()['friendEmail']!,
                  index: widget.index,
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
      appBar: AppBar(
        title: Text("Udostępnij listę znajomym"),
        backgroundColor: Colors.green,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: addFriendToList(),
        ),
      ),
    );
  }
}

class AddFriendToListTile extends StatefulWidget {
  final String friendName;
  final String friendEmail;
  final String index;
  const AddFriendToListTile({
    super.key,
    required this.friendName,
    required this.friendEmail,
    required this.index,
  });

  @override
  State<AddFriendToListTile> createState() => _AddFriendToListTileState();
}

class _AddFriendToListTileState extends State<AddFriendToListTile> {
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
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green)),
          onPressed: () {
            addFriendToList();
            setState(() {});
            showDialog(
              context: context,
              builder: (BuildContext context) => _buildPopupDialogAdd(context),
            );
          },
          child: Container(
            child: Text(
              "Dodaj",
            ),
          ),
        ), // przycisk dodający znajomego do listy zakupowej // przycisk usuwający  znajomego z  listy zakupowej
      ]),
    );
  }

  addFriendToList() {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .addFriendToList(widget.index, [widget.friendEmail]);
  }

  Widget _buildPopupDialogAdd(BuildContext context) {
    return new AlertDialog(
      title: const Text('Dodano znajomego do listy zakupowej'),
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
