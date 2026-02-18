import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ForumsCommentsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  var expandedReplies = <String, bool>{}.obs;

  
  Stream<QuerySnapshot> fetchComments(String postId) {
    return _firestore
        .collection('Forums')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> fetchReplies(String postId, String commentId) {
    return _firestore
        .collection('Forums')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  
Future<void> addComment(String postId, String userId, String text) async {
  try {
    
    CollectionReference comments =
        _firestore.collection('Forums').doc(postId).collection('comments');

   
    DocumentReference docRef = await comments.add({
      'userId': userId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'reactions': {}, 
      'likeCount': 0, 
    });

   
    await Future.delayed(Duration(milliseconds: 300));

    
    if (docRef.id.isNotEmpty) {
      await docRef.update({'commentId': docRef.id});
    } else {
      throw Exception("Failed to generate comment ID");
    }

   
    await _firestore.collection('Forums').doc(postId).update({
      'commentcount': FieldValue.increment(1),
    });

    print("✅ Comment added successfully with ID: ${docRef.id}");
  } catch (e) {
    print("❌ Error adding comment: $e");
  }
}



  
  Future<void> addReply(String postId, String commentId, String userId, String text) async {
    CollectionReference replies = _firestore
        .collection('Forums')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies');

    await replies.add({
      'userId': userId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'reactions': {},
    });
  }

  
  void toggleReplies(String commentId) {
    expandedReplies.update(commentId, (value) => !value, ifAbsent: () => true);
  }

  
  
}
