/* Plik obsługujący wszystkie zapytania do bazy danych.
W projekcie skorzystano z nowego rozwiązania od firmy Google - "Cloud Firestore" 
Jest to nowa, usprawniona wersja bazy danych, która pozwala między innymi na:
- aktualizację danych w czasie rzeczywistym
- synchronizację offline
- skalowalność
*/

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});
  // collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  // Funkcja tworząca kolekcję użytkowników
  Future updateUserData(
      String? name, String? surname, String? email, String? id) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'surname': surname,
      'email': email,
      'id': id,
    });
  }

  // Funkcja stworzona w celu wyszukiwania użytkownika w bazie za pomocą emaila
  getUserByEmail(String? email) {
    return userCollection.where('email', isEqualTo: email).get();
  }

  // Funkcja bazy danych odpowiedzialna za przesłanie zaproszenia
  Future sendFriendRequest(String? currentUserEmail, String? currentUserName,
      String? currentUserSurname, String? friendEmail) async {
    return await userCollection
        .doc(friendEmail)
        .collection('requests')
        .doc(currentUserEmail)
        .set({
      'requestFromEmail': currentUserEmail,
      'requestFromName': currentUserName,
      'requestFromSurname': currentUserSurname,
      'requestTo': friendEmail,
    });
  }

  // Funkcja pobierająca zaproszenia z bazy
  getFriendRequests(String? currentUserEmail) {
    return userCollection.doc(currentUserEmail).collection('requests').get();
  }

  //Funkcja odpowiedzialna za akceptację zaproszenia po stronie użytkownika
  Future acceptFriendRequestUser(String? currentUserEmail, String? friendEmail,
      String? friendName, String? friendSurname) async {
    return await userCollection
        .doc(currentUserEmail)
        .collection('friends')
        .doc(friendEmail)
        .set({
      'friendEmail': friendEmail,
      'friendName': friendName,
      'friendSurname': friendSurname,
    });
  }

  //Funkcja odpowiedzialna za akceptację zaproszenia po stronie przyjaciela
  Future acceptFriendRequestFriend(
      String? currentUserEmail,
      String? currentUserName,
      String? friendEmail,
      String? currentUserSurname) async {
    return await userCollection
        .doc(friendEmail)
        .collection('friends')
        .doc(currentUserEmail)
        .set({
      'friendEmail': currentUserEmail,
      'friendName': currentUserName,
      'friendSurname': currentUserSurname,
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

  //Funkcja tworząca kolekcję list produktów użytkownika -- tutaj
  Future addNewList(String? listName, usersArray) async {
    return await FirebaseFirestore.instance.collection('lists').doc().set({
      'count': 0,
      'bought': 0,
      'listId': listName,
      'users': usersArray,
    });
  }

  //Funkcja pobierająca listy z bazy
  getLists(String? currentUserEmail) {
    return FirebaseFirestore.instance
        .collection('lists')
        .where('users', arrayContains: currentUserEmail)
        .get();
  }

  //Funkcja kasująca całą listę
  Future deleteList(String? index) async {
    return await FirebaseFirestore.instance
        .collection('lists')
        .doc(index)
        .delete();
  }

  //Funkcja odpowiedzialna za dodawanie produktu do bazy danych
  Future addProduct(String? index, String product, String userName,
      String userSurname) async {
    return await FirebaseFirestore.instance
        .collection('lists')
        .doc(index)
        .collection('products')
        .doc(product)
        .set({
      'name': product,
      'addBy': userName + ' ' + userSurname,
      'isChecked': false,
    }, SetOptions(merge: true));
  }

  //Funkcja pobierająca produkty z listy
  getProducts(String? index) {
    return FirebaseFirestore.instance
        .collection('lists')
        .doc(index)
        .collection('products')
        .get();
  }

  //Funkcja kasująca produkt z listy
  Future deleteProduct(String? index, String? name) async {
    return await FirebaseFirestore.instance
        .collection('lists')
        .doc(index)
        .collection('products')
        .doc(name)
        .delete();
  }

  //Funkcja odpowiedzialna za dodanie znajomego do listy produktów
  Future addFriendToList(String? index, usersArray) async {
    return await FirebaseFirestore.instance
        .collection('lists')
        .doc(index)
        .update({
      'users': FieldValue.arrayUnion(usersArray),
    });
  }

  //Funkcja odpowiedzialna za usunięcie znajomego z listy produktów
  Future deleteFriendFromList(String? index, usersArray) async {
    return await FirebaseFirestore.instance
        .collection('lists')
        .doc(index)
        .update({
      'users': FieldValue.arrayRemove(usersArray),
    });
  }

  //Funkcja nadpisująca wartość isChecked
  Future isCheckedUpdate(
      String? index, String product, bool? isCheckedValue) async {
    return await FirebaseFirestore.instance
        .collection('lists')
        .doc(index)
        .collection('products')
        .doc(product)
        .update({
      'isChecked': isCheckedValue,
    });
  }

  // Funkcja inkrementująca liczbę produktów znajdujących się w liście
  Future addToCount(String? index) async {
    return await FirebaseFirestore.instance
        .collection('lists')
        .doc(index)
        .update({
      'count': FieldValue.increment(1),
    });
  }

  // Funkcja dekrementująca liczbę produktów znajdujących się w liście
  Future deleteFromCount(String index) async {
    return await FirebaseFirestore.instance
        .collection('lists')
        .doc(index)
        .update({
      'count': FieldValue.increment(-1),
    });
  }

  // Funkcja inkrementująca liczbę zakupionyhc produktów w liście
  Future addToBought(String index) async {
    return await FirebaseFirestore.instance
        .collection('lists')
        .doc(index)
        .update({
      'bought': FieldValue.increment(1),
    });
  }

  // Funkcja dekrementująca liczbę zakupionych produktów w liście
  Future deleteFromBought(String index) async {
    return await FirebaseFirestore.instance
        .collection('lists')
        .doc(index)
        .update({
      'bought': FieldValue.increment(-1),
    });
  }

  // FUnkcja pobierająca pola z konkretnej listy takie jak lista użytkowników, liczba zakupionych produktów
  getUsersList(String index) {
    return FirebaseFirestore.instance.collection('lists').doc(index).get();
  }
}
