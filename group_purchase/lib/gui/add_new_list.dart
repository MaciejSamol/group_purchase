import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:group_purchase/services/database.dart';

class AddNewListPage extends StatefulWidget {
  const AddNewListPage({super.key});

  @override
  State<AddNewListPage> createState() => _AddNewListPageState();
}

class _AddNewListPageState extends State<AddNewListPage> {
  DatabaseService databaseService = new DatabaseService();
  TextEditingController listNameTextEditingController =
      new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dodaj nową listę"),
        backgroundColor: Colors.green,
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: listNameTextEditingController,
                      decoration: InputDecoration(
                        hintText: 'wprowadź nazwę listy',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (listNameTextEditingController.text != '') {
                        addList(listNameTextEditingController.text);
                        Navigator.pop(context);
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              _buildPopupDialog(context),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text('Dodaj'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  addList(String? listName) {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .addNewList(listName);
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
