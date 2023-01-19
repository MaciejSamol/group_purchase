import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_purchase/gui/list_view.dart';
import 'package:group_purchase/gui/settings.dart';
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
  TextEditingController listNameTextEditingController =
      new TextEditingController();
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
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ListTile(
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
                  MaterialPageRoute(builder: (context) => LogoutPage()),
                );
              }
            }),
        title: const Text('Moje listy'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Settings(
                            onSignOut: (userCred) => onRefresh(userCred))));
              }),
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: listWidget(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) =>
                _buildPopupDialogNewList(context),
          );
        },
      ),
    );
  }

  addList(String? listName) {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .addNewList(listName);
  }

  Widget _buildPopupDialogNewList(BuildContext context) {
    return AlertDialog(
      title: const Text('Dodawanie listy'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: listNameTextEditingController,
            decoration: InputDecoration(
              hintText: 'wprowadź nazwę listy',
              border: InputBorder.none,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () {
            //Dodawanie produktu
            if (listNameTextEditingController.text != '') {
              addList(listNameTextEditingController.text.capitalize());
              setState(() {
                listNameTextEditingController = new TextEditingController();
              });
              // Kasowannie zawartości listNameTextEditingController
              Navigator.of(context).pop();
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) => _buildPopupDialog(context),
              );
            }
          },
          child: const Text('Dodaj'),
        ),
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

  Widget _buildPopupDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('Nie podano nazwy listy'),
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

class ListTile extends StatefulWidget {
  final String id;
  const ListTile({super.key, required this.id});

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
                    widget.id,
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
