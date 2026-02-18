import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> fetchFollowersAndFollowing(String userId) async {
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      List<dynamic> followers = userData['followers'] ?? [];
      List<dynamic> following = userData['following'] ?? [];

      print('Followers: $followers');
      print('Following: $following');
    } else {
      print('User not found');
    }
  } catch (e) {
    print('Error fetching followers and following: $e');
  }
}