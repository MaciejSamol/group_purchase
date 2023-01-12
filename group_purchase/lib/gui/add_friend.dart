import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_purchase/services/database.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  DatabaseService databaseService = new DatabaseService();
  TextEditingController searchTextEditingController =
      new TextEditingController();

  dynamic searchSnapshot;

  initiateSearch() {
    if (searchTextEditingController.text !=
        FirebaseAuth.instance.currentUser!.email) {
      databaseService
          .getUserByEmail(searchTextEditingController.text)
          .then((val) {
        setState(() {
          searchSnapshot = val;
        });
      });
    } else {
      searchSnapshot = null;
    }
  }

  Widget searchList() {
    return searchSnapshot != null
        ? ListView.builder(
            itemCount: searchSnapshot.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return SearchTile(
                friendName: searchSnapshot.docs[index].data()['name']!,
                friendEmail: searchSnapshot.docs[index].data()['email']!,
              );
            })
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dodaj znajomego"),
        backgroundColor: Colors.green,
      ), // Pasek górny
      body: Container(
        child: Column(
          children: [
            Container(
              color: Colors.green[300], //kolor paska wyszukiwania
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchTextEditingController,
                      decoration: InputDecoration(
                        hintText: 'wprowadź email',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      initiateSearch();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          const Color(0xFF66BB6A),
                          const Color(0xFF2E7D32)
                        ]),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Image.asset('assets/images/search_white.png'),
                    ),
                  ),
                ],
              ),
            ),
            searchList()
          ],
        ),
      ),
    );
  }
}

class SearchTile extends StatelessWidget {
  final String friendName;
  final String friendEmail;
  const SearchTile(
      {super.key, required this.friendName, required this.friendEmail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(friendName),
            Text(friendEmail),
          ],
        ),
        Spacer(),
        GestureDetector(
          onTap: () {
            sendRequest(friendEmail); // funkcja odpowiedzialna za wysłanie friend requesta
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text("Dodaj"),
          ),
        )
      ]),
    );
  }
  
  sendRequest(String friendEmail) {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.email).sendFriendRequest(FirebaseAuth.instance.currentUser!.email, friendEmail); 
  }
}
