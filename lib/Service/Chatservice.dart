import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Stream<List<Map<String, dynamic>>> getChats() {
    return _firestore.collection('chats')
      .where('membersIds', arrayContains: currentUserId) 
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return doc.data();
        }).toList();
      });
  }

  Future<void> markMessagesAsRead(String chatId, String currentUserId) async {
    try {
     
      QuerySnapshot unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('read', isEqualTo: false)
          .where('senderId', isNotEqualTo: currentUserId) 
          .get();

     
      for (var messageDoc in unreadMessages.docs) {
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(messageDoc.id)
            .update({
          'read': true, 
        });
      }
    } catch (e) {
      print("Error marking messages as read: $e");
    }
  }
}
