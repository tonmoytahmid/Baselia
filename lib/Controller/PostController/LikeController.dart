import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Likecontroller extends GetxController{
  Future<void> toggleLike(String postId, String userId) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final DocumentReference postRef = firestore.collection('posts').doc(postId);

  
  await firestore.runTransaction((transaction) async {
    DocumentSnapshot postSnapshot = await transaction.get(postRef);

    if (!postSnapshot.exists) return;

    List<dynamic> likedBy = postSnapshot['likes'] ?? [];
    int likeCount = postSnapshot['likecount'] ?? 0;

    if (likedBy.contains(userId)) {
     
      transaction.update(postRef, {
        'likes': FieldValue.arrayRemove([userId]),
        'likecount': likeCount > 0 ? FieldValue.increment(-1) : 0,
      });
    } else {
     
      transaction.update(postRef, {
        'likes': FieldValue.arrayUnion([userId]),
        'likecount': FieldValue.increment(1),
      });
    }
  });
}

}