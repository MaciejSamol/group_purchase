import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:group_purchase/services/database.dart';

class ListViewPage extends StatefulWidget {
  final String index;
  const ListViewPage({super.key, required this.index});

  @override
  State<ListViewPage> createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  DatabaseService databaseService = new DatabaseService();
  TextEditingController productTextEditingController =
      new TextEditingController();

  dynamic productSnapshot;

  Future initiateProductsLoad() async {
    await databaseService
        .getProducts(FirebaseAuth.instance.currentUser!.email, widget.index)
        .then((val) {
      if (!mounted) return;
      setState(() {
        productSnapshot = val;
      });
    });
  }

  Widget productsWidget() {
    initiateProductsLoad();
    return productSnapshot != null
        ? ListView.builder(
            itemCount: productSnapshot.docs.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ProductTile(
                name: productSnapshot.docs[index].data()['name']!,
                index: widget.index,
              );
            })
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(widget.index),
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
        child: SingleChildScrollView(child: productsWidget()
            // wywołanie
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
            addProduct(productTextEditingController.text.capitalize());
            setState(() {
              productTextEditingController = new TextEditingController();
            });
            // Kasowannie zawartości productTextEditingController
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
  final String name;
  final String index;
  const ProductTile({
    super.key,
    required this.name,
    required this.index,
  });

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  bool? _isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(children: [
        Column(
          children: [
            Checkbox(
              value: _isChecked,
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  _isChecked = value;
                });
              },
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: TextStyle(fontSize: 15),
            ),
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
            deleteProduct(widget.index, widget.name);
          },
        )
      ]),
    );
  }

  deleteProduct(String index, String name) {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .deleteProduct(FirebaseAuth.instance.currentUser!.email, index, name);
  }
}

extension MyExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
