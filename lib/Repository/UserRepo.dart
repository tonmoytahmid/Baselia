import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/UserModel.dart';

Stream<Usermodel?> getUserStream(String uid) {
  return FirebaseFirestore.instance
      .collection('Users')
      .doc(uid)
      .snapshots()
      .map((snapshot) {
    if (snapshot.exists) {
      return Usermodel.fromMap(snapshot.data()!);
    }
    return null;
  });
}

Future<String> fetchProfilePic(String uid) async {
  DocumentSnapshot doc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
  return (doc.data() as Map<String, dynamic>)['profileImage'] ?? '';
}

Future<String> fetchCoverPic(String uid) async {
  DocumentSnapshot doc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
  return (doc.data() as Map<String, dynamic>)['coverImage'] ?? '';
}



