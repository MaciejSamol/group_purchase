import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:group_purchase/gui/list_view.dart';
import 'package:group_purchase/gui/settings.dart';
import 'package:group_purchase/services/database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'login.dart';
import 'logout.dart';

class MainPage extends StatefulWidget {
  final String deviceId;
  const MainPage({super.key, required this.deviceId});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Map _source = {ConnectivityResult.none: false};
  final MyConnectivity _connectivity = MyConnectivity.instance;
  String string = '';
  DatabaseService databaseService = new DatabaseService();
  TextEditingController listNameTextEditingController =
      new TextEditingController();
  User? user;
  @override
  void initState() {
    super.initState();
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      _source = source;
      switch (_source.keys.toList()[0]) {
        case ConnectivityResult.mobile:
          string = 'Online';
          break;
        case ConnectivityResult.wifi:
          string = 'Online';
          break;
        case ConnectivityResult.none:
        default:
          string = 'Offline';
      }
      setState(() {});
    });
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

  dynamic anonListSnapshot;

  Future initiateAnonListLoad() async {
    await databaseService.getLists(widget.deviceId).then((val) {
      if (!mounted) return;
      setState(() {
        anonListSnapshot = val;
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
                  listName: listSnapshot.docs[index].data()['listId']!,
                  id: listSnapshot.docs[index].reference.id.toString(),
                  deviceId: widget.deviceId,
                  count: listSnapshot.docs[index].data()['count']!.toString(),
                  bought: listSnapshot.docs[index].data()['bought']!.toString(),
                );
              })
          : Container();
    } else {
      initiateAnonListLoad();
      return anonListSnapshot != null
          ? ListView.builder(
              itemCount: anonListSnapshot.docs.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ListTile(
                  listName: anonListSnapshot.docs[index].data()['listId']!,
                  id: anonListSnapshot.docs[index].reference.id.toString(),
                  deviceId: widget.deviceId,
                  count:
                      anonListSnapshot.docs[index].data()['count']!.toString(),
                  bought:
                      anonListSnapshot.docs[index].data()['bought']!.toString(),
                );
              })
          : Container(); // W przyszłości listy dla użytkowników bez konta
    }
  }

  @override
  Widget build(BuildContext context) {
    return string != 'Offline'
        ? Scaffold(
            backgroundColor: Color.fromARGB(255, 231, 229, 229),
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
                                  devId: widget.deviceId,
                                )),
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
                                  onSignOut: (userCred) =>
                                      onRefresh(userCred))));
                    }),
              ],
            ),
            body: SingleChildScrollView(
              child: listWidget(),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
              onPressed: () {
                if (user != null) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        _buildPopupDialogNewList(context),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        _buildPopupDialogNewAnonList(context),
                  ); // FUnkcja dodająca listy dla użytkownika bez konta
                }
              },
            ),
          )
        : Scaffold(
            backgroundColor: Color.fromARGB(255, 231, 229, 229),
            appBar: AppBar(
              backgroundColor: Colors.grey,
              title: Center(child: const Text('Brak połączenia z internetem')),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 95,
                    backgroundColor: Colors.grey,
                    child: CircleAvatar(
                      radius: 92,
                      backgroundImage: AssetImage(
                        'assets/images/no_connection.png',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    'Offline',
                    style: TextStyle(fontSize: 40),
                  ),
                ],
              ),
            ),
          );
  }

  addList(String? listName) {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email)
        .addNewList(listName, [FirebaseAuth.instance.currentUser!.email]);
  }

  addAnonList(String? listName, String? index) {
    DatabaseService(uid: index).addNewList(listName, [index]);
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
            setState(() {
              listNameTextEditingController = new TextEditingController();
            });
          },
          child: const Text('Zamknij'),
        ),
      ],
    );
  }

  Widget _buildPopupDialogNewAnonList(BuildContext context) {
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
              addAnonList(listNameTextEditingController.text.capitalize(),
                  widget.deviceId);
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
            setState(() {
              listNameTextEditingController = new TextEditingController();
            });
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

  @override
  void dispose() {
    _connectivity.disposeStream();
    super.dispose();
  }
}

class ListTile extends StatefulWidget {
  final String listName;
  final String id;
  final String deviceId;
  final String count;
  final String bought;
  const ListTile(
      {super.key,
      required this.listName,
      required this.id,
      required this.deviceId,
      required this.count,
      required this.bought});

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
                    devicId: widget.deviceId,
                  )),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 5,
          shadowColor: Colors.black,
          child: ClipPath(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.green, width: 5),
                ),
              ),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      Text(
                        widget.listName,
                        style: TextStyle(fontSize: 20),
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      // Zliczanie produktów
                      Text(
                        widget.bought + "/" + widget.count,
                        style: TextStyle(fontSize: 20),
                      )
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class MyConnectivity {
  MyConnectivity._();

  static final _instance = MyConnectivity._();
  static MyConnectivity get instance => _instance;
  final _connectivity = Connectivity();
  final _controller = StreamController.broadcast();
  Stream get myStream => _controller.stream;

  void initialise() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    _checkStatus(result);
    _connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    _controller.sink.add({result: isOnline});
  }

  void disposeStream() => _controller.close();
}
