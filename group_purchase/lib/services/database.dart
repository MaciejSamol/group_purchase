import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});
  // collectio nreference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Future updateUserData(String? name, String? email, String? id) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'email': email,
      'id': id,
    });
  }
}
