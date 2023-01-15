import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/animation.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});
  // collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  // Funkcja tworząca kolekcję użytkowników
  Future updateUserData(String? name, String? email, String? id) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'email': email,
      'id': id,
    });
  }

  // Funkcja stworzona w celu wyszukiwania użytkownika w bazie za pomocą emaila
  getUserByEmail(String? email) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
  }

  // Funkcja bazy danych odpowiedzialna za przesłanie zaproszenia
  Future sendFriendRequest(String? currentUserEmail, String? currentUserName,
      String? friendEmail) async {
    return await userCollection
        .doc(friendEmail)
        .collection('requests')
        .doc(currentUserEmail)
        .set({
      'requestFromEmail': currentUserEmail,
      'requestFromName': currentUserName,
      'requestTo': friendEmail,
    });
  }

  // Funkcja pobierająca zaproszenia z bazy
  getFriendRequests(String? currentUserEmail) {
    return userCollection.doc(currentUserEmail).collection('requests').get();
  }

  //Funkcja odpowiedzialna za akceptację zaproszenia po stronie użytkownika
  Future acceptFriendRequestUser(
      String? currentUserEmail, String? friendEmail, String? friendName) async {
    return await userCollection
        .doc(currentUserEmail)
        .collection('friends')
        .doc(friendEmail)
        .set({
      'friendEmail': friendEmail,
      'friendName': friendName,
    });
  }

  //Funkcja odpowiedzialna za akceptację zaproszenia po stronie przyjaciela
  Future acceptFriendRequestFriend(String? currentUserEmail,
      String? currentUserName, String? friendEmail) async {
    return await userCollection
        .doc(friendEmail)
        .collection('friends')
        .doc(currentUserEmail)
        .set({
      'friendEmail': currentUserEmail,
      'friendName': currentUserName,
    });
  }

  //Funkcja odpowiedzialna za odrzucenie zaproszenia
  Future deleteFriendRequest(
      String? currentUserEmail, String? friendEmail) async {
    return await userCollection
        .doc(currentUserEmail)
        .collection('requests')
        .doc(friendEmail)
        .delete();
  }

  //Funkcja odpowiedzialna za pobranie listy znajomych
  getFriendList(String? currentUserEmail) {
    return userCollection.doc(currentUserEmail).collection('friends').get();
  }

  //Funkcja odpowiedzialna za usunięcie z listy znajomych po stronie użytkownika
  Future deleteFriendUser(String? currentUserEmail, String? friendEmail) async {
    return await userCollection
        .doc(currentUserEmail)
        .collection('friends')
        .doc(friendEmail)
        .delete();
  }

  //Funkcja odpowiedzialna za usunięcie z listy znajomych po stronie przyjaciela
  Future deleteFriendFriend(
      String? currentUserEmail, String? friendEmail) async {
    return await userCollection
        .doc(friendEmail)
        .collection('friends')
        .doc(currentUserEmail)
        .delete();
  }

  //Funkcja tworząca kolekcję list użytkownika
  Future addNewList(String? listName) async {
    return await userCollection.doc(uid).collection('lists').doc().set({
      'listName': listName,
    });
  }

  //Funkcja pobierająca listy z bazy
  getLists(String? currentUserEmail) {
    return userCollection.doc(currentUserEmail).collection('lists').get();
  }
}
