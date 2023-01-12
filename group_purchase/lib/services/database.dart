import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});
  // collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Future updateUserData(String? name, String? email, String? id) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'email': email,
      'id': id,
    });
  }

  getUserByEmail(String? email) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
  }

  Future sendFriendRequest(
      String? currentUserEmail, String? friendEmail) async {
    return await userCollection
        .doc(friendEmail)
        .collection('requests')
        .doc(currentUserEmail)
        .set({
      'requestFrom': currentUserEmail,
      'requestTo': friendEmail,
    });
  }
}
