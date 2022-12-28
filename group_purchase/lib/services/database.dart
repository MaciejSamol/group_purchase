import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // collectio nreference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
}
