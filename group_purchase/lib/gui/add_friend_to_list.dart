/* Strona dodawania osób z listy znajomych użytkownika do listy zakupowej. Dodane osoby będą mogły dodawać, kasować oraz oznaczać produkty jako zakupione w tej konkretnej liście zakupowej. */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_purchase/services/database.dart';

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
                  friendSurname: addFriendToListSnapshot.docs[index]
                      .data()['friendSurname']!,
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
      backgroundColor: Color.fromARGB(255, 231, 229, 229),
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
  final String friendSurname;
  final String index;
  const AddFriendToListTile({
    super.key,
    required this.friendName,
    required this.friendEmail,
    required this.index,
    required this.friendSurname,
  });

  @override
  State<AddFriendToListTile> createState() => _AddFriendToListTileState();
}

class _AddFriendToListTileState extends State<AddFriendToListTile> {
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
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green)),
              onPressed: () {
                addFriendToList();
                setState(() {});
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildPopupDialogAdd(context),
                );
              },
              child: Container(
                child: Text(
                  "Dodaj",
                ),
              ),
            ), // przycisk dodający znajomego do listy zakupowej // przycisk usuwający  znajomego z  listy zakupowej
          ]),
        ),
      ),
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
