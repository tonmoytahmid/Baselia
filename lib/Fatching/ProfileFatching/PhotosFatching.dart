import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> fetchUserPosts(String userId) async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .get();

    List<Map<String, dynamic>> posts = [];
    for (var doc in snapshot.docs) {
      var postData = doc.data() as Map<String, dynamic>;
     
      if (postData['image_media'] != null || postData['video_media'] != null) {
        posts.add(postData);
      }
    }
    return posts;
  } catch (e) {
    print("Error fetching user posts: $e");
    return [];
  }
}
