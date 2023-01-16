import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:group_purchase/services/database.dart';

class ListViewPage extends StatefulWidget {
  final String listName;
  final String index;
  const ListViewPage({super.key, required this.listName, required this.index});

  @override
  State<ListViewPage> createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  DatabaseService databaseService = new DatabaseService();
  TextEditingController productTextEditingController =
      new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(widget.listName),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                //Funkcja odpowiedzialna za kasowanie całej listy
                deleteList();
                Navigator.pop(context);
              }),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            // Wywołanie produktów
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () {
          //Funkcja odpowiedzialna za wyświetlenie okna dodawania produktu
          showDialog(
            context: context,
            builder: (BuildContext context) => _buildPopupDialog(context),
          );
        },
      ),
    );
  }

  deleteList() {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .deleteList(FirebaseAuth.instance.currentUser!.email, widget.index);
  }

  Widget _buildPopupDialog(BuildContext context) {
    int productNr = 1;
    return AlertDialog(
      title: const Text('Dodawanie produktu'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: productTextEditingController,
            decoration: InputDecoration(
              hintText: 'wprowadź nazwę produktu',
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
            addProduct(productTextEditingController.text);
            Navigator.of(context).pop();
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

  addProduct(String product) {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email).addProduct(
        FirebaseAuth.instance.currentUser!.email, widget.index, product);
  }
}

class ProductTile extends StatefulWidget {
  const ProductTile({super.key});

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Text(widget.friendName),
            //Wyświetlanie produktu w kafelku
          ],
        ),
        Spacer(),
        Column(
            //Tutaj ilość produktów lub checkbox czy kupione
            ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.delete_forever),
          color: Colors.green,
          onPressed: () {
            // funkcja odpowiedzialna za kasowanie przedmiotu
          },
        )
      ]),
    );
  }
}
