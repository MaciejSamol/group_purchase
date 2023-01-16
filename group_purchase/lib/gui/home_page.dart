import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_purchase/gui/add_new_list.dart';
import 'package:group_purchase/gui/list_view.dart';
import 'package:group_purchase/services/database.dart';

import 'login.dart';
import 'logout.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DatabaseService databaseService = new DatabaseService();
  User? user;
  @override
  void initState() {
    super.initState();
    onRefresh(FirebaseAuth.instance.currentUser);
  }

  onRefresh(userCred) {
    setState(() {
      user = userCred;
    });
  }

  dynamic listSnapshot;

  Future initiateListLoad() async {
    await databaseService
        .getLists(FirebaseAuth.instance.currentUser!.email)
        .then((val) {
      if (!mounted) return;
      setState(() {
        listSnapshot = val;
      });
    });
  }

  Widget listWidget() {
    if (user != null) {
      initiateListLoad();
      return listSnapshot != null
          ? ListView.builder(
              itemCount: listSnapshot.docs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  listName: listSnapshot.docs[index].data()['listName']!,
                  id: listSnapshot.docs[index].reference.id.toString(),
                );
              })
          : Container();
    } else {
      return Container(); // W przyszłości listy dla użytkowników bez konta
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              if (user == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginPage(
                          onSignIn: (userCred) => onRefresh(userCred))),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LogoutPage(
                          onSignOut: (userCred) => onRefresh(userCred))),
                );
              }
            }),
        title: const Text('Moje listy'),
      ),
      body: Container(
        child: Column(
          children: [listWidget()],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNewListPage()),
          );
        },
      ),
    );
  }
}

class ListTile extends StatefulWidget {
  final String listName;
  final String id;
  const ListTile({super.key, required this.listName, required this.id});

  @override
  State<ListTile> createState() => _ListTileState();
}

class _ListTileState extends State<ListTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ListViewPage(
                    listName: widget.listName,
                    index: widget.id,
                  )),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(width: 2.0, color: Colors.grey)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 5,
                offset: Offset(0, 3),
              )
            ],
          ),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                children: [
                  Text(
                    widget.listName,
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Text(
                    "0/0",
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
