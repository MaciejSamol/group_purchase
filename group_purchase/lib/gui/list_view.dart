/* Strona wyświetlająca zawartość listy zakupowej użytkownika.
Na stronie tej znajduje się lista produktów. Przy każdym z produktów znajduje się przycisk odpowiedzialny za usunięcie produktu z listy oraz przycisk pozwalający na oznaczenie produktu jako produkt już zakupiony. */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_purchase/gui/add_friend_to_list.dart';
import 'package:group_purchase/gui/firends_added_to_list.dart';
import 'package:group_purchase/services/database.dart';

class ListViewPage extends StatefulWidget {
  final String index;
  final String listName;
  final String devicId;
  const ListViewPage(
      {super.key,
      required this.index,
      required this.listName,
      required this.devicId});

  @override
  State<ListViewPage> createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  DatabaseService databaseService = new DatabaseService();
  TextEditingController productTextEditingController =
      new TextEditingController();

  String userName = '';
  String userSurname = '';

  // Funkcja pobierająca imię i nazwisko użytkownika z bazy danych
  Future _getDataFromDatabase() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot.exists) {
          setState(() {
            userName = '${documentSnapshot.get('name')}';
            userSurname = '${documentSnapshot.get('surname')}';
          });
        } else {
          print('Document does not exist on the database');
        }
      });
    } else {
      print('User not logged');
    }
  }

  dynamic productSnapshot;

  //Funkcja inicjująca pobranie danych listy zakupowej z bazdy
  Future initiateProductsLoad() async {
    await databaseService.getProducts(widget.index).then((val) {
      if (!mounted) return;
      setState(() {
        productSnapshot = val;
      });
    });
  }

  dynamic productAnonSnapshot;

  Future initiateAnonProductsLoad() async {
    await databaseService.getProducts(widget.index).then((val) {
      if (!mounted) return;
      setState(() {
        productAnonSnapshot = val;
      });
    });
  }

  // Funkcja tworząca listę zawierającą poszczególne produkty w widoku karty.
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
                user: productSnapshot.docs[index].data()['addBy']!,
                index: widget.index,
                isChecked: productSnapshot.docs[index].data()['isChecked']!,
                devId: widget.devicId,
              );
            })
        : Container();
  }

  @override
  void initState() {
    _getDataFromDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 231, 229, 229),
      appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text(widget.listName),
          actions: checkForUser()),
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
            builder: (BuildContext context) =>
                _buildPopupDialog(context, userName, userSurname),
          );
        },
      ),
    );
  }

  // Sprawdzenie czy użytkownik jest zalogowany
  checkForUser() {
    if (FirebaseAuth.instance.currentUser != null) {
      return <Widget>[
        IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              //Funkcja odpowiedzialna za udostępnianie listy znajomym
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddFriendToListPage(
                            index: widget.index,
                          )));
            }),
        IconButton(
            icon: Icon(Icons.people),
            onPressed: () {
              //Funkcja odpowiedzialna za wyświetlanie listy członków listy zakupowej
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FriendsAddedToListPage(id: widget.index)));
            }),
        IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              //Funkcja odpowiedzialna za kasowanie całej listy
              deleteList();
              Navigator.pop(context);
            }),
      ];
    } else {
      return <Widget>[
        IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              //Funkcja odpowiedzialna za kasowanie całej listy
              deleteList();
              Navigator.pop(context);
            }),
      ];
    }
  }

  deleteList() {
    DatabaseService(uid: widget.index).deleteList(widget.index);
  }

  Widget _buildPopupDialog(
      BuildContext context, String userName, String userSurname) {
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
            if (FirebaseAuth.instance.currentUser != null) {
              addProduct(productTextEditingController.text.capitalize(),
                  userName, userSurname);
              addToCount();
            } else {
              addAnonProduct(productTextEditingController.text.capitalize(),
                  userName, userSurname);
              addToAnonCount();
            }
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
            setState(() {
              productTextEditingController = new TextEditingController();
            });
          },
          child: const Text('Zamknij'),
        ),
      ],
    );
  }

  addToCount() {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .addToCount(widget.index);
  }

  addToAnonCount() {
    DatabaseService(uid: widget.devicId).addToCount(widget.index);
  }

  addProduct(String product, String userName, String userSurname) {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .addProduct(widget.index, product, userName, userSurname);
  }

  addAnonProduct(String product, String userName, String userSurname) {
    DatabaseService(uid: widget.devicId)
        .addProduct(widget.index, product, userName, userSurname);
  }
}

// Klasa odpowiedzialna za wygląd karty produktu.
class ProductTile extends StatefulWidget {
  final String name;
  final String user;
  final String index;
  final bool isChecked;
  final String devId;
  const ProductTile({
    super.key,
    required this.name,
    required this.index,
    required this.user,
    required this.isChecked,
    required this.devId,
  });

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(children: [
        Column(
          children: [
            Checkbox(
              value: widget.isChecked,
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  if (FirebaseAuth.instance.currentUser != null) {
                    isCheckedUpdate(widget.index, widget.name, value);
                    if (value == true) {
                      addToBought(widget.index);
                    } else {
                      deleteFromBought(widget.index);
                    }
                  } else {
                    isCheckedUpdateAnon(
                        widget.devId, widget.index, widget.name, value);
                    if (value == true) {
                      addToBoughtAnon(widget.devId, widget.index);
                    } else {
                      deleteFromBoughtAnon(widget.devId, widget.index);
                    }
                  }
                });
              },
            ),
          ],
        ),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: checkForUser()
            //Wyświetlanie produktu w kafelku
            ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.delete_forever),
          color: Colors.green,
          onPressed: () {
            if (FirebaseAuth.instance.currentUser != null) {
              deleteProduct(widget.index, widget.name);
              deleteFromCount(widget.index);
              if (widget.isChecked == true) {
                deleteFromBought(widget.index);
              }
            } else {
              deleteProductAnon(widget.devId, widget.index, widget.name);
              deleteFromCountAnon(widget.devId, widget.index);
              if (widget.isChecked == true) {
                deleteFromBoughtAnon(widget.devId, widget.index);
              }
            }
          },
        )
      ]),
    );
  }

  deleteFromCount(String index) {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .deleteFromCount(index);
  }

  deleteFromCountAnon(String deviceId, String index) {
    DatabaseService(uid: deviceId).deleteFromCount(index);
  }

  addToBought(String index) {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .addToBought(index);
  }

  addToBoughtAnon(String deviceId, String index) {
    DatabaseService(uid: deviceId).addToBought(index);
  }

  deleteFromBought(String index) {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .deleteFromBought(index);
  }

  deleteFromBoughtAnon(String deviceId, String index) {
    DatabaseService(uid: deviceId).deleteFromBought(index);
  }

  checkForUser() {
    if (FirebaseAuth.instance.currentUser != null) {
      return [
        Text(
          widget.name,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Text(
          'Produkt dodany przez: ' + widget.user,
          style: TextStyle(fontSize: 12),
        )
      ];
    } else {
      return [
        Text(
          widget.name,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        )
      ];
    }
  }

  isCheckedUpdate(String index, String product, bool? value) {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .isCheckedUpdate(index, product, value);
  }

  isCheckedUpdateAnon(String devId, String index, String product, bool? value) {
    DatabaseService(uid: devId).isCheckedUpdate(index, product, value);
  }

  deleteProduct(String index, String name) {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .deleteProduct(index, name);
  }

  deleteProductAnon(String devId, String index, String name) {
    DatabaseService(uid: devId).deleteProduct(index, name);
  }
}

extension MyExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
